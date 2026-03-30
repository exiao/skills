---
name: seedance
version: "1.0"
description: Generate videos using ByteDance Seedance 2.0 via PiAPI. Triggers on "Seedance", "ByteDance video", "video generation", "text-to-video", "image-to-video". Supports text-to-video, image-to-video, video editing, and video extension.
---

# Seedance 2.0 Video Generation

Generate cinematic AI videos using ByteDance's Seedance 2.0 model through PiAPI's API.

## Requirements

- `PIAPI_API_KEY` env var (get from app.piapi.ai)
- `jq` (brew install jq)
- PiAPI credits topped up

## Models & Pricing

| Model | Mode | Price/sec |
|-------|------|-----------|
| `seedance-2-preview` | Text/Image to Video | $0.15 |
| `seedance-2-fast-preview` | Text/Image to Video | $0.08 |
| `seedance-2-preview` | Video Edit | $0.25 |
| `seedance-2-fast-preview` | Video Edit | $0.13 |

## Usage

### Text-to-Video

```bash
# Quick generation (5s, fast model)
{baseDir}/scripts/seedance.sh generate "A cinematic aerial shot of a coastal city at sunrise"

# Full quality, 10 seconds, vertical
{baseDir}/scripts/seedance.sh generate "A woman walks through a neon-lit Tokyo street at night" \
  --model seedance-2-preview \
  --duration 10 \
  --aspect 9:16
```

### Image-to-Video

```bash
# Animate a reference image
{baseDir}/scripts/seedance.sh generate "The person in @image1 starts dancing" \
  --image https://example.com/photo.jpg

# Multiple image references
{baseDir}/scripts/seedance.sh generate "@image1 transforms into @image2" \
  --image https://example.com/before.jpg \
  --image https://example.com/after.jpg
```

### Video Edit

```bash
# Edit an existing video
{baseDir}/scripts/seedance.sh generate "Change the background to a snowy mountain landscape" \
  --video https://example.com/original.mp4
```

### Video Extension

```bash
# Extend a previously generated video by providing its task ID
{baseDir}/scripts/seedance.sh extend <task_id>

# Extend with a custom continuation prompt
{baseDir}/scripts/seedance.sh extend <task_id> "zoom out to reveal the full skyline"
```

### Check Status

```bash
# Check task status (single call)
{baseDir}/scripts/seedance.sh status <task_id>

# Poll with auto-download
{baseDir}/scripts/seedance.sh wait <task_id> --output video.mp4
```

**`wait` options:**
- `--output <file>` — download the completed video to this path
- `--max-attempts <N>` — max poll attempts (default: 720 = 1 hour at 5s intervals)

## Parameters

| Parameter | Values | Default |
|-----------|--------|---------|
| `--model` | `seedance-2-preview`, `seedance-2-fast-preview` | `seedance-2-fast-preview` |
| `--duration` | `5`, `10`, or `15` (seconds) — other values rejected | `5` |
| `--aspect` | `16:9`, `9:16`, `4:3`, `3:4` | `16:9` |
| `--image` | URL (repeatable, max 9) | none |
| `--video` | URL (1 max, enables edit mode) | none |
| `--output` | (wait only) file path to download video to | none |
| `--max-attempts` | (wait only) max poll attempts | 720 |

> **Model mapping:** The `--model` value (e.g. `seedance-2-fast-preview`) is sent as `task_type` in the API request. The `model` field is always `"seedance"` (the PiAPI product name). This is correct API behavior — don't change it.

## Image References in Prompts

Use `@image1`, `@image2`, etc. to reference images in order:
- "The cat in @image1 walks through a garden"
- "@image1 transforms into @image2"
- "The whale in @image1 meets the ninja in @image2"

## Notes

- Peak hours (09:00-15:00 GMT): queue times can extend to hours
- Video edit mode ignores `--duration`; output length = input video length
- Aspect ratio of reference image overrides the `--aspect` parameter
- Videos are generated asynchronously; use `wait` to poll until complete
- Output URLs are temporary; download promptly
