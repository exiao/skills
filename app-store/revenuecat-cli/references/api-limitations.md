# RevenueCat API v2 Limitations

Discovered 2026-05-11 while trying to analyze revenue by country for an international user spike.

## Missing endpoints (all return 404)

- `/v2/projects/{id}/transactions` — no bulk transaction listing
- `/v2/projects/{id}/charts` — no chart data via API
- No country/region grouping on any metric endpoint

## What IS available via API

- Overview metrics: MRR, revenue (28d), active trials, active subs, new customers, active users, transaction count
- Per-customer: subscriptions, purchases, attributes
- Catalog: products, entitlements, offerings, packages
- Webhooks

## What requires the dashboard

- **Revenue by country** — Charts > Revenue > Group by Country
- **Cohort analysis** — Charts > Cohort
- **Revenue trends over time** — Charts > Revenue (daily/weekly/monthly)
- **Trial conversion by cohort** — Charts > Trial Conversion
- Any chart with date range + grouping dimensions

## When this matters

When correlating ad spend with revenue, you often need country-level revenue data. Common scenario:
- App Store featuring or viral spike drives 10-30K international users
- RC overview shows new customers surged but MRR didn't proportionally increase
- To confirm international users aren't converting to paid, you need revenue-by-country
- API can't answer this — must use dashboard or ask the user to export

## Workaround for country-level analysis

If dashboard access isn't available:
1. Use the New Customers CSV from RC (has country breakdown for installs)
2. Cross-reference with Google Ads conversion value data (has revenue attribution per campaign)
3. Compare US customer count vs total to estimate international conversion gap
4. If US customers are ~40/day and MRR is growing proportionally to US acquisition (not total), international users likely aren't paying
