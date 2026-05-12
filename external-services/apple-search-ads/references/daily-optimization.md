# Daily ASA optimization runbook

Use this when running a recommendation-only daily optimization pass across Apple Search Ads campaigns.

## Guardrails

- Do not apply changes in the daily pass. Produce numbered recommendations with exact `./scripts/...` commands for later approval.
- If `ASA_CLIENT_ID`, `ASA_TEAM_ID`, `ASA_KEY_ID`, `ASA_ORG_ID`, or `ASA_PRIVATE_KEY_PATH` is missing, stop and report the missing variables. Do not fabricate performance data.
- Use yesterday for campaign summary and a 7-day lookback for keyword, search-term, bid, and wasted-spend decisions. One day of search terms is too noisy.
- For strict low-CPI apps, treat `$1.00` CPA as the hard guardrail. Flag anything over target as expensive.

## Known script/API quirks

These quirks were observed against Apple Search Ads API v5 in daily cron runs.

1. `./scripts/campaigns.sh list --status ENABLED` can fail with HTTP 400 `UNRECOGNIZED_PROPERTY` for `selector`. Work around it by running `./scripts/campaigns.sh list`, then filter the formatted table for `ENABLED` rows.
2. `./scripts/reports.sh keywords <cid> --sort spend` can fail with `INVALID_ORDER_BY_INPUT` because the API expects `localSpend`, not `spend`. Use `--sort localSpend`, omit `--sort`, or call `asa_api` directly with `orderBy.field="localSpend"`.
3. `optimize.sh bids` can emit `jq` division errors when install metrics are null. Continue with raw keyword reports and compute recommendations yourself from `total.localSpend.amount`, `total.taps`, and `totalInstalls` or `tapInstalls`.
4. Search term reports should use `timeZone:"ORTZ"`. General campaign and keyword reports can use UTC, but search terms are picky.
5. Search tab, Today tab, and Product Page campaigns do not contain keywords. Keyword-style wasted-spend reports may emit expected `INVALID_INPUT` errors for those supply sources. Note the errors, but do not abort the whole pass.
6. `metadata.searchTermText` in raw search-term JSON is often `null`. The formatted `search-terms.sh` script handles mapping via keyword metadata. When using the raw fallback, correlate search-term spend with keyword-level reports (which have `metadata.keyword` text) to identify actual terms.
7. `reports.sh campaigns` grand totals show `Spend=null` when Apple hasn't settled the day. Use the 7-day aggregate from POST `/reports/campaigns` endpoint (proper `grandTotals`) as the primary view.
8. Raw `/reports/campaigns` includes paused campaigns in rows and grand totals. For daily optimization reports, compute grand totals from the enabled-campaign rows only, using `campaigns.sh list --status ENABLED` (or list-all fallback) as the enabled source of truth. Otherwise paused historical spend can make the report look worse than the active account.
9. If an instruction references `~/.hermes/skills/advertising/apple-search-ads` but that directory does not exist, search installed skill paths and prefer `~/.hermes/skills/external-services/apple-search-ads` before failing. Multiple copies may exist; use the one with `references/daily-optimization.md` and executable scripts.

## Raw API fallback

When formatted scripts fail, source `scripts/asa-api.sh` and fetch raw JSON:

