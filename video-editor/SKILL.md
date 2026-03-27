---
name: video-editor
description: Programmatic video editing via ffmpeg CLI. Handles trimming clips, merging/concatenating videos, overlays (picture-in-picture, watermarks, logos), crossfade transitions between clips, speed ramping (speed up/slow motion), cropping to aspect ratios (16:9 to 9:16), scaling/resizing, adding or replacing audio tracks, fade in/out effects, text overlays (drawtext), rotation, looping clips, extracting frames, GIF creation, audio ducking (sidechaincompress), volume normalization (loudnorm), mixing audio tracks (amix), and audio fades. Use whenever asked to edit video, trim clip, merge videos, add music to video, overlay, picture in picture, video transition, speed up video, slow motion, crop video, resize video, audio ducking, mix audio tracks, normalize audio, create GIF from video, extract frames, loop a clip, add text to video, fade video, or any ffmpeg-based media manipulation. Also use when assembling finished videos from clips, audio, and overlays for content creation pipelines.
---

# Video Editor

Programmatic video editing via ffmpeg. This skill wraps common ffmpeg operations into a single bash script with subcommands, so you don't have to reconstruct complex filter graphs from scratch each time.

## Prerequisites

- ffmpeg 6+ (check with `ffmpeg -version`)
- All commands assume input files exist and are valid media files

## The Edit Script

The main tool is `scripts/edit.sh` in this skill's directory. In examples below, `{baseDir}` means the skill directory (e.g. `~/clawd/skills/video-editor`); replace with that path.

### Core Video Operations

**Trim** a segment from a video:
```bash
{baseDir}/scripts/edit.sh trim -i input.mp4 -ss 00:01:00 -to 00:02:30 -o output.mp4
```
Uses stream copy (`-c copy`) for speed. For frame-accurate cuts, add `--precise` which re-encodes.

**Concat** multiple clips into one:
```bash
{baseDir}/scripts/edit.sh concat -i "clip1.mp4,clip2.mp4,clip3.mp4" -o merged.mp4
```
Uses the concat demuxer for same-codec files. If codecs differ, it re-encodes automatically.

**Overlay** an image or video on top of another (PiP, watermark, logo):
```bash
{baseDir}/scripts/edit.sh overlay -i base.mp4 --overlay logo.png --position top-right -o output.mp4
# Positions: top-left, top-right, bottom-left, bottom-right, center
# Custom position: --position "10:10" (x:y pixels)
# Scale overlay: --scale 0.25 (25% of base video width)
```

**Crossfade** transition between two clips:
```bash
{baseDir}/scripts/edit.sh crossfade -i "clip1.mp4,clip2.mp4" --duration 1 -o output.mp4
# --transition: fade (default), wipeleft, wiperight, slideup, slidedown, circleopen, dissolve
```

**Speed** change (ramp up/slow down):
```bash
{baseDir}/scripts/edit.sh speed -i input.mp4 --factor 2.0 -o output.mp4   # 2x speed
{baseDir}/scripts/edit.sh speed -i input.mp4 --factor 0.5 -o output.mp4   # half speed (slow-mo)
```
Adjusts both video (setpts) and audio (atempo) together.

**Crop** to an aspect ratio:
```bash
{baseDir}/scripts/edit.sh crop -i input.mp4 --ratio 9:16 -o output.mp4    # vertical
{baseDir}/scripts/edit.sh crop -i input.mp4 --ratio 1:1 -o output.mp4     # square
# --gravity: center (default), top, bottom
```

**Scale** / resize:
```bash
{baseDir}/scripts/edit.sh scale -i input.mp4 --width 1920 --height 1080 -o output.mp4
{baseDir}/scripts/edit.sh scale -i input.mp4 --width 720 -o output.mp4    # height auto-calculated
```

**Fade** in/out (video and/or audio):
```bash
{baseDir}/scripts/edit.sh fade -i input.mp4 --fade-in 1 --fade-out 2 -o output.mp4
# --video-only or --audio-only to apply to just one stream
```

**Text overlay** using drawtext:
```bash
{baseDir}/scripts/edit.sh text -i input.mp4 --text "Hello World" --position bottom-center \
  --fontsize 48 --fontcolor white --from 0 --to 5 -o output.mp4
# --font: path to .ttf file (optional, uses default sans)
# --bg-color: background box color, e.g. "black@0.5"
```

**Rotate**:
```bash
{baseDir}/scripts/edit.sh rotate -i input.mp4 --angle 90 -o output.mp4    # 90, 180, 270
```

**Loop** a clip to fill a target duration:
```bash
{baseDir}/scripts/edit.sh loop -i short.mp4 --duration 30 -o looped.mp4   # loop to 30 seconds
```

**Extract frames** to image sequence:
```bash
{baseDir}/scripts/edit.sh frames -i input.mp4 --fps 2 -o frames/frame_%03d.jpg
# --fps: frames per second to extract (default 1)
```

**GIF** creation:
```bash
{baseDir}/scripts/edit.sh gif -i input.mp4 --fps 15 --width 480 -o output.gif
# --from and --to for segment, --optimize for two-pass palette optimization
```

### Audio Operations

**Add audio** track to video (mix with existing):
```bash
{baseDir}/scripts/edit.sh add-audio -i video.mp4 --audio music.mp3 --volume 0.3 -o output.mp4
```

**Replace audio** (swap the audio track entirely):
```bash
{baseDir}/scripts/edit.sh replace-audio -i video.mp4 --audio voiceover.mp3 -o output.mp4
```

**Audio ducking** (lower music when voice plays):
```bash
{baseDir}/scripts/edit.sh ducking -i voice.mp3 --music bg.mp3 -o mixed.mp3
# --threshold: voice detection threshold (default 0.02)
# --ratio: compression ratio (default 8)
# --attack: attack time ms (default 200)
# --release: release time ms (default 1000)
```

**Volume normalize** using EBU R128 loudnorm:
```bash
{baseDir}/scripts/edit.sh normalize -i audio.mp3 -o normalized.mp3
# --target-lufs: target loudness (default -16 for podcasts, -14 for music)
```

**Mix** multiple audio tracks:
```bash
{baseDir}/scripts/edit.sh mix -i "voice.mp3,music.mp3,sfx.mp3" --volumes "1.0,0.15,0.3" -o output.mp3
# --duration: longest (default), shortest, or specific seconds
```

**Fade audio**:
```bash
{baseDir}/scripts/edit.sh fade-audio -i audio.mp3 --fade-in 2 --fade-out 3 -o output.mp3
```

## Recipes

For common multi-step workflows (talking head with B-roll, TikTok slideshows, product demos), see `references/recipes.md` in this skill's directory. Read it when you need to chain multiple operations together.

## Tips

- **Probe before editing:** Run `ffprobe -v quiet -print_format json -show_format -show_streams input.mp4` to understand what you're working with (codec, resolution, duration, audio channels).
- **Preview before full render:** For long videos, test your filter chain on a short segment first using trim.
- **Codec compatibility:** The concat command handles mixed codecs by detecting mismatches and re-encoding. For speed, ensure input files share the same codec/resolution.
- **Audio sync:** When replacing audio, the script maps the new audio to match video duration. If audio is shorter, it pads with silence; if longer, it trims.
- **Chaining operations:** For multi-step edits, either chain script calls (output of one becomes input of next) or build a custom ffmpeg command with multiple filters. The recipes file has examples of both approaches.
