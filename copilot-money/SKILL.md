---
name: copilot-money
description: Use when querying Copilot Money for finances, transactions, net worth, and holdings.
---

# Copilot Money CLI

Use the Rust CLI (`copilot` binary at `/usr/local/bin/copilot`). The Python `copilot-money` CLI is deprecated — don't use it.

> **Note:** Unofficial tool, not affiliated with Copilot Money.

## Auth

Token stored at `~/.config/copilot-money-cli/token`. Already configured.

```bash
copilot auth status
```

## Commands

```bash
# Transactions
copilot transactions list                                    # Last 25
copilot transactions list --limit 50 --pages 10             # 500 txns
copilot transactions list --all                             # Everything (slow)
copilot transactions list --sort date-desc --output json
copilot transactions list --unreviewed
copilot transactions list --category "Groceries"
copilot transactions list --name-contains "uber"
copilot transactions list --date 2026-03-01

# Categories
copilot categories list --output json                       # {id, name} — use to resolve categoryId

# Write (require --yes in scripts)
copilot transactions set-category <id> --category "Food"
copilot transactions set-notes <id> --notes "..."
copilot transactions review <ids...>
```

## Analysis pattern

```python
import subprocess, json
from collections import defaultdict

# Category map: id -> name
cats = {c['id']: c['name'] for c in json.loads(
    subprocess.check_output(['copilot', 'categories', 'list', '--output', 'json'])
)}

# Transactions (last ~8 weeks)
raw = json.loads(subprocess.check_output([
    'copilot', 'transactions', 'list',
    '--limit', '50', '--pages', '20', '--sort', 'date-desc', '--output', 'json'
]))['transactions']

# Resolve categories
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
