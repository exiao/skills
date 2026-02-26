---
name: image-generator
description: "Use when generate article visuals: diagrams, hero images, screenshots."
---

# Image Generator Skill

Generate article visuals — diagrams, hero images, and screenshots for blog posts.

## Visual Types

### 1. Excalidraw Diagrams

Use the excalidraw skill (`~/clawd/skills/excalidraw/SKILL.md`).

**What to make:**
- Architecture diagrams (system flows, data pipelines)
- Comparison matrices (2x2 grids, feature comparisons)
- Process flows (step 1 → step 2 → step 3)
- Concept visualizations (abstract ideas made concrete)
- Before/after comparisons
- Timeline diagrams

**Rules:**
- Clean, minimal, consistent colors
- Label everything
- Simple enough to understand in 3 seconds

**Save to:** `marketing/substack/drafts/[slug]/images/`

### 2. Nano Banana Pro

Use the nano-banana-pro skill.

**What to make:**
- Hero images for article headers
- Illustrations for concepts
- Thumbnails for social promotion

**Rules:**
- High brightness, high saturation
- Must work at small sizes (social thumbnails)
- Text overlays should be readable
- Style consistent across articles

**Save to:** `marketing/substack/drafts/[slug]/images/`

### 3. Screenshots

Capture real UI, conversations, and data.

**What to capture:**
- App UI (Bloom app, terminal output, code)
- Conversations (Signal messages, chat interfaces)
- Dashboards (analytics, metrics)

**Tools:** Use peekaboo skill for macOS UI capture if needed.

**Rules:**
- Crop tight
- Annotate with arrows/highlights if needed
- Redact sensitive info

**Save to:** `marketing/substack/drafts/[slug]/images/`

## Process

1. Read the approved outline from outline-generator
2. For each `[DIAGRAM:]`, `[IMAGE:]`, `[SCREENSHOT:]` placeholder, determine which tool to use
3. Generate/capture each visual
4. Save all to the article's images directory
5. Create an images manifest (`images/manifest.md`) listing each image with filename, type, alt text, and which section it belongs to

## Image Alt Text Rules (SEO)

- Describe the image content with keywords where natural
- Keep under 125 characters
- Don't start with "Image of" or "Picture of"

## References

- **Input:** outline-generator skill (provides image placeholders)
- **Output:** Feeds into article-writer skill (embeds images in draft)
