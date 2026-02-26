---
name: evaluate-content
description: "Use when judging content quality: shareability, readability, voice, cuttability, angle."
---

# Evaluate Content

Honest, brutal content evaluation. Run this on anything before it goes live — articles, threads, tweets, headlines, outlines.

## The Six Questions

Every piece of content gets judged on these six questions. Score each 1-5 and explain why.

---

### 1. "Would someone share this in a group chat?"

**What you're really asking:** Is this interesting enough that someone would text it to a friend unprompted?

**Score 5:** "I'm sending this to three people right now." It has a surprising fact, a spicy take, or it articulates something people feel but haven't been able to say.
**Score 3:** "Hm, interesting." They'd read it but not forward it. It's informative but not remarkable.
**Score 1:** "Why would I share this?" Generic, nothing new, reads like a summary of things people already know.

**Tests:**
- The Signulll test (John Rush): Would someone share this to virtue signal, say something they can't say themselves, or show off their taste?
- The screenshot test: Would someone screenshot a specific line and post it?
- The "actually" test: Does it contain something that makes people say "actually, did you know..."?

**Common failures:**
- Too balanced — no point of view worth sharing
- Too obvious — says what everyone already thinks
- Too niche — interesting but the reader can't explain it to someone else in one sentence

---

### 2. "Is this informative or fun to read?"

**What you're really asking:** Does the reader get something from this — either knowledge they didn't have, or entertainment they enjoyed?

**Score 5:** Reader learned something specific they can use, OR they genuinely enjoyed reading it. Ideally both.
**Score 3:** Some useful info but presented in a way that's easy to skim-and-forget. Or mildly entertaining but no substance.
**Score 1:** Neither. It's a slog to get through and you don't learn anything new.

**Tests:**
- The "so what?" test: After every section, ask "so what?" If you can't answer in one sentence, the section failed.
- The retention test: Close the article. What do you remember? If the answer is "not much" — it's not informative enough.
- The re-read test: Would you read any part of this twice? If yes, which part? That's your best content.

**Common failures:**
- All setup, no payoff — spends 500 words explaining context before saying anything new
- Data without insight — shows numbers but doesn't say what they mean
- Informative but dry — reads like a textbook, technically correct but boring

---

### 3. "Does it write like someone is talking?"

**What you're really asking:** Does this sound like a human wrote it, or does it sound like AI / a corporate blog / a college essay?

**Score 5:** You can hear the author's voice. Irregular sentences. Personal asides. Opinions stated directly. You'd recognize this writer's style blind.
**Score 3:** Mostly natural but has some stiff patches. Occasional "it's important to note" or "in this article we'll explore" slipping through.
**Score 1:** Full robot. Uniform sentence length. No personality. Could've been written by any AI or any corporate comms team.

**Tests:**
- Read it aloud. Where do you stumble? Those sentences are broken.
- The "bar test": Would you say this to a friend at a bar? If it sounds weird spoken, rewrite it.
- Ctrl+F the Kill Phrases list in `~/marketing/WRITING-STYLE.md`. Any hits = automatic deduction. This is the ground truth for voice — not generic "sounds human" criteria.
- Check for first-person. Zero "I" in an opinion piece = probably slop.
- Check sentence variety. Same-length sentences in a row = robot cadence.
- Cross-check against the Voice Fingerprint section of `~/marketing/WRITING-STYLE.md`: does it lead with a concrete moment (not a thesis)? Does it use specific numbers? Does it show the work rather than claim it? If none of these are present, it's not Eric's voice.

**Common failures:**
- Every paragraph starts with "This" or "The"
- No personality — could be attributed to anyone
- Uses filler transitions: "Furthermore," "Moreover," "Additionally,"
- Three adjectives in a row: "powerful, innovative, and transformative"

---

### 4. "What could I cut out?"

**What you're really asking:** Where does the reader's attention drift? What's there for the writer, not the reader?

**Score 5 (tight):** Every sentence earns its place. You couldn't cut anything without losing meaning.
**Score 3 (some fat):** 10-20% could go. Some repeated points, some throat-clearing, some sections that don't advance the argument.
**Score 1 (bloated):** 30%+ is filler. Repeats the same point in different words. Long preambles. Obvious padding.

