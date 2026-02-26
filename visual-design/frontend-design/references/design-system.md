# Design System & UI Engineering Reference

Advanced frontend design system with tunable dials, bias corrections, performance guardrails, and a creative pattern library. Use this reference to elevate frontend-design output beyond defaults.

Load this file when the user wants to tune design parameters, needs a structured component architecture, or asks for premium/polished UI engineering.

---

## 1. Tunable Design Dials

Three dials control the aesthetic baseline. Adapt dynamically based on user requests.

| Dial | Default | Range | Description |
|------|---------|-------|-------------|
| DESIGN_VARIANCE | 8 | 1=Perfect Symmetry, 10=Artsy Chaos | Layout asymmetry and spatial risk |
| MOTION_INTENSITY | 6 | 1=Static, 10=Cinematic Physics | Animation complexity and perpetual motion |
| VISUAL_DENSITY | 4 | 1=Art Gallery/Airy, 10=Cockpit/Packed | Spacing, padding, information density |

### DESIGN_VARIANCE Levels
* **1-3 (Predictable):** Flexbox `justify-center`, strict 12-column symmetrical grids, equal paddings.
* **4-7 (Offset):** `margin-top: -2rem` overlapping, varied image aspect ratios (4:3 next to 16:9), left-aligned headers over center-aligned data.
* **8-10 (Asymmetric):** Masonry layouts, CSS Grid with fractional units (`grid-template-columns: 2fr 1fr 1fr`), massive empty zones (`padding-left: 20vw`).
* **MOBILE OVERRIDE:** For levels 4-10, any asymmetric layout above `md:` MUST fall back to strict single-column (`w-full`, `px-4`, `py-8`) on viewports `< 768px`.

### MOTION_INTENSITY Levels
* **1-3 (Static):** No automatic animations. CSS `:hover` and `:active` states only.
* **4-7 (Fluid CSS):** `transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1)`. `animation-delay` cascades for load-ins. Strictly `transform` and `opacity`. Use `will-change: transform` sparingly.
* **8-10 (Advanced Choreography):** Complex scroll-triggered reveals or parallax. Framer Motion hooks. NEVER use `window.addEventListener('scroll')`.

### VISUAL_DENSITY Levels
* **1-3 (Art Gallery):** Lots of white space. Huge section gaps. Expensive and clean.
* **4-7 (Daily App):** Normal spacing for standard web apps.
* **8-10 (Cockpit):** Tiny paddings. No card boxes; 1px lines to separate data. **Mandatory:** Use Monospace (`font-mono`) for all numbers.

---

## 2. Architecture & Conventions

* **Dependency Verification [Mandatory]:** Before importing any 3rd party library, check `package.json`. If missing, output the install command first. Never assume a library exists.
* **Framework:** React or Next.js. Default to Server Components (RSC).
    * RSC Safety: Global state works ONLY in Client Components. Wrap providers in `"use client"`.
    * Interactivity Isolation: Interactive components MUST be extracted as isolated leaf components with `'use client'`.
* **State Management:** Local `useState`/`useReducer` for isolated UI. Global state strictly for deep prop-drilling avoidance.
* **Styling:** Tailwind CSS (v3/v4) for 90% of styling.
    * Tailwind Version Lock: Check `package.json`. Don't use v4 syntax in v3 projects.
    * T4 Config Guard: For v4, use `@tailwindcss/postcss` or Vite plugin, NOT `tailwindcss` plugin in `postcss.config.js`.
* **Anti-Emoji Policy:** Never use emojis in code, markup, text content, or alt text. Use icons (Radix, Phosphor) or SVG primitives.
* **Responsiveness:**
    * Standardize breakpoints (`sm`, `md`, `lg`, `xl`).
    * Contain layouts: `max-w-[1400px] mx-auto` or `max-w-7xl`.
    * Never use `h-screen` for full-height sections. Use `min-h-[100dvh]`.
    * Grid over Flex-Math: Use CSS Grid (`grid grid-cols-1 md:grid-cols-3 gap-6`) instead of `w-[calc(33%-1rem)]`.
