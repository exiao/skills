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

**Source A (primary): OpenInsider pre-built page**

**IMPORTANT: The screener URL with filters often returns zero data rows even when trades exist.** Use the pre-built page instead and filter client-side:
```
http://openinsider.com/insider-purchases-25k
```
This returns ALL insider purchases >$25k filed in the last ~2 days. Filter client-side for >$500k and CEO/CFO/COB/Director titles.

The screener URL (below) can be tried as a secondary option but frequently returns empty:
```
http://openinsider.com/screener?s=&o=&pl=500000&ph=&ll=&lh=&fd=1&fdr=&td=0&tdr=&fession=&cession=at&t2=1&xp=1&ic1ceo=1&ic2cfo=1&ic3cob=1&ic5=1&hft=0&grp=0&cnt=100&page=1
```

**Parsing the HTML table:**
- The data table has class `tinytable` — use `re.search(r'<table[^>]*class="tinytable[^"]*"[^>]*>(.*?)</table>', html, re.DOTALL)` to extract it
- Extract rows with `re.findall(r'<tr[^>]*>(.*?)</tr>', table, re.DOTALL)` — skip row 0 (header)
- Each data row has 17 cells (via `re.findall(r'<td[^>]*>(.*?)</td>', row, re.DOTALL)`). Key indices (0-based):
  - [0]: Flags (M=Multiple, D=Derivative, blank)
  - [1]: Filing datetime (e.g. "2026-05-04 16:05:25")
  - [2]: Trade date (e.g. "2026-04-30")
  - [3]: Ticker (embedded in tooltip markup; extract after `UnTip()">` e.g. `re.search(r'UnTip\(\)">(\w+)', raw_cell)`)
  - [4]: Company name (plain text after stripping tags)
  - [5]: Insider name
  - [6]: Title (CEO, CFO, Dir, COB, 10%, See Remarks, etc.)
  - [7]: Trade type ("P - Purchase")
  - [8]: Price (e.g. "$13.16")
  - [9]: Shares change (e.g. "+254,100")
  - [10]: Total shares owned after trade
  - [11]: Ownership change % (e.g. "+13%")
  - [12]: Dollar value (e.g. "+$3,342,856")
- **Filter logic:** cell [12] value >= $500,000 AND cell [6] contains CEO/CFO/COB/Dir/Director/Chairman
- **Cluster detection:** Multiple insiders buying the same ticker on the same day = strongest possible signal. Prioritize these.

Use `curl -sL` piped to inline `python3 -c`. The `tinytable` class reliably identifies the data table even on the pre-built pages.

**Source B (fallback): SEC EDGAR Form 4 scraper**

If OpenInsider is unreachable on both HTTP and HTTPS, fall back to the SEC EDGAR full-text search API directly. Search for Form 4 filings mentioning "open market", then parse each XML filing for purchase transactions >= $500k by officers/directors.

Output should be a JSON array of qualifying trades with ticker, company, insider_name, title, shares, price, total_value, trade_date, filing_date, and sec_url.

