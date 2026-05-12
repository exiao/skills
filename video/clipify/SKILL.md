---
name: clipify
description: Find the funniest moments in a video, cut them as standalone clips, optionally reformat 16:9 → 9:16 (face-pan or split-screen), and burn opus-style word-by-word captions. Use when the user mentions "clipify," "cut clips from this video," "make shorts from this," "find funny moments," "reframe to 9:16," "vertical clips," or pastes a video file path and wants social-ready cuts.
---

# Clipify

Find the funniest moments in a video, cut them as standalone clips, optionally reformat 16:9 → 9:16 (face-pan or split-screen), and burn opus-style word-by-word captions.

Source repo: ~/projects/clipify (cloned from github.com/louisedesadeleer/clipify)

## Inputs

- A video file path (the user will provide it; otherwise ask)
- Optional: requested format (9:16, 16:9, 1:1)
- Optional: subtitle style preference

## Tooling

- **Whisper:** `whisper --model tiny.en --word_timestamps True --output_format json` (fast; for non-English use `--model base`)
- **ffmpeg:** add `-hwaccel videotoolbox` on macOS for decode, `-preset ultrafast` for renders. Final: `-c:v libx264 -crf 20`
- **Scripts:** `~/projects/clipify/scripts/`
  - `analyze.py` — speaker timeline from two ROI motion files
  - `build_pan.py` — ffmpeg crop x-expression with hard cuts
  - `build_ass.py` — opus-style ASS captions from whisper JSON
  - `audio_align.py` — find offset of a sub-clip in a longer source

Working dir: `/tmp/clipify/` (mkdir at start)

---

## Workflow

### Step 1 — Find the funniest parts

```bash
mkdir -p /tmp/clipify
ffmpeg -y -hwaccel videotoolbox -i "$VIDEO" -vn -ac 1 -ar 16000 /tmp/clipify/audio.wav
whisper /tmp/clipify/audio.wav --model tiny.en --word_timestamps True --output_format json --output_dir /tmp/clipify --language en
```

Read JSON, pick 3-5 candidates. Funny signals: punchlines/reactions, reversals, awkward pauses, self-roasts, audio peaks.

For each: `[start, end, why-it's-funny, suggested title]`. Aim 10-25s. Show list, let user pick.

### Step 2 — Trim

```bash
ffmpeg -y -ss "$START" -t "$DURATION" -i "$VIDEO" -c copy /tmp/clipify/clip_$N.mp4
```

### Step 3 — Output format

Ask: "9:16 (TikTok/Reels), 16:9 (YouTube), or 1:1 (Insta feed)?"

### Step 4 — If 16:9 → 9:16: pan or split-screen

#### 4a — Pan-between-faces

1. Sample one frame, eyeball face ROIs (mouth+chin area as x,y,w,h)
2. Extract per-frame motion energy in each ROI via ffmpeg tblend+signalstats
3. Build speaker timeline: `python3 ~/projects/clipify/scripts/analyze.py /tmp/clipify/L.txt /tmp/clipify/R.txt 1.0 > /tmp/clipify/segments.json`
4. Pick pan x-coordinates for vertical strip (crop width = 608 for 1920 source)
5. Generate x expression and render: `python3 ~/projects/clipify/scripts/build_pan.py /tmp/clipify/segments.json $LEFT_X $RIGHT_X`

#### 4b — Split-screen

Two stacked tiles (1080x960 each), active speaker on top. Build enable expression from segments.json.

### Step 5 — Subtitles

Three styles: **opus** (big bold, yellow active-word), **karaoke** (4-word chunks, green highlight), **minimal** (clean Helvetica).

```bash
whisper /tmp/clipify/clip_panned.mp4 --model tiny.en --word_timestamps True --output_format json --output_dir /tmp/clipify --language en
python3 ~/projects/clipify/scripts/build_ass.py /tmp/clipify/clip_panned.json /tmp/clipify/captions.ass opus
ffmpeg -y -i /tmp/clipify/clip_panned.mp4 -vf "subtitles=/tmp/clipify/captions.ass" -c:v libx264 -preset fast -crf 20 -c:a copy "$OUTPUT.mp4"
```

### Step 6 — Deliver

- Save to `<source_dir>/clipify_out/`
- Print: name, duration, what was funny, output path
- Open first output for review
- Offer to iterate

## Pitfalls

- Don't over-tune ROIs (2 iterations max)
- Check for scene cuts in clip (`select='gt(scene,0.3)'`)
- 4K source: downscale to 1080p first or double all coordinates
- Whisper the trimmed clip (not full source) for caption timestamps
- If source has burned-in subs, use `audio_align.py` to find clean master

## Requirements

- ffmpeg with libx264 AND libass (for subtitle burn). Check: `ffmpeg -filters 2>&1 | grep subtitles`. The default Homebrew ffmpeg formula does NOT include libass. Use the homebrew-ffmpeg tap: `brew tap homebrew-ffmpeg/ffmpeg && brew uninstall --ignore-dependencies ffmpeg && brew install homebrew-ffmpeg/ffmpeg/ffmpeg`. If brew complains about outdated CLT, run `softwareupdate --install "Command Line Tools for Xcode <version>"` first (check `softwareupdate --list` for the exact label).
- whisper (openai-whisper): `brew install openai-whisper` or `pip install openai-whisper`
- Python 3 + numpy
- macOS recommended (VideoToolbox), works on Linux without hwaccel flag

## Workaround if no libass

If ffmpeg lacks the `subtitles`/`ass` filter, use `drawtext` as a fallback for simple captions (one word at a time, less pretty but functional). Or reinstall ffmpeg with libass.
