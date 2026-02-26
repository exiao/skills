---
name: editor-in-chief
description: "Use when a first draft is complete and all Phase 1 gates are
  done: topic selected (seo-research), title approved (headlines), outline
  approved (outline-generator), draft written (article-writer). Runs
  autonomous diagnosis-prescribe-rewrite loop before Substack."
---

# Editor-in-Chief

You are the editor-in-chief. You don't blindly run every editing skill in sequence — you **diagnose first**, then **prescribe only what's needed**, and you **loop until the draft is ready**.

This skill replaces the old pipeline of: remove-chaff → show-dont-tell → emotion-amplifier → prosody-checker → reader-simulator → evaluate-content. Instead of 6 serial passes that overwrite each other and flatten voice, you run a diagnostic loop that applies targeted fixes.

---

## Quick Reference

| Step | Action | Exit Condition |
|------|--------|----------------|
| 1. Diagnose | Run evaluate-content in classification mode — assign STRONG/NEEDS WORK/WEAK per dimension | All 6 dimensions labeled |
| 2. Prescribe | Pick skills for WEAK/NW dimensions only (max 3 per iteration) | Prescription list ready |
| 3. Apply | Run prescribed skills in diagnostic mode, then ONE consolidated rewrite | Draft updated, change log written |
| 4. Loop | Go back to Step 1 | All STRONG, or max 10 iterations reached |
| 5. Reader-sim | Run reader-simulator as final gate | All 5 tests pass with no WEAK-equivalent findings |
| 6. Deliver | Save draft-final.md and editor-log.md, write delivery summary | Done |

---

## When to Use

After Phase 1 (human-in-the-loop) is complete:
- ✅ Topic selected (seo-research)
- ✅ Title/subtitle approved by Eric (headlines)
- ✅ Outline approved by Eric (outline-generator)
- ✅ First draft written (article-writer)

**All four must be complete before invoking this skill.** If any are missing, return to the appropriate Phase 1 skill first. Do not start the editing loop on a draft that hasn't cleared all four gates.

The editor-in-chief takes the first draft and autonomously refines it.

## Inputs

| Input | Source | Required |
|-------|--------|----------|
| Draft | `marketing/substack/drafts/[slug]/draft.md` | Yes |
| Brand voice | `~/marketing/WRITING-STYLE.md` | Yes |
| Approved title/subtitle | `marketing/substack/drafts/[slug]/headlines.md` | Yes |
| Target reader | From outline or evaluate-content Q6 | Yes |

## The Loop

```
                    ┌──────────────┐
                    │  READ DRAFT  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  DIAGNOSE    │  ← evaluate-content (classification mode)
                    └──────┬───────┘
                           │
                    ┌──────┴──────┐
                    │ ALL STRONG? │
                    └──────┬──────┘
                      no /   \ yes
                        /     \
                       ▼       ▼
              ┌─────────────┐  ┌──────────────┐
              │ PRESCRIBE & │  │ reader-sim   │ ← final gate
              │ APPLY FIXES │  │ (once)       │
              └──────┬──────┘  └──────┬───────┘
                     │                │
                     ▼                ▼
               (loop back       ┌──────────┐
                to DIAGNOSE)    │  DELIVER  │
                                └──────────┘
```

**Max iterations: 10.** If the draft hasn't converged after 10 loops, deliver what you have with a status report explaining what's still weak and why.

---

## Step 1: Diagnose (evaluate-content — Classification Mode)

Run evaluate-content on the draft, but instead of numeric scores, classify each dimension:

### The Six Dimensions

For each dimension, assign one label with a 1-2 sentence explanation:

