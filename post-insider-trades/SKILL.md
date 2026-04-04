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

### Step 1 — Scrape Insider Trade Data (multi-source)

**Source A (primary): OpenInsider via HTTP**

Try HTTP first (HTTPS is unreliable):
```
http://openinsider.com/screener?s=&o=&pl=500&ph=&ll=&lh=&fd=1&fdr=&td=0&tdr=&feession=&cession=at&t2=1&xp=1&ic1ceo=1&ic2cfo=1&ic3cob=1&ic5=1&hft=0&grp=0&cnt=100&page=1
```
This filters: P-Purchase only, >$500k value, filed in last 24h, CEO/CFO/COB/Director, excludes 10b5-1 plans.

Use `web_fetch` first. If that fails or returns empty/error, try `browser` with the same URL. Parse the HTML table for trade data.

**Source B (fallback): SEC EDGAR Form 4 scraper**

If OpenInsider is unreachable on both HTTP and HTTPS, fall back to the SEC EDGAR full-text search API directly. Search for Form 4 filings mentioning "open market", then parse each XML filing for purchase transactions >= $500k by officers/directors.

Output should be a JSON array of qualifying trades with ticker, company, insider_name, title, shares, price, total_value, trade_date, filing_date, and sec_url.

**Source selection logic:**
1. Try OpenInsider HTTP → if data returned, use it
2. Try OpenInsider HTTPS → if data returned, use it
3. Run EDGAR scraper → use its results
4. If all fail, report the failure (don't silently skip)

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
node scripts/typefully.js media:upload $TYPEFULLY_SOCIAL_SET_ID /tmp/insider-trade-card-$(date +%Y%m%d).png
# → returns media_id

# Create draft with media + scheduled slot
node scripts/typefully.js drafts:create $TYPEFULLY_SOCIAL_SET_ID --platform x --text "<tweet_text>" --media <media_id>
# Do NOT add --schedule. Save as unscheduled draft only — Eric reviews before posting.
# → returns draft_id and scheduled time
```

### Step 9 — Report

Include in your final reply (cron delivery handles routing to Signal):

```
📈 Insider trade found:
[Insider name], [Role] — [Company] ($TICKER)
Bought: [shares] shares @ $[price] = $[total]
Filed: [date]
Stock: $[current] | YTD: [+/-X%]

Tweet: [tweet text]
Typefully: https://typefully.com/?a=$TYPEFULLY_SOCIAL_SET_ID&d=[draft_id]
```

---

## Delivery

- Cron delivery: announces to Marketing Signal group automatically
- Typefully account: `$TYPEFULLY_SOCIAL_SET_ID` (Bloom @invest.with.bloom)
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
