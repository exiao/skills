---
name: auto-captions
description: Generate styled, word-by-word highlighted captions (karaoke-style like CapCut) and burn them into video files. Full pipeline from transcription to styled ASS subtitles to final render. Use whenever the user mentions adding captions, subtitles, burning in captions, word-by-word highlight, karaoke captions, caption styling, TikTok captions, Reel captions, auto-subtitle, transcribe and overlay, or any request to put text on video with timing. Also use when the user wants to style existing subtitles, generate SRT/ASS files from video, or create social media videos with pop-in word animations.
---

# Auto Captions

Generate styled, word-by-word highlighted captions and burn them into video. The current word lights up as it's spoken, CapCut/karaoke style.

## Pipeline

1. Extract audio from video (ffmpeg)
2. Transcribe with word-level timestamps (stable-ts / Whisper)
3. Generate styled ASS subtitle file with per-word karaoke highlighting
4. Burn captions into video with ffmpeg

## Quick Start

In examples below, `{baseDir}` means the skill directory (e.g. `~/clawd/skills/auto-captions`); replace with that path or run from that directory.

```bash
# Full pipeline: transcribe + style + burn in
python3 {baseDir}/scripts/caption.py input.mp4 -o output.mp4

# With a style preset
python3 {baseDir}/scripts/caption.py input.mp4 -o output.mp4 --preset tiktok

# Just generate the ASS subtitle file (no burn-in)
python3 {baseDir}/scripts/caption.py input.mp4 --ass-only -o captions.ass

# Custom styling
python3 {baseDir}/scripts/caption.py input.mp4 -o output.mp4 \
  --font "Montserrat" --font-size 72 --highlight-color "&H0000FFFF" \
  --words-per-block 3 --position bottom
```

## Dependencies

Install before first use:

```bash
pip install stable-ts
```

ffmpeg must be installed (brew install ffmpeg). Whisper model auto-downloads on first run (~140MB for "base").

## Style Presets

| Preset | Look | Details |
|--------|------|---------|
| `tiktok` (default) | Yellow active word, inactive semi-transparent white | Montserrat Bold 68px, 4px outline, bottom-center, 3 words/block |
| `minimal` | Clean sans-serif, subtle shadow | Helvetica 54px, thin outline, soft shadow, center, 4 words/block |
| `bold` | Large yellow highlight on white base | Impact 80px, yellow active word, white inactive words, dark outline, 3 words/block |

**How presets highlight differently:** `tiktok` uses color contrast (active word is yellow, inactive are semi-transparent white). `minimal` uses opacity contrast (active word is fully opaque, inactive words are semi-transparent). `bold` uses color contrast (active word is yellow, inactive are white). For a visible color pop like CapCut, use `tiktok`, `bold`, or set `--highlight-color` to a bright color on any preset.

## CLI Options

| Flag | Default | Description |
|------|---------|-------------|
| `--preset` | `tiktok` | Style preset: tiktok, minimal, bold |
| `--font` | (from preset) | Font family name |
| `--font-size` | (from preset) | Font size in pixels |
| `--highlight-color` | (from preset) | ASS color for the active word (format: `&HAABBGGRR`) |
| `--base-color` | (from preset) | ASS color for inactive words |
| `--outline-color` | `&H00000000` | Outline color |
| `--outline-width` | (from preset) | Outline thickness |
| `--shadow-depth` | (from preset) | Shadow distance |
| `--words-per-block` | (from preset) | Words shown per caption block (3-4 typical) |
| `--position` | `bottom` | Caption position: top, center, bottom |
| `--margin-bottom` | `150` | Bottom margin in pixels (avoids platform UI) |
| `--margin-top` | `100` | Top margin in pixels |
| `--resolution` | auto-detect | Video resolution (e.g., 1080x1920) |
| `--model` | `base` | Whisper model size: tiny, base, small, medium, large |
| `--ass-only` | false | Only generate the .ass file, skip burn-in |
| `--crf` | `18` | Video quality (lower = better, 18 is visually lossless) |
| `--pop-in` | true | Enable per-word pop-in scale animation |
| `--language` | auto | Language code for transcription (e.g., en, es, ja) |

## ASS Color Format

ASS uses `&HAABBGGRR` (alpha, blue, green, red). Common colors:
- White: `&H00FFFFFF`
- Yellow: `&H0000FFFF`
- Red: `&H000000FF`
- Cyan: `&H00FFFF00`

## Vertical Video (TikTok/Reels)

The script detects vertical video (height > width) and applies default margins sized for platform UI:
- Top 100px reserved (status bar / back button)
- Bottom 150px reserved (TikTok controls / description)

These defaults apply to all videos; override with `--margin-top` and `--margin-bottom`.

## How the Karaoke Highlighting Works

The ASS subtitle format supports karaoke timing tags:
- `\kf<duration>` fades the highlight onto each word over `<duration>` centiseconds
- `\k<duration>` snaps the highlight instantly

Each caption block shows N words at once. The currently spoken word renders in the highlight color while other words stay in the base color. When all words in a block are spoken, the next block appears.

The pop-in animation uses `\fscx` and `\fscy` (scale) tags to animate each word from 80% to 100% size over 50ms as it becomes active.

## Troubleshooting

**"No module named stable_ts"**: Run `pip install stable-ts`. If using a venv, activate it first.

**Fonts not rendering**: ffmpeg uses fontconfig. Run `fc-list | grep "FontName"` to check availability. On macOS, system fonts work. For custom fonts, place .ttf/.otf in `~/.fonts/` and run `fc-cache -f`.

**Slow transcription**: Use `--model tiny` for faster results (lower accuracy). Use `--model large` for best accuracy on difficult audio.

**Out of sync captions**: stable-ts handles this well, but if audio has long silences or music, try `--model medium` or `--model large` for better alignment.
