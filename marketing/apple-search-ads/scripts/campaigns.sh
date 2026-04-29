#!/usr/bin/env bash
set -euo pipefail

# campaigns.sh — Apple Search Ads campaign management
#
# Usage:
#   campaigns.sh list [--status ENABLED|PAUSED]
#   campaigns.sh get <campaign_id>
#   campaigns.sh create --name NAME --app-id ID --budget AMOUNT --countries US,GB [--supply-source APPSTORE_SEARCH_RESULTS]
#   campaigns.sh update <campaign_id> [--status ENABLED|PAUSED] [--daily-budget AMOUNT] [--name NAME]
#   campaigns.sh pause <campaign_id>
#   campaigns.sh enable <campaign_id>
#   campaigns.sh setup-structure --app-id ID --countries US --daily-budget AMOUNT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/asa-api.sh"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

cmd_list() {
  local status=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --status) status="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  local response
  if [[ -n "$status" ]]; then
    response=$(asa_api POST "/campaigns/find" "$(jq -n --arg s "$status" '{
      "selector": {
        "conditions": [{"field":"status","operator":"EQUALS","values":[$s]}],
        "orderBy": [{"field":"id","sortOrder":"ASCENDING"}],
        "pagination": {"offset":0,"limit":100}
      }
    }')") || return 1
  else
    response=$(asa_api GET "/campaigns") || return 1
  fi

  echo "$response" | jq -r '
    .data[]? | [.id, .name, .status, .supplySources[0] // "N/A",
      (.dailyBudgetAmount.amount // "N/A"),
      (.budgetAmount.amount // "N/A")] |
    @tsv' | column -t -s $'\t' | {
      echo "ID  NAME  STATUS  SUPPLY_SOURCE  DAILY_BUDGET  TOTAL_BUDGET"
      cat
    }
}

cmd_get() {
  local campaign_id="$1"
  asa_api GET "/campaigns/${campaign_id}" | jq '.data'
}

cmd_create() {
  local name="" app_id="" budget="" daily_budget="" countries="" supply_source="APPSTORE_SEARCH_RESULTS"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name) name="$2"; shift 2 ;;
      --app-id) app_id="$2"; shift 2 ;;
      --budget) budget="$2"; shift 2 ;;
      --daily-budget) daily_budget="$2"; shift 2 ;;
      --countries) countries="$2"; shift 2 ;;
      --supply-source) supply_source="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$name" || -z "$app_id" || -z "$countries" ]]; then
    echo "ERROR: --name, --app-id, and --countries are required" >&2
    return 1
  fi

  # Build countries array
  local countries_json
  countries_json=$(echo "$countries" | tr ',' '\n' | jq -R . | jq -s .)

  local body
  body=$(jq -n \
    --arg name "$name" \
    --argjson adamId "$app_id" \
    --argjson countries "$countries_json" \
    --arg supply "$supply_source" \
    --arg budget "${budget:-}" \
    --arg daily "${daily_budget:-}" \
    '{
      name: $name,
      adamId: $adamId,
      countriesOrRegions: $countries,
      supplySources: [$supply],
      billingEvent: "TAPS",
      status: "ENABLED"
    }
    + (if $budget != "" then {budgetAmount: {amount: $budget, currency: "USD"}} else {} end)
    + (if $daily != "" then {dailyBudgetAmount: {amount: $daily, currency: "USD"}} else {} end)')

  asa_api POST "/campaigns" "$body" | jq '.data'
}

cmd_update() {
  local campaign_id="$1"; shift
  local updates="{}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --status) updates=$(echo "$updates" | jq --arg v "$2" '.status = $v'); shift 2 ;;
      --daily-budget) updates=$(echo "$updates" | jq --arg v "$2" '.dailyBudgetAmount = {amount: $v, currency: "USD"}'); shift 2 ;;
      --name) updates=$(echo "$updates" | jq --arg v "$2" '.name = $v'); shift 2 ;;
      --budget) updates=$(echo "$updates" | jq --arg v "$2" '.budgetAmount = {amount: $v, currency: "USD"}'); shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  asa_api PUT "/campaigns/${campaign_id}" "$updates" | jq '.data'
}

cmd_pause() {
  cmd_update "$1" --status PAUSED
}

cmd_enable() {
  cmd_update "$1" --status ENABLED
}

cmd_setup_structure() {
  local app_id="" countries="" daily_budget=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --app-id) app_id="$2"; shift 2 ;;
      --countries) countries="$2"; shift 2 ;;
      --daily-budget) daily_budget="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$app_id" || -z "$countries" || -z "$daily_budget" ]]; then
    echo "ERROR: --app-id, --countries, and --daily-budget required" >&2
    return 1
  fi

  echo "Setting up recommended 4-campaign structure..."
  echo ""

  # Budget split: Brand 20%, Category 50%, Competitor 20%, Discovery 10%
  local brand_budget category_budget competitor_budget discovery_budget
  brand_budget=$(echo "$daily_budget * 0.20" | bc)
  category_budget=$(echo "$daily_budget * 0.50" | bc)
  competitor_budget=$(echo "$daily_budget * 0.20" | bc)
  discovery_budget=$(echo "$daily_budget * 0.10" | bc)

  local campaigns=("Brand:$brand_budget" "Category:$category_budget" "Competitor:$competitor_budget" "Discovery:$discovery_budget")

  for entry in "${campaigns[@]}"; do
    local ctype="${entry%%:*}"
    local cbudget="${entry##*:}"

    echo "Creating campaign: $ctype (daily budget: \$$cbudget)..."
    cmd_create --name "App ${app_id} - ${countries} - ${ctype}" \
      --app-id "$app_id" \
      --countries "$countries" \
      --daily-budget "$cbudget" 2>&1 | head -5

    echo ""
  done

  echo "Structure created. Next steps:"
  echo "  1. Create ad groups in each campaign"
  echo "  2. Add keywords (exact match for Brand/Category/Competitor, Search Match for Discovery)"
  echo "  3. Add negative keywords in Discovery to exclude terms covered by other campaigns"
}

# Main dispatch
case "${1:-help}" in
  list)          shift; cmd_list "$@" ;;
  get)           shift; cmd_get "$@" ;;
  create)        shift; cmd_create "$@" ;;
  update)        shift; cmd_update "$@" ;;
  pause)         shift; cmd_pause "$@" ;;
  enable)        shift; cmd_enable "$@" ;;
  setup-structure) shift; cmd_setup_structure "$@" ;;
  help|*)
    echo "Usage: campaigns.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list [--status ENABLED|PAUSED]"
    echo "  get <campaign_id>"
    echo "  create --name NAME --app-id ID --countries US,GB [--budget AMT] [--daily-budget AMT]"
    echo "  update <campaign_id> [--status S] [--daily-budget AMT] [--name N]"
    echo "  pause <campaign_id>"
    echo "  enable <campaign_id>"
    echo "  setup-structure --app-id ID --countries US --daily-budget AMT"
    ;;
esac
