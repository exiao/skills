#!/usr/bin/env bash
set -euo pipefail

# optimize.sh — Apple Search Ads bid optimization
#
# Usage:
#   optimize.sh audit <campaign_id> --start DATE --end DATE
#   optimize.sh bids <campaign_id> --start DATE --end DATE --target-cpa AMT
#   optimize.sh auto-bid <campaign_id> --start DATE --end DATE --target-cpa AMT [--max-bid AMT] [--min-bid AMT] [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/asa-api.sh"

_get_keyword_report() {
  local cid="$1" start="$2" end="$3"

  local body
  body=$(jq -n --arg s "$start" --arg e "$end" '{
    startTime: $s,
    endTime: $e,
    timeZone: "UTC",
    granularity: "DAILY",
    selector: {
      orderBy: [{"field":"localSpend","sortOrder":"DESCENDING"}],
      pagination: {"offset":0,"limit":1000}
    },
    returnRowTotals: true
  }')

  asa_api POST "/reports/campaigns/${cid}/keywords" "$body"
}

cmd_audit() {
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
  response=$(_get_keyword_report "$cid" "$start" "$end") || return 1

  echo "=== Campaign Audit: $start to $end ==="
  echo ""

  # High CPA keywords (spend > $10, CPA > $10)
  echo "--- HIGH CPA (> \$10, spend > \$10) ---"
  echo "$response" | jq -r '
    [.data.reportingDataResponse.row[]? |
     select((.total.localSpend.amount | tonumber) > 10) |
     select(.total.installs > 0) |
     select(((.total.localSpend.amount | tonumber) / .total.installs) > 10)] |
    sort_by(-((.total.localSpend.amount | tonumber) / .total.installs))[] |
    [.metadata.keyword, .metadata.matchType,
     ((.total.localSpend.amount | tonumber) / .total.installs * 100 | round / 100 | tostring),
     .total.localSpend.amount, .total.installs] |
    @tsv' | column -t -s $'\t' | {
      echo "KEYWORD  MATCH  CPA  SPEND  INSTALLS"
      cat
    }
  echo ""

  # Zero-install keywords with spend
  echo "--- ZERO INSTALLS (spend > \$5) ---"
  echo "$response" | jq -r '
    [.data.reportingDataResponse.row[]? |
     select((.total.localSpend.amount | tonumber) > 5) |
     select(.total.installs == 0)] |
    sort_by(-(.total.localSpend.amount | tonumber))[] |
    [.metadata.keyword, .metadata.matchType,
     .total.localSpend.amount, .total.impressions, .total.taps] |
    @tsv' | column -t -s $'\t' | {
      echo "KEYWORD  MATCH  SPEND  IMPRESSIONS  TAPS"
      cat
    }
  echo ""

  # Low TTR keywords (impressions > 100, TTR < 2%)
  echo "--- LOW TAP-THROUGH (TTR < 2%, impressions > 100) ---"
  echo "$response" | jq -r '
    [.data.reportingDataResponse.row[]? |
     select(.total.impressions > 100) |
     select((.total.ttr | tonumber) < 0.02)] |
    sort_by(.total.ttr | tonumber)[] |
    [.metadata.keyword, .metadata.matchType,
     .total.ttr, .total.impressions, .total.taps] |
    @tsv' | column -t -s $'\t' | {
      echo "KEYWORD  MATCH  TTR  IMPRESSIONS  TAPS"
      cat
    }
  echo ""

  # Top performers
  echo "--- TOP PERFORMERS (installs > 0, sorted by CPA ascending) ---"
  echo "$response" | jq -r '
    [.data.reportingDataResponse.row[]? |
     select(.total.installs > 0)] |
    sort_by((.total.localSpend.amount | tonumber) / .total.installs)[:10][] |
    [.metadata.keyword, .metadata.matchType,
     ((.total.localSpend.amount | tonumber) / .total.installs * 100 | round / 100 | tostring),
     .total.localSpend.amount, .total.installs, .total.taps] |
    @tsv' | column -t -s $'\t' | {
      echo "KEYWORD  MATCH  CPA  SPEND  INSTALLS  TAPS"
      cat
    }
}

cmd_bids() {
  local cid="$1"; shift
  local start="" end="" target_cpa=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --target-cpa) target_cpa="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  [[ -z "$start" || -z "$end" || -z "$target_cpa" ]] && {
    echo "ERROR: --start, --end, --target-cpa required" >&2; return 1
  }

  local response
  response=$(_get_keyword_report "$cid" "$start" "$end") || return 1

  echo "=== Bid Recommendations (target CPA: \$$target_cpa) ==="
  echo ""

  # For each keyword with data, suggest bid adjustment
  echo "$response" | jq -r --arg tc "$target_cpa" '
    [.data.reportingDataResponse.row[]? |
     select(.total.taps > 0) |
     {
       keyword: .metadata.keyword,
       match: .metadata.matchType,
       kwId: .metadata.keywordId,
       spend: (.total.localSpend.amount | tonumber),
       taps: .total.taps,
       installs: .total.installs,
       cpt: ((.total.localSpend.amount | tonumber) / .total.taps),
       cpa: (if .total.installs > 0 then (.total.localSpend.amount | tonumber) / .total.installs else 999 end),
       cvr: (if .total.taps > 0 then .total.installs / .total.taps else 0 end)
     }] |
    sort_by(-.spend)[] |
    # Recommendation logic:
    # If CPA < target * 0.7: raise bid 20% (underbidding)
    # If CPA > target * 1.3: lower bid 30% (overbidding)
    # If CPA > target * 2.0: pause candidate
    # If installs == 0 and spend > target * 3: pause candidate
    (if .installs == 0 and .spend > (($tc | tonumber) * 3) then
       .action = "PAUSE (no installs, spent >" + (($tc | tonumber) * 3 | tostring) + ")"
     elif .cpa > (($tc | tonumber) * 2) then
       .action = "PAUSE (CPA " + (.cpa * 100 | round / 100 | tostring) + " > 2x target)"
     elif .cpa > (($tc | tonumber) * 1.3) then
       .action = "LOWER BID 30% (CPA " + (.cpa * 100 | round / 100 | tostring) + ")"
     elif .cpa < (($tc | tonumber) * 0.7) and .installs >= 2 then
       .action = "RAISE BID 20% (CPA " + (.cpa * 100 | round / 100 | tostring) + ", room to grow)"
     else
       .action = "HOLD (CPA " + (.cpa * 100 | round / 100 | tostring) + " within range)"
     end) |
    [.keyword, .match, .action, (.spend * 100 | round / 100 | tostring), .installs] |
    @tsv' | column -t -s $'\t' | {
      echo "KEYWORD  MATCH  RECOMMENDATION  SPEND  INSTALLS"
      cat
    }
}

