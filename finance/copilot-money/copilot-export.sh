#!/usr/bin/env bash
# copilot-export: Bulk export all Copilot Money transactions via GraphQL ExportTransactions
# Usage: copilot-export [--output FILE] [--filter-json '{"categoryId":"..."}']
#
# Requires a valid Firebase JWT token at ~/.config/copilot-money-cli/token

set -euo pipefail

OUTPUT="transactions.csv"
FILTER="{}"
TOKEN_FILE="${COPILOT_TOKEN_FILE:-$HOME/.config/copilot-money-cli/token}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output|-o) OUTPUT="$2"; shift 2 ;;
    --filter) FILTER="$2"; shift 2 ;;
    --token-file) TOKEN_FILE="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: copilot-export [--output FILE] [--filter JSON]"
      echo ""
      echo "Export all Copilot Money transactions to CSV via the ExportTransactions GraphQL API."
      echo "Downloads everything in a single request (no pagination)."
      echo ""
      echo "Options:"
      echo "  --output, -o FILE   Output CSV file (default: transactions.csv)"
      echo "  --filter JSON       TransactionFilter JSON (e.g. '{\"categoryId\":\"abc\"}')"
      echo "  --token-file PATH   Token file (default: ~/.config/copilot-money-cli/token)"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ ! -f "$TOKEN_FILE" ]]; then
  echo "Error: Token file not found at $TOKEN_FILE"
  echo "Run: copilot auth login"
  exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")

# Build the GraphQL request
VARIABLES=$(python3 -c "
import json, sys
f = json.loads('$FILTER')
v = {'sort': [{'direction': 'DESC', 'field': 'DATE'}]}
if f:
    v['filter'] = f
print(json.dumps(v))
")

QUERY='query ExportTransactions($filter: TransactionFilter, $sort: [TransactionSort!]) { exportTransactions(filter: $filter, sort: $sort) { expiresAt url } }'

BODY=$(python3 -c "
import json
print(json.dumps({
    'operationName': 'ExportTransactions',
    'variables': $VARIABLES,
    'query': '''$QUERY'''
}))
")

# Call the API
RESPONSE=$(curl -s -X POST https://app.copilot.money/api/graphql \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY")

# Check for errors
ERROR=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
errs = d.get('errors', [])
if errs:
    print(errs[0].get('message', 'Unknown error'))
" 2>/dev/null || true)

if [[ -n "$ERROR" ]]; then
  echo "Error: $ERROR"
  echo "Token may be expired. Refresh with: copilot auth login"
  exit 1
fi

# Extract the signed URL and download
EXPORT_URL=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d['data']['exportTransactions']['url'])
")

EXPIRES=$(echo "$RESPONSE" | python3 -c "
import sys, json, datetime
d = json.load(sys.stdin)
ts = d['data']['exportTransactions']['expiresAt']
if isinstance(ts, (int, float)):
    dt = datetime.datetime.fromtimestamp(ts / 1000)
    print(dt.strftime('%Y-%m-%d %H:%M:%S'))
else:
    print(ts)
" 2>/dev/null || echo "unknown")

curl -s "$EXPORT_URL" -o "$OUTPUT"
LINES=$(($(wc -l < "$OUTPUT") - 1))
echo "Downloaded $LINES transactions to $OUTPUT (expires: $EXPIRES)"
