#!/usr/bin/env bash
set -euo pipefail

# search-terms.sh — Apple Search Ads search term mining and analysis
#
# Usage:
#   search-terms.sh report <campaign_id> --start DATE --end DATE
#   search-terms.sh winners <campaign_id> --start DATE --end DATE [--min-installs 3] [--max-cpa 5.00]
#   search-terms.sh losers <campaign_id> --start DATE --end DATE [--min-spend 20] [--max-installs 0]
#   search-terms.sh harvest <discovery_campaign_id> --target-campaign <id> --target-adgroup <id> --start DATE --end DATE [--cpa-threshold 5.00] [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/asa-api.sh"

_get_search_terms() {
  local cid="$1" start="$2" end="$3"

  local body
  body=$(jq -n --arg s "$start" --arg e "$end" '{
    startTime: $s,
    endTime: $e,
    timeZone: "UTC",
    granularity: "DAILY",
    selector: {
      conditions: [{"field":"impressions","operator":"GREATER_THAN","values":["5"]}],
      orderBy: [{"field":"localSpend","sortOrder":"DESCENDING"}],
      pagination: {"offset": 0, "limit": 1000}
    },
    returnRowTotals: true
  }')

  asa_api POST "/reports/campaigns/${cid}/searchterms" "$body"
}

cmd_report() {
  local cid="$1"; shift
  local start="" end=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  [[ -z "$start" || -z "$end" ]] && { echo "ERROR: --start and --end required" >&2; return 1; }

  local response
  response=$(_get_search_terms "$cid" "$start" "$end") || return 1

  echo "$response" | jq -r '
    .data.reportingDataResponse.row[]? |
    [.metadata.searchTermText, .metadata.keyword, .metadata.matchType,
     .total.localSpend.amount, .total.impressions, .total.taps, .total.installs,
     (if .total.installs > 0 then
       ((.total.localSpend.amount | tonumber) / .total.installs * 100 | round / 100 | tostring)
      else "N/A" end)] |
    @tsv' | column -t -s $'\t' | {
      echo "SEARCH_TERM  KEYWORD  MATCH  SPEND  IMPRESSIONS  TAPS  INSTALLS  CPA"
      cat
    }
}

cmd_winners() {
  local cid="$1"; shift
  local start="" end="" min_installs="3" max_cpa="5.00"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --min-installs) min_installs="$2"; shift 2 ;;
      --max-cpa) max_cpa="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  [[ -z "$start" || -z "$end" ]] && { echo "ERROR: --start and --end required" >&2; return 1; }

  local response
  response=$(_get_search_terms "$cid" "$start" "$end") || return 1

  echo "=== Winning Search Terms (installs >= $min_installs, CPA <= \$$max_cpa) ==="
  echo ""
  echo "$response" | jq -r --arg mi "$min_installs" --arg mc "$max_cpa" '
    [.data.reportingDataResponse.row[]? |
     select(.total.installs >= ($mi | tonumber)) |
     select(.total.installs > 0) |
     select(((.total.localSpend.amount | tonumber) / .total.installs) <= ($mc | tonumber))] |
    sort_by(-.total.installs)[] |
    [.metadata.searchTermText,
     .total.installs,
     ((.total.localSpend.amount | tonumber) / .total.installs * 100 | round / 100 | tostring),
     .total.localSpend.amount,
     .total.taps,
     .metadata.matchType] |
    @tsv' | column -t -s $'\t' | {
      echo "SEARCH_TERM  INSTALLS  CPA  SPEND  TAPS  MATCH_TYPE"
      cat
    }

  echo ""
  echo "Action: Add these as EXACT keywords in your exact-match campaign."
}

cmd_losers() {
  local cid="$1"; shift
  local start="" end="" min_spend="20" max_installs="0"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --min-spend) min_spend="$2"; shift 2 ;;
      --max-installs) max_installs="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  [[ -z "$start" || -z "$end" ]] && { echo "ERROR: --start and --end required" >&2; return 1; }

  local response
  response=$(_get_search_terms "$cid" "$start" "$end") || return 1

  echo "=== Losing Search Terms (spend >= \$$min_spend, installs <= $max_installs) ==="
  echo ""
  echo "$response" | jq -r --arg ms "$min_spend" --arg mi "$max_installs" '
    [.data.reportingDataResponse.row[]? |
     select((.total.localSpend.amount | tonumber) >= ($ms | tonumber)) |
     select(.total.installs <= ($mi | tonumber))] |
    sort_by(-.total.localSpend.amount | tonumber)[] |
    [.metadata.searchTermText,
     .total.localSpend.amount,
     .total.impressions,
     .total.taps,
     .total.installs] |
    @tsv' | column -t -s $'\t' | {
      echo "SEARCH_TERM  SPEND  IMPRESSIONS  TAPS  INSTALLS"
      cat
    }

  echo ""
  echo "Action: Add these as NEGATIVE EXACT keywords."
}

