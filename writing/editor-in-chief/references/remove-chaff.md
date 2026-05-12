---
name: remove-chaff
description: Cut filler, throat-clearing, and redundancy from drafts. Inspired by Sudowrite's Remove Chaff plugin (6.5k users). Use on any draft before publishing.
---

# Remove Chaff

AI writing contains chaff. It's not advancing the argument. It's wrapping things neatly in a bow. It's restating what was just said in different words. Kill it.

## Process

Go paragraph by paragraph. For each one, mark it:
- **ESSENTIAL** — advances the argument, provides new info, or creates necessary tension
- **NICE-TO-HAVE** — adds flavor but the piece survives without it
- **CUT** — filler, restatement, or throat-clearing

Then cut all the CUTs and most of the NICE-TO-HAVEs.

## What Chaff Looks Like

### 1. Section Mini-Summaries
AI loves to wrap up every section by restating what was just said.
- ❌ "As we've seen, energy stocks represent a compelling opportunity in today's market environment."
- ✅ Just end the section. The next section's hook does the transition work.

### 2. Throat-Clearing Openers
The first 1-2 sentences of each section are often filler. Delete them and see if the section reads better. If yes, they were chaff.
- ❌ "Now that we've established the macro backdrop, let's turn our attention to individual stock selection."
- ✅ Start with the actual point: "Three stocks stand out."

### 3. Connective Tissue That Says Nothing
- ❌ "With that in mind, let's look at..."
- ❌ "Building on the previous point..."
- ❌ "This brings us to an important consideration."
- ✅ Just start the next point. The reader can follow.

### 4. Restating the Same Idea in Different Words
- ❌ "The sector is undervalued. It's trading at a significant discount to its historical average. Valuations are compressed relative to the broader market."
- ✅ Pick one. "The sector trades at 3.3% of the S&P — a 75% discount from its 2011 weighting."

### 5. Qualification Bloat
- ❌ "It's worth noting that, in many cases, investors who carefully consider..."
- ✅ "Most investors who..."

### 6. Empty Intensifiers
Every "very", "really", "quite", "extremely", "incredibly", "significantly" is a candidate for deletion. If removing it doesn't change the meaning, it was chaff.

### 7. Redundant Transitions
- ❌ "Additionally," / "Furthermore," / "Moreover,"
- ✅ Just start the sentence. If the logic flows, you don't need a signpost.

## Output Format

```markdown
## Chaff Report: [article title]

### Cuts (remove entirely)
- ¶3: "As we've seen, this represents..." — section summary, adds nothing
- ¶7: "With that in mind..." — empty transition
- ¶12-13: Restates ¶11 in different words

### Trims (shorten)
- ¶1: "It's important to understand that investors should carefully consider" → "Consider"
- ¶9: Remove "very" and "significantly" (2 instances)

### Stats
- Original: X words
- After cuts: Y words
- Reduction: Z%
- Target: 20-30% reduction
```

## References

- Part of **article-writer** revision pipeline
- Run before **show-dont-tell**
