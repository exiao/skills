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
| **Bloom MCP** (`https://api.getbloom.app/mcp/`, Bearer: `${BLOOM_MCP_API_KEY}`) | Check what stocks Bloom users are watching — front-load coverage of these. Note: `BLOOM_MCP_API_KEY` is a separate credential from bloom-cli's `BLOOM_API_KEY`. |

---

## Step 0: Pull Market Data (before web search)

Run this block first. It gives you ground-truth numbers before any web search. All percentages in the final briefing must come from here, not from article snippets.

```bash
mkdir -p /tmp/bloom

# Today's actual top movers (top 20 only — stocks outside this set won't have verified data)
# Note: verify flag names against `bloom --help` if this errors; flags may differ by version
bloom market --type top_movers --limit 20 -f json > /tmp/bloom/movers.json 2>/tmp/bloom/movers.err \
  && jq empty /tmp/bloom/movers.json 2>/dev/null \
  || { echo "WARN: bloom market failed or invalid JSON ($(cat /tmp/bloom/movers.err))" >&2; echo '{"status":"error"}' > /tmp/bloom/movers.json; }

# Fear & Greed + AAII sentiment
bloom sentiment -f json > /tmp/bloom/sentiment.json 2>/tmp/bloom/sentiment.err \
  && jq empty /tmp/bloom/sentiment.json 2>/dev/null \
  || { echo "WARN: bloom sentiment failed or invalid JSON ($(cat /tmp/bloom/sentiment.err))" >&2; echo '{"status":"error"}' > /tmp/bloom/sentiment.json; }

# Major index data (includes day-over-day change_pct directly from the API)
bloom market --type major_indexes -f json > /tmp/bloom/indexes.json 2>/tmp/bloom/indexes.err \
  && jq empty /tmp/bloom/indexes.json 2>/dev/null \
  || { echo "WARN: bloom market major_indexes failed or invalid JSON ($(cat /tmp/bloom/indexes.err))" >&2; echo '{"status":"error"}' > /tmp/bloom/indexes.json; }
```

### Validate bloom output before extraction

If any bloom command returned empty, null, or error JSON, skip the verification step for that data source rather than passing bad data to the model.

> **Verified bloom-cli output formats (as of bloom-cli v1.x):**
> - `bloom market --type top_movers -f json` → `{"status":"success","data":{"stocks":[{"symbol","change_percent","market_cap",...}]}}`
> - `bloom market --type major_indexes -f json` → `{"status":"success","data":{"SPY":{"change_pct":-0.42,"price":512.30,"first_price":515.47,...},...}}` (day-over-day change fields directly, no manual computation needed; `first_price` = previous close)
> - `bloom sentiment -f json` → `{"aaii_sentiment":{"bullish_percent","bearish_percent",...},"cnn_fear_greed":{"index_value","level",...},...}`

> ⚠️ **Scope note:** Claude Code runs each Bash tool call in a fresh shell. The `bloom_valid()` function defined below **must be in the same shell block** as all the `if bloom_valid ...` calls that use it. Do not split the function definition and its callers across separate code blocks.

```bash
# Helper: check if file has valid, non-empty bloom data
# Uses jq instead of grep to correctly handle both '"status":"error"' and '"status": "error"'
bloom_valid() {
  local f="$1"
  [ -s "$f" ] && jq -e '.status != "error"' "$f" >/dev/null 2>&1 && {
    local len
    len=$(jq 'if .data then (.data | length) else (keys | length) end' "$f" 2>/dev/null)
    [ "${len:-0}" != "0" ]
  }
}

# Top movers summary
if bloom_valid /tmp/bloom/movers.json; then
  jq '.data.stocks[] | {symbol: .symbol, change_pct: .change_percent, market_cap: .market_cap}' /tmp/bloom/movers.json
else
  echo "SKIP: movers data unavailable or invalid" >&2
fi

# Sentiment — with null guards in case paths are missing or schema differs across versions
# Paths may differ across bloom-cli versions — confirm against live output if extraction returns null
if bloom_valid /tmp/bloom/sentiment.json; then
  jq '{
    fear_greed: (.cnn_fear_greed.index_value // null),
    fear_greed_label: (.cnn_fear_greed.level // null),
    aaii_bull: (.aaii_sentiment.bullish_percent // null),
    aaii_bear: (.aaii_sentiment.bearish_percent // null)
  }' /tmp/bloom/sentiment.json
else
  echo "SKIP: sentiment data unavailable or invalid" >&2
fi

# Major index summary — change_pct comes directly from the API (day-over-day; first_price = previous close)
# Inline fallback: if change_pct is null, compute from price and first_price
# Only extract from .data to avoid leaking non-index keys (status, etc.) into output
# Expected output shape: {"symbol":"SPY","change_pct":-0.42,"price":512.30}
if bloom_valid /tmp/bloom/indexes.json; then
  jq '.data | to_entries[] | {
    symbol: .key,
    change_pct: (.value.change_pct // (
      if .value.price and .value.first_price and .value.first_price != 0
      then ((.value.price - .value.first_price) / .value.first_price * 100)
      else null
      end
    )),
    price: .value.price
  }' /tmp/bloom/indexes.json
else
  echo "SKIP: index data unavailable or invalid" >&2
fi
```
Keep these numbers in context. Every stock percentage you write must come from this data.

If any individual field is null after extraction, fall back to the news article's number but mark it as unverified: e.g., `~+2.3% (unverified — source: article)`.

---

## What to Cover

### 0. Verified Numbers Rule
Every stock percentage mentioned MUST be verified against bloom-cli price data. If bloom-cli shows a different number than a news article, use bloom-cli's number. Never estimate or round aggressively.

**Dataset coverage:** Step 0 only fetches the top 20 movers + major indexes (SPY/QQQ/IWM/DIA/etc.). Stocks not in the top 20 won't have bloom-cli verified data. For earnings reactions on stocks outside the dataset, use the news article's number but mark it as unverified: e.g., "~+4.1% (unverified — source: article)".

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
Required env vars for delivery:
```bash
export SKILLS_DIR=/path/to/your/skills          # directory containing skill folders
export SIGNAL_BRIEFING_GROUP=<group-id>          # Signal group for briefing delivery
export TYPEFULLY_SOCIAL_SET_ID=<social-set-id>   # Typefully social set for @investwithbloom
```

Send to the Signal group configured in `$SIGNAL_BRIEFING_GROUP` (or the Cron Admin group if unset).

```python
import os

# Use message tool
channel = "signal"
target = os.environ.get("SIGNAL_BRIEFING_GROUP", "<set SIGNAL_BRIEFING_GROUP env var>")
```

### Typefully (secondary — @investwithbloom)
After Signal, create a public-facing tweet of the sharpest single data point:

```bash
# SKILLS_DIR must point to the directory containing skill folders (e.g. /Users/yourname/clawd/skills).
# TYPEFULLY_SOCIAL_SET_ID is the Typefully social set ID for @investwithbloom (set as an env var;
# do not hardcode the numeric ID here — store it in the gateway env or .env file).
node "$SKILLS_DIR/typefully/scripts/typefully.js" drafts:create "${TYPEFULLY_SOCIAL_SET_ID:?}" \
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
