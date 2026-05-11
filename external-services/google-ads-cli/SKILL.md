---
name: google-ads-cli
preloaded: true
description: "Use when managing Google Ads campaigns: performance checks, keyword pausing, report downloads, or campaign optimization via browser or API."
---

# Google Ads Skill

Manage Google Ads accounts via API or browser automation.

## Mode Selection

**Check which mode to use:**

1. **API Mode** - If user has `google-ads.yaml` configured or `GOOGLE_ADS_*` env vars
2. **Browser Mode** - If user says "I don't have API access" or just wants quick checks

```bash
# Check for API config
ls ~/.google-ads.yaml 2>/dev/null || ls google-ads.yaml 2>/dev/null
```

If no config found, ask: "Do you have Google Ads API credentials, or should I use browser automation?"

---

## Browser Automation Mode (Universal)

**Requirements:** User logged into ads.google.com in browser

### Setup
1. User opens ads.google.com and logs in
2. User clicks OpenClaw Browser Relay toolbar icon (badge ON)
3. Use `browser` tool with `profile="chrome"`

### Common Workflows

#### Get Campaign Performance
```
1. Navigate to: ads.google.com/aw/campaigns
2. Set date range (top right date picker)
3. Snapshot the campaigns table
4. Parse: Campaign, Status, Budget, Cost, Conversions, Cost/Conv
```

#### Find Zero-Conversion Keywords (Wasted Spend)
```
1. Navigate to: ads.google.com/aw/keywords
2. Click "Add filter" → Conversions → Less than → 1
3. Click "Add filter" → Cost → Greater than → [threshold, e.g., $500]
4. Sort by Cost descending
5. Snapshot table for analysis
```

#### Pause Keywords/Campaigns
```
1. Navigate to keywords or campaigns view
2. Check boxes for items to pause
3. Click "Edit" dropdown → "Pause"
4. Confirm action
```

#### Download Reports
```
1. Navigate to desired view (campaigns, keywords, etc.)
2. Click "Download" icon (top right of table)
3. Select format (CSV recommended)
4. File downloads to user's Downloads folder
```

**For detailed browser selectors:** See `references/browser-workflows.md`

---

## API Mode (Power Users)

**Requirements:** Google Ads API developer token + OAuth credentials

### Setup Check
```bash
# Verify google-ads SDK
python -c "from google.ads.googleads.client import GoogleAdsClient; print('OK')"

# Check config
cat ~/.google-ads.yaml
```

### Common Operations

#### Query Campaign Performance
```python
from google.ads.googleads.client import GoogleAdsClient

client = GoogleAdsClient.load_from_storage()
ga_service = client.get_service("GoogleAdsService")

query = """
    SELECT campaign.name, campaign.status,
           metrics.cost_micros, metrics.conversions,
           metrics.cost_per_conversion
    FROM campaign
    WHERE segments.date DURING LAST_30_DAYS
    ORDER BY metrics.cost_micros DESC
"""

response = ga_service.search(customer_id=CUSTOMER_ID, query=query)
```

#### Find Zero-Conversion Keywords
```python
query = """
    SELECT ad_group_criterion.keyword.text,
           campaign.name, metrics.cost_micros
    FROM keyword_view
    WHERE metrics.conversions = 0
      AND metrics.cost_micros > 500000000
      AND segments.date DURING LAST_90_DAYS
    ORDER BY metrics.cost_micros DESC
"""
```

#### Pause Keywords
```python
operations = []
for keyword_id in keywords_to_pause:
    operation = client.get_type("AdGroupCriterionOperation")
    operation.update.resource_name = f"customers/{customer_id}/adGroupCriteria/{ad_group_id}~{keyword_id}"
    operation.update.status = client.enums.AdGroupCriterionStatusEnum.PAUSED
    operations.append(operation)

service.mutate_ad_group_criteria(customer_id=customer_id, operations=operations)
```

**For full API reference:** See `references/api-setup.md`

---

## Google Ads Scripts

For recurring automation tasks, use Google Ads Scripts (JavaScript running in Google Ads editor). See `references/google-ads-scripts.md` for the full guide including:

- AdsApp API fundamentals (selectors, iterators, statistics)
- Campaign, ad group, keyword, and ad operations
- Bid optimization (ROAS/CPA-based)
- Performance reporting and Google Sheets export
- Budget management and spending alerts
- Automated rules (pause low-quality keywords, quality score monitoring)
- Error handling and debugging patterns

