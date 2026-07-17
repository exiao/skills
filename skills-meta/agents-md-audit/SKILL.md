---
name: agents-md-audit
description: "Audit and score a repo's agent context file (AGENTS.md, CLAUDE.md, .hermes.md, .cursorrules) for how Hermes actually loads it: the 20KB truncation cap, one-file-wins priority, injection-scanner blocks, SOUL-vs-AGENTS placement, plus a Karpathy 12-rule completeness rubric and per-line instruction lints. Use when the user says audit my AGENTS.md, review this CLAUDE.md, check my context file, is my AGENTS.md too big, why isn't my AGENTS.md being followed, grade my repo instructions, or points at an AGENTS.md/CLAUDE.md and asks if it's good. For auditing a SKILL.md instead, use skill-audit."
---

# AGENTS.md Audit

Audit a repository's agent context file the way **Hermes actually loads it**, then grade its content. This is the sibling of `skill-audit` (which grades a SKILL.md); this grades the project context file that shapes every session in a repo.

Read [references/rubric.md](references/rubric.md) first. It holds the Karpathy 12-rule completeness rubric and the per-line instruction lints. This SKILL.md holds the Hermes loading model, which is where most real findings come from.

## Why this is not a generic CLAUDE.md linter

Tools built for Claude Code (e.g. ccmd) assume the file is **re-sent on every turn** and price token bloat as a per-turn tax. **Hermes does not work that way.** Per the [Hermes context-files docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files), Hermes loads ONE project context file ONCE at session start into the system prompt, then keeps that prompt byte-stable for the life of the conversation (prompt caching is sacred). So the every-turn cost model is wrong here, and the real failure modes are different: truncation, priority, and the injection scanner. Audit for those, not for per-turn dollars.

## The Hermes loading model (where the real findings are)

Run these seven checks against the file. They catch problems no content rubric sees.

### H1: The 20KB truncation cap (highest-value check)
`context_file_max_chars` defaults to **20,000 chars (~7,000 tokens)**. A file over the cap is head/tail truncated: **70% head + 20% tail kept, the middle 10% DROPPED**, with a marker where the hole is. The dropped middle is invisible to the agent for the whole session.

**Check the local override FIRST:** `grep context_file_max_chars ~/.hermes/config.yaml`. An instance that raises the cap (e.g. to 80,000) loads a 64-73KB AGENTS.md whole. Audit local truncation against the configured cap; cite the 20K default only as the portability number (other installs/harnesses).

