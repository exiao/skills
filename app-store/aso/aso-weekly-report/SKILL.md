---
name: aso-weekly-report
description: Run Bloom's unattended weekly organic ASO report using Appfigures and DataForSEO. Use when the weekly ASO cron fires, or when asked for an ASO performance report, organic app store report, App Store keyword ranking update, keyword gaps report, or weekly app store growth summary. For interactive audits use aso-audit instead.
---

# ASO Weekly Report

Automated weekly report on Bloom's organic App Store performance. Pull organic metrics from Appfigures, keyword rankings from DataForSEO, compare against the prior snapshot, save a new snapshot, then return a concise chat-ready report.

This skill is designed for unattended cron runs. Do the work directly; do not ask follow-up questions unless required credentials or app IDs are missing.

## Required environment

Load credentials from the runtime environment, usually `~/.hermes/.env` in Hermes Agent cron contexts. Do not print credential values.

Required:
- `$APPFIGURES_PAT`
- `$APPFIGURES_BLOOM_IOS_ID`
- `$BLOOM_APP_STORE_ID`
- `$DATAFORSEO_AUTH_BASE64`

Optional:
- `$APPFIGURES_BLOOM_ANDROID_ID`
- `$APPFIGURES_COMPETITOR_APP_IDS`, comma-separated Appfigures product IDs for tracked competitors
- `$ASO_COMPETITOR_APP_STORE_IDS`, comma-separated Apple app IDs for DataForSEO gap checks
- `$ASO_LOCATION_CODE`, DataForSEO location code. Default: `2840` for United States.
- `$ASO_LANGUAGE_CODE`, DataForSEO language code. Default: `en`.
- `$ASO_SNAPSHOT_DIR`, snapshot directory. Default: `$HOME/.hermes/skills/analytics/aso-weekly-report/snapshots/`.

Related skills with endpoint details:
- `appfigures-cli`
- `dataforseo-cli`
- `aso-audit`
- `keyword-research`
- `competitor-analysis`
- `Apple Search Ads` for paid search, not this organic report

## Data windows

Use complete trailing weekly windows:
- This week: last 7 complete days.
- Prior week: the 7 complete days before that.

If the APIs only support relative offsets in the current environment, use Appfigures integer offsets, not `-7d` style strings.

## Workflow

### 1. Appfigures organic metrics

Use the Appfigures API to fetch current and prior-week data for Bloom iOS, plus Android when `$APPFIGURES_BLOOM_ANDROID_ID` is set.

Base setup:
```bash
AUTH="Authorization: Bearer $APPFIGURES_PAT"
BASE="https://api.appfigures.com/v2"
PRODUCTS="$APPFIGURES_BLOOM_IOS_ID"
if [ -n "$APPFIGURES_BLOOM_ANDROID_ID" ]; then PRODUCTS="$PRODUCTS,$APPFIGURES_BLOOM_ANDROID_ID"; fi
```

Fetch:
- Sales/downloads for a complete 14-day window: `GET /reports/sales/?products=$PRODUCTS&group_by=dates&start_date=-14&end_date=-1`, then split locally into this week and prior week.
- Revenue including IAPs for the same complete 14-day window: add `include_inapps=true`.
- Subscriptions if available: `GET /reports/subscriptions`
- Current ratings: `GET /ratings?products=$APPFIGURES_BLOOM_IOS_ID`
- Category ranks for the same complete 14-day window: `GET /ranks/$APPFIGURES_BLOOM_IOS_ID/daily/-14/-1?countries=US`
- Recent 1 to 2 star reviews: `GET /reviews?products=$APPFIGURES_BLOOM_IOS_ID&stars=1,2&count=10&sort=-date`

Compute:
- Downloads, uninstalls, net installs when available.
- Revenue, trials, trial conversions, active subscriptions, churn when available.
- Week-over-week deltas for each metric with prior-week data.
- Current rating and total rating count.
- Category rank best, average, latest, and 7-day change.
- Negative review themes from new 1 to 2 star reviews only.

### 2. DataForSEO keyword rankings

Use DataForSEO Labs Apple endpoints. They are synchronous and cheaper than task endpoints for this report.

```bash
DFS_AUTH="Authorization: Basic $DATAFORSEO_AUTH_BASE64"
DFS_BASE="https://api.dataforseo.com/v3"
ASO_LOCATION_CODE="${ASO_LOCATION_CODE:-2840}"
ASO_LANGUAGE_CODE="${ASO_LANGUAGE_CODE:-en}"
```

Fetch Bloom's top App Store keywords:
```bash
curl -s -X POST "$DFS_BASE/dataforseo_labs/apple/keywords_for_app/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"app_id":"'"$BLOOM_APP_STORE_ID"'","location_code":'"$ASO_LOCATION_CODE"',"language_code":"'"$ASO_LANGUAGE_CODE"'","limit":100,"order_by":["ranked_serp_element.serp_item.rank_absolute,asc"]}]'
```

Parse `tasks[0].result[0].items`. For each item, extract:
- `keyword_data.keyword`
- `keyword_data.keyword_info.search_volume`
- `ranked_serp_element.serp_item.rank_absolute`

Track top 50 by rank in the snapshot. In the report, show only the most useful top keywords or movers.

