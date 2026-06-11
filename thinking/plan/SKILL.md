---
name: plan
preloaded: true
description: Plan-only mode — inspect context and write a markdown plan into `~/.hermes/plans/` when the user wants planning instead of execution. Use when the user says "plan this", "make a plan", "/plan", "don't implement yet", or "investigate and make a plan". If the user asks to plan and then implement, save the plan first, present it for approval, then continue.
---

# Plan Mode

Use this skill when the user wants a plan instead of execution.

## Core behavior

Use planning-only behavior only when the user asks for a plan instead of execution (for example `/plan`, "make a plan", "don't implement yet"). If the user asks to "investigate and make a plan, then do it" or otherwise requests both planning and execution, save a concise plan first, then continue into implementation under the normal coding workflow.

### Pitfall: "Make a plan, then implement"

When the user says "make a plan for X, then implement" (or "plan, implement, PR"), treat these as **sequential gated steps**, not a single continuous action. Write the plan, **present it in your reply as a readable summary**, and STOP. Wait for their approval before implementing. The user wants to review and possibly adjust the plan before you start coding. Jumping straight from planning into implementation without pausing defeats the purpose of planning. The only exception is if the user explicitly says "don't wait for approval" or "just do it all."

### Pitfall: Silent plan files

Writing a plan to `~/.hermes/plans/` and then immediately starting implementation is the same as not planning. The plan must appear in your reply text so the user can read, adjust, and approve it. A plan file that only you read is not a plan, it's a private note.

For planning-only turns:

- Do not implement code.
- Do not edit project files except the plan markdown file.
- Do not run mutating terminal commands, commit, push, or perform third-party actions.
- You may inspect the repo or other context with read-only commands/tools when needed.
- Your deliverable is a markdown plan saved under `~/.hermes/plans/`.

## Output requirements

Write a markdown plan that is concrete and actionable.

Include, when relevant:
- Goal
- Current context / assumptions
- Proposed approach
- Step-by-step plan
- Files likely to change
- Tests / validation
- Risks, tradeoffs, and open questions

If the task is code-related, include exact file paths, likely test targets, and verification steps.

### Architecture plans: ASCII diagram first

When the plan involves infrastructure, system architecture, or data flow changes (DB migrations, new compute layers, service splits), lead with an ASCII diagram showing current state vs target state before the prose plan. Many users explicitly prefer this ("map out the architecture in ASCII first"). The diagram should show components, data stores, connections, and what moves where. Keep it compact (under 30 lines per state). The prose plan follows the diagram.

## Agent architecture plans

When planning an agent system (multi-phase pipeline, long-running agent, research agent, etc.), load `references/anthropic-harness-patterns.md` first. It contains condensed patterns from Anthropic's harness design articles: session/harness/sandbox separation, generator/evaluator pattern, lens isolation, inter-session state management, and framework selection criteria.

When simplifying a pipeline (removing opinion layers, reducing scope), use this heuristic: if two lenses/agents can't meaningfully contradict each other, merge them — but don't over-merge (more than ~100 lines of framework per agent tends to degrade quality).

When planning a pipeline that produces sourced/factual output, remember that checking "does the report match the raw file" is insufficient. Web-scraped raw files can contain wrong or misattributed data. The pipeline must verify claims against their *actual* cited sources and chase provenance chains for web-sourced data.

After drafting any architecture plan, stress-test it for these failure modes: context-window overload, test-suite coupling, backward-compat gaps, gather/scope bloat, and opinion leakage between layers.

### Mega-file split / behavior-preserving refactor plans

When asked to investigate large files and make a split plan:

1. Inspect the actual repo, not just memory: current branch, working tree status, AGENTS/CLAUDE instructions, tracked file sizes/line counts, duplicate generated artifacts, and AST-level function/class sizes for the worst files.
2. Separate code problems from expected artifacts: lockfiles, generated `200.html`/`index.html` deploy copies, fixtures, and archived outputs may be large but should not drive the first refactor.
3. Prioritize behavior-preserving seams over conceptual purity. For FastAPI apps, extract `APIRouter` modules while preserving route registration order and `server:app` compatibility. For pipeline scripts, extract phase modules behind a thin facade. For public modules with many imports, keep old-function reexports until tests migrate.
4. Plan stacked PRs, not a big-bang split. First split the clearest seam, then pipeline/core modules, then tests/static cleanup.
5. Include validation commands after each extraction stage so failures are attributable.

