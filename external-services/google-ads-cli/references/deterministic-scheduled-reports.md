# Deterministic scheduled Google Ads reports

Use this when a recurring Google Ads cron report needs reliable numbers. The May 2026 daily report exposed a failure mode: the agent queried API data, then an LLM formatted dates, recomputed ratios, selected top assets, and inferred attribution context. That produced wrong year, stale ROAS, wrong iOS/CPP explanation for an Android campaign, and a top asset chosen by CTR/conversions instead of value/ROAS.

## Failure mode

Scheduled reports are especially prone to subtle hallucinations because they combine API querying, arithmetic, interpretation, and concise writing. Do not let the model invent or recompute critical metrics in prose after querying raw rows.

Observed mistakes:
- Date formatted as 2025 even though the cron run was 2026.
- ROAS reported as 1.68x while current API conversion lag had updated it to 2.01x.
- Attribution explanation referenced iOS CPP undercounting for an Android Google Play App Campaign.
- "Top asset" was selected by conversion count/CTR, but the campaign used tROAS. Asset ranking should use conversion value and ROAS.

## Preferred fix

For recurring reports, use a deterministic script and have cron deliver stdout as-is.

1. Query Google Ads API directly from Python with `GoogleAdsClient.load_from_storage(path="~/.google-ads.yaml")`.
2. Compute every ratio in code: CPA, ROAS, spend pacing, target comparisons.
3. Include app context from `campaign.app_campaign_setting.app_id`, `app_store`, and `bidding_strategy_goal_type` so attribution explanations match the actual app/store.
4. Segment conversion mix by `segments.conversion_action_name` using only compatible metrics. Do not include `metrics.cost_micros` in that segmented query because Google Ads rejects cost with conversion-action segments.
5. Rank assets by objective:
   - tROAS campaigns: conversion value, ROAS, and enough spend/impressions.
   - tCPA campaigns: CPA/conversions, with spend and volume floors.
6. In the cron job, set `script` to the deterministic report script and `no_agent=true`; prompt should say to deliver stdout as-is.

## GAQL snippets

Campaign context and metrics:

```sql
SELECT campaign.id, campaign.name, campaign.status,
       campaign_budget.amount_micros,
       campaign.bidding_strategy_type,
       campaign.target_roas.target_roas,
       campaign.maximize_conversion_value.target_roas,
       campaign.target_cpa.target_cpa_micros,
       campaign.maximize_conversions.target_cpa_micros,
       campaign.app_campaign_setting.app_id,
       campaign.app_campaign_setting.app_store,
       campaign.app_campaign_setting.bidding_strategy_goal_type,
       metrics.cost_micros, metrics.conversions, metrics.conversions_value,
       metrics.all_conversions, metrics.all_conversions_value,
       metrics.clicks, metrics.impressions
FROM campaign
WHERE campaign.status != 'REMOVED'
  AND segments.date DURING LAST_30_DAYS
ORDER BY metrics.cost_micros DESC
```

Conversion mix. Note no cost field:

```sql
SELECT segments.conversion_action_name,
       metrics.conversions, metrics.conversions_value,
       metrics.all_conversions, metrics.all_conversions_value
FROM campaign
WHERE campaign.name = 'Bloom'
  AND segments.date DURING LAST_30_DAYS
ORDER BY metrics.conversions DESC
```

App Campaign asset performance:

```sql
SELECT asset.id, asset.type, asset.text_asset.text, asset.name,
       asset.image_asset.full_size.url,
       ad_group_ad_asset_view.field_type,
       metrics.impressions, metrics.clicks, metrics.cost_micros,
       metrics.conversions, metrics.conversions_value
FROM ad_group_ad_asset_view
WHERE campaign.status = 'ENABLED'
  AND segments.date DURING LAST_30_DAYS
  AND metrics.impressions > 0
ORDER BY metrics.conversions_value DESC
LIMIT 100
```

## Cron update pattern

Use the cron tool to replace agent-written scheduled reports with script-driven delivery:

```python
cronjob(
    action="update",
    job_id="<job-id>",
    script="google_ads_daily_report.py",
    no_agent=True,
    deliver="signal:Google Ads Manager",
    schedule="30 4 * * *",
    prompt="Run the deterministic Google Ads daily report script. Deliver stdout as-is. The script performs all Google Ads API queries and math directly, with no LLM-derived date, ratios, attribution explanations, or recommendations."
)
```

## Double-down workflow for winning assets

When the user says to "double down" on a winning Google Ads asset:

1. Fetch the asset by ID and inspect its full-size URL.
2. Use vision to describe the creative pattern precisely.
3. Update the weekly creative job or generate variants that preserve the winning mechanism, not just the broad category.
4. Do not upload assets automatically. Generate/report first, then wait for explicit upload confirmation.

Example learning: a winning Bloom asset was not a phone mockup. It was a minimalist chart/callout graphic: white background, thick green line, orange donut event marker, and a small financial-news tooltip. The winning mechanism was news-to-price-move causality, so variants should explore earnings surprise, analyst upgrade, guidance raise, or market-moving news rather than generic app UI.