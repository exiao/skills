# Instagram Professional Dashboard Boost Flow

Browser-based ad workflow for running ads **without a Facebook ad account** — via Instagram Professional Dashboard only. Used when the Meta ad account is restricted or unavailable.

## Context

- **Account:** invest.with.bloom on Instagram
- **Login:** admin@getbloom.app (password in ads/iteration/config.json)
- **Budget per ad:** $5/day, run until paused
- **Destination:** App Store link for Bloom
- **Browser profile:** clawd

---

## Step 1 — Check Performance

1. Open browser (profile: clawd), navigate to instagram.com
2. Confirm logged in as invest.with.bloom
3. Go to: **Professional Dashboard → Ad tools → Manage ads**
4. For each running ad, capture: impressions, reach, spend, clicks, engagement rate
5. Save to `ads/iteration/[YYYY-MM-DD]_performance.md`

---

## Step 2 — Classify Ads

Only classify ads with **1,000+ impressions** (below that = insufficient data).

| Decision | Criteria |
|----------|----------|
| **KILL** | CPM > 2× median OR engagement rate < 0.5% |
| **PROMOTE** | CPM < 0.7× median AND engagement rate > 2% |
| **KEEP** | Everything else |

Save decisions to `ads/iteration/[YYYY-MM-DD]_decisions.md`.

---

## Step 3 — Kill Losers

In Ad tools → Manage ads: find the ad → pause or delete it.
Log to `ads/iteration/[YYYY-MM-DD]_kills.log`.

---

## Step 4 — Promote Winners

In Ad tools: find the ad → edit budget → increase daily spend.
Log to `ads/iteration/[YYYY-MM-DD]_promotions.log`.

---

## Step 5 — Upload New Creatives

**Always generate 6 new creatives per run**, regardless of how many were killed.

**Before generating:** read all manifests in `ads/iteration/creatives/` to build an exclusion list. Never repeat a hook + format + concept combination already used.

**Creative formats:** iOS Notes App, Reddit post, Twitter/X screenshot, meme comparison, testimonial card, dark stat card, text-over-chart, founder video caption, before/after split, news headline mockup, app store screenshot mock

**Upload flow (browser):**
1. Professional Dashboard → Ad tools → Create ad
2. Select "Run an ad that won't show on profile"
3. Upload PNG (1080×1080)
4. Add caption (the ad copy)
5. When boost dialog appears: select **"Without a Facebook ad account"**
6. Objective: Visit your website → App Store URL
7. Budget: $5/day, run until paused
8. **If payment method needed: STOP and notify Eric**

Save manifest to `ads/iteration/creatives/[YYYY-MM-DD]/manifest.md` with: filename, format, hook, primary text.

---

## Step 6 — Report

Send to signal +15202753080:
- X ads analyzed, Y killed, Z promoted, W new uploaded
- Best/worst performer (CPM + engagement)
- 6 new creative concepts — what makes each one fresh

Then send each new creative image via Signal (one at a time, with caption).

---

## Notes

- This flow predates the Marketing API integration. The account was restricted from Facebook advertising at the time, so all ads ran through Instagram's "Without a Facebook ad account" mode.
- If the account restriction is lifted, prefer the API-based flow in `skill.md` — it's faster, automatable, and supports iOS + Android ad sets separately.
- Browser automation via instagram.com can break if Instagram changes their UI. Always take a snapshot before acting.