**Additional script resources:**
- `references/google-ads-scripts-api-reference.md` — Complete AdsApp API reference
- `references/google-ads-scripts-examples.md` — Production-ready code examples
- `references/google-ads-scripts-best-practices.md` — Best practices with code
- `references/google-ads-scripts-patterns.md` — Reusable automation patterns
- `references/google-ads-scripts-validators.py` — Python validation utilities
- `references/google-ads-scripts-campaign-optimizer.js` — Campaign optimizer template
- `references/google-ads-scripts-bid-manager.js` — Bid manager template

---

## Report-only daily optimization review

Use this workflow for scheduled or recurring optimization reviews where the user explicitly says not to mutate campaigns.

1. Confirm API access with `~/.google-ads.yaml`; install the Python package if needed with `python -m pip install google-ads`.
2. Query all enabled campaigns for `YESTERDAY`, `LAST_7_DAYS`, and `LAST_30_DAYS`.
3. Include `campaign_budget.amount_micros`, `campaign.bidding_strategy_type`, `campaign.target_cpa.target_cpa_micros`, `campaign.maximize_conversions.target_cpa_micros`, `campaign.target_roas.target_roas`, and `campaign.maximize_conversion_value.target_roas` so recommendations can cite current vs proposed values.
4. Include App Campaign context (`campaign.app_campaign_setting.app_id`, `app_store`, `bidding_strategy_goal_type`) before explaining attribution. Do not infer iOS/CPP behavior for Android Google Play campaigns.
5. Pull App Campaign asset performance from `ad_group_ad_asset_view`, not `asset_group_asset`.
6. Score campaigns on CPA vs tCPA, ROAS vs tROAS, spend pacing against daily budget, and conversion volume.
7. Rank top assets by the campaign objective, not generic CTR. For tROAS campaigns, prefer conversion value and ROAS with enough spend/impressions; for tCPA campaigns, use CPA/conversions with volume floors.
8. Only recommend actions. Do not call mutate services, pause assets, change budgets, or edit bids in report-only mode.

### Deterministic scheduled reports

For recurring cron reports, prefer a deterministic script over an agent-written prose report. Have the script query Google Ads, compute CPA/ROAS/date math, include app store context, and print the final report; then configure cron with `script=...` and `no_agent=true` so stdout is delivered as-is. This prevents LLM date mistakes, stale ratio math, wrong attribution explanations, and objective-mismatched top asset picks. See `references/deterministic-scheduled-reports.md` for GAQL snippets, cron update pattern, and the double-down workflow for winning assets.

Recommendation thresholds to start from:
- **PAUSE**: zero conversions plus meaningful spend over 7-30 days.
- **BUDGET UP**: CPA well below target or ROAS above target, high conversion volume, and daily spend near budget.
- **BUDGET DOWN**: sustained overspend with weak conversion signal.
- **BID ADJUST**: tCPA/tROAS mismatch persists across 7d and 30d windows.
- **REMOVE ASSET**: 1000+ impressions and zero conversions.
- **INVESTIGATE**: value tracking is zero on tROAS campaigns, sudden conversion/value drops, policy/status issues, or low CPA but weak ROAS where installs may be dominating counted conversions.

## Audit Checklist

Quick health check for any Google Ads account:

| Check | Browser Path | What to Look For |
|-------|--------------|------------------|
| Zero-conv keywords | Keywords → Filter: Conv<1, Cost>$500 | Wasted spend |
| Empty ad groups | Ad Groups → Filter: Ads=0 | No creative running |
| Policy violations | Campaigns → Status column | Yellow warning icons |
| Optimization Score | Overview page (top right) | Below 70% = action needed |
| Conversion tracking | Tools → Conversions | Inactive/no recent data |

---

## Output Formats

When reporting findings, use tables:

```markdown
## Campaign Performance (Last 30 Days)
| Campaign | Cost | Conv | CPA | Status |
|----------|------|------|-----|--------|
| Branded  | $5K  | 50   | $100| ✅ Good |
| SDK Web  | $10K | 2    | $5K | ❌ Pause |

## Recommended Actions
1. **PAUSE**: SDK Web campaign ($5K CPA)
2. **INCREASE**: Branded budget (strong performer)
```

---

