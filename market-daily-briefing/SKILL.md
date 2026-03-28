---
name: market-daily-briefing
description: Use when delivering a daily market briefing — covering earnings results, macro news, and notable stock moves. Runs automatically at 10am ET Mon-Fri via cron, or on-demand when asked for a market update.
---

# Market Daily Briefing

Delivers a concise, narrative market briefing covering earnings results, economic data, and notable stock moves. Prioritizes stories that matter to Bloom users.

---

## Tools

| Tool | Purpose |
|------|---------|
| **Bloom CLI** (`bloom`) | Pull real-time price data, top movers, sentiment scores. Auth: bloom-cli reads API keys from `~/.bloom/config.json` or env vars (`BLOOM_API_KEY`). Run `bloom auth` to configure. |
| **Serper** (`web-search` skill, `SERPER_API_KEY`) | Search for earnings results, analyst reactions, market news |
| **Firecrawl** (`FIRECRAWL_API_KEY`) | Scrape full articles when Serper snippets cut off before the numbers |
| **Bloom MCP** (`https://api.getbloom.app/mcp/`, Bearer: `${BLOOM_MCP_API_KEY}`) | Check what stocks Bloom users are watching — front-load coverage of these |

---

## Step 0: Pull Market Data (before web search)

Run this block first. It gives you ground-truth numbers before any web search. All percentages in the final briefing must come from here, not from article snippets.

```bash
mkdir -p /tmp/bloom

# Today's actual top movers
if ! bloom market --type top_movers --limit 20 -f json -o /tmp/bloom/movers.json 2>/tmp/bloom/movers.err; then
  echo "WARN: bloom market failed ($(cat /tmp/bloom/movers.err))" >&2
  echo '{"status":"error"}' > /tmp/bloom/movers.json
fi

# Fear & Greed + AAII sentiment
if ! bloom sentiment -f json -o /tmp/bloom/sentiment.json 2>/tmp/bloom/sentiment.err; then
  echo "WARN: bloom sentiment failed ($(cat /tmp/bloom/sentiment.err))" >&2
  echo '{}' > /tmp/bloom/sentiment.json
fi

# Major index data (includes day-over-day change_pct directly from the API)
if ! bloom market --type major_indexes -f json -o /tmp/bloom/indexes.json 2>/tmp/bloom/indexes.err; then
  echo "WARN: bloom market major_indexes failed ($(cat /tmp/bloom/indexes.err))" >&2
  echo '{}' > /tmp/bloom/indexes.json
fi
```

### Validate bloom output before extraction

If any bloom command returned empty, null, or error JSON, skip the verification step for that data source rather than passing bad data to the model.

> **Verified bloom-cli output formats (as of bloom-cli v1.x):**
> - `bloom market --type top_movers -f json` → `{"status":"success","data":{"stocks":[{"symbol","change_percent","market_cap",...}]}}`
> - `bloom market --type major_indexes -f json` → `{"status":"success","data":{"SPY":{"change_pct":-0.42,"price":512.30,...},...}}` (day-over-day change fields directly, no manual computation needed)
> - `bloom sentiment -f json` → `{"aaii_sentiment":{"bullish_percent","bearish_percent",...},"cnn_fear_greed":{"index_value","level",...},...}`

