# Google Ads mutation/no-overwrite audit

Use this when Eric asks whether a Google Ads cron, agent run, or ad workflow actually changed anything.

## What to verify

1. Check the local run record first:
   - `~/.hermes/cron/jobs.json` for the job state, last run time, and whether the prompt says report-only.
   - `~/.hermes/cron/output/<job_id>/<timestamp>.md` for final output, MEDIA lines, upload CTAs, and any explicit "uploaded/mutated" claims.
2. Query Google Ads `change_event` for every affected customer ID.
3. Query assets directly for proposed new text or generated asset names.
4. Report the result plainly: whether campaigns, ads, assets, headlines, descriptions, budgets, or statuses changed.

## Important GAQL quirk

`change_event.change_date_time >= '...'` can fail with `CHANGE_DATE_RANGE_INFINITE`. Use a finite range:

```sql
SELECT
  change_event.change_date_time,
  change_event.change_resource_type,
  change_event.resource_change_operation,
  change_event.resource_name,
  change_event.changed_fields,
  change_event.client_type,
  change_event.user_email
FROM change_event
WHERE change_event.change_date_time BETWEEN '2026-05-10 17:45:00' AND '2026-05-11 03:42:00'
ORDER BY change_event.change_date_time DESC
LIMIT 500
```

For ad creative audits, print all events, or at minimum filter mentally for resource types containing `ASSET`, `AD`, `CAMPAIGN_ASSET`, `AD_GROUP_AD`, `ASSET_GROUP_ASSET`, budgets, and campaign/ad group criteria. Zero events across the window is strong evidence that no Google Ads mutation occurred.

## Asset existence checks

For proposed text assets, query exact text:

```sql
SELECT asset.id, asset.name, asset.type, asset.text_asset.text
FROM asset
WHERE asset.type = 'TEXT'
  AND asset.text_asset.text IN ('News behind every move', 'Why stocks move')
LIMIT 100
```

For generated image/video names, use separate `LIKE` queries. GAQL can reject chained `OR` in some contexts, so run one pattern at a time if needed:

```sql
SELECT asset.id, asset.name, asset.type
FROM asset
WHERE asset.name LIKE '%bloom-earnings-surprise%'
LIMIT 50
```

## Reporting pattern

Keep the final short and confidence-ranked:

- Change history for accounts X/Y during window: 0 change events.
- Proposed text assets found: 0.
- Generated image/video assets found: 0.
- Cron/output evidence: report-only, no mutate/upload confirmation.
- Conclusion: no existing headlines, descriptions, ads, image assets, budgets, or statuses were overwritten.

If change events exist, list timestamp, resource type, operation, changed fields, client type, and user email. Do not expose credentials or raw config contents.