# Adding Slides to an Existing Deck from Image References

## When This Applies

User sends screenshot images of slides and asks to add them to an existing Surge-hosted HTML presentation. This is Mode C (Enhancement) with visual input.

## Workflow

1. **Read the existing deck's HTML** to understand the slide structure, CSS custom properties, class naming conventions (`.slide`, `.signal-card`, `.card-layout`, etc.), and section numbering scheme (`data-slide` attributes).
2. **Analyze the screenshots** to identify the visual content: diagrams, text, layout structure, colors.
3. **Recreate as inline SVG/HTML.** Do NOT save the images as files. Rebuild the visual content using:
   - Inline `<svg>` for diagrams (venn diagrams, flowcharts, cycle arrows, architecture diagrams)
   - HTML/CSS for text, cards, grids, and layout
   - The deck's existing CSS custom properties (`var(--color-accent)`, `var(--font-display)`, etc.)
4. **Match the deck's existing style.** Use the same card components (`.signal-card`, `.primitive-card`), typography scale, and spacing patterns already in the deck. **Match header colors to existing slides** — don't introduce new heading colors (e.g. blue `#0066FF`) unless the deck already uses them.
5. **Choose insertion point.** If the user doesn't specify, infer from content flow. Conceptual/framing slides go early; detail/technique slides go later.
6. **Assign `data-slide` IDs** that fit the existing scheme (e.g., if inserting between `1b` and `2`, use `1c`, `1d`, `1e`).
7. **Deploy with `npx surge . <domain>` (timeout 60s).** 30s often times out for larger decks.

## SVG Recreation Patterns

| Visual Element | SVG Approach |
|---|---|
| Waterfall/cascade diagram | Nested divs with colored pill `<span>`s and arrow characters |
| Venn diagram (3 circles) | `<circle>` elements with `fill="none"` and `stroke`, `<text>` labels |
| Cycle diagram (arrows) | Use SVG arc commands (`A`) not cubic beziers. Proper `<marker>` with `orient="auto-start-reverse"` and `viewBox`. See below. |
| Architecture/flow diagram | `<rect>` boxes, `<line>`/`<path>` connectors, `<text>` labels, `<marker>` arrowheads |
| Converged/overlapping circles | Nearly-concentric `<circle>` elements with slight offset |

Always set `font-family="Outfit, sans-serif"` (or whatever the deck uses) on SVG `<text>` elements to match the deck typography.

### Complex SVGs: Use Gemini to Generate

Hand-coding SVG paths for cycle diagrams, curved arrows, and complex shapes produces ugly results. **Use Gemini 2.5 Pro to generate the SVG instead.**

```bash
source ~/.hermes/.env && curl -s \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"<describe the SVG you want, include viewBox, colors, fonts, labels>. Return ONLY the raw SVG element."}]}]}' \
  > /tmp/gemini-raw.json
# Extract SVG from response:
python3 -c "
import json, re
with open('/tmp/gemini-raw.json') as f:
    text = json.load(f)['candidates'][0]['content']['parts'][0]['text']
m = re.search(r'<svg[\s\S]*?</svg>', text)
print(m.group(0) if m else text)
" > /tmp/output.svg
```

**Model name:** Use `gemini-2.5-pro` (not preview/dated variants like `gemini-2.5-pro-preview-06-05`, those 404).

**Why this works better:**
- Gemini uses proper SVG arc commands (`A 120 120 0 0 1 ...`) which produce mathematically correct curves
- Hand-coded cubic beziers (`C`/`Q`) require manual coordinate tuning that looks janky
- Gemini sets up `<marker>` defs with `viewBox` and `orient="auto-start-reverse"` correctly
- One API call replaces 30+ minutes of path coordinate tweaking

**When to use:** Any SVG with curved arrows, cycle diagrams, flow charts, or complex shapes. Simple rectangles, circles, and straight lines are fine to hand-code.

**Marker ID collisions:** When embedding Gemini-generated SVG into a page with other SVGs, rename marker IDs to be unique (e.g., suffix with `-g`). Multiple SVGs sharing the same `#arrowhead` ID will conflict.

## Slide Critique Workflow

When asked to review/improve a slide:

1. Diagnose the structural problem (not just cosmetic). Common issues:
   - **Feature list masquerading as insight.** Numbered lists with equal weight convey no hierarchy.
   - **No before/after.** Abstract descriptions without concrete examples don't land.
   - **Too many items.** 5 items of equal weight should consolidate to 3 with clear relationships.
2. Propose specific changes with rationale. Name what to cut, what to merge, what to add.
3. Reference any related content (URLs, plans, docs) the user shared for source material.
4. Execute the rebuild after approval.

## Pitfalls

- SVG `<text>` with `<tspan>` for colored words (e.g., red keywords in a sentence): use `<tspan fill="#E8606A">keyword</tspan>` inside the parent `<text>`.
- SVG arrow markers need unique IDs if multiple SVGs on the same page use them. Use distinct IDs like `arrowhead-1`, `arrowhead-2`, or suffix with context (`-g` for Gemini-generated).
- CSS `var()` references work inside inline SVG `fill`/`stroke` attributes in modern browsers but test across the deck's target audience.
- Surge deploy: always use 60s timeout. Large decks with images can take 40-50s.
- **Style consistency:** When adding new slides, don't introduce custom heading colors. Always inherit from the existing deck's h2 style. The user called out blue `#0066FF` headers as inconsistent when the rest of the deck used default black.
