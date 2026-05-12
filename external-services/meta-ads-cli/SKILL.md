---
name: meta-ads-cli
preloaded: true
description: Daily Meta ad operations via Marketing API — competitor research via Ad Library, check performance, kill losers, promote winners, generate 6 fresh creatives via Nano Banana Pro + gpt-image-2 + Higgsfield MCP, upload as new ads, and report to Signal. Runs as cron at 2am ET.
---

# Meta Ads Iteration

Daily 4am routine: audit running ads via Meta Marketing API, kill underperformers, boost winners, generate 6 brand-new creative concepts (never repeating a used hook/format combo), upload them as new ads via API, and report to Signal.

---

## API Credentials

```bash
TOKEN=$META_ACCESS_TOKEN           # Meta Marketing API token
ACCOUNT="$BLOOM_AD_ACCOUNT_ID"    # Bloom ad account (act_...)
GRAPH_URL="https://graph.facebook.com/v22.0"
PAGE_ID="$BLOOM_PAGE_ID"           # Facebook Page ID
INSTAGRAM_ID="$BLOOM_INSTAGRAM_ID" # Instagram user ID for creatives
IOS_APP_LINK="http://itunes.apple.com/app/id${BLOOM_APP_STORE_ID}"
ANDROID_APP_LINK="http://play.google.com/store/apps/details?id=$ANDROID_PACKAGE_NAME"
ADSET_IOS="$BLOOM_IOS_ADSET_ID"       # General, iOS (ACTIVE)
ADSET_ANDROID="$BLOOM_ANDROID_ADSET_ID"   # General, Android (ACTIVE)
# All BLOOM_* vars set in gateway env.
```

---

## Tools

| Tool | Purpose |
|------|---------|
| `curl` + Meta Marketing API v22.0 | All ad management (read, pause, budget, create) |
| `curl` + Meta Ad Library API | Competitor creative research |
| `higgsfield` CLI | Higgsfield AI image generation (seedream, gpt_image_2, marketing_studio_image) |
| `trend-research` skill | Find what investing/finance content is trending today |
| `web-search` skill | Serper for trending finance content |
| `nano-banana-pro` skill | Generate 1080×1080 ad creatives |
| Reply output | Report + creative summaries (cron delivery handles Signal routing) |

---

## Workflow

### Step 1 — Get Performance Data

```bash
# Get all ads with status
curl -sG "$GRAPH_URL/$ACCOUNT/ads" \
  --data-urlencode "fields=id,name,status,effective_status,adset_id" \
  --data-urlencode "access_token=$TOKEN"

# Get insights for last 7 days (use last_30d if an ad is newer)
curl -sG "$GRAPH_URL/$ACCOUNT/insights" \
  --data-urlencode "fields=ad_id,ad_name,impressions,reach,clicks,spend,cpm,ctr,actions,cost_per_action_type,action_values,purchase_roas" \
  --data-urlencode "date_preset=last_7d" \
  --data-urlencode "level=ad" \
  --data-urlencode "access_token=$TOKEN"
```

Save to `ads/iteration/$(date +%Y-%m-%d)_performance.md`:
- ad_id, name, impressions, spend, CPM, CTR, clicks
- `actions` and `cost_per_action_type`, especially `app_store_visit`, `mobile_app_install`, `app_install`, `omni_app_install`, `purchase`, `omni_purchase`
- `action_values` / `purchase_roas` when present so ROAS can be calculated. If Meta returns no install/purchase values, explicitly say ROAS is unavailable instead of inventing it.

### Step 2 — Classify Ads

Only classify ads with **1,000+ impressions** (insufficient data below this).
Ads with <1,000 impressions are still ramping — never kill or score them.

Calculate median CPM across all qualifying ads.

