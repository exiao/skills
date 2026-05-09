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

## Aesthetic choices that worked

For aerospace, defense, frontier-tech, or investor-facing proposals:
- Use a “classified technical memo” feel: dark background, cream type, thin borders, mono labels, one sharp accent color.
- Use diagrams instead of generic cards: layers, mission map, orbit/revisit timeline, roadmap, proof stack.
- Make specs carry the argument: altitude, latency, coverage, persistence, reusability.
- Keep the visual language close to the client’s brand but make hierarchy more explicit than the original site.

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
