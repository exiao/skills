---
name: post-investinglog-trades
description: Use when the cron fires at 4pm ET on weekdays — picks the best unposted trade from the investing-log repo, generates a trade card, creates a Typefully draft, and reports to Signal.
---

# Investing Log Trades Pipeline

Pulls recent AI model trades from the Bloom investing-log repo, picks the most compelling unposted one, generates a branded trade card, schedules a tweet, and reports to Signal.

---

## Tools

| Tool | Purpose |
|------|---------|
| `gh` CLI | Fetch trade files from Bloom-Invest/investing-log repo |
| `web-search` skill | Enrich with current price + YTD % |
| `nano-banana-pro` skill | Generate 1080×1080 trade card |
| `typefully` skill | Upload card + create scheduled tweet draft |
| `message` tool | Report to Signal group |

---

## Workflow

### Step 1 — Fetch Latest Trades

Fetch the 5 most recent trades from each model folder:

```bash
# Claude
gh api 'repos/Bloom-Invest/investing-log/contents/trades/claude' \
  --jq '[.[] | {name: .name, download_url: .download_url}] | sort_by(.name) | reverse | .[0:5]'

# OpenAI
gh api 'repos/Bloom-Invest/investing-log/contents/trades/openai' \
  --jq '[.[] | {name: .name, download_url: .download_url}] | sort_by(.name) | reverse | .[0:5]'

# Gemini
gh api 'repos/Bloom-Invest/investing-log/contents/trades/gemini' \
  --jq '[.[] | {name: .name, download_url: .download_url}] | sort_by(.name) | reverse | .[0:5]'
```

**Filter out** any filenames containing `NOACTION` or `SCENARIO`.

Download each trade file:
```bash
curl -sL "<download_url>" -o /tmp/trade-<filename>.md
```

### Step 2 — Dedup Check

Read state file: `~/clawd/memory/il-pipeline-state.json`

```json
{
  "posted": ["2025-01-15_AAPL_BUY_claude.md", "..."]
}
```

Skip any trade whose filename is already in `posted`. If **all** candidate trades are already posted: **NO_REPLY** (stop silently).

### Step 3 — Pick the Best Trade

Priority order:
1. **Action:** BUY or REBALANCE > SELL
2. **Model:** claude > openai > gemini
3. **Market value:** Larger allocation % = higher priority
4. **Ticker recognition:** Widely-known ticker > obscure

Pick exactly one trade. Note the filename, model, and full path.

### Step 4 — Parse Trade File

Extract from the trade markdown:
- `ticker` — e.g. AAPL
- `action` — BUY / SELL / REBALANCE
- `fill_price` — price paid/received
- `allocation_pct` — % of portfolio allocated
- `rationale` — 1 sentence summary of why
- `date` — trade date

### Step 5 — Enrich

Via web-search skill:
- Current stock price
- YTD % change

### Step 6 — Resolve GEMINI_API_KEY

```bash
GEMINI_API_KEY=$(python3 -c "import json, os; d=json.load(open(os.path.expanduser('~/.clawdbot/clawdbot.json'))); print(d.get('skills',{}).get('entries',{}).get('nano-banana-pro',{}).get('apiKey','') or d['env']['vars'].get('GEMINI_API_KEY',''))" 2>/dev/null)
export GEMINI_API_KEY
```

### Step 7 — Generate Trade Card (1080×1080)

Use Nano Banana Pro:
```bash
uv run /opt/homebrew/lib/node_modules/clawdbot/skills/nano-banana-pro/scripts/generate_image.py
```

**Design spec:**
- Background: warm off-white `#fffefa`
- Ticker as hero element: large, Bloom orange `#F5A623`, with brushstroke underline
- Row below ticker: fill price | allocation % | YTD %
- Rationale text in a white card/callout box
- Action indicator: green dot (BUY/REBALANCE) or red dot (SELL)
- Model attribution: small text "claude" / "openai" / "gemini" in corner
- "bloom" wordmark bottom-right

Output: `/tmp/trade-card-[TICKER]-$(date +%Y%m%d).png`

### Step 8 — Write Tweet

Rules:
- Max 250 characters
- Data-led, conversational tone
- No hashtags, no emojis
- Lead with the action and ticker
- Include fill price, allocation, and brief rationale

Example:
```
Bloom's AI bought $NVDA today — added a 4% position at $127.40. AI infrastructure is still early; this is a long-term hold, not a trade.

YTD: +18.3%
```

### Step 9 — Ensure Tag + Upload + Create Draft

```bash
cd ~/clawd/skills/typefully

# Ensure 'investing-log' tag exists (safe to run even if it already exists)
node scripts/typefully.js tags:create 286685 --name 'investing-log' 2>/dev/null || true

# Upload card
node scripts/typefully.js media:upload 286685 /tmp/trade-card-[TICKER]-$(date +%Y%m%d).png
# → returns media_id

# Create draft
node scripts/typefully.js drafts:create 286685 \
  --platform x \
  --text "<tweet_text>" \
  --media <media_id> \
  --tags investing-log
# Do NOT add --schedule. Save as unscheduled draft only — Eric reviews before posting.
# → returns draft_id + scheduled time
```

### Step 10 — Update State File

```bash
# Read current state
cat ~/clawd/memory/il-pipeline-state.json
```

Add the posted trade's filename to the `posted` array. Keep only the last 50 entries (trim oldest if over 50).

Write back to `~/clawd/memory/il-pipeline-state.json`.

If the file doesn't exist, create it:
```json
{
  "posted": ["<filename>"]
}
```

### Step 11 — Report to Signal

Send to `$SIGNAL_GROUP_ID`:  # set SIGNAL_GROUP_ID in your env

```
📊 Investing Log trade posted:
$[TICKER] — [ACTION] @ $[fill_price]
Allocation: [X]% | YTD: [+/-X%]
Model: [claude/openai/gemini]

Tweet: [tweet text]
Typefully: https://typefully.com/?a=286685&d=[draft_id]
Scheduled: [time]
```

---

## Delivery

- Signal group: `$SIGNAL_GROUP_ID`  # set SIGNAL_GROUP_ID in your env
- Typefully account: 286685 with `investing-log` tag
- State file: `~/clawd/memory/il-pipeline-state.json`
- Card: `/tmp/trade-card-TICKER-YYYYMMDD.png`

---

## Cron Config

- **ID:** `117fc1e3-86a7-48d7-8a4b-541cf053e715`
- **Schedule:** `0 16 * * 1-5` (4pm ET, Mon–Fri)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Posting NOACTION/SCENARIO files** — always filter these out in Step 1.
2. **Skipping dedup check** — always read il-pipeline-state.json first; repeating a tweet is embarrassing.
3. **Wrong Typefully account** — use account ID `286685` (not 22264 which is Eric's personal).
4. **PIL fallback** — never use PIL/Pillow. Only Nano Banana Pro for image generation.
5. **State file not updated** — always write back after successful post; otherwise same trade posts again tomorrow.
6. **Overwriting old state** — keep last 50 entries, don't truncate to just the new one.
7. **Not creating the tag** — run `tags:create` before `drafts:create`; Typefully may reject unknown tags.

## Constitutional Rules
- NEVER lower the quality bar to find something to post. If nothing meets criteria, report "nothing to post today" and why.
- NEVER post without reading back the full content first.
- Always create as draft first; do not schedule or publish directly.
