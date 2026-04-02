---
name: character-creation
description: Create and manage consistent AI video characters — define the persona, generate the portrait with Nano Banana, and store the config for reuse across all videos in the series.
---

# Character Creation

Design a character once. Reuse it forever.

A character is: a name, a personality, a visual identity (portrait image), and a voice archetype. Every video in a series pulls from the same config so the character stays consistent across 100 episodes.

Characters are stored at `~/clawd/characters/<slug>/`.

---

## Step 1: Define the Character

Before touching Nano Banana, answer these questions:

| Field | Description | Example |
|-------|-------------|---------|
| **Name** | Character's on-screen name | "Max", "Dr. Erica", "The Analyst" |
| **Slug** | Filesystem-safe ID | `max`, `dr-erica`, `the-analyst` |
| **Platform** | Primary target | TikTok, Reels, Shorts |
| **Niche / Topic** | What does this character talk about? | Investing, personal finance, crypto |
| **Personality** | 3 adjectives max | Confident, dry, contrarian |
| **Speech style** | How they talk | Short sentences. No hedging. Uses "here's the thing:" a lot. |
| **Voice archetype** | For ElevenLabs selection | Deep male, mid-range female, energetic young male |
| **Visual style** | Overall aesthetic | Photorealistic, 3D animated, illustrated |
| **Appearance** | Age, ethnicity, clothing, setting | 35yo, business casual, minimalist office background |

Save answers — you'll use them in every step.

---

## Step 2: Generate the Portrait

Two images required: **portrait** (for thumbnails, branding) and **face reference** (for InfiniteTalk consistency).

### Portrait (9:16 for TikTok/Reels)

```bash
uv run ~/clawd/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "<appearance description>, looking directly at camera, confident expression, <visual style>, professional lighting, clean background" \
  --filename "~/clawd/characters/<slug>/portrait-$(date +%Y-%m-%d).png" \
  --aspect-ratio 9:16 \
  --resolution 2K \
  --thinking high
```

### Face Reference (1:1 for InfiniteTalk)

```bash
uv run ~/clawd/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "<appearance description>, extreme close-up headshot, neutral expression, facing forward, <visual style>, studio lighting, white background" \
  --filename "~/clawd/characters/<slug>/face-ref-$(date +%Y-%m-%d).png" \
  --aspect-ratio 1:1 \
  --resolution 2K \
  --thinking high
```

### Iteration

- Start at `--resolution 512` for fast drafts. Lock the look first.
- Once approved, regenerate at `2K` with `--thinking high`.
- If 80% is right, edit: `--input-image` the draft + prompt the specific fix.
- For consistency across future regenerations: always pass the approved face reference as `--input-image` with `"Keep the person's facial features exactly the same as the input image"`.

---

## Step 3: Save the Config

Create `~/clawd/characters/<slug>/config.json`:

```json
{
  "name": "Max",
  "slug": "max",
  "platform": "TikTok",
  "niche": "Investing / Stock Market",
  "personality": ["confident", "dry", "contrarian"],
  "speech_style": "Short punchy sentences. No hedging. Calls out conventional wisdom. Uses 'here's the thing:' as a transition.",
  "voice_archetype": "Deep male, 35-45yo, measured pace, slight edge",
  "elevenlabs_voice_id": "",
  "visual_style": "Photorealistic",
  "appearance": "35yo male, sharp jawline, business casual (navy blazer, no tie), minimalist modern office background, warm key light from left",
  "portrait": "portrait-2026-03-03.png",
  "face_ref": "face-ref-2026-03-03.png",
  "created": "2026-03-03",
  "accounts": {
    "tiktok": "",
    "reels": "",
    "shorts": ""
  }
}
```

Fill in `elevenlabs_voice_id` after selecting/cloning the voice in ElevenLabs. Fill in `accounts` with platform handles once set up.

---

## Step 4: Verify Consistency

Before the character is production-ready, generate 3 test images using the face reference as input and verify:

- Same facial features across all 3
- Expression changes work (neutral, smile, serious)
- The character reads clearly at thumbnail size (small screen test)

If consistency breaks: pass 2-3 approved reference images simultaneously via comma-separated `--input-image`.

---

## Character Directory Structure

```
~/clawd/characters/
  max/
    config.json
    portrait-2026-03-03.png
    face-ref-2026-03-03.png
  dr-erica/
    config.json
    portrait-2026-03-03.png
    face-ref-2026-03-03.png
```

---

## When to Create a New Character

- New account on a new platform with a different niche or tone
- Series concept that needs a visually distinct persona
- A/B testing two character styles on the same niche

**Don't** create a new character just because you're starting a new series. If the niche and platform match, reuse the existing character — that's the whole point.

---

## Downstream Usage

Once a character is created:

- **Scripts** → `content-strategy` skill (Video Series section) writes the episode scripts in the character's voice
- **Audio** → ElevenLabs, using `elevenlabs_voice_id` from config
- **Video** → InfiniteTalk, using `face_ref` image + ElevenLabs audio
- **Scheduling** → upload the output MP4 to your platform of choice
