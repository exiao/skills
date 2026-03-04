---
name: meta-ads-iteration
description: Use when the cron fires at 4am ET daily — checks Instagram ad performance via browser, kills losers, promotes winners, generates 6 fresh creatives via Nano Banana Pro, uploads them as new Instagram ads, and reports to Signal.
---

# Meta Ads Iteration

Daily 4am routine: audit running Instagram ads for performance, kill underperformers, boost winners, generate 6 brand-new creative concepts (never repeating a used hook/format combo), upload them as new $5/day ads, and report to Signal with all new creatives.

---

## Tools

| Tool | Purpose |
|------|---------|
| `browser` (profile: clawd) | Instagram Professional Dashboard — view/manage/create ads |
| `trend-research` skill | Find what investing/finance content is trending today |
| `web-search` skill | Serper for trending finance content |
| `nano-banana-pro` skill | Generate 1080×1080 Instagram ad creatives |
| `message` tool | Report + send creatives to Signal group |

---

## Key Context

- **Eric's personal Facebook** is restricted from advertising — do NOT use it
- **All ads run via Instagram boost** on `invest.with.bloom` account
- **Mode:** "Without a Facebook ad account"
- **Login:** admin@getbloom.app
- **No API available** — everything via browser automation

---

## Workflow

### Step 1 — Check Performance

1. Open browser (profile: clawd): `https://www.instagram.com`
2. Confirm logged in as `invest.with.bloom` (check profile icon)
3. Navigate: **Professional Dashboard → Ad tools → Manage ads**
4. For each running ad, screenshot and capture:
   - Impressions
   - Reach
   - Engagement rate (%)
   - Clicks / link clicks
   - Spend to date
   - CPM (calculate if not shown: spend / impressions × 1000)

5. Save performance data to `ads/iteration/$(date +%Y-%m-%d)_performance.md`

### Step 2 — Classify Ads

Only classify ads with **1,000+ impressions** (insufficient data below this).

Calculate median CPM across all ads (with 1000+ impressions).

| Decision | Criteria |
|----------|----------|
| **KILL** | CPM > 2× median CPM, OR engagement rate < 0.5% |
| **PROMOTE** | CPM < 0.7× median CPM AND engagement rate > 2% |
| **KEEP** | Everything else |

Save decisions to `ads/iteration/$(date +%Y-%m-%d)_decisions.md`.

### Step 3 — Kill Losers

For each KILL ad:
1. In Ad tools → Manage ads: find the ad → pause or delete it (prefer pause to preserve data)
2. Log to `ads/iteration/$(date +%Y-%m-%d)_kills.log`:
   ```
   [timestamp] KILLED: [ad title/id] | CPM: $X | Engagement: X% | Reason: [criteria triggered]
   ```

### Step 4 — Promote Winners

For each PROMOTE ad:
1. In Ad tools: find the ad → edit → increase daily budget by $2-5/day
2. Log to `ads/iteration/$(date +%Y-%m-%d)_promotions.log`:
   ```
   [timestamp] PROMOTED: [ad title/id] | CPM: $X | Engagement: X% | Budget: $old → $new
   ```

### Step 5 — Generate 6 New Creatives

**Always generate exactly 6 new creatives per run, regardless of how many were killed.**

#### 5a — Build Exclusion List

Before generating anything, audit:
- All files in `ads/iteration/creatives/` (manifest.md files)
- All `ads/iteration/*_report.md` files

Build a list of used combos: `hook_type + format + concept`. No combo may be repeated.

#### 5b — Research Trending Content

Use trend-research skill + web-search:
- Query: "investing finance content trending [today's date]"
- Look for: viral formats on TikTok/Instagram, hot tickers, news-driven hooks

#### 5c — Pick 6 Novel Concepts

Requirements:
- All 6 hooks must differ from the exclusion list
- At least 2 must come from fresh trend research
- At least 1 must use a format not previously tested

**Available formats to cycle through:**
- iOS Notes App screenshot
- Reddit post mockup
- Twitter/X screenshot
- Meme comparison (before/after)
- Testimonial card
- Dark stat card (big number, minimal text)
- Text-over-chart
- Founder video caption card
- News headline mockup
- App Store screenshot mock
- Bold typographic (single statement, large font)
- Phone mockup (app screen)

