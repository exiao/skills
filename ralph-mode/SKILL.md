---
name: ralph-mode
description: "Use when running Ralph Mode, autonomous coding loops, iterative build-test-fix cycles, or hands-off development. Also use for 'let the agent code autonomously', 'auto-iterate until it works', 'autonomous development', or 'build loop with iteration gates'."
---
# Ralph Mode - Autonomous Development Loops

Ralph Mode implements the Ralph Wiggum technique adapted for OpenClaw: autonomous task completion through continuous iteration with backpressure gates, completion criteria, and structured planning.

## When to Use

- Building features that require multiple iterations and refinement
- Complex projects with acceptance criteria to validate
- Need automated testing, linting, or typecheck gates between iterations
- Want to track progress across many iterations systematically
- Prefer autonomous loops over manual turn-by-turn guidance

## Core Workflow: Three Phases

### Phase 1 — Requirements Definition
- Document specs in `specs/` (one file per topic of concern)
- Define acceptance criteria: observable, verifiable outcomes
- Create prioritized `IMPLEMENTATION_PLAN.md`

### Phase 2 — Planning (no implementation)
- Gap analysis: compare specs against existing code
- Generate `IMPLEMENTATION_PLAN.md` with prioritized tasks
- No code written during this phase

### Phase 3 — Building (iterative loop)
- Pick one task per iteration
- Implement → validate → update plan → commit
- Repeat until all tasks complete or criteria met

## Loop Mechanics

### Outer Loop (You coordinate)
- Spawn sub-agents for each iteration — don't allocate work to main context
- Let the LLM self-identify and self-correct ("Let Ralph Ralph")
- Plan is disposable — regenerate when wrong/stale; don't salvage
- Sit outside the loop and observe; don't micromanage

### Inner Loop (Sub-agent per iteration)
1. **Study** — Read plan, specs, relevant code
2. **Select** — Pick most important uncompleted task
3. **Implement** — Write code for that one task only
4. **Validate** — Run backpressure gates (tests, lint, typecheck)
5. **Update** — Mark task done, note discoveries, commit
6. **Exit** — Next iteration starts fresh with clean context

## Backpressure Gates

**Programmatic (always use these):**
- Tests: must pass before committing
- Typecheck: catch type errors early
- Lint: enforce code quality
- Build: verify integration

**Subjective (for UX/design quality):**
- LLM-as-judge reviews: binary pass/fail
- Only add after programmatic gates are reliable

## Completion Criteria

Define success upfront — avoid "seems done" ambiguity.

**Programmatic:** All tests pass (exit 0), no TypeScript errors, build succeeds, coverage threshold met.

**Subjective (LLM-as-judge):** For quality that resists automation — tone, aesthetics, usability. Binary pass/fail that converges through iteration.

**Stopping conditions:**
- ✅ All `IMPLEMENTATION_PLAN.md` tasks completed
- ✅ All acceptance criteria met
- ✅ Tests passing, no blocking issues
- ⚠️ Max iterations reached
- 🛑 Manual stop

## Quick Start

```
"Start Ralph Mode for my project at ~/projects/my-app.
I want to implement [feature]."
```

Ralph Mode will:
1. Create `IMPLEMENTATION_PLAN.md` with prioritized tasks
2. Spawn sub-agents for iterative implementation
3. Apply backpressure gates (test, lint, typecheck) each iteration
4. Track progress and announce completion

## Key Rules

- **One task per iteration** — keeps context fresh, avoids drift
- **Plans are disposable** — regenerate cheaply vs. salvage stale ones
- **Lean prompts** — target ~40–60% context utilization ("smart zone")
- **Spawn sub-agents for exploration** — protect main context

---

## References

This skill content is modularized into reference docs for readability.

- [When to Use](references/when-to-use.md)
- [Core Principles](references/core-principles.md)
- [File Structure](references/file-structure.md)
- [In Progress](references/in-progress.md)
- [Completed](references/completed.md)
- [Backlog](references/backlog.md)
- [Build Commands](references/build-commands.md)
- [Validation](references/validation.md)
- [Operational Notes](references/operational-notes.md)
- [Hats (Personas)](references/hats-personas.md)
- [Loop Mechanics](references/loop-mechanics.md)
- [Completion Criteria](references/completion-criteria.md)
- [Completion Check - UX Quality](references/completion-check-ux-quality.md)
- [Completion Check - Design Quality](references/completion-check-design-quality.md)
- [Technology-Specific Patterns](references/technology-specific-patterns.md)
- [Quick Start Command](references/quick-start-command.md)
- [Operational Learnings](references/operational-learnings.md)
- [Discovered Patterns](references/discovered-patterns.md)
- [Escape Hatches](references/escape-hatches.md)
- [Advanced: LLM-as-Judge Fixture](references/advanced-llm-as-judge-fixture.md)
- [Critical Operational Requirements](references/critical-operational-requirements.md)
- [Iteration [N] - [Timestamp]](references/iteration-n-timestamp.md)
- [Status: COMPLETE ✅](references/status-complete.md)
- [Operational Parameters](references/operational-parameters.md)
- [Memory Updates](references/memory-updates.md)
- [[Date] Ralph Mode Session](references/date-ralph-mode-session.md)
- [Appendix: Hall of Failures](references/appendix-hall-of-failures.md)
- [NEW: Session Initialization Best Practices (2025-02-07)](references/new-session-initialization-best-practices-2025-02-07.md)
- [Task: [ONE specific thing]](references/task-one-specific-thing.md)
- [Rules](references/rules.md)
- [Iteration [N] - [Timestamp]](references/iteration-n-timestamp-2.md)
- [Summary](references/summary.md)
