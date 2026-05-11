# Meta Ads CLI — Operational Pitfalls (Discovered in Production)

These are runtime issues discovered during actual cron executions. Check this file before debugging failures.

## Android App Link Mismatch (2026-05-10)

The Android adset's `promoted_object.object_store_url` uses the package name from `$ANDROID_PACKAGE_NAME`, not stale package env vars from older setups.

**Fix:** Always verify the adset's promoted_object before creating creatives:
```bash
curl -sG "$GRAPH_URL/$ADSET_ANDROID" \
  --data-urlencode "fields=promoted_object" \
  --data-urlencode "access_token=$TOKEN" | python3 -m json.tool
```
Use the `object_store_url` value from the response as the link in your `object_story_spec`. Create iOS and Android creatives with SEPARATE object_story_specs (different links).

## 50-Ad-Per-Adset Limit (2026-05-10)

Meta enforces max 50 ads per adset. This includes PAUSED ads (but not ARCHIVED). Error message: "Too Many Ads" (code 100, subcode 1487809).

**Fix:** Before uploading new ads, archive oldest paused ads:
```bash
curl -s -X POST "$GRAPH_URL/$AD_ID" \
  -F "status=ARCHIVED" \
  -F "access_token=$TOKEN"
```
Archive at least 12 to make room for a full batch (6 iOS + 6 Android).

**Important:** The adset-level ad listing may return 0 ads if the default filter excludes paused/archived. Use the account-level listing from Step 1 (which already pulled all ads) to identify paused ads by adset_id.

## Rate Limiting (2026-05-10)

Error: "User request limit reached" (code 17, subcode 2446079).

**Prevention:**
- Do ALL reads first (Step 1), then ALL writes (archiving, creating) after
- Add `sleep 2` between write operations
- If hit: wait 5 minutes, then retry

**Recovery:** The rate limit clears after ~5 minutes of inactivity on the ad account.

## OpenAI image model API format (2026-05-10)

If falling back to `gpt-image-1` instead of the current preferred image model, the OpenAI Images API:
- Returns `b64_json` by default in `data[0].b64_json`
- Does NOT accept `response_format` parameter (causes "Unknown parameter" error)
- Does NOT return a `url` field

**Correct usage:**
```bash
curl -s --max-time 240 "https://api.openai.com/v1/images/generations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{"model": "gpt-image-1", "prompt": "...", "n": 1, "size": "1024x1024"}' \
  | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
with open('output.png', 'wb') as f:
    f.write(base64.b64decode(data['data'][0]['b64_json']))
"
```

## Nano Banana Pro Script Path

The generate script is at:
```
~/.hermes/skills/creative/nano-banana-pro/scripts/generate_image.py
```
NOT at `~/skills/nano-banana-pro/scripts/generate_image.py` (which doesn't exist).

## Higgsfield Model IDs

Exact model IDs (from `higgsfield model list`):
- `marketing_studio_image` (not `marketing_studio`)
- `seedream_v4_5` (not `seedream_4_5`)
- `gpt_image_2` (Higgsfield's wrapper, different from direct OpenAI API)

Always run `higgsfield model list` if unsure about the exact ID string.

## Ad Library API Authorization (2026-05-10)

The `ads_archive` endpoint returns error code 10, subcode 2332002: "Application does not have permission for this action."

This requires separate registration at `facebook.com/ads/library/api`. Until that's done, fall back to:
1. Web search for "[competitor name] facebook ads 2026"
2. Firecrawl scrape of the public Ad Library web pages (may fail on JS-heavy rendering)

## Archived Ads Cannot Be Edited (2026-05-10)

If you try to pause an already-archived ad, you get: "Archived Ads Can't Be Edited" (code 100, subcode 1885088). Only `name` can be edited. Skip archived ads in the kill loop.