Also calculate a composite score for every qualifying ad:
1. Normalize each available metric across qualifying ads to 0-1.
2. Lower CPM is better, higher CTR is better, higher ROAS is better.
3. If ROAS is available: `score = 0.40 * roas_norm + 0.30 * cpm_norm + 0.30 * ctr_norm`.
4. If ROAS is unavailable for an ad: fall back to `score = 0.50 * cpm_norm + 0.50 * ctr_norm`.
5. Report the score, but do not let a score alone kill an ad. The kill guardrail below still applies.

| Decision | Criteria |
|----------|----------|
| **KILL** | CPM > 2× median CPM, OR CTR < 0.5% (among ads with 1,000+ imps only) |
| **PROMOTE** | CPM < 0.7× median CPM AND CTR > 2% |
| **KEEP** | Everything else |

Save decisions to `ads/iteration/$(date +%Y-%m-%d)_decisions.md` and include score, spend, and ROAS (or `n/a`).

### Step 3 — Kill Losers

```bash
# Pause a specific ad
curl -s -X POST "$GRAPH_URL/$AD_ID" \
  -F "status=PAUSED" \
  -F "access_token=$TOKEN"
```

Log each kill to `ads/iteration/$(date +%Y-%m-%d)_kills.log`.

### Step 4 — Promote Winners

```bash
# Increase ad set daily budget (in cents — $6/day = 600)
# Get current adset budget first, then increase by $2
CURRENT_BUDGET=$(curl -sG "$GRAPH_URL/$ADSET_ID" \
  --data-urlencode "fields=daily_budget" \
  --data-urlencode "access_token=$TOKEN" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['daily_budget'])")
NEW_BUDGET=$((CURRENT_BUDGET + 200))
curl -s -X POST "$GRAPH_URL/$ADSET_ID" \
  -F "daily_budget=$NEW_BUDGET" \
  -F "access_token=$TOKEN"
```

Log each promotion to `ads/iteration/$(date +%Y-%m-%d)_promotions.log`.

### Step 4.5 — Competitor Ad Library Research

Research what competitors are running on Meta to inform creative ideation.

**Preferred method: Meta Ad Library API**
Query `/$GRAPH_URL/ads_archive` with `search_terms`, `ad_reached_countries=US`, active ads, and fields like `page_name`, `ad_delivery_start_time`, `ad_creative_bodies`, `ad_creative_link_titles`, `ad_snapshot_url`.

If the API returns OAuth code `10` / subcode `2332002` ("Application does not have permission" / "Authorization and login needed"), treat it like an Ad Library auth failure: do **not** attempt browser login. Fall back to public web search for competitor ad examples and note the API limitation in the report. If it returns 403, do the same.

**Fallback method: Scrape public Ad Library via firecrawl**
```bash
# Scrape competitor ads from the public Meta Ad Library (JS-heavy, needs wait)
# Key competitors: Robinhood, Acorns, Wealthfront, Public, Stash, SoFi
firecrawl scrape --wait-for 5000 "https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=robinhood"
firecrawl scrape --wait-for 5000 "https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=acorns%20investing"
firecrawl scrape --wait-for 5000 "https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=wealthfront"
firecrawl scrape --wait-for 5000 "https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=sofi%20invest"
firecrawl scrape --wait-for 5000 "https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=public.com%20investing"
```

Extract from each page: ad copy text, creative descriptions, start dates, and any visible format patterns.

**Analyze and save to `ads/iteration/$(date +%Y-%m-%d)_competitor_research.md`:**

1. **Longest-running ads** (oldest `ad_delivery_start_time`) = proven winners. Note their hooks, formats, CTAs.
2. **Newest ads** (last 7 days) = what competitors are testing now. Note emerging patterns.
3. **Hook patterns** — extract the first line of each `ad_creative_bodies`. Group by type (question, stat, pain point, social proof).
4. **Format patterns** — what visual styles dominate? (UGC, product shots, charts, testimonials, memes)
5. **Gaps** — what are competitors NOT doing that Bloom could own?

**Output a brief (10-15 line) summary with:**
- Top 3 competitor patterns to remix
- Top 2 gaps/opportunities
- 1 format to explicitly avoid (oversaturated)

