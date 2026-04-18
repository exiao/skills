#!/usr/bin/env bash
set -euo pipefail

# negatives.sh — Apple Search Ads negative keyword management
#
# Usage:
#   negatives.sh list-campaign <campaign_id>
#   negatives.sh list-adgroup <campaign_id> <adgroup_id>
#   negatives.sh add-campaign <campaign_id> --text "keyword" --match EXACT|BROAD
#   negatives.sh add-adgroup <campaign_id> <adgroup_id> --text "keyword" --match EXACT|BROAD
#   negatives.sh add-bulk-campaign <campaign_id> --file negatives.csv
#   negatives.sh delete-campaign <campaign_id> <keyword_id>
#   negatives.sh delete-adgroup <campaign_id> <adgroup_id> <keyword_id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/asa-api.sh"

cmd_list_campaign() {
  local cid="$1"
  asa_api GET "/campaigns/${cid}/negativekeywords" | jq -r '
    .data[]? | [.id, .text, .matchType, .status] | @tsv' | column -t -s $'\t' | {
      echo "ID  TEXT  MATCH_TYPE  STATUS"
      cat
    }
}

cmd_list_adgroup() {
  local cid="$1" agid="$2"
  asa_api GET "/campaigns/${cid}/adgroups/${agid}/negativekeywords" | jq -r '
    .data[]? | [.id, .text, .matchType, .status] | @tsv' | column -t -s $'\t' | {
      echo "ID  TEXT  MATCH_TYPE  STATUS"
      cat
    }
}

_add_negative() {
  local endpoint="$1" text="" match="EXACT"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --text) text="$2"; shift 2 ;;
      --match) match="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$text" ]]; then
    echo "ERROR: --text is required" >&2
    return 1
  fi

  local body
  body=$(jq -n --arg text "$text" --arg match "$match" \
    '[{"text": $text, "matchType": $match, "status": "ACTIVE"}]')

  asa_api POST "$endpoint" "$body" | jq '.data'
}

cmd_add_campaign() {
  local cid="$1"; shift
  _add_negative "/campaigns/${cid}/negativekeywords" "$@"
}

cmd_add_adgroup() {
  local cid="$1" agid="$2"; shift 2
  _add_negative "/campaigns/${cid}/adgroups/${agid}/negativekeywords" "$@"
}

cmd_add_bulk_campaign() {
  local cid="$1"; shift
  local file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file) file="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if [[ -z "$file" || ! -f "$file" ]]; then
    echo "ERROR: --file required (CSV: text,matchType)" >&2
    return 1
  fi

  local negatives_json="[]"
  while IFS=',' read -r text match; do
    [[ "$text" == "text" ]] && continue
    [[ -z "$text" ]] && continue
    match="${match:-EXACT}"
    local neg
    neg=$(jq -n --arg t "$text" --arg m "$match" '{"text":$t,"matchType":$m,"status":"ACTIVE"}')
    negatives_json=$(echo "$negatives_json" | jq --argjson n "$neg" '. + [$n]')
  done < "$file"

  local count
  count=$(echo "$negatives_json" | jq 'length')
  echo "Adding $count negative keywords to campaign $cid..." >&2

  asa_api POST "/campaigns/${cid}/negativekeywords" "$negatives_json" | jq '.data | length | tostring + " negatives added"'
}

cmd_delete_campaign() {
  local cid="$1" kwid="$2"
  asa_api DELETE "/campaigns/${cid}/negativekeywords/${kwid}"
  echo "Deleted negative keyword $kwid from campaign $cid"
}

cmd_delete_adgroup() {
  local cid="$1" agid="$2" kwid="$3"
  asa_api DELETE "/campaigns/${cid}/adgroups/${agid}/negativekeywords/${kwid}"
  echo "Deleted negative keyword $kwid from ad group $agid"
}

# Main dispatch
case "${1:-help}" in
  list-campaign)      shift; cmd_list_campaign "$@" ;;
  list-adgroup)       shift; cmd_list_adgroup "$@" ;;
  add-campaign)       shift; cmd_add_campaign "$@" ;;
  add-adgroup)        shift; cmd_add_adgroup "$@" ;;
  add-bulk-campaign)  shift; cmd_add_bulk_campaign "$@" ;;
  delete-campaign)    shift; cmd_delete_campaign "$@" ;;
  delete-adgroup)     shift; cmd_delete_adgroup "$@" ;;
  help|*)
    echo "Usage: negatives.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list-campaign <campaign_id>"
    echo "  list-adgroup <campaign_id> <adgroup_id>"
    echo "  add-campaign <campaign_id> --text TEXT [--match EXACT|BROAD]"
    echo "  add-adgroup <campaign_id> <adgroup_id> --text TEXT [--match EXACT|BROAD]"
    echo "  add-bulk-campaign <campaign_id> --file negatives.csv"
    echo "  delete-campaign <campaign_id> <keyword_id>"
    echo "  delete-adgroup <campaign_id> <adgroup_id> <keyword_id>"
    ;;
esac
