# Instagram Professional Dashboard Boost Flow

Browser-based workflow for boosting Instagram posts when the full Meta ad account flow is restricted or unavailable.

## Context Variables

- Account: `$INSTAGRAM_HANDLE`
- Login: credentials stored locally by the user's browser profile
- Budget per ad: `$DAILY_BUDGET`
- Destination: `$DESTINATION_URL`
- Browser profile: `$BROWSER_PROFILE`

## Step 1: Check Performance

1. Open Instagram in the configured browser profile.
2. Confirm logged in as `$INSTAGRAM_HANDLE`.
3. Go to Professional Dashboard → Ad tools → Manage ads.
4. For each running ad, capture: impressions, reach, spend, clicks, and engagement rate.
5. Save to `ads/iteration/[YYYY-MM-DD]_performance.md`.

## Step 2: Classify Ads

Only classify ads with enough impressions for the account's baseline.

| Decision | Criteria |
|----------|----------|
| KILL | CPM above 2x median or engagement rate below baseline |
| PROMOTE | CPM below 0.7x median and engagement rate above baseline |
| KEEP | Everything else |

Save decisions to `ads/iteration/[YYYY-MM-DD]_decisions.md`.

## Step 3: Pause Losers

In Ad tools → Manage ads: find the ad → pause it.
Log to `ads/iteration/[YYYY-MM-DD]_kills.log`.

## Step 4: Promote Winners

In Ad tools: find the ad → edit budget → increase daily spend.
Log to `ads/iteration/[YYYY-MM-DD]_promotions.log`.

## Step 5: Upload New Creatives

Before generating, read existing manifests in `ads/iteration/creatives/` to build an exclusion list. Do not repeat a hook + format + concept combination already used.

Useful creative formats:
- Notes app
- Reddit-style post
- X/Twitter screenshot style
- Meme comparison
- Testimonial card
- Stat card
- Text over chart
- Founder video caption
- Before/after split
- App screenshot mock

Upload flow:
1. Professional Dashboard → Ad tools → Create ad.
2. Select an unpublished or boosted ad option if available.
3. Upload creative.
4. Add caption and CTA.
5. Select the no-Facebook-ad-account path only if that is the intended fallback.
6. Set objective and destination URL.
7. Set budget and duration.
8. If payment method or account verification is needed, stop and ask the account owner.

Save manifest with: filename, format, hook, primary text, headline, CTA, destination URL, and notes.

## Step 6: Report

Report:
- Ads analyzed
- Ads paused
- Ads promoted
- New creative uploaded
- Best and worst performer
- New creative concepts and why each is fresh

## Safety

- Do not launch or increase spend without explicit approval.
- Do not store credentials in the repo.
- Do not automate payment or account-verification steps.