This feeds directly into Step 5c ideation.

---

### Step 4.75 — Capacity Preflight Before Creative Generation

Before spending time or tokens on new image generation, check whether both target ad sets have room for a full paired upload. Meta's max-ad limit includes paused/inactive ads, not just active ads, so the active count is not enough.

1. Pull account-level ads with `fields=id,name,status,effective_status,adset_id,created_time`.
2. Count non-archived ads in `$ADSET_IOS` and `$ADSET_ANDROID`.
3. Each new creative needs one iOS slot and one Android slot.
4. If either ad set lacks enough room for the intended batch, stop before generating images and report that old ads must be archived or fresh ad sets created.

Do not create an iOS-only or Android-only partial rollout. If capacity is unclear, assume unsafe and stop before upload.

### Step 5 — Generate New Creatives (4-Phase Process)

#### 5a — Build Exclusion List

Audit all `ads/iteration/creatives/*/manifest.md` files. Build list of used `hook_type + format + concept` combos. No repeats.

#### 5b — Read Learnings File

Read `ads/iteration/learnings.md` before ideation. This file contains:
- Permanent creative principles (what works on Meta)
- Account-specific patterns (what has worked/failed for Bloom)
- Run log from previous days

Use these insights to inform concept selection. Double down on documented winners. Avoid documented losers.

#### 5c — Research and Ideation (Phase 1: 5 Concepts)

Use these skills to generate concepts:
- **competitor research** (from Step 4.5) — remix proven competitor hooks, exploit gaps they're missing
- **trend-research** — what is viral in investing/fintech right now
- **web-search** — trending finance content today
- **hooks** — generate scroll-stopping openers
- **meta-ads-creative** — 6 Elements framework, proven ad formats
- **content-strategy** — angles from what is working on social

Come up with **5 distinct concepts**. Each concept needs:
- A hook (the first thing someone reads/sees)
- A format (what it looks like visually)
- A payload (what the ad actually communicates about Bloom)
- Why it should work (reference trend data, competitor intel, or historical performance)
- Competitor context (is this remixing a proven competitor pattern, exploiting a gap, or testing something novel?)

Analyze what has historically performed best on this account (from Step 1 data). Double down on winning patterns (formats, tones, hooks that got low CPM + high CTR). At least 1 concept must be a direct remix of a top competitor pattern. At least 1 must exploit an identified gap.

#### 5d — Visual Exploration (Phase 2: 25 ASCII Mockups)

For each of the 5 concepts, create **5 different visual mockup variations using ASCII art**. These are rough layout sketches showing:
- Where text goes
- What the visual hierarchy looks like
- Phone mockup framing (if applicable)
- Where the hook text sits
- Whether it uses a logo or not

Output all 25 as text-based ASCII layouts. This is cheap exploration before expensive image generation.

#### 5e — Selection (Phase 3: Pick Top 5)

From all 25 ASCII mockups, select the **top 5** based on:
1. Historical performance patterns from this account (what formats/hooks got best composite scores)
2. Scroll-stopping potential (would YOU stop scrolling?)
3. Concept clarity (is the message obvious in 0.5 seconds?)
4. Novelty vs exclusion list (not a repeat)
5. Trend alignment (timely, relevant)

Explain why each was picked.

#### 5f — Image Generation (Phase 4: Create Final Creatives)

Generate the 5 selected creatives using the dual-model flow:

**Available formats:**
iOS Notes App screenshot, Reddit post mockup, Twitter/X screenshot, Meme comparison, Testimonial card, Dark stat card, Text-over-chart, Founder video caption card, News headline mockup, App Store screenshot mock, Bold typographic, Phone mockup, WhatsApp group chat, Court/legal parody, Weather app card, Bank statement, Review split card, CVS receipt, Glassdoor card, Earnings card

#### 5d — Generate Each Creative (Tri-Model Variance)

