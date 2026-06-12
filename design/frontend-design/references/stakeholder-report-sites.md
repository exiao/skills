# Stakeholder Report Sites

Patterns for stakeholder report sites.

## When to Use

When the user asks to present development progress, research results, or project outcomes as a shareable site for investors, LPs, or technical stakeholders. These differ from sales assets: the audience already has context, they want to verify quality and see evidence, not be sold.

## Audience-First Framing

Before writing any copy, establish the audience explicitly. A portfolio manager at a large fund reads differently than a developer or a product reviewer:

- **PM/investor audience:** Lead with proof, not claims. Specific numbers over percentages. Show the actual output (embed a real memo, not a description of one). Admit errors openly — disclosing a known computation error is more credible than claiming perfection.
- **Technical stakeholder:** Architecture diagrams, eval system details, session/tool call counts.
- **Mixed:** Layer it. Hero stats for skimmers, expandable sections for depth.

## Structure That Worked

1. **Hero:** Short headline + 3 proof stats (specific numbers, not percentages or vanity metrics)
2. **Problem:** Why existing approaches fail (positions the solution without claiming superiority)
3. **How it works:** Pipeline steps with minimal jargon
4. **Architecture:** SVG diagram showing system layers (see below)
5. **Results:** Run-by-run comparison cards with expandable full memos
6. **Eval detail:** Diagram of the verification process
7. **Sample output:** Real memo content with expandable appendix sections
8. **Verification:** Claim-by-claim audit table
9. **Next steps:** Numbered grid of concrete improvements

## Inline SVG Diagrams

Use inline SVG over Excalidraw screenshots when the diagram needs to match the site's typography, colors, and spacing. Key lessons:

- **Route lines outside content.** Retry loops, feedback arrows, and connector paths must route around boxes, not through them. Widen the viewBox (e.g., 800 to 860) to give routing space on the edges.
- **Use the site's font stack.** Set font-family on every SVG text element to match the page (DM Sans for body, JetBrains Mono for data).
- **Use the site's color palette.** Pull from CSS vars conceptually (warm borders #ddd9d0, green #137333, red #c5221f, paper #fafaf7).
- **Remove decorative-only elements.** A red bar that only appears in one of four boxes creates inconsistency. Every visual element should appear in all peers or none.
- **Tighten vertical spacing.** First drafts always have too much gap between the check boxes and the decision diamond. Reduce by 30-40px.

## Expandable Content Patterns

Two patterns emerged that work well for dense stakeholder content:

### Slide-over panel (for full documents)
Use for raw memos, quality reports, or any content >500 words. Button in the card triggers a fixed right panel (width: min(640px, 90vw)) with:
- Header showing run label + PASS/FAIL badge
- Close button (X), backdrop click, and Escape key all close
- pre element with monospace font, white-space: pre-wrap
- Body scroll lock while open (document.body.style.overflow = 'hidden')

### Details/summary accordions (for appendix sections)
Use for supplementary content the reader may want to drill into (appendix files, source indices). Native details element with:
- Custom arrow (triangle rotates 90deg on open via CSS transform)
- Badge on summary for scores/counts (margin-left: auto)
- Border-top separator between summary and content
- Content paragraphs at 13px with bold labels

## Color for Progress Bars

Don't use red/amber/green traffic light colors for accuracy progression bars. A run can PASS but still have errors (e.g., 97% accuracy with one failure). Use a single-hue ramp that darkens with improvement (e.g., slate: #94a3b8, #64748b, #475569, #1e293b). Shows progression through intensity without implying bad-to-good judgments that may not match the data.

## Copy for This Audience

Run the writer skill. Key corrections that recur:
- Kill "institutional-quality" (puffery)
- Kill "X, not Y" formulaic contrasts
- Kill manufactured drop endings ("Three iterations. Zero errors.")
- Prefer specific claim counts ("35/36 claims traced to source") over percentages ("97% accuracy")
- "40min from input to cited memo" beats "fast turnaround" every time
- Admit the failure: naming the one wrong result builds more trust than "97% accuracy"

## Font Inheritance Pitfall

When adding new subsections inside result cards (e.g., "execution detail"), nested ul and li elements inherit the browser default font size, not the card's styled size. Always add explicit font-size: 13px and matching bullet styles to new nested containers. Check visually; the mismatch is obvious on mobile.
