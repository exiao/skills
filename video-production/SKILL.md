---
name: video-production
description: Router skill — dispatches video tasks to the right sub-skill.
---

# Video Production Router

This skill routes video tasks to the correct sub-skill. Read the task, pick the tool, follow that sub-skill's SKILL.md.

## Sub-skill Map

| Sub-skill | What it does | Use when |
|-----------|-------------|----------|
| **sora** | OpenAI Sora API — generates or remixes short AI video clips from text/image prompts | You need a rendered MP4 from a text/image prompt; cinematic shots, social ads, UGC-style content, product teasers |
| **kling** | Prompt engineering for Kling 3.0 AI video | The user explicitly mentions Kling, or wants film-director-style prompts crafted for that specific model |
| **remotion-videos** | React/code animated marketing videos → MP4/GIF file | Branded animated video that needs precise programmatic control, captions, batch rendering, or a reusable composition |
| **browser-animation-video** | Motion graphics via Framer Motion + GSAP, runs in-browser | High-fidelity motion piece that lives on the web, plays in-page, or needs to be screen-recorded; no file output required |
| **demo-video** | Records real browser interactions via Playwright CDP | Walkthrough or product demo of an actual running web app; capturing real UI |
| **gemini-svg** | AI-generated interactive SVG animations (Gemini) | Small UI components, decorative animations, data viz, icons, or anything SVG-sized and interactive in a browser |

## Routing Logic

**Auto-route (clear signal → act immediately):**
- "generate a video of…" / "make a clip of…" / "Sora…" → **sora**
- "Kling prompt" / "write a Kling…" → **kling**
- "Remotion" / "render an MP4" / "animated marketing video in code" → **remotion-videos**
- "motion graphics" / "Framer Motion" / "GSAP animation" / "brand video for the web" → **browser-animation-video**
- "record a demo" / "walkthrough video" / "screen-record the app" → **demo-video**
- "SVG animation" / "animated icon" / "Gemini SVG" → **gemini-svg**

**Ambiguous cases — ask the user:**
- "Make me a video" with no other context → ask: *Do you want (a) AI-generated footage, (b) a coded animation, or (c) a screen recording of a real app?*
- "Animated video" without specifying output format or tech → clarify: web embed vs. MP4 file
- "Product video" — could be sora (AI footage), remotion-videos (coded), or demo-video (recorded walkthrough) → ask which
- Both sora and kling apply when the user wants AI video but hasn't named a model → default to **sora** (has a working API integration); mention Kling as an alternative if they want to use that platform instead

## How to Execute

Once routed:
1. Read `~/clawd/skills/video-production/<sub-skill>/SKILL.md` fully.
2. Follow its workflow exactly — do not improvise around its conventions.
3. Sub-skill files are authoritative; this router is just dispatch.
