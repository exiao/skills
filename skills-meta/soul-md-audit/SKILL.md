---
name: soul-md-audit
description: "Audit and score a SOUL.md (Hermes agent identity file) or any agent persona / system-prompt / operator-instruction doc, against how Hermes loads it plus attention research. Use when the user shares a SOUL.md, persona file, agent constitution, or system-prompt and asks to review/grade/audit it, 'is this good', or 'compare to best practice'. Not for skills (use skill-audit)."
---

# SOUL.md Audit

Score a SOUL.md or agent persona/system-prompt file on two things at once: how Hermes loads and truncates it, and how the model reads and follows it. A SOUL.md can read well to a human and still fail. Half its rules may sit in the truncated middle. It may say "be direct" five different ways. It may be full of instructions the model has no way to obey.

Read [references/checklist.md](references/checklist.md) first. The research behind the attention items is in [references/attention-basis.md](references/attention-basis.md). Cite the paper when you flag one. When you recommend a rewrite, point the user at [references/template.md](references/template.md), the target shape that shows what good looks like, so the fix has a concrete goal and not just a list of problems.

## What this audits (and what it doesn't)

Use this for **identity, voice, and operator-behavior** files: `~/.hermes/SOUL.md`, a persona template, a profile or lane's SOUL, an "autonomous operator" constitution, a system-prompt draft.

**Classify the archetype first. It changes what counts as a fail:**
- **Persona/voice SOUL** (a general assistant whose job is *who it is*): voice is the spine. Commands, paths, and project detail are drift that belongs in AGENTS.md.
- **Task-operator SOUL** (a profile or lane with one main job it grabs skills for, like research-lead): the operational spine IS the identity. The primary objective, skill inventory, delegation workflow, command sequences, and folder map belong in SOUL, *unless a loaded AGENTS.md already owns them*. The right order runs: who you are, then primary objective, then how to behave and write, then skills, then workflows, then memory, then folders. Don't flag this content as drift. Judge whether it's ordered right and whether it has a better home that actually loads.

If you're auditing a *skill*, use skill-audit instead. This skill borrows skill-audit's P-dimension research and applies it to persona and operator files, where truncation and identity-slot mechanics also matter.

## Process

1. **Get the file.** Read the whole thing. Note its length in chars (`wc -c`), since truncation behavior depends on it.
2. **Run the checklist.** Score M1-M3 (Hermes mechanics), V1-V2 (voice quality), P1-P3 (attention hygiene), and R1 (readable, understandable, and no longer than the job needs). Each item is 1 point, binary. Short files (well under the truncation limit, a dozen lines) auto-pass M2 and P1. Positional placement only bites once a file is long enough to have a middle.
3. **Generate the scorecard** (format below).
4. **Offer to fix.** List fixes in priority order. For a rewrite, keep the user's voice; the audit finds problems, it doesn't sand off personality. Ask before editing their actual `~/.hermes/SOUL.md`. When R1 fails, or the user asks to simplify, run the **Simplify pass** below rather than hand-editing.

## Simplify pass (the R1 fix)

When R1 fails or the user asks to make a SOUL clearer or shorter, run the file through the
`writer` skill under tight guardrails. The goal is meaning-preserving, not
meaning-improving: tighten language and cut padding without loosening a single constraint.