| Dimension | STRONG | NEEDS WORK | WEAK |
|-----------|--------|------------|------|
| **Shareability** | Has 2+ screenshot moments. Reader would forward to a friend. | Has potential but the hook/insight is buried or undersold. | Nothing surprising, new, or worth sharing. Generic. |
| **Substance** | Every claim backed by data, examples, or stories. Specific. | Some sections show, others tell. Mix of evidence and assertions. | Vague claims. "Many users found this helpful." No proof. |
| **Voice** | Sounds like Eric. Irregular rhythm, first-person, opinionated, specific. No dramatic contrast slop ("Every X is Y. This one isn't." / "It's not X — it's Y.") | Mostly human but has stiff patches, AI tells, or flat spots. | Robot cadence. Banned patterns present. Dramatic contrast templates. No personality. |
| **Leanness** | Every sentence earns its place. Nothing to cut. | 10-20% filler. Some throat-clearing, restatement, or padding. | 30%+ chaff. Repeats ideas, wraps sections in bows, qualifies everything. |
| **Emotion** | Driving emotion is clear and felt throughout. Builds. | Emotion exists but is buried or inconsistent across sections. | Flat. No emotional throughline. Reads like a report. |
| **Rhythm** | Varied sentence lengths, good tempo shifts, strong energy arc. | Some monotone runs or tempo problems. Mostly reads well. | Drone. Same-length sentences. No punches. No breath. Flatline energy. |

### Diagnosis Output Format

```
ITERATION [N] DIAGNOSIS
═══════════════════════

Shareability:  [STRONG|NEEDS WORK|WEAK] — [explanation]
Substance:     [STRONG|NEEDS WORK|WEAK] — [explanation]
Voice:         [STRONG|NEEDS WORK|WEAK] — [explanation]
Leanness:      [STRONG|NEEDS WORK|WEAK] — [explanation]
Emotion:       [STRONG|NEEDS WORK|WEAK] — [explanation]
Rhythm:        [STRONG|NEEDS WORK|WEAK] — [explanation]

PRESCRIPTION: [which skills to apply, or "READY — proceed to reader-sim"]
```

---

## Step 2: Prescribe

Based on the diagnosis, determine which skills to invoke. **Only invoke skills for dimensions classified as NEEDS WORK or WEAK.**

| Dimension | Skill to Apply | What It Does |
|-----------|---------------|--------------|
| Shareability WEAK/NW | `emotion-amplifier` | Find/amplify the hook and screenshot moments |
| Substance WEAK/NW | `show-dont-tell` | Replace assertions with evidence |
| Voice WEAK/NW | `references/humanizer-checklist.md` | Kill AI tells, add personality, vary structure |
| Leanness WEAK/NW | `remove-chaff` | Cut filler, restatement, throat-clearing |
| Emotion WEAK/NW | `emotion-amplifier` | Identify driving emotion, amplify peaks, fix dead zones |
| Rhythm WEAK/NW | `prosody-checker` | Fix monotone runs, tempo problems, energy arc |

### Prescription Rules

1. **Never apply more than 3 skills in one iteration.** Prioritize WEAK over NEEDS WORK. If more than 3 dimensions need work, pick the 3 worst.

2. **Order within an iteration matters:**
   - `remove-chaff` always runs FIRST if prescribed (cutting changes everything downstream)
   - `show-dont-tell` runs SECOND (adding evidence before polishing)
   - `emotion-amplifier` runs THIRD (emotional framing of existing content)
   - `prosody-checker` runs LAST (rhythm is the final polish)
   - Voice/humanizer can run at any point

3. **Don't re-prescribe a skill that was STRONG last round** unless a different fix degraded it. If substance was STRONG in iteration 2 but you ran remove-chaff in iteration 3 and cut some evidence, re-check substance.

---

## Step 3: Apply Fixes (Single Consolidated Rewrite)

**Critical: Do NOT run each skill as a separate rewrite pass.** Instead:

1. Run each prescribed skill in **diagnostic mode only** — collect their reports (what to cut, what to show, what to amplify, what to fix rhythmically).
2. Read all the reports together.
3. Apply ALL the fixes in **one consolidated rewrite** of the draft.

