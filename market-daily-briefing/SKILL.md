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
| **Bloom MCP** (`https://api.getbloom.app/mcp/`, Bearer: `${BLOOM_MCP_API_KEY:-test-api-key}`) | Check what stocks Bloom users are watching — front-load coverage of these |

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

# Index prices (--timeframes 1d returns intraday points for today)
for SYM in SPY QQQ IWM; do
  OUTFILE="/tmp/bloom/$(echo $SYM | tr '[:upper:]' '[:lower:]').json"
  if ! bloom price "$SYM" --timeframes 1d -f json -o "$OUTFILE" 2>/tmp/bloom/price_${SYM}.err; then
    echo "WARN: bloom price $SYM failed ($(cat /tmp/bloom/price_${SYM}.err))" >&2
    echo '{}' > "$OUTFILE"
  fi
done
```

### Validate bloom output before extraction

If any bloom command returned empty, null, or error JSON, skip the verification step for that data source rather than passing bad data to the model.

```bash
# Helper: check if file has valid, non-empty bloom data
bloom_valid() {
  local f="$1"
  [ -s "$f" ] && ! grep -q '"status":"error"' "$f" && [ "$(jq 'length' "$f" 2>/dev/null)" != "0" ]
}
```

Extract key data:

> **Verified bloom-cli output formats (as of bloom-cli v1.x):**
> - `bloom market --type top_movers -f json` → `{"status":"success","data":{"stocks":[{"symbol","change_percent","market_cap",...}]}}`
> - `bloom sentiment -f json` → `{"aaii_sentiment":{"bullish_percent","bearish_percent",...},"cnn_fear_greed":{"index_value","level",...},...}`
> - `bloom price <SYM> --timeframes 1d -f json` → `{"type":"chart_data","timeframes":{"1d":[{"date","price"},...]}}` (time series, no single change_pct field)

```bash
# Top movers summary
if bloom_valid /tmp/bloom/movers.json; then
  jq '.data.stocks[] | {symbol: .symbol, change_pct: .change_percent, market_cap: .market_cap}' /tmp/bloom/movers.json
else
  echo "SKIP: movers data unavailable or invalid" >&2
fi

# Sentiment
if bloom_valid /tmp/bloom/sentiment.json; then
  jq '{fear_greed: .cnn_fear_greed.index_value, fear_greed_label: .cnn_fear_greed.level, aaii_bull: .aaii_sentiment.bullish_percent, aaii_bear: .aaii_sentiment.bearish_percent}' /tmp/bloom/sentiment.json
else
  echo "SKIP: sentiment data unavailable or invalid" >&2
fi

# Index prices — extract latest price and compute change_pct from the 1d time series
# bloom price returns {"timeframes":{"1d":[{"date":"...","price":N},...]}}
# We take first and last entries to compute the day's percentage change.
for SYM in SPY QQQ IWM; do
  OUTFILE="/tmp/bloom/$(echo $SYM | tr '[:upper:]' '[:lower:]').json"
  if bloom_valid "$OUTFILE"; then
    RESULT=$(jq --arg sym "$SYM" '{
      symbol: $sym,
      latest_price: (.timeframes["1d"] | last | .price),
      first_price: (.timeframes["1d"] | first | .price),
      change_pct: (
        ((.timeframes["1d"] | last | .price) - (.timeframes["1d"] | first | .price))
        / (.timeframes["1d"] | first | .price) * 100 * 100 | round / 100
      ),
      data_points: (.timeframes["1d"] | length)
    }' "$OUTFILE" 2>/dev/null)
    # Guard against null computation (e.g. first_price is 0 or missing)
    if [ -z "$RESULT" ] || echo "$RESULT" | jq -e '.change_pct == null or .latest_price == null' >/dev/null 2>&1; then
      echo "WARN: $SYM price computation returned null — inspect raw JSON" >&2
      echo "$RESULT"
    else
      echo "$RESULT"
    fi
  else
    echo "SKIP: $SYM price data unavailable or invalid" >&2
  fi
done
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