## Attribution: Custom Product Pages (iOS App Campaigns)

For iOS app install campaigns, use Apple Custom Product Pages (CPPs) as the ad click-through destination. Each CPP is tracked in App Store Connect analytics with exact download and revenue data, giving you deterministic attribution per campaign/ad group without relying on SKAdNetwork or MMPs.

**How:** Create a CPP in App Store Connect, then set the CPP URL as the Final URL in your App Campaign ads. Google Ads supports custom App Store URLs for app install campaigns.

**The 30% rule:** CPP revenue undercounts by ~30% because view-through users (saw the ad, searched the App Store directly) aren't captured. Factor this into ROAS.

**Limit:** 35 CPPs per app. One per campaign or ad group theme works well.

This is the cleanest iOS attribution signal available post-ATT. Server-side, no SDK, no privacy thresholds.

## Common Mistakes

1. **Using dashes in Customer ID** — The Google Ads API requires the 10-digit customer ID without dashes (e.g., `1234567890` not `123-456-7890`). Wrong format causes immediate authentication failure.
2. **RSA character limits ignored** — Headlines max 30 chars, descriptions max 90 chars. Exceeding these silently truncates or rejects ads. Always count before submitting.
3. **Developer token in test mode** — A test-mode developer token can query the API but can't modify campaigns. If mutations silently fail, verify the token is approved for production.
4. **Checking UI before waiting for tables** — The Google Ads UI is heavy and loads data asynchronously. Taking a snapshot too early captures loading spinners, not data. Wait for tables to fully render.
6. **`asset_group_asset` is not reliable for App Campaign asset reporting** — legacy App Campaigns may return zero rows. Use `ad_group_ad_asset_view` with `campaign.status` in the SELECT clause. If you see `PROHIBITED_RESOURCE_TYPE_IN_SELECT_CLAUSE` from `asset_field_type_view`, switch views instead of fighting the field list.
7. **`campaign_budget` fields are incompatible with `ad_group_ad_asset_view`** — query budgets separately from `campaign`; don't include `campaign_budget.amount_micros` in the asset-performance GAQL.
8. **Default config path may be wrong** — if `GoogleAdsClient.load_from_storage()` looks for `~/google-ads.yaml` while the real file is `~/.google-ads.yaml`, pass the absolute path explicitly.
9. **DataForSEO app competitor rows may omit titles** — resolve returned app IDs through `https://itunes.apple.com/lookup?id=<ids>&country=us` before reporting competitor names.
10. **Higgsfield model schemas change** — `seedream_v5_lite` may reject `--aspect_ratio 2:1`; check `higgsfield model get seedream_v5_lite --json`, generate 16:9 if needed, then crop to 1200x628.

---

## Weekly Creative Asset Generation

Run weekly (Mondays) to refresh ad assets. Separate from the daily performance report.

### Asset Specs (Google App Campaigns)

| Asset Type | Specs | Max per campaign |
|---|---|---|
| Headline | Max 30 chars | 5 |
| Description | Max 90 chars | 5 |
| Landscape Image | 1200x628px, <5MB, PNG/JPG | 20 |
| Square Image | 1200x1200px, <5MB, PNG/JPG | 20 |
| Video | YouTube URL, 10-30s preferred | 20 |

### Step W1 — Analyze Existing Asset Performance

For App Campaigns, prefer `ad_group_ad_asset_view`. `asset_group_asset` often returns zero rows for legacy App Campaigns, and `asset_field_type_view` can reject direct `asset.*` fields as incompatible.

Read `references/weekly-creative-generation-notes.md` before scheduled creative runs. It captures API quirks, DataForSEO title lookup, Higgsfield sizing workarounds, and the chart/callout double-down pattern from prior runs.

```python
# Query asset performance for App Campaigns
query = """
    SELECT
      campaign.status,
      campaign.id,
      campaign.name,
      asset.id,
      asset.name,
      asset.type,
      asset.text_asset.text,
      asset.image_asset.full_size.url,
      asset.youtube_video_asset.youtube_video_title,
      ad_group_ad_asset_view.field_type,
      metrics.impressions,
      metrics.clicks,
      metrics.cost_micros,
      metrics.conversions,
      metrics.conversions_value
    FROM ad_group_ad_asset_view
    WHERE campaign.status = 'ENABLED'
      AND segments.date DURING LAST_30_DAYS
      AND metrics.impressions > 0
    ORDER BY metrics.conversions DESC
    LIMIT 500
"""
```