```bash
# Helper: check if file has valid, non-empty bloom data
# Uses jq instead of grep to correctly handle both '"status":"error"' and '"status": "error"'
bloom_valid() {
  local f="$1"
  [ -s "$f" ] && jq -e '.status != "error"' "$f" >/dev/null 2>&1 && [ "$(jq 'length' "$f" 2>/dev/null)" != "0" ]
}

# Top movers summary
if bloom_valid /tmp/bloom/movers.json; then
  jq '.data.stocks[] | {symbol: .symbol, change_pct: .change_percent, market_cap: .market_cap}' /tmp/bloom/movers.json
else
  echo "SKIP: movers data unavailable or invalid" >&2
fi

# Sentiment
# Verify key paths: .cnn_fear_greed and .aaii_sentiment nesting may differ in actual API response
# (may be nested differently or absent — confirm against live bloom output before relying on these paths)
if bloom_valid /tmp/bloom/sentiment.json; then
  jq '{fear_greed: .cnn_fear_greed.index_value, fear_greed_label: .cnn_fear_greed.level, aaii_bull: .aaii_sentiment.bullish_percent, aaii_bear: .aaii_sentiment.bearish_percent}' /tmp/bloom/sentiment.json
else
  echo "SKIP: sentiment data unavailable or invalid" >&2
fi

# Major index summary — change_pct comes directly from the API (day-over-day)
# Extracting only needed fields to avoid bloating context window
if bloom_valid /tmp/bloom/indexes.json; then
  jq '.data // . | to_entries[] | {symbol: .key, change_pct: .value.change_pct, price: .value.price}' /tmp/bloom/indexes.json
else
  echo "SKIP: index data unavailable or invalid" >&2
fi
```

Keep these numbers in context. Every stock percentage you write must come from this data.

---

## What to Cover

### 0. Verified Numbers Rule
Every stock percentage mentioned MUST be verified against bloom-cli price data. If bloom-cli shows a different number than a news article, use bloom-cli's number. Never estimate or round aggressively.

If bloom-cli returned null or was unavailable for a field, fall back to the article's number but mark it as unverified: e.g., "~+2.3% (unverified — source: article)". Never silently use null as a percentage.

### 1. Earnings Results (Today + Last Night)
For each notable company that reported:
- Beat or miss (EPS and revenue vs. consensus)
- How the stock reacted (after-hours move or today's open)
- 2-3 interesting takeaways: guidance changes, margin shifts, subscriber growth, segment commentary

Prioritize: mega-caps, widely-held names, dramatic movers (>5%), anything popular on Bloom.

### 2. Market-Moving News
- Fed comments or policy signals
- Economic data releases (CPI, jobs, GDP, PMI)
- Major sector rotations
- Single-stock moves >5% not covered above
- M&A announcements
- Regulatory news

---

## Output Format

- Title: `📊 Morning Market Briefing — [date]`
- Conversational narrative — no tables, no bullet dumps
- Lead with the most important story
- On quiet days: 2-3 sentences is fine
- **Max 2000 characters** (Signal limit)

---

## Delivery

### Signal (primary)
Send to: `signal group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`

```python
# Use message tool
channel = "signal"
target = "group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY="
```

### Typefully (secondary — @investwithbloom)
After Signal, create a public-facing tweet of the sharpest single data point:

```bash
cd /Users/testuser/clawd/skills/typefully
node scripts/typefully.js drafts:create 286685 \
  --platform x \
  --text "<post text>"
# Do NOT add --schedule. Save as unscheduled draft only — Eric reviews before posting.
```

Tweet guidelines:
- Max 280 characters
- Lead with the most striking number or fact
- Conversational, not robotic. No hashtags unless they add value.
- Frame as market intelligence, not a recap
- Don't copy the Signal briefing verbatim — distill to one sharp point

---

## Cron Config

- **ID:** `b04e6814-7840-4927-b529-feb052cadbfc`
- **Schedule:** `0 10 * * 1-5` (10am ET, Mon-Fri)
- **Model:** `sonnet`

---

## Common Mistakes

1. **Missing Bloom MCP check** — Always check what stocks Bloom users are watching. User-held stocks belong front and center.
2. **Truncated earnings numbers** — Serper snippets often cut off before EPS/revenue figures. Use Firecrawl on the earnings press release when numbers are missing.
3. **Skipping stock reaction** — A beat/miss means nothing without the stock's actual % move. Always include both.
4. **Too long** — Under 2000 characters. If it's longer, cut. Quiet days = 2-3 sentences.
5. **Copying Signal verbatim to Typefully** — Public post needs to be distilled to one sharp point, not a copy-paste.
6. **Hallucinated percentages** — News article snippets often don't contain exact current-day % moves. The model fills in plausible-sounding numbers that are wrong. Always pull from bloom-cli first (Step 0), then narrate around verified numbers.
