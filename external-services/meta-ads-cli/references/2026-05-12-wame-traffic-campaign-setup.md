# wa.me Traffic Campaign: Proven API Setup (2026-05-12)

End-to-end verified setup for a Meta Traffic campaign that sends users to WhatsApp via wa.me deep link. Use this when BloomBot runs on Baileys (no WABA registration).

## Proven API sequence

### 1. Create campaign

```bash
curl -s -X POST "$GRAPH_URL/$ACCOUNT/campaigns" \
  -F "name=META_Traffic_Bloombot_WhatsApp_Cold_US_2026-05" \
  -F "objective=OUTCOME_TRAFFIC" \
  -F "status=ACTIVE" \
  -F "special_ad_categories=[]" \
  -F "access_token=$META_ACCESS_TOKEN"
```

### 2. Create ad set

```bash
curl -s -X POST "$GRAPH_URL/$ACCOUNT/adsets" \
  -F "name=US_Broad_25-54_WhatsApp_AllPlacements" \
  -F "campaign_id=$CAMPAIGN_ID" \
  -F "daily_budget=5000" \
  -F "billing_event=IMPRESSIONS" \
  -F "optimization_goal=LINK_CLICKS" \
  -F "bid_strategy=LOWEST_COST_WITHOUT_CAP" \
  -F "status=ACTIVE" \
  -F "targeting={\"geo_locations\":{\"countries\":[\"US\"]},\"age_min\":25,\"age_max\":54,\"locales\":[6],\"targeting_automation\":{\"advantage_audience\":0}}" \
  -F "access_token=$META_ACCESS_TOKEN"
```

**Critical:** The `targeting_automation.advantage_audience` field is REQUIRED (error 1870227 if missing). Set to `0` for manual targeting, `1` for Advantage+ audience expansion.

### 3. Upload image + create creative + create ad (per creative)

```bash
# Upload
UPLOAD=$(curl -s -X POST "$GRAPH_URL/$ACCOUNT/adimages" \
  -F "filename=@/path/to/creative.png" \
  -F "access_token=$META_ACCESS_TOKEN")
IMAGE_HASH=$(echo $UPLOAD | python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d['images'].values())[0]['hash'])")

# Creative with wa.me link
WAME_URL="https://wa.me/$WHATSAPP_NUMBER?text=Can+you+review+my+portfolio%3F"
CREATIVE_RESULT=$(curl -s -X POST "$GRAPH_URL/$ACCOUNT/adcreatives" \
  -F "name=Bloom CTWA Creative N" \
  -F "object_story_spec={
    \"page_id\": \"$PAGE_ID\",
    \"instagram_user_id\": \"$INSTAGRAM_ID\",
    \"link_data\": {
      \"link\": \"$WAME_URL\",
      \"message\": \"Primary ad text here\",
      \"image_hash\": \"$IMAGE_HASH\",
      \"name\": \"Headline here\",
      \"call_to_action\": {
        \"type\": \"LEARN_MORE\",
        \"value\": {\"link\": \"$WAME_URL\"}
      }
    }
  }" \
  -F "access_token=$META_ACCESS_TOKEN")
CREATIVE_ID=$(echo $CREATIVE_RESULT | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

# Ad
curl -s -X POST "$GRAPH_URL/$ACCOUNT/ads" \
  -F "name=Bloom WhatsApp Ad N - Headline" \
  -F "adset_id=$ADSET_ID" \
  -F "creative={\"creative_id\": \"$CREATIVE_ID\"}" \
  -F "status=ACTIVE" \
  -F "access_token=$META_ACCESS_TOKEN"
```

## Key details

- **Objective must be OUTCOME_TRAFFIC** (not OUTCOME_ENGAGEMENT or OUTCOME_LEADS, which require WABA).
- **CTA type: LEARN_MORE** works. SEND_MESSAGE may also work but LEARN_MORE is verified.
- **link_data.name** = headline (not "name" in the intuitive sense).
- **link_data.message** = primary text (the body copy above the image).
- **Budget in cents**: daily_budget=5000 means $50/day.
- **Ads go to IN_PROCESS** after creation (Meta ad review, typically a few hours).

## Attribution via unique prefills

Each ad gets a distinct prefilled message matching its angle. This serves as both routing and basic attribution since native CTWA `ctwa_clid` is unavailable.

Proven prefill set (2026-05-12 launch):

| Ad | Angle | Prefill |
|----|-------|---------|
| 1 | Portfolio WhatsApp chat | Can you review my portfolio? |
| 2 | Portfolio Notes checklist | I want a second opinion on my holdings |
| 3 | Stock gut check product test | What do you think about NVDA? |
| 4 | Stock gut check Reddit | Can you break down a stock for me? |
| 5 | Market brief sequence | What's happening in the market today? |
| 6 | Market brief bold statement | Give me today's market brief |

Frame prefills as natural conversation starters, not tracking codes. Users are less likely to edit/delete text that sounds like their own intent.

## Pitfall: advantage_audience required

Meta API error 1870227 ("Advantage Audience Flag Required") fires if you create an ad set without `targeting_automation.advantage_audience` in the targeting spec. This was added sometime in 2025-2026. Always include it.
