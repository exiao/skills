---
name: plan
preloaded: true
description: Plan mode for Hermes Agent — inspect context, write a markdown plan into the active workspace's `.hermes/plans/` directory, and do not execute the work.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  runtime:
    tags: [planning, plan-mode, implementation, workflow]
    related_skills: [writing-plans, subagent-driven-development]
---

# Plan Mode

Use this skill when the user wants a plan instead of execution.

## Core behavior

For this turn, you are planning only.

- Do not implement code.
- Do not edit project files except the plan markdown file.
- Do not run mutating terminal commands, commit, push, or perform third-party actions.
- You may inspect the repo or other context with read-only commands/tools when needed.
- Your deliverable is a markdown plan saved inside the active workspace under `.hermes/plans/`.

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

## Pitfall: Distributing third-party learnings into a skill library

When the plan involves incorporating tips/frameworks from third-party sources (tweets, articles) into existing skills:

1. **Decompose first.** Break the source into atomic tips before deciding placement.
2. **Audit the full skill landscape.** Use `skills_list` + `SkillView` on every candidate skill. Look at existing sections, principles, and gaps. Don't guess from memory.
3. **Map each tip to its owner.** Create a tip-to-skill mapping table. Strategy tips go to strategy skills, creative tips to creative skills, operational tips to operational skills. Don't dump everything into one skill.
4. **Keep operational skills operational.** CLI/API wrapper skills should not accumulate strategy, targeting philosophy, or creative guidelines. Those belong in the strategy skill for that domain.
5. **Prefer expanding existing sections** (5-15 lines) over creating new standalone skills. Create new only when no existing skill covers the class.
6. **Source-attribute everything.** Include `(Source: @handle, Month YYYY)` so future sessions can assess staleness.

## Save location

Save the plan with `write_file` under:
- `.hermes/plans/YYYY-MM-DD_HHMMSS-<slug>.md`

Treat that as relative to the active working directory / backend workspace. Hermes Agent file tools are backend-aware, so using this relative path keeps the plan with the workspace on local, docker, ssh, modal, and daytona backends.

If the runtime provides a specific target path, use that exact path.
If not, create a sensible timestamped filename yourself under `.hermes/plans/`.

## Interaction style

- If the request is clear enough, write the plan directly.
- If no explicit instruction accompanies `/plan`, infer the task from the current conversation context.
- If it is genuinely underspecified, ask a brief clarifying question instead of guessing.
- After saving the plan, reply briefly with what you planned and the saved path.