Alternate between **Nano Banana Pro** (Gemini), **gpt-image-2** (OpenAI), and **Higgsfield** (marketing_studio_image/seedream) for visual variety. Split: 2 each (Nano Banana: 1, 4; gpt-image-2: 2, 5; Higgsfield: 3, 6).

**Nano Banana Pro (creatives 1, 4):**
```bash
GEMINI_API_KEY=$(python3 -c "import json, os; d=json.load(open(os.path.expanduser('~/.openclaw/openclaw.json'))); print(d.get('skills',{}).get('entries',{}).get('nano-banana-pro',{}).get('apiKey','') or d['env']['vars'].get('GEMINI_API_KEY',''))" 2>/dev/null)
export GEMINI_API_KEY

uv run ~/.hermes/skills/creative/nano-banana-pro/scripts/generate_image.py \
  --prompt "..." \
  --filename "ads/iteration/creatives/$(date +%Y-%m-%d)/creative-N-<format-slug>.png" \
  --resolution 2K
```

**gpt-image-2 (creatives 2, 5):**
```bash
curl -s -X POST "https://api.openai.com/v1/images/generations" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-image-2","prompt":"...","n":1,"size":"1024x1024","quality":"high"}' \
  > /tmp/gpt_img.json

python3 -c "
import json, base64
with open('/tmp/gpt_img.json') as f: d = json.load(f)
assert 'error' not in d, d['error']['message']
with open('OUTPUT_PATH', 'wb') as f: f.write(base64.b64decode(d['data'][0]['b64_json']))
"
```
Replace `OUTPUT_PATH` with `ads/iteration/creatives/$(date +%Y-%m-%d)/creative-N-<format-slug>.png`.

**Higgsfield (creatives 3, 6):**
```bash
# Generate via Higgsfield CLI — use seedream_v5_lite for text-only prompts,
# gpt_image_2 for graphic design/typography
higgsfield generate create seedream_v5_lite \
  --prompt "..." \
  --aspect_ratio 1:1 \
  --wait --json

# Result prints the URL on stdout. Download it:
curl -s -o "ads/iteration/creatives/$(date +%Y-%m-%d)/creative-N-<format-slug>.png" "<result_url>"
```

For Higgsfield, prefer:
- `gpt_image_2` — graphic design, UI, banners, typography, high-fidelity general generation (default)
- `seedream_v5_lite` — photorealistic lifestyle scenes, fast and cheap
- `seedream_v4_5` — higher quality alternative, vector illustrations, face edits
- `marketing_studio_image` — polished product shots, app screenshots, professional ad-ready output (requires product/avatar setup)

Use `--wait` to block until done. Add `--json` for machine-readable output.
If auth fails (`Session expired`), skip Higgsfield creatives and fall back to extra Nano Banana Pro / gpt-image-2 creatives.

**Model strengths (assign concepts accordingly):**
- Nano Banana Pro: text-heavy formats (Reddit posts, tweets, notes app), clean typography, flat design
- gpt-image-2: photorealistic scenes, dramatic lighting, meme compositions, phone mockups, charts
- Higgsfield: product/app ad creatives, UGC-style content, professional lifestyle scenes, polished marketing materials

**UGC/video note:** For video creatives, prefer reference-first generation. Use a winning ad or competitor video as Ad Reference, then generate Bloom variants through `marketing_studio_video --ad_reference_id`. See `higgsfield-generate/references/reference-video-and-postprocessing.md` for first-frame, motion-transfer, and anti-AI post-processing guidance.

**Design requirements:**
- 1080×1080 pixels (square for feed)
- Bloom brand colors: `#28B5BD` teal, `#0f172a` navy, `#F5A623` amber
- High contrast, thumb-stopping in 0.5s
- Bloom logo: 3 teal circles (light top-right, medium left, dark small bottom-right)

**Logo usage:** Only include the Bloom logo when the concept calls for it (e.g. a branded card, CTA panel). Many formats (fake notifications, mock apps, memes) work better without a logo. When you DO include it, do not trust the image model to draw the logo correctly:

