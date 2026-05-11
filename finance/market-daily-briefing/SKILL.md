---
name: market-daily-briefing
description: Create a concise daily market briefing covering indexes, macro news, earnings, and notable stock moves. Use for scheduled market updates or on-demand briefings. Supports market data CLIs/APIs, web sources, and optional social or messaging delivery.
---

# Market Daily Briefing

Deliver a concise, narrative market briefing covering earnings results, macro news, and notable stock moves.

## Scope

This is market commentary, not financial advice. Prioritize verified numbers, clear attribution, and useful context over hot takes.

## Inputs

Optional configuration:
- Market data command or API: `$MARKET_DATA_COMMAND`
- Watchlist source: `$WATCHLIST_SOURCE`
- Delivery destination: `$DELIVERY_TARGET`
- Social scheduler: `$SOCIAL_SCHEDULER`
- Max length: default 2,000 characters

## Data Sources

Prefer structured market data first, then web sources.

| Source | Use |
|--------|-----|
| Market data CLI/API | Indexes, top movers, prices, sentiment, fundamentals |
| Earnings calendar/API | Earnings results and upcoming reports |
| Web search | Macro news, company-specific news, source confirmation |
| Watchlist file/API | Prioritize names the audience cares about |

## Workflow

### Step 1: Pull structured market data

Collect:
- Major index moves: S&P 500, Nasdaq, Dow, Russell 2000
- Top gainers and losers by market cap or liquidity
- Sector moves if available
- Market sentiment indicators if available
- Notable earnings results

Validate output before using it. If a command returns empty, null, or error JSON, skip that source rather than passing bad data forward.

Generic validation pattern:

```bash
MARKET_TMP=$(mktemp -d /tmp/market-XXXXXX)
trap 'trash "$MARKET_TMP" 2>/dev/null || true' EXIT

# Replace with your market data command or API wrapper.
if ! $MARKET_DATA_COMMAND top-movers --limit 20 --format json > "$MARKET_TMP/movers.json" 2>"$MARKET_TMP/movers.err"; then
  echo '{"status":"error"}' > "$MARKET_TMP/movers.json"
fi

jq 'type == "object" and (.status != "error")' "$MARKET_TMP/movers.json"
```

### Step 2: Fill gaps with web search

If structured data is unavailable, use web search for:
- Market open or close recaps
- Earnings reports
- Fed or economic data
- Large-cap movers
- Sector-specific headlines

Always prefer primary sources or reputable market outlets.

### Step 3: Verify numbers

Every stock percentage and index move should come from a reliable source.

Rules:
- Do not estimate price moves from headlines.
- If sources disagree, use the most current structured market data.
- If a number is unverified, mark it as approximate and cite the source.
- Never silently use null, stale, or missing values.

### Step 4: Choose the lead stories

Prioritize:
1. Major index moves
2. Mega-cap or widely held stock moves
3. Earnings beats or misses with clear stock reaction
4. Macro data: CPI, PCE, jobs, Fed comments, yields
5. Sector moves with a clear reason
6. Watchlist names, if provided

Skip tiny movers unless the reason is unusually important.

## Briefing Format

Keep it conversational and compact.

Template:

```
Market update:

[One-sentence summary of the day]

• Indexes: [SPY/Nasdaq/Dow move and why]
• Big movers: [2-4 stocks with verified % moves]
• Earnings: [most important beat/miss and takeaway]
• Macro: [Fed/data/rates/oil/dollar if relevant]

What matters: [one useful synthesis]
```

Avoid tables for messaging delivery. Tables are fine for internal notes or markdown reports.

## Style Rules

- No hype
- No trade recommendations
- No "stocks soared" unless the move is actually large
- Explain why the move happened, not just that it happened
- Keep uncertain causality honest: "after", "as investors weighed", "following", not "because" unless confirmed
- Max 2,000 characters by default

## Optional Drafting for Social

If asked to create a public post, save as an unscheduled draft for review unless explicitly told to publish.

Social post pattern:

```
Today in markets:

1. [Index/macro story]
2. [Big stock move]
3. [Earnings takeaway]

The important bit: [synthesis]
```

## Output Format

Return:

1. Final briefing
2. Source notes
3. Verified numbers used
4. Skipped or uncertain stories
5. Optional social draft text
