---
name: nano-banana-pro
description: "Generate or edit images via Gemini 3 Pro Image Preview (Nano Banana Pro). Use when asked to generate an image, create artwork, edit a photo, add/remove elements from an image, compose multiple images, style transfer, create avatars, illustrations, or any visual content generation. Also use for 'make me an image of', 'edit this photo', 'create artwork', or 'generate a picture'."
homepage: https://ai.google.dev/
metadata:
  {
    "openclaw":
      {
        "emoji": "🍌",
        "requires": { "bins": ["uv"], "env": ["GEMINI_API_KEY"] },
        "primaryEnv": "GEMINI_API_KEY",
        "install":
          [
            {
              "id": "uv-brew",
              "kind": "brew",
              "formula": "uv",
              "bins": ["uv"],
              "label": "Install uv (brew)",
            },
          ],
      },
  }
---

# Nano Banana Pro (Gemini 3 Pro Image Preview)

Use the bundled script to generate or edit images.

Generate

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "your image description" --filename "output.png" --resolution 1K
```

Generate (pro quality)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "your image description" --filename "output.png" --resolution 1K --model pro
```

Edit (single image)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "edit instructions" --filename "output.png" -i "/path/in.png" --resolution 2K
```

Multi-image composition (up to 14 images)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "combine these into one scene" --filename "output.png" -i img1.png -i img2.png -i img3.png
```

API key

- `GEMINI_API_KEY` env var
- Or set `skills."nano-banana-pro".apiKey` / `skills."nano-banana-pro".env.GEMINI_API_KEY` in `~/.openclaw/openclaw.json`

Specific aspect ratio (optional)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "portrait photo" --filename "output.png" --aspect-ratio 9:16
```

Notes

- Models: `--model flash` (default, fast, Gemini 3.1 Flash) or `--model pro` (best quality, Gemini 3 Pro).
- Resolutions: `1K` (default), `2K`, `4K`.
- Aspect ratios: `1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `4:5`, `5:4`, `9:16`, `16:9`, `21:9`. Without `--aspect-ratio` / `-a`, the model picks freely - use this flag for avatars, profile pics, or consistent batch generation.
- Use timestamps in filenames: `yyyy-mm-dd-hh-mm-ss-name.png`.
- The script prints a `MEDIA:` line for OpenClaw to auto-attach on supported chat providers.
- Do not read the image back; report the saved path only.

## Runtime gotchas

- **Timeout:** Pro quality runs slow. Use `timeout=300, yieldMs=280000` when invoking via exec/delegate.
- **No `--thinking` flag.** The script does not accept it; Nano Banana Pro doesn't expose reasoning mode.

## Prompting Best Practices

| Bad prompt | Good prompt |
|-----------|------------|
| "a dog" | "Golden retriever puppy sitting in autumn leaves, soft natural lighting, shallow depth of field, warm tones" |
| "logo for my app" | "Minimal flat logo mark, teal gradient on white, geometric leaf shape, no text, SVG-ready clean edges" |
| "edit: make it better" | "edit: increase contrast, warm the color temperature, sharpen the subject's face, blur background slightly" |

Tips:
- Be specific about **style** (photorealistic, watercolor, flat illustration, 3D render, pixel art)
- Specify **lighting** (golden hour, studio lighting, dramatic shadows, soft diffused)
- Mention **composition** (close-up, bird's eye view, rule of thirds, centered)
- Reference known styles ("in the style of Studio Ghibli", "Wes Anderson color palette", "Bauhaus poster")
- For edits, describe the change precisely rather than vaguely
- Use `--resolution 2K` for final output; `1K` is fine for iterations

## Output Review & Iteration

After generation:
1. Report the saved file path (the `MEDIA:` line handles auto-attachment)
2. Do NOT read the image back into context with the image tool
3. If the user isn't satisfied, suggest specific prompt refinements:
   - **Wrong style?** → Add explicit style keywords
   - **Wrong composition?** → Add camera angle and framing
   - **Colors off?** → Specify a color palette or reference
   - **Text illegible?** → Gemini struggles with text; try fewer words, larger, simpler fonts
4. For iterative refinement, use edit mode (`-i previous_output.png`) with targeted instructions rather than regenerating from scratch
