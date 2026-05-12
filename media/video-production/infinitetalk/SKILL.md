---
name: infinitetalk
description: Generate a talking avatar video from a character image + audio file using InfiniteTalk via Fal.ai. Lip-syncs the audio to the character with full-body animation.
---

# InfiniteTalk

Animates a static character image to lip-sync + body-animate to an audio file. Runs via Fal.ai — cloud API, no GPU needed.

**API:** Fal.ai (`FAL_KEY` env var)
**Model ID:** `fal-ai/infinitalk` (image + audio → video)

---

## Quick Usage

```bash
uv run ~/clawd/skills/video-production/infinitetalk/scripts/generate_video.py \
  --image ~/clawd/characters/max/face-ref-2026-03-03.png \
  --audio ~/clawd/characters/max/audio/2026-03-03-episode-1.mp3 \
  --prompt "A confident financial analyst explaining a market insight, expressive but composed" \
  --output ~/clawd/characters/max/videos/2026-03-03-episode-1.mp4
```

---

## Parameters

| Flag | Required | Default | Notes |
|------|----------|---------|-------|
| `--image` | ✅ | — | Local path or URL to character image (PNG/JPG) |
| `--audio` | ✅ | — | Local path or URL to audio file (MP3/WAV) |
| `--prompt` | ✅ | — | Expression/behavior guide for the avatar |
| `--output` | — | `~/clawd/output/infinitetalk-<timestamp>.mp4` | Output MP4 path |
| `--resolution` | — | `720p` | `480p` or `720p` |
| `--acceleration` | — | `regular` | `none`, `regular`, or `high` |

---

## Prompt Tips

The prompt guides how the character moves and expresses — not what they say (that's from the audio).

Good prompts:
- `"A confident investor making a key point, direct eye contact, subtle hand gestures"`
- `"An energetic young analyst reacting to market news, expressive face"`
- `"A calm financial educator, measured delivery, slight nods"`

Bad prompts: vague descriptions like "a person talking" give generic results.

---

## Output

Prints the saved path on completion:
```
VIDEO: ~/clawd/characters/max/videos/2026-03-03-episode-1.mp4
```

---

## Pricing (via Fal.ai)

Billed per generation. A ~60-second video at 720p ≈ $0.20-0.50 depending on frame count.
- 145 frames (default) ≈ ~5 seconds of video. For longer scripts, increase `--frames`.
- Max frames: 721. For a 60-second script, audio length drives output length automatically.

---

## Setup

```bash
pip install fal-client
export FAL_KEY="your_key_here"
```

---

## In the Pipeline

1. Create character → `character-creation` skill (generates `face-ref.png`)
2. Write script → `content-strategy` (Video Series section)
3. Generate audio → `elevenlabs` sub-skill (generates `.mp3`)
4. **Generate video → this skill** (takes image + audio → MP4)
5. Schedule → PostBridge MCP (see below)

## Scheduling via PostBridge MCP

The InfiniteTalk output video is hosted on fal.ai storage as a public URL — pass it directly to PostBridge MCP. No separate media upload needed.

```bash
# 1. Get your social account IDs (one-time setup)
mcporter call postbridge.list_social_accounts

# 2. Schedule the video
mcporter call postbridge.create_post \
  caption="Your caption here" \
  social_accounts='["tiktok-account-id", "reels-account-id"]' \
  media_urls='["https://v3.fal.media/files/.../<video>.mp4"]' \
  scheduled_at="2026-03-04T14:00:00Z"

# 3. Check it posted
mcporter call postbridge.list_post_results
```

**Note:** `media_urls` accepts the fal.ai URL directly from InfiniteTalk output — no re-upload required.

Store account IDs in `~/clawd/characters/<slug>/config.json` under `accounts.postbridge_ids`.

---

## Character Directory Convention

```
~/clawd/characters/<slug>/
  config.json          ← character config (voice, appearance, accounts)
  face-ref-YYYY-MM-DD.png   ← use as --image input
  audio/
    YYYY-MM-DD-<title>.mp3  ← output from elevenlabs skill
  videos/
    YYYY-MM-DD-<title>.mp4  ← output from this skill
  scripts/
    YYYY-MM-DD-<title>.md   ← episode scripts
```
