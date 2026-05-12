---
name: design-md
description: Use when creating, editing, or validating DESIGN.md files, design tokens, DTCG token specs, Tailwind theme exports, design system documentation, WCAG contrast checks, or Google Stitch-compatible design specs.
---

# DESIGN.md Skill

DESIGN.md is Google's open spec (Apache-2.0, `google-labs-code/design.md`) for
describing a visual identity to coding agents. One file combines:

- **YAML front matter** — machine-readable design tokens (normative values)
- **Markdown body** — human-readable rationale, organized into canonical sections

Tokens give exact values. Prose tells agents *why* those values exist and how to
apply them. The CLI (`npx @google/design.md`) lints structure + WCAG contrast,
diffs versions for regressions, and exports to Tailwind or W3C DTCG JSON.

## When to use this skill

- User asks for a DESIGN.md file, design tokens, or a design system spec
- User wants consistent UI/brand across multiple projects or tools
- User pastes an existing DESIGN.md and asks to lint, diff, export, or extend it
- User asks to port a style guide into a format agents can consume
- User wants contrast / WCAG accessibility validation on their color palette

For purely visual inspiration or layout examples, use `popular-web-designs`
instead. For *process and taste* when designing a one-off HTML artifact
from scratch (prototype, deck, landing page, component lab), use
`claude-design`. This skill is for the *formal spec file* itself.

## File anatomy

```md
---
version: alpha
name: Heritage
description: Architectural minimalism meets journalistic gravitas.
colors:
  primary: "#1A1C1E"
  secondary: "#6C7278"
  tertiary: "#B8422E"
  neutral: "#F7F5F2"
typography:
  h1:
    fontFamily: Public Sans
    fontSize: 3rem
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.02em"
  body-md:
    fontFamily: Public Sans
    fontSize: 1rem
rounded:
  sm: 4px
  md: 8px
  lg: 16px
spacing:
  sm: 8px
  md: 16px
  lg: 24px
components:
  button-primary:
    backgroundColor: "{colors.tertiary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.sm}"
    padding: 12px
  button-primary-hover:
    backgroundColor: "{colors.primary}"
---

## Overview

Architectural Minimalism meets Journalistic Gravitas...

## Colors

- **Primary (#1A1C1E):** Deep ink for headlines and core text.
- **Tertiary (#B8422E):** "Boston Clay" — the sole driver for interaction.

## Typography

Public Sans for everything except small all-caps labels...

## Components

`button-primary` is the only high-emphasis action on a page...
```

## Token types

| Type | Format | Example |
|------|--------|---------|
| Color | `#` + hex (sRGB) | `"#1A1C1E"` |
| Dimension | number + unit (`px`, `em`, `rem`) | `48px`, `-0.02em` |
| Token reference | `{path.to.token}` | `{colors.primary}` |
| Typography | object with `fontFamily`, `fontSize`, `fontWeight`, `lineHeight`, `letterSpacing`, `fontFeature`, `fontVariation` | see above |

Component property whitelist: `backgroundColor`, `textColor`, `typography`,
`rounded`, `padding`, `size`, `height`, `width`. Variants (hover, active,
pressed) are **separate component entries** with related key names
(`button-primary-hover`), not nested.

## Canonical section order

Sections are optional, but present ones MUST appear in this order. Duplicate
headings reject the file.

1. Overview (alias: Brand & Style)
2. Colors
3. Typography
4. Layout (alias: Layout & Spacing)
5. Elevation & Depth (alias: Elevation)
6. Shapes
7. Components
8. Do's and Don'ts

Unknown sections are preserved, not errored. Unknown token names are accepted
if the value type is valid. Unknown component properties produce a warning.

## Workflow: authoring a new DESIGN.md

1. **Ask the user** (or infer) the brand tone, accent color, and typography
   direction. If they provided a site, image, or vibe, translate it to the
   token shape above.
2. **Write `DESIGN.md`** in their project root using `write_file`. Always
   include `name:` and `colors:`; other sections optional but encouraged.
3. **Use token references** (`{colors.primary}`) in the `components:` section
   instead of re-typing hex values. Keeps the palette single-source.
4. **Lint it** (see below). Fix any broken references or WCAG failures
   before returning.
5. **If the user has an existing project**, also write Tailwind or DTCG
   exports next to the file (`tailwind.theme.json`, `tokens.json`).

## Workflow: lint / diff / export

The CLI is `@google/design.md` (Node). Use `npx` — no global install needed.

```bash
# Validate structure + token references + WCAG contrast
npx -y @google/design.md lint DESIGN.md

# Compare two versions, fail on regression (exit 1 = regression)
npx -y @google/design.md diff DESIGN.md DESIGN-v2.md

# Export to Tailwind theme JSON
npx -y @google/design.md export --format tailwind DESIGN.md > tailwind.theme.json

# Export to W3C DTCG (Design Tokens Format Module) JSON
npx -y @google/design.md export --format dtcg DESIGN.md > tokens.json

# Print the spec itself — useful when injecting into an agent prompt
npx -y @google/design.md spec --rules-only --format json
```

All commands accept `-` for stdin. `lint` returns exit 1 on errors. Use the
`--format json` flag and parse the output if you need to report findings
structurally.

### Lint rule reference (what the 7 rules catch)

- `broken-ref` (error) — `{colors.missing}` points at a non-existent token
- `duplicate-section` (error) — same `## Heading` appears twice
- `invalid-color`, `invalid-dimension`, `invalid-typography` (error)
- `wcag-contrast` (warning/info) — component `textColor` vs `backgroundColor`
  ratio against WCAG AA (4.5:1) and AAA (7:1)
- `unknown-component-property` (warning) — outside the whitelist above

When the user cares about accessibility, call this out explicitly in your
summary — WCAG findings are the most load-bearing reason to use the CLI.

## Pitfalls

- **Don't nest component variants.** `button-primary.hover` is wrong;
  `button-primary-hover` as a sibling key is right.
- **Hex colors must be quoted strings.** YAML will otherwise choke on `#` or
  truncate values like `#1A1C1E` oddly.
- **Negative dimensions need quotes too.** `letterSpacing: -0.02em` parses as
  a YAML flow — write `letterSpacing: "-0.02em"`.
- **Section order is enforced.** If the user gives you prose in a random order,
  reorder it to match the canonical list before saving.
- **`version: alpha` is the current spec version** (as of Apr 2026). The spec
  is marked alpha — watch for breaking changes.
- **Token references resolve by dotted path.** `{colors.primary}` works;
  `{primary}` does not.

## Spec source of truth

- Repo: https://github.com/google-labs-code/design.md (Apache-2.0)
- CLI: `@google/design.md` on npm
- License of generated DESIGN.md files: whatever the user's project uses;
  the spec itself is Apache-2.0.

---

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
