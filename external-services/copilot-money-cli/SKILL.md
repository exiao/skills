---
name: copilot-money-cli
preloaded: true
description: Use when querying Copilot Money for finances, transactions, net worth, and holdings.
---

# Copilot Money CLI

Use the Rust CLI (`copilot` binary at `/usr/local/bin/copilot`). The Python `copilot-money` CLI is deprecated.

> **Note:** Unofficial tool, not affiliated with Copilot Money.

## Auth

Token stored at `~/.config/copilot-money-cli/token`. Firebase JWT, expires every ~1 hour.

```bash
copilot auth status          # Check if token is valid
copilot auth login           # Interactive browser login
copilot auth refresh         # Refresh expired token (needs playwright)
```

If `copilot auth refresh` fails ("token refresh helper not found"), grab a fresh token from the web app session instead (see Bulk Export below).

## Commands

```bash
# Transactions
copilot transactions list                                    # Last 25
copilot transactions list --limit 50 --pages 10             # 500 txns (paginated)
copilot transactions list --all                             # Everything (slow, 25/page)
copilot transactions list --sort date-desc --output json
copilot transactions list --unreviewed
copilot transactions list --category "Groceries"
copilot transactions list --name-contains "uber"
copilot transactions list --date 2026-03-01
copilot transactions list --date-after 2026-01-01 --date-before 2026-03-31

# Categories
copilot categories list --output json                       # {id, name}

# Write (require --yes in scripts)
copilot transactions set-category <id> --category "Food"
copilot transactions set-notes <id> --notes "..."
copilot transactions review <ids...>
```

## Bulk Transaction Download

### Option A: CSV Export (fastest, all transactions in one request)

The GraphQL API has an `ExportTransactions` operation that generates a signed GCS URL to a complete CSV. No pagination, no limits. This is what the web app's "Download transactions" button uses.

```bash
TOKEN=$(cat ~/.config/copilot-money-cli/token)
EXPORT_URL=$(curl -s -X POST https://app.copilot.money/api/graphql \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operationName": "ExportTransactions",
    "variables": {
      "sort": [{"direction": "DESC", "field": "DATE"}]
    },
    "query": "query ExportTransactions($filter: TransactionFilter, $sort: [TransactionSort!]) { exportTransactions(filter: $filter, sort: $sort) { expiresAt url } }"
  }' | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['exportTransactions']['url'])")

curl -s "$EXPORT_URL" -o transactions.csv
```

CSV columns: `date, name, amount, status, category, parent category, excluded, tags, type, account, account mask, note, recurring`

The `filter` variable accepts `TransactionFilter` (same as the paginated query) so you can filter server-side before export.

**Note:** The signed URL expires (check `expiresAt` timestamp). Download immediately.

### Option B: CLI with date-range chunking (for JSON + programmatic filtering)

The server hard-caps pagination at **25 results per page** regardless of `--limit`. For large datasets, chunk by date range to reduce total pages:

```bash
# Monthly chunks, JSON output
for MONTH in 01 02 03; do
  copilot transactions list \
    --date-after "2026-$MONTH-01" \
    --date-before "2026-$MONTH-31" \
    --all --output json \
    >> txns_2026.jsonl
done
```

Or use `--pages` to control how many pages to fetch per chunk:
```bash
copilot transactions list \
  --date-after 2026-01-01 --date-before 2026-03-31 \
  --limit 25 --pages 40 --sort date-desc --output json
```

### When to use which

| Method | Speed | Format | Filtering | Best for |
|--------|-------|--------|-----------|----------|
| Option A (Export) | Fast (1 request) | CSV | Server-side via filter | Full dumps, spreadsheet analysis |
| Option B (CLI chunks) | Slow (25/page) | JSON | CLI flags + post-processing | Programmatic analysis, category resolution |

## API Details (discovered)

- **GraphQL endpoint:** `POST https://app.copilot.money/api/graphql`
- **Auth:** Firebase JWT in `Authorization: Bearer <token>` header
- **Pagination hard cap:** 25 items/page (server ignores `first` values above 25)
- **Export:** `ExportTransactions` returns a signed Google Cloud Storage URL (no pagination)
- **Firebase project:** `copilot-production-22904`

## Analysis pattern

```python
import subprocess, json, csv
from collections import defaultdict

# Option A: CSV (fast, complete)
# Run the export curl commands above, then:
with open('transactions.csv') as f:
    txns = list(csv.DictReader(f))
# Category already resolved as text in CSV

# Option B: JSON via CLI
cats = {c['id']: c['name'] for c in json.loads(
    subprocess.check_output(['copilot', 'categories', 'list', '--output', 'json'])
)}

raw = json.loads(subprocess.check_output([
    'copilot', 'transactions', 'list',
    '--all', '--sort', 'date-desc', '--output', 'json'
]))['transactions']

for t in raw:
    t['category'] = cats.get(t.get('categoryId', ''), 'Uncategorized')
```

## JSON output fields (transactions)

```json
{
  "id": "...",
  "date": "2026-03-03",
  "name": "Trader Joe's",
  "amount": 28.88,
  "categoryId": "K4Ij...",
  "type": "REGULAR",
  "isReviewed": false
}
```

## Security

- Calls only `app.copilot.money`. No telemetry.
- Token stored in plaintext at `~/.config/copilot-money-cli/token`.
