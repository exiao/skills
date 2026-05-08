---
name: earnings-card-pipeline
description: Use when the cron fires at 8am ET on Mondays — pulls the week's major earnings events, generates a die-cut sticker style card for each, creates Typefully drafts, and reports to Signal.
---

# Earnings Card Pipeline

Every Monday, pulls up to 5 major companies reporting earnings that week, writes an analyst-perspective take for each, generates a styled earnings card via Nano Banana Pro, and creates unscheduled Typefully drafts for Eric review.

---

## Tools

| Tool | Purpose |
|------|---------|
| `web-search` skill | Serper query for earnings calendar + analyst estimates |
| `exec` (curl) | Benzinga API for earnings calendar |
| `nano-banana-pro` skill | Generate 1080×1080 die-cut sticker earnings card |
| `typefully` skill | Upload card + create unscheduled tweet draft |
| final response | Report to Signal group via cron delivery. Do not call message/send_message |

---

## Workflow

### Step 1 — Pull This Week's Earnings

**Discovery: Serper web search** (find which companies report this week):
1. `"most anticipated earnings week [Month] [day] [Year]"` — EarningsWhispers posts weekly lists
2. `"earnings calendar this week [Month] [Year]"` — broader coverage

**Data: bloom CLI** (get estimates and dates for discovered tickers):
```bash
# Confirm earnings dates and get EPS/revenue estimates
bloom earnings-calendar AAPL MSFT GOOG AMZN NVDA --days 7
# Returns: symbol, earnings_date, eps_estimate, market_cap

# For deeper estimates and history per ticker
bloom earnings AAPL
```

From the combined results, select up to **5 mega-cap or widely-held names** (Apple, Google, Meta, Amazon, Netflix, NVDA, AMD, etc. — names retail investors recognize). Skip micro-caps. **Skip companies that already reported** (e.g., Sunday evening releases like PLTR) even if they appear in the week's calendar.

**Do NOT use Benzinga API** — the token expires frequently and returns 401. Serper + bloom CLI covers everything needed.

### Step 2 — Research Each Company

For each company, use web-search to find:
- **EPS consensus estimate** (e.g. "$1.42 EPS expected")
- **Revenue estimate** (e.g. "$94.3B revenue expected")
- **One key stat or narrative** to watch (guidance, margins, AI spend, etc.)

Write a **2-3 sentence AI take** for each:
- What the market expects
- The key thing to watch
- What a beat or miss would signal

### Step 3 — Resolve Environment Variables

```bash
source ~/.hermes/.env
export GEMINI_API_KEY  # MUST export — the Python script reads os.environ, not shell vars
```

**Important:** `source` alone loads vars into the shell but doesn't export them. The Nano Banana Pro script spawns a subprocess that needs exported env vars.

### Step 4 — Generate Earnings Card per Company

**ONLY use Nano Banana Pro. Never fall back to PIL.**

```bash
source ~/.hermes/.env && export GEMINI_API_KEY && uv run ~/.hermes/skills/creative/nano-banana-pro/scripts/generate_image.py \
  --prompt "..." \
  --filename "/tmp/earnings-card-[TICKER]-$(date +%Y%m%d).png" \
  --resolution 1K \
  --aspect-ratio 1:1 \
  --model pro
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

**exec timeout: 300s minimum** — image generation takes 60–120s; use `timeout=300, yieldMs=280000`

**Batch generation via script file (required):** ShellExec interprets `&&` as shell backgrounding and rejects chained commands. Instead of running each card as a separate ShellExec call, write all generation commands into a single bash script (e.g., `/tmp/gen-earnings-cards.sh`) and execute it once with `timeout=600`. This avoids the `&&` error and reduces round-trips from 5+ calls to 1. Same pattern works for Typefully uploads and draft creation.

**Quote prompts safely:** Earnings prompts and tweets contain `$0.50`, `$15.58B`, and `$TICKER`. If the bash script uses `set -u` and double-quoted prompt strings, shell expansion treats `$0`, `$15`, `$JD`, etc. as variables and can crash with `unbound variable` or silently corrupt the prompt. Put long prompts and tweet text in **single quotes** inside the script, or use heredocs with quoted delimiters (`cat <<'EOF'`).

```bash
#!/bin/bash
set -e
source ~/.hermes/.env
export GEMINI_API_KEY
SCRIPT=~/.hermes/skills/creative/nano-banana-pro/scripts/generate_image.py

run_card "TICKER" 'Create a 1080x1080 financial earnings data card in die-cut sticker style... Est. EPS: $1.04 ... Est. Rev: $15.58B ...'
uv run "$SCRIPT" --prompt "$prompt" --filename "/tmp/earnings-card-TICKER-YYYYMMDD.png" \
  --resolution 1K --aspect-ratio 1:1 --model pro
# repeat for each ticker...
```

### Step 5 — Write Tweet per Company

Format (keep under 240 chars):
```
$[TICKER] reports [day]. Est: $[EPS] EPS / $[rev]B rev. [Key watch point]. [1-sentence AI take].
```

No hashtags. No emojis. Confident and data-forward.

### Step 6 — Upload + Create Each Draft

**Typefully account:** Bloom = social_set_id `$TYPEFULLY_SOCIAL_SET_ID` (discovered via `social-sets:list`). `TYPEFULLY_SOCIAL_SET_ID` is NOT in .env — use `$TYPEFULLY_SOCIAL_SET_ID` directly.

```bash
source ~/.hermes/.env && export TYPEFULLY_API_KEY

