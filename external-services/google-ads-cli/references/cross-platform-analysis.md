# Cross-Platform Ad Spend Analysis

How to correlate RevenueCat subscriber data with Google Ads and Meta Ads spend to evaluate channel ROI.

## Data sources

| Source | What it provides | What it doesn't |
|--------|-----------------|-----------------|
| RevenueCat API | MRR, revenue (28d), active trials/subs, new customers (28d), transaction count | Country-level revenue, time-series charts, customer enumeration |
| RevenueCat CSV export | New customers by country by day | Revenue by country (dashboard only) |
| Google Ads API | Spend, conversions, conversion value by campaign, asset performance | Which conversions became paying subscribers |
| Meta Ads API | Spend, impressions, CPM, CTR | Often zero installs/purchases (attribution broken post-ATT) |

## Analysis workflow

### 1. Pull overview metrics from RevenueCat
```bash
mcporter call revenuecat.get-overview-metrics project_id=$REVENUECAT_PROJECT_ID currency=USD --output json
```
Key numbers: MRR, revenue (28d), active trials, active subs, new customers (28d).

### 2. Pull ad spend from Google Ads
Query both accounts for LAST_30_DAYS campaign performance including cost_micros, conversions, conversions_value.

### 3. Pull ad spend from Meta
Use the meta-ads-cli daily cron output or query directly via Marketing API.

### 4. Compute blended ROAS
```
Blended ROAS = RC Revenue (28d) / Total Ad Spend (28d)
MRR-to-Spend Ratio = MRR / Monthly Ad Spend
```

### 5. Estimate US vs International contribution
If you have an RC New Customers CSV with country breakdown:
- Compare US daily customer count (typically stable) vs total
- If US is flat and total spiked, the spike is organic/international
- Google Ads conversions that far exceed US customer count = international installs

## Key patterns discovered

### International spike analysis (Apr-May 2026)
- App Store featuring or viral events can drive 10-30K daily new customers
- These spikes are typically 95%+ international (Philippines, India, SA, Nigeria)
- US acquisition stays flat at its ad-driven baseline (~40/day for Bloom)
- Classic decay curve: spike day -> 50% next day -> settles at 3x baseline in ~5 days
- International users convert to paid at much lower rates (estimated <1% vs ~10-15% US)

### Meta attribution blindspot
- Post-ATT, Meta frequently reports 0 installs and 0 purchases even with active campaigns
- ROAS shows as "unavailable" when Meta can't attribute conversions
- Don't increase Meta budget until attribution is verifiable
- At $4-5/day spend, Meta is too small to optimize meaningfully anyway

### Google Ads international efficiency trap
- Google Play campaigns (especially the 625 account) show very low CPA ($0.11)
- This is real but misleading: most conversions are cheap international installs
- tROAS campaigns may show actual ROAS well below target because international users don't convert to paid
- Don't mistake cheap installs for good ROAS unless revenue data confirms it

## Decision framework

| Signal | Action |
|--------|--------|
| Blended ROAS > 3x and MRR growing | Ads are working, maintain spend |
| Blended ROAS > 3x but MRR flat | International installs inflating conversion count, not revenue |
| US customers flat despite spend increase | Budget ceiling reached for US, diminishing returns |
| Meta showing 0 installs | Fix attribution before scaling Meta |
| International spike with low conversion | Don't chase with ad dollars, let organic run free |
| Need country-level revenue confirmation | Must use RC Dashboard, API can't provide this |
