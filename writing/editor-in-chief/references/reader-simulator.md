---
name: reader-simulator
description: Read a draft as the target reader and identify where they'd skim, screenshot, or bounce. Inspired by Sudowrite's Reader Simulator (featured). Use as final revision pass before publishing.
---

# Reader Simulator

Get inside your reader's head. Read the draft as *them*, not as the author. Find where they'd skim, where they'd screenshot, and where they'd bounce.

## Process

### Step 1 — Define the Reader

Use the target reader from **evaluate-content** question #6, or define one now:
- **Who:** [one sentence description — age, role, situation]
- **Trigger:** [what happened that made them need this article]
- **What they'd Google:** [the search query that led them here]
- **Awareness level:** unaware / problem-aware / solution-aware / product-aware
- **Reading context:** phone on commute? laptop at desk? scanning Twitter?

### Step 2 — Read as the Reader

Go through the entire draft in order, annotating:

**🟢 Screenshot moments** — Where would the reader stop and screenshot to send to a friend? These are your best content. You want at least 2-3 per article.

**🟡 Skim zones** — Where would the reader's eyes glaze over and start scanning for the next bold text or heading? These need to be cut or rewritten.

**🔴 Bounce points** — Where would the reader close the tab entirely? Usually happens when:
- The intro takes too long to get to the point
- A section feels like it's repeating something already said
- The reader feels talked down to
- A claim is made without evidence and the reader thinks "prove it"

**❓ Unanswered questions** — What would the reader still want to know after reading? These are either gaps to fill or hooks for a follow-up article.

### Step 3 — The Five Tests

Run each of these on the draft:

**1. The 8-Second Test (Intro)**
Read only the title, subtitle, and first 3 sentences. Would the target reader keep going?
- If they're on their phone, scrolling Twitter, and see this — do they tap?
- If not, the intro needs a stronger hook or faster payoff.

**2. The Skim Test (Structure)**
Read only the headings and bold text. Does the article's argument come through?
- A skimmer should get 60% of the value from headings + bold alone
- If the headings are generic ("Background", "Analysis", "Conclusion"), they fail this test

**3. The "So What?" Test (Every Section)**
After each section, ask "so what?" If you can't answer in one sentence, the section doesn't have a clear point.

**4. The Screenshot Test (Shareability)**
Identify the 2-3 most shareable sentences or paragraphs. If you can't find any, the article lacks a standout insight.
- Good screenshots: surprising data, a hot take stated crisply, a perfect analogy
- Bad screenshots: generic advice, obvious observations

**5. The Subscribe Test (Ending)**
After reading the closing, would the target reader subscribe for more?
- Does the ending make them feel smarter, more confident, or more curious?
- Or does it fizzle into "hope you found this helpful"?

## Output Format

```markdown
## Reader Simulation: [article title]

### Target Reader
[who / trigger / search query / awareness / context]

### Annotations
| Section | Rating | Note |
|---------|--------|------|
| Title + subtitle | 🟢/🟡/🔴 | [would they click?] |
| Intro (¶1-3) | 🟢/🟡/🔴 | [would they keep reading?] |
| Section 1 | 🟢/🟡/🔴 | [annotation] |
| Section 2 | 🟢/🟡/🔴 | [annotation] |
| ... | ... | ... |
| Closing | 🟢/🟡/🔴 | [would they subscribe?] |

### Screenshot Moments 🟢
1. ¶X: "[quote]" — shareable because [reason]
2. ¶Y: "[quote]" — would get screenshotted for [reason]

### Skim Zones 🟡
1. ¶X-Y: [why it's skimmable + fix suggestion]

### Bounce Points 🔴
1. ¶X: [why they'd leave + fix]

### Unanswered Questions ❓
1. [question the reader would still have]
2. [question]

### Five Test Results
| Test | Pass? | Note |
|------|-------|------|
| 8-Second (intro) | ✅/❌ | |
| Skim (structure) | ✅/❌ | |
| So What? (sections) | ✅/❌ | |
| Screenshot (share) | ✅/❌ | |
| Subscribe (ending) | ✅/❌ | |
```

## References

- Part of **writer** revision pipeline
- Run after **emotion-amplifier**, before **evaluate-content**
- Uses target reader from **evaluate-content** question #6
