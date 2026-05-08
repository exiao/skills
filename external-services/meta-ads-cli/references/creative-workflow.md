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

**Design requirements:**
- 1080×1080 pixels (square for feed)
- Bloom brand colors: `#28B5BD` teal, `#0f172a` navy, `#F5A623` amber
- High contrast, thumb-stopping in 0.5s
- Bloom logo: 3 teal circles (light top-right, medium left, dark small bottom-right)

**Logo usage:** Only include the Bloom logo when the concept calls for it (e.g. a branded card, CTA panel). Many formats (fake notifications, mock apps, memes) work better without a logo. When you DO include it:

- Nano Banana Pro: pass `-i {baseDir}/assets/bloom-logo.png` as reference so the model sees the real logo
- gpt-image-2: composite the real logo onto the output after generation using PIL/Pillow (don't ask the model to draw it)
- Higgsfield: include the logo description in the prompt ("three teal circles arranged as the Bloom logo: large light-teal top-right, medium teal left, small dark-teal bottom-right"). Composite the real logo after if result is inaccurate.

The logo reference file lives at: `{baseDir}/assets/bloom-logo.png` (1024×1024 PNG)

**Output filename:** Use a short slug describing the format:
- Pattern: `creative-N-<format-slug>.png` (e.g. `creative-1-whatsapp-chat.png`, `creative-3-weather-card.png`)
- Slug: 2–3 words, lowercase, hyphenated. Makes files scannable without opening them.

#### 5e — Save Manifest

Write `ads/iteration/creatives/$(date +%Y-%m-%d)/manifest.md` with format/hook/concept table. Use the labeled filenames (with slug) in the File column.


#### 5f — Visual QA Gate (MANDATORY)

After generating each creative, run a vision inspection on the output image. Check for:

1. **Text legibility** — all text must be fully readable, correctly spelled, no garbled/mangled characters
2. **No wrong logos** — if a logo is present, it must be correct (three teal circles). A missing logo is fine. A WRONG logo (feather, four circles, garbled shape, competitor brand) is a hard fail.
3. **AI artifacts** — no distorted UI elements, no hallucinated brand logos, no nonsense text

```
For each generated creative image:
  - Use the vision tool to inspect the image
  - Ask: "Is all text legible and correctly spelled? If any logo is shown, is it correct (three teal circles, not a feather or garbled)? Any AI artifacts or wrong brand logos?"
  - If FAIL: regenerate with a more explicit prompt (add "IMPORTANT: spell all words correctly, no typos")
  - If second attempt also FAIL: skip this creative, do not upload it
  - Only upload creatives that PASS the visual QA gate
```

**Hard rule:** Never upload a creative with misspelled text or a WRONG logo. Missing logo is fine — wrong logo is not. One bad ad damages brand credibility more than no ad at all.

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

⚠️ **If any API call returns an error with `payment` or `billing`: STOP and notify the account owner.**

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