## Pitfall: Distributing third-party learnings into a skill library

When the plan involves incorporating tips/frameworks from third-party sources (tweets, articles) into existing skills:

1. **Decompose first.** Break the source into atomic tips before deciding placement.
2. **Audit the full skill landscape.** Use `skills_list` + `SkillView` on every candidate skill. Look at existing sections, principles, and gaps. Don't guess from memory.
3. **Map each tip to its owner.** Create a tip-to-skill mapping table. Strategy tips go to strategy skills, creative tips to creative skills, operational tips to operational skills. Don't dump everything into one skill.
4. **Keep operational skills operational.** CLI/API wrapper skills should not accumulate strategy, targeting philosophy, or creative guidelines. Those belong in the strategy skill for that domain.
5. **Prefer expanding existing sections** (5-15 lines) over creating new standalone skills. Create new only when no existing skill covers the class.
6. **Source-attribute everything.** Include `(Source: @handle, Month YYYY)` so future sessions can assess staleness.
7. **If the source is a video post, watch the video — don't work off the tweet/thread text alone.** Video posts often contain proof, examples, or numbers absent from the written thread. Download with `yt-dlp -f mp4`, extract frames with ffmpeg at intervals, and inspect with vision per-frame (montage grids get truncated; single key frames read more reliably). Cheap one-shot video-inspection tools frequently hallucinate a generic answer for slideshow/tutorial videos — distrust them and verify against frames. The video sometimes shows a *different* example than the written post claims, so the proof can exist only in the footage.
8. **Same failure mode for dense static images (infographics, charts, screenshots with many labels).** Vision tools default to describing the *art style* and ignore the request to transcribe labels — returning paragraphs about aesthetics instead of the data you asked for, even when re-prompted. Fixes that work: (a) demand a rigid output contract — "Output ONLY a markdown table, no intro sentence, row per item, start immediately with the data"; (b) tell it explicitly "do NOT describe the art style"; (c) chunk the transcription — ask for one region/layer at a time because one call routinely truncates a long list mid-item; (d) for yes/no coverage gaps, ask a closed question per item. Budget 4-6 calls for a dense infographic, not 1.
9. **Before executing a planned skill update, check whether a prior session already did it (partially or fully).** Skill-update plans drafted in one session may sit unexecuted until a later "execute all" turn — and another session may have already done the work in between. Symptom: you patch an `old_string` from your plan and it doesn't match, because the file already says what you intended to write. When that happens, STOP patching blindly and reconcile: run `git status --short <skill-dir>` and `git log --oneline` to see uncommitted/recent skill changes, read the current state of every target file, and look for prior-session artifacts (new reference files you planned to create that already exist, half-applied edits). Then do ONLY the residual work — often a prior session created the new reference files and wired SKILL.md but left *stale inline numbers* in the older reference files uncorrected. Verify with a diff before replying.
10. **Before editing skill files, confirm WHERE the target skills actually live and which copy the runtime loads.** A public skills repo and the runtime skills dir (`~/.hermes/skills`) can diverge: different category paths, different reference sets, and files present in one but missing in the other. Check `find <repo> -name SKILL.md -path "*<skill>*"` in both, compare line counts, and confirm the reference files you plan to touch exist in the target. If they've drifted, surface the divergence and ask the user which copy should receive the change rather than editing blindly. Also: a `git remote -v` may print an embedded plaintext token in the URL; redact it in any reply and flag it for rotation.

## Pitfall: Spec-to-implementation gap analysis

When implementing features from a roadmap, spec, or design doc, always verify completeness against the spec BEFORE declaring the work done. Common pattern: subagents implement 80% of a spec correctly but miss UI components, CLI naming requirements, or "done when" criteria.

**Process:**
1. After implementation, delegate a comparison subagent with read-only access to both the spec and the diff.
2. Have it produce a structured MATCH / GAP / EXTRA table for each requirement.
3. Fix all GAPs before opening the PR, or document them as intentional scope cuts.

This catches: missing UI layers (spec says "UI" but only API was built), wrong naming (spec names one command but a different one was used), incomplete logging (spec says "store inputs, diff, scores" but only scores were stored), and missing automation (spec says "produce a PR" but the script just prints output).

**Don't self-certify.** The temptation after a large implementation is to skim the plan, pattern-match each item as "done," and move on. This produces false completions. Instead:
- Re-read the plan line by line. Every numbered item, every bullet.
- For each: verify with a concrete check (grep the diff, inspect the file, check the route). "I think I did this" is not verification.
- Be honest about gaps. Labeling something "nice to have" or "natural follow-up" when the plan explicitly called for it is reclassifying, not completing.
- If the user asks "did you check the plan?", you already failed. The check should have happened before you said "done."

