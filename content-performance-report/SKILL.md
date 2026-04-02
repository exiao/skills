---
name: content-performance-report
description: Use when the cron fires at 9am ET on Mondays — pulls Typefully published posts from the last 30 days, classifies them by content pillar, pulls Appfigures download data, scores each pillar, and sends a weekly report to Signal.
---

# Content Performance Report

Every Monday morning, audits Bloom's content output across 4 pillars against targets, correlates with app download trends, and sends a scored weekly report to Signal.

---

## Tools

| Tool | Purpose |
|------|---------|
| `typefully` skill | Pull published posts from both Typefully accounts |
| `exec` (curl) | Appfigures API for iOS + Android download data |
| `message` tool | Send formatted report to Signal group |

---

## Bloom's 4 Content Pillars

| Pillar | Channels | Monthly Target |
|--------|----------|----------------|
| **Insider Trades** | Twitter + TikTok | 15–20 posts/month |
| **Build Log** | Substack + Twitter | 4–5 posts/month |
| **Market Explainers** | TikTok / Shorts / Reels | 12–16 posts/month |
| **Earnings Reactions** | Twitter + TikTok | 8–12/quarter (seasonal) |

---

## Workflow

### Step 1 — Pull Published Posts (Last 30 Days)

```bash
cd /Users/testuser/clawd/skills/typefully

# Bloom brand account
node scripts/typefully.js drafts:list 286685 --status published

# Eric's personal account
node scripts/typefully.js drafts:list 22264 --status published
```

Collect all posts with their text, publish date, and platform.

**Filter to last 30 days** — discard anything older.

### Step 2 — Classify by Pillar

For each post, classify into one pillar based on text keywords:

| Pillar | Keywords / Signals |
|--------|--------------------|
| **Insider Trades** | insider, bought, CEO buy, CFO buy, Form 4, $X worth |
| **Earnings Reactions** | earnings, EPS, revenue, beat, miss, reports [day] |
| **Market Explainers** | market, NVDA, Fed, rate, inflation, general commentary, "here's why" |
| **Build Log** | built, shipped, bloom ai, we added, new feature, just launched |

Posts that don't match any pillar: classify as "Other" (don't count toward targets).

Count posts per pillar.

### Step 3 — Pull Appfigures Download Data

```bash
AUTH="Authorization: Bearer $APPFIGURES_PAT"

# Last 7 days (iOS + Android)
curl -s "https://api.appfigures.com/v2/reports/sales/\
?products=$APPFIGURES_BLOOM_IOS_ID,$APPFIGURES_BLOOM_ANDROID_ID\
&group_by=dates\
&start_date=-7\
&end_date=0" \
-H "$AUTH"

# Last 30 days (for trend comparison)
curl -s "https://api.appfigures.com/v2/reports/sales/\
?products=$APPFIGURES_BLOOM_IOS_ID,$APPFIGURES_BLOOM_ANDROID_ID\
&group_by=dates\
&start_date=-30\
&end_date=0" \
-H "$AUTH"
```

Extract:
- Total installs last 7 days (iOS + Android combined)
- Total installs last 30 days
- Prior 7 days (days 8-14 back) for week-over-week trend

Calculate:
- Week-over-week change: `(this_week - prior_week) / prior_week * 100`

### Step 4 — Score Each Pillar

Score each pillar against its monthly target:

| Score | Meaning | Criteria |
|-------|---------|----------|
| **SCALE** | Double down | At or above target, strong |
| **KEEP** | Maintain pace | Within 80% of target |
| **ELEVATE** | Needs more effort | 50–79% of target |
| **ROTATE OUT** | Below threshold, reconsidering | <50% of target |
| **NOT STARTED** | Zero posts this month | 0 posts |

Apply judgment: if content is high-quality but volume is low, note that. If Earnings is seasonal and we're not in earnings season, note that context.

### Step 5 — Send Report to Signal

Send to `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`:

```
📊 Weekly Content Report — [Mon DD, YYYY]

• Insider Trades: [X posts] → [SCORE] (target: 15-20/mo)
• Market Explainers: [X posts] → [SCORE] (target: 12-16/mo)
• Earnings Reactions: [X posts] → [SCORE] (target: 8-12/qtr)
• Build Log: [X posts] → [SCORE] (target: 4-5/mo)

Bloom installs last 7d: [N] (iOS + Android)
Trend vs prior week: [+/-X%]

[1-2 sentences: what's driving installs, what pillar to prioritize this week]
```

---

## Delivery

- Signal group: `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`
- No files saved — report is sent directly to Signal

---

## Cron Config

- **ID:** `7858718b-37aa-493e-920d-4504d91ed5ce`
- **Schedule:** `0 9 * * 1` (9am ET, Mondays)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Counting posts outside 30-day window** — filter strictly to the last 30 days before counting.
2. **Misclassifying earnings into market explainers** — earnings reactions are about specific company results (beat/miss), not general market commentary.
3. **Ignoring seasonal context for Earnings** — if it's not earnings season (Q1/Q2/Q3/Q4 reporting weeks), explain why the count is low.
4. **Wrong Appfigures date syntax** — use `start_date=-7&end_date=0` for last 7 days. These are relative day offsets, not calendar dates.
5. **Losing sight of the "so what"** — the last 1-2 sentences are the most valuable part. Don't just list numbers; give a recommendation.
6. **Skipping prior week comparison** — always compute week-over-week; flat install numbers without trend context are less useful.
