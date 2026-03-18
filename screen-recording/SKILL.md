---
name: screen-recording
description: Record macOS screen via CLI with ffmpeg. Pair with peekaboo for automated UI demos. Use when recording tutorials, product walkthroughs, or automated demo videos.
metadata: {"clawdbot":{"emoji":"🎬","requires":{"anyBins":["ffmpeg"],"optionalBins":["peekaboo","screencapture"]}}}
---

# Screen Recording (macOS CLI)

Record the macOS screen from the command line using ffmpeg + AVFoundation. Pair with peekaboo for automated UI demos. Supports start/stop control, background recording, region capture, and post-processing.

## Quick Start

```bash
# Start recording (returns PID)
./skills/screen-recording/scripts/record.sh start --output /tmp/demo.mp4

# Stop recording
./skills/screen-recording/scripts/record.sh stop <PID>

# Fixed-duration recording
./skills/screen-recording/scripts/record.sh start --output /tmp/demo.mp4 --duration 30
```

---

## Methods Compared (tested on MacBook Air, 2880×1800 Retina)

| Method | File Size/10s | Resolution | Actual FPS | Cursor | Prog. Stop | CPU |
|--------|--------------|------------|------------|--------|------------|-----|
| ffmpeg + libx264 CRF18 | ~730KB | 2880×1800 | ~27fps | ✅ | ✅ | ~30% |
| ffmpeg + libx264 CRF23 | ~327KB | 2880×1800 | ~27fps | ✅ | ✅ | ~25% |
| ffmpeg + libx264 CRF28 | ~277KB | 2880×1800 | ~26fps | ✅ | ✅ | ~20% |
| ffmpeg + h264_videotoolbox | ~4.6MB | 2880×1800 | ~26fps | ✅ | ✅ | ~15% |
| screencapture -V | ~8.6MB | 2880×1800 | ~43fps | ✅ | ❌ (timed only) | ~2% |
| peekaboo live (frames) | ~5MB/8 PNGs | 1440×900 | ~0.8fps eff. | ❌ | ✅ | ~5% |

**Recommendation:**
- **Tutorial videos** → `ffmpeg + libx264 CRF18` (best quality, full Retina, small file)
- **Quick demos / drafts** → `ffmpeg + libx264 CRF23` (great balance, ~33KB/s)
- **High-motion content** → `screencapture -V` (highest FPS, but no programmatic stop)
- **Frame analysis / AI review** → `peekaboo capture live` (motion-triggered PNGs, not video)

### Key Findings
- **ffmpeg captures full 2880×1800 Retina** (screencapture too; peekaboo is 1440×900 logical)
- **ffmpeg achieves ~26-27fps** targeting 30fps — CPU is the bottleneck at full Retina res
- **screencapture achieves ~43fps** with near-zero CPU (OS-native HEVC pipeline)
- **peekaboo is NOT for continuous video** — it's motion-triggered snapshots, perfect for AI analysis
- **h264_videotoolbox uses GPU** — lower CPU but larger files at similar quality vs libx264
- Input pixel format for AVFoundation is `uyvy422` — never specify on input, use `-pix_fmt yuv420p` on output only

---

## record.sh Usage

```bash
SCRIPT=./skills/screen-recording/scripts/record.sh

# Start (background, returns PID to stdout)
PID=$($SCRIPT start --output /tmp/out.mp4)

# Start with options
PID=$($SCRIPT start \
  --output /tmp/out.mp4 \
  --fps 30 \
  --quality 23 \
  --cursor)

# Fixed duration (blocks until done)
$SCRIPT start --output /tmp/out.mp4 --duration 30 --cursor

# Capture a region: x,y,width,height (logical coords)
PID=$($SCRIPT start --output /tmp/out.mp4 --region 0,0,1280,800)

# Stop recording
$SCRIPT stop $PID

# Check if recording is active
kill -0 $PID 2>/dev/null && echo "recording" || echo "stopped"
```

### Parameters

| Flag | Default | Description |
|------|---------|-------------|
| `--output PATH` | required | Output .mp4 file path |
| `--fps N` | 30 | Frame rate (30 recommended; 60 may drop frames) |
| `--quality N` | 23 | libx264 CRF (18=high, 23=balanced, 28=small) |
| `--duration N` | unlimited | Auto-stop after N seconds |
| `--cursor` | off | Capture cursor in recording |
| `--clicks` | off | Visualize mouse clicks |
| `--region x,y,w,h` | full screen | Capture sub-region (logical pixel coords) |
| `--codec [x264\|vt]` | x264 | Encoder: libx264 (smaller) or h264_videotoolbox (faster) |

---

## Paired with Peekaboo: Automated Demo Videos

```bash
# Start recording, run automation, stop recording
PID=$(./skills/screen-recording/scripts/record.sh start --output /tmp/demo.mp4 --cursor --clicks)
sleep 1  # let recording stabilize

# Drive UI with peekaboo
peekaboo type --text "Hello world" --app TextEdit
peekaboo click --app Safari --element "Address Bar"
peekaboo type --text "https://example.com" --submit

sleep 2
./skills/screen-recording/scripts/record.sh stop $PID
```

See `scripts/record-with-actions.sh` for a full template.

---

## Post-Processing with ffmpeg

