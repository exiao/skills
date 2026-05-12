---
name: prosody-checker
description: Measure and improve the rhythm, tempo, stress, and pacing of written content. Analyzes sentence length patterns, syllable density, paragraph cadence, and energy flow to make articles feel natural when read aloud.
---

# Prosody Checker

Writing has a sound, even when read silently. Good writing has varied rhythm. Bad writing drones. This skill measures the musicality of a piece and fixes the flat spots.

## What Prosody Means for Non-Fiction

- **Rhythm** — the pattern of short and long sentences. Monotone = boring.
- **Tempo** — how fast the piece moves. Dense paragraphs slow it down. One-liners speed it up.
- **Stress** — which words and ideas get emphasis. Bold, italics, sentence position, paragraph breaks.
- **Intonation** — the rise and fall of energy across the piece. Should build, not flatline.

## Process

### Step 1 — Sentence Length Map

Count the word count of every sentence and plot the pattern:

```
S1: 14 ████████████████
S2: 6  ████████
S3: 3  ████
S4: 22 ██████████████████████████
S5: 19 ███████████████████████
S6: 21 █████████████████████████
S7: 4  █████
```

**What to look for:**
- **Monotone runs**: 3+ sentences in a row within ±5 words of each other = robot cadence. **5+ consecutive similar-length sentences is an automatic fail.** Fix by splitting a long one or combining two short ones.
- **Missing punches**: No sentences under 6 words in a section = no emphasis. Short sentences hit hard. Use them.
- **Missing breath**: No sentences over 20 words in a section = staccato fatigue. Longer sentences give the reader space to settle in before the next punch.
- **Vary aggressively**: The ideal pattern is irregular. Long-short-medium-short-long-short. Like jazz, not a metronome. If you can swap two adjacent sentences and nobody would notice, the rhythm is too uniform.

**Reference — Ahmad Jivraj's rhythm:**
> "Everyone talks about AI." (5) / "Nobody wants to talk about oil." (7) / "And that, right there, might be the opportunity." (9)

> "Position sizing isn't about how many dollars you put in." (11) / "It's about how much risk you're taking." (8)

> "Most people can't do it." (5) / "That's precisely why it works." (6)

Short-short-medium. Punch-punch-land.

### Step 2 — Paragraph Tempo Map

Classify each paragraph by tempo:

- **⚡ Fast** (1-2 sentences, under 30 words) — punchy, emphatic, transitional
- **🚶 Medium** (3-4 sentences, 30-80 words) — standard argument building
- **🐢 Slow** (5+ sentences or 80+ words) — dense explanation, data-heavy, deep dive

Map the pattern:

```
¶1:  🚶 Medium (setup)
¶2:  ⚡ Fast (one-liner punch)
¶3:  🐢 Slow (data section)
¶4:  🐢 Slow (more data)
¶5:  🐢 Slow (still going)  ← PROBLEM: three slow in a row
¶6:  ⚡ Fast (transition)
¶7:  🚶 Medium (argument)
```

**Rules:**
- Never more than 2 slow paragraphs in a row without a fast break
- Every section should have at least one ⚡ fast paragraph
- After a dense data section, give the reader a one-liner to breathe
- The opening and closing should be ⚡ or 🚶, never 🐢

### Step 3 — Stress Pattern

Check where emphasis falls. In writing, stress comes from:

**1. Position stress** — The first and last sentences of a section carry the most weight. Are your best lines there, or buried in the middle?
- First sentence = the hook. Should be surprising, specific, or provocative.
- Last sentence = the landing. Should resolve or open a loop.
- If your best insight is in sentence 3 of 5, move it to sentence 1 or 5.

**2. Typographic stress** — Bold, italics, standalone lines. Are you using them intentionally or randomly?
- Bold should highlight the one key insight per section, not decorate every other phrase
- Standalone one-liners get automatic stress — use for your strongest points
- If nothing is bolded or set apart, everything has equal weight = nothing stands out

**3. Structural stress** — Short paragraphs after long ones create emphasis through contrast.
- ❌ Long paragraph. Long paragraph. Long paragraph. (flat)
- ✅ Long paragraph with buildup. Short punch. Medium follow-through. (dynamic)

### Step 4 — Energy Arc

Map the energy level of each section (1-5 scale):

```
Intro:    ████░ (4) — strong hook
Section 1: ███░░ (3) — context setting
Section 2: ██░░░ (2) — uh oh, energy drop
Section 3: ████░ (4) — data that surprises
Section 4: █████ (5) — the "aha" moment
Section 5: ███░░ (3) — practical advice
Closing:   ████░ (4) — strong landing
```

**The ideal energy arc:**
- **Open high** (4-5) — hook them immediately
- **Can dip** (2-3) — for necessary context, but don't stay low for more than one section
- **Build to a peak** (5) — the central insight or "aha"
- **Close high** (4-5) — punchline, not a fizzle

**Red flags:**
- Energy drops below 2 for more than one consecutive section = reader is bored
- Energy never reaches 5 = the piece lacks a clear peak
- Closing is lower energy than opening = the piece deflates

### Step 5 — Read Aloud Test

The ultimate prosody test. Read the piece aloud (or imagine reading it) and mark:
- Where you run out of breath (sentence too long, needs a break)
- Where you stumble (awkward phrasing, tongue twisters)
- Where your voice goes monotone (repetitive structure)
- Where you naturally speed up (good — the writing has pull)
- Where you naturally slow down (good if intentional for emphasis, bad if boring)

## Output Format

```markdown
## Prosody Report: [article title]

### Sentence Length Map
[visual bar chart of sentence lengths per section]

**Monotone runs:** [locations where 3+ sentences are similar length]
**Missing punches:** [sections with no short sentences]
**Missing breath:** [sections with no long sentences]

### Paragraph Tempo Map
[⚡🚶🐢 pattern for each paragraph]

**Tempo problems:**
- ¶X-Y: Three slow paragraphs in a row. Break with a one-liner after ¶X.
- Section Z: No fast paragraphs. Add a standalone punch line.

### Stress Analysis
**Position stress issues:**
- Section X: Best line is buried in ¶3. Move to opener or closer.

**Typographic stress issues:**
- Too much bold in Section Y (5 bolded phrases = nothing stands out)
- Section Z has no emphasis at all

### Energy Arc
[1-5 scale visualization per section]

**Issues:**
- Energy dips to 2 in sections X-Y. Needs a surprising fact or one-liner to break the lull.
- Closing energy is 2 — needs a stronger landing.

### Read Aloud Notes
- ¶X: "..." — run-on, split after "..."
- ¶Y: "..." — awkward phrasing, suggest: "..."
- ¶Z: Three paragraphs in a row with same structure — vary.

### Top 3 Pacing Fixes
1. [most impactful change]
2. [second most impactful]
3. [third]
```

## References

- Part of **writer** revision pipeline (optional, for polish)
- Run after **remove-chaff** (chaff removal changes the rhythm)
- Complements **emotion-amplifier** (pacing serves emotion)