**How to evaluate:**
- Mark every sentence as ESSENTIAL, NICE-TO-HAVE, or CUT
- Look for repeated points stated differently (the most common padding)
- Check opening paragraphs of each section — are the first 1-2 sentences throat-clearing?
- Count qualifiers: "very," "really," "quite," "somewhat," "in order to" — each one is a candidate for deletion
- If a section could be summarized in one sentence and nothing would be lost, cut it to one sentence

**Provide a specific cut list:**
```
CUT: [paragraph/sentence] — reason
CUT: [paragraph/sentence] — reason
TRIM: [paragraph/sentence] → [shorter version]
```

---

### 5. "What's the unique perspective or driving emotion?"

**What you're really asking:** Why does THIS person need to write THIS article? What's the angle only they can bring?

**Score 5:** Crystal clear point of view. You know exactly what the author believes and why. There's a driving emotion — frustration with the status quo, excitement about a discovery, pride in something they built.
**Score 3:** Has an angle but doesn't commit to it fully. Hedges too much. Or the emotion is there but buried under too much analysis.
**Score 1:** No angle. This could be a Wikipedia summary. No emotion. No stakes. No reason this person specifically needed to write this.

**Identify:**
- **The thesis** in one sentence. If you can't state it in one sentence, the article doesn't have one.
- **The driving emotion**: frustration, relief, pride, curiosity, anger, surprise? Name it.
- **The "only I" factor**: What does this author know/have experienced that makes them uniquely qualified? If anyone could've written this, it's not differentiated.

**Common failures:**
- "Balanced" pieces with no thesis — presenting information without a point of view
- Borrowed opinions — restating what everyone else says without adding anything
- The emotion exists but is buried in paragraph 7 instead of leading

---

### 6. "What kind of person would be looking for this article?"

**What you're really asking:** Who is this for? Can you picture them? What did they Google or scroll past that led them here?

**Score 5:** You can describe the reader in one sentence. Their problem is clear. The article directly addresses their situation.
**Score 3:** General audience. "People interested in investing." Not wrong, but not specific enough to drive strong resonance.
**Score 1:** Nobody in particular. Or the article serves two different audiences and does neither well.

**Identify:**
- **The reader** in one sentence: "A 28-year-old PM who just got assigned to an AI product and has no idea what evals are."
- **Their trigger**: What happened that made them need this? "Their AI shipped a wrong answer and the CEO noticed."
- **What they'd Google**: The search query that would lead to this. "how to test AI product quality"
- **Their awareness level** (from headlines skill):
  - Unaware: doesn't know the problem exists
  - Problem-aware: knows the problem, doesn't know the solution
  - Solution-aware: knows solutions exist, comparing options
  - Product-aware: knows your specific product

---

## Scoring Modes

### Classification Mode (used by editor-in-chief)

When invoked by the editor-in-chief skill, use **classification labels** instead of numeric scores. This maps the 6 questions to 6 dimensions with STRONG / NEEDS WORK / WEAK labels:

| Question | Dimension | STRONG | NEEDS WORK | WEAK |
|----------|-----------|--------|------------|------|
| Q1 (Shareable?) | Shareability | 2+ screenshot moments, reader would forward | Hook/insight exists but buried or undersold | Nothing worth sharing |
| Q2 (Informative/fun?) | Substance | Every claim backed by evidence | Mix of evidence and assertions | Vague claims, no proof |
| Q3 (Human voice?) | Voice | Sounds like the author, irregular rhythm, opinionated | Mostly human, some stiff patches or AI tells | Robot cadence, banned patterns present |
| Q4 (Cuttable fat?) | Leanness | Every sentence earns its place | 10-20% filler | 30%+ chaff |
| Q5 (Unique angle?) | Emotion | Driving emotion clear and felt throughout | Emotion exists but buried or inconsistent | Flat, no emotional throughline |
| Q6 (Target reader?) | Reader Fit | Clear reader profile, article directly serves them | General audience, not specific enough | Nobody in particular |