# For each company:
# 1. Upload the card image
node ~/.hermes/skills/marketing/typefully/scripts/typefully.js media:upload $TYPEFULLY_SOCIAL_SET_ID /tmp/earnings-card-[TICKER]-$(date +%Y%m%d).png
# → returns JSON with media_id field

# 2. Parse the media_id from the JSON output (use jq)
MEDIA_ID=$(node ~/.hermes/skills/marketing/typefully/scripts/typefully.js media:upload $TYPEFULLY_SOCIAL_SET_ID /tmp/earnings-card-[TICKER]-$(date +%Y%m%d).png | jq -r '.media_id')

# 3. Create draft WITH media attached in the same call
node ~/.hermes/skills/marketing/typefully/scripts/typefully.js drafts:create $TYPEFULLY_SOCIAL_SET_ID \
  --platform x \
  --text "..." \
  --media "$MEDIA_ID"
# Do NOT add --schedule. Save as unscheduled draft only — the account owner reviews before posting.
# → returns draft_id, private_url
```

**IMPORTANT: --media requires --text in drafts:update.** If you need to attach media to an existing draft after creation, you MUST pass `--text` with the existing tweet text alongside `--media`. The `drafts:update` command requires at least one content flag. Example:
```bash
node ~/.hermes/skills/marketing/typefully/scripts/typefully.js drafts:update $TYPEFULLY_SOCIAL_SET_ID <draft_id> \
  --text "<existing tweet text>" \
  --media "<media_id>"
```

**Best practice:** Upload media FIRST, then pass the media_id to `drafts:create` in a single call. This avoids the update workaround entirely.

### Step 7 — Report to Signal

Send to `$SIGNAL_MARKETING_GROUP`:

```
📅 Earnings cards queued for this week:

[For each company:]
$[TICKER] — [day] | Est: $[EPS] / $[rev]B
Tweet: [text]
Draft: https://typefully.com/?d=[draft_id]&a=$TYPEFULLY_SOCIAL_SET_ID | Status: unscheduled

[Note any Benzinga/Gemini/Nano Banana failures]
```

---

## Delivery

- Signal group: `$SIGNAL_MARKETING_GROUP` — cron delivery handles routing, do NOT send via message tool
- Typefully account: Bloom = `$TYPEFULLY_SOCIAL_SET_ID` (hardcoded, not in .env)
- Cards: `/tmp/earnings-card-TICKER-YYYYMMDD.png`

---

## Cron Config

- **ID:** `$CRON_JOB_ID`
- **Schedule:** `0 8 * * 1` (8am ET, Mondays)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Tilted cards** — always include "perfectly upright, 0° rotation, no tilt, no skew" in the image prompt. Gemini interprets "sticker" as slightly rotated; override it explicitly.
2. **PIL fallback** — ONLY use Nano Banana Pro. If it fails, log the failure and skip that card; do not generate a PIL fallback.
3. **Missing GEMINI_API_KEY export** — `source ~/.hermes/.env` loads the var but does NOT export it. Always follow with `export GEMINI_API_KEY`. The Python script uses `os.environ` which only sees exported vars.
4. **Including micro-caps** — stick to names retail investors know. If you've never heard of it, skip it.
5. **Wrong date math on macOS** — macOS `date` uses `-v+5d` not `--date=+5days`. Use: `$(date -v+5d +%Y-%m-%d)`.
6. **Overloading the queue** — use `next-free-slot` for each card to spread them out throughout the week.
7. **Vague AI take** — "could move the stock" is not useful. Be specific: "margin guidance matters more than EPS beat."
8. **Not reporting failures** — if Nano Banana Pro fails for one ticker, still process the others and report the failure in Signal.
9. **Benzinga 401** — Token expires periodically. Don't waste time debugging; go straight to Serper fallback. The Serper path (EarningsWhispers + individual ticker searches) is fully sufficient.
10. **TYPEFULLY_SOCIAL_SET_ID not in .env** — The Bloom account ID is `$TYPEFULLY_SOCIAL_SET_ID`. Discover with `social-sets:list` if unsure, but it's stable.
11. **Already-reported companies** — Some mega-caps report Sunday evening (e.g., PLTR on May 4) or Monday after close. When searching for each ticker, check snippets for past-tense language like "reported", "beat", "missed", "revenue was", "EPS of $X" to detect companies that already reported. In the May 2026 run, PLTR, AMD, SHOP, and RIVN had all reported by the time the cron executed on Wednesday — only DIS, UBER, NVO, APP, and COIN were still upcoming.
12. **Mid-week re-runs** — The cron is scheduled for Monday 8am ET, but may fire late or be re-triggered mid-week. If running on a non-Monday, use the actual current date to determine which companies have already reported vs. are still upcoming. Tweet text should reference the actual reporting day ("reports tomorrow", "reports Thursday") relative to the current date, not relative to Monday.
13. **Serper script path** — The correct path is `~/.hermes/skills/ai-tools/web-search/scripts/serper.sh` (not `skills/serper-search/`). The web-search skill's script directory moved; always use the path from the web-search skill.
14. **Bash `$` expansion in prompts/tweets** — In generated scripts, single-quote prompt and tweet literals that contain prices or cashtags. Double quotes plus `set -u` caused `/tmp/gen-earnings-cards.sh: line 22: $4: unbound variable` because `$45.57B` was parsed as `$4`. The Typefully script has the same risk for `$JD` cashtags and estimate text; use single quotes or quoted heredocs.
