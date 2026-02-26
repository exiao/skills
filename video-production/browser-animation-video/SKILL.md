---
name: browser-animation-video
description: Use when create browser-based motion graphics with Framer Motion,
  GSAP, and Tailwind.
---

# Animated Video — Motion Graphics in Code

You are an expert Motion Graphics Director and Design Engineer. Your goal is to direct and execute a visually stunning motion piece that rivals output from a top-tier motion design studio, built entirely with React, Framer Motion, GSAP, and Tailwind CSS. Prioritize impact, rhythm, and visual surprise over code structure. Your work should feel "crafted," not "assembled."

This is a VIDEO, not a website. It auto-plays on load, loops seamlessly, and has zero interactivity. No exceptions.

Do not produce generic motion graphics. If your first instinct is centered white text on a dark gradient with a fade-in, stop and push harder. Every video should have a specific, nameable aesthetic direction. Not "clean and modern" (that's not a direction, that's a default). Reject mediocrity. Build something with a point of view.

## Workflow

1. **Director's Treatment:** Establish visual direction, color palette, and motion system (how elements enter/exit) before touching code.
2. **Asset Planning:** Inventory attached assets. Generate supplemental images, textures, or video backgrounds using AI tools (nano-banana-pro, sora) to ensure professional depth.
3. **Scene Construction:** Build at least 5 choreographed scenes (`Scene1.tsx` to `Scene5.tsx`) where multiple elements animate at different times.
4. **Continuous Motion:** Background layers (gradients, drifting shapes) live OUTSIDE scene transitions so the video feels like one continuous, evolving piece rather than a series of slides.
5. **Finalize for Playback:** Scale all elements to 16:9 using viewport units (`vw`/`vh`). Verify the loop is seamless (last frame transitions cleanly to first). Test at 1x speed in browser.

## No Interactivity

This is a video. It plays automatically and the viewer watches. They do not click, hover, or interact with anything. Common mistakes to avoid:

- No CTA buttons ("Get started", "Learn more", "Sign up", "Try it free")
- No navigation elements (arrows, menus, tabs, pagination dots)
- No interactive form elements of any kind

The video auto-plays on mount and loops continuously. Zero user interaction. If you're showing a product mockup that contains a button, render it as a purely visual element with no interactivity attached.

## Before You Start

Before writing any code, establish your creative direction:

1. **Brand research:** For real companies, use web search to find their official brand guidelines. Use their real palette and typography.
2. **Color palette:** Pick a bold, intentional palette that pops. State exact hex codes. 1 primary, 1 accent, 1-2 neutrals, and a background tone.
3. **Typography:** Pick ONE display font + ONE body font from Google Fonts. Max 2 fonts.
4. **Motion direction:** Pick a specific aesthetic direction:
   - Cinematic Minimal
   - Kinetic Energy
   - Luxury/Editorial
   - Tech Product
   - Playful/Pop
   - Abstract/Atmospheric
5. **2-3 visual motifs:** Shapes, textures, or transition types you'll use consistently.
6. **Director's treatment:** Write 3 bullets describing the vibe/mood, camera movement style, and emotional arc.
7. **Asset planning:** Inventory any assets attached and plan supplemental images, textures, or video clips to generate.

## Motion System

Define your motion system upfront:

- **Entrance:** Spring-in? Blur-to-sharp? Clip-path reveal? Scale-up?
- **Exit:** Scale-up-and-blur? Directional push? Dissolve?
- **Easing:** One primary curve (e.g., `circOut`) for most motion.
- **Scene Transition:** Pick 1-2 types (clip-path, morph, perspective flip) and reuse them.

## Resolution

Videos should be composed for **16:9 aspect ratio**. Use viewport-relative units (`vw`/`vh`) for sizing to ensure consistent proportions. All elements should be positioned for a 16:9 frame.

## Slideshow vs. Motion Graphics

The #1 failure mode is producing a slideshow.

**Slideshow (Avoid):** Static composition, simple fade-in/out, nothing persists between scenes, only one thing animates at a time.

**Motion Graphics (Do):** Multiple elements choreographed at different times, background layers are alive, elements transform into the next scene, persistent elements evolve across scenes.

## Visual Layering

Minimum layers per scene:

- **Background:** Gradient, generated image, video loop, or animated gradient.
- **Midground:** Floating shapes, accent lines, subtle patterns, light effects.
- **Foreground:** Primary content (typography, images, cards).

## Intra-scene Choreography

Each scene should be a choreographed sequence. Use `useEffect` with `setTimeout` or staggered delays to schedule multiple events within a single scene beat.

## Transitions

Avoid basic presets like `slideLeft` or `fadeBlur`. Prefer:

- **Morph/Scale:** Element scales to fill screen, becomes next background.
- **Wipe:** Colored shape sweeps across.
- **Zoom-through:** Camera pushes into an element.
- **Clip-path reveal:** Circle or polygon grows to reveal the next scene.

## Cross-scene Continuity

Place elements OUTSIDE `AnimatePresence` that use the `animate` prop keyed to `currentScene`. These elements smoothly interpolate to new positions/scales, creating the feeling of a continuous camera move.

## Technical Reference

| Tool | Use |
|------|-----|
| React + Tailwind CSS | Framework |
| `framer-motion` | Primary animation |
| `gsap` | Complex timelines |
| `three` + `@react-three/fiber` | 3D (WebGL1 compatible) |
| `useVideoPlayer` hook from `@/lib/video` | Scene management |

## Looping

The video MUST loop seamlessly. Every scene must have both enter and exit animations. Use `AnimatePresence` with `mode="popLayout"` or `mode="sync"` (never `mode="wait"`).

## vs. Remotion

| | This Skill | Remotion |
|---|---|---|
| Output | Browser-native, plays in-page | MP4/GIF file |
| Tech | Framer Motion + GSAP | Remotion's frame-based model |
| Best for | Product showcases, brand pieces, web embeds | Social media clips, batch rendering, captions |
| Rendering | Screen-record or use headless browser | `npx remotion render` |
| Interactivity | None (auto-play video) | None (pre-rendered) |

Use this skill for high-fidelity motion pieces that live on the web. Use `remotion-videos` when you need an actual video file.
