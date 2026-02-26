# Ad Iteration Engine (Kill-Promote Loop)

The core loop: generate variations → render → bulk upload → analyze performance data → kill losers → promote winners. Can run daily on a cron job.

## Overview

This is the autonomous ad iteration engine. Instead of manually reviewing ads, the system:

1. Pulls performance data from the data warehouse (Graphed MCP or Meta API)
2. Identifies losing ads (high CPM, low CTR, no conversions)
3. Turns them off via the Facebook Ads API
4. Identifies winning ads
5. Promotes winners to a conversion campaign with their own budget
6. Generates new creative variations to replace the losers
7. Bulk uploads the new variations

## Step 1: Pull Performance Data

Use Graphed MCP (data warehouse) or Meta Ads API to pull ad-level metrics.

**Key metrics to pull:**
- CPM (cost per 1,000 impressions): primary kill signal
- CPC (cost per click): secondary signal
- CTR (click-through rate): creative quality signal
- Conversions + CPA: ultimate success metric
- Impressions: minimum threshold before judging (need 1,000+)
- Spend: total cost per ad

**Via Graphed MCP (preferred, if installed):**
```
Use mcporter skill to call Graphed MCP.
Query: ad-level performance for the last 24h (or since last run).
Filter: only ads with 1,000+ impressions.
```

**Via Meta Marketing API (fallback):**
```python
# Pull ad insights
GET /{ad_account_id}/insights?level=ad
  &fields=ad_id,ad_name,impressions,cpm,cpc,ctr,actions,spend
  &date_preset=yesterday
  &filtering=[{"field":"impressions","operator":"GREATER_THAN","value":1000}]
```

**Output:** Save to `ads/iteration/[date]_performance.json`

## Step 2: Classify Ads (Kill / Keep / Promote)

Apply thresholds to classify each ad:

| Signal | Kill Threshold | Promote Threshold |
|--------|---------------|-------------------|
| CPM | > 2x campaign median | < 0.7x campaign median |
| CPC | > 2x campaign median | < 0.5x campaign median |
| CTR | < 0.5% | > 2% |
| CPA | > 2x target CPA | < 0.7x target CPA |

**Classification logic:**
```
FOR each ad with 1,000+ impressions:
  IF CPM > 2x median OR CPC > 2x median OR CTR < 0.5%:
    → KILL (turn off)
  ELIF CPA < 0.7x target AND CTR > 1.5%:
    → PROMOTE (move to conversion campaign)
  ELSE:
    → KEEP (let it run)
```

**Output:** `ads/iteration/[date]_decisions.md` with ad IDs, metrics, and classification.

## Step 3: Kill Losing Ads

Turn off ads classified as KILL via the Facebook Ads API.

**Via Meta API:**
```python
# Pause an ad
POST /{ad_id}
  &status=PAUSED
```

**Via browser automation (fallback):**
```
browser:navigate → Ads Manager → filter to specific ads → toggle off
```

Log every kill with reason: `ads/iteration/[date]_kills.log`

## Step 4: Promote Winners

Move winning ads to a dedicated conversion campaign with their own ad budget.

**Promotion flow:**
1. Create a new ad set in the conversion campaign (or use existing)
2. Duplicate the winning ad into the conversion campaign
3. Set individual budget ($10-20/day starting, scale from there)
4. Set optimization for conversions (not CPC)

**Via Meta API:**
```python
# Duplicate ad to conversion campaign
POST /{ad_account_id}/ads
  &creative={"creative_id": "{winning_creative_id}"}
  &adset_id={conversion_adset_id}
  &status=ACTIVE
```

Log promotions: `ads/iteration/[date]_promotions.log`

## Step 5: Generate Replacement Creatives

For every killed ad, generate a replacement variation. Use existing winners as signal for what works.

**Creative generation pipeline:**

1. **Analyze winners:** What hooks, formats, and angles are working? Extract patterns.
2. **Generate new hooks:** Use ad-copy skill with PAS/AIDA/BAB formulas. Vary the angle (fear vs hope, problem vs aspiration, specific vs broad).
3. **Pick formats:** Rotate through lo-fi formats (Notes App, Reddit screenshot, text-over-video, meme, testimonial card). Bias toward formats that have produced winners.
4. **Render as PNGs:** Use canvas tool to render HTML ad creatives as images (1080x1080 or 1080x1350).

**Tools for creative generation:**
- `ad-copy` skill: Generate copy variations (hooks, primary text, headlines)
- `meta-ads-creative` skill: 6 Elements framework, format templates
- `canvas` tool: Render HTML/React ad templates to PNG
- `image` tool: Analyze competitor ads for inspiration

**Template approach:**
```
For each killed ad slot:
  1. Pick a pain point (from research or winner analysis)
  2. Write 2-3 hook variations
  3. Select a format (rotate through the format library)
  4. Render via canvas as 1080x1080 PNG
  5. Add to upload queue
```

**Output:** PNGs saved to `ads/iteration/creatives/[date]/`

## Step 6: Bulk Upload New Creatives

Upload all new creatives to the CPC testing campaign.

**Via Meta API:**
```python
# Upload image
POST /{ad_account_id}/adimages
  &filename=@/path/to/creative.png

# Create ad creative
POST /{ad_account_id}/adcreatives
  &name="{campaign}_{format}_{hook}_{version}"
  &object_story_spec={"page_id": "{page_id}", "link_data": {
    "image_hash": "{hash}",
    "link": "{landing_url}",
    "message": "{primary_text}",
    "name": "{headline}",
    "description": "{description}",
    "call_to_action": {"type": "LEARN_MORE"}
  }}

# Create ad
POST /{ad_account_id}/ads
  &adset_id={cpc_test_adset_id}
  &creative={"creative_id": "{creative_id}"}
  &status=ACTIVE
  &name="{naming_convention}"
```

## Step 7: Log & Report

After each iteration run, generate a summary:

```markdown
## Ad Iteration Report - [Date]

### Actions Taken
- Ads analyzed: X
- Ads killed: Y (list with CPM/reason)
- Ads promoted: Z (list with CPA/metrics)
- New creatives uploaded: W

### Performance Trends
- Median CPM: $X.XX (vs $Y.YY yesterday)
- Best performer: [ad name] (CPA: $X.XX, CTR: X.X%)
- Worst performer killed: [ad name] (CPM: $X.XX)

### Winner Patterns
- Top hooks: [list patterns from winners]
- Top formats: [list formats from winners]
- Underperforming angles: [list]
```

Save to `ads/iteration/[date]_report.md` and send summary via message.

## Configuration

Store iteration config in `ads/iteration/config.json`:

```json
{
  "ad_account_id": "",
  "cpc_test_campaign_id": "",
  "conversion_campaign_id": "",
  "page_id": "",
  "landing_url": "",
  "target_cpa": 10.00,
  "min_impressions": 1000,
  "kill_cpm_multiplier": 2.0,
  "promote_cpa_multiplier": 0.7,
  "daily_budget_per_winner": 15.00,
  "max_new_creatives_per_run": 10,
  "data_source": "graphed_mcp",
  "pain_points_file": "ads/research/pain_points.md",
  "brand_voice_file": "~/marketing/WRITING-STYLE.md"
}
```

## Daily Cron Job

This phase runs on a 4am ET cron job. The job:
1. Pulls yesterday's data
2. Classifies ads
3. Kills losers
4. Promotes winners to conversion campaign
5. Generates replacement creatives
6. Uploads new creatives
7. Sends summary report