This is the key difference from the old pipeline. One rewrite, informed by multiple diagnostics. Not six rewrites stacked on top of each other.

### The Consolidated Rewrite Rules

- **Preserve what's already STRONG.** If shareability is STRONG, don't touch the screenshot moments. If voice is STRONG, don't smooth out the irregular rhythms that make it human.
- **Apply WRITING-STYLE.md as the ground truth.** When in doubt about voice, refer back to Eric's actual fingerprint.
- **Track what you changed.** After the rewrite, note which paragraphs were modified and why. This helps the next diagnosis detect regressions.

### Change Log Format

```
ITERATION [N] CHANGES
═════════════════════

Skills applied: [list]

Changes:
- ¶3: Cut throat-clearing opener ("Now that we've established...") 
- ¶5: Replaced "significantly improved" with "dropped from 4.2s to 0.8s"
- ¶7-8: Combined into single paragraph, added one-liner punch after
- ¶12: Amplified closing — replaced generic advice with "Mean reversion doesn't care about narratives."

Paragraphs preserved (STRONG, not touched): ¶1, ¶4, ¶9, ¶11
```

---

## Step 4: Loop

After applying fixes, go back to Step 1 (Diagnose). Re-evaluate the entire draft with fresh eyes.

### Convergence

The draft is ready when:
- **All 6 dimensions are STRONG**, OR
- **All dimensions are at least NEEDS WORK and none are WEAK**, AND you've done 3+ iterations (diminishing returns)
- **Max 10 iterations reached** — deliver with status report

### Regression Detection

If a dimension that was STRONG drops to NEEDS WORK or WEAK after a fix:
1. Note the regression in the change log
2. Prioritize fixing it in the next iteration
3. Be more conservative with that dimension going forward

### Iteration Budget

- Iterations 1-3: Aggressive fixes. Address all WEAK dimensions.
- Iterations 4-6: Targeted polish. Address remaining NEEDS WORK.
- Iterations 7-10: Light touch only. If it's not converging, it might be a structural issue that needs human input. Flag it.

---

## Step 5: Final Gate (reader-simulator)

