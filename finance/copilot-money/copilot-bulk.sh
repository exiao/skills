#!/usr/bin/env bash
# copilot-bulk: Bulk download transactions as JSON via CLI with date-range chunking
# Usage: copilot-bulk [--output FILE] [--start YYYY-MM-DD] [--end YYYY-MM-DD] [--months N]
#
# Chunks by month to work around the 25/page server cap.

set -eo pipefail

OUTPUT="transactions.json"
START=""
END=""
MONTHS=3
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output|-o) OUTPUT="$2"; shift 2 ;;
    --start) START="$2"; shift 2 ;;
    --end) END="$2"; shift 2 ;;
    --months) MONTHS="$2"; shift 2 ;;
    --category) EXTRA_ARGS+=(--category "$2"); shift 2 ;;
    --unreviewed) EXTRA_ARGS+=(--unreviewed); shift ;;
    --reviewed) EXTRA_ARGS+=(--reviewed); shift ;;
    --name-contains) EXTRA_ARGS+=(--name-contains "$2"); shift 2 ;;
    --account) EXTRA_ARGS+=(--account "$2"); shift 2 ;;
    --tag) EXTRA_ARGS+=(--tag "$2"); shift 2 ;;
    --help|-h)
      echo "Usage: copilot-bulk [OPTIONS]"
      echo ""
      echo "Bulk download transactions as JSON using the CLI with date-range chunking."
      echo "Works around the server's 25-per-page hard cap by splitting into monthly chunks."
      echo ""
      echo "Options:"
      echo "  --output, -o FILE       Output JSON file (default: transactions.json)"
      echo "  --start YYYY-MM-DD      Start date (default: N months ago)"
      echo "  --end YYYY-MM-DD        End date (default: today)"
      echo "  --months N              Months to look back if no --start (default: 3)"
      echo "  --category NAME         Filter by category name"
      echo "  --unreviewed            Only unreviewed transactions"
      echo "  --reviewed              Only reviewed transactions"
      echo "  --name-contains TEXT    Filter by merchant name"
      echo "  --account NAME          Filter by account name"
      echo "  --tag TAG               Filter by tag"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Calculate date range
if [[ -z "$END" ]]; then
  END=$(date +%Y-%m-%d)
fi

if [[ -z "$START" ]]; then
  START=$(python3 -c "
from datetime import date, timedelta
d = date.today() - timedelta(days=$MONTHS * 31)
print(d.replace(day=1).isoformat())
")
fi

echo "Fetching transactions from $START to $END..."

# Generate monthly boundaries
BOUNDARIES=$(python3 -c "
from datetime import date
import calendar

start = date.fromisoformat('$START')
end = date.fromisoformat('$END')

current = start.replace(day=1)
while current <= end:
    last_day = calendar.monthrange(current.year, current.month)[1]
    month_end = date(current.year, current.month, last_day)
    chunk_start = max(current, start)
    chunk_end = min(month_end, end)
    print(f'{chunk_start.isoformat()} {chunk_end.isoformat()}')
    if current.month == 12:
        current = date(current.year + 1, 1, 1)
    else:
        current = date(current.year, current.month + 1, 1)
")

# Collect all transactions
TMPDIR=$(mktemp -d)
TOTAL=0
CHUNK_NUM=0

while IFS=' ' read -r CHUNK_START CHUNK_END; do
  CHUNK_NUM=$((CHUNK_NUM + 1))
  CHUNK_FILE="$TMPDIR/chunk_$CHUNK_NUM.json"

  echo -n "  $CHUNK_START to $CHUNK_END: "

  copilot transactions list \
    --date-after "$CHUNK_START" \
    --date-before "$CHUNK_END" \
    --all \
    --sort date-desc \
    --output json \
    ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"} \
    > "$CHUNK_FILE" 2>/dev/null || true

  COUNT=$(python3 -c "
import json, sys
try:
    d = json.load(open('$CHUNK_FILE'))
    txns = d.get('transactions', [])
    print(len(txns))
except:
    print(0)
")
  TOTAL=$((TOTAL + COUNT))
  echo "$COUNT transactions"
done <<< "$BOUNDARIES"

# Merge all chunks into a single JSON file
python3 -c "
import json, glob, os

all_txns = []
seen_ids = set()
for f in sorted(glob.glob('$TMPDIR/chunk_*.json')):
    try:
        d = json.load(open(f))
        for t in d.get('transactions', []):
            tid = t.get('id', '')
            if tid not in seen_ids:
                seen_ids.add(tid)
                all_txns.append(t)
    except:
        pass

all_txns.sort(key=lambda t: t.get('date', ''), reverse=True)
json.dump({'transactions': all_txns, 'count': len(all_txns)}, open('$OUTPUT', 'w'), indent=2)
print(f'Merged {len(all_txns)} unique transactions')
"

# Cleanup
rm -rf "$TMPDIR"
echo "Saved to $OUTPUT ($TOTAL total, deduplicated)"
