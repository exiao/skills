# SOUL.md Audit Checklist

9 items, 1 point each, binary, across four dimensions: Hermes-mechanics M1-M3 (3 points),
voice V1-V2 (2), attention hygiene P1-P3 (3, borrowed from skill-audit and applied to
persona files), and readability R1 (1).

## Mechanics (3 points) — how Hermes actually loads the file

### M1: Scope fits the SOUL's archetype
Decide which archetype this is first, because "commands don't belong in SOUL" is only true for one of them:

- **Persona/voice SOUL** (a general assistant whose job is *who it is*): content should be durable voice, identity, and stance. Repo conventions, file paths, commands, tool syntax, and architecture notes are drift. They belong in AGENTS.md. For this archetype, operational detail is an M1 fail (relocate, don't delete).
- **Task-operator SOUL** (a profile or lane with one main job it grabs skills for, like research-lead): the operational spine IS the identity. The primary objective, the skill inventory, the delegation workflow, the command sequences, and the folder map are what the agent *is*, not clutter. They belong in SOUL on one condition: that no AGENTS.md actually loads for this profile and owns them. If a loaded project-context file could hold the volatile commands, prefer it. It won't truncate first and won't stale the identity slot. If SOUL is the only durable slot the profile has, the operational content is correct there.
- **Why:** SOUL loads from HERMES_HOME and is slot #1. The real test isn't "is this a command" but "does this content have a better home that actually loads for this agent?" For a persona with a project AGENTS.md, yes. For a standalone profile, often no.
- **Pass:** a persona SOUL is voice-only; OR a task-operator SOUL carries operational content that has no better loaded home.
- **Fail:** a persona SOUL leaks project detail into voice; OR a task-operator SOUL duplicates commands and paths that a loaded AGENTS.md already owns (the stale-duplicate trap). When you flag this, say which archetype you judged it as first.

**Task-operator ordering (the right shape for this archetype):** who you are, then primary objective, then how to behave and write, then skills, then workflows, then memory, then folders. Identity and objective go first, in the high-attention slot. Reference material (skills, folder map) goes to the back. A task SOUL that buries its primary objective below its skill list is mis-ordered even if every line belongs.

### M2: Truncation safety
- File is under `context_file_max_chars` (default 20,000 / ~7k tokens), OR, if over, its identity and hard constraints live in the first ~70% and the closing ~20%, never only in the middle.
- **Why:** over-limit files are cut to 70% head + 20% tail with the middle 10% replaced by a marker. A rule in the middle of a long SOUL is the first thing dropped from the prompt.
- **Short-file auto-pass:** a file comfortably under the limit passes M2 outright. (Shorter-is-better is scored separately, under R1. M2 only asks "does it survive truncation?")
- **Pass:** under limit, or critical content is front/end-loaded.
- **Fail:** over limit with identity that must survive or constraints stranded mid-file.

### M3: Injection-scan clean
- No text that trips Hermes' prompt-injection scanner: "ignore previous instructions", "disregard your rules", "do not tell the user", "system prompt override", hidden HTML comments (`<!-- ... -->`), hidden divs, `curl ... $API_KEY`, `cat .env` / `cat credentials`, or invisible, zero-width, or bidi characters.
- **Why:** a single tripped pattern blocks the ENTIRE file and Hermes silently falls back to its default identity. The best-written SOUL is worthless if it never loads.
- **Pass:** no scanner-tripping phrases or hidden characters.
- **Fail:** any blocking pattern present. Fix = rephrase the offending line. You can express the same constraint without the trigger phrase.

## Voice (2 points) — identity quality

### V1: Specific voice, not generic filler
- Adds real, distinctive personality and stance.
- Does NOT spend lines restating what Hermes already does by default ("be helpful", "be clear", "be accurate", "assist the user").
- **Why:** SOUL.md replaces the default identity. The baseline is already helpful and clear, so generic filler adds zero signal while it eats the highest-attention slot in the prompt.
- **Pass:** a stranger reading it could describe how this agent sounds differently from a stock assistant.
- **Fail:** mostly evergreen platitudes any assistant would already follow.

### V2: Concrete examples, not just adjectives
- Demonstrates the intended behavior with at least one concrete instance (a sample of good pushback, a "when I say X do Y", a worked example of the tone), not only abstract adjectives.
- **Why:** examples are the strongest signal a model has for a target behavior. A pile of synonyms for "be direct" tells it the register but not your actual line.
- **Judgment exception:** a deliberately terse voice can pass by *being* terse. Don't force worked examples onto a file whose demonstrated point is brevity.
- **Pass:** the reader can point to a concrete example of the behavior, not just its name.
- **Fail:** 100% abstract exhortation, no instance of the behavior in action.

## Attention hygiene (3 points) — borrowed from skill-audit's P dimension

### P1: Non-negotiables are front-loaded
- Hard constraints (safety bans, "never without approval", irreversible-action gates) appear near the top of the file, not buried only mid-file.
- **Why:** models show a U-shaped attention bias: highest at the start and end, degraded in the middle, strongest when input fills up to ~50% of the window (2307.03172, 2508.07479). This compounds with M2: the low-attention middle is also the truncated middle. So the hard rules go at the top, where primacy and truncation-safety both favor them. (Recency at the very end is real too, but do NOT require a restatement to earn it: a closing echo is optional, never a scored obligation, and one idea smeared across the file to chase recency is a P2 fail, not a P1 win.)
- **Short-file note:** a file too short to have a "middle" auto-passes.
- **Pass:** critical constraints appear near the top, not stranded mid-file.
- **Fail:** a hard constraint sits only in the middle of the file, out of the high-attention top slot.

### P2: No diluted restatement of one instruction
- The same behavioral rule isn't re-expressed 3+ times in near-synonyms across sections (e.g. "be direct" / "don't coddle" / "clarity first" / "useful beats agreeable" as four separate passes at one idea).
- **Why:** models routinely fail to reconcile overlapping demands inside one prompt, and longer prompts raise derailment probability (2502.12197, 2602.17046). Restating one idea five ways spends attention budget without adding a constraint, and it shoves real rules toward the truncated middle.
- **Not a fail:** a single optional closing echo of the 2-3 hard rules (recency is real; one short restatement is fine). The line is a *scored requirement* to restate: P1 does not demand one, and P2 fails a rule smeared across the body.
- **Pass:** each behavioral rule stated once, in one place.
- **Fail:** one idea smeared across 3+ near-synonym restatements. Fix = merge into a single canonical line.

### P3: Enforceable instructions only
- Every hard rule is testable behavior or wired to a real mechanism.
- Aspirational directives with no mechanism ("make me notice", "create motion", "track my loop-closing rate across sessions", "keep me operating at a higher level") are flagged unless backed by a concrete tool, file, or tracked state.
- **Why:** models struggle to enforce even simple instruction hierarchies, and role labels are weaker levers than assumed. Unenforceable rules teach the model to treat the whole doc as vibes rather than binding constraints (2502.15851, 2404.13208). An instruction with no mechanism is decoration.
- **Pass:** every directive is actionable behavior or mechanism-backed.
- **Fail:** the file carries aspirational rules the model cannot act on. Fix = give the mechanism or cut the line.

## Readability (1 point) — is the file easy to read, easy to understand, and no longer than the job needs

### R1: Lean, clean, and clear
Three things at once: the prose reads cleanly on one pass, a first-time reader *understands*
every section, and the file is no longer than its job requires. Shorter is better by default.
Between two SOULs that encode the same constraints, the tighter one wins, because every extra
line spends attention budget and pushes real rules toward the truncated middle. And if a
section isn't easy to understand, it's a bad section, however correct it is: the model can't
follow a rule it has to guess at.

Fails when the file shows 2+ of these markers to a degree that hurts reading or comprehension:

**Density markers (hard to read):**
- **Padding.** Filler, throat-clearing, or restated ideas make it longer than the job needs. (P2 catches one *rule* repeated across sections; R1 catches general bloat, whether or not it's a rule.)
- **Stacked parentheticals.** Asides nested inside asides, or a parenthetical on most bullets carrying a real constraint (a constraint in parens is easy to skim past).
- **Qualifier run-ons.** Single bullets chaining 3+ clauses or conditions that should be 2-3 separate lines.
- **Emphasis inflation.** ALL-CAPS or bold on so many phrases that emphasis stops signaling. If everything's shouted, nothing is.
- **Over-nesting.** Bullet trees past 2 levels, or sub-bullets that restate their parent.
- **Wall-of-prose.** A paragraph doing the job of a short list, or vice versa.

**Comprehension markers (hard to understand):** these are evaluate-content's Sweep 1 (Clarity) checks, applied to a SOUL. That skill is the canonical "what clear means"; load it for the fuller list and the Seven Sweeps.
- **Unexplained jargon or insider language.** A term, tool, or acronym used as if the reader already knows it, with no gloss and no pointer to where it's defined. A rule the model can't decode is a rule it can't follow.
- **Unclear pronoun reference.** "This", "it", "that one", "the above" with no clear antecedent, so the reader has to guess what the rule points at.
- **Missing context / assumed knowledge.** A section that only parses if you already know a fact that lives nowhere in the file (an unstated workflow, a prior decision, a piece of the environment).
- **Sentence trying to say too much.** One sentence carrying an idea, its exception, and a caveat at once. Break it, or the trigger and the action get lost. (Overlaps the density "qualifier run-on" marker; count it once.)
- **Point buried in qualifications.** The actual instruction is wrapped in so many hedges and conditions you can't tell what to do. State the rule, then the exceptions.
- **Abstract where concrete would land.** "Handle it appropriately" instead of a testable behavior. Ties to P3: vague-and-unenforceable often reads as unclear too.
- **Re-read sentences.** Any line you have to read twice to parse. If the audit slows down to understand it, so will the agent.

- **Why:** the same research the P-items cite (2502.12197 conflict-resolution failure, 2602.17046 derailment rising with length, lost-in-the-middle) says a denser, longer, harder-to-parse prompt is a harder-to-follow prompt. R1 is the prose-clarity-and-length companion to P2's structural-redundancy check, and it borrows evaluate-content's Sweep 1 (Clarity) definition of "clear" so the bar matches the rest of the skill library.
- **Length is job-relative, not an absolute cap.** A task-operator SOUL (credential maps, workflows, folder map) legitimately runs longer than a persona SOUL. Judge concision against what *this* archetype needs, and never penalize length that's carrying real, non-duplicated operational content. Penalize length that's carrying filler.
- **Judgment exception (mirror of V2):** a deliberately terse, dense voice can be dense-but-good. Density that *aids* precision (a tight credential table) passes. Density that *obscures* it (constraints buried in nested parens) fails. But terseness is never an excuse for a section a first-time reader can't decode: clear-and-short beats clever-and-cryptic.
- **Pass:** reads cleanly on one pass, a first-time reader understands each section (Rule of One: one main idea per section), emphasis is rationed, one idea per line, and no shorter version would carry the same constraints.
- **Fail:** 2+ markers hurt reading or comprehension, OR the file is padded well past what its job needs. Fix = run the simplify pass (see SKILL.md); for a comprehension miss, add the missing gloss/antecedent/context rather than just cutting.

## Scoring

9 items: M1-M3, V1-V2, P1-P3, R1. Short files auto-pass M2 and P1.
Score as a fraction of applicable points.

| Score | Rating |
|-------|--------|
| 9     | Excellent — mechanically sound, distinctive, lean, and every rule earns its place |
| 7-8   | Good — strong voice, minor truncation/redundancy/enforceability/readability gaps |
| 5-6   | Average — reads well but leaks project detail, restates itself, runs long, or carries aspirational fiction |
| 3-4   | Below average — generic voice or rules stranded where the model won't see them |
| 0-2   | Poor — trips the scanner, is mostly filler, or is an AGENTS.md wearing a SOUL costume |