* **Icons:** Use `@phosphor-icons/react` or `@radix-ui/react-icons`. Standardize `strokeWidth` globally.

---

## 3. LLM Bias Corrections

### Typography
* **Display/Headlines:** `text-4xl md:text-6xl tracking-tighter leading-none`.
    * Discourage `Inter` for premium/creative vibes. Use `Geist`, `Outfit`, `Cabinet Grotesk`, or `Satoshi`.
    * Serif fonts BANNED for Dashboard/Software UIs. Use Sans-Serif pairings (`Geist` + `Geist Mono` or `Satoshi` + `JetBrains Mono`).
* **Body:** `text-base text-gray-600 leading-relaxed max-w-[65ch]`.

### Color
* Max 1 accent color. Saturation < 80%.
* "AI Purple/Blue" aesthetic is BANNED. No purple button glows, no neon gradients. Use neutral bases (Zinc/Slate) with singular high-contrast accents (Emerald, Electric Blue, Deep Rose).
* One palette per project. Don't mix warm and cool grays.

### Layout
* Centered Hero/H1 sections BANNED when DESIGN_VARIANCE > 4. Use split screen (50/50), left-aligned/right-asset, or asymmetric whitespace.

### Cards & Surfaces
* For VISUAL_DENSITY > 7, generic card containers are BANNED. Use `border-t`, `divide-y`, or negative space. Data metrics should breathe without being boxed.
* Use cards ONLY when elevation communicates hierarchy. Tint shadows to the background hue.

### Interactive States
Every component must implement:
* **Loading:** Skeletal loaders matching layout sizes (no generic spinners).
* **Empty States:** Composed empty states indicating how to populate.
* **Error States:** Clear inline error reporting.
* **Tactile Feedback:** On `:active`, use `-translate-y-[1px]` or `scale-[0.98]`.

### Forms
* Label above input. Helper text optional. Error text below. Standard `gap-2` for input blocks.

---

## 4. Creative Techniques

### Liquid Glass Refraction
Beyond `backdrop-blur`: add `border-white/10` and `shadow-[inset_0_1px_0_rgba(255,255,255,0.1)]` for physical edge refraction.

### Magnetic Micro-physics (MOTION_INTENSITY > 5)
Buttons that pull toward cursor. Use EXCLUSIVELY Framer Motion's `useMotionValue` and `useTransform` outside React render cycle. Never `useState` for continuous animations.

### Perpetual Micro-Interactions (MOTION_INTENSITY > 5)
Continuous infinite micro-animations (Pulse, Typewriter, Float, Shimmer, Carousel). Spring Physics: `type: "spring", stiffness: 100, damping: 20` for all interactive elements.

### Layout Transitions
Use Framer Motion's `layout` and `layoutId` for smooth re-ordering, resizing, shared element transitions.

### Staggered Orchestration
Use `staggerChildren` (Framer) or CSS cascade (`animation-delay: calc(var(--index) * 100ms)`). Parent and children variants MUST be in the same Client Component tree.

---

## 5. Performance Guardrails

* Grain/noise filters: apply exclusively to `fixed inset-0 z-50 pointer-events-none` pseudo-elements. Never on scrolling containers.
* Never animate `top`, `left`, `width`, or `height`. Use `transform` and `opacity` only.
* Z-index: use strictly for systemic layers (navbars, modals, overlays). No arbitrary z-50 spam.
* Perpetual motion and infinite loops MUST be memoized (`React.memo`) and isolated in their own Client Component.
* Never mix GSAP/ThreeJS with Framer Motion in the same component tree. Default to Framer Motion for UI. GSAP/ThreeJS only for isolated scrolltelling or canvas backgrounds with strict `useEffect` cleanup.

---

## 6. Forbidden Patterns (AI Tells)

### Visual & CSS
* No neon/outer glows. Use inner borders or tinted shadows.
* No pure `#000000`. Use Off-Black, Zinc-950, Charcoal.
* No oversaturated accents. Desaturate to blend with neutrals.
* No excessive gradient text on large headers.
* No custom mouse cursors.

