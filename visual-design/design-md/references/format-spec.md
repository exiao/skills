# DESIGN.md Format Specification

Based on [Google Stitch DESIGN.md spec](https://stitch.withgoogle.com/docs/design-md/format/) with VoltAgent extensions.

## File header

```markdown
# Design System Inspired by <Brand>

*Short lede — one or two sentences setting atmosphere. Example: "Vercel takes frontend deployment as its base, then sharpens it through black and white precision, Geist font. Strong fit for developer platforms and infrastructure marketing."*
```

---

## 1. Visual Theme & Atmosphere

Describe the mood and philosophy in 2–4 paragraphs. Answer:

- What does this UI feel like? (A literary salon? A control tower? A museum?)
- What's the **one move** that defines the aesthetic? (Vercel = Geist + monochrome. Claude = parchment + terracotta. Tesla = radical subtraction.)
- What does it deliberately *avoid*? (Vercel avoids gradients. Claude avoids cool grays.)

Then a bulleted "Key Characteristics" list — 5–8 terse lines covering surface, typography, accent, neutrals, icons, depth, pacing.

---

## 2. Color Palette & Roles

Group colors under these subsections. Each color gets: **semantic name** (`#hex`) + functional role.

### Primary
The 1–3 colors that define the brand.

### Secondary & Accent
Supporting accents, error/warning/success where relevant.

### Surface & Background
Page bg, card bg, elevated surfaces, dark-mode pairs.

### Neutrals & Text
Full text hierarchy (primary, secondary, tertiary, placeholder, disabled).

### Semantic & Accent
Borders, rings, focus, hover tints.

### Gradient System
If gradients are used, define them. If not (e.g. Claude, Vercel), **say so explicitly** — absence of gradients is a design decision.

**Format example:**
```markdown
- **Terracotta Brand** (`#c96442`): Core brand color for primary CTAs. Deliberately earthy and un-tech.
- **Coral Accent** (`#d97757`): Lighter warmer variant for text accents and links on dark surfaces.
```

---

## 3. Typography Rules

### Font Family
List primary fonts with fallbacks:
- **Headline**: `Font Name`, with fallback: `Georgia`
- **Body / UI**: `Font Name`, with fallback: `Arial`
- **Code**: `Font Name`, with fallback: `Menlo`

### Hierarchy (full table)

| Role | Font | Size | Weight | Line Height | Letter Spacing | Notes |
|------|------|------|--------|-------------|----------------|-------|
| Display / Hero | — | 64px | 500 | 1.10 | normal | Max impact |
| Section Heading | — | 52px | 500 | 1.20 | normal | |
| Sub-heading Large | — | 36px | 500 | 1.30 | normal | |
| Sub-heading | — | 32px | 500 | 1.10 | normal | |
| Body Large | — | 20px | 400 | 1.60 | normal | Intro paragraphs |
| Body Standard | — | 16px | 400 | 1.50 | normal | |
| Caption | — | 14px | 400 | 1.43 | normal | Metadata |
| Label | — | 12px | 500 | 1.25 | 0.12px | Badges |
| Code | — | 14px | 400 | 1.60 | -0.32px | Inline code |

### Principles

3–5 bullets covering: weight choices, line-height philosophy, serif/sans split if relevant, what NOT to do (no italic body, no mixed weights in single heading, etc).

---

## 4. Component Stylings

For each component type, define: shape/border, surface, text treatment, states (default / hover / active / disabled / focus).

### Buttons
- **Primary**: background, border, text color, radius, padding, hover behavior
- **Secondary**: same fields
- **Tertiary / Ghost**: same fields
- **Icon button**: size, hit area

### Cards
Base surface, border, radius, padding, shadow (reference Depth section), hover lift behavior.

### Inputs & Forms
Field background, border, radius, focus ring color/width, placeholder color, error state, disabled state.

### Navigation
Top nav: height, bg, border, active state indicator. Side nav if applicable.

### Data Display
Tables, lists, metric cards, tags/chips, badges.

---

## 5. Layout Principles

### Spacing Scale
State the scale (4px base? 8px? Fibonacci?) and list tokens:
```
--space-1: 4px
--space-2: 8px
--space-3: 12px
--space-4: 16px
...
```

### Grid & Container
Max widths, column counts, gutters, breakpoint behavior.

### Whitespace Philosophy
How much room around elements? One paragraph describing pacing (dense data-UI vs. generous editorial).

---

## 6. Depth & Elevation

### Shadow System
List every shadow with its role:
```
--shadow-sm:  0 1px 2px rgba(0,0,0,.04)    // Cards at rest
--shadow-md:  0 4px 12px rgba(0,0,0,.08)   // Dropdowns, popovers
--shadow-lg:  0 12px 32px rgba(0,0,0,.12)  // Modals
```

### Surface Hierarchy
Which surface sits on top of which — z-index or flat? How is depth signaled when shadows are minimal (e.g. ring-based like Claude)?

---

## 7. Do's and Don'ts

Two lists. Short. Opinionated.

**Do:**
- Use the brand accent only for primary actions and key emphasis
- Pair serif headlines with sans UI text
- Keep borders subtle — warm-tinted, not cool

**Don't:**
- Use cool blue-grays (breaks warm palette consistency)
- Mix shadow styles (ring-based OR drop-shadow, pick one)
- Use the accent on large surfaces (reserved for text/buttons)

These are the **anti-slop guardrails** — this is what makes the design feel intentional instead of default-Tailwind.

---

## 8. Responsive Behavior

### Breakpoints
```
sm:  640px   Phones
md:  768px   Tablets
lg:  1024px  Laptops
xl:  1280px  Desktops
2xl: 1536px  Wide
```

### Touch targets
Minimum 44×44px on touch surfaces. Spacing between interactive elements ≥8px.

### Collapsing strategy
How does the nav collapse on mobile? Hamburger? Sheet? Bottom bar? How do multi-column layouts stack?

---

## 9. Agent Prompt Guide

This is the section agents skim when generating a new page. Make it action-ready.

### Quick color reference
```
Primary text:    #141413
Secondary text:  #5e5d59
Accent:          #c96442
Page bg:         #f5f4ed
Card bg:         #faf9f5
Border:          #f0eee6
```

### Ready-to-use prompts

Provide 3–5 prompt snippets an agent can paste:

**For a marketing page:**
> "Build a hero section using DESIGN.md. Headline in serif, 64px, weight 500. Parchment background. One terracotta CTA button. No gradients. Add a subtle warm-tinted border below."

**For a dashboard:**
> "Build a metric card grid using DESIGN.md. Warm sand card backgrounds, olive-gray secondary text, ring-based shadows not drop-shadows. Label text in 12px uppercase with 0.12px letter-spacing."

**For a form:**
> "Build a form using DESIGN.md. 4px radius inputs. Focus ring uses focus blue (#3898ec) — the only cool color allowed. Error state uses crimson (#b53333). Placeholder in stone gray."

---

## Quality checklist

Before finishing a DESIGN.md, verify:

- [ ] Every hex code appears with a semantic name and a functional role
- [ ] Typography hierarchy table has at least 8 rows
- [ ] Every component has all states documented (default/hover/active/disabled/focus)
- [ ] Shadow system is explicit (or absence is explicit)
- [ ] Do's and Don'ts are opinionated, not generic
- [ ] Agent Prompt Guide has 3+ ready-to-paste prompts
- [ ] File lives at project root as `DESIGN.md` (all caps)
- [ ] Referenced in `AGENTS.md` / `CLAUDE.md` so agents find it