Identify:
- Top performing headlines, descriptions, images, and videos by campaign objective. For tROAS campaigns, prioritize conversion value and ROAS with enough spend/impressions; for tCPA campaigns, prioritize CPA/conversions.
- Bottom performers by conversion rate once they have meaningful impressions
- Removal candidates: assets with 1000+ impressions and zero conversions
- Whether known winning assets still win, and what visual/copy pattern should be doubled down on

### Step W2 — Competitor Copy Research (via DataForSEO)

```bash
# Get competitor App Store listings for copy inspiration
export BASE="https://api.dataforseo.com/v3"
export DFS_AUTH="Authorization: Basic $DATAFORSEO_AUTH_BASE64"

# Get keywords competitors rank for
curl -s -X POST "$BASE/dataforseo_labs/apple/app_competitors/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"app_id": "$BLOOM_APP_STORE_ID", "location_code": 2840, "language_code": "en", "limit": 10}]'

# Get keyword ideas for ad copy inspiration
curl -s -X POST "$BASE/keywords_data/google_ads/keywords_for_keywords/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "stock research", "portfolio tracker", "ai stock picks"], "location_code": 2840, "language_code": "en", "limit": 50}]'
```

Use high-volume keyword phrases to inform headline and description copy.

### Step W3 — Generate Headlines + Descriptions

Generate **5 new headlines** (max 30 chars each) and **3 new descriptions** (max 90 chars each).

**Headline principles:**
- Include high-volume keywords naturally
- Benefit-focused, not feature-focused
- Numbers when possible ("500+ stocks", "24/7")
- Must be EXACTLY ≤30 characters (count carefully)

**Description principles:**
- Expand on the headline's promise
- Include a soft CTA ("Start free", "Try today")
- Social proof if fits ("100K+ downloads")
- Must be EXACTLY ≤90 characters

**Informed by:**
- Winning patterns from Step W1 (double down)
- Competitor keyword themes from Step W2
- Bloom value props: AI stock picks, 500+ stocks monitored, no experience needed, free to start

### Step W4 — Generate Image Assets (2 images)

Generate using the tri-model approach. Sizes needed:

1. **Landscape (1200x628)** — for display network, YouTube placements
2. **Square (1200x1200)** — for feed placements, discovery

```bash
# Higgsfield (landscape)
# Check allowed aspect ratios first. If 2:1 is unavailable, generate 16:9 and crop/resize to 1200x628.
higgsfield model get seedream_v5_lite --json
higgsfield generate create seedream_v5_lite \
  --prompt "..." \
  --aspect_ratio 16:9 \
  --quality high \
  --wait --json

# Nano Banana Pro, gpt-image-2, or Seedream 1:1 (square)
# Resize final square to 1200x1200.
```

For exact crop commands and known model quirks, see `references/weekly-creative-generation-notes.md`.