### 3. Competitors and keyword gaps

Prefer `$ASO_COMPETITOR_APP_STORE_IDS` when set. Otherwise use DataForSEO `app_competitors/live` to discover competitors:

```bash
curl -s -X POST "$DFS_BASE/dataforseo_labs/apple/app_competitors/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"app_id":"'"$BLOOM_APP_STORE_ID"'","location_code":'"$ASO_LOCATION_CODE"',"language_code":"'"$ASO_LANGUAGE_CODE"'","limit":5}]'
```

For up to 3 competitors, fetch their `keywords_for_app/live` results with limit 50.

Gap rules:
- High priority: competitor ranks top 10, Bloom is absent or worse than 50, and the keyword is relevant to investing, stocks, finance, portfolio tracking, research, or AI investing.
- Medium priority: competitor ranks top 20, Bloom ranks 30 to 100.
- Skip irrelevant keywords, even if volume is high.
- Remember: DataForSEO volume is Google search volume used as a proxy, not exact App Store search demand.

### 4. Snapshot comparison

Snapshot directory:
```bash
SNAPSHOT_DIR="${ASO_SNAPSHOT_DIR:-$HOME/.hermes/skills/analytics/aso-weekly-report/snapshots}"
```

Filename format:
```text
YYYY-MM-DD.json
```

Snapshot structure:
```json
{
  "date": "YYYY-MM-DD",
  "period": {"start": "YYYY-MM-DD", "end": "YYYY-MM-DD"},
  "downloads_7d": 0,
  "revenue_7d": 0,
  "rating": 0,
  "ratings_count": 0,
  "category_rank": null,
  "keywords": [
    {"keyword": "ai investing app", "rank": 14, "volume": 68}
  ],
  "competitor_gaps": [
    {"keyword": "stock research", "competitor": "Example", "competitor_rank": 8, "bloom_rank": null, "volume": 54, "priority": "high"}
  ]
}
```

Compare this week to the most recent prior snapshot:
- Existing keyword: compute rank movement. Lower rank number is better.
- New keyword: mark new.
- Keyword missing from this week: mark lost if it was important last week.
- Ratings endpoint is a snapshot, so estimate new ratings by comparing rating count to the prior snapshot.

If no snapshot exists, skip rank movement and establish the baseline.

Save this week's snapshot after comparison. Keep old snapshots; do not remove files during cron runs.

### 5. Recommendations

Generate 2 to 3 specific recommendations. Use these triggers:

| Signal | Recommendation |
|---|---|
| Keyword dropped 5+ positions | Defend that keyword in metadata or supporting copy. |
| High-volume relevant gap | Add or test that keyword in the keyword field, subtitle, description, or paid ASA exploration. |
| Downloads down week-over-week | Check metadata freshness, ranking losses, category movement, and recent review themes. |
| Negative reviews cluster around one issue | Flag the issue for product or paywall/onboarding copy. |
| Keyword enters top 10 | Reinforce the term in screenshots, description, or related content. |
| Trial volume spikes but conversions lag | Watch conversion and churn before assuming quality improved. |

Do not overreact to one weird week. Call out incomplete data, attribution uncertainty, or campaign-driven spikes when the numbers suggest it.

## Output format

Return only the report. Do not call message-sending tools from cron.

Keep it under 50 lines:

```text
📱 ASO Weekly Report: [YYYY-MM-DD] to [YYYY-MM-DD]

Organic performance:
- Downloads: [N] ([delta])
- Revenue: $[N] ([delta])
- Trials/conversions/subs: [only if available]
- Rating: [X.XX]★ from [N] ratings
- Category rank: best #[N], avg #[N]
- Negative reviews: [N or theme]

Keyword rankings:
- [top 5 to 8 useful rankings or movers]

Competitor gaps:
- [keyword]: [competitor] #[rank], Bloom [rank/not top 100], volume [N]

Takeaway:
[One concise interpretation]

Recommendations:
1. [Specific action]
2. [Specific action]
3. [Specific action if warranted]

Snapshot saved: $SNAPSHOT_DIR/[YYYY-MM-DD].json
```

First run ending:
```text
Baseline established. Next week's report will include rank movement.
```

## Common mistakes

- Do not use stale skill names `dataforseo` or `appfigures`; use `dataforseo-cli` and `appfigures-cli`.
- Do not fabricate prior-week movement if the prior snapshot or API comparison is missing.
- Do not treat DataForSEO volume as exact App Store volume.
- Do not dump raw tables. This report goes to chat.
- Do not label spikes as fraud or bots without evidence. State the data and the uncertainty.
- Do not expose tokens, API keys, account IDs, or private app IDs in the report.

## Approximate DataForSEO cost

- Bloom `keywords_for_app/live`: about $0.012.
- `app_competitors/live`: about $0.011.
- Three competitor `keywords_for_app/live` calls: about $0.036.
- Appfigures via PAT: no per-request cost.

Expected weekly cost: about $0.06.

## Skill source

Recreated from prior local cron prompts and run outputs after the original runtime skill was lost during skill repository cleanup. To refresh this skill, compare future cron reports against this runbook, then update endpoint details from the `appfigures-cli` and `dataforseo-cli` skills rather than pasting private operational state into this public repository.
