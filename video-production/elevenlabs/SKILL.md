---
name: elevenlabs
description: Generate voiceover audio from a script using ElevenLabs v3 via Fal.ai. Outputs an MP3 file for use with InfiniteTalk or standalone audio.
---

# ElevenLabs TTS

Converts a script into speech audio via ElevenLabs Eleven v3, hosted on Fal.ai. No GPU required — cloud API, pay-per-use.

**API:** Fal.ai (`FAL_KEY` env var)
**Model ID:** `fal-ai/elevenlabs/tts/eleven-v3`

---

## Quick Usage

```bash
uv run ~/clawd/skills/video-production/elevenlabs/scripts/tts.py \
  --text "The market just shifted. Here's what most people are missing." \
  --voice "Alice" \
  --output ~/clawd/characters/max/audio/2026-03-03-episode-1.mp3
```

---

## Parameters

| Flag | Required | Default | Notes |
|------|----------|---------|-------|
| `--text` | ✅ | — | The script text to speak |
| `--voice` | — | `Rachel` | See voice list below |
| `--stability` | — | `0.5` | 0-1; higher = more monotone, lower = more expressive |
| `--output` | — | `~/clawd/output/tts-<timestamp>.mp3` | Output path |
| `--language` | — | auto | ISO 639-1 code (e.g. `en`, `es`) |

## Available Voices

Aria, Roger, Sarah, Laura, Charlie, George, Callum, River, Liam, Charlotte, Alice, Matilda, Will, Jessica, Eric, Chris, Brian, Daniel, Lily, Bill, Rachel

Pick the voice that matches your character's archetype. Store the chosen voice name in the character's `config.json` under `elevenlabs_voice`.

---

## Output

The script prints the saved path on completion:
```
AUDIO: /Users/testuser/clawd/characters/max/audio/2026-03-03-episode-1.mp3
```

---

## Pricing (via Fal.ai)

Billed per character. Estimated: ~$0.001/word. A 60-second script (~150 words) costs roughly $0.15.

---

## Setup

Requires `FAL_KEY` in env (add to `~/.openclaw/openclaw.json` under `env`):
```bash
pip install fal-client
```

---

## Realism Rule: Background Noise

**Clean audio sounds fake.** A perfect studio recording is an instant AI tell in a UGC context.

After generating the MP3, add ambient background noise before feeding it to InfiniteTalk:

```bash
# Mix in light ambient noise at low volume (-18dB)
ffmpeg -i output.mp3 -i /path/to/ambient.mp3 \
  -filter_complex "[1:a]volume=-18dB[noise];[0:a][noise]amix=inputs=2:duration=first" \
  output_with_noise.mp3
```

Good ambient sources: coffee shop hum, light room tone, street noise. Keep it under -18dB — the goal is texture, not distraction. For indoor talking-head UGC, light room tone works best.

---

## In the Pipeline

1. Write script → `content-strategy` (Video Series section)
2. **Generate audio → this skill** (`tts.py --text "..." --voice "Alice"`)
3. Generate video → `infinitetalk` sub-skill (passes `--audio` output from this step)