**Creative direction for Google App Campaign images:**
- Double down on proven winning visual patterns from Step W1. If the winner is a clean chart/callout creative, create variants of that pattern instead of defaulting to phone mockups.
- For chart/callout variants: white background, thick green trend line, orange event marker, small clean tooltip connected to the chart, neutral market-event language, and no real tickers.
- Show the app in action only when the winning pattern or prompt calls for UI. Do not add phone mockups by default.
- Clean, professional, not meme-style (Google is stricter than Meta)
- Include the app name "Bloom" visually only if it improves clarity
- No misleading financial claims or specific return promises
- Bright, optimistic color palette matching brand (teal #28B5BD, navy #0f172a)

### Step W5 — Generate Video Asset (1 video, 15-30s)

Use Higgsfield Marketing Studio for a polished app ad video:

```bash
# Fetch Bloom as webproduct (App Store URL)
higgsfield marketing-studio products fetch --url "https://apps.apple.com/app/id$BLOOM_APP_STORE_ID" --wait

# Generate video ad (UGC or Product Showcase preset)
higgsfield generate create marketing_studio_video \
  --url "https://apps.apple.com/app/id$BLOOM_APP_STORE_ID" \
  --mode product_showcase \
  --duration 15 \
  --aspect_ratio 16:9 \
  --wait --json
```

**Video requirements for Google:**
- Must be uploaded to YouTube first (Google Ads references YouTube URLs)
- 10-30 seconds preferred
- 16:9 (landscape) or 9:16 (vertical/Shorts) or 1:1 (square)
- After generation, upload to YouTube as unlisted → use YouTube URL as asset

**Alternative if Higgsfield video auth fails:**
- Generate a static image + use it as a YouTube Short with Ken Burns effect
- Or skip video for this week and note in report

### Step W6 — Visual QA Gate

Inspect every generated image/video before reporting it. Be stricter than normal: Eric explicitly rejected generic AI image assets for ads, so bias toward false negatives. It is better to send zero creative assets than to offer low-quality ones for upload.

Hard reject any asset with:
1. Illegible, misspelled, garbled, or awkward text
2. Wrong logos, fake UI, fake tickers, or misleading finance claims
3. Obvious AI artifacts, glossy AI-template polish, or uncanny composition
4. Generic finance visuals: bland line charts, abstract stock arrows, meaningless dashboards, crypto/Wall Street clichés, clipart people, or low-effort SaaS ad layouts
5. Weak connection to Bloom's actual value prop: understanding why stocks move, AI research, market news, and investor decision support
6. Anything that looks like an asset Eric would call "AI slop" or "this image asset sucks"

Score each asset 1-5 on specificity, taste/design quality, typography, non-generic finance visual, and policy safety. Approve only if the overall score is at least 4/5 and no category is below 3/5.

Rejected assets must not be attached, recommended, offered for upload, or uploaded. Regenerate up to 2 times if time allows. If nothing clears the gate, say no usable image assets were generated this week and attach zero images.

If video/UGC looks too synthetic but otherwise promising, apply light finishing: grain 25-40, sharpness +10-20, brightness -5 to -10, vignette 5-15. If it still looks fake or generic, reject it.

### Step W7 — Report with Confirmation

Output the report with only approved assets. DO NOT upload automatically.

```
🎯 Google Ads Weekly Creative Refresh — [date]

## Asset Performance (Last 30 Days)
Top headline: "..." — X conv, Y% CTR
Top description: "..." — X conv
Weakest asset: "..." — 0 conv, $X spend → recommend removal

## New Headlines (5)
1. "AI research for investors" (25 chars)
2. ...

## New Descriptions (3)
1. "See the news behind price moves. Try Bloom free." (48 chars)
2. ...

## Creative QA
Generated candidates: X
Approved assets: Y
Rejected assets: Z
Rejected reasons:
- asset/file: reason

## Approved Images
[attach only approved assets]

## Approved Video
[YouTube URL or attach only if approved]

If Y > 0: Reply "upload" to add approved assets to campaign [name].
If Y = 0: No assets are uploadable from this run. Do not include an upload CTA.
```

### Step W8 — Upload on Confirmation (manual trigger)

```python
# Create text asset (headline)
asset_op = client.get_type("AssetOperation")
asset = asset_op.create
asset.text_asset.text = "AI picks. You profit."
asset.name = f"Bloom Headline {date}"

asset_service.mutate_assets(customer_id=CUSTOMER_ID, operations=[asset_op])

# Create image asset
asset_op = client.get_type("AssetOperation")
asset = asset_op.create
asset.image_asset.data = image_bytes  # raw bytes
asset.image_asset.file_size = len(image_bytes)
asset.image_asset.mime_type = client.enums.MimeTypeEnum.IMAGE_PNG
asset.name = f"Bloom Landscape {date}"

# Link asset to campaign asset group
campaign_asset_op = client.get_type("AssetGroupAssetOperation")
...
```

---

## Troubleshooting

### Browser Mode Issues
- **Can't see data**: Check user is on correct account (top right account selector)
- **Slow loading**: Google Ads UI is heavy; wait for tables to fully load
- **Session expired**: User needs to re-login to ads.google.com

### API Mode Issues
- **Authentication failed**: Refresh OAuth token, check `google-ads.yaml`
- **Developer token rejected**: Ensure token is approved (not test mode)
- **Customer ID error**: Use 10-digit ID without dashes
- **proto-plus CopyFrom errors**: Assign directly (e.g., `operation.create = obj`) instead of `CopyFrom` on create fields
- **contains_eu_political_advertising required**: Set to integer `0/1` (not boolean)
- **RSA text too long**: Headlines max 30 chars, descriptions max 90 chars
