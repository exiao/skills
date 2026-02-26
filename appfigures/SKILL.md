---
name: appfigures
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
- `281045205499` — Bloom: AI for Investing (iOS)
- `281090333286` — Bloom: AI for Investing (Google Play)

**Bible Genius (own apps):**
- `337976251547` — Bible Genius (iOS)
- `337932807605` — Bible Genius (Google Play)

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
curl -s "https://api.appfigures.com/v2/reports/sales/?products=281045205499&group_by=dates&start_date=-7&end_date=0" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Current subscription metrics (Bloom, all platforms):**
```bash
curl -s "https://api.appfigures.com/v2/reports/subscriptions?products=281045205499,281090333286&include_inapps=true&start_date=-30&end_date=0" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Recent 1-star reviews:**
```bash
curl -s "https://api.appfigures.com/v2/reviews?products=281045205499&stars=1&count=20&sort=-date" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Monthly revenue trend (Bloom, last 6 months):**
```bash
curl -s "https://api.appfigures.com/v2/reports/sales/?products=281045205499,281090333286&group_by=dates&granularity=monthly&start_date=-6m&end_date=0&include_inapps=true" \
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

---

## App Store Optimization (ASO)

Use Appfigures data combined with these frameworks to optimize Bloom's store listings.

### Keyword Strategy

**Scoring formula for keyword prioritization:**

| Factor | Weight | High Score |
|--------|--------|------------|
| Relevance | 35% | Describes core app function |
| Volume | 25% | 10,000+ monthly searches |
| Competition | 25% | Top 10 apps have <4.5 avg rating |
| Conversion intent | 15% | Transactional ("best X app") |

**Platform character limits:**

| Field | iOS | Android |
|-------|-----|---------|
| Title | 30 chars | 50 chars |
| Subtitle | 30 chars | N/A |
| Keywords | 100 chars | N/A |
| Short Description | N/A | 80 chars |
| Promotional Text | 170 chars (editable without update) | N/A |
| Full Description | 4,000 chars | 4,000 chars |
| What's New | 4,000 chars | 500 chars |

**iOS keyword field tricks:**
- No spaces after commas (saves chars)
- No plurals (Apple indexes both forms)
- Don't repeat words already in title/subtitle
- Don't include your app name or category name
- Prioritize by keyword score

**Track keyword rankings via Appfigures:**
```bash
curl -s "https://api.appfigures.com/v2/ranks/281045205499/daily/-30/0?countries=US" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

### Metadata Optimization

**Title formula:** `[Brand] - [Primary Keyword] [Secondary Keyword]`
- Example: `Bloom - AI Stock Research` (24 chars, fits iOS)

**Description structure (target 2-3% primary keyword density):**
1. **Hook** (50-100 words): Address pain point, state value prop, primary keyword
2. **Features** (100-150 words): Top 5 features as bullets with benefits, secondary keywords
3. **Social proof** (50-75 words): Download count, rating, press mentions
4. **CTA** (25-50 words): Clear next step, reassurance (free trial, etc.)

**Screenshot captions:** Lead with benefits, not features
- Bad: "AI Chat Feature"
- Good: "Ask Any Stock Question, Get Instant Analysis"

### Competitor Analysis

**Pull competitor reviews to find positioning gaps:**
```bash
# Seeking Alpha 1-2 star reviews (find their weaknesses)
curl -s "https://api.appfigures.com/v2/reviews?products=212878126&stars=1,2&count=50&sort=-date" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Compare ratings over time:**
```bash
curl -s "https://api.appfigures.com/v2/ratings?products=281045205499,212878126,40417581583&start_date=-3m&end_date=0" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

**Competitor keyword gap analysis:**
1. Extract keywords from competitor titles, subtitles, first 100 words of descriptions
2. Map which keywords each competitor targets
3. Find keywords with <40% competitor coverage but decent volume
4. Look for long-tail opportunities competitors miss

### A/B Testing (Apple Product Page Optimization)

**Prioritize by conversion impact:**

| Element | Potential Lift | Effort |
|---------|---------------|--------|
| Screenshot 1 | 15-35% | Medium |
| App Icon | 10-25% | Medium |
| Title | 5-15% | Low |
| Short Description | 5-10% | Low |
| App Preview Video | 10-20% | High |

**Minimum sample sizes (per variant, 95% confidence, 5% MDE):**

| Baseline CVR | Impressions Needed |
|--------------|-------------------|
| 1% | 31,000 |
| 2% | 15,500 |
| 5% | 6,200 |
| 10% | 3,100 |

Run tests for at least 7 days. Single variable per test.

### Review Mining for ASO

**Use review themes to inform keyword and messaging strategy:**
```bash
# Bloom positive reviews (what do users love?)
curl -s "https://api.appfigures.com/v2/reviews?products=281045205499&stars=4,5&count=100&sort=-date" \
  -H "Authorization: Bearer $APPFIGURES_PAT"
```

Look for:
- Words users repeat (these are natural keywords)
- Features users highlight (prioritize in screenshots)
- Emotional language (use in description hook)
- Complaints that reveal unmet needs (positioning opportunities)

### Platform Behavior Notes

- iOS: Keyword changes require a new app submission
- iOS: Promotional text is editable without an update (good for testing messaging)
- Android: Metadata changes index in 1-2 hours (faster iteration)
- Android: No keyword field; full description is the keyword source
- Both platforms change algorithms without notice
