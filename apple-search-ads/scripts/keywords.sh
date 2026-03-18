#!/usr/bin/env bash
set -euo pipefail

# keywords.sh — Apple Search Ads keyword management
#
# Usage:
#   keywords.sh list <campaign_id> <adgroup_id> [--status ACTIVE|PAUSED]
#   keywords.sh add <campaign_id> <adgroup_id> --text "keyword" --match EXACT|BROAD [--bid 1.50]
#   keywords.sh add-bulk <campaign_id> <adgroup_id> --file keywords.csv
#   keywords.sh bid <campaign_id> <adgroup_id> <keyword_id> --amount 2.00
#   keywords.sh pause <campaign_id> <adgroup_id> <keyword_id>
#   keywords.sh enable <campaign_id> <adgroup_id> <keyword_id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/asa-api.sh"

cmd_list() {
  local cid="$1" agid="$2"; shift 2
  local status=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --status) status="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  local response
  if [[ -n "$status" ]]; then
    response=$(asa_api POST "/campaigns/${cid}/adgroups/${agid}/targetingkeywords/find" "$(jq -n --arg s "$status" '{
      "selector": {
        "conditions": [{"field":"status","operator":"EQUALS","values":[$s]}],
        "pagination": {"offset":0,"limit":1000}
      }
    }')") || return 1
  else
    response=$(asa_api GET "/campaigns/${cid}/adgroups/${agid}/targetingkeywords") || return 1
  fi

  echo "$response" | jq -r '
    .data[]? | [.id, .text, .matchType, .status,
      (.bidAmount.amount // "default")] |
    @tsv' | column -t -s $'\t' | {
      echo "ID  TEXT  MATCH_TYPE  STATUS  BID"
      cat
    }
}

cmd_add() {
  local cid="$1" agid="$2"; shift 2
  local text="" match="EXACT" bid=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --text) text="$2"; shift 2 ;;
      --match) match="$2"; shift 2 ;;
      --bid) bid="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$text" ]]; then
    echo "ERROR: --text is required" >&2
    return 1
  fi

  local body
  body=$(jq -n \
    --arg text "$text" \
    --arg match "$match" \
    --arg bid "${bid:-}" \
    '[{
      text: $text,
      matchType: $match,
      status: "ACTIVE"
    }
    + (if $bid != "" then {bidAmount: {amount: $bid, currency: "USD"}} else {} end)]')

  asa_api POST "/campaigns/${cid}/adgroups/${agid}/targetingkeywords" "$body" | jq '.data'
}

cmd_add_bulk() {
  local cid="$1" agid="$2"; shift 2
  local file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file) file="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$file" || ! -f "$file" ]]; then
    echo "ERROR: --file is required and must exist" >&2
    echo "CSV format: text,matchType,bid" >&2
    echo "Example: investing app,EXACT,1.50" >&2
    return 1
  fi

  # Build JSON array from CSV (skip header if present)
  local keywords_json="[]"
  while IFS=',' read -r text match bid; do
    # Skip header row
    [[ "$text" == "text" ]] && continue
    [[ -z "$text" ]] && continue

    match="${match:-EXACT}"
    local kw
    kw=$(jq -n \
      --arg text "$text" \
      --arg match "$match" \
      --arg bid "${bid:-}" \
      '{text: $text, matchType: $match, status: "ACTIVE"}
       + (if $bid != "" then {bidAmount: {amount: $bid, currency: "USD"}} else {} end)')

    keywords_json=$(echo "$keywords_json" | jq --argjson kw "$kw" '. + [$kw]')
  done < "$file"

  local count
  count=$(echo "$keywords_json" | jq 'length')
  echo "Adding $count keywords..." >&2

  # Apple limits bulk operations; batch in groups of 1000
  local batch_size=1000
  local offset=0

  while [[ $offset -lt $count ]]; do
    local batch
    batch=$(echo "$keywords_json" | jq --argjson o "$offset" --argjson l "$batch_size" '.[$o:$o+$l]')
    local batch_count
    batch_count=$(echo "$batch" | jq 'length')

    echo "Sending batch: $batch_count keywords (offset $offset)..." >&2
    asa_api POST "/campaigns/${cid}/adgroups/${agid}/targetingkeywords" "$batch" | jq '.data | length | tostring + " keywords added"'

    offset=$(( offset + batch_size ))
  done
}

cmd_bid() {
  local cid="$1" agid="$2" kwid="$3"; shift 3
  local amount=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --amount) amount="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$amount" ]]; then
    echo "ERROR: --amount is required" >&2
    return 1
  fi

  local body
  body=$(jq -n --arg id "$kwid" --arg amt "$amount" \
    '[{"id": ($id | tonumber), "bidAmount": {"amount": $amt, "currency": "USD"}}]')

  asa_api PUT "/campaigns/${cid}/adgroups/${agid}/targetingkeywords" "$body" | jq '.data'
}

cmd_pause() {
  local cid="$1" agid="$2" kwid="$3"
  local body
  body=$(jq -n --arg id "$kwid" '[{"id": ($id | tonumber), "status": "PAUSED"}]')
  asa_api PUT "/campaigns/${cid}/adgroups/${agid}/targetingkeywords" "$body" | jq '.data'
}

cmd_enable() {
  local cid="$1" agid="$2" kwid="$3"
  local body
  body=$(jq -n --arg id "$kwid" '[{"id": ($id | tonumber), "status": "ACTIVE"}]')
  asa_api PUT "/campaigns/${cid}/adgroups/${agid}/targetingkeywords" "$body" | jq '.data'
}

# Main dispatch
case "${1:-help}" in
  list)      shift; cmd_list "$@" ;;
  add)       shift; cmd_add "$@" ;;
  add-bulk)  shift; cmd_add_bulk "$@" ;;
  bid)       shift; cmd_bid "$@" ;;
  pause)     shift; cmd_pause "$@" ;;
  enable)    shift; cmd_enable "$@" ;;
  help|*)
    echo "Usage: keywords.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list <campaign_id> <adgroup_id> [--status ACTIVE|PAUSED]"
    echo "  add <campaign_id> <adgroup_id> --text TEXT --match EXACT|BROAD [--bid AMT]"
    echo "  add-bulk <campaign_id> <adgroup_id> --file keywords.csv"
    echo "  bid <campaign_id> <adgroup_id> <keyword_id> --amount AMT"
    echo "  pause <campaign_id> <adgroup_id> <keyword_id>"
    echo "  enable <campaign_id> <adgroup_id> <keyword_id>"
    ;;
esac
