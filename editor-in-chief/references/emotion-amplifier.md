---
name: emotion-amplifier
description: Identify and intensify the driving emotion in a piece of content. Inspired by Sudowrite's Emotion Enhancer (9.3k users). Use on drafts to make them hit harder.
---

# Emotion Amplifier

Every piece of content that works has a driving emotion. Find it. Then turn it up.

## The Three Emotions That Drive Action

From John Rush / headlines skill:
1. **Frustration** — "I'm done with this crap." Call out what's broken.
2. **Relief** — "This finally fixed it." Promise the solution.
3. **Pride** — "I feel like myself again." Make them feel smart for reading.

Other drivers: **curiosity** (I need to know), **surprise** (I didn't expect that), **anger** (this is wrong), **vindication** (I knew it).

## Process

### Step 1 — Identify the Emotion

Read the draft and answer:
- What emotion is the author feeling? (frustration with AI slop? pride in what they built? curiosity about a result?)
- What emotion should the *reader* feel?
- Are they the same? If not, which one matters more?

State it in one sentence: "The driving emotion is **[emotion]** because **[reason]**."

### Step 2 — Find Where It Lives

Scan the draft for the emotional peaks — the sentences that actually make you *feel* something. Mark them. These are your anchors.

Then find the emotional dead zones — sections where the energy drops, where it reads like a textbook. These need work.

### Step 3 — Amplify

**In the opening (first 3 sentences):**
The emotion should be present immediately. Don't bury the thing that makes this piece interesting under context-setting.
- ❌ "In this article, we'll examine the state of AI investing tools and their effectiveness."
- ✅ "Most AI investing tools just Google things for you. I know because I built one."

**In transitions between sections:**
Each section break is a moment where the reader might leave. Use the emotion to pull them forward.
- ❌ "Next, let's look at the results."
- ✅ "Here's where it fell apart." (if frustration/surprise)
- ✅ "And then something unexpected happened." (if curiosity)

**In the data/evidence:**
Numbers are more powerful when the reader already feels something about them.
- ❌ "The sector represents 3.3% of the S&P 500."
- ✅ "The entire oil and gas industry — the stuff that literally powers the global economy — has been reduced to a rounding error."

**In the closing:**
The emotion should resolve or intensify. Never let it fizzle into generic advice.
- ❌ "In conclusion, investors should consider adding energy exposure to their portfolios."
- ✅ "Mean reversion doesn't care about narratives. It just happens."
- ✅ "Most people can't sit still for 3 years. That's precisely why it works."

### Step 4 — Vulnerability Check

Every article needs at least one moment of honesty that makes the author human:
- Admitting a mistake ("Coffee Can 11 was a result of hubris")
- Sharing uncertainty ("I don't know if this will work, but here's why I'm trying")
- Acknowledging the counterargument genuinely ("I'd be dishonest if I didn't mention the headwinds")

If the draft has zero vulnerability, it reads like a press release.

## Output Format

```markdown
## Emotion Report: [article title]

### Driving Emotion
[emotion] — [one sentence why]

### Emotional Peaks ✅
- ¶X: "[quote]" — this hits because [reason]
- ¶Y: "[quote]" — strong moment of [emotion]

### Dead Zones (needs work)
- ¶X-Y: Reads like a textbook. Suggestion: [rewrite idea]
- ¶Z: Data presented without emotional context. Frame it as [suggestion]

### Opening Check
- Current: [first sentence]
- Emotion present in first 3 sentences? [yes/no]
- Suggestion: [if needed]

### Closing Check
- Current: [last sentence]
- Does it resolve/intensify? [yes/no]
- Suggestion: [if needed]

### Vulnerability Check
- Found: [yes/no, with location]
- If missing, suggest where to add one
```

## References

- Part of **article-writer** revision pipeline
- Run after **show-dont-tell**, before **reader-simulator**
- Shares emotion framework with **headlines** and **evaluate-content**