**Subagent gap pattern (multi-part plans).** When a plan has numbered parts (e.g., "Part A" and "Part B"), subagents reliably implement the first part and drop subsequent parts. The fix: after all subagents complete, re-read every plan item and diff each PR against its section of the plan. Don't trust subagent summaries that say "done". Cross-branch integration points (module A in PR X calls module B in PR Y) are especially likely to be missed because no single subagent owns both sides.

### Docs/spec refresh planning

When the task is "what needs to be updated in AGENTS/CLAUDE/specs" or a docs/spec audit:

1. Run the repo's existing docs check, but treat a pass as a smoke test, not proof. Read the checker to see what it actually verifies. Many checkers only cover file parity or inventory, not spec freshness.
2. Compare current main against active/open branches, not just the checkout. Recent behavior may live on unmerged branches, and documenting it on main as current behavior creates a false contract.
3. Split the plan into two tracks: current-main hygiene (stale wording, shipped commands still described as future work) and branch-specific docs (new output fields, new source backends, new flags, consent/cost tradeoffs).
4. Do not put future-branch behavior into main docs unless it is explicitly labeled pending. Specs should describe the code on their base branch.
5. For AGENTS/CLAUDE duplicates, preserve the repo's parity rule exactly: shared text identical outside any tool-specific block, real files not symlinks, and checker updated if the source-backend inventory rule changes.
6. Validate brittle numbers from source. For test counts, collect with the repo command instead of trusting old docs. For model lists, report sections, phases, env flags, and queues, import or grep the defining code.
7. Look for semantic contradictions inside the same doc. A doc can correctly describe a new scheduler in one section and still say "not yet built" later.

## Multi-Repo / Open PR Branch Strategy

When planning work on a project with multiple repos and open PRs that represent big rewrites:

1. **Identify the latest state.** Open PRs may diverge from each other. Find which branch is "most advanced" (has the most recent architectural decisions). New work branches off THAT branch, not main.
2. **Check branch relationships.** Use `git log branchA..branchB` to see what's unique to each. Divergent branches that share a merge base need explicit merge-order recommendations in the plan.
3. **Map work to repos.** CLI/data changes go in the CLI repo; pipeline/skill changes go in the agent repo. Don't mix. This enables parallel execution.
4. **State the base branch explicitly** for every item in the plan. "Branch off `feature-x`" not "branch off the latest."
5. **Flag merge-order risks.** If a later PR rewrites what an earlier PR touched, recommend merge order in the plan. Cherry-picking specific commits from the superseded PR is often cleaner than rebasing.

### Competing PRs: Combine or Sequence

When two open PRs overlap or depend on each other (e.g., one adds infrastructure and the other refactors the same code), always present the tradeoff clearly:

- **Sequence** (merge A then B): simpler, lower risk, but B may need painful rebasing onto A's changes.
- **Combine** (new PR taking the best of both): cleaner result, but more upfront work. Prefer this when: (a) neither PR is merge-ready, (b) one PR caused multiple rounds of bug fixes indicating the approach was wrong, (c) the user explicitly wants minimal total lines.

When combining: audit both PRs for what to keep (capability) vs discard (implementation approach). The new PR should cherry-pick capabilities, not code. Branch from main, not from either PR branch.

## Pitfall: Planning new builds before grepping for existing infrastructure

Before a plan proposes new fields, new modules, new ingestion, or new compute, grep the actual codebase for infrastructure that already does part of the job. Apparent scope routinely collapses once you check. The plan's first job is a reuse audit, not a build list. Real failure modes:

1. **A canonical helper already exists, just not wired into this path.** A "messy categories" bug (several variants of the same value as separate rows) often has its fix already sitting in a `normalize_*` helper + a display-name map that the aggregation path simply never calls. The plan becomes "wire in the existing normalizer," not "design a new taxonomy."

2. **A field the user wants as "new" already exists on the model.** A requested axis may already be a field with full CHOICES defined. That slice is a read, not an ingest + migration.

3. **A value is already fetched upstream but silently dropped.** A needed field may already be pulled from an upstream API but never assigned to the model or persisted. The work is "persist what's already fetched + backfill," not "build ingestion from scratch."