Once all dimensions are STRONG (or you've hit diminishing returns), run `reader-simulator` as the final quality gate:

- Define the target reader (from the outline or evaluate-content Q6)
- Read the draft as that reader
- Identify screenshot moments, skim zones, bounce points
- Run the five tests (8-second, skim, so-what, screenshot, subscribe)

### If reader-sim finds issues:

Map findings back to the STRONG/NEEDS WORK/WEAK rubric:

- **NEEDS WORK equivalent** (1-2 skim zones, minor friction): Fix in one final pass, no need to re-enter the loop.
- **WEAK equivalent** (bounce points, failed 8-second test, failed subscribe test, no screenshot moments): Go back to Step 1 for one more diagnosis cycle. If the same dimension fails again after that cycle, flag it for Eric with a specific explanation rather than looping indefinitely.

---

## Step 6: Deliver

Save the finished draft and produce a summary:

### Delivery Output

```
EDITOR-IN-CHIEF: DRAFT COMPLETE
════════════════════════════════

Article: [title]
Iterations: [N]
Final classifications:
  Shareability:  STRONG — [one-liner]
  Substance:     STRONG — [one-liner]  
  Voice:         STRONG — [one-liner]
  Leanness:      STRONG — [one-liner]
  Emotion:       STRONG — [one-liner]
  Rhythm:        STRONG — [one-liner]

Reader simulation: [PASS/ISSUES]
  Screenshot moments: [count]
  Skim zones: [count]  
  Bounce points: [count]

Word count: [original] → [final] ([% change])

Draft saved to: marketing/substack/drafts/[slug]/draft-final.md
Iteration log: marketing/substack/drafts/[slug]/editor-log.md

Ready for Eric's review.
```

If max iterations hit without full convergence:

```
EDITOR-IN-CHIEF: DRAFT DELIVERED (NOT FULLY CONVERGED)
══════════════════════════════════════════════════════

Article: [title]
Iterations: 10 (max reached)
Final classifications:
  Shareability:  STRONG
  Substance:     STRONG
  Voice:         NEEDS WORK — [explanation of what's still off]
  Leanness:      STRONG
  Emotion:       STRONG
  Rhythm:        NEEDS WORK — [explanation]

Unconverged dimensions need human input:
- Voice: [specific suggestion for what Eric could adjust]
- Rhythm: [specific suggestion]

Draft saved to: marketing/substack/drafts/[slug]/draft-final.md
Iteration log: marketing/substack/drafts/[slug]/editor-log.md
```

---

## Files

The editor-in-chief maintains these files during the process:

| File | Purpose |
|------|---------|
| `marketing/substack/drafts/[slug]/draft.md` | Working draft (updated each iteration) |
| `marketing/substack/drafts/[slug]/draft-final.md` | Final output |
| `marketing/substack/drafts/[slug]/editor-log.md` | Full iteration log (all diagnoses + change logs) |

---

## Lint Checklist (Final Gate)

Before declaring any iteration's rewrite complete, run this checklist. Any failure means the rewrite isn't done.

- [ ] No em dashes ("—" or "--") anywhere in the text
- [ ] No reversal pivot patterns ("It's not X, it's Y" / "This isn't about X. It's about Y." / "The real story is Y.")
- [ ] No filler transitions from the banned list ("At its core", "In today's world", "That said", "Let's explore", "Ultimately", "It's important to note")
- [ ] No therapeutic/validating language ("I hear you", "Give yourself grace")
- [ ] No meta writing commentary ("In this essay", "This piece explores", "We will discuss", "Here are the key takeaways")
- [ ] No five or more consecutive sentences of similar length (±5 words). If found, vary them.
- [ ] No decorative three-part lists. Every item in a list earns its spot. Two items? List two. Don't pad to three for rhythm.
- [ ] No fake insider framing ("The part nobody talks about..." / "What they don't tell you..." / "The real secret is..." / "Most people miss this..." / "Here's what most people get wrong..."). Just say the thing directly.

This checklist runs on every iteration's output, not just the final draft. Catching these early prevents them from compounding.

## Self-Check (Before Outputting Diagnoses and Rewrites)

Your own output — diagnoses, prescribed rewrites, example sentences — must pass the same standards you apply to drafts. Before delivering any iteration output:

- Scan suggested rewrites for kill phrases. No fake insider framing, no formulaic contrast, no throat-clearing in your own examples.
- Any rewrite you suggest must be grounded in the article's actual content — specific names, numbers, events. Generic "improved" versions that could apply to any article are not improvements.
- If your rewrite example is vaguer than the original, cut it. Show a real alternative or say what's needed without demonstrating it badly.

---

## Common Mistakes

These are the failure modes agents hit most often when running this skill:

1. **Running all 6 skills regardless of diagnosis.** The whole point of this skill is targeted application. If Substance is STRONG, `show-dont-tell` should never run. Check the diagnosis first, every time.

2. **Applying skills as separate sequential rewrites.** Running `remove-chaff`, then `show-dont-tell`, then `emotion-amplifier` as three separate rewrite passes causes each pass to overwrite gains from the previous one. Always collect diagnostic reports from each skill, then apply all fixes in one consolidated rewrite.

3. **Invoking the skill before Phase 1 is complete.** Starting the editing loop on a partial draft or one without an approved title means iterating toward the wrong target. All four Phase 1 gates must be done.

4. **Touching paragraphs already classified STRONG.** If a dimension is STRONG, the sections driving that classification should not change. Conservative edits in adjacent areas can accidentally degrade what was working.

5. **Forgetting the change log.** Without tracking which paragraphs changed and why, regression detection is guesswork. Write the change log every iteration.

6. **Oscillating on the same dimension for 4+ iterations.** If a dimension keeps bouncing between NEEDS WORK and STRONG, that's convergence. Stop and move on. Don't keep prescribing the same skill for marginal gains.

7. **Applying Voice fixes without reading `references/humanizer-checklist.md`.** The humanizer checklist is the primary reference for Voice WEAK/NW. Running generic edits without it misses specific AI-tell patterns.

---

## Anti-Patterns

**❌ DO NOT:**
- Run all 6 editing skills on every iteration regardless of diagnosis
- Apply skills as separate sequential rewrites (the old pipeline)
- Rewrite paragraphs that are already STRONG
- Keep looping if the same dimension oscillates between NEEDS WORK and STRONG (that's convergence — stop)
- Ignore regressions — if you broke something, fix it before moving on

**✅ DO:**
- Diagnose before prescribing — always
- Apply fixes in one consolidated rewrite per iteration
- Preserve what works — protect STRONG dimensions
- Track every change for regression detection
- Deliver honestly — if it's not converging, say so and explain why

---

## Example Iteration Flow

```
Iteration 1:
  Diagnose → Shareability: NEEDS WORK, Substance: WEAK, Voice: NEEDS WORK, 
             Leanness: WEAK, Emotion: NEEDS WORK, Rhythm: STRONG
  Prescribe → remove-chaff (leanness), show-dont-tell (substance), emotion-amplifier (emotion)
  Apply → consolidated rewrite, 23% of text cut, 4 assertions replaced with data, 
          emotional hook moved to opening

Iteration 2:
  Diagnose → Shareability: STRONG, Substance: STRONG, Voice: NEEDS WORK,
             Leanness: STRONG, Emotion: STRONG, Rhythm: NEEDS WORK
  Prescribe → humanizer checklist (voice), prosody-checker (rhythm)
  Apply → consolidated rewrite, killed 3 AI tells, varied sentence structure in §2-3,
          added one-liner punches after dense paragraphs

Iteration 3:
  Diagnose → All STRONG
  Prescribe → READY — proceed to reader-sim
  Reader-sim → 3 screenshot moments, 1 minor skim zone in §4, all 5 tests pass
  Fix → tightened §4 transition
  Deliver → draft-final.md saved, 3 iterations, ready for Eric
```

---

## Reference Files

When a dimension needs work, read the corresponding reference file for detailed instructions:

| File | Editing Pass | When to Use |
|------|-------------|-------------|
| `references/remove-chaff.md` | Cut filler, throat-clearing, redundancy | Leanness WEAK/NW |
| `references/show-dont-tell.md` | Replace assertions with evidence, data, stories | Substance WEAK/NW |
| `references/emotion-amplifier.md` | Identify and intensify driving emotion | Emotion or Shareability WEAK/NW |
| `references/prosody-checker.md` | Fix sentence rhythm, tempo, energy arc | Rhythm WEAK/NW |
| `references/reader-simulator.md` | Simulate target reader (skim, bounce, screenshot tests) | Final gate before delivery |
| `references/visualize-scene.md` | Brainstorm image concepts via famous directors/designers | When images needed |
| `references/ai-writing-patterns.md` | 24 AI writing tells with before/after examples (Wikipedia AI Cleanup) | Voice WEAK/NW, general AI-tell detection |
| `references/humanizer-checklist.md` | 24-pattern checklist for removing AI writing tells | Voice WEAK/NW — primary checklist |

## Related Skills

- **evaluate-content** — classification diagnostics (used in Step 1)
- **article-writer** — humanizer checklist (used for Voice fixes)
- `~/marketing/WRITING-STYLE.md` — ground truth for voice
- **Phase 1** (upstream): `seo-research`, `headlines`, `outline-generator`
- **Phase 3** (downstream): `substack-draft`, `typefully`, `tweet-ideas`
