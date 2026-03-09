---
name: meta-ads-iteration
description: Use when the cron fires at 4am ET daily — checks Meta ad performance via API, kills losers, promotes winners, generates 6 fresh creatives via Nano Banana Pro, uploads them as new ads via API, and reports to Signal.
---

# Meta Ads Iteration

Daily 4am routine: audit running ads via Meta Marketing API, kill underperformers, boost winners, generate 6 brand-new creative concepts (never repeating a used hook/format combo), upload them as new ads via API, and report to Signal.

---

## API Credentials

```bash
TOKEN=$FACEBOOK_ACCESS_TOKEN      # Meta Marketing API token
ACCOUNT="$BLOOM_AD_ACCOUNT_ID"    # Bloom ad account (act_...)
API="https://graph.facebook.com/v22.0"
PAGE_ID="$BLOOM_PAGE_ID"           # Facebook Page ID
INSTAGRAM_ID="$BLOOM_INSTAGRAM_ID" # Instagram user ID for creatives
IOS_APP_LINK="http://itunes.apple.com/app/id${BLOOM_APP_STORE_ID_NEW}"  # current App Store ID
ANDROID_APP_LINK="http://play.google.com/store/apps/details?id=com.bloom.invest"
ADSET_IOS="$BLOOM_IOS_ADSET_ID"       # General, iOS (ACTIVE)
ADSET_ANDROID="$BLOOM_ANDROID_ADSET_ID"   # General, Android (ACTIVE)
# All BLOOM_* vars set in gateway env. BLOOM_APP_STORE_ID_NEW = current app for ad links.
```

---

## Tools

| Tool | Purpose |
|------|---------|
| `curl` + Meta Marketing API v22.0 | All ad management (read, pause, budget, create) |
| `trend-research` skill | Find what investing/finance content is trending today |
| `web-search` skill | Serper for trending finance content |
| `nano-banana-pro` skill | Generate 1080×1080 ad creatives |
| `message` tool | Report + send creatives to Signal group |

---

## Workflow

### Step 1 — Get Performance Data

```bash
# Get all ads with status
curl -s "$API/$ACCOUNT/ads?fields=id,name,status,effective_status,adset_id&access_token=$TOKEN"

# Get insights for last 7 days (use last_30d if an ad is newer)
curl -s "$API/$ACCOUNT/insights?fields=ad_id,ad_name,impressions,reach,clicks,spend,cpm,ctr,actions&date_preset=last_7d&level=ad&access_token=$TOKEN"
```

Save to `ads/iteration/$(date +%Y-%m-%d)_performance.md`:
- ad_id, name, impressions, spend, CPM, CTR, clicks

### Step 2 — Classify Ads

Only classify ads with **1,000+ impressions** (insufficient data below this).

Calculate median CPM across all qualifying ads.

| Decision | Criteria |
|----------|----------|
| **KILL** | CPM > 2× median CPM, OR CTR < 0.5% |
| **PROMOTE** | CPM < 0.7× median CPM AND CTR > 2% |
| **KEEP** | Everything else |

Save decisions to `ads/iteration/$(date +%Y-%m-%d)_decisions.md`.

### Step 3 — Kill Losers

```bash
# Pause a specific ad
curl -s -X POST "$API/$AD_ID" \
  -F "status=PAUSED" \
  -F "access_token=$TOKEN"
```

Log each kill to `ads/iteration/$(date +%Y-%m-%d)_kills.log`.

### Step 4 — Promote Winners

```bash
# Increase ad set daily budget (in cents — $6/day = 600)
# Get current adset budget first, then increase by $2
curl -s -X POST "$API/$ADSET_ID" \
  -F "daily_budget=600" \
  -F "access_token=$TOKEN"
```

Log each promotion to `ads/iteration/$(date +%Y-%m-%d)_promotions.log`.

### Step 5 — Generate 6 New Creatives

**Always generate exactly 6 new creatives per run.**

#### 5a — Build Exclusion List

Audit all `ads/iteration/creatives/*/manifest.md` files. Build list of used `hook_type + format + concept` combos. No repeats.

#### 5b — Research Trending Content

Use trend-research skill + web-search:
- "investing finance content trending [today's date]"
- Look for viral formats, hot tickers, news-driven hooks

#### 5c — Pick 6 Novel Concepts

- All 6 hooks must differ from exclusion list
- At least 2 from fresh trend research
- At least 1 format not previously tested

**Available formats:**
iOS Notes App screenshot, Reddit post mockup, Twitter/X screenshot, Meme comparison, Testimonial card, Dark stat card, Text-over-chart, Founder video caption card, News headline mockup, App Store screenshot mock, Bold typographic, Phone mockup, WhatsApp group chat, Court/legal parody, Weather app card, Bank statement, Review split card, CVS receipt, Glassdoor card, Earnings card

#### 5d — Generate Each Creative

```bash
GEMINI_API_KEY=$(python3 -c "import json; d=json.load(open('/Users/testuser/.clawdbot/clawdbot.json')); print(d.get('skills',{}).get('entries',{}).get('nano-banana-pro',{}).get('apiKey','') or d['env']['vars'].get('GEMINI_API_KEY',''))" 2>/dev/null)
export GEMINI_API_KEY

uv run /opt/homebrew/lib/node_modules/clawdbot/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "..." \
  --filename "ads/iteration/creatives/$(date +%Y-%m-%d)/creative-N.png" \
  --resolution 2K --thinking high
```