cmd_harvest() {
  local discovery_cid="$1"; shift
  local target_cid="" target_agid="" start="" end="" cpa_threshold="5.00" dry_run=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target-campaign) target_cid="$2"; shift 2 ;;
      --target-adgroup) target_agid="$2"; shift 2 ;;
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --cpa-threshold) cpa_threshold="$2"; shift 2 ;;
      --dry-run) dry_run=true; shift ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$target_cid" || -z "$target_agid" || -z "$start" || -z "$end" ]]; then
    echo "ERROR: --target-campaign, --target-adgroup, --start, --end required" >&2
    return 1
  fi

  local response
  response=$(_get_search_terms "$discovery_cid" "$start" "$end") || return 1

  # Extract winners
  local winners
  winners=$(echo "$response" | jq -r --arg mc "$cpa_threshold" '
    [.data.reportingDataResponse.row[]? |
     select(.total.installs >= 2) |
     select(.total.installs > 0) |
     select(((.total.localSpend.amount | tonumber) / .total.installs) <= ($mc | tonumber))] |
    .[].metadata.searchTermText')

  # Extract losers (spent > $20, zero installs)
  local losers
  losers=$(echo "$response" | jq -r '
    [.data.reportingDataResponse.row[]? |
     select((.total.localSpend.amount | tonumber) >= 20) |
     select(.total.installs == 0)] |
    .[].metadata.searchTermText')

  local winner_count loser_count
  winner_count=$(echo "$winners" | grep -c . || true)
  loser_count=$(echo "$losers" | grep -c . || true)

  echo "=== Harvest Results ==="
  echo "Winners to promote as EXACT keywords: $winner_count"
  echo "Losers to add as NEGATIVE keywords: $loser_count"
  echo ""

  if [[ "$winner_count" -gt 0 ]]; then
    echo "--- Winners ---"
    echo "$winners"
    echo ""
  fi

  if [[ "$loser_count" -gt 0 ]]; then
    echo "--- Losers ---"
    echo "$losers"
    echo ""
  fi

  if [[ "$dry_run" == true ]]; then
    echo "[DRY RUN] No changes made."
    return 0
  fi

  # Add winners as exact keywords
  if [[ "$winner_count" -gt 0 ]]; then
    echo "Adding $winner_count winners as EXACT keywords to campaign $target_cid, ad group $target_agid..."
    local kw_array="[]"
    while IFS= read -r term; do
      [[ -z "$term" ]] && continue
      kw_array=$(echo "$kw_array" | jq --arg t "$term" '. + [{"text":$t,"matchType":"EXACT","status":"ACTIVE"}]')
    done <<< "$winners"

    asa_api POST "/campaigns/${target_cid}/adgroups/${target_agid}/targetingkeywords" "$kw_array" | \
      jq '.data | length | tostring + " keywords added"'
  fi

  # Add losers as campaign-level negatives on the discovery campaign
  if [[ "$loser_count" -gt 0 ]]; then
    echo "Adding $loser_count losers as NEGATIVE keywords on discovery campaign $discovery_cid..."
    local neg_array="[]"
    while IFS= read -r term; do
      [[ -z "$term" ]] && continue
      neg_array=$(echo "$neg_array" | jq --arg t "$term" '. + [{"text":$t,"matchType":"EXACT","status":"ACTIVE"}]')
    done <<< "$losers"

    asa_api POST "/campaigns/${discovery_cid}/negativekeywords" "$neg_array" | \
      jq '.data | length | tostring + " negatives added"'
  fi

  echo ""
  echo "Harvest complete."
}

# Main dispatch
case "${1:-help}" in
  report)   shift; cmd_report "$@" ;;
  winners)  shift; cmd_winners "$@" ;;
  losers)   shift; cmd_losers "$@" ;;
  harvest)  shift; cmd_harvest "$@" ;;
  help|*)
    echo "Usage: search-terms.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  report <campaign_id> --start DATE --end DATE"
    echo "  winners <campaign_id> --start DATE --end DATE [--min-installs N] [--max-cpa AMT]"
    echo "  losers <campaign_id> --start DATE --end DATE [--min-spend AMT] [--max-installs N]"
    echo "  harvest <discovery_cid> --target-campaign ID --target-adgroup ID --start DATE --end DATE [--cpa-threshold AMT] [--dry-run]"
    ;;
esac
