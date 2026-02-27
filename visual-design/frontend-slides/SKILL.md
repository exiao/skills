---
name: frontend-slides
description: Use when creating animation-rich HTML presentations or convert PPT to web.
---
# Frontend Slides Skill

Create zero-dependency, animation-rich HTML presentations that run entirely in the browser. This skill helps non-designers discover their preferred aesthetic through visual exploration ("show, don't tell"), then generates production-quality slide decks.

## Core Philosophy

1. **Zero Dependencies** — Single self-contained HTML files. No npm, no build tools.
2. **Show, Don't Tell** — Generate visual previews; people don't know what they want until they see it.
3. **Distinctive Design** — Avoid generic "AI slop" aesthetics. Every deck should feel custom-crafted.
4. **Production Quality** — Well-commented, accessible, performant code.
5. **Viewport Fitting (NON-NEGOTIABLE)** — Every slide MUST fit exactly in the viewport. No scrolling within slides. Ever.

## Phase 0: Detect Mode First

Before anything else, identify which mode applies:

| Mode | Trigger | Go to |
|------|---------|-------|
| **A: New Presentation** | Creating from scratch | Phase 1 (Content Discovery) |
| **B: PPT Conversion** | User has a .ppt/.pptx file | Phase 4 (PPT Extraction) |
| **C: Enhancement** | Existing HTML presentation to improve | Read file → enhance |

## Core Workflow (New Presentation)

1. **Phase 1 — Content Discovery:** Extract topic, key messages, audience, tone, slide count.
2. **Phase 2 — Style Discovery:** Generate 3 visual thumbnails (different aesthetics). User picks or mixes. Never ask abstract style questions.
3. **Phase 3 — Generate Presentation:** Build the full HTML file based on content + chosen style.
4. **Phase 4 (if PPT) — Extract & Convert:** Parse PPTX structure, preserve layout intent, elevate with web animations.
5. **Phase 5 — Deliver:** Output as a single `.html` file. Include keyboard nav, swipe support, progress bar.

## Generating the Presentation (Phase 3)

### Required HTML Architecture
- One `.html` file; all CSS/JS inline
- `<section class="slide">` per slide
- CSS custom properties (`:root { --accent: ...; --title-size: clamp(...); }`) for easy theming
- `SlidePresentation` JS class: keyboard nav (arrows, space), touch/swipe, mouse wheel, progress bar, nav dots
- `IntersectionObserver` for scroll-triggered `.reveal` animations

### Required JavaScript Features
Every presentation needs:
- Keyboard navigation (← → Space)
- Touch/swipe support
- Mouse wheel navigation
- Progress bar updates
- Navigation dots
- Scroll-triggered animations via `IntersectionObserver`

Optional enhancements (based on chosen style): custom cursor, particle backgrounds, parallax, 3D tilt, magnetic buttons, counter animations.

### Code Quality
- Comment every section: what it does, why, how to modify
- Semantic HTML (`<section>`, `<nav>`, `<main>`)
- ARIA labels where needed
- `prefers-reduced-motion` support

## CRITICAL: Viewport Fitting Requirements

**The Golden Rule:** Each slide = exactly one viewport height (`100vh`/`100dvh`). Content overflows? Split into multiple slides. Never allow scrolling within a slide.

### Mandatory CSS for Every Presentation
```css
html { scroll-snap-type: y mandatory; height: 100%; }
body { height: 100%; overflow-x: hidden; }

.slide {
  width: 100vw;
  height: 100vh;
  height: 100dvh;        /* mobile browsers */
  overflow: hidden;      /* CRITICAL */
  scroll-snap-align: start;
  display: flex;
  flex-direction: column;
  position: relative;
}

/* ALL typography and spacing must use clamp() */
:root {
  --title-size: clamp(1.5rem, 5vw, 4rem);
  --body-size: clamp(0.75rem, 1.5vw, 1.125rem);
  --slide-padding: clamp(1rem, 4vw, 4rem);
}
```

### Content Density Limits (per slide)
| Slide Type | Max Content |
|------------|-------------|
| Title | 1 heading + 1 subtitle + optional tagline |
| Content | 1 heading + 4–6 bullets OR 2 paragraphs |
| Feature grid | 1 heading + 6 cards max |
| Code | 1 heading + 8–10 lines |
| Quote | 1 quote (3 lines max) + attribution |
| Image | 1 heading + 1 image (max 60vh) |

**If content exceeds limits → split into multiple slides, never scroll.**

### Responsive Breakpoints Required
```css
@media (max-height: 700px) { /* reduce padding + font sizes */ }
@media (max-height: 600px) { /* hide decorative elements */ }
@media (max-height: 500px) { /* extra compact for landscape phones */ }
@media (max-width: 600px)  { /* stack grids, larger font scale */ }
```

### Pre-Generation Checklist
- ✅ Every `.slide` has `height: 100vh; height: 100dvh; overflow: hidden;`
- ✅ All font sizes use `clamp()`
- ✅ All spacing uses `clamp()` or viewport units
- ✅ Content containers have `max-height` constraints
- ✅ Images constrained to `max-height: min(50vh, 400px)`
- ✅ Grids use `auto-fit` with `minmax()`
- ✅ Breakpoints for heights: 700px, 600px, 500px

## Output Format

A single self-contained `presentation.html` file (or `[name].html`) with all CSS/JS inline. No external dependencies except optional web fonts (Fontshare/Google Fonts).

---

## References

This skill content is modularized into reference docs for readability.

- [Core Philosophy](references/core-philosophy.md)
- [CRITICAL: Viewport Fitting Requirements](references/critical-viewport-fitting-requirements.md)
- [Phase 0: Detect Mode](references/phase-0-detect-mode.md)
- [Phase 1: Content Discovery (New Presentations)](references/phase-1-content-discovery-new-presentations.md)
- [Phase 2: Style Discovery (Visual Exploration)](references/phase-2-style-discovery-visual-exploration.md)
- [Phase 3: Generate Presentation](references/phase-3-generate-presentation.md)
- [Phase 4: PPT Conversion](references/phase-4-ppt-conversion.md)
- [Phase 5: Delivery](references/phase-5-delivery.md)
- [Style Reference: Effect → Feeling Mapping](references/style-reference-effect-feeling-mapping.md)
- [Animation Patterns Reference](references/animation-patterns-reference.md)
- [Troubleshooting](references/troubleshooting.md)
- [Related Skills](references/related-skills.md)
- [Example Session Flow](references/example-session-flow.md)
- [Conversion Session Flow](references/conversion-session-flow.md)
