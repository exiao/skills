#!/usr/bin/env bash
set -euo pipefail

# asa-auth.sh — Apple Search Ads OAuth token generation
#
# Generates an ES256 JWT client secret, exchanges it for an access token,
# and caches the token in /tmp/.asa-access-token with TTL check.
#
# Required env vars:
#   ASA_CLIENT_ID        — SEARCHADS.xxxxxxxx-xxxx-...
#   ASA_TEAM_ID          — SEARCHADS.xxxxxxxx-xxxx-...
#   ASA_KEY_ID           — xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   ASA_PRIVATE_KEY_PATH — path to EC P-256 private key PEM
#
# Dependencies: python3.13, pyjwt[crypto], curl, jq
#
# Usage:
#   source asa-auth.sh
#   token=$(asa_get_token)

TOKEN_CACHE="/tmp/.asa-access-token"
TOKEN_TTL_BUFFER=300  # refresh if < 5 min remaining

_asa_check_env() {
  local missing=()
  [[ -z "${ASA_CLIENT_ID:-}" ]] && missing+=("ASA_CLIENT_ID")
  [[ -z "${ASA_TEAM_ID:-}" ]] && missing+=("ASA_TEAM_ID")
  [[ -z "${ASA_KEY_ID:-}" ]] && missing+=("ASA_KEY_ID")
  [[ -z "${ASA_PRIVATE_KEY_PATH:-}" ]] && missing+=("ASA_PRIVATE_KEY_PATH")

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: Missing env vars: ${missing[*]}" >&2
    echo "See: https://developer.apple.com/documentation/apple_ads/implementing-oauth-for-the-apple-search-ads-api" >&2
    return 1
  fi

  if [[ ! -f "$ASA_PRIVATE_KEY_PATH" ]]; then
    echo "ERROR: Private key not found at $ASA_PRIVATE_KEY_PATH" >&2
    return 1
  fi
}

_asa_generate_client_secret() {
  # Generate ES256 JWT using Python pyjwt (one-liner)
  python3.13 -c "
import jwt, time
key = open('${ASA_PRIVATE_KEY_PATH}').read()
print(jwt.encode(
    {'sub': '${ASA_CLIENT_ID}', 'aud': 'https://appleid.apple.com',
     'iat': int(time.time()), 'exp': int(time.time()) + 3600,
     'iss': '${ASA_TEAM_ID}'},
    key, algorithm='ES256', headers={'kid': '${ASA_KEY_ID}'}
))"
}

_asa_exchange_token() {
  local client_secret="$1"
  local response
  response=$(curl -s -X POST "https://appleid.apple.com/auth/oauth2/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials&client_id=${ASA_CLIENT_ID}&client_secret=${client_secret}&scope=searchadsorg")

  local token
  token=$(echo "$response" | jq -r '.access_token // empty')

  if [[ -z "$token" ]]; then
    local err
    err=$(echo "$response" | jq -r '.error // "unknown"')
    echo "ERROR: Token exchange failed: $err" >&2
    echo "$response" >&2
    return 1
  fi

  # Cache token with expiry (token is valid 1 hour)
  local expiry
  expiry=$(( $(date +%s) + 3600 ))
  echo "${token}|${expiry}" > "$TOKEN_CACHE"
  chmod 600 "$TOKEN_CACHE"

  echo "$token"
}

asa_get_token() {
  _asa_check_env || return 1

  # Check cache
  if [[ -f "$TOKEN_CACHE" ]]; then
    local cached expiry now
    cached=$(cat "$TOKEN_CACHE")
    expiry=$(echo "$cached" | cut -d'|' -f2)
    now=$(date +%s)

    if [[ $(( expiry - now )) -gt $TOKEN_TTL_BUFFER ]]; then
      echo "$cached" | cut -d'|' -f1
      return 0
    fi
  fi

  # Generate fresh token
  local secret
  secret=$(_asa_generate_client_secret) || return 1
  _asa_exchange_token "$secret"
}

asa_clear_token() {
  rm -f "$TOKEN_CACHE"
  echo "Token cache cleared." >&2
}

# If run directly (not sourced), print the token
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  asa_get_token
fi
