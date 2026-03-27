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
| **Bloom MCP** (`https://api.getbloom.app/mcp/`, Bearer: `test-api-key`) | Check what stocks Bloom users are watching — front-load coverage of these |

---

## Step 0: Pull Market Data (before web search)

Run this block first. It gives you ground-truth numbers before any web search. All percentages in the final briefing must come from here, not from article snippets.

```bash
mkdir -p /tmp/bloom

# Today's actual top movers
(bloom market --type top_movers --limit 20 -o /tmp/bloom/movers.json) || echo '[]' > /tmp/bloom/movers.json

# Fear & Greed + AAII sentiment
(bloom sentiment -o /tmp/bloom/sentiment.json) || echo '{}' > /tmp/bloom/sentiment.json

# Index prices
(bloom price SPY --timeframes 1d -o /tmp/bloom/spy.json) || echo '{}' > /tmp/bloom/spy.json
(bloom price QQQ --timeframes 1d -o /tmp/bloom/qqq.json) || echo '{}' > /tmp/bloom/qqq.json
(bloom price IWM --timeframes 1d -o /tmp/bloom/iwm.json) || echo '{}' > /tmp/bloom/iwm.json
```

Extract key data:

> **Note:** The jq key paths below are based on expected bloom-cli output structure.
> If bloom wraps responses in a `"data"` envelope (e.g. `{"data": {...}}`), prepend `.data` to each path.
> Verify field names against actual `bloom` output if extraction fails (run without jq first to inspect raw JSON).

```bash
# Top movers summary (assumes top-level array; if wrapped, use '.data[]' instead of '.[]')
jq '.[] | {symbol: .symbol, change_pct: .change_pct, price: .price}' /tmp/bloom/movers.json

# Sentiment (key paths may vary — inspect raw output if these return null)
jq '{fear_greed: .cnn_fear_greed.index_value, fear_greed_label: .cnn_fear_greed.level, aaii_bull: .aaii_bullish, aaii_bear: .aaii_bearish}' /tmp/bloom/sentiment.json

# Index moves (assumes flat structure; if wrapped, use '.data.change_pct' etc.)
jq '{spy_pct: .change_pct, spy_price: .price}' /tmp/bloom/spy.json
jq '{qqq_pct: .change_pct, qqq_price: .price}' /tmp/bloom/qqq.json
jq '{iwm_pct: .change_pct, iwm_price: .price}' /tmp/bloom/iwm.json
```

Keep these numbers in context. Every stock percentage you write must come from this data.

---

## What to Cover

### 0. Verified Numbers Rule
Every stock percentage mentioned MUST be verified against bloom-cli price data. If bloom-cli shows a different number than a news article, use bloom-cli's number. Never estimate or round aggressively.

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
