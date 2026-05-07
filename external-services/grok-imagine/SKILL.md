---
name: grok-imagine
description: "Generate or edit images via xAI Grok Imagine (Aurora). Use when asked to generate images with Grok, Aurora, or xAI. Supports text-to-image, single-image editing, and multi-image composition (up to 3). Also use for 'grok imagine', 'aurora image', 'xai generate image'."
homepage: https://docs.x.ai/developers/model-capabilities/images
metadata:
  openclaw:
    emoji: "🎨"
    requires:
      bins: ["uv"]
      env: ["XAI_API_KEY"]
    primaryEnv: "XAI_API_KEY"
---

# Grok Imagine (xAI Aurora)

Use the bundled script to generate or edit images via xAI's image API.

## Generate

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "description" --filename "output.png"
```

## Generate (quality model)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "description" --filename "output.png" --model quality
```

## Edit (single image)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "edit instructions" --filename "output.png" -i /path/to/input.png
```

## Multi-image composition (up to 3)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "combine these" --filename "output.png" -i img1.png -i img2.png -i img3.png
```

## API key

- `XAI_API_KEY` env var
- Or `--api-key` / `-k` flag to override

## Notes

- Models: `--model default` (`grok-imagine-image`, fast) or `--model quality` (`grok-imagine-image-quality`, best).
- `grok-imagine-image-pro` is scheduled for deprecation on May 15, 2026. Use `quality` instead.
- Resolutions: `1k` (default), `2k`.
- Aspect ratios: `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `2:1`, `1:2`, `auto`.
- Use timestamps in filenames: `yyyy-mm-dd-hh-mm-ss-name.png`.
- Generated URLs are **temporary**; the script downloads automatically.
- The script prints a `MEDIA:` line for gateway auto-attachment.
- Do not read the image back; report the saved path only.
- Max 10 images per request via `-n`.
- `-n` is ignored for image edits (only 1 output per edit request).
- Image edits are billed for both input and output images.

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
- Use `--resolution 2k` for final output; `1k` is fine for iterations
- For multi-image composition, describe how the subjects should interact in the scene

## Output Review & Iteration

After generation:
1. Report the saved file path (the `MEDIA:` line handles auto-attachment)
2. Do NOT read the image back into context with the image tool
3. If the user isn't satisfied, suggest specific prompt refinements:
   - **Wrong style?** Add explicit style keywords
   - **Wrong composition?** Add camera angle and framing
   - **Colors off?** Specify a color palette or reference
   - **Text illegible?** Try fewer words, larger, simpler fonts
4. For iterative refinement, use edit mode (`-i previous_output.png`) with targeted instructions rather than regenerating from scratch
