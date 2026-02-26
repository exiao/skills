# Core Principles

### Three-Phase Workflow

**Phase 1: Requirements Definition**
- Document specs in `specs/` (one file per topic of concern)
- Define acceptance criteria (observable, verifiable outcomes)
- Create implementation plan with prioritized tasks

**Phase 2: Planning**
- Gap analysis: compare specs against existing code
- Generate `IMPLEMENTATION_PLAN.md` with prioritized tasks
- No implementation during this phase

**Phase 3: Building (Iterative)**
- Pick one task from plan per iteration
- Implement, validate, update plan, commit
- Continue until all tasks complete or criteria met

### Backpressure Gates

Reject incomplete work automatically through validation:

**Programmatic Gates (Always use these):**
- Tests: `[test command]` - Must pass before committing
- Typecheck: `[typecheck command]` - Catch type errors early
- Lint: `[lint command]` - Enforce code quality
- Build: `[build command]` - Verify integration

**Subjective Gates (Use for UX, design, quality):**
- LLM-as-judge reviews for tone, aesthetics, usability
- Binary pass/fail - converges through iteration
- Only add after programmatic gates work reliably

### Context Efficiency

- One task per iteration = fresh context each time
- Spawn sub-agents for exploration, not main context
- Lean prompts = smart zone (~40-60% utilization)
- Plans are disposable - regenerate cheap vs. salvage