#### 5d — Generate Each Creative

Resolve GEMINI_API_KEY first:
```bash
GEMINI_API_KEY=$(python3 -c "import json; d=json.load(open('/Users/testuser/.clawdbot/clawdbot.json')); print(d.get('skills',{}).get('entries',{}).get('nano-banana-pro',{}).get('apiKey','') or d['env']['vars'].get('GEMINI_API_KEY',''))" 2>/dev/null)
export GEMINI_API_KEY
```

Generate via Nano Banana Pro:
```bash
uv run /opt/homebrew/lib/node_modules/clawdbot/skills/nano-banana-pro/scripts/generate_image.py
```

**Design requirements:**
- 1080×1080 pixels
- Instagram-native: bright, high-contrast, thumb-stopping
- Bloom brand colors: `#F5A623` amber, `#0f172a` navy
- Variety across the 6: don't use the same layout twice
- Each must have a strong hook visible in the first 0.5 seconds of scrolling

**Output:** `ads/iteration/creatives/$(date +%Y-%m-%d)/creative-[1-6].png`

#### 5e — Save Manifest

Write `ads/iteration/creatives/$(date +%Y-%m-%d)/manifest.md`:
```markdown
# Creatives — [date]

| File | Format | Hook | Primary Text | Concept |
|------|--------|------|-------------|---------|
| creative-1.png | [format] | [hook] | [ad copy] | [concept desc] |
...
```

### Step 6 — Upload New Ads (Browser)

For each of the 6 creatives:
1. Professional Dashboard → Ad tools → **Create ad**
2. Select: **"Run an ad that won't show on profile"**
3. Upload the PNG (1080×1080)
4. Add the ad copy (hook text)
5. When boost dialog appears: select **"Without a Facebook ad account"**
6. Objective: **Visit your website**
7. URL: `https://apps.apple.com/app/bloom-investing/id1590519285`
8. Budget: **$5/day**, run until paused
9. Submit

⚠️ **If at any point a payment method is required: STOP immediately. Do not enter any payment info. Notify Eric in Signal.**

### Step 7 — Report to Signal

Send to `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`:

```
🎯 Meta Ads Daily Run — [date]

X ads analyzed | Y killed | Z promoted | W new ads uploaded

Best performer: [ad title] — CPM $X, X% engagement
Worst performer: [ad title] — CPM $X, X% engagement

6 new concepts:
1. [format] — [hook description]
2. ...
6. ...
```

Then send each of the 6 new creative images **one at a time** with a caption describing the concept.

---

## Delivery

- Signal group: `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`
- Performance log: `ads/iteration/[date]_performance.md`
- Kills log: `ads/iteration/[date]_kills.log`
- Promotions log: `ads/iteration/[date]_promotions.log`
- Creatives: `ads/iteration/creatives/[date]/creative-[1-6].png`
- Manifest: `ads/iteration/creatives/[date]/manifest.md`

---

## Cron Config

- **ID:** `f0c3f833-36d6-4781-b2ff-e5ab8e4129a4`
- **Schedule:** `0 4 * * *` (4am ET, daily)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Using Eric's personal Facebook** — it's restricted. Always use invest.with.bloom Instagram boost only.
2. **Repeating a hook/format/concept combo** — always audit the exclusion list before generating. Repetition = wasted $5/day.
3. **Entering payment info** — if Instagram asks for payment, STOP and notify Eric. Never add payment details autonomously.
4. **Generating fewer than 6 creatives** — always 6, even if nothing was killed. Fresh creatives are the priority.
5. **Missing GEMINI_API_KEY** — resolve from clawdbot.json before calling Nano Banana Pro.
6. **Not sending the creative images** — the Signal report should include all 6 images, one per message with caption.
7. **Classifying ads with <1000 impressions** — insufficient data. Mark as KEEP and don't touch.
8. **Forgetting to save the manifest** — without the manifest, future runs can't build the exclusion list properly.
