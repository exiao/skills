#!/usr/bin/env bash
set -euo pipefail

# reports.sh — Apple Search Ads performance reporting
#
# Usage:
#   reports.sh campaigns --start DATE --end DATE [--granularity DAILY|WEEKLY|MONTHLY]
#   reports.sh keywords <campaign_id> --start DATE --end DATE [--sort FIELD] [--limit N]
#   reports.sh search-terms <campaign_id> --start DATE --end DATE [--min-impressions N]
#   reports.sh adgroups <campaign_id> --start DATE --end DATE
#   reports.sh wasted-spend --start DATE --end DATE [--min-spend AMT] [--max-installs N]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/asa-api.sh"

_build_report_body() {
  local start="$1" end="$2" granularity="${3:-DAILY}" sort_field="${4:-localSpend}" limit="${5:-100}"
  local conditions="${6:-[]}"

  jq -n \
    --arg start "$start" \
    --arg end "$end" \
    --arg gran "$granularity" \
    --arg sort "$sort_field" \
    --argjson limit "$limit" \
    --argjson conditions "$conditions" \
    '{
      startTime: $start,
      endTime: $end,
      timeZone: "UTC",
      granularity: $gran,
      selector: {
        conditions: $conditions,
        orderBy: [{field: $sort, sortOrder: "DESCENDING"}],
        pagination: {offset: 0, limit: $limit}
      },
      returnRowTotals: true,
      returnGrandTotals: true
    }'
}