- Preferred: composite the real logo from `{baseDir}/assets/bloom-logo.png` onto the final PNG with PIL/Pillow, SVG, or canvas.
- Nano Banana Pro: you may pass `-i {baseDir}/assets/bloom-logo.png` as reference, but still inspect the final logo against the reference asset.
- gpt-image-2: composite the real logo after generation. Do not ask the model to draw it.
- Higgsfield: composite the real logo after generation. Prompted logo descriptions are not enough.
- If a generated background includes a fake/wrong Bloom logo, mask/crop it out or regenerate before compositing the real logo.

The canonical logo reference file lives at: `{baseDir}/assets/bloom-logo.png` (1024×1024 PNG). It is three teal circles: medium teal left, large light-teal top-right, small dark-teal bottom-right. Any feather/leaf/checkmark, four-circle cluster, garbled blob, or different geometry is the wrong logo.

**Output filename:** Use a short slug describing the format:
- Pattern: `creative-N-<format-slug>.png` (e.g. `creative-1-whatsapp-chat.png`, `creative-3-weather-card.png`)
- Slug: 2–3 words, lowercase, hyphenated. Makes files scannable without opening them.

#### 5e — Save Manifest

Write `ads/iteration/creatives/$(date +%Y-%m-%d)/manifest.md` with format/hook/concept table. Use the labeled filenames (with slug) in the File column.


#### 5f — Visual QA Gate (MANDATORY)

After generating each creative, run a vision inspection on the output image. Check for:

1. **Text legibility** — all text must be fully readable, correctly spelled, no garbled/mangled characters
2. **Logo accuracy against canonical asset** — if a logo is present, compare it to `{baseDir}/assets/bloom-logo.png`. It must be the Bloom mark: exactly three teal circles, medium teal left, large light-teal top-right, small dark-teal bottom-right. Missing logo is fine. Wrong logo is a hard fail: feather/leaf/checkmark, four circles, garbled blob, off-brand geometry, competitor brand, or any model-invented symbol.
3. **AI artifacts** — no distorted UI elements, no hallucinated brand logos, no nonsense text

```
For each generated creative image:
  - Use the vision tool to inspect the image
  - Ask: "Is all text legible and correctly spelled? If any logo is shown, compare it to the canonical Bloom logo reference: exactly three teal circles (medium teal left, large light-teal top-right, small dark-teal bottom-right). Is the logo correct, or is it a feather/leaf/checkmark/four-circle cluster/garbled/model-invented mark? Any AI artifacts or wrong brand logos?"
  - If FAIL: regenerate with a more explicit prompt (add "IMPORTANT: spell all words correctly, no typos, no fake logos")
  - If second attempt also FAIL: skip this creative, do not upload it
  - Only upload creatives that PASS the visual QA gate
```

**Hard rule:** Never upload a creative with misspelled text or a wrong Bloom logo. Missing logo is fine. A model-generated fake logo is not close enough, even if it is teal or vaguely circular. One bad ad damages brand credibility more than no ad at all.

**Reliable text/logo workaround:** For text-heavy static ads, generate a text-free or low-text background with Nano Banana / gpt-image-2 / Higgsfield, then render final ad copy, CTA, disclaimer, and Bloom logo deterministically with SVG/HTML/canvas/PIL instead of asking the image model to spell. This preserves tri-model visual variety while making the QA gate much easier to pass. If capacity is blocked, image models are slow, or model auth is flaky, deterministic PIL/SVG cards are an acceptable fallback execution path as long as the manifest records the intended model slot and final images pass vision QA. If PIL/Pillow is unavailable, SVG + `rsvg-convert` works for logo/card overlays.

#### 5h — Append to Learnings File

After generating and QA-ing creatives, append a brief entry to `ads/iteration/learnings.md`:

```
## [date] Run Summary
- Top performer from data: [ad name, format, why it worked]
- Killed: [what and why]
- New concepts tried: [list formats/hooks]
- New insight: [anything learned about what works/doesn't]
```

Keep entries to 3-5 lines. This builds institutional memory across runs.

