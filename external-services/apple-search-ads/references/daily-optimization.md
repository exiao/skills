# Daily ASA optimization runbook

Use this when running a recommendation-only daily optimization pass across Apple Search Ads campaigns.

## Guardrails

- Do not apply changes in the daily pass. Produce numbered recommendations with exact `./scripts/...` commands for later approval.
- If `ASA_CLIENT_ID`, `ASA_TEAM_ID`, `ASA_KEY_ID`, `ASA_ORG_ID`, or `ASA_PRIVATE_KEY_PATH` is missing, stop and report the missing variables. Do not fabricate performance data.
- Use yesterday for campaign summary and a 7-day lookback for keyword, search-term, bid, and wasted-spend decisions. One day of search terms is too noisy.
- For strict low-CPI apps, treat `$1.00` CPA as the hard guardrail. Flag anything over target as expensive.

## Known script/API quirks

These quirks were observed against Apple Search Ads API v5 in a daily cron run.

1. `./scripts/campaigns.sh list --status ENABLED` can fail with HTTP 400 `UNRECOGNIZED_PROPERTY` for `selector`. Work around it by running `./scripts/campaigns.sh list`, then filter the formatted table for `ENABLED` rows.
2. `./scripts/reports.sh keywords <cid> --sort spend` can fail with `INVALID_ORDER_BY_INPUT` because the API expects `localSpend`, not `spend`. Use `--sort localSpend`, omit `--sort`, or call `asa_api` directly with `orderBy.field="localSpend"`.
3. `optimize.sh bids` can emit `jq` division errors when install metrics are null. Continue with raw keyword reports and compute recommendations yourself from `total.localSpend.amount`, `total.taps`, and `totalInstalls` or `tapInstalls`.
4. Search term reports should use `timeZone:"ORTZ"`. General campaign and keyword reports can use UTC, but search terms are picky.
5. Search tab, Today tab, and Product Page campaigns do not contain keywords. Keyword-style wasted-spend reports may emit expected `INVALID_INPUT` errors for those supply sources. Note the errors, but do not abort the whole pass.

## Raw API fallback

When formatted scripts fail, source `scripts/asa-api.sh` and fetch raw JSON:

```bash
source scripts/asa-api.sh
body_keywords=$(jq -n --arg start "$WEEK_AGO" --arg end "$YESTERDAY" '{
  startTime:$start,
  endTime:$end,
  timeZone:"UTC",
  granularity:"DAILY",
  selector:{orderBy:[{field:"localSpend",sortOrder:"DESCENDING"}],pagination:{offset:0,limit:1000}},
  returnRowTotals:true,
  returnGrandTotals:true
}')
body_search=$(jq -n --arg start "$WEEK_AGO" --arg end "$YESTERDAY" '{
  startTime:$start,
  endTime:$end,
  timeZone:"ORTZ",
  selector:{orderBy:[{field:"localSpend",sortOrder:"DESCENDING"}],pagination:{offset:0,limit:1000}},
  returnRowTotals:true,
  returnGrandTotals:true
}')
asa_api POST "/reports/campaigns/$cid/keywords" "$body_keywords" > "raw-keywords-$cid.json"
asa_api POST "/reports/campaigns/$cid/searchterms" "$body_search" > "raw-searchterms-$cid.json"
asa_api GET "/campaigns/$cid/adgroups" > "raw-adgroups-$cid.json"
```

For deterministic approval commands, pull IDs from raw metadata:

- Keyword bid or pause: `metadata.keywordId`, `metadata.adGroupId`, `metadata.campaignId`
- Search-term promote target: use the relevant ad group ID from `/campaigns/$cid/adgroups`
- Negative: campaign ID is enough for `negatives.sh add-campaign`

## Recommendation thresholds

- Pause keyword: 7-day spend > `$2`, installs = 0, taps >= 5.
- Lower bid: CPA > `$1.50`, installs >= 2. Move partway toward target CPA, and include current bid, suggested bid, and estimated savings.
- Raise bid: CPA < `$0.60`, installs >= 3, and impression share < 80%. Cap raise at +30% of current bid.
- Add negative: search term spend > `$1.50`, installs = 0, taps >= 3.
- Promote search term: installs >= 2 and CPA < `$0.80`.

Sort visible recommendations by dollar impact. Cap the visible list at 10 and mention that additional recommendations are in the logs.

## Signal report shape

Keep the final report compact:

```text
🍎 ASA Daily Optimization - <YESTERDAY>

GRAND TOTALS
• Spend: $X.XX | Imps: N | Taps: N | Installs: N
• CPI: $X.XX | TTR: X.X% | CVR: X.X%
• vs target CPA ($1.00): UNDER/OVER by $X.XX

CAMPAIGN BREAKDOWN
| Campaign | Spend | Installs | CPI | TTR | CVR | Status |

──────────────────────────────────
📋 RECOMMENDATIONS (reply "approve N" or "approve all" to execute)

1. [ACTION] details
   Action: ./scripts/...

💰 Total projected weekly savings if all approved: $X.XX
📁 Full logs: <OUT>
```

If yesterday's total spend is under `$0.10`, warn that Apple data may still be finalizing and lean on the 7-day aggregate.