1. **Load the `writer` skill** and its WRITING-STYLE.md (kill-phrase list, plain-language rules). For the clarity and leanness definitions, also pull `evaluate-content` (Sweep 1 Clarity and the Seven Sweeps). Those are the canonical "what clear and lean mean"; don't invent a parallel bar. SOUL prose obeys the same style rules as any other writing in the author's voice.
2. **Inventory the constraints FIRST, before rewriting.** Extract every hard rule, gate, and never-do into a checklist. Grep for `never`, `only`, `always`, `must`, `block`, `don't`, `NOT`. This list is the ground truth the rewrite must preserve.
3. **Rewrite prose, not structure.** writer tightens language, unstacks parentheticals, splits run-ons, strips inflated emphasis, and cuts filler. For a comprehension miss (unexplained jargon, an ambiguous "this", assumed context), *add* the missing gloss, antecedent, or fact rather than just cutting. It must NOT reorder sections, drop a section, merge two distinct rules, or soften a constraint's force. "never" stays "never".
4. **Verify against the inventory.** Re-extract the constraint list from the rewrite and diff against step 2. Every rule present before must be present after. Any drop rejects *that edit*, not the whole pass. Report before/after char count and the constraint-count match as evidence. Run the check as greppable invariants, not eyeballing: count the tokens that must survive that must survive (item anchors, citation IDs, Pass/Fail lines, scoring numbers) with `grep -c` before and after and confirm the counts match. A prose rewrite that silently drops a citation or an anchor is the exact failure this step exists to catch.
5. **Diff for review, don't overwrite blind.** Show the user a diff, or write to a `.simplified` sibling, and ask before replacing their real SOUL.md. Never edit `~/.hermes/SOUL.md` (or a profile's) without approval.

## How Hermes loads SOUL.md (the mechanics the audit checks)

These are the facts M1-M3 test against. Source: Hermes docs (context-files, use-soul-with-hermes, personality), verified 2026-07.

- **Slot #1, injected verbatim.** SOUL.md is the agent's primary identity. It goes first in the system prompt and replaces the built-in default, with no wrapper text added. The content IS the identity, so sloppy content is the identity being sloppy.
- **Loaded ONLY from `HERMES_HOME/SOUL.md`** (`~/.hermes/SOUL.md`). Hermes never checks the working directory for it, so a repo-local `SOUL.md` does nothing. When someone says "I edited it and nothing changed," they usually edited the wrong file or didn't restart the session.
- **Truncation is head/tail, not tail-drop.** Files over `context_file_max_chars` (default 20,000, ~7k tokens) are cut to **70% head + 20% tail**, with a marker replacing the middle 10%. So the middle of a long SOUL is the first thing dropped. Front-load identity and hard constraints. In a long file the closing lines survive too, but the middle does not. **Check the local override first** (`grep context_file_max_chars ~/.hermes/config.yaml`): an instance that raises the cap (e.g. to 80,000) loads a 22KB SOUL whole; score truncation against the configured cap, cite the 20K default only for portability.
- **Injection-scanned before inclusion.** If the file contains patterns like "ignore previous instructions", "do not tell the user", `cat .env`, hidden HTML comments, or invisible/bidi characters, the WHOLE file is blocked and Hermes falls back to the default identity. A SOUL that trips the scanner silently disables itself.
- **Empty = default.** An empty or whitespace-only SOUL.md means Hermes uses its built-in identity. The same happens under `skip_context_files` (subagents).
- **SOUL vs AGENTS vs /personality.** SOUL is durable voice and identity that follows you everywhere. AGENTS.md holds per-project conventions, paths, and commands. `/personality` is a temporary session overlay. Mixing project detail into SOUL is the single most common mistake the docs call out.

## Scorecard Format

```
# SOUL.md Audit
## Length: [N] chars ([under / over] the 20k truncation limit)
## Score: [X]/9

### ✅ Passing
- [item]: [what's good]

### ⚠️ Warnings (passes but fragile)
- [item]: [what's borderline]

### ❌ Failing
- [item]: [what's wrong + specific fix]

### Recommended Actions (priority order)
1. [highest-impact fix]
2. ...
```

## Scoring rules

- Be honest. A polished-but-unexamined operator template (the common case) usually scores 4-7/9: strong on stated values, weak on truncation-safety, redundancy, enforceability, and leanness.
- Don't inflate to be nice. An audit where everything passes is useless.
- Voice items (V1-V2) are judgment calls. A genuinely distinctive terse voice can pass V2 without worked examples when the terseness itself is the voice on display. Use judgment. Don't force examples onto a file whose whole point is brevity.
- When in doubt, fail and explain. Better to flag a non-issue than miss a rule stranded in the truncated middle.