### Trim a clip
```bash
ffmpeg -i input.mp4 -ss 00:00:02 -to 00:00:15 -c copy trimmed.mp4
```

### Crop to a region (pixel coords in output)
```bash
# Crop to 1920x1080 starting at 480,360 (centers 1080p in 2880x1800)
ffmpeg -i input.mp4 -vf "crop=1920:1080:480:360" cropped.mp4
```

### Scale down from Retina to 1440p
```bash
ffmpeg -i input.mp4 -vf "scale=2560:1600" -crf 18 -c:v libx264 output_1440p.mp4
```

### Scale down to 1080p (common for sharing)
```bash
ffmpeg -i input.mp4 -vf "scale=1920:1080" -crf 20 -c:v libx264 output_1080p.mp4
```

### Add cursor zoom effect (magnify cursor region)
```bash
# Zoom into center 640x400 area and overlay in corner
ffmpeg -i input.mp4 \
  -vf "split[main][zoom];[zoom]crop=640:400:1120:700,scale=320:200[zoomed];[main][zoomed]overlay=20:20" \
  -crf 20 cursor_zoom.mp4
```

### Speed up (2x timelapse)
```bash
ffmpeg -i input.mp4 -vf "setpts=0.5*PTS" -r 60 fast.mp4
```

### Convert MOV to MP4 (from screencapture)
```bash
ffmpeg -i recording.mov -c:v libx264 -pix_fmt yuv420p -crf 20 recording.mp4
```

---

## Optimal Settings Reference

### Tutorial Videos (max quality, sharing-ready)
```bash
./skills/screen-recording/scripts/record.sh start \
  --output tutorial.mp4 \
  --fps 30 \
  --quality 18 \
  --cursor --clicks
# Then scale to 1080p in post for uploads
```

### Quick Demo / Draft
```bash
./skills/screen-recording/scripts/record.sh start \
  --output demo.mp4 \
  --fps 30 \
  --quality 23 \
  --cursor
```

### Tiny File (Slack / email preview)
```bash
./skills/screen-recording/scripts/record.sh start \
  --output preview.mp4 \
  --fps 15 \
  --quality 28 \
  --codec vt
# Then scale down: ffmpeg -i preview.mp4 -vf scale=1280:800 -crf 28 preview_small.mp4
```

### Automated CI/Demo (no cursor, clean)
```bash
PID=$(./skills/screen-recording/scripts/record.sh start --output /tmp/ci_demo.mp4 --quality 23)
# ... run automation ...
./skills/screen-recording/scripts/record.sh stop $PID
```

---

## Device Discovery

```bash
# List available screen devices
/usr/local/bin/ffmpeg -list_devices true -f avfoundation -i "" 2>&1 | grep -E "AVFoundation|^\[AVFoundation"

# On Eric's MacBook Air:
# [0] FaceTime HD Camera
# [1] Capture screen 0  ← use "1:none"
```

---

## screencapture Alternative

Use when you need the highest frame rate and don't need programmatic mid-recording stop:

```bash
# 10-second recording with cursor and click visualization
/usr/sbin/screencapture -v -V 10 -C -k -x /tmp/recording.mov

# Region capture (logical pixel coords)
/usr/sbin/screencapture -v -V 10 -C -R "0,0,1440,900" -x /tmp/region.mov

# Convert to MP4 after
ffmpeg -i /tmp/recording.mov -c:v libx264 -pix_fmt yuv420p -crf 20 /tmp/recording.mp4
```

**Flags:** `-v` video, `-V<s>` duration, `-C` cursor, `-k` click visualization, `-x` no sound, `-R` region

---

## Peekaboo Live Capture (Frame Analysis)

Peekaboo's live mode captures motion-triggered PNG frames — NOT continuous video. Use for:
- AI analysis of what happened on screen
- Building contact sheets / diffs
- Lightweight logging of UI state

```bash
# Capture 10s at up to 8fps (motion-triggered)
peekaboo capture live \
  --mode screen \
  --duration 10 \
  --active-fps 8 \
  --path /tmp/frames

# Output: keep-0001.png ... keep-NNNN.png + contact.png + metadata.json
# Resolution: 1440x900 (logical, not Retina)

# Stitch into video if needed (sparse/timelapse)
ffmpeg -framerate 2 \
  -pattern_type glob \
  -i '/tmp/frames/keep-*.png' \
  -vcodec libx264 -pix_fmt yuv420p -crf 23 \
  output.mp4
```

---

## Tips

1. **Always use `-pix_fmt yuv420p` on output only** — AVFoundation input is `uyvy422`, don't set it on `-i`
2. **Target 30fps, not 60** — at 2880×1800 Retina, ffmpeg delivers ~26-27fps targeting 30; 60fps target gets ~same actual fps with more dropped frames
3. **Add 1s sleep after starting** before driving UI — ffmpeg needs a moment to stabilize the capture pipeline
4. **Use `kill -SIGINT $PID`** to stop ffmpeg cleanly (writes moov atom); `kill -9` corrupts the file
5. **screencapture can't be stopped mid-recording** — it blocks until `-V` seconds elapse or is Ctrl+C'd (which doesn't save the file)
6. **h264_videotoolbox** uses Apple's hardware encoder — lower CPU but files are 10-15x larger than libx264 at similar visual quality
7. **Region coords are logical pixels** (1440×900 space) not physical Retina pixels (2880×1800)
