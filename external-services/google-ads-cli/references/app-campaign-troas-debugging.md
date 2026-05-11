# App Campaign tROAS Debugging Notes

Use this when an App Campaign looks cheap on CPA but weak on ROAS, or when a daily report says to investigate tROAS/value tracking.

## Key lesson

A low CPA can be meaningless for tROAS campaigns if most counted conversions are installs with tiny default value. Split conversions by action before calling it a tracking problem.

## Checks

1. Verify the app platform before attribution assumptions:
   - `campaign.app_campaign_setting.app_id`
   - `campaign.app_campaign_setting.app_store`
   - `campaign.app_campaign_setting.bidding_strategy_goal_type`
   Do not apply iOS/CPP/SKAN undercount explanations to Android Google Play campaigns.

2. Query campaign performance over yesterday, 7d, and 30d:
   - cost
   - conversions
   - conversions_value
   - all_conversions/all_conversions_value
   - target_roas
   Conversion lag can materially change yesterday's report by the time you investigate.

3. Split by conversion action using conversion/value metrics only. Google Ads API rejects `metrics.cost_micros` with `segments.conversion_action` and `segments.conversion_action_name`.

Example query:

```sql
SELECT
  segments.conversion_action_name,
  segments.conversion_action,
  metrics.conversions,
  metrics.conversions_value,
  metrics.all_conversions,
  metrics.all_conversions_value
FROM campaign
WHERE campaign.name = 'Bloom'
  AND segments.date DURING LAST_30_DAYS
ORDER BY metrics.conversions DESC
```

4. Interpret the split:
   - Installs with default value near $0.01 drive CPA and conversion count.
   - Purchase/subscription actions drive ROAS.
   - If purchases have realistic value and are included, tracking is probably firing. The issue is conversion mix or insufficient purchase volume.

5. Compute target purchase volume:
   - Required value = spend × target_roas
   - Required purchases ≈ required value / observed value per purchase
   This grounds the recommendation better than vague "tracking may be broken" language.

## Reporting guidance

Say directly whether this is likely tracking or economics:
- Tracking issue: purchase/subscription actions missing, hidden, excluded, or zero value despite expected purchases.
- Economics issue: purchases exist with plausible value but volume is too low for target ROAS.

Avoid recommending scale from cheap installs alone on tROAS campaigns. Scale only when purchase/subscription value supports it.