Process: for every noun in the request (a field, a category, a metric), run a grep sweep first:
- `grep "def normalize" / "DISPLAY_NAMES" / "<noun>_CHOICES"` for existing maps/enums.
- `grep "\.<field>\s*=" / "<field>=" / '"<field>"'` for where it's written vs merely read.
- Read the ingestion/compute path end to end and note values that are fetched-then-discarded.

Then the plan separates "wire/persist existing" (cheap, low-risk, ship first) from "genuinely new" (schema + backfill, ship last). If the feature ALREADY EXISTS, stop and report it in the plan instead of silently rebuilding it. Trace the actual aggregation/write path to name the root cause (e.g. "buckets on raw unnormalized text") rather than guessing ("sparse data").

## Schema simplification plans

When planning a database schema simplification (table consolidation, column audit, ORM migration):

1. **Audit every table for actual usage.** For each table: grep writes, grep reads, count references. Tables referenced only in tests or never queried are candidates for deletion.
2. **Audit every column for actual writes.** A column in the schema that's never written by any INSERT is always NULL. Kill it. A column that's written but never read is also a kill candidate (or rename it to be useful).
3. **Present the schema interactively.** Don't dump 15 tables at once. Walk through each table, explain what it does, let the user question each one. One schema went from 15 to 8 tables through iterative "why does X exist?" questioning over multiple turns.
4. **Look for identical schemas hiding under different names.** Two tables with the same columns are one table with a type column.
5. **Question intermediate tables.** If A to B to C and B is just a routing step with no independent state, collapse to A to C.
6. **Derive, don't store.** If a column's value can be computed from a JOIN or query (e.g. `last_run_at = MAX(completed_at) FROM runs`), don't store it.
7. **State from relationships, not status columns.** A trigger with `run_id IS NULL` is pending. No status enum to maintain.
8. **Make placeholder columns real or kill them.** A column always written with the same hardcoded string is a placeholder. Either populate it with real data or delete it.
9. **Check for database reserved words** when naming tables. `trigger`, `user`, `order`, `group`, `index` are all reserved in PostgreSQL. Use descriptive prefixes (e.g. `pipeline_trigger`).

## ORM migration plans

When planning a migration from raw SQL to an ORM (Piccolo, SQLAlchemy, Django ORM):

1. **Foundation first, fan out second.** ORM models + config must be committed before any module rewrites start. Everything depends on the models.
2. **Rewrite tests, don't patch them.** Tests written against raw sqlite3 (in-memory DBs, `conn.execute()`, `_fresh_db()` patterns) cannot be incrementally patched to use ORM fixtures. Rewriting from scratch is faster and produces cleaner tests.
3. **Skip auxiliary module tests first, circle back.** When the core modules are migrated but auxiliary ones still use raw SQL, skip their tests with `@pytest.mark.skip(reason="Pending migration")` rather than blocking the PR.
4. **Fan out module rewrites by file group.** Subagents can work in parallel on non-overlapping file groups. But they cannot share the same files.
5. **Backward-compat stubs matter.** Keep `connect()` functions returning a no-op connection object (not None) with a `.close()` method. Old callers crash on `None.close()`.
6. **Status from relationships, not enums.** A trigger with `run_id IS NOT NULL` is "processing." No status column to maintain. But you need sentinel values for edge cases.

## Technique: When the verbal explanation isn't landing, build the artifact

If the user pushes back with "i'm not getting it" / "what are you talking about" on a design or mechanic, stop re-explaining in prose. Abstract descriptions of a behavior ("recurs until accepted, self-disables on a row existing") are exactly what fail to land. Build a concrete, interactive artifact that *shows the mechanic happening* and ship it (a quick deployed web page is the fast path; an ASCII walkthrough works inline).

Recipe: pick the smallest real scenario that exercises the mechanic end to end, render each step concretely (not "the bot may offer X" but the actual message bubble with the actual content), highlight the one thing that's new, annotate the *why* at each decision point, and add a truth table enumerating every input case for completeness. Dramatize the rule across concrete instances rather than describing it. This is faster than a fourth paragraph of prose and it doubles as the spec.

## Pitfall: Inventing durable state the architecture doesn't need

The most expensive plan error this class produces is not under-building, it's **over-building a state machine for a stateless problem**. Symptom: the plan introduces a new DB column, a new "mark it done" endpoint, a consume/accounting step, and a session flag — all to enforce some "exactly once / remember whether we did X" guarantee the user never asked for. A typical correction from the user when this happens: *"what are you talking about. each message is a message and that's it."*