Output format for classification mode:
```
Shareability:  [STRONG|NEEDS WORK|WEAK] — [1-2 sentence explanation with specific examples]
Substance:     [STRONG|NEEDS WORK|WEAK] — [explanation]
Voice:         [STRONG|NEEDS WORK|WEAK] — [explanation]
Leanness:      [STRONG|NEEDS WORK|WEAK] — [explanation]
Emotion:       [STRONG|NEEDS WORK|WEAK] — [explanation]
Reader Fit:    [STRONG|NEEDS WORK|WEAK] — [explanation]
```

### Numeric Mode (standalone use)

When used standalone (not via editor-in-chief), use the original numeric scoring:

| Score | Meaning |
|-------|---------|
| 28-30 | Ship it. This is great. |
| 22-27 | Good but needs polish. Address the weakest scores. |
| 16-21 | Needs significant rework. Focus on scores below 3. |
| Below 16 | Start over or fundamentally rethink the angle. |

## Output Format (Numeric Mode)

```markdown
# Content Evaluation: [title or description]

## Scores
| Question | Score | One-line verdict |
|----------|-------|-----------------|
| Shareable? | X/5 | ... |
| Informative/fun? | X/5 | ... |
| Human voice? | X/5 | ... |
| Cuttable fat? | X/5 | ... |
| Unique angle? | X/5 | ... |
| Target reader? | X/5 | ... |
| **Total** | **XX/30** | |

## Detailed Feedback

### Shareable? (X/5)
[explanation + specific examples from the content]

### Informative/fun? (X/5)
[explanation + specific examples]

### Human voice? (X/5)
[explanation + flagged slop patterns]

### Cuttable fat? (X/5)
[specific cut list]

### Unique angle? (X/5)
[thesis + driving emotion + "only I" factor]

### Target reader? (X/5)
[reader profile + trigger + search query + awareness level]

## Top 3 Changes That Would Improve This Most
1. ...
2. ...
3. ...
```

## Hard Filters

Before scoring, check these. Any hit is a red flag that should pull the relevant score down:

- **Redundancy**: If any sentence merely restates the previous one in different words, flag it. One thought, one sentence.
- **Emotion-guiding**: If any sentence exists only to tell the reader how to feel ("This is exciting", "What's remarkable is"), flag it. The content should create the feeling, not name it.
- **Uncertain padding**: If quality is uncertain on a section, the fix is cutting, not adding. Less confident = write less. Silence beats slop.
- **Fake insider framing**: Flag any sentence using "The part nobody talks about..." / "What they don't tell you..." / "The real secret is..." / "Most people miss this..." / "Here's what most people get wrong..." — these imply secret knowledge without delivering anything genuinely exclusive. Pull Voice score down.

## Short-Form Video Hook Checklist

Use this when evaluating TikTok slideshows, YouTube Shorts scripts, or any short-form video content. Run before the 6 questions above.

A solo dev with zero audience, zero budget got 18M views in 28 days using these principles. Each is a binary pass/fail.

**Hook: Is it about the viewer, not the product?**
- ❌ "Bloom's AI analyzes stocks for you"
- ✅ "I let an AI pick my stocks for 30 days — here's what it found"
If the first line is about the product's features, it will flop. Rewrite until it opens with something the viewer experiences, fears, wants, or wonders about themselves.

**Angle: Is it broad enough for people outside your niche?**
- ❌ "Here's what this earnings report means for $NVDA investors"
- ✅ "Everyone laughed when I bought this stock. Now they're asking me how."
Can a non-investor relate to it? Can a non-user of your app still feel something from the opening? If only your target customer would watch past 3 seconds, the angle is too narrow.

**Curiosity gap: Is there something they need to see by the end?**
The hook must create a question the viewer needs answered. Tease a result, reveal, or test early — hold the answer until the final slide. If there's no unresolved tension, there's nothing keeping them to the end.

**Line discipline: Does every line earn the next?**
Read the script line by line. For each line, ask: does this build curiosity, escalate tension, or deliver on a promise? If it explains, teaches, or provides context without earning it — cut it. Information is the reward at the end, not the scaffolding throughout.

---

## Self-Check (Before Outputting Feedback)

Before delivering any evaluation or suggested rewrites, scan your own output for kill phrases. You are not exempt from the standards you're applying. Specifically:

