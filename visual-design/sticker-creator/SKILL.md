---
name: sticker-creator
description: Create die-cut sticker style cards via Nano Banana Pro. Use for social media cards, earnings cards, brand stickers, announcement cards, and any content formatted as a bold, clean sticker with a thick white border.
---

# Sticker Creator

Generates die-cut sticker style cards using Nano Banana Pro. Output is a 1080×1080 PNG.

---

## Tools

| Tool | Purpose |
|------|---------|
| `nano-banana-pro` skill | Image generation via Gemini |

---

## Core Design Language

These rules apply to every sticker unless explicitly overridden:

| Element | Spec |
|---------|------|
| Canvas | 1080×1080 px, aspect ratio 1:1 |
| Orientation | **Perfectly upright. 0° rotation. No tilt. No skew. Ever.** |
| Border | Thick white die-cut border (~16px), soft drop shadow |
| Corner radius | Large rounded corners (~32px) |
| Background | Dark navy `#0f172a` (default) — overridable |
| Primary text | Bold white, large, top-left |
| Accent color | Teal/cyan `#22d3ee` for key values (default) — overridable |
| Callout box | Dark rounded pill/box for "Watch:", "Key:", or annotation text |
| Wordmark | "Bloom" in muted gray, bottom-right |
| Feel | Financial data card — confident, clean, minimal decoration |

**Always include this verbatim in every Nano Banana prompt:**
> `perfectly upright, zero rotation, no tilt, no skew, card sits flat and square`

---

## Step 1 — Resolve GEMINI_API_KEY

```bash
GEMINI_API_KEY=$(python3 -c "
import json, os
d = json.load(open(os.path.expanduser('~/.clawdbot/clawdbot.json')))
print(
  d.get('skills',{}).get('entries',{}).get('nano-banana-pro',{}).get('apiKey','')
  or d['env']['vars'].get('GEMINI_API_KEY','')
)" 2>/dev/null)
export GEMINI_API_KEY
```

---

## Step 2 — Build the Prompt

Start from the appropriate template below, then customize for the content.

### Financial / Earnings Card

```
Dark navy #0f172a background, die-cut sticker with thick white border and soft drop shadow,
large rounded corners, perfectly upright, zero rotation, no tilt, no skew, card sits flat and square.

Top-left: bold white ticker "$[TICKER]" in very large type.
Below ticker: "[Subtitle line]" in small muted gray text.

Center section:
- "Est. EPS: [value]" — label in white, value in teal/cyan bold
- "Est. Rev: [value]" — label in white, value in teal/cyan bold

Bottom: dark rounded box containing "Watch:" in teal bold followed by "[watch text]" in white.
Bottom-right: "Bloom" wordmark in muted gray.

Style: clean financial data card, no gradients, no decorative elements.
```

### Announcement / General Card

```
Dark navy #0f172a background, die-cut sticker with thick white border and soft drop shadow,
large rounded corners, perfectly upright, zero rotation, no tilt, no skew, card sits flat and square.

Top: "[Headline]" in bold white, large type.
Center: "[Body text or key stat]" in [accent color] bold.
Bottom: dark rounded pill containing "[Callout text]" in white.
Bottom-right: "Bloom" wordmark in muted gray.

Style: clean, confident, minimal decoration.
```

### Brand / Logo Sticker

```
[Background color] background, die-cut sticker with thick white border and soft drop shadow,
large rounded corners, perfectly upright, zero rotation, no tilt, no skew, card sits flat and square.

Center: "[Brand name or logo text]" in bold [color], very large.
[Optional tagline in small muted text below]

Style: clean brand mark, no gradients, no decorative elements.
```

---

## Step 3 — Generate

```bash
OUTFILE="/tmp/sticker-[name]-$(date +%Y%m%d-%H%M%S).png"

uv run /opt/homebrew/lib/node_modules/clawdbot/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "[assembled prompt]" \
  --filename "$OUTFILE" \
  --resolution 2K
```

- Always use `--resolution 2K` for finals (crisp at 1080×1080)
- Do NOT pass `--thinking` — `high` times out, `dynamic` throws a parameter conflict; default works fine
- Output path: `/tmp/sticker-[descriptive-name]-YYYYMMDD-HHMMSS.png`
- **exec timeout: 300s minimum** — image generation at 2K takes 60–120s; use `timeout=300, yieldMs=280000`

---

## Step 4 — Review & Iterate

After generation, show the image to the user. Common issues and fixes:

| Issue | Fix |
|-------|-----|
| Card is tilted | Add "perfectly upright, zero rotation, no tilt, card sits flat and square" — Gemini interprets "sticker" as rotated; override explicitly |
| Text too small | Add "large bold text, high contrast, easy to read at a glance" |
| Colors wrong | Specify exact hex codes in the prompt |
| Border too thin | Add "very thick white border, prominent die-cut effect" |
| Too decorative | Add "no gradients, no textures, flat clean design" |

If the first result is off, regenerate with a more explicit prompt — don't accept a tilted or messy card.

---

## Common Mistakes

1. **Tilted output** — must include "perfectly upright, zero rotation, no tilt, no skew, card sits flat and square" verbatim in every prompt. Non-negotiable.
2. **Using `--thinking` flag** — `high` times out, `dynamic` throws a parameter conflict. Omit the flag entirely; default quality is sufficient.
3. **Using `--resolution 1K` for finals** — always use `2K` for anything that gets posted.
4. **Vague prompts** — specify hex colors, exact text, font weight. Don't leave it to interpretation.
5. **PIL fallback** — never fall back to PIL. If Nano Banana fails, report the failure.