cmd_auto_bid() {
  local cid="$1"; shift
  local start="" end="" target_cpa="" max_bid="10.00" min_bid="0.25" dry_run=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start) start="$2"; shift 2 ;;
      --end) end="$2"; shift 2 ;;
      --target-cpa) target_cpa="$2"; shift 2 ;;
      --max-bid) max_bid="$2"; shift 2 ;;
      --min-bid) min_bid="$2"; shift 2 ;;
      --dry-run) dry_run=true; shift ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  [[ -z "$start" || -z "$end" || -z "$target_cpa" ]] && {
    echo "ERROR: --start, --end, --target-cpa required" >&2; return 1
  }

  local response
  response=$(_get_keyword_report "$cid" "$start" "$end") || return 1

  # Get ad groups to know which ad group each keyword belongs to
  local adgroups_response
  adgroups_response=$(asa_api GET "/campaigns/${cid}/adgroups") || return 1

  echo "=== Auto-Bid Adjustment (target CPA: \$$target_cpa, bounds: \$$min_bid - \$$max_bid) ==="
  echo ""

  # Extract keywords needing bid changes
  local changes
  changes=$(echo "$response" | jq --arg tc "$target_cpa" --arg maxb "$max_bid" --arg minb "$min_bid" '
    [.data.reportingDataResponse.row[]? |
     select(.total.taps >= 5) |
     select(.total.installs > 0) |
     {
       kwId: .metadata.keywordId,
       adGroupId: .metadata.adGroupId,
       keyword: .metadata.keyword,
       cpt: ((.total.localSpend.amount | tonumber) / .total.taps),
       cpa: ((.total.localSpend.amount | tonumber) / .total.installs),
       cvr: (.total.installs / .total.taps)
     } |
     # Calculate new bid: target_cpa * conversion_rate (what CPT should be for target CPA)
     .idealCpt = (($tc | tonumber) * .cvr) |
     # Dampen adjustment (move 50% toward ideal)
     .newBid = ((.cpt + .idealCpt) / 2) |
     # Clamp to bounds
     .newBid = (if .newBid > ($maxb | tonumber) then ($maxb | tonumber)
                elif .newBid < ($minb | tonumber) then ($minb | tonumber)
                else .newBid end) |
     # Only include if change is significant (> 10%)
     select(((.newBid - .cpt) | fabs) / .cpt > 0.10) |
     {kwId, adGroupId, keyword, currentCpt: (.cpt * 100 | round / 100),
      newBid: (.newBid * 100 | round / 100), cpa: (.cpa * 100 | round / 100)}]')

  local change_count
  change_count=$(echo "$changes" | jq 'length')

  echo "$changes" | jq -r '.[] |
    [.keyword, (.currentCpt | tostring), (.newBid | tostring), (.cpa | tostring)] | @tsv' | column -t -s $'\t' | {
      echo "KEYWORD  CURRENT_CPT  NEW_BID  CPA"
      cat
    }

  echo ""
  echo "Changes to apply: $change_count"

  if [[ "$dry_run" == true ]]; then
    echo "[DRY RUN] No changes applied."
    return 0
  fi

  if [[ "$change_count" -eq 0 ]]; then
    echo "No bid adjustments needed."
    return 0
  fi

  # Apply changes grouped by ad group
  echo "Applying bid changes..."
  local adgroup_ids
  adgroup_ids=$(echo "$changes" | jq -r '.[].adGroupId' | sort -u)

  for agid in $adgroup_ids; do
    local batch
    batch=$(echo "$changes" | jq --arg ag "$agid" \
      '[.[] | select(.adGroupId == ($ag | tonumber)) |
        {"id": .kwId, "bidAmount": {"amount": (.newBid | tostring), "currency": "USD"}}]')

    local batch_count
    batch_count=$(echo "$batch" | jq 'length')
    echo "  Ad group $agid: updating $batch_count keywords..." >&2

    asa_api PUT "/campaigns/${cid}/adgroups/${agid}/targetingkeywords" "$batch" | \
      jq '.data | length | tostring + " updated"'
  done

  echo "Bid adjustments complete."
}

# Main dispatch
case "${1:-help}" in
  audit)     shift; cmd_audit "$@" ;;
  bids)      shift; cmd_bids "$@" ;;
  auto-bid)  shift; cmd_auto_bid "$@" ;;
  help|*)
    echo "Usage: optimize.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  audit <campaign_id> --start DATE --end DATE"
    echo "  bids <campaign_id> --start DATE --end DATE --target-cpa AMT"
    echo "  auto-bid <campaign_id> --start DATE --end DATE --target-cpa AMT [--max-bid AMT] [--min-bid AMT] [--dry-run]"
    ;;
esac
