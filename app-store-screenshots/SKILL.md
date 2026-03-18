---
name: app-store-screenshots
description: Generate production-ready App Store marketing screenshots for iOS apps using a Next.js generator. Screenshots are designed as ads (not UI showcases) and exported at all 4 Apple-required sizes (6.9", 6.5", 6.3", 6.1"). Use when asked to create App Store screenshots, generate marketing screenshot assets, or build a screenshot page for an iOS app.
---

# App Store Screenshots Generator

Generates marketing screenshots for the App Store — advertisement-style, not UI showcases. Scaffolds a Next.js project with an iPhone mockup, renders at Apple's required resolutions, and exports PNGs via `html-to-image`.

**Source:** https://github.com/ParthJadhav/app-store-screenshots  
**Installed at:** `~/.claude/skills/app-store-screenshots`

## Export Sizes

| Display | Resolution |
|---------|-----------|
| 6.9"    | 1320×2868 |
| 6.5"    | 1284×2778 |
| 6.3"    | 1206×2622 |
| 6.1"    | 1125×2436 |

> **Note:** Use a 6.1" simulator to capture starting screenshots to avoid resizing issues.

## Key Design Principles

- Screenshots are **ads, not docs** — each slide sells one idea
- Copy follows the "one second" rule — readable at thumbnail size
- Layouts vary — no two adjacent slides share the same phone placement
- Style is user-driven — no hardcoded colors, fonts, or gradients

## How to Use

Delegate to Claude Code via acpx from the Bloom repo (or any project with the screenshots output dir):

```bash
cd ~/bloom  # or wherever the screenshots should live
acpx --approve-all claude 'Build App Store screenshots for the Bloom app.

Use the app-store-screenshots skill.

Required context:
- App screenshots: [path to raw simulator screenshots]
- App icon: [path to app icon PNG]
- Brand colors: #your-color, white text on dark bg
- Font: [font name]
- Features (priority order): [list]
- Number of slides: 6
- Style: clean/minimal, dark mode preferred

When done, run: clawdbot gateway wake --text "App Store screenshots done. Output in [dir]" --mode now'
```

## What Gets Scaffolded

```
project/
├── public/
│   ├── mockup.png          # iPhone frame (copied from skill)
│   ├── app-icon.png        # Your app icon
│   └── screenshots/        # Your raw app screenshots
├── src/app/
│   ├── layout.tsx          # Font setup
│   └── page.tsx            # Screenshot generator (single file)
└── package.json
```

Run the dev server, open `http://localhost:3000/__design_lab`, click any screenshot to export as PNG.

## Requirements

- Node.js 18+ (bun preferred)
- Raw simulator screenshots at 6.1" (1125×2436)