cmd_campaigns() {
  local start="" end="" granularity="DAILY"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --granularity) granularity="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$start" || -z "$end" ]]; then
    echo "ERROR: --start and --end are required (YYYY-MM-DD)" >&2
    return 1
  fi

  local body
  body=$(_build_report_body "$start" "$end" "$granularity")
  local response
  response=$(asa_api POST "/reports/campaigns" "$body") || return 1

  # Print summary table
  echo "=== Campaign Performance: $start to $end ==="
  echo ""
  echo "$response" | jq -r '
    .data.reportingDataResponse.row[]? |
    [.metadata.campaignName,
     .total.localSpend.amount,
     .total.impressions,
     .total.taps,
     (.total.tapInstalls // .total.installs // 0),
     (.total.totalInstalls // 0),
     (.total.tapInstallCPI.amount // "N/A"),
     (.total.totalAvgCPI.amount // "N/A"),
     (.total.tapInstallRate // "N/A"),
     (.total.totalInstallRate // "N/A"),
     .total.ttr] |
    @tsv' | column -t -s $'\t' | {
      echo "CAMPAIGN  SPEND  IMPRESSIONS  TAPS  TAP_INSTALLS  TOTAL_INSTALLS  TAP_CPI  TOTAL_CPI  TAP_INSTALL_RATE  TOTAL_INSTALL_RATE  TTR"
      cat
    }

  # Print grand totals
  echo ""
  echo "$response" | jq -r '
    .data.reportingDataResponse.grandTotals? //empty |
    "TOTALS: Spend=\(.localSpend.amount) Impressions=\(.impressions) Taps=\(.taps) TapInstalls=\(.tapInstalls // 0) TotalInstalls=\(.totalInstalls // 0) TapCPI=\(.tapInstallCPI.amount // "N/A") TotalCPI=\(.totalAvgCPI.amount // "N/A")"'
}

cmd_keywords() {
  local cid="$1"; shift
  local start="" end="" sort_field="localSpend" limit="50"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --sort) sort_field="$2"; shift 2 ;;
      --limit) limit="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$start" || -z "$end" ]]; then
    echo "ERROR: --start and --end are required" >&2
    return 1
  fi

  local body
  body=$(_build_report_body "$start" "$end" "DAILY" "$sort_field" "$limit")
  local response
  response=$(asa_api POST "/reports/campaigns/${cid}/keywords" "$body") || return 1

  echo "=== Keyword Performance: $start to $end ==="
  echo ""
  echo "$response" | jq -r '
    .data.reportingDataResponse.row[]? |
    [.metadata.keyword,
     .metadata.matchType,
     .total.localSpend.amount,
     .total.impressions,
     .total.taps,
     (.total.tapInstalls // .total.installs // 0),
     (.total.totalInstalls // 0),
     (.total.tapInstallCPI.amount // "N/A"),
     (.total.totalAvgCPI.amount // "N/A"),
     (.total.tapInstallRate // "N/A")] |
    @tsv' | column -t -s $'\t' | {
      echo "KEYWORD  MATCH  SPEND  IMPRESSIONS  TAPS  TAP_INSTALLS  TOTAL_INSTALLS  TAP_CPI  TOTAL_CPI  TAP_INSTALL_RATE"
      cat
    }
}

cmd_search_terms() {
  local cid="$1"; shift
  local start="" end="" min_impressions="10"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --min-impressions) min_impressions="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$start" || -z "$end" ]]; then
    echo "ERROR: --start and --end are required" >&2
    return 1
  fi

  local conditions
  conditions=$(jq -n --arg v "$min_impressions" \
    '[{"field":"impressions","operator":"GREATER_THAN","values":[$v]}]')

  # Search terms API doesn't support granularity — use returnRowTotals only
  local body
  body=$(jq -n \
    --arg start "$start" \
    --arg end "$end" \
    --argjson conditions "$conditions" \
    '{
      startTime: $start,
      endTime: $end,
      timeZone: "UTC",
      selector: {
        conditions: $conditions,
        orderBy: [{field: "localSpend", sortOrder: "DESCENDING"}],
        pagination: {offset: 0, limit: 1000}
      },
      returnRowTotals: true,
      returnGrandTotals: true
    }')
  local response
  response=$(asa_api POST "/reports/campaigns/${cid}/searchterms" "$body") || return 1

  echo "=== Search Terms: $start to $end (min $min_impressions impressions) ==="
  echo ""
  echo "$response" | jq -r '
    .data.reportingDataResponse.row[]? |
    [.metadata.searchTermText,
     .metadata.keyword,
     .metadata.matchType,
     .total.localSpend.amount,
     .total.impressions,
     .total.taps,
     (.total.tapInstalls // .total.installs // 0),
     (.total.totalInstalls // 0),
     (.total.tapInstallCPI.amount // "N/A"),
     (.total.totalAvgCPI.amount // "N/A")] |
    @tsv' | column -t -s $'\t' | {
      echo "SEARCH_TERM  KEYWORD  MATCH  SPEND  IMPRESSIONS  TAPS  TAP_INSTALLS  TOTAL_INSTALLS  TAP_CPI  TOTAL_CPI"
      cat
    }
}

cmd_adgroups() {
  local cid="$1"; shift
  local start="" end=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$start" || -z "$end" ]]; then
    echo "ERROR: --start and --end are required" >&2
    return 1
  fi

  local body
  body=$(_build_report_body "$start" "$end")
  local response
  response=$(asa_api POST "/reports/campaigns/${cid}/adgroups" "$body") || return 1

  echo "=== Ad Group Performance: $start to $end ==="
  echo ""
  echo "$response" | jq -r '
    .data.reportingDataResponse.row[]? |
    [.metadata.adGroupName,
     .total.localSpend.amount,
     .total.impressions,
     .total.taps,
     .total.installs,
     (if .total.installs > 0 then
       ((.total.localSpend.amount | tonumber) / .total.installs * 100 | round / 100 | tostring)
      else "N/A" end)] |
    @tsv' | column -t -s $'\t' | {
      echo "AD_GROUP  SPEND  IMPRESSIONS  TAPS  INSTALLS  CPA"
      cat
    }
}

cmd_wasted_spend() {
  local start="" end="" min_spend="10" max_installs="0"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --min-spend) min_spend="$2"; shift 2 ;;
      --max-installs) max_installs="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$start" || -z "$end" ]]; then
    echo "ERROR: --start and --end are required" >&2
    return 1
  fi

  # Get all campaigns first
  local campaigns
  campaigns=$(asa_api GET "/campaigns" | jq -r '.data[]?.id') || return 1

  echo "=== Wasted Spend Report: $start to $end ==="
  echo "Criteria: spend >= \$$min_spend, installs <= $max_installs"
  echo ""

  local total_wasted=0

  for cid in $campaigns; do
    local body
    body=$(_build_report_body "$start" "$end" "DAILY" "localSpend" "1000")
    local response
    response=$(asa_api POST "/reports/campaigns/${cid}/keywords" "$body") 2>/dev/null || continue

    echo "$response" | jq -r --arg ms "$min_spend" --argjson mi "$max_installs" '
      .data.reportingDataResponse.row[]? |
      select((.total.localSpend.amount | tonumber) >= ($ms | tonumber)) |
      select((.total.tapInstalls // .total.installs // 0) <= $mi) |
      [.metadata.keyword, .metadata.matchType,
       .total.localSpend.amount, .total.impressions,
       .total.taps, (.total.tapInstalls // .total.installs // 0)] |
      @tsv'
  done | column -t -s $'\t' | {
    echo "KEYWORD  MATCH  SPEND  IMPRESSIONS  TAPS  INSTALLS"
    cat
  }
}

# Main dispatch
case "${1:-help}" in
  campaigns)     shift; cmd_campaigns "$@" ;;
  keywords)      shift; cmd_keywords "$@" ;;
  search-terms)  shift; cmd_search_terms "$@" ;;
  adgroups)      shift; cmd_adgroups "$@" ;;
  wasted-spend)  shift; cmd_wasted_spend "$@" ;;
  help|*)
    echo "Usage: reports.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  campaigns --start DATE --end DATE [--granularity DAILY|WEEKLY|MONTHLY]"
    echo "  keywords <campaign_id> --start DATE --end DATE [--sort FIELD] [--limit N]"
    echo "  search-terms <campaign_id> --start DATE --end DATE [--min-impressions N]"
    echo "  adgroups <campaign_id> --start DATE --end DATE"
    echo "  wasted-spend --start DATE --end DATE [--min-spend AMT] [--max-installs N]"
    ;;
esac
