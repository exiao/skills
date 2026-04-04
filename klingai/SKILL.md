---
name: klingai
version: "1.0.3"
description: Official Kling AI Skill. Call Kling AI for video generation, image generation, and subject management. Use subcommand video / image / element by user intent. Use when the user mentions "Kling", "可灵", "文生视频", "图生视频", "文生图", "图生图", "AI 画图", "视频生成", "图片生成", "主体", "角色", "多镜头", "4K", "组图", "text-to-video", "image-to-video", "text-to-image", "subject", "character", "element".
metadata: {"openclaw":{"emoji":"🎬","requires":{"bins":["node"]},"primaryEnv":"KLING_TOKEN","homepage":"https://app.klingai.com/cn/dev/document-api"}}
---

> **Language**: Respond in the user's language (detect from their message). Use it for explanations, confirmations, errors, and follow-ups. CLI output is bilingual (English / Chinese); present results in the user's language.

# Kling AI

Video generation, image generation, and subject management. Invoke with subcommand **`video`** | **`image`** | **`element`** according to user intent. Tasks are billable; confirm with the user when intent is ambiguous before submitting.

## Invocation

From repository root:

```bash
node skills/klingai/scripts/kling.mjs <video|image|element> [options]
```

In examples below, `{baseDir}` means the skill directory (e.g. `skills/klingai`); replace with that path or run from that directory.

## Intent routing (required)

**You must decide the subcommand from user intent:**

| User intent | Subcommand |
| --- | --- |
| Video (text-to-video, image-to-video, multi-shot, reference video, animation) | `video` |
| Image (text-to-image, image-to-image, 4K, picture, AI drawing) | `image` |
| Subject / element (create, manage, or list characters) | `element` |

**Selection rules:** Video-related → **`video`**; image-only → **`image`**; subject CRUD → **`element`**. To *use* an existing subject in a video or image, use **`video`** or **`image`** with `--element_ids`; to create the subject, use **`element`** first.

**When ambiguous:** e.g. “generate something with Kling” (video or image?) or “generate a character” (new subject vs character image) → ask the user, then call the script with the chosen subcommand. **Confirm before submit:** Kling tasks are billable and expensive. Only submit when the task is clear; if intent is at all ambiguous, confirm with the user before submitting.

## Cost and submission rules

- **Every submit is charged.** Treat submissions seriously; do not submit speculatively or “to see what happens.”
- **Confirm intent first.** Only submit after the task is clear. If the user’s intent is vague or ambiguous, ask and confirm before calling the script.
- **Queue and failures.** Queues can be long. On timeout, failure, or any unexpected outcome, **ask the user** whether to continue waiting or to retry. **Do not** automatically resubmit, and **do not** change the user’s intent and retry without explicit confirmation.

## Prerequisites

- Node.js 18+; no other dependencies.
- **Authentication** (one of): `KLING_TOKEN` (Bearer, recommended) or `KLING_API_KEY` (`accessKey|secretKey`, JWT auto).
- **Region**: Unset `KLING_API_BASE` → script probes China/Global and caches in `~/.config/kling/state.json`. To force region, set `KLING_API_BASE`. After account/region change: `rm ~/.config/kling/state.json`.

## Quick start

```bash
# Show help
node {baseDir}/scripts/kling.mjs --help

# Video
node {baseDir}/scripts/kling.mjs video --prompt "A cat running on the grass" --output_dir ./output
node {baseDir}/scripts/kling.mjs video --image ./photo.jpg --prompt "Wind blowing hair"
node {baseDir}/scripts/kling.mjs video --multi_shot --shot_type customize --multi_prompt '[{"index":1,"prompt":"Sunrise","duration":"5"}]'

# Image
node {baseDir}/scripts/kling.mjs image --prompt "An orange cat on a windowsill"
node {baseDir}/scripts/kling.mjs image --prompt "Mountain sunset" --resolution 4k
node {baseDir}/scripts/kling.mjs image --prompt "<<<element_1>>> on the beach" --element_ids 123456

# Subject / element
node {baseDir}/scripts/kling.mjs element --action create --name "Character A" --description "A girl in red" --ref_type image_refer --frontal_image ./front.jpg
node {baseDir}/scripts/kling.mjs element --action list
node {baseDir}/scripts/kling.mjs element --action query --task_id <id>

# Query existing task (use same subcommand as when you submitted)
node {baseDir}/scripts/kling.mjs video --task_id <id> --download
node {baseDir}/scripts/kling.mjs image --task_id <id> --download
```

