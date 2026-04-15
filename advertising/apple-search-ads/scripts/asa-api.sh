#!/usr/bin/env bash
set -euo pipefail

# asa-api.sh — Generic Apple Search Ads API caller
#
# Sources asa-auth.sh for token, injects auth headers,
# implements exponential backoff for 429s.
#
# Required env vars: (same as asa-auth.sh) + ASA_ORG_ID
#
# Usage:
#   source asa-api.sh
#   asa_api GET /campaigns
#   asa_api POST /reports/campaigns "$json_body"
#   asa_api PUT "/campaigns/$id" "$json_body"
#   asa_api DELETE "/campaigns/$id"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/asa-auth.sh"

ASA_BASE_URL="https://api.searchads.apple.com/api/v5"
ASA_MAX_RETRIES="${ASA_MAX_RETRIES:-5}"
ASA_INITIAL_BACKOFF="${ASA_INITIAL_BACKOFF:-2}"

asa_api() {
  local method="$1"
  local endpoint="$2"
  local body="${3:-}"

  if [[ -z "${ASA_ORG_ID:-}" ]]; then
    echo "ERROR: ASA_ORG_ID not set" >&2
    return 1
  fi

  local token
  token=$(asa_get_token) || return 1

  local url="${ASA_BASE_URL}${endpoint}"
  local retries=0
  local backoff=$ASA_INITIAL_BACKOFF

  while true; do
    local curl_args=(
      -s -w "\n%{http_code}"
      -X "$method"
      -H "Authorization: Bearer $token"
      -H "X-AP-Context: orgId=${ASA_ORG_ID}"
      -H "Content-Type: application/json"
    )

    if [[ -n "$body" ]]; then
      curl_args+=(-d "$body")
    fi

    local raw_response
    raw_response=$(curl "${curl_args[@]}" "$url")

    local http_code
    http_code=$(echo "$raw_response" | tail -1)
    local response_body
    response_body=$(echo "$raw_response" | sed '$d')

    case "$http_code" in
      2[0-9][0-9])
        echo "$response_body"
        return 0
        ;;
      401)
        # Token expired, clear cache and retry once
        if [[ $retries -eq 0 ]]; then
          asa_clear_token 2>/dev/null
          token=$(asa_get_token) || return 1
          retries=$((retries + 1))
          continue
        fi
        echo "ERROR: Authentication failed (401)" >&2
        echo "$response_body" >&2
        return 1
        ;;
      429)
        retries=$((retries + 1))
        if [[ $retries -gt $ASA_MAX_RETRIES ]]; then
          echo "ERROR: Rate limited, max retries ($ASA_MAX_RETRIES) exceeded" >&2
          return 1
        fi
        # Exponential backoff with jitter
        local jitter=$(( RANDOM % backoff ))
        local wait=$(( backoff + jitter ))
        echo "Rate limited (429). Retry $retries/$ASA_MAX_RETRIES in ${wait}s..." >&2
        sleep "$wait"
        backoff=$(( backoff * 2 ))
        continue
        ;;
      *)
        echo "ERROR: HTTP $http_code" >&2
        echo "$response_body" >&2
        return 1
        ;;
    esac
  done
}

# Convenience: paginated GET that fetches all results
asa_api_all() {
  local endpoint="$1"
  local limit="${2:-100}"
  local offset=0
  local all_results="[]"

  while true; do
    local sep="?"
    [[ "$endpoint" == *"?"* ]] && sep="&"
    local response
    response=$(asa_api GET "${endpoint}${sep}limit=${limit}&offset=${offset}") || return 1

    local items
    items=$(echo "$response" | jq '.data // []')
    local count
    count=$(echo "$items" | jq 'length')

    all_results=$(echo "$all_results" "$items" | jq -s '.[0] + .[1]')

    if [[ "$count" -lt "$limit" ]]; then
      break
    fi
    offset=$(( offset + limit ))
  done

  echo "$all_results"
}

# If run directly, execute the API call from args
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ $# -lt 2 ]]; then
    echo "Usage: asa-api.sh METHOD /endpoint [JSON_BODY]" >&2
    exit 1
  fi
  asa_api "$@"
fi