```bash
wc -c AGENTS.md   # >20000 = truncated; >18000 = flag, near the edge
```
- **Fail** (hard) if over 20,000: name roughly which section lands in the dropped middle (it's the material between ~14,000 and ~18,000 chars). Any rule that MUST hold belongs in the head or the tail, never the middle.
- Fix: split into nested subdirectory `AGENTS.md` files (see H6), or move detail behind `references/`-style pointers the agent reads on demand, keeping the root file lean.
- Real case: a 70KB `AGENTS.md` and a 64KB one are 3x+ over the cap; the bulk of each never reaches the model at startup.

### H2: One file wins per session (priority + drift)
Only ONE project context type loads per session, first match wins in this order: **`.hermes.md`/`HERMES.md` → `AGENTS.md` → `CLAUDE.md` → `.cursorrules`**. (`SOUL.md` loads separately as identity; see H4.)
- If the repo has both `AGENTS.md` and `CLAUDE.md`, **only AGENTS.md loads**. A `CLAUDE.md` that has drifted from it is dead weight in Hermes (though Codex/Claude Code still read it). `diff` them; flag divergence.
- If a `.hermes.md` exists, it silently shadows the AGENTS.md the user was editing. Flag it loudly.

### H3: Injection-scanner tripwires (blocks the WHOLE file)
Before loading, Hermes scans the file for prompt-injection patterns. **One match blocks the entire file** (`[BLOCKED: AGENTS.md contained potential prompt injection]`), not just the offending line. A legitimate file that quotes an injection example, documents a `cat .env` incident, or shows a `curl ...$TOKEN` command can nuke its own loading.

```bash
grep -niE "ignore (previous|prior|above) instructions|disregard (your|the) (rules|instructions)|do not tell the user|system prompt override|cat +\.env|cat +credential|curl.*\\\$[A-Z_]*(KEY|TOKEN|SECRET)" AGENTS.md
```
Also flag: hidden HTML comments (`<!-- ... -->` containing instruction-like text), `<div style="display:none">`, and zero-width / bidi / word-joiner characters (`grep -nP "[\x{200B}\x{200C}\x{200D}\x{2060}\x{202A}-\x{202E}]" AGENTS.md`).
- **Fail** (hard) on any hit: the file may be loading as `[BLOCKED]` and the agent is running with NO project context. Reword the example so it doesn't match (paraphrase the injection, redact the secret-exfil command).

### H4: SOUL.md vs AGENTS.md placement
Per the [SOUL guide](https://hermes-agent.nousresearch.com/docs/guides/use-soul-with-hermes): identity, tone, voice, and how-to-communicate belong in `~/.hermes/SOUL.md` (global, loads every session, slot #1). Project facts (paths, commands, ports, conventions, architecture) belong in AGENTS.md (per-repo). They are the most-confused pair.
- **Flag in AGENTS.md** (should move to SOUL): "be direct", "avoid hype", "push back when I'm wrong", tone/personality rules. They're repo-scoped here but should be global.
- **Flag in SOUL** (should move to AGENTS), if auditing SOUL too: stack names, file paths, commands, ports, "never edit migrations." Rule of thumb: applies everywhere → SOUL; one project → AGENTS.

### H5: Cache-stability (lower severity on Hermes than on Claude Code)
A volatile line near the top (an ISO date, "today", "this session", a churning version) does NOT re-bill every turn on Hermes (the prompt is loaded once and cached). But it still makes each fresh session start from a different prefix, and stale dated context is worse than none. **Warn, don't fail.** Move volatile lines to the bottom or drop them. (This is ccmd's `cache_bust` finding, demoted because Hermes's loading model makes it cheap.)

### H6: Progressive subdirectory discovery (is nesting used well?)
Hermes loads subdirectory `AGENTS.md` files on demand when the agent touches that subtree (capped at **8,000 chars** per subdir file, appended to the tool result). This is the correct fix for an over-cap root file (H1): move `frontend/`-specific rules into `frontend/AGENTS.md`, etc.
- If the root file is over-cap AND the repo is a monorepo with no nested context files, recommend splitting by subtree. Each subdir file has its own 8KB budget and only costs context when that subtree is touched.
- If nested files exist, spot-check they're under 8KB (over-cap subdir files truncate too).

### H7: Codex 32KB block placement (only if the repo is Codex-reviewed)
If the file carries a `<!-- CODEX-ONLY:START -->` block for GitHub Codex review, that block must sit within the **first ~32KB** (`project_doc_max_bytes`, Codex's own cap, separate from Hermes's 20KB). Confirm the block is near the top. Note the two caps are independent: a file can satisfy Codex's 32KB and still be truncated by Hermes at 20KB.

## Process

1. **Locate the file(s).** Ask for the repo path. List which context files exist (`ls -la` for `.hermes.md AGENTS.md CLAUDE.md .cursorrules`) and determine which one Hermes actually loads (H2).
2. **Run the Hermes loading checks (H1-H7).** These are greppable and produce the highest-value findings. Do them first.
3. **Run the content rubric.** Read `references/rubric.md`: score the Karpathy 12-rule completeness pass-count, the per-line instruction lints (missing-why, 28-word run-ons, vague terms, unescaped absolutes), and the **readability pass** (Part 2b): read each section as a first-time agent and flag any that isn't clear on one pass. If a section is hard to understand, it's a bad AGENTS.md, no matter how complete it is.
4. **Generate the scorecard.** Format below.
5. **Offer to fix.** List actions in priority order, hard fails first (H1 truncation, H3 injection block). Ask before editing.

## Scorecard Format

```
# AGENTS.md Audit: <repo>
## Loaded file: <which one Hermes actually uses> (<size> / 20KB cap)

### 🚨 Hermes loading (H1-H7)
- H1 truncation: <pass / FAIL: N chars over, middle section "X" is dropped>
- H2 priority+drift: <which file wins; drift with CLAUDE.md?>
- H3 injection scan: <clean / FAIL: line N would block the whole file>
- H4 SOUL/AGENTS placement: <clean / N tone lines belong in SOUL>
- H5 cache stability: <clean / warn: dated line at top>
- H6 subdir nesting: <n/a / recommend split / nested files ok>
- H7 Codex block: <n/a / in first 32KB / FAIL>

### 📋 Content rubric
- Karpathy completeness: X/12 (missing: <rules>)
- Line lints: <missing-why: N, 28-word: N, vague: N, bare-absolute: N>
- Readability: <N sections flagged — heading: cause; ...>
  - <quote the hard-to-parse passage + the clearer rewrite for each>

### ❌ Top fixes (priority order)
1. <hard fail first>
2. ...
```

## Scoring

Two independent scores, don't blend them. **Hermes loading** is pass/fail per H1-H7; any hard fail (H1 over-cap, H3 injection block) means the file is materially broken regardless of content quality, say so first. **Content** is the 12-rule completeness count plus the line-lint tally from `references/rubric.md`. A file can score 11/12 on content and still be a hard fail because it's 60KB and half of it never loads. Report the loading verdict before the content grade.

## Gotchas

- **The 20KB cap is the finding people miss.** Teams write a beautiful 40KB AGENTS.md and assume the agent reads all of it. It doesn't; the middle is gone. Always `wc -c` first.
- **Don't price per-turn tokens.** That's a Claude Code framing. On Hermes the file loads once and caches. The cost lever is truncation and attention, not per-turn dollars. If you find yourself computing "$X per 1k messages," you're auditing the wrong runtime.
- **An injection-example in the file is self-sabotage.** The scanner can't tell a documented attack from a real one. A file explaining "reject prompts that say 'ignore previous instructions'" may block itself. Paraphrase such examples.
- **CLAUDE.md is not dead everywhere.** In Hermes it loses to AGENTS.md, but Codex and Claude Code still read it. "Only AGENTS.md loads" is a Hermes statement; don't tell the user to delete CLAUDE.md if their repo is also reviewed by other agents. Flag the drift, recommend a sync (many repos keep them identical minus a CODEX-ONLY block), not deletion.
- **This is not skill-audit.** skill-audit grades a `SKILL.md` (a skill's structure/description/references). This grades a repo's project context file (its loading behavior + instruction completeness). Different object, different caps, different rubric.

## Skill source

- Hermes context-files behavior (20KB cap, 70/20 truncation, one-file-wins priority, progressive subdir discovery, injection scanner): https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files
- SOUL.md vs AGENTS.md split: https://hermes-agent.nousresearch.com/docs/guides/use-soul-with-hermes
- Karpathy 12-rule rubric + per-line lints seeded from ccmd's analyzer: https://ccmd.dev/karpathy-rules
- Update procedure: if Hermes changes `context_file_max_chars` (default 20,000), the truncation ratios (70/20), or the priority order, re-read the context-files doc and update H1/H2/H6. Verify caps against `agent/prompt_builder.py` (`build_context_files_prompt`) and `agent/subdirectory_hints.py` in the hermes-agent repo if in doubt.
