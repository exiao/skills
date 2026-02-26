#!/usr/bin/env bash
# Serper Google Search CLI wrapper
# Usage: serper.sh "query" [--num N] [--type search|news|images|places] [--gl COUNTRY] [--hl LANG]
#
# Requires: SERPER_API_KEY environment variable
# API docs: https://serper.dev

set -euo pipefail

if [[ -z "${SERPER_API_KEY:-}" ]]; then
  echo "Error: SERPER_API_KEY not set" >&2
  exit 1
fi

QUERY=""
NUM=10
TYPE="search"
GL=""
HL=""
TBS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --num)   NUM="$2"; shift 2 ;;
    --type)  TYPE="$2"; shift 2 ;;
    --gl)    GL="$2"; shift 2 ;;
    --hl)    HL="$2"; shift 2 ;;
    --tbs)   TBS="$2"; shift 2 ;;
    -*)      echo "Unknown flag: $1" >&2; exit 1 ;;
    *)       QUERY="$1"; shift ;;
  esac
done

if [[ -z "$QUERY" ]]; then
  echo "Usage: serper.sh \"query\" [--num N] [--type search|news|images|places] [--gl COUNTRY] [--hl LANG] [--tbs TIME]" >&2
  exit 1
fi

# Build JSON payload
JSON=$(jq -n \
  --arg q "$QUERY" \
  --argjson num "$NUM" \
  '{q: $q, num: $num}')

[[ -n "$GL" ]] && JSON=$(echo "$JSON" | jq --arg gl "$GL" '. + {gl: $gl}')
[[ -n "$HL" ]] && JSON=$(echo "$JSON" | jq --arg hl "$HL" '. + {hl: $hl}')
[[ -n "$TBS" ]] && JSON=$(echo "$JSON" | jq --arg tbs "$TBS" '. + {tbs: $tbs}')

# Map type to endpoint
ENDPOINT="https://google.serper.dev/${TYPE}"

# Make the request
RESPONSE=$(curl -s -X POST "$ENDPOINT" \
  -H "X-API-KEY: ${SERPER_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$JSON")

# Format output for readability
echo "$RESPONSE" | jq -r '
  # Knowledge Graph
  if .knowledgeGraph then
    "📌 \(.knowledgeGraph.title // "")" +
    (if .knowledgeGraph.description then "\n   \(.knowledgeGraph.description)" else "" end) +
    "\n"
  else "" end,

  # Answer Box
  if .answerBox then
    "💡 \(.answerBox.title // .answerBox.snippet // "")\n"
  else "" end,

  # Organic results
  if .organic then
    (.organic[] |
      "[\(.position)]. \(.title)\n    \(.link)\n    \(.snippet // "")\n"
    )
  else "" end,

  # News results
  if .news then
    (.news[] |
      "📰 \(.title)\n    \(.link)\n    \(.date // "") | \(.source // "")\n    \(.snippet // "")\n"
    )
  else "" end,

  # People Also Ask
  if .peopleAlsoAsk then
    "❓ People Also Ask:",
    (.peopleAlsoAsk[] | "   • \(.question)")
  else "" end
' 2>/dev/null || echo "$RESPONSE" | jq .
