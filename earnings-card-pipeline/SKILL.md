---
name: earnings-card-pipeline
description: Use when the cron fires at 8am ET on Mondays — pulls the week's major earnings events, generates a die-cut sticker style card for each, creates Typefully drafts, and reports to Signal.
---

# Earnings Card Pipeline

Every Monday, pulls up to 5 major companies reporting earnings that week, writes an analyst-perspective take for each, generates a styled earnings card via Nano Banana Pro, and schedules tweets via Typefully.

---

## Tools

| Tool | Purpose |
|------|---------|
| `web-search` skill | Serper query for earnings calendar + analyst estimates |
| `exec` (curl) | Benzinga API for earnings calendar |
| `nano-banana-pro` skill | Generate 1080×1080 die-cut sticker earnings card |
| `typefully` skill | Upload card + create scheduled tweet draft |
| `message` tool | Report to Signal group |

---

## Workflow

### Step 1 — Pull This Week's Earnings

**Benzinga API:**
```bash
source ~/bloom/.env  # loads BENZINGA_TOKEN

curl -s "https://api.benzinga.com/api/v2.1/calendar/earnings?\
token=$BENZINGA_TOKEN\
&date_from=$(date +%Y-%m-%d)\
&date_to=$(date -v+5d +%Y-%m-%d)\
&importance=3" | python3 -m json.tool
```
(importance=3 filters to major companies only)

**Serper supplement** (if Benzinga returns thin results):
Use web-search skill with query: `"earnings calendar this week [Month] [Year]"`

From the combined results, select up to **5 mega-cap or widely-held names** (Apple, Google, Meta, Amazon, Netflix, NVDA, etc. — names retail investors recognize). Skip micro-caps.

### Step 2 — Research Each Company

For each company, use web-search to find:
- **EPS consensus estimate** (e.g. "$1.42 EPS expected")
- **Revenue estimate** (e.g. "$94.3B revenue expected")
- **One key stat or narrative** to watch (guidance, margins, AI spend, etc.)

Write a **2-3 sentence AI take** for each:
- What the market expects
- The key thing to watch
- What a beat or miss would signal

### Step 3 — Resolve GEMINI_API_KEY

```bash
GEMINI_API_KEY=$(python3 -c "import json,os; d=json.load(open(os.path.expanduser('~/.clawdbot/clawdbot.json'))); print(d.get('skills',{}).get('entries',{}).get('nano-banana-pro',{}).get('apiKey','') or d['env']['vars'].get('GEMINI_API_KEY',''))" 2>/dev/null)
export GEMINI_API_KEY
```

### Step 4 — Generate Earnings Card per Company

**ONLY use Nano Banana Pro. Never fall back to PIL.**

```bash
uv run /opt/homebrew/lib/node_modules/clawdbot/skills/nano-banana-pro/scripts/generate_image.py
```

**Design spec per card (1080×1080):**
- Style: Die-cut sticker with thick white border — **perfectly upright, 0° rotation, no tilt, no skew**
- Background: Dark navy `#0f172a`
- Ticker: Bold white, top-left, large
- Report day: "Reports [weekday]" in small text below ticker
- EPS section: "Est. EPS: $[X]" 
- Revenue section: "Est. Rev: $[X]B"
- Key stat or narrative callout
- BEAT badge (green `#22c55e`) or MISS badge (red) — use as a design element even pre-report (label it "Est." to clarify)
- Bloom wordmark bottom-right
- Overall feel: financial data card, confident and clean

Output: `/tmp/earnings-card-[TICKER]-$(date +%Y%m%d).png`

**exec timeout: 300s minimum** — image generation at 2K takes 60–120s; use `timeout=300, yieldMs=280000`

### Step 5 — Write Tweet per Company

Format (keep under 240 chars):
```
$[TICKER] reports [day]. Est: $[EPS] EPS / $[rev]B rev. [Key watch point]. [1-sentence AI take].
```

No hashtags. No emojis. Confident and data-forward.

### Step 6 — Upload + Schedule Each Card

```bash
cd ~/clawd/skills/typefully

# For each company:
node scripts/typefully.js media:upload 286685 /tmp/earnings-card-[TICKER]-$(date +%Y%m%d).png
# → returns media_id

node scripts/typefully.js drafts:create 286685 \
  --platform x \
  --text "$[TICKER] reports [day]. Est: $[EPS] EPS / $[rev]. [Key watch]. [AI take]." \
  --media <media_id>
# Do NOT add --schedule. Save as unscheduled draft only — Eric reviews before posting.
# → returns draft_id + scheduled time
```

Process all companies sequentially (one at a time).

### Step 7 — Report to Signal

Send to `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`:

```
📅 Earnings cards queued for this week:

[For each company:]
$[TICKER] — [day] | Est: $[EPS] / $[rev]B
Tweet: [text]
Draft: https://typefully.com/?a=286685&d=[draft_id] | Scheduled: [time]

[Note any Gemini/Nano Banana failures]
```

---

## Delivery

- Signal group: `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`
- Typefully account: 286685
- Cards: `/tmp/earnings-card-TICKER-YYYYMMDD.png`

---

## Cron Config

- **ID:** `0400d7b1-679c-40da-8772-def88fbb7824`
- **Schedule:** `0 8 * * 1` (8am ET, Mondays)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Tilted cards** — always include "perfectly upright, 0° rotation, no tilt, no skew" in the image prompt. Gemini interprets "sticker" as slightly rotated; override it explicitly.
2. **PIL fallback** — ONLY use Nano Banana Pro. If it fails, log the failure and skip that card; do not generate a PIL fallback.
3. **Missing GEMINI_API_KEY** — always resolve from clawdbot.json before calling Nano Banana Pro.
4. **Including micro-caps** — stick to names retail investors know. If you've never heard of it, skip it.
5. **Wrong date math on macOS** — macOS `date` uses `-v+5d` not `--date=+5days`. Use: `$(date -v+5d +%Y-%m-%d)`.
6. **Overloading the queue** — use `next-free-slot` for each card to spread them out throughout the week.
7. **Vague AI take** — "could move the stock" is not useful. Be specific: "margin guidance matters more than EPS beat."
8. **Not reporting failures** — if Nano Banana Pro fails for one ticker, still process the others and report the failure in Signal.
