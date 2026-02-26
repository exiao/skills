---
name: show-dont-tell
description: Replace vague assertions with concrete evidence — data, examples, stories. Inspired by Sudowrite's Dev Edit Show Don't Tell (6.9k users). Use on non-fiction drafts.
---

# Show Don't Tell

For non-fiction: don't *tell* the reader something is true. *Show* them with data, an example, or a story. Every claim earns its place by proving itself.

## Process

Go section by section. For every claim or assertion, ask: "Am I telling or showing?"

### Telling vs. Showing

| Telling (weak) | Showing (strong) |
|----------------|-----------------|
| "This approach is incredibly effective." | "This approach caught 14 of 15 failure modes in the first run." |
| "AI agents are changing how people invest." | "Last Tuesday I asked my agent to screen 2,000 small-caps. It took 4 minutes. My analyst friend spent 3 days on the same list." |
| "Energy stocks have performed well historically." | "Exxon Mobil returned over 80% in 2022 alone." |
| "The sector is undervalued." | "Energy is 3.3% of the S&P 500. That's less than any single top-5 stock." |
| "Our evaluations showed mixed results." | "Product knowledge: 100% match. Tone: 20% match. Nearly random." |
| "This was a significant improvement." | "Response time dropped from 4.2 seconds to 0.8 seconds." |
| "Many users found this helpful." | "4 out of 5 beta testers said they'd pay for it. The fifth one already built a competitor." |

### Types of Evidence (Pick At Least One Per Section)

1. **Specific number** — percentages, dollar amounts, counts, dates
2. **Named example** — a real company, person, product, or event
3. **Personal anecdote** — "When I tried this..." / "Last week I..."
4. **Comparison** — before/after, us vs. them, then vs. now
5. **Quote** — from a user, expert, or source
6. **Visual** — chart, screenshot, or diagram that proves the point

### Red Flags (Sentences That Are Probably Telling)

- Contains "incredibly", "significantly", "very effective", "game-changing"
- Uses "many", "some", "several" without a number
- Claims something is "important" or "crucial" without showing why
- Uses passive voice to hide the actor ("It was discovered that...")
- Describes an outcome without the specific result

## Output Format

```markdown
## Show Don't Tell Report: [article title]

### Telling → Showing Rewrites
| Section | Telling (current) | Suggested Show |
|---------|-------------------|----------------|
| ¶3 | "This significantly improved performance" | "Latency dropped from 4.2s to 0.8s" |
| ¶7 | "Many users found this helpful" | Need specific number or quote |
| ¶11 | "The results were impressive" | What were the actual results? |

### Sections Missing Evidence
- Section 2: No numbers, examples, or stories. Needs at least one.
- Section 5: Has a claim about market trends with no source.

### Sections That Already Show Well ✅
- Section 1: Strong opening anecdote
- Section 4: Good data comparison
```

## References

- Part of **article-writer** revision pipeline
- Run after **remove-chaff**, before **emotion-amplifier**