```bash
source scripts/asa-api.sh
body_keywords=$(jq -n --arg start "$WEEK_AGO" --arg end "$YESTERDAY" '{
  startTime:$start,
  endTime:$end,
  timeZone:"UTC",
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

**Known issue:** `metadata.searchTermText` in raw search-term JSON is often `null`. The formatted `search-terms.sh` handles this via keyword metadata mapping. When using the raw fallback, correlate search-term spend with keyword-level reports (which have text in `metadata.keyword`) to identify actual terms.

For deterministic approval commands, pull IDs from raw metadata:

- Keyword bid or pause: `metadata.keywordId`, `metadata.adGroupId`, `metadata.campaignId`
- Search-term promote target: use the relevant ad group ID from `/campaigns/$cid/adgroups`
- Negative: campaign ID is enough for `negatives.sh add-campaign`

## Search-Match-only campaigns (e.g. "Automation")

Campaigns using only Search Match (no targeting keywords) return empty keyword reports. This is expected, not an error. Optimization levers:

- **Budget adjustment** -- the only direct lever (reduce daily budget to control CPI).
- **Search-term mining** -- pull search-term reports and promote winners into exact-match campaigns. Negate losers at campaign level.
- **Ad group default bid** -- lower `defaultBidAmount` to reduce CPTs.
- Note in report as "Search Match only -- no keyword-level control."
- The `adgroup` detail endpoint (`GET /campaigns/$cid/adgroups/$agid`) may return null fields when querying single ad groups. Use the list endpoint instead.

## Yesterday-only data quirks

- Grand totals show `Spend=null` on yesterday-only campaign reports when Apple hasn't settled. Use the 7-day aggregate from POST `/reports/campaigns` (returns proper `grandTotals` with numeric values) as the primary view.
- If total yesterday spend < $0.10, lead with 7-day view and warn about data finalization.
- If yesterday spend is moderate ($1-5) but below 7-day daily avg, it's likely low traffic, not unsettled. Still prefer 7-day for optimization decisions.

## Recommendation thresholds

Only number recommendations that can be safely executed later by exact command. Put non-deterministic advice (`consider pausing`, `manual`, `reduce bids across the board`, budget strategy) in NOTABLE PATTERNS or a separate STRATEGIC NOTES section without approval numbers. Users reply by number, so numbered items must be executable.

- Pause keyword: 7-day spend > `$2`, installs = 0, taps >= 5.
- Lower bid: CPA > `$1.50`, installs >= 2. Move partway toward target CPA, and include current bid, suggested bid, and estimated savings.
- Raise bid: CPA < `$0.60`, installs >= 3, and impression share < 80%. Cap raise at +30% of current bid.
- Add negative: search term spend > `$1.50`, installs = 0, taps >= 3. Do not add an exact negative for the core brand term inside a brand campaign just because the 7-day window had zero attributed installs; brand-defense terms need manual review.
- Promote search term: installs >= 2 and CPA < `$0.80`.

**Edge case -- non-English keyword clusters:** When individual keywords don't breach the $2 pause threshold but a cluster of non-English/off-category keywords collectively waste significant spend (e.g. 5 German/Italian/Spanish bible keywords each at $1.30 = $6.50 total), flag them as a batch pause recommendation. The pattern matters more than individual thresholds.

Sort visible recommendations by dollar impact. Cap the visible list at 10 and mention that additional recommendations are in the logs.

## Bid calculation formula

Before recommending a bid change, compare the live bid to the 7-day average CPT. If live bid is already far below the average CPT that produced the bad CPA, the account may already have been corrected mid-window. In that case either skip the bid change or label it as a conservative extra trim; do not overstate projected savings.

For LOWER BID:
```
ideal_cpt = target_cpa * conversion_rate
suggested_bid = current_bid + (ideal_cpt - current_bid) * 0.5   # dampened 50%
```
Clamp: min $0.10, max = target CPA.

For RAISE BID:
```
suggested_bid = min(current_bid * 1.30, target_cpa * conversion_rate * 1.2)
```

## Fetching current bids

Always fetch current bids before recommending changes:
```bash
asa_api GET "/campaigns/$cid/adgroups/$agid/targetingkeywords" | jq '[.data[] | {id, text, bid: .bidAmount.amount}]'
```
The keyword report `metadata.bidAmount` field also works but may be stale if bids changed mid-period. The targeting keywords endpoint gives live values.

## Approval and execution follow-up

When the user replies after a recommendation report with `approve all`, `do everything`, or similar:

- Execute only numbered recommendations that include an exact, deterministic `./scripts/...` action command.
- Treat `CONSIDER`, `manual`, or strategy-only recommendations as advisory unless the user explicitly confirms the specific change (for example, `reduce Automation budget to $5`). Do not infer a mutable account change from a vague note.
- Before executing, copy the commands into a compact plan and verify env/script availability. After executing, verify from command output where possible.
- If an API endpoint hangs or times out repeatedly, do not keep retrying the same endpoint. Switch approach: use prior raw logs, formatted reports, or existing targeting snapshots, then report what was and was not safely applied.
- Keep the user-facing reply terse: applied actions, skipped advisory items, and any next confirmation needed. No filler like "I have all the data" or "let me write the report."

## Signal report shape

Keep the final report compact:

```text
ASA Daily Optimization - <YESTERDAY>

GRAND TOTALS (7-day: <WEEK_AGO> to <YESTERDAY>)
Spend: $X.XX | Imps: N | Taps: N | Installs: N
CPI: $X.XX | TTR: X.X% | CVR: X.X%
vs target CPA ($1.00): UNDER/OVER by $X.XX

YESTERDAY ONLY
Spend: $X.XX | Imps: N | Taps: N | Installs: N

CAMPAIGN BREAKDOWN (7-day)
| Campaign | Spend | Installs | CPI | TTR | CVR | Status |
(Status = under $1 CPI, $1-2, over $2, zero installs)

RECOMMENDATIONS (reply "approve N" or "approve all" to execute)

1. [ACTION] details
   Action: ./scripts/...
   Est. savings: $X.XX/week

Total projected weekly savings if all approved: $X.XX
Full logs: <OUT>

NOTABLE PATTERNS:
<insight about campaign mix, what's working, what's bleeding>
```

Add a NOTABLE PATTERNS section at the end with 3-5 strategic observations about the account's health and trajectory. This helps the user prioritize beyond individual keyword actions.