**Design requirements:**
- 1080×1080 pixels (square for feed)
- Bloom brand colors: `#28B5BD` teal, `#0f172a` navy, `#F5A623` amber
- High contrast, thumb-stopping in 0.5s
- Bloom logo: 3 teal circles (light top-right, medium left, dark small bottom-right)

**Output filename:** Use a short slug describing the format:
- Pattern: `creative-N-<format-slug>.png` (e.g. `creative-1-whatsapp-chat.png`, `creative-3-weather-card.png`)
- Slug: 2–3 words, lowercase, hyphenated. Makes files scannable without opening them.

#### 5e — Save Manifest

Write `ads/iteration/creatives/$(date +%Y-%m-%d)/manifest.md` with format/hook/concept table. Use the labeled filenames (with slug) in the File column.

### Step 6 — Upload New Ads via API

For each of the 6 creatives, run this 3-step sequence:

**Step 6a: Upload image**
```bash
UPLOAD=$(curl -s -X POST "$API/$ACCOUNT/adimages" \
  -F "filename=@/path/to/creative-N.png" \
  -F "access_token=$TOKEN")

IMAGE_HASH=$(echo $UPLOAD | python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d['images'].values())[0]['hash'])")
```

**Step 6b: Create ad creative**
```bash
CREATIVE=$(curl -s -X POST "$API/$ACCOUNT/adcreatives" \
  -F "name=Bloom Creative $(date +%Y-%m-%d) N" \
  -F "object_story_spec={
    \"page_id\": \"$PAGE_ID\",
    \"instagram_user_id\": \"$INSTAGRAM_ID\",
    \"link_data\": {
      \"link\": \"$IOS_APP_LINK\",
      \"message\": \"[ad copy — the hook text]\",
      \"image_hash\": \"$IMAGE_HASH\",
      \"call_to_action\": {
        \"type\": \"LEARN_MORE\",
        \"value\": {\"link\": \"$IOS_APP_LINK\"}
      }
    }
  }" \
  -F "access_token=$TOKEN")

CREATIVE_ID=$(echo $CREATIVE | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
```

**Step 6c: Create ad in iOS ad set**
```bash
curl -s -X POST "$API/$ACCOUNT/ads" \
  -F "name=Bloom $(date +%Y-%m-%d) Creative N" \
  -F "adset_id=$ADSET_IOS" \
  -F "creative={\"creative_id\": \"$CREATIVE_ID\"}" \
  -F "status=ACTIVE" \
  -F "access_token=$TOKEN"
```

Repeat 6a-6c for Android ad set (`$ADSET_ANDROID`) using the Android app link, so each creative gets two ads (iOS + Android).

⚠️ **If any API call returns an error with `payment` or `billing`: STOP and notify Eric.**

### Step 7 — Report to Signal

Send to `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`:

```
🎯 Meta Ads Daily Run — [date]

X ads analyzed | Y killed | Z promoted | 12 new ads uploaded (6 iOS + 6 Android)

Best performer: [ad name] — CPM $X, CTR X%
Worst performer: [ad name] — CPM $X, CTR X%

6 new concepts:
1. [format] — [hook]
...
```

Then send each of the 6 creative images one at a time with a caption.

---

## Delivery

- Signal group: `group:5TgLlI8NfnETVAzVvUi0rJ0WKz2Pz2Flj5i2/VAcFSY=`
- Performance log: `ads/iteration/[date]_performance.md`
- Kills log: `ads/iteration/[date]_kills.log`
- Promotions log: `ads/iteration/[date]_promotions.log`
- Creatives: `ads/iteration/creatives/[date]/creative-N-<format-slug>.png`
- Manifest: `ads/iteration/creatives/[date]/manifest.md`

---

## Cron Config

- **ID:** `f0c3f833-36d6-4781-b2ff-e5ab8e4129a4`
- **Schedule:** `0 4 * * *` (4am ET, daily)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## ⚠️ CRITICAL: API Only — Never Browser Login

**NEVER attempt to log into Meta Ads Manager or Facebook via browser.** Browser login can trigger a security lockout on the ad account. All Meta ad management must go through the Marketing API only (`graph.facebook.com/v22.0`).

If the API returns `code=31` ("pending action" / security hold), **stop and notify Eric** — he must resolve it manually from his own browser. Do not attempt browser automation to fix it.

Always use `$BLOOM_APP_STORE_ID_NEW` for iOS ad links (the current App Store ID). The adset's `promoted_object.object_store_url` is the ground truth — verify it matches before creating creatives.

## Common Mistakes

1. **Token not set** — always use `$FACEBOOK_ACCESS_TOKEN` from env. Never hardcode.
2. **Wrong budget units** — daily_budget is in cents. $5/day = 500, $6/day = 600.
3. **Repeating a hook/format/concept combo** — always audit exclusion list first.
4. **Forgetting Android ad set** — each creative should get two ads (iOS + Android ad sets).
5. **Not checking impressions threshold** — don't classify ads with <1000 impressions.
6. **Missing GEMINI_API_KEY** — resolve from clawdbot.json before Nano Banana Pro.
7. **Not sending creative images** — Signal report must include all 6 images.
8. **Forgetting the manifest** — required for future exclusion list audits.
9. **Wrong App Store URL** — always use `$BLOOM_APP_STORE_ID_NEW` for ad links. Verify against adset `promoted_object.object_store_url`.
