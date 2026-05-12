# Feedback Loop

The daily + monthly cadence that turns posting into a system.

## Daily: Post-Level Analysis

After every post (24–48h):

1. Pull per-post analytics (views, likes, comments, shares) from platform APIs or dashboard
2. If RevenueCat is connected, pull conversions in the same 24–72h window
3. Tag in `hook-performance.json`:

```json
{
  "postId": "platform-native-id",
  "date": "2026-02-26",
  "hook": "The hook text exactly as posted",
  "hookCategory": "person-conflict-ai",
  "platform": "tiktok",
  "views": 45000,
  "likes": 1200,
  "comments": 45,
  "shares": 89,
  "conversions": 4,
  "cta": "Download Bloom — link in bio"
}
```

### Decision Rules

| Views | Action |
|-------|--------|
| 50K+ | DOUBLE DOWN — make 3 variations immediately |
| 10K–50K | Good — keep in rotation, test small tweaks |
| 1K–10K | Okay — try 1 more variation before dropping |
| <1K (twice) | DROP — radically different approach needed |

### Two-Axis Diagnostic

| Views | Conversions | Diagnosis | Fix |
|-------|-------------|-----------|-----|
| High | High | 🟢 Scale it | Variations, more frequency, cross-post |
| High | Low | 🟡 CTA broken | Hook works — fix CTA, landing page, caption |
| Low | High | 🟡 Hook broken | Content converts — fix hook/thumbnail |
| Low | Low | 🔴 Full reset | Different format, niche, or audience angle |
| High | Low downloads | 🔴 App issue | Not a content problem — fix onboarding/paywall |

### Hook Variation When Iterating

- **Same hook, different person:** "landlord" → "mum" → "boyfriend"
- **Same structure, different subject:** bedroom → kitchen → bathroom
- **Same images, different text:** proven visuals can carry new hooks
- **Same hook, different posting time:** morning vs evening

### CTA Rotation

When views are strong but conversions are low, cycle through:
- "Download [App] — link in bio"
- "[App] is free to try — link in bio"
- "I used [App] for this — link in bio"
- "Search [App] on the App Store"
- No explicit CTA (app name visible in post only)

Track conversion rate per CTA in `hook-performance.json`.

---

## Monthly: Pillar-Level Review (Run on the 1st)

Group all posts by content pillar. Score each:

| Score | Criteria | Action |
|-------|----------|--------|
| SCALE | High views + high conversions | Increase posting frequency |
| KEEP | Decent and stable | Maintain cadence |
| ELEVATE | Underperforming but concept is sound | Change one lever: hook, format, or value density |
| ROTATE OUT | Underperforming 2+ months after elevation | Retire to bench |

### Monthly Report Format

Save to `tiktok-marketing/reports/monthly/YYYY-MM.md`:

```
## Pillar Performance — [Month Year]

| Pillar | Posts | Views | Saves | Conversions | Verdict |
|--------|-------|-------|-------|-------------|---------|
| [name] | X     | X     | X     | X           | SCALE/KEEP/ELEVATE/ROTATE |

### Changes for next month:
- SCALE: [pillar] — increasing from 3x/week to 5x/week
- ELEVATE: [pillar] — testing new hook style (listicle → POV)
- ROTATE OUT: [pillar] — replacing with [new pillar idea]
- NEW: [pillar] — launching with 5–10 posts to establish baseline
```

### Pillar Lifecycle

- Months 1–2: Launch with 5–10 posts, establish baseline
- Months 3–4: Evaluate. Scale winners, elevate laggards
- Months 5–6: Rotate out persistent underperformers
- Month 7+: Steady state — 2–3 proven pillars + 1–2 experimental slots

### The Bench

Rotated-out pillars aren't dead. Algorithms change, trends shift. Store in `tiktok-marketing/pillar-bench.json` and revisit quarterly.

---

## Automated Daily Cron

Set up a cron to run every morning before the first post (7:00 AM user's timezone):

```
Task: Pull last 3 days of posts → fetch analytics → cross-reference conversions → apply diagnostic → suggest hooks → message user
Output: tiktok-marketing/reports/YYYY-MM-DD.md
```

Why 3 days? TikTok posts peak at 24–48h. Conversion attribution takes up to 72h. The 3-day window captures the full lifecycle.

The daily report:
1. Fetches posts from last 3 days via platform APIs
2. Pulls per-post analytics
3. Cross-references RevenueCat conversion events (if connected)
4. Applies the diagnostic framework per post
5. Suggests 3–5 new hooks based on winning patterns
6. Updates `hook-performance.json`
7. Messages the user with summary + hook suggestions for today