Before a plan adds ANY persistence (a column, a flag, an endpoint, a counter, a cache key) to remember something across turns, force this question: **does the existing per-request architecture already make this decision for free?** Most request/response systems (a gate that fires fresh every message, with no session) can express "should we do X right now?" as a pure function of current state that's already in the DB. Examples of the collapse:

- "Show the offer once, then stop" → if accepting the offer creates a row (a config, a subscription, a setting), then "no such row exists yet" IS the eligibility signal. It self-disables the instant they accept. No `shown_at`, no consume step, no endpoint. The offer recurring until accepted is usually **better** UX anyway (the user can't permanently miss a one-shot) — so the simpler design is also the better one, not a compromise.
- "Track whether we greeted them" → the welcome path already branches on `is_new_user`/`created`. Reuse it.
- "Remember which step of a flow they're on" → derive it from what data they've already supplied, not a stored `flow_state` enum.

Heuristic: **count the moving parts in two columns — "what the user actually wants" vs "machinery to remember state."** If the second column is bigger, the design is wrong. Collapse the plan to: one signal (a boolean computed from existing rows) + the actual content + the one instruction that consumes the signal. Re-derive instead of persist. Migrations, new endpoints, and accounting steps are the things to delete first when a reviewer (or the user) says "this is too complicated."

When you catch yourself writing "new field `*_at` / `*_shown` / `*_count`" or "new endpoint to record that we did X," stop and prove the per-request signal can't already answer the question. It usually can.

## Pitfall: Plans resting on an unproven feasibility assumption

When a plan's whole value depends on a technical assumption that has NOT been verified ("can we stream-parse partial JSON and render it incrementally?", "will this animation actually look right?", "does this API return what we think?"), do not jump from plan straight to a multi-PR build. A common standing correction: **"build a prototype first to validate this will actually work."** A multi-phase plan whose riskiest link is unproven is a guess wearing a checklist.

Identify the load-bearing assumption (the one thing that, if false, sinks the whole plan) and de-risk it with a throwaway prototype BEFORE committing to the real implementation:

1. **Isolate the risky core, drop everything else.** For a streaming-render plan the risk is "partial-JSON parsing + incremental render." The prototype ignores the backend, the runtimes, caching, and error handling, and just proves that one thing.
2. **Replay real data, not synthetic.** Lift a real payload from the codebase (e.g. an existing fallback/mock fixture) so the prototype exercises the actual shapes, escaping, and edge cases production will hit. Serialize it in the exact field order the real source emits.
3. **Prove the logic headless first, then the render.** Write a test that sweeps the core function across EVERY truncation boundary / input variant and asserts invariants (never surfaces a corrupt/partial value, monotonic growth, correct final parse). Add an adversarial test for the nastiest known cases (e.g. escaped quotes inside a string value, braces/brackets inside string values). Only after the logic passes headless do you validate the visual/animation in a real browser with a screenshot.
4. **Build it standalone, outside the repo.** A self-contained `~/projects/<thing>-proto/` (plain HTML + ES modules + CDN libs, pinned to the production library version) is faster than wiring into the real build and keeps the experiment disposable.
5. **Quantify the win, don't just say "it works."** A concrete number ("paints at 26% of the stream, ~3.8x faster first paint") both justifies the build and can be checked against the headless prediction.
6. **Write the prototype findings back into the plan** as a "Prototype validation (DONE)" section: what was proven, the evidence, and the implementation takeaways. The validated prototype's core module + its tests port directly into the real implementation.

The prototype either de-risks the build or kills a bad plan cheaply. Either outcome beats discovering the assumption was wrong three PRs deep.

## Save location

Default:
- `~/.hermes/plans/YYYY-MM-DD_HHMMSS-<slug>.md`

The standing convention is that all task plans live under `~/.hermes/plans/`, and completed plans move to `~/.hermes/plans/archive/`. Do **not** put plans in repo-local `.hermes/plans/` unless the user/runtime explicitly asks for backend-local workspace plans.

If the runtime provides a specific target path, use that exact path.
If not, create a sensible timestamped filename under `~/.hermes/plans/`.

## Interaction style

- If the request is clear enough, write the plan directly.
- If no explicit instruction accompanies `/plan`, infer the task from the current conversation context.
- If it is genuinely underspecified, ask a brief clarifying question instead of guessing.
- After saving the plan, reply briefly with what you planned and the saved path.
