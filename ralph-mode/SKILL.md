# Ralph Loop

Implementation of the Ralph Wiggum technique for iterative, self-referential AI development loops in Claude Code.

## What It Is

Ralph Loop is a development methodology: a simple `while true` that repeatedly feeds the same prompt to Claude Code, letting it iteratively improve its work until completion. Named after the Ralph Wiggum coding technique by Geoffrey Huntley.

This skill implements Ralph using a **Stop hook** that intercepts Claude's exit attempts inside the current session. No external bash loops needed.

## How It Works

```
/ralph-loop "Your task description" --completion-promise "DONE"

# Claude Code automatically:
# 1. Works on the task
# 2. Tries to exit
# 3. Stop hook blocks exit, feeds SAME prompt back
# 4. Claude sees its previous work in files + git history
# 5. Repeat until completion
```

**Always quote the prompt.** Unquoted prompts with special characters (parentheses, `$`, backticks, etc.) will break in the shell before the script sees them.

The prompt never changes between iterations. Claude improves by reading its own past work in files.

## Setup

The plugin files live in this skill directory. To use Ralph in a project, install the official Claude Code plugin:

```bash
# In Claude Code, run:
/install-plugin https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop
```

Or manually copy the hooks/commands/scripts directories into the project's `.claude/` directory.

## Commands

### /ralph-loop

Start a Ralph loop in the current session.

```
/ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"
```

Always wrap `<prompt>` in quotes to avoid shell interpretation of special characters.

Options:
- `--max-iterations <n>`: Stop after N iterations (default: unlimited)
- `--completion-promise <text>`: Phrase that signals completion

### /cancel-ralph

Cancel the active Ralph loop (removes `.claude/ralph-loop.local.md`).

## Completion Promises

To signal completion, Claude outputs a `<promise>` tag:

```
<promise>TASK COMPLETE</promise>
```

The stop hook uses exact string matching. Always use `--max-iterations` as a safety net.

## Prompt Best Practices

### Clear Completion Criteria

Bad: "Build a todo API and make it good."

Good:
```
Build a REST API for todos.

When complete:
- All CRUD endpoints working
- Input validation in place
- Tests passing (coverage > 80%)
- README with API docs
- Output: <promise>COMPLETE</promise>
```

### Incremental Goals

```
Phase 1: User authentication (JWT, tests)
Phase 2: Product catalog (list/search, tests)
Phase 3: Shopping cart (add/remove, tests)

Output <promise>COMPLETE</promise> when all phases done.
```

### Self-Correction (TDD)

```
Implement feature X following TDD:
1. Write failing tests
2. Implement feature
3. Run tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green
7. Output: <promise>COMPLETE</promise>
```

### Escape Hatches

Always set `--max-iterations`. In the prompt, include what to do if stuck:
```
After 15 iterations, if not complete:
- Document what's blocking progress
- List what was attempted
- Suggest alternative approaches
```

## When to Use

Good for:
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement (e.g., getting tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters)

Not good for:
- Tasks requiring human judgment or design decisions
- One-shot operations
- Tasks with unclear success criteria
- Production debugging (use targeted debugging instead)

## OpenClaw Integration

When spawning a Ralph loop via OpenClaw ACPX:

```
sessions_spawn({
  runtime: "acp",
  agentId: "claude",
  task: '/ralph-loop "Build X. Output <promise>DONE</promise> when complete." --completion-promise "DONE" --max-iterations 20',
  cwd: "<repo>",
  runTimeoutSeconds: 3600
})
```

The plugin must be installed in the target project first.

## Philosophy

1. **Iteration > Perfection**: Don't aim for perfect on first try. Let the loop refine.
2. **Failures Are Data**: "Deterministically bad" means failures are predictable. Use them to tune prompts.
3. **Operator Skill Matters**: Success depends on writing good prompts, not just having a good model.
4. **Persistence Wins**: Keep trying until success.

## References

- Original technique: https://ghuntley.com/ralph/
- Official plugin: https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator
