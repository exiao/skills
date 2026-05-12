# Bloom Fastlane Visual QA

Last updated: 2026-05-11

Use this when the Fastlane daily cron generates content but intentionally leaves scheduling to the agent. The agent must visually self-verify every completed item, generate up to two replacements total, and schedule only content that passes.

## Inputs

The cron output usually includes:

- `COMPLETED_IDS=<id id id>`
- `FAILED_IDS=...`
- target connection IDs for Bloom TikTok, Instagram, and YouTube
- Fastlane content URLs for each generated item

If no `COMPLETED_IDS` exist, report that nothing was ready. Do not schedule anything.

## API

Use:

```bash
source ~/.hermes/.env
BASE="https://api.usefastlane.ai/api/v1"
UA="usefastlane-ai-agent/1.0"
```

Required headers:

```text
Authorization: Bearer $FASTLANE_API_KEY
User-Agent: usefastlane-ai-agent/1.0
Content-Type: application/json
```

Fetch each item with `GET /content/:id`. `GET /content/:id` only exposes `_id`, `type`, `status`, `files`, and `thumbnailUrl`; hook/suggestion text must come from the cron output or the `POST /blitz` response for replacements.

## Media inspection workflow

1. Download all `files` into `/tmp/fastlane-preview/<content_id>/`.
2. For videos, use `ffprobe` for duration, then `ffmpeg` to extract at least three representative frames: early, middle, late. Avoid relying only on the thumbnail.
3. For slideshows/images, inspect every slide when feasible. For long sets, inspect thumbnail plus first/middle/last at minimum.
4. Use vision analysis on the downloaded images/frames. Do not pass/fail from metadata alone.

Example video extraction:

```bash
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 video.mp4)
t1=$(echo "$dur/6" | bc -l | head -c6)
t2=$(echo "$dur/2" | bc -l | head -c6)
t3=$(echo "$dur*5/6" | bc -l | head -c6)
ffmpeg -y -i video.mp4 \
  -vf "select='between(t\,$t1\,$t1+0.1)+between(t\,$t2\,$t2+0.1)+between(t\,$t3\,$t3+0.1)',setpts=N/FRAME_RATE/TB" \
  -frames:v 3 frame_%02d.png
```

## Bloom visual QA gate

Reject if:

- The background has no semantic relationship to investing, markets, finance, AI tools, productivity, phone/app usage, charts, research, or decision-making.
- Serious investing/trading copy sits over random lifestyle scenes: brunch, parties, bedrooms, classrooms, generic friend groups, unrelated restaurants, storage rooms, lounge/bar scenes, car interiors, or anything that triggers “why is this the background?”
- People or backgrounds distract from the copy, text overlaps faces/hands, text is hard to read, or text is cropped.
- Text has obvious spelling or grammar issues.
- The scene implies financial advice, guaranteed returns, safety, outperformance, or trade certainty.

Pass only if this sentence is honest:

> This background supports this investing hook because ...

Examples from 2026-05-11:

- Rejected: strong wall-of-text copy over a random storage room/clothing rack with text over a person’s face.
- Rejected: slideshow about market-news overwhelm using lounge/bar and car-console iced-coffee backgrounds.
- Rejected: video hook using a generic bedroom selfie background and “before every trade” wording.
- Passed: research/study desk slideshow with a Bloom product slide. The study visuals loosely support diligence and second-opinion framing.
- Passed: Bloom app mockup/video showing Chat PRO. Directly connected to AI investing research.

## Bloom copy QA gate

Reject if copy:

- Is vague AI finance slop: “trade smarter with AI,” “unlock your financial future,” “invest like a pro,” generic guru phrasing.
- Uses growth-hack phrasing like “asap” unless the creative is intentionally meme-native and otherwise strong.
- Overpromises certainty, confidence, validation, outperformance, safety, or guaranteed results.
- Sounds like personalized financial advice or tells the viewer to buy/sell.
- Is not concrete, emotionally specific, weird, or useful.

Be extra cautious with “before every trade,” “signal,” and “commit with confidence.” These can imply trade-by-trade validation or certainty. Prefer “second read,” “cleaner starting point,” or “for your own research.”

## Replacement loop

If fewer than 3 items pass:

1. Call `POST /blitz` once.
2. Capture `data.contentId` and `data.suggestion.generatedText` if present. Suggestions may be objects.
3. Poll `GET /content/:id` every 15 seconds until `CREATED` or `FAILED`, max 5 minutes.
4. Run the same media download and QA process.
5. Stop after 2 replacement attempts total, even if fewer than 3 pass.

Do not schedule rejected content just to hit volume.

## Scheduling rules

- Stagger approved content tomorrow at 18:00, 21:00, and 00:00 UTC, cycling by approved item.
- Schedule every approved item to Bloom TikTok and Instagram.
- Schedule to YouTube only for video content types (`video-hook`, `green-screen`). Skip slideshows.
- Write fresh captions. Do not dump raw Fastlane suggestion JSON.
- Keep captions natural, specific, short, and soft-sell Bloom.
- For YouTube, `caption` is the title and must be under 100 chars. Put longer text in `description`.

## Rejection logging

Append one JSONL row per rejected item to:

```text
~/.hermes/fastlane/rejections.jsonl
```

Fields:

```json
{
  "timestamp": "ISO-8601 UTC",
  "content_id": "...",
  "content_type": "slideshow|wall-of-text|video-hook|green-screen",
  "hook": "hook or suggestion if known",
  "visual_reason": "one-line reason",
  "copy_reason": "one-line reason or pass",
  "thumbnail_url": "..."
}
```

Include rejected representative frames/slides as `MEDIA:` attachments in the final cron report when available so Eric can sanity-check taste.

## Final report format

Keep it concise:

- generated count, approved count, rejected count, replacement attempts used
- scheduled post IDs grouped by content ID and platform
- rejected IDs with one-line reasons
- if fewer than 3 passed, say: `scheduled N/3, quality gate blocked the rest`

If genuinely nothing is ready or new, return exactly `[SILENT]` for cron suppression when the job instructions allow it.