### Typography
* No Inter font. Use `Geist`, `Outfit`, `Cabinet Grotesk`, `Satoshi`.
* No oversized H1s that scream. Control hierarchy with weight and color.
* Serif ONLY for creative/editorial. Never on dashboards.

### Layout
* No 3-column equal card layouts. Use 2-column zig-zag, asymmetric grid, or horizontal scroll.

### Content & Data
* No generic names ("John Doe", "Sarah Chan"). Use creative, realistic names.
* No generic SVG avatar icons. Use photo placeholders or styled alternatives.
* No predictable numbers (`99.99%`, `50%`). Use organic data (`47.2%`, `+1 (312) 847-1928`).
* No startup slop names ("Acme", "Nexus", "SmartFlow"). Invent premium contextual brands.
* No AI copy cliches ("Elevate", "Seamless", "Unleash", "Next-Gen"). Use concrete verbs.

### External Resources
* No Unsplash links. Use `https://picsum.photos/seed/{random_string}/800/600` or SVG avatars.
* shadcn/ui: never in default state. Customize radii, colors, shadows to match the aesthetic.

---

## 7. Creative Pattern Library

### Navigation
* Mac OS Dock Magnification, Magnetic Button, Gooey Menu, Dynamic Island, Contextual Radial Menu, Floating Speed Dial, Mega Menu Reveal

### Layout & Grids
* Bento Grid (asymmetric tiles), Masonry Layout, Chroma Grid (animated color borders), Split Screen Scroll, Curtain Reveal

### Cards & Containers
* Parallax Tilt Card, Spotlight Border Card, Glassmorphism Panel, Holographic Foil Card, Tinder Swipe Stack, Morphing Modal

### Scroll Animations
* Sticky Scroll Stack, Horizontal Scroll Hijack, Locomotive Scroll Sequence, Zoom Parallax, Scroll Progress Path, Liquid Swipe Transition

### Galleries & Media
* Dome Gallery, Coverflow Carousel, Drag-to-Pan Grid, Accordion Image Slider, Hover Image Trail, Glitch Effect Image

### Typography & Text
* Kinetic Marquee, Text Mask Reveal, Text Scramble Effect, Circular Text Path, Gradient Stroke Animation, Kinetic Typography Grid

### Micro-Interactions
* Particle Explosion Button, Liquid Pull-to-Refresh, Skeleton Shimmer, Directional Hover Aware Button, Ripple Click Effect, Animated SVG Line Drawing, Mesh Gradient Background, Lens Blur Depth

---

## 8. Bento Dashboard Paradigm

For modern SaaS dashboards or feature sections, use this "Bento 2.0" architecture:

### Aesthetic
* Background: `#f9fafb`. Cards: pure white `#ffffff` with `border-slate-200/50`.
* `rounded-[2.5rem]` for major containers.
* Diffusion shadow: `shadow-[0_20px_40px_-15px_rgba(0,0,0,0.05)]`.
* Strict `Geist`, `Satoshi`, or `Cabinet Grotesk`. Subtle `tracking-tight` on headers.
* Labels outside and below cards (gallery-style). Generous `p-8`/`p-10` padding inside.

### 5-Card Archetypes
1. **Intelligent List:** Auto-sorting loop with `layoutId` swaps (simulating AI prioritization).
2. **Command Input:** Multi-step typewriter cycling prompts, blinking cursor, shimmer loading state.
3. **Live Status:** Breathing status indicators, overshoot spring notification badges (3s display).
4. **Wide Data Stream:** Infinite horizontal carousel (`x: ["0%", "-100%"]`), seamless loop.
5. **Contextual UI:** Staggered text highlight followed by float-in action toolbar.

---

## 9. Pre-Flight Checklist

- [ ] Global state used only to avoid deep prop-drilling?
- [ ] Mobile collapse (`w-full`, `px-4`, `max-w-7xl mx-auto`) for high-variance designs?
- [ ] Full-height sections use `min-h-[100dvh]` not `h-screen`?
- [ ] `useEffect` animations have cleanup functions?
- [ ] Empty, loading, and error states provided?
- [ ] Cards omitted in favor of spacing where possible?
- [ ] CPU-heavy perpetual animations isolated in own Client Components?
