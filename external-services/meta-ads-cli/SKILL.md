---
name: meta-ads-cli
description: Operate Meta Ads campaigns via the Marketing API. Use when auditing campaign performance, pausing losers, identifying winners, researching competitors with Meta Ad Library, generating new creative concepts, uploading ads, or reporting paid social performance.
---

# Meta Ads CLI

Run repeatable Meta Ads operations using the Marketing API and supporting creative tools.

## Scope

This skill is for operational paid social workflows. It assumes the user has authorized access to a Meta ad account and has supplied account IDs through environment variables or config.

Do not hardcode account IDs, page IDs, app IDs, tokens, or private campaign names in this skill. Use placeholders.

## Environment

Expected variables:

```bash
META_ACCESS_TOKEN="$META_ACCESS_TOKEN"
META_AD_ACCOUNT_ID="$META_AD_ACCOUNT_ID"      # act_...
META_PAGE_ID="$META_PAGE_ID"
META_INSTAGRAM_ID="$META_INSTAGRAM_ID"
META_IOS_ADSET_ID="$META_IOS_ADSET_ID"
META_ANDROID_ADSET_ID="$META_ANDROID_ADSET_ID"
META_APP_STORE_ID="$META_APP_STORE_ID"
META_GRAPH_VERSION="v24.0"
GRAPH_URL="https://graph.facebook.com/${META_GRAPH_VERSION}"
```

Optional:

```bash
BRAND_NAME="$BRAND_NAME"
PRODUCT_NAME="$PRODUCT_NAME"
LANDING_PAGE_URL="$LANDING_PAGE_URL"
CREATIVE_HISTORY_FILE="$CREATIVE_HISTORY_FILE"
```

## Common Workflow

1. Audit active ads
2. Pull performance by campaign, ad set, and ad
3. Pause clear losers only when enough spend/data exists
4. Identify winners and extract patterns
5. Research competitor ads
6. Generate new creative concepts
7. Upload new creatives into the correct ad sets
8. Report what changed and what to watch next

## Data Pulls

### Active ads

```bash
curl -sG "$GRAPH_URL/$META_AD_ACCOUNT_ID/ads" \
  -d "access_token=$META_ACCESS_TOKEN" \
  -d 'fields=id,name,status,effective_status,campaign_id,adset_id,creative{id,name,thumbnail_url},created_time' \
  -d 'effective_status=["ACTIVE"]'
```

### Insights

```bash
curl -sG "$GRAPH_URL/$META_AD_ACCOUNT_ID/insights" \
  -d "access_token=$META_ACCESS_TOKEN" \
  -d 'level=ad' \
  -d 'date_preset=last_7d' \
  -d 'fields=ad_id,ad_name,spend,impressions,clicks,ctr,cpc,cpm,actions,action_values,purchase_roas'
```

### Ad Library competitor research

Use Meta Ad Library or the Marketing API where available. Track:
- Hook
- Format
- Visual style
- Offer
- CTA
- Landing page angle
- Estimated longevity
- What the advertiser repeats

Long-running ads are signal. New ads are hypotheses.

## Performance Rules

Do not kill ads too early. Require enough spend or impressions to make a decision.

Default guardrails:
- Minimum spend before judgment: `$MIN_DECISION_SPEND`, for example 1 to 2x target CPA
- Minimum impressions: `$MIN_IMPRESSIONS`
- Compare against campaign objective, not generic CTR alone
- Check attribution window and conversion lag
- Avoid pausing learning-phase ads unless performance is obviously broken

Pause candidates:
- High spend with no meaningful downstream action
- CTR far below account baseline and no conversions
- High CPC plus weak landing-page action
- Frequency fatigue with declining CTR
- Clearly broken creative, URL, or policy issue

Winner candidates:
- Low CPA or high ROAS vs account baseline
- Strong CTR and downstream conversion quality
- Good comments/save/share signal
- Holds performance as spend increases

## Creative Generation Brief

Generate concepts that are different from recent creative history.

For each concept include:
- Hook
- Format
- Visual direction
- Primary text
- Headline
- Description
- CTA
- Target audience
- Why it should work
- What previous pattern it is testing against

Use native formats:
- Notes app screenshot
- Text over lo-fi video
- Founder or user talking head
- Reddit/Tweet screenshot style
- Comment reply
- Meme format
- Before/after workflow
- Product proof reveal
- "I tried it for a week"

Avoid generic polished ad graphics unless the brand specifically needs them.

## Upload Pattern

1. Create or upload media asset.
2. Create ad creative with the page and Instagram actor IDs.
3. Create ad in target ad set.
4. Verify status and preview link.
5. Log the creative concept and ad ID.

Pseudo-flow:

```bash
# 1. Upload image or video asset
# 2. Create creative
curl -s -X POST "$GRAPH_URL/$META_AD_ACCOUNT_ID/adcreatives" \
  -d "access_token=$META_ACCESS_TOKEN" \
  -d "name=$CREATIVE_NAME" \
  -d "object_story_spec=$OBJECT_STORY_SPEC_JSON"

# 3. Create ad
curl -s -X POST "$GRAPH_URL/$META_AD_ACCOUNT_ID/ads" \
  -d "access_token=$META_ACCESS_TOKEN" \
  -d "name=$AD_NAME" \
  -d "adset_id=$TARGET_ADSET_ID" \
  -d "creative={\"creative_id\":\"$CREATIVE_ID\"}" \
  -d "status=PAUSED"
```

Default new ads to `PAUSED` unless the user explicitly asks to launch active ads.

## Reporting Format

Return:

1. Account/campaign audited
2. Date range
3. Spend, impressions, clicks, CTR, CPC, CPM, CPA/ROAS if available
4. Ads paused or recommended for pause, with reason
5. Winners to scale or clone
6. Competitor patterns noticed
7. New creative concepts generated
8. New ad IDs or draft asset paths
9. Risks, missing data, or next watch items

## Safety and Policy

- Do not publish or activate ads without explicit confirmation.
- Do not make prohibited claims.
- Do not use personal attributes in ad copy.
- Do not imply guaranteed financial, health, or income outcomes.
- Keep all IDs and tokens in environment variables.
- Report API failures without printing tokens.