## Core parameters by subcommand

### video (video generation)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--prompt` | Video description (required for text/image/Omni) | — |
| `--image` | First-frame image path or URL (comma-separated multiple → Omni) | — |
| `--duration` | Duration 3–15 s | 5 |
| `--model` | **kling-v3** / **kling-v2-6**: standard t2v, i2v, first/last-frame. **kling-v3-omni**: multi-image, element combo, edit tasks (see “When to use Omni”). kling-video-o1: script chooses by endpoint | by endpoint |
| `--mode` | pro (1080P) / std (720P) | pro |
| `--aspect_ratio` | 16:9 / 9:16 / 1:1 | 16:9 |
| `--sound` | on / off (v3/omni; with --video only off; o1 no sound) | off |
| `--image_tail` | Last-frame image | — |
| `--element_ids` | Subject IDs, comma-separated (Omni, max 3) | — |
| `--video` | Reference video path or URL (Omni) | — |
| `--video_refer_type` | feature / base (with --video) | feature |
| `--multi_shot` | Enable multi-shot | false |
| `--shot_type` | customize (required when multi_shot) | — |
| `--multi_prompt` | Shots JSON array (max 6) | — |
| `--output_dir` | Output directory | ./output |
| `--task_id` | Query task; use with `--download` to download | — |

### image (image generation)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--prompt` | Image description (required) | — |
| `--image` | Reference image path or URL (comma-separated multiple → Omni) | — |
| `--resolution` | 1k / 2k / 4k (4k uses Omni) | 1k |
| `--aspect_ratio` | 16:9 / 9:16 / 1:1 / auto (Omni) | 16:9 / auto |
| `--n` | Number of images 1–9 | 1 |
| `--negative_prompt` | Negative prompt (basic API only) | — |
| `--result_type` | single / series (series uses Omni) | single |
| `--series_amount` | Series count 2–9 | 4 |
| `--element_ids` | Subject IDs, comma-separated (Omni) | — |
| `--output_dir` | Output directory | ./output |
| `--task_id` | Query task; use with `--download` to download | — |

### element (subject management)

| Parameter | Description |
|-----------|-------------|
| `--action create` | Create subject: `--name` (≤20 chars), `--description` (≤100 chars), `--ref_type` required |
| `--ref_type` | image_refer (need `--frontal_image`) / video_refer (need `--video`) |
| `--frontal_image` | Front reference image (image_refer) |
| `--refer_images` | Other reference images, comma-separated (1–3) |
| `--video` | Reference video (video_refer) |
| `--action query --task_id <id>` | Query creation task |
| `--action list` | List custom subjects |
| `--action list-presets` | List preset subjects |
| `--action delete --element_id <id>` | Delete subject |

Run `node {baseDir}/scripts/kling.mjs video --help`, `image --help`, or `element --help` for full parameters.

## API routing (by subcommand)

You choose the subcommand (video | image | element); the script then picks the backend API from the parameters (e.g. multi_shot, element_ids, multiple images, or reference video → omni). So pass the right parameters for the task: use the “When to use Omni” section to decide when to pass Omni-triggering options.

- **video**: Text only → text2video; single first-frame only → image2video; multi-image/subject/reference video/multi-shot → omni-video.
- **image**: Basic (1k/2k, no 4K/series/subject) → generations; 4K/series/subject/multi-image/auto → omni-image.
- **element**: advanced-custom-elements, advanced-presets-elements, delete-elements.

## When to use Omni; element vs image reference

**kling-v3 / kling-v2-6** suit standard text-to-video, image-to-video, and first/last-frame tasks. **kling-v3-omni** is for the more complex cases below.

**Use Omni (kling-v3-omni)** when the task is not just “first frame animates” (simple image-to-video), but involves: multiple different images, combinations of elements and images, or **edit-style instructions** (add/remove/change content in images or videos). The Omni model supports these by letting you refer to subjects, images, and video in the prompt (see below).

**Prefer image as reference** for straightforward “use this image as reference” tasks (e.g. “make the person in this photo move”, “generate based on this reference”). Pass the image via `--image` and use the basic or image-to-video path. **Create an element first** only when the user clearly intends to *solidify* the subject as a reusable element, or explicitly needs **subject ID consistency** across shots/outputs, or needs to **reuse the same subject in many places**. Creating an element adds an extra step and latency; default to completing the task with image reference when that is sufficient.

