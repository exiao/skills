---
name: polymarket
description: Query Polymarket prediction markets via the polymarket CLI. Browse markets, search topics, check prices, order books, and view events. Use when a user asks about prediction markets, odds, or "what does Polymarket say about X".
metadata:
  clawdbot:
    emoji: "🔮"
    requires:
      bins:
        - polymarket
    install:
      - id: polymarket
        kind: brew
        tap: Polymarket/polymarket-cli
        formula: polymarket
        label: "Install Polymarket CLI (brew)"
    tags:
      - prediction-markets
      - polymarket
      - odds
      - forecasting
---

# Polymarket CLI Skill

Query Polymarket prediction markets from the terminal. All read commands work without a wallet.

## Always use JSON output for parsing

Add `-o json` before the subcommand for machine-readable output:

```bash
polymarket -o json markets search "topic" --limit 10
```

## Common Commands

### Search & Browse

```bash
# Search markets by keyword
polymarket -o json markets search "bitcoin" --limit 10

# List active markets sorted by volume
polymarket -o json markets list --limit 20 --active true --order volume_num

# Get a specific market by slug or ID
polymarket -o json markets get will-trump-win-the-2024-election
polymarket -o json markets get 12345

# List events (groups of related markets)
polymarket -o json events list --limit 10 --active true
polymarket -o json events list --tag politics --active true
polymarket -o json events get 500

# Browse tags
polymarket -o json tags list
polymarket -o json tags get politics
```

### Prices & Order Books (no wallet needed)

```bash
# Current price for a token
polymarket -o json clob price TOKEN_ID --side buy
polymarket -o json clob midpoint TOKEN_ID
polymarket -o json clob spread TOKEN_ID

# Order book depth
polymarket -o json clob book TOKEN_ID

# Batch prices (comma-separated token IDs)
polymarket -o json clob batch-prices "TOKEN1,TOKEN2" --side buy

# Price history
polymarket -o json clob price-history TOKEN_ID --interval 1d --fidelity 30
# Intervals: 1m, 1h, 6h, 1d, 1w, max

# Last trade
polymarket -o json clob last-trade TOKEN_ID
```

### On-Chain Data (no wallet needed)

```bash
# View any wallet's positions
polymarket -o json data positions 0xWALLET_ADDRESS

# Closed positions and activity
polymarket -o json data closed-positions 0xWALLET_ADDRESS
polymarket -o json data activity 0xWALLET_ADDRESS
```

### Filters for `markets list`

- `--limit N` — number of results
- `--offset N` — pagination
- `--order FIELD` — sort field (e.g., `volume_num`)
- `--ascending` — ascending sort
- `--active true/false` — active markets only
- `--closed true/false` — closed markets only

## Formatting Results

When presenting to the user:
1. Search first, then get details on interesting markets
2. Show: question, yes/no prices (as percentages), volume, and liquidity
3. Price is in cents (52.00¢ = 52% implied probability)
4. For events, list the child markets with their prices
5. Keep it conversational: "Polymarket gives X a 52% chance" not raw JSON dumps

## Trading Commands (require wallet setup)

Trading is available but **always confirm with the user before placing any order**.

```bash
# Place a limit order
polymarket clob create-order --token TOKEN_ID --side buy --price 0.50 --size 10

# Place a market order
polymarket clob market-order --token TOKEN_ID --side buy --amount 5

# Cancel orders
polymarket clob cancel ORDER_ID
polymarket clob cancel-all

# View positions
polymarket clob orders
polymarket clob trades
polymarket clob balance --asset-type collateral
```

## Notes

- No wallet needed for browsing, searching, or checking prices
- Wallet setup: `polymarket setup` or `polymarket wallet create`
- Config lives at `~/.config/polymarket/config.json`
- All commands support `-o json` and `-o table` (default)
