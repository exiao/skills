---
name: appfigures-cli
preloaded: true
description: Use when querying Appfigures for app store analytics (downloads, revenue, reviews, rankings).
---

# Appfigures

Pull app store analytics via the Appfigures REST API.

## Authentication

All requests use Bearer token auth:
```
curl -s "https://api.appfigures.com/v2/{route}" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

## Product IDs

**Bloom (own apps):**
- `$APPFIGURES_BLOOM_IOS_ID` — Bloom: AI for Investing (iOS)
- `$APPFIGURES_BLOOM_ANDROID_ID` — Bloom: AI for Investing (Google Play)

**Bible Genius (own apps):**
- `$APPFIGURES_BG_IOS_ID` — Bible Genius (iOS)
- `$APPFIGURES_BG_ANDROID_ID` — Bible Genius (Google Play)

**Competitors (tracked):**
- `212878126` — Seeking Alpha (iOS)
- `40417581583` — Robinhood (iOS)
- `41519036492` — Robinhood (Google Play)
- `5957199` — Yahoo Finance (iOS)

Use `products={id}` or `products={id1},{id2}` to filter. For Bloom with all IAPs, add `&include_inapps=true`.

## Core Routes

### Sales (downloads, revenue)
```
GET /reports/sales/?start_date={date}&end_date={date}&group_by={pivots}&products={ids}&granularity={daily|weekly|monthly}
```
- `group_by`: products, countries, dates, stores (comma-separated)
- Key fields: `downloads`, `revenue`, `gross_revenue`, `net_downloads`, `uninstalls`
- Date format: `yyyy-mm-dd` or relative (`-7` = 7 days ago, `-1m` = 1 month ago)

### Subscriptions (MRR, churn, trials)
```
GET /reports/subscriptions?start_date={date}&end_date={date}&group_by={pivots}&products={ids}&include_inapps=true
```
- `group_by`: product, country, date, store
- Key fields: `active_subscriptions`, `mrr`, `churn`, `new_trials`, `trial_conversions`, `cancellations`, `actual_revenue`, `paying_subscriptions`
- For Bloom subs, use the app product ID + `include_inapps=true`

### Reviews
```
GET /reviews?products={ids}&count={1-500}&sort=-date&stars={1,2,3,4,5}&lang={iso}
```
- Paginated: `page=N`, check `total` and `pages` in response
- Add `lang=en` to auto-translate non-English reviews
- Fields: `author`, `title`, `review`, `stars`, `date`, `version`, `iso`

### Ratings
```
GET /ratings?products={ids}&countries={iso}&start_date={date}&end_date={date}
```
- Returns snapshot array with `stars: [1star, 2star, 3star, 4star, 5star]` counts
- Default country: US

### Rankings
```
GET /ranks/{product_ids}/{granularity}/{start_date}/{end_date}?countries={iso}
```
- Granularity: `daily` or `hourly`
- Returns positions and deltas per category/country

### Products
```
GET /products/mine
```
- List all tracked products with metadata

## Date Shortcuts

| Shortcut | Meaning |
|----------|---------|
| `-7` | 7 days ago |
| `-1m` | 1 month ago |
| `-1w` | 1 week ago |
| `-1y` | 1 year ago |
| `0` | today |

## Common Queries

**Last 7 days downloads by date (Bloom iOS):**
```bash
curl -s "https://api.appfigures.com/v2/reports/sales/?products=$APPFIGURES_BLOOM_IOS_ID&group_by=dates&start_date=-7&end_date=0" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Current subscription metrics (Bloom, all platforms):**
```bash
curl -s "https://api.appfigures.com/v2/reports/subscriptions?products=$APPFIGURES_BLOOM_IOS_ID,$APPFIGURES_BLOOM_ANDROID_ID&include_inapps=true&start_date=-30&end_date=0" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Recent 1-star reviews:**
```bash
curl -s "https://api.appfigures.com/v2/reviews?products=$APPFIGURES_BLOOM_IOS_ID&stars=1&count=20&sort=-date" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Monthly revenue trend (Bloom, last 6 months):**
```bash
curl -s "https://api.appfigures.com/v2/reports/sales/?products=$APPFIGURES_BLOOM_IOS_ID,$APPFIGURES_BLOOM_ANDROID_ID&group_by=dates&granularity=monthly&start_date=-6m&end_date=0&include_inapps=true" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

## Output Formatting

- Default output is JSON. Add `&format=csv` for CSV (sales, ranks routes).
- Parse with `python3 -m json.tool` or `jq` for readable output.
- For Signal/chat output, summarize key metrics in bullet points.

## Rate Limits

Each account has a monthly API call limit. Avoid unnecessary repeated calls. Cache results when running multiple analyses in a single session.

## Detailed API Reference

For field definitions and advanced query options, see [references/api-routes.md](references/api-routes.md).
