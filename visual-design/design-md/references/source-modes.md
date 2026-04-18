# Source Modes Playbook

Detailed workflow for each of the four source modes. Pick the mode that matches the user's starting point.

## Decision tree

```
Does the project already have a brand doc or style guide?
├─ YES  → Mode 1: Adapt from existing brand doc
└─ NO
   │
   Did the user name a specific website?
   ├─ YES  → Is it in the VoltAgent gallery (references/gallery.md)?
   │         ├─ YES → Mode 4 (use the template, optionally customize)
   │         └─ NO  → Mode 2 (scrape the URL)
   └─ NO
      │
      Is there existing production UI to extract from?
      ├─ YES → Mode 3: Extract from codebase
      └─ NO  → Mode 4: Pick from the gallery
```

---

## Mode 1 — Adapt from existing brand doc

**When:** Project has a brand strategy doc, style guide, exported Figma tokens, or a `tailwind.config.js` with defined theme.

**Sources to check, in order:**
1. `BRAND.md`, `brand.md`, `docs/brand*.md`, `docs/design-system*.md`
2. Output directory of `marketing/brand-identity` skill
3. `tailwind.config.js` → `theme.extend.colors` + `fontFamily`
4. `:root { --* }` custom properties in `theme.css`, `globals.css`, `styles/index.css`, `app.css`
5. Storybook / Ladle tokens file
6. Any Figma link in README.md (you can't scrape it, but note it as reference)

**Process:**
1. Read all brand sources. Extract: accent colors, full palette, typography stack, spacing scale, border radii.
2. Do NOT invent values. If a section has no source, either omit it or mark `TBD — pending design decision`.
3. Structure the extracted values into the 9 DESIGN.md sections (see `format-spec.md`).
4. Add a source citation at the top:
   ```markdown
   <!-- Generated from: docs/brand.md, tailwind.config.js -->
   ```
5. Show the draft to the user. Ask: "Anything missing or wrong?" Iterate.

**Output quality check:** Every hex code should trace back to a source. If you had to make one up, flag it inline with `<!-- TODO: confirm -->`.

---

## Mode 2 — Scrape a live URL

**When:** User says "make it look like [url]" and the URL isn't in the gallery.

**Tools:**
- Headless browser: Playwright (preferred) or Puppeteer. If neither is installed, `curl` + regex fallback with degraded accuracy.
- Color sampling: `getComputedStyle` on buttons, links, headings, body.
- Font detection: `getComputedStyle(element).fontFamily` on actual rendered text, not just declared in CSS (catches fallbacks).
- Screenshot: save to `assets/reference/<domain>.png` as visual anchor.

**Process:**

```python
# Pseudocode — adapt to available tools
from playwright.sync_api import sync_playwright

def extract_design(url):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={'width': 1440, 'height': 900})
        page.goto(url, wait_until='networkidle')

        # 1. Root CSS custom properties
        css_vars = page.evaluate("""
            () => {
                const style = getComputedStyle(document.documentElement);
                const vars = {};
                for (const prop of style) {
                    if (prop.startsWith('--')) vars[prop] = style.getPropertyValue(prop).trim();
                }
                return vars;
            }
        """)

        # 2. Rendered fonts on body and headings
        fonts = page.evaluate("""
            () => ({
                body:    getComputedStyle(document.body).fontFamily,
                h1:      document.querySelector('h1') ? getComputedStyle(document.querySelector('h1')).fontFamily : null,
                h2:      document.querySelector('h2') ? getComputedStyle(document.querySelector('h2')).fontFamily : null,
                button:  document.querySelector('button') ? getComputedStyle(document.querySelector('button')).fontFamily : null,
            })
        """)

        # 3. Accent color — sample primary button
        accent = page.evaluate("""
            () => {
                const btn = document.querySelector('button, a.btn, [class*="primary"]');
                return btn ? getComputedStyle(btn).backgroundColor : null;
            }
        """)

        # 4. Screenshot for visual reference
        page.screenshot(path='assets/reference/screenshot.png', full_page=False)

        browser.close()
        return {'css_vars': css_vars, 'fonts': fonts, 'accent': accent}
```

**Fallback without headless browser:**
- `curl -sL <url>` → grep `<link rel="stylesheet">` → fetch the CSS → grep for `--*:`, `font-family:`, hex codes.
- Accuracy drops because you miss computed values. Be explicit with the user that this is degraded.

**Fill DESIGN.md from what you measured.** If you measured 6 colors, document 6. Don't pad with guesses.

**Output quality check:** Include the screenshot as `assets/reference/<domain>.png` and cite the URL + date scraped at the top of DESIGN.md.

---

## Mode 3 — Extract from codebase

**When:** Established product, user wants DESIGN.md to *describe what's already there* so future work stays consistent.

**Engine:** Delegate to `visual-design/impeccable/extract`. It already scans for components, tokens, and patterns. Run it first, then translate its output into DESIGN.md structure.

**Process:**

1. **Locate the design system / component library.** Common paths:
   - `src/components/ui/`
   - `packages/ui/`
   - `apps/*/components/`
   - `design-system/`
2. **Extract design tokens:**
   - Tailwind config (`theme.extend.colors`, `fontFamily`, `spacing`, `boxShadow`)
   - CSS custom properties in `:root`, `html`, or a central theme file
   - Emotion/styled-components theme object (search for `const theme = { colors: ...`)
   - JS/TS constants files (`constants/design.ts`, `theme/tokens.ts`)
3. **Audit components.** For each core component (Button, Card, Input, Nav), note:
   - Variants exported (`primary`, `secondary`, `ghost`, `destructive`)
   - States implemented (does the hover state exist? focus ring? disabled?)
   - Border radius / shadow / padding scale used
4. **Check actual usage.** Grep for hex codes or color tokens in JSX — are tokens being used, or are there hardcoded colors sneaking in? Note inconsistencies.
5. **Write DESIGN.md as a description of current reality** — not aspirational. If the codebase has 3 grays and no dedicated "placeholder" color, document that.
6. Offer the user a follow-up: "Want me to run `visual-design/impeccable/audit` to flag gaps or inconsistencies against this DESIGN.md?"

**Output quality check:** Every section should have a file citation. Example: `Typography from tailwind.config.js and src/styles/globals.css`.

---

## Mode 4 — Pick from the VoltAgent gallery

**When:** User has no brand doc, no specific URL in mind, and no existing UI to extract from. The default fallback.

**Process:**

1. **Show the gallery categories first** (not all 68 brands). From `references/gallery.md`:
   - AI & LLM Platforms (12)
   - Developer Tools & IDEs (7)
   - Backend, Database & DevOps (11)
   - Productivity & SaaS (8)
   - Design & Creative Tools (7)
   - Fintech & Crypto (8)
   - E-commerce & Retail (5)
   - Media & Consumer Tech (11)
   - Automotive (6)

2. **Use the "Quick mental map"** at the top of `gallery.md` to narrow first:
   > "Sounds like you want something warm and editorial — that points to claude, airbnb, or ferrari. Want to see those three?"

3. **Show only the narrow list** (3–6 brands, with descriptions).

4. **Install the one they pick:**
   ```bash
   npx getdesign@latest add <brand>
   ```
   If `DESIGN.md` exists at root, CLI saves to `./<brand>/DESIGN.md`. Tell the user:
   ```bash
   cp <brand>/DESIGN.md ./DESIGN.md
   ```

5. **Offer to customize.** The template is aspirational — it's another brand's design. Standard customizations:
   - Swap brand name in section 1 header
   - Adjust accent color to something distinctive (copy the template's structure but change the hex)
   - Delete sections that don't apply (e.g. no automotive hero imagery if you're a SaaS)
   - Rename component styles to the project's domain language

6. **Commit the final DESIGN.md.** Add a line to `AGENTS.md`:
   ```markdown
   ## Design
   Read `DESIGN.md` before any UI work. It defines colors, typography, components, and anti-patterns.
   ```

**Output quality check:** After install, open the file and confirm it's readable as-is. If the accent color is dramatic (e.g. Bugatti's cinema-black) but the product is a baby-tracking app, that's a mismatch — push back on the pick.

---

## Tips across all modes

- **Err toward specificity.** "Use a warm neutral" is useless to an agent. "Use `#f5f4ed` for page background" works.
- **Name anti-patterns explicitly.** Don'ts do more work than dos. Agents default to Tailwind slop; the Don'ts block that.
- **Include at least 3 Agent Prompt Guide snippets** (section 9). These are copy-pasteable prompts the user can hand to Cursor / Claude Code without thinking.
- **Keep DESIGN.md under 1500 lines.** If longer, split shared patterns to `docs/design/` and link from DESIGN.md.
- **Version it.** DESIGN.md v1.1, v1.2 as the design evolves. Note changes in a CHANGELOG at the bottom.
