---
name: post-insider-trades
description: Use when the cron fires at 9am or 2pm ET on weekdays — scrapes OpenInsider for significant recent insider buys, generates a brokerage-receipt trade card, writes a tweet, creates a Typefully draft, and reports to Signal.
---

# Insider Trades Pipeline

Finds the most compelling recent insider buy (CEO/CFO/Director, >$500k, filed last 24h), generates a visual trade receipt card, schedules a tweet via Typefully, and reports to Signal.

---

## Tools

| Tool | Purpose |
|------|---------|
| `web_fetch` / `browser` | Scrape OpenInsider screener |
| `web-search` skill | Enrich with current price, YTD %, news, SEC Form 4 URL |
| `nano-banana-pro` skill | Generate 1080×1080 trade receipt card image |
| `typefully` skill | Upload card + create scheduled tweet draft |
| `message` tool | Report to Signal group |

---

## Workflow

### Step 1 — Scrape OpenInsider

Fetch this URL (web_fetch or browser):
```
https://openinsider.com/screener?s=&o=&pl=500000&ph=&ll=&lh=&fd=2&fdr=&td=0&tdr=&fdlyl=&fdlyh=&daysago=1&xs=1&cnt=20&action=1
```
This filters: P-Purchase only, >$500k value, filed in last 24h, excludes 10b5-1 plans.

### Step 2 — Pick the Best Trade

Score trades by:
- **Role:** CEO/CFO > Director > Other
- **Dollar value:** Larger = better
- **Company:** Well-known / widely-held > obscure
- **Stock context:** Down YTD is a bonus (insider buying dip = conviction signal)
- **Multiple insiders buying same stock** = strong bonus

If no qualifying trades are found: **NO_REPLY** (stop, send nothing).

### Step 3 — Enrich

Using web-search skill, gather:
- Current stock price
- YTD % change
- Recent news (1-2 headlines)
- SEC Form 4 URL (search "TICKER insider Form 4 SEC EDGAR [name]")

### Step 4 — Fetch Company Logo

```bash
# Try Wikipedia Commons / company Wikipedia page for logo
curl -sL "https://en.wikipedia.org/wiki/[Company_Name]" | grep -i 'logo\|svg\|png' | head -5
# Download candidate logo
curl -sL "[logo_url]" -o /tmp/insider-logo.png
# Validate: must be >5KB
wc -c /tmp/insider-logo.png
```
If logo fetch fails or file is <5KB, skip the logo (proceed without it).

### Step 5 — Resolve GEMINI_API_KEY

```bash
GEMINI_API_KEY=$(python3 -c "import json, os; d=json.load(open(os.path.expanduser('~/.openclaw/openclaw.json'))); print(d.get('skills',{}).get('entries',{}).get('nano-banana-pro',{}).get('apiKey','') or d['env']['vars'].get('GEMINI_API_KEY',''))" 2>/dev/null)
export GEMINI_API_KEY
```

### Step 6 — Generate Trade Receipt Card (1080×1080)

Use Nano Banana Pro:
```bash
uv run ~/clawd/skills/nano-banana-pro/scripts/generate_image.py
```

**Design spec:**
- Warm off-white background (#fffdf7)
- Company logo top-left (if fetched)
- "TRADE RECEIPT" header in small caps
- Insider name + role
- Action: PURCHASED
- Shares × price = total value (large, prominent)
- Stock ticker + current price + YTD %
- Filing date
- "bloom" wordmark bottom-right (small, subtle)
- Brokerage/receipt aesthetic — monospace font for numbers

Output: `/tmp/insider-trade-card-$(date +%Y%m%d).png`

### Step 7 — Write Tweet

Rules:
- Max 260 characters
- Who bought, how much, what company, stock context
- SEC Form 4 URL on its own line at the end
- No hashtags, no emojis, no mention of Bloom
- Data-led, matter-of-fact tone

Example format:
```
[Name], [Role] at [Company], bought $[amount] worth of $[TICKER] shares on [date]. Stock is [+/-X%] YTD.

[Form 4 URL]
```

### Step 8 — Upload Card + Create Typefully Draft

```bash
cd ~/clawd/skills/typefully

# Upload media
node scripts/typefully.js media:upload 286685 /tmp/insider-trade-card-$(date +%Y%m%d).png
# → returns media_id

# Create draft with media + scheduled slot
node scripts/typefully.js drafts:create 286685 --platform x --text "<tweet_text>" --media <media_id>
# Do NOT add --schedule. Save as unscheduled draft only — Eric reviews before posting.
# → returns draft_id and scheduled time
```

### Step 9 — Report to Signal

Send to `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`:

```
📈 Insider trade found:
[Insider name], [Role] — [Company] ($TICKER)
Bought: [shares] shares @ $[price] = $[total]
Filed: [date]
Stock: $[current] | YTD: [+/-X%]

Tweet: [tweet text]
Typefully: https://typefully.com/?a=286685&d=[draft_id]
Scheduled: [time]
```

---

## Delivery

- Signal group: `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`
- Typefully account: 286685 (Bloom @invest.with.bloom)
- Card saved to: `/tmp/insider-trade-card-YYYYMMDD.png`

---

## Cron Config

- **ID:** `76392017-245d-43bd-a6a5-899ea211467c`
- **Schedule:** `0 9,14 * * 1-5` (9am + 2pm ET, Mon–Fri)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Posting 10b5-1 trades** — the screener URL already excludes them (`xs=1`), but double-check the raw data. 10b5-1 = pre-scheduled, not discretionary.
2. **Using PIL/Pillow fallback** — always use Nano Banana Pro for image generation. Never fall back to Python PIL.
3. **Logo too small** — always validate logo file is >5KB before using. Placeholder/icon files are useless.
4. **Tweet over 260 chars** — count carefully; the Form 4 URL alone is ~60 chars.
5. **Missing GEMINI_API_KEY** — always resolve it from openclaw.json before calling Nano Banana Pro.
6. **Scheduling without checking** — use `next-free-slot` to avoid stacking tweets; Typefully handles spacing.
7. **Reporting when no trade found** — if Step 2 yields nothing, NO_REPLY silently. Don't send a "nothing found" message.

## Constitutional Rules
- NEVER lower the quality bar to find something to post. If nothing meets criteria, report "nothing to post today" and why.
- NEVER post without reading back the full content first.
- Always create as draft first; do not schedule or publish directly.
