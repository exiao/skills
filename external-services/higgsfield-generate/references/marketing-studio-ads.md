# Marketing Studio — Ad Production Reference

**Source:** https://higgsfield.ai/marketing-studio-intro

## Core Concept

Marketing Studio generates publish-ready marketing videos from a single prompt. No filming, no crew, no post-production. Works for physical products and digital apps. Paste any product/app URL and get a tailored ad.

## Workflow (4 Steps)

1. **Add product** — Paste URL (auto-extracts name, description, images) or upload up to 5 images
2. **Pick avatar** — 40+ in library or generate custom via Soul 2.0 text prompt
3. **Choose mode** — UGC, Professional, or General direction
4. **Generate** — Ad-ready video, no post-production needed

## 10 Creative Modes

| Mode | Slug | Description | Best For |
|------|------|-------------|----------|
| TV Spot | `tv_spot` | Broadcast-ready cinematic, camera work, real-world locations, story arcs | Brand campaigns |
| UGC (Talking Head) | `ugc` | Face-to-camera reviews, selfie framing, natural speech, iPhone-style | Social ads, TikTok/Reels |
| Tutorial | `ugc_how_to` | Step-by-step how-to, casual TikTok-style, talk + demonstrate | Educational content |
| Product Review | `product_review` | Close-up hands-on footage, natural voiceover, shot on phone | Trust-building |
| Unboxing | `ugc_unboxing` | Package arrives, tape rips, product revealed, first-touch reaction | Product launches |
| UGC Virtual Try-On | `ugc_virtual_try_on` | Try-on haul, person wearing product, posing, reacting | Fashion/apparel |
| Pro Virtual Try-On | `virtual_try_on` | Cinematic tracking shots, editorial posing, urban architecture | Premium fashion |
| Hyper Motion | `product_showcase` | Pure CGI commercial, dynamic camera, premium lighting, VFX, no people | Product hero videos |
| Wild Card | `wild_card` | Describe a scenario, AI directs everything. Most creative, least input | Experimental |

**Three production tiers:** Authentic UGC (social), CGI-grade commercials (brand), Cinematic narrative (campaigns)

## Key Features

### URL to Ad
Fastest path from product page to finished ad. Drop URL → select creative direction + avatar → Studio handles script, shots, camera, edit.

### Ad Reference
Upload a reference ad + attach your product and avatar. AI analyzes the structure, writes the script. Same format, your brand, your face.

**How it works:**
1. Upload your top-performing video (or a competitor's viral ad)
2. Pass the upload ID as `--ad_reference_id` to `marketing_studio_video`
3. Marketing Studio recreates the format with your product and avatar

```bash
# 1. Upload reference video
higgsfield upload create ./top-performing-ad.mp4 --json
# Returns upload_id

# 2. Generate new ad using that reference
PRODUCT_IDS_JSON=$(mktemp)
printf '["<product_id>"]' > "$PRODUCT_IDS_JSON"

higgsfield generate create marketing_studio_video \
  --prompt "Recreate this ad format for Bloom AI investing app" \
  --ad_reference_id "<upload_id_or_job_id>" \
  --product_ids @"$PRODUCT_IDS_JSON" \
  --mode ugc \
  --duration 15 \
  --resolution 1080p \
  --aspect_ratio 9:16 \
  --wait --json
```

**Use cases for Bloom ads:**
- Feed in your best-performing Meta/Google ad → generate variations
- Feed in a competitor's viral ad → recreate with Bloom branding
- A/B test the same ad format with different avatars or hooks
- Scale winning formats across platforms (Meta → TikTok → YouTube)

### Scroll-Stopping Hooks
First 3 seconds decide if ad gets watched. Pick a proven opener → Studio builds the rest around your product. Browse with:
```bash
higgsfield marketing-studio hooks list --json
```

### Settings (Locations/Vibes)
Reusable scene contexts. Browse with:
```bash
higgsfield marketing-studio settings list --json
```

## CLI Workflow for Ad Generation

```bash
# 1. Import product from URL
higgsfield marketing-studio products fetch --url "https://apps.apple.com/app/id..." --wait

# 2. Browse avatars
higgsfield marketing-studio avatars list --json

# 3. Browse hooks (optional)
higgsfield marketing-studio hooks list --json

# 4. Generate video
PRODUCT_IDS_JSON=$(mktemp)
AVATARS_JSON=$(mktemp)
printf '["<product_id>"]' > "$PRODUCT_IDS_JSON"
printf '[{"id":"<avatar_id>","type":"preset"}]' > "$AVATARS_JSON"

higgsfield generate create marketing_studio_video \
  --prompt "Young investor discovers AI-powered stock recommendations on their phone" \
  --avatars @"$AVATARS_JSON" \
  --product_ids @"$PRODUCT_IDS_JSON" \
  --mode ugc \
  --duration 15 \
  --aspect_ratio 9:16 \
  --wait --json

# 5. Generate marketing image
higgsfield generate create marketing_studio_image \
  --prompt "Clean app ad showing Bloom AI investing interface" \
  --aspect_ratio 1:1 \
  --resolution 2k \
  --wait --json
```

## Mode Selection for Bloom Ads

| Goal | Recommended Mode | Why |
|------|-----------------|-----|
| Meta/IG feed ad | `ugc` | Feels native to social, highest engagement |
| Google App Campaign | `product_showcase` | Clean, professional, no person needed |
| TikTok ad | `ugc` or `ugc_how_to` | Tutorial-style performs well on TikTok |
| YouTube pre-roll | `tv_spot` | Cinematic quality for 15-30s slots |
| App Store preview | `product_showcase` | Shows the app, no distracting avatar |
| Experimental/viral | `wild_card` | Let AI surprise you |

## Video Engine: Seedance 2.0

- Generates motion, audio, and speech in a single pass
- Native lip-sync, physics-aware movement
- Consistent characters across shots
- Powers all formats from iPhone-style UGC to full CGI

## Pricing Context

The account owner has a Creator subscription. Credit costs vary by model:
- 1,000 credits ≈ 500 Nano Banana Pro images ≈ ~114 Kling 3.0 videos
- Marketing Studio videos cost more credits than static images
- Check balance: `higgsfield account status`