**Source selection logic:**
1. Try OpenInsider `insider-purchases-25k` → if data returned, use it (filter client-side)
2. Try OpenInsider screener URL → if data returned, use it
3. Run EDGAR scraper → use its results
4. If all fail, report the failure (don't silently skip)

### Step 2 — Pick the Best Trade

Score trades by:
- **Role:** CEO/CFO > Director > Other
- **Dollar value:** Larger = better
- **Company:** Well-known / widely-held > obscure
- **Stock context:** Down YTD is a bonus (insider buying dip = conviction signal)
- **Multiple insiders buying same stock** = strong bonus (cluster buy)

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
source ~/.hermes/.env  # loads GEMINI_API_KEY
```

**IMPORTANT:** The Nano Banana Pro script requires `GEMINI_API_KEY` as an environment variable. You must export it explicitly when calling the script:
```bash
source ~/.hermes/.env && GEMINI_API_KEY="$GEMINI_API_KEY" uv run ...
```
Just `source ~/.hermes/.env` alone is not sufficient if the script checks `os.environ` — the variable must be exported or passed inline.

### Step 6 — Generate Trade Receipt Card (1080×1080)

Use Nano Banana Pro:
```bash
source ~/.hermes/.env && GEMINI_API_KEY="$GEMINI_API_KEY" uv run ~/.hermes/skills/creative/nano-banana-pro/scripts/generate_image.py \
  --prompt "<detailed design prompt>" \
  --filename "/tmp/insider-trade-card-$(date +%Y%m%d).png" \
  --resolution 1K \
  --aspect-ratio 1:1 \
  --model pro
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
- If cluster buy, note "+ N directors bought same day"
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

SEC Form 4 URLs are typically ~95 chars. Budget accordingly. Test with `echo -n "..." | wc -c`.

### Step 8 — Upload Card + Create Typefully Draft

The Bloom Typefully social set ID is **$TYPEFULLY_SOCIAL_SET_ID**.

```bash
cd ~/.hermes/skills/marketing/typefully

# Upload media
TYPEFULLY_API_KEY=<key> node scripts/typefully.js media:upload $TYPEFULLY_SOCIAL_SET_ID /tmp/insider-trade-card-$(date +%Y%m%d).png
# → returns media_id

# Create draft with media (unscheduled)
TYPEFULLY_API_KEY=<key> node scripts/typefully.js drafts:create $TYPEFULLY_SOCIAL_SET_ID --platform x --text "<tweet_text>" --media <media_id>
# Do NOT add --schedule. Save as unscheduled draft only — Eric reviews before posting.
# → returns draft_id
```

**Note:** `TYPEFULLY_SOCIAL_SET_ID` is not set in .env. Use `$TYPEFULLY_SOCIAL_SET_ID` for Bloom. The API key is `TYPEFULLY_API_KEY` from .env.

### Step 9 — Report

Include in your final reply (cron delivery handles routing to Signal):

```
📈 Insider trade found:
[Insider name], [Role] — [Company] ($TICKER)
Bought: [shares] shares @ $[price] = $[total]
Filed: [date]
Stock: $[current] | YTD: [+/-X%]

Tweet: [tweet text]
Typefully: https://typefully.com/?d=[draft_id]&a=$TYPEFULLY_SOCIAL_SET_ID
```

---

## Delivery

- Cron delivery: announces to Marketing Signal group automatically
- Typefully account: social_set_id `$TYPEFULLY_SOCIAL_SET_ID` (Bloom the configured Typefully account)
- Card saved to: `/tmp/insider-trade-card-YYYYMMDD.png`

---

## Cron Config

- **ID:** `$CRON_JOB_ID`
- **Schedule:** `0 9,14 * * 1-5` (9am + 2pm ET, Mon–Fri)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Posting 10b5-1 trades** — the screener URL already excludes them (`xs=1`), but double-check the raw data. 10b5-1 = pre-scheduled, not discretionary.
2. **Using PIL/Pillow fallback** — always use Nano Banana Pro for image generation. Never fall back to Python PIL.
3. **Logo too small** — always validate logo file is >5KB before using. Placeholder/icon files are useless.
4. **Tweet over 260 chars** — count carefully; SEC Form 4 URLs are ~95 chars. Use `echo -n | wc -c` to verify.
5. **Missing GEMINI_API_KEY** — must pass inline: `GEMINI_API_KEY="$GEMINI_API_KEY" uv run ...`. Just sourcing .env isn't enough.
6. **Scheduling without checking** — use `next-free-slot` to avoid stacking tweets; Typefully handles spacing.
7. **Reporting when no trade found** — if Step 2 yields nothing, NO_REPLY silently. Don't send a "nothing found" message.
8. **Using screener URL as primary source** — it frequently returns empty HTML. Always start with `insider-purchases-25k` page and filter client-side.
9. **TYPEFULLY_SOCIAL_SET_ID not in .env** — set it via env or discover with `social-sets:list`.
10. **Not detecting cluster buys** — when multiple insiders buy the same ticker on the same day, that's the strongest signal. Always check for this pattern and highlight it in the tweet.

## Constitutional Rules
- NEVER lower the quality bar to find something to post. If nothing meets criteria, report "nothing to post today" and why.
- NEVER post without reading back the full content first.
- Always create as draft first; do not schedule or publish directly.
