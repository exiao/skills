---
name: thumbnail
description: Generate video cover frames and thumbnails for YouTube, TikTok, and social media. Use when asked for a "video thumbnail", "cover frame", "YouTube thumbnail", or when needing to extract a still from a video for use as a cover image.
---

# Thumbnail — Video Cover Frames & Thumbnails

Generate optimized video thumbnails / cover frames for YouTube, TikTok, and social media.

## Two Approaches

### A. Extract Best Frame from Video (ffmpeg)

```bash
# Extract I-frame (keyframe) — usually sharpest
ffmpeg -i video.mp4 -vf "select=eq(pict_type\,I)" -frames:v 1 -q:v 2 thumb.jpg

# Extract frame at specific timestamp
ffmpeg -ss 00:00:05 -i video.mp4 -frames:v 1 -q:v 2 thumb.jpg

# Extract multiple candidate frames (one every 5 seconds)
ffmpeg -i video.mp4 -vf "fps=1/5" -q:v 2 thumb_%03d.jpg
```

After extracting candidates, review them with the image tool and pick the best one (sharpest, best expression, good composition).

### B. Generate Custom Thumbnail (Nano Banana Pro)

Use an image generation tool (e.g., Gemini image generation) to generate a designed thumbnail from scratch.

Prompt guidance:
- Include a face/subject with clear expression
- Specify text overlay in the prompt (keep to 3-5 words)
- Request high contrast, bright colors
- Match the platform aspect ratio (see specs below)

Example prompt structure: "YouTube thumbnail, 16:9, [subject description], [expression/action], bold text '[YOUR TEXT]', bright [color] background, high contrast, photorealistic"

## Platform Specs

| Platform | Size | Aspect | Notes |
|----------|------|--------|-------|
| YouTube | 1280x720 | 16:9 | Custom upload. Most important for CTR. |
| TikTok | 1080x1920 | 9:16 | Select from video frames only (no custom upload). |
| Instagram Reels | 1080x1920 | 9:16 | Can set cover frame from video. |
| YouTube Shorts | 1080x1920 | 9:16 | Auto-selected from video. |

## Best Practices

- **Faces with expression** increase CTR 30%+
- **High contrast colors** (avoid muted tones)
- **Large text** (3-5 words max, readable at small size)
- **Don't repeat the title** verbatim
- **Rule of thirds** for subject placement
- **Bright background** or colored border to stand out in feed
- For YouTube: test with mobile preview size (the thumbnail is tiny on phone)

## Adding Text to an Extracted Frame (ffmpeg)

```bash
# Centered text near bottom with black outline
ffmpeg -i thumb.jpg -vf "drawtext=text='3 MISTAKES':fontsize=80:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=h-text_h-50" thumb_text.jpg

# Top-left text
ffmpeg -i thumb.jpg -vf "drawtext=text='WATCH THIS':fontsize=72:fontcolor=yellow:borderw=3:bordercolor=black:x=40:y=40" thumb_text.jpg
```

For more complex text layouts (drop shadows, multiple text blocks, custom fonts), use an image generation tool to generate the thumbnail instead.

## Workflow

1. **Determine approach:** Does the user have a video to extract from (→ A) or need a generated thumbnail (→ B)?
2. **Confirm platform:** YouTube 16:9 vs. vertical 9:16. Default to YouTube 1280x720 if unspecified.
3. **Extract or generate:** Run the appropriate approach.
4. **Add text if needed:** Use ffmpeg drawtext for simple overlays, or regenerate with image generation if complex.
5. **Review:** Screenshot/display the result for user approval.