### Step 6 — Upload New Ads via API

For each of the 6 creatives, run this 3-step sequence:

**Step 6a: Upload image**
```bash
UPLOAD=$(curl -s -X POST "$GRAPH_URL/$ACCOUNT/adimages" \
  -F "filename=@/path/to/creative-N.png" \
  -F "access_token=$TOKEN")

IMAGE_HASH=$(echo $UPLOAD | python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d['images'].values())[0]['hash'])")
```

**Step 6b: Create ad creative**
```bash
CREATIVE=$(curl -s -X POST "$GRAPH_URL/$ACCOUNT/adcreatives" \
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
curl -s -X POST "$GRAPH_URL/$ACCOUNT/ads" \
  -F "name=Bloom $(date +%Y-%m-%d) Creative N" \
  -F "adset_id=$ADSET_IOS" \
  -F "creative={\"creative_id\": \"$CREATIVE_ID\"}" \
  -F "status=ACTIVE" \
  -F "access_token=$TOKEN"
```

Repeat 6a-6c for Android ad set (`$ADSET_ANDROID`) using the Android app link, so each creative gets two ads (iOS + Android).

⚠️ **If any API call returns an error with `payment` or `billing`: STOP and notify the account owner.**

⚠️ **If ad creation returns Meta error `1487809` / "Too Many Ads" (ad set/campaign/account max ads, including paused/inactive ads): STOP uploading immediately and report it.** Do not partially roll out iOS-only or Android-only ads. Log whether an image upload, ad creative object, or ad object was already created, then tell the account owner the ad set needs cleanup or a fresh ad set before new ads can launch. If the local upload log is empty but the failure happened after creative creation, verify recent `/adcreatives` before saying nothing was created.

### Step 7 — Output Report

Do NOT send via the message tool. Just output the report as your reply. Cron delivery handles routing to Signal (Marketing group).

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

## Ad Creative Framework and Iteration Log

Load `references/ad-creative-framework.md` when generating new creatives, updating the exclusion list, or reviewing prior creative iteration history.

## Delivery

- Signal group: `$SIGNAL_MARKETING_GROUP` — cron delivery handles routing, do NOT send via message tool
- Performance log: `ads/iteration/[date]_performance.md`
- Kills log: `ads/iteration/[date]_kills.log`
- Promotions log: `ads/iteration/[date]_promotions.log`
- Creatives: `ads/iteration/creatives/[date]/creative-N-<format-slug>.png`
- Manifest: `ads/iteration/creatives/[date]/manifest.md`

---

## Cron Config

- **ID:** `$META_ADS_CRON_ID`
- **Schedule:** `0 4 * * *` (4am ET, daily)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## ⚠️ CRITICAL: API Only — Never Browser Login

**NEVER attempt to log into Meta Ads Manager or Facebook via browser.** Browser login can trigger a security lockout on the ad account. All Meta ad management must go through the Marketing API only (`graph.facebook.com/v22.0`).

If the API returns `code=31` ("pending action" / security hold), **stop and notify the account owner** — he must resolve it manually from his own browser. Do not attempt browser automation to fix it.

Always use `$BLOOM_APP_STORE_ID` for iOS ad links (the current App Store ID). The adset's `promoted_object.object_store_url` is the ground truth — verify it matches before creating creatives.

## Attribution: Click-to-WhatsApp / Bloombot

For campaigns that send users into Bloombot's WhatsApp Business number, load `references/click-to-whatsapp-bloombot.md` before setup or optimization. Key rule: judge by cost per qualified conversation, not cost per message. Capture CTWA webhook metadata (`ctwa_clid`, `source_id`, referral headline/body/media, prefill text) on first inbound message, then send CAPI events back to Meta: Lead = qualified conversation, Subscribe/CompleteRegistration = recurring opt-in, Purchase = paid subscription. Do not scale conversation optimization without downstream quality data, or Meta will find cheap bored tappers.

## Attribution: Custom Product Pages

