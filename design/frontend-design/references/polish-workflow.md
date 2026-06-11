# Polish Workflow: critique → animate → polish

When the user asks to improve or refine a frontend page (especially after initial build), run the impeccable sub-commands in this order.

## 1. Critique first (diagnose)

Load the `critique` skill. Evaluate through the target audience's lens, not generic UX. A PM evaluating an AI tool has different needs than a developer reading docs. Key outputs: AI slop detection, visual hierarchy issues, missing interaction states, content that doesn't serve the reader.

Do NOT skip the audience framing. "Use these design skills" without knowing who reads the page produces generic fixes.

## 2. Animate (add life)

Load the `animate` skill. Focus on:
- **Scroll-reveal**: IntersectionObserver with staggered delays (100-150ms between siblings). Use `opacity: 0` + `translateY(24px)` as initial state, transition to visible on intersection.
- **Data animations**: bars/charts should animate their width/height on scroll, not on page load. Use `data-width` attributes and set `width` via JS on intersection.
- **Table cascade**: rows appearing one at a time (80ms stagger) is more compelling than all at once.
- **Hover states**: cards lift (translateY -2px + shadow), interactive elements scale subtly (1.02).
- **Always respect `prefers-reduced-motion`**.

Pitfall: vision-based QA tools will see the pre-animation state (elements at opacity 0) and report the page as "broken." Verify animations work by checking `.visible` class count via the browser console after scrolling, not via screenshot of initial load.

## 3. Polish last (refine)

Load the `polish` skill. After critique issues are fixed and animations are in:
- Consistent border-radius (pick 6px or 8px, not both)
- Spacing rhythm (use 8px base scale)
- Hover highlight on table rows
- Color-code semantic elements (failure bullets get red dots, not gray)
- Tighten padding on cards (20-24px, not 28-32px)
- Ensure mono font only appears on actual data/numbers

## Combined pass

For efficiency, apply all three in a single file rewrite rather than three deploys. Read critique findings, plan animate additions, note polish fixes, then write once.
