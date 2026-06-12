# Visual proposal pages

Use when the user asks to turn recommendations, copy strategy, product critique, or design feedback into a shareable page.

## Pattern

Create a static, polished page that makes the recommendation visible before it explains it. For website copy or positioning reviews, prefer a before/after narrative:

1. Hero states the goal in one sharp sentence.
2. Before/after panels show the current direction and proposed direction side by side.
3. Proof strip pulls the strongest metrics or claims up front.
4. Visual modules turn abstract strategy into diagrams, maps, timelines, or cards.
5. Copy table translates current phrases into proposed phrases.
6. Final recommendation gives the page architecture and strongest next step.

## Stakeholder / portfolio pages

When the audience is non-technical (portfolio managers, investors, executives), apply these rules:

**Content selection:**
- Lead with the problem the product solves, not how it was built.
- Show the output (a sample memo, a dashboard screenshot, a result), not the engineering (PR counts, commit history, skills grids).
- Use metrics the audience cares about (accuracy, error rate, time saved), not builder metrics (lines of code, test count).
- Cut anything that requires domain knowledge to parse (eval scenario lists, data source inventories, repo stats). Move it to an appendix or drop it entirely.
- "Half the length, twice the signal" is the target.

**Story arc for product demos:**
1. Problem framing (why current tools fail)
2. How we solve it (pipeline/process, not code)
3. Proof it works (before/after, improvement metrics)
4. See for yourself (sample output, interactive elements)
5. Verification / trust evidence

**Expandable content for long-form detail:**
When stakeholders need access to full outputs (memos, reports, transcripts) without cluttering the summary page, use a slide-over panel pattern:
- Button at bottom of each summary card: "View full memo" with arrow icon
- Panel slides in from the right (fixed position, 640px or 90vw max)
- Header with context (run label, date, PASS/FAIL badge) + close button
- Scrollable monospace `<pre>` for raw content
- Backdrop overlay (rgba black 0.3) + Escape key to close
- Body scroll lock while panel is open
- Load content from a separate JS file to keep HTML clean

## Aesthetic choices that worked

For aerospace, defense, frontier-tech, or investor-facing proposals:
- Use a "classified technical memo" feel: dark background, cream type, thin borders, mono labels, one sharp accent color.
- Use diagrams instead of generic cards: layers, mission map, orbit/revisit timeline, roadmap, proof stack.
- Make specs carry the argument: altitude, latency, coverage, persistence, reusability.
- Keep the visual language close to the client's brand but make hierarchy more explicit than the original site.

For finance/research/institutional audiences:
- Editorial aesthetic: serif headlines (Instrument Serif) + sans-serif body (DM Sans), warm paper tones, no dark mode.
- No gradient text, no card soup, no glassmorphism. These audiences associate that with AI slop.
- Monospace (JetBrains Mono) for data, metrics, and verification tables.
- Tinted neutrals over pure grays. Warm off-whites (#fcfcfa, #f5f3ed) over stark white.
- Red/green only for PASS/FAIL semantics, not decoration.

## Surge deployment checklist

- Write `index.html` and a primary asset file such as `styles.css`.
- Add a `CNAME` file if deploying to a stable Surge domain.
- Verify locally in a browser before deploying.
- Deploy with `surge . <domain>.surge.sh`.
- Open the production URL and visually verify CSS loaded, fonts render, sections are present, and no layout breakage is visible.

## Pitfalls

- Do not deliver only a written plan when the user asks for visual before/after. Build the page.
- Do not make the page a generic portfolio template. The visuals should encode the actual strategic argument.
- Watch for hero crowding with oversized type and right-side visuals. Verify with a screenshot or visual inspection before publishing.
- First drafts of stakeholder pages almost always have too much engineering detail. The user will ask you to cut. Anticipate this by filtering through the audience lens before building.
- When embedding long-form content (memos, reports), use expandable panels instead of inlining the full text. Inlined content makes the page feel like a changelog, not a product showcase.