For iOS app campaigns, use Apple Custom Product Pages (CPPs) as the ad destination instead of the default App Store listing. Each CPP gets tracked separately in App Store Connect analytics, giving you exact revenue per ad/campaign with zero SDK complexity.

**How:** Create a CPP in App Store Connect, get its unique URL, and use it as the `object_store_url` in the ad's `promoted_object` (or set it at the ad level via `url_tags` / deep link).

**The 30% rule:** CPP-attributed revenue undercounts by ~30%. Users who see the ad but search the App Store directly won't be attributed. Factor this into ROAS calculations.

**Limit:** 35 CPPs per app. Allocate one per ad set or creative theme. This is the most reliable iOS attribution method post-ATT since it's deterministic and server-side (Apple tracks it, not an SDK).

## Common Mistakes

See also `references/2026-05-09-run-pitfalls.md` for concrete API error payloads and the deterministic text-overlay workaround from a real run. Load `references/operational-pitfalls.md` when debugging app link mismatches, creative-limit errors, missing ad objects, or production API responses that don't match the happy path. Load `references/2026-05-11-run-pitfalls.md` when handling max-ad capacity, orphaned ad creative objects, wrong/ambiguous Bloom logos, failed creative-pack repair, or deciding whether to generate creatives before upload capacity is known.

1. **Token not set** — always use `$META_ACCESS_TOKEN` from env. Never hardcode.
2. **Cron scanner false positives** — this skill is loaded into scheduled cron prompts, and Hermes scans the fully assembled prompt before execution. Avoid single-line examples where `curl` contains `$API`, `$TOKEN`, `$KEY`, `$SECRET`, or similar on the same line. Use neutral variable names like `GRAPH_URL` instead of `API`, and put auth form fields or headers on continuation lines. Verify with `tools.cronjob_tools._scan_cron_prompt(skill_text)` after editing.
3. **Wrong budget units** — daily_budget is in cents. $5/day = 500, $6/day = 600.
3. **Repeating a hook/format/concept combo** — always audit exclusion list first.
4. **Forgetting Android ad set** — each creative should get two ads (iOS + Android ad sets).
5. **Not checking impressions threshold** — don't classify ads with <1000 impressions.
6. **Missing GEMINI_API_KEY** — resolve from openclaw.json before Nano Banana Pro.
7. **Not sending creative images** — Signal report must include all 6 images.
8. **Forgetting the manifest** — required for future exclusion list audits.
9. **Wrong App Store URL** — always use `$BLOOM_APP_STORE_ID` for ad links. Verify against adset `promoted_object.object_store_url`.
10. **Higgsfield auth expired** — if `higgsfield account status` shows `Session expired`, skip Higgsfield creatives. Don't attempt browser login. Alert in report.
11. **Skipping competitor research** — Step 4.5 must run before ideation. Without it, creatives are generated in a vacuum.
12. **Firecrawl fails on Ad Library** — if firecrawl can't scrape the page (JS-heavy rendering), fall back to web search for "[competitor] facebook ads 2026" and extract what you can.
13. **Ad Library API auth failure is not always 403** — OAuth code `10` / subcode `2332002` also means the app lacks Ad Library API authorization. Skip browser login, fall back to web search, and report the limitation.
14. **Ad set max-ad limit** — Meta error `1487809` / "Too Many Ads" means the ad set/campaign/account hit the 50-ad limit including paused/inactive ads. Check capacity before generating creatives, using account-level ads and non-archived counts by target ad set. Stop uploading and report cleanup/fresh-ad-set needed. Do not create a partial platform rollout.
15. **Image-model text risk** — for text-heavy ad cards, render final text and logo deterministically over generated backgrounds with SVG/canvas. This avoids misspellings while preserving visual variety.

## Constitutional Rules
- NEVER pause or kill an ad without reporting which ad, current spend, and ROAS first.
- NEVER increase budgets by more than 20% in a single action without confirmation.
- Always report what you changed after, not just what you plan to change.