## Prompt template syntax (video / image Omni)

In `--prompt` you can reference inputs with `<<<>>>`:

- `<<<image_1>>>` — first image from `--image`
- `<<<element_1>>>` — first subject from `--element_ids`
- `<<<video_1>>>` — video from `--video` (video subcommand only)

## Notes

- **Timing**: Video 1–5 min (can be longer); image ~20–60 s; subject creation ~30 s – 2 min.
- **Task status and polling**: Generation is asynchronous. Poll at a reasonable interval (e.g. every 30–60 s) with `--task_id` (same subcommand as submit); do not block or hang the conversation. Keep the user informed of status (e.g. submitted → processing → succeed/failed) and notify when the result is ready or if it failed.
- **Retention**: Assets cleaned after 30 days; save in time.
- **Sound**: v3/omni support `--sound`; with `--video` (reference video) only `off`; kling-video-o1 has no sound.

## Recipe: Motion Control for AI UGC Ads

Animate an AI-generated face using a reference motion video. The reference video is YOU doing the motion; Kling maps it onto the AI face. This is the core technique behind @athcanft's $5-10 CPA TikTok ads.

### When to Use

- Before/after transformation ads (animate both the "before" and "after" face with the same reference motion)
- AI UGC talking-head ads (generate a face with nano-banana-pro, animate with your reference motion)
- Any ad where you need a realistic AI person speaking/moving

### The Workflow

```bash
# 1. Generate the AI face (use nano-banana-pro, Kling image, or any image generator)
#    Save as: before_face.png, after_face.png

# 2. Record your reference motion video
#    - Simple head turns, nodding, talking — these work best
#    - Avoid: hand motions near face, covering mouth (inconsistent results)
#    - Keep it 5s, vertical (9:16)
#    Save as: reference_motion.mp4

# 3. Animate the "before" face with your reference motion
node skills/klingai/scripts/kling.mjs video \
  --image ./before_face.png \
  --video ./reference_motion.mp4 \
  --prompt "<<<image_1>>> person talking naturally, same motion as <<<video_1>>>" \
  --duration 5 \
  --mode pro \
  --aspect_ratio 9:16 \
  --output_dir ./output

# 4. Animate the "after" face with the SAME reference motion
node skills/klingai/scripts/kling.mjs video \
  --image ./after_face.png \
  --video ./reference_motion.mp4 \
  --prompt "<<<image_1>>> person talking naturally, same motion as <<<video_1>>>" \
  --duration 5 \
  --mode pro \
  --aspect_ratio 9:16 \
  --output_dir ./output
```

### Recommended Settings

| Setting | Value | Why |
|---------|-------|-----|
| Duration | 5s | Enough for one beat of the before/after; concat two for 10s + 2s CTA = 12s ad |
| Mode | pro | 1080P output needed for TikTok ads |
| Aspect ratio | 9:16 | Vertical for TikTok/Reels |
| Model | kling-v3-omni | Required for `--video` reference (motion control) |

### Tips

- **Simple motions only.** Head turns, nodding, talking, looking at camera. These produce natural, consistent results.
- **Hands near face = inconsistent.** Kling struggles with hand-to-face interactions. If your reference video has hand gestures, keep them below chest level.
- **Same reference for both faces.** Use the identical reference motion video for the "before" and "after" faces so the movement matches perfectly when concatenated.
- **Lighting in the still matters.** The AI face image sets the lighting/mood. Make the "before" slightly dim/cool, "after" warm/bright.
- **5s + 5s + 2s = 12s.** The sweet spot for TikTok ads per @athcanft. Don't go longer.

### Bloom Example Prompts

**Before face image prompt (nano-banana-pro):**
> Young adult looking at phone with furrowed brow, confused expression, dim cool lighting, casual clothes, plain background, medium shot, 9:16 portrait

**After face image prompt (nano-banana-pro):**
> Same young adult, relaxed confident smile, warm golden lighting, slight glow, looking at camera, medium shot, 9:16 portrait

Then enhance the "after" image with `fal-face-enhance.sh` for the glow-up effect before animating.

## Reference

- `docs/kling3.0-server-api.md` — full API (fields, enums, capability matrix).
- `docs/api-overview.md` — base URL, paths, skill mapping.