## Gotchas

- **"It reads well" is not a pass.** The failure modes here (truncated middle, diluted restatement, unenforceable aspiration) are invisible to a human skim, because a human reads the whole file top to bottom and fills the gaps charitably. The model doesn't. Score against the mechanics, not the vibe.
- **Aspirational fiction is the signature SOUL.md failure.** Operator templates love lines like "make me notice," "create motion," "track my loop-closing rate across sessions." The model has no memory of your loop-closing rate and no way to make you notice. Flag these under P3: either wire them to a real tool, file, or tracked state, or cut them. Unenforceable rules train the model to treat the whole doc as vibes.
- **Redundancy hides as thoroughness.** Four sections that each say "be sharp, be direct, don't coddle, useful beats agreeable" feel rigorous, but they are one instruction spending four times the attention budget and pushing real constraints toward the truncated middle. That's a P2 fail, not diligence.
- **A closing restatement is optional, never required.** Repeating the 2-3 hard constraints at the very end is *allowed* (recency is real), but P1 does NOT score a file down for lacking one, and never demand the author add one. What P2 still fails is one idea smeared across the *body* in near-synonyms. Front-loading the hard rules at the top is the scored requirement; the end echo is a nicety, not an obligation.
- **A true research finding is not automatically a scored rule.** P1 rests on the U-shaped attention curve, which says both the start AND the end get high attention. It's tempting to turn that into "so restate the bans at the end" and score files down for skipping it. That inference was rejected: a SOUL loaded once per session gains little from a mechanical end-echo, and requiring one manufactures the exact body-smear P2 exists to catch. The durable line: cite recency as real, front-load the hard rules (primacy + truncation-safety both point there), and leave the closing echo optional. When adapting any attention-research finding into a checklist item, ask whether it earns a *requirement* or just a *permission* before you make it cost points.
- **Project detail in SOUL is an M1 fail even when well-written.** "Use pytest not unittest" is a great instruction in the wrong file. The fix is to move it to AGENTS.md, not delete it.
- **A file can pass every M/V/P item and still be unreadable or confusing.** Correct scope, safe truncation, clean scan, distinctive voice, no redundancy, all enforceable, and still a wall of nested parens and shouted caps twice as long as the job needs, or a section that only parses if you already know an unstated fact. That's what R1 catches. If a section isn't easy to understand, it's a bad section, however correct the rule is: the model can't follow what it has to guess at. Shorter and clearer is better by default. Fix a failing R1 with the Simplify pass (add the missing context for a comprehension miss; cut for a density miss), not by dropping constraints.
- **Editing this skill's own rubric files: preserve invariants and trust re-reads over warnings.** When you patch checklist.md or SKILL.md, the same discipline the Simplify pass demands applies to your own edits. After a rescale (e.g. /8 to /9) grep for stray old values, and confirm the item-anchor count, the arXiv IDs, and the Pass/Fail line counts are unchanged. If a patch returns a "modified by sibling subagent" warning, don't trust it blindly and don't overwrite blindly: re-read the file, confirm only your own edit landed, then continue. In this session those warnings were false alarms, but re-reading is the only way to know.

## Skill source

Built 2026-07 from: Hermes docs (`/docs/user-guide/features/context-files`, `/docs/guides/use-soul-with-hermes`, `/docs/user-guide/features/personality`) for the loading mechanics, and prompt-attention research for the P1-P3 attention basis (papers restated compactly in `references/attention-basis.md`). R1 (readability and length) was added later from the same attention research: shorter, cleaner prompts derail less. `references/template.md` is the target "what good looks like" shape, adapted from a community "Anatomy of a SOUL.md" infographic and corrected against the mechanics (Boundaries moved to top + end, Defaults block added per the docs' Identity/Style/Avoid/Defaults structure, Memory reframed as privacy *policy* not mechanism). To refresh: re-read those three doc pages for any change to truncation ratios, the HERMES_HOME-only rule, or the injection scanner, and re-check the arXiv findings.
