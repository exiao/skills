---
name: design-md
description: >
  Create a DESIGN.md file at the project root — a plain-text design system document
  that AI coding agents read to produce consistent, on-brand UI. Follows the Google
  Stitch DESIGN.md format. Supports five source modes: (1) adapt existing brand doc,
  (2) scrape a live URL, (3) extract from codebase, (4) browse Refero Styles gallery
  at styles.refero.design for rich measured design tokens, (5) VoltAgent awesome-design-md
  CLI gallery of 68 curated templates. Trigger on "create DESIGN.md", "set up design
  system", "scaffold design doc", "design.md", "make my UI look like <brand>", "design
  system for AI agents", "awesome-design-md", "getdesign", "refero styles".
---

# DESIGN.md Generator

Create a `DESIGN.md` at the root of a project — the visual counterpart to `AGENTS.md`. AI coding agents read it before generating UI so the output is consistent and on-brand instead of generic AI slop.

## When to use

- Starting a new project and want UI that doesn't look like every other Claude-generated Tailwind site.
- Existing project has drifted visually — different pages look like different apps.
- User asks for "the UI to look like [brand]" and you need a durable reference, not a one-shot prompt.
- After `marketing/brand-identity` produces a brand doc, to translate strategy into an agent-readable design system.
- Before calling `visual-design/frontend-design`, to satisfy its Context Gathering Protocol with a written source of truth.

## Five source modes (pick in this order)

Ask the user which source they want. If they don't care or don't have one, walk them through the list below.

### 1. Adapt from existing brand doc (preferred when available)

Look for these in the project, in order:
- `BRAND.md`, `brand.md`, `docs/brand*.md`
- Output from `marketing/brand-identity` skill
- A style guide, any Figma link with tokens exported, a tailwind.config.js
- CSS custom properties defined in a `:root` / `theme.css` / `globals.css`

If found: the DESIGN.md should *distill and structure* the existing brand into the DESIGN.md format — don't invent new colors or fonts. Cite the source doc in a comment at the top.

### 2. Scrape a live URL (most common Stitch use case)

User says "make it look like [url]" or names a site that isn't in the gallery.

Use `visual-design/frontend-design` context gathering + a headless browser (Chromium via Playwright, or `curl` + regex fallback) to pull:
- Computed CSS custom properties from `:root`
- Font families actually rendered (check `getComputedStyle` on headings and body)
- A screenshot for visual reference (save to `assets/reference/<domain>.png`)
- Primary accent color (sample from buttons and links)

Fill the DESIGN.md sections from what you measured, not what you guessed.

### 3. Extract from codebase

User says "make a DESIGN.md for this project" and no brand doc exists.

Use `visual-design/impeccable/commands/extract` as the engine. It already walks the component library and design tokens. Feed its output into the DESIGN.md structure. This is the most accurate mode for established products.

### 4. Browse Refero Styles (richest gallery — preferred for brand-matching)

[Refero Styles](https://styles.refero.design) is a curated library of real-product design systems. Each style page includes: color palette (accent + neutrals with named tokens), full typography scale (fonts, weights, sizes, line heights, letter spacing), spacing & shape (density, max width, gaps, border radius, elevation/shadows), Do's and Don'ts guidelines, and component previews.

**How to use:**
1. Browse https://styles.refero.design — search by brand name, mood, color, typography, or paste a URL
2. Open a style page to see the full extracted design system
3. Copy the design tokens directly into a DESIGN.md following the Stitch spec

Each style page gives you everything needed for a complete DESIGN.md: colors with semantic names, type scale with precise values, spacing tokens, border radius per element type, elevation/shadow definitions, and curated Do/Don't guardrails. Richer than VoltAgent templates because it includes measured values from actual live sites.

**Refero also offers:**
- **Refero MCP** ($17/mo Pro plan) — gives AI agents direct access to 130K+ screens and 10K+ user flows for design research. See https://refero.design/mcp
- **Refero Skill** — a design methodology that installs into agents: `npx skills add https://github.com/referodesign/refero_skill`

**When to prefer Refero Styles over VoltAgent:**
- You want precise, measured token values (not approximations)
- The brand exists on Refero but not in VoltAgent's 68 templates
- You want Do/Don't guidelines extracted from the actual product
- You need typography details like letter-spacing and line-height per size step

### 5. Pick from the VoltAgent gallery (CLI install — quick template)

If the user wants a fast one-command install, use the 68 curated templates from [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md). See `references/gallery.md` for the full categorized list with one-line descriptions.

Ask: **"Which of these brands is closest to the aesthetic you want?"** Show the categories first (AI, Developer Tools, Fintech, E-commerce, Automotive, etc.) so they can narrow down.

Once they pick:

```bash
# Install the template as ./DESIGN.md
npx getdesign@latest add <brand>
```

Zero-dependency CLI that copies the curated DESIGN.md into the project root. No API keys, no config.

If `DESIGN.md` already exists at root, the CLI saves to `./<brand>/DESIGN.md` instead. To activate:
```bash
cp <brand>/DESIGN.md ./DESIGN.md
```

After install, offer to **customize the template** to the user's actual brand (swap brand name, adjust accent color, drop sections that don't apply).

## Output format

Follow the [Stitch DESIGN.md spec](https://stitch.withgoogle.com/docs/design-md/overview/). Full section reference in `references/format-spec.md`. The 9 sections:

1. **Visual Theme & Atmosphere** — mood, density, philosophy
2. **Color Palette & Roles** — semantic name + hex + functional role
3. **Typography Rules** — font families + full hierarchy table
4. **Component Stylings** — buttons, cards, inputs, nav with states
5. **Layout Principles** — spacing scale, grid, whitespace
6. **Depth & Elevation** — shadow system, surface hierarchy
7. **Do's and Don'ts** — guardrails, anti-patterns
8. **Responsive Behavior** — breakpoints, touch targets, collapsing
9. **Agent Prompt Guide** — quick color reference, ready-to-use prompts

## File location

Always write to the **project root** as `DESIGN.md` (all caps, matching convention with `AGENTS.md`, `CLAUDE.md`, `README.md`). This is what agents will find by default.

## After install

- Add DESIGN.md to the repo (commit it — it's a first-class doc).
- Mention it in `AGENTS.md` / `CLAUDE.md`: "Read DESIGN.md before any UI work."
- Hand off to `visual-design/frontend-design` for the first build — its Context Gathering Protocol will consume DESIGN.md and skip the interrogation.

## Integration with other skills

| Skill | Relationship |
|-------|--------------|
| `marketing/brand-identity` | Upstream. Strategy → DESIGN.md is the natural pipeline. |
| `visual-design/frontend-design` | Downstream consumer. Reads DESIGN.md as project context. |
| `visual-design/impeccable/commands/extract` | Engine for source mode 3 (codebase extract). |
| `creative/popular-web-designs` | Sibling inspiration library — use for mood before picking a DESIGN.md. |

## Quick command reference

```bash
# List available VoltAgent templates
npx getdesign@latest list

# Install a template (writes ./DESIGN.md if absent, else ./<brand>/DESIGN.md)
npx getdesign@latest add vercel

# Overwrite existing DESIGN.md
npx getdesign@latest add stripe --force

# Install to a custom path
npx getdesign@latest add ibm --out ./docs/DESIGN.md
```

## References

- `references/format-spec.md` — full Stitch DESIGN.md section spec
- `references/gallery.md` — all 68 VoltAgent templates, categorized
- `references/source-modes.md` — detailed playbook for each source mode
