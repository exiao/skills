# Appfigures API Reference

Base URL: `https://api.appfigures.com/v2/`

## Sales Response Fields

| Field | Type | Description |
|-------|------|-------------|
| downloads | int | Total downloads |
| net_downloads | int | Downloads minus returns |
| app_downloads | int | App-only downloads (no IAP) |
| re_downloads | int | Reinstalls/subsequent installs |
| updates | int | Total updates |
| revenue | float | Revenue after store fee (user's currency) |
| app_revenue | float | App-only revenue after store fee |
| gross_revenue | float | Revenue before store fee |
| returns | int | Total returns |
| uninstalls | int | App removals (Apple + Google only) |
| gifts | int | Times gifted |
| promos | int | Promo codes used |
| edu_downloads | int | Educational downloads |
| pre_orders | int | Pre-release orders |

## Subscriptions Response Fields

| Field | Type | Description |
|-------|------|-------------|
| all_active_subscriptions | int | Total active (incl. trials, discounted) |
| active_subscriptions | int | Paying standard price |
| active_free_trials | int | Currently in free trial |
| paying_subscriptions | int | Paying any rate (standard + discounted) |
| actual_revenue | float | Subscription revenue after store fee |
| mrr | float | Monthly recurring revenue after store fee |
| gross_mrr | float | MRR before store fee |
| gross_revenue | float | Revenue before store fee |
| activations | int | New + re-activations + conversions + tier changes |
| cancellations | int | Not renewed (by customer or tier change) |
| churn | float | Cancelled / total active (percent) |
| new_subscriptions | int | Brand new subscribers |
| new_trials | int | New trial starts |
| trial_conversions | int | Trials that became paid |
| cancelled_trials | int | Trials that didn't convert |
| reactivations | int | Re-subscribed after lapse |
| renewals | int | Auto-renewed successfully |
| first_year_subscribers | int | Active < 1 year (higher store fee, iOS/Mac only) |
| non_first_year_subscribers | int | Active > 1 year (lower store fee) |
| active_grace | int | Failed charge, being retried |
| grace_drop_off | int | Cancelled due to payment failure |
| grace_recovery | int | Recovered after payment failure |

## Reviews Query Parameters

| Param | Description |
|-------|-------------|
| q | Search text in reviews |
| products | Product IDs (comma-separated) |
| countries | ISO codes (comma-separated) |
| page | Page number (1-500) |
| count | Results per page (1-500, default 25) |
| lang | Translate to language code (e.g., `en`, `es`) |
| author | Filter by author name |
| versions | Filter by version (comma-separated) |
| stars | Filter by star rating (e.g., `1,2` for 1 and 2 star) |
| sort | Sort field: `country`, `stars`, `date` (prefix `-` for desc) |
| start | Start date (yyyy-mm-dd) |
| end | End date (yyyy-mm-dd) |

## Ratings Response

Array of snapshots:
- `product`: Appfigures product ID
- `region`: Country ISO code (or `L:en` for Google Play)
- `date`: Snapshot date
- `stars`: Array of [1★, 2★, 3★, 4★, 5★] cumulative counts

Note: Ratings are cumulative snapshots, not daily deltas.

## Ranks Route

```
GET /ranks/{product_ids}/{granularity}/{start_date}/{end_date}?countries={iso}&filter={top_n}
```

- `granularity`: `hourly` or `daily`
- `countries`: ISO codes separated by semicolons (`;`)
- `filter`: Limit to top N (1-1000, default 400)
- Response contains `dates[]` array and `data[]` with series per category/country
- Each series: `positions[]`, `deltas[]`, `category`, `country`, `product_id`

## Ranks Snapshot

```
GET /ranks/snapshots/{time}/{country}/{category}/{subcategory}?count={n}
```

- `time`: `current` or `yyyy-mm-ddTHH` (last 24h only)
- `subcategory`: `free`, `paid`, `topgrossing`

## Date Formats

- Absolute: `yyyy-mm-dd` (e.g., `2026-02-01`)
- Relative days: `-7` (7 days ago), `0` (today)
- Relative weeks: `-2w`, `w` (last week)
- Relative months: `-1m`, `-6m`
- Relative years: `-1y`

## Group By Options

### Sales
`products`, `countries`, `dates`, `stores`, `device`

### Subscriptions
`product`, `country`, `date`, `store`

## Format Options

Add `&format=csv` for CSV output (sales, ranks routes). Default is JSON.
