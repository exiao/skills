---
name: visual-design
description: "Use when designing graphics, creating charts, data visualizations, slides, presentations, sales decks, infographics, mockups, wireframes, diagrams, UI designs, landing pages, or any visual creative output. Covers Excalidraw, D3.js, canvas HTML, image generation, and frontend design. Use for any request that produces a visual artifact."
---

# Design Visual — Router

This skill is a dispatch layer. Read the request, pick the right sub-skill, then follow that sub-skill's `SKILL.md` fully.

---

## Sub-Skills at a Glance

| Sub-skill | When to use |
|-----------|-------------|
| **canvas-design** | Creating standalone visual art / design artifacts as `.png` or `.pdf`. Philosophy-driven, museum/gallery quality, mostly visual, minimal text. |
| **d3js-visualization** | Interactive data visualizations in the browser (charts, graphs, maps, dashboards). Output is a `.html` file powered by D3.js. |
| **frontend-design** | Production-grade frontend interfaces — components, pages, apps, dashboards. Output is working HTML/CSS/JS or React/Vue. High design quality, not just functional. |
| **frontend-slides** | Animation-rich HTML slide decks for presentations. Also use for converting PPT/PPTX files to web format. Output is a self-contained `.html` file. |
| **image-generator** | Article visuals: architecture diagrams (Excalidraw), hero images, social thumbnails, screenshots. Orchestrates excalidraw + nano-banana-pro + peekaboo as needed. |
| **nano-banana-pro** | Direct image generation or editing via Nano Banana 2 (gemini-3.1-flash-image-preview). Use for hero images, illustrations, product composites, AI-generated visuals when called explicitly or when image-generator delegates here. |
| **create-a-sales-asset** | Generate sales assets (landing pages, decks, one-pagers) tailored to a prospect or audience. Full multi-phase workflow: context → research → structure → build. |
| **slideshow-creator** | Automate TikTok slideshow marketing — research, generate, post via ReelFarm, track, iterate. |
| **apple-ux-guidelines** | Apple HIG reference for UI/UX decisions on iOS, macOS, watchOS, visionOS, etc. |

---

## Routing Logic

### Auto-route (clear signal)

- "Make me a chart / graph / visualization with data" → **d3js-visualization**
- "Create a poster / art piece / design / PDF/PNG artwork" → **canvas-design**
- "Build a UI / component / page / app / dashboard" → **frontend-design**
- "Make a presentation / slide deck / convert this PPT" → **frontend-slides**
- "Generate an image / hero image / illustration / product composite" → **nano-banana-pro**
- "Create visuals for an article / blog post / diagram for a post" → **image-generator**
- "Create a sales asset / one-pager / sales deck / landing page for a prospect" → **create-a-sales-asset**
- "TikTok slideshow / ReelFarm / automate TikTok posts" → **slideshow-creator**
- "Apple HIG / Human Interface Guidelines / iOS UX / Apple design patterns" → **apple-ux-guidelines**

### Ask if ambiguous

If the request could map to more than one sub-skill, ask:

> "I can approach this a few ways — which fits best?
> - **Canvas art** (.png/.pdf design artifact)
> - **Interactive chart** (D3.js in browser)
> - **Frontend UI** (working interface/component)
> - **Slide deck** (HTML presentation)
> - **Generated image** (AI image via Gemini)
> - **Article visual** (diagram + hero image for a post)
> - **Sales asset** (landing page, deck, or one-pager for a prospect)
> - **TikTok slideshow** (ReelFarm automation pipeline)"

### Common ambiguous cases

| Request sounds like… | Likely intent | Clarify if… |
|----------------------|---------------|-------------|
| "Visualize this data" | d3js-visualization | …they want a static image → canvas-design or nano-banana-pro |
| "Design a landing page" | frontend-design | …they want a PDF mockup → canvas-design |
| "Make a diagram" | image-generator (Excalidraw) | …it's for a live app → frontend-design |
| "Create a visual for this article" | image-generator | …they want a full illustration → nano-banana-pro |
| "Generate an image" | nano-banana-pro | …it's meant for a blog → image-generator |

---

## Live Prototype Loop (for iterative visual work)

For any design that requires visual iteration (layout, spacing, colors, typography, component feel), use the live browser prototyping technique instead of rebuilding on each change:

1. Open the target in browser — local file or the app's production site (check TOOLS.md for the URL)
2. Write initial HTML/CSS or navigate to the target page
3. Use `browser action=act request={kind:evaluate, fn:"() => { /* JS to patch styles/DOM */ }"}` to apply changes live
4. Screenshot to validate — iterate until it looks right
5. Write only the final confirmed values back to the source file / PR

Production site edits via JS eval are non-persistent (reset on reload) — safe for visual exploration. Always commit final changes to the codebase.

This approach applies across all sub-skills: frontend-design, frontend-slides, d3js-visualization, and any work involving a live browser target.

---

## Execution

Once the sub-skill is identified:

1. Read that sub-skill's `SKILL.md` in full. Sub-skills live at `~/clawd/skills/visual-design/<sub-skill>/SKILL.md`. Exception: `nano-banana-pro` lives at `~/clawd/skills/nano-banana-pro/SKILL.md`.
2. Follow its instructions exactly — this router adds nothing on top.
3. Do not blend sub-skill approaches unless the user explicitly asks for both.