- No fake insider framing in your own suggestions ("The part nobody talks about...", "What they don't tell you...")
- No formulaic contrast openers ("Every X is Y. This one isn't." / "It's not X, it's Y")
- No throat-clearing ("Here's the thing:", "The key insight is...")
- No vague rewrite examples — any rewrite you suggest must be as specific as the original content warrants. Generic improvement suggestions are not improvements.

If your feedback contains any of these patterns, rewrite the feedback before sending.

---

## Pillar-Level Evaluation (Monthly)

The six questions above evaluate individual pieces. Pillar evaluation assesses an entire content category over a month. Use this during monthly content reviews.

### What's a pillar?

A recurring content concept + 1-2 formats. Examples: "Insider trades via data cards," "Build log via Substack long-form," "Market explainers via TikTok slideshows." Run 3-5 pillars simultaneously.

### Pillar Scorecard

For each pillar, evaluate monthly:

| Dimension | Question | Data Source |
|-----------|----------|-------------|
| Volume | Did we hit the monthly post target? | Post count |
| Reach | Are new people seeing this? | Views, impressions |
| Resonance | Are people engaging beyond a view? | Saves, shares, comments |
| Growth | Is this attracting new audience? | New followers attributed |
| Conversion | Is this driving the business outcome? | Downloads, signups, revenue |
| Differentiation | Could anyone else make this content? | The "only I" factor from Q5 |

### Pillar Verdicts

Based on the scorecard, assign one verdict per pillar:

- **SCALE** — Strong on 4+ dimensions. Increase frequency. Make variations of winners. This is working.
- **KEEP** — Solid on 2-3 dimensions. Maintain current cadence. Don't fix what's not broken.
- **ELEVATE** — Weak on reach or resonance but the concept is sound. Pick exactly one lever:
  - Better hooks (change the opening line / first 2 seconds / slide 1)
  - Change production value (lo-fi → polished, or polished → lo-fi)
  - 2x the value (double the insight density or entertainment per post)
- **ROTATE OUT** — Underperforming for 2 consecutive months after elevation. Replace it. Move to the bench (retired pillars can come back when algorithms or trends shift).

### Monthly Recap Format

```markdown
## Content Pillar Review — [Month Year]

| Pillar | Posts | Views | Saves | Follows | Verdict |
|--------|-------|-------|-------|---------|---------|
| [name] | X     | X     | X     | +X      | SCALE   |
| [name] | X     | X     | X     | +X      | ELEVATE |

### Decisions:
- SCALE: [pillar] — reason, action (e.g., increase from 3x to 5x/week)
- ELEVATE: [pillar] — lever chosen (e.g., testing new hook style)
- ROTATE OUT: [pillar] → replaced by [new pillar]

### "Only I" Check:
- [pillar]: passes (score 3/3) — uses Bloom AI data + builder story
- [pillar]: borderline (score 1/3) — could be made more distinctive by [specific change]
```

### Pillar-Level vs Post-Level

| Level | Tool | Cadence | Purpose |
|-------|------|---------|---------|
| Post | The Six Questions (above) | Before publishing | Quality gate for individual pieces |
| Pillar | Pillar Scorecard (this section) | Monthly | Strategy: what categories to keep, improve, or drop |
| Channel | Platform analytics | Monthly | Distribution: where to post, cross-post decisions |

Use all three levels together. A great post (high individual score) in a dying pillar still needs the pillar rotated. A weak post in a strong pillar needs the post improved, not the pillar abandoned.

## When to Use This

- **Before publishing any article** — run the six questions as final gate
- **On thread hooks** — just questions 1, 3, and 5
- **On tweet batches** — just questions 1 and 3
- **On headlines** — just questions 1 and 5
- **When something underperforms** — diagnose why with all 6
- **Monthly content review** — run pillar-level evaluation across all active pillars

## References

- Used by **article-writer** (revision pass)
- Used by **typefully** (hook quality check)
- Used by **tweet-ideas** (tweet quality)
- Used by **headlines** (title evaluation)
- Shares voice standards with **article-writer** humanizer section
- **`~/marketing/WRITING-STYLE.md`** — ground truth for voice evaluation. Read the Kill Phrases list and Voice Fingerprint section before scoring Question 3. Generic "sounds human" is not the bar; Eric's specific fingerprint is.
