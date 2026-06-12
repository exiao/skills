---
name: ralph-mode
preloaded: true
description: "Run iterative self-referential development loops using the Ralph Wiggum technique. Use when tasks need repeated iteration, TDD cycles, greenfield builds, or autonomous refinement until tests pass or completion criteria are met. Triggers on ralph loop, ralph mode, iterative loop, autonomous loop, /goal."
---

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

## Self-Loop Protocol (OpenClaw)

OpenClaw doesn't have post-completion hooks like Claude Code. Instead, the loop lives in the agent's behavior. When Ralph Mode is active, follow this protocol at the end of every turn:

### After completing any work:

1. **Re-read** `IMPLEMENTATION_PLAN.md`
2. **Count** remaining incomplete tasks
3. **If tasks remain AND iteration < max:**
   - Pick the next highest-priority incomplete task
   - Implement it (one task only)
   - Run backpressure gates
   - Update the plan
   - Commit
   - Go to step 1
4. **If all tasks complete OR max iterations reached:**
   - Run final validation (all gates)
   - Emit the completion signal: `█RALPH_COMPLETE█`
   - Stop

### Completion signal

The literal string `█RALPH_COMPLETE█` signals the loop is done. Do not emit it until:
- Every task in `IMPLEMENTATION_PLAN.md` is marked done
- All backpressure gates pass
- No known blocking issues remain

If you hit max iterations (default: 10) without completing, emit `█RALPH_TIMEOUT█` instead and list remaining tasks.

### Why this works

The agent continues working within a single turn, using tool calls to implement, test, and commit in sequence. Each "iteration" is a tool-call cycle within the same turn, not a separate session. Context stays fresh because each task is small. If context gets heavy, the agent spawns a sub-agent for the next batch.

### For sub-agent mode (fresh context per iteration)

When the task is large enough to exhaust context:

```
sessions_spawn({
  runtime: "subagent",
  task: "Read IMPLEMENTATION_PLAN.md at [path]. Pick the next incomplete task. Implement it. Run [gates]. Update the plan. Commit. If more tasks remain, say CONTINUE. If all done, say █RALPH_COMPLETE█.",
  cwd: "[repo]",
  runTimeoutSeconds: 1800
})
```

The parent checks the sub-agent's output. If it says CONTINUE, spawn another. If `█RALPH_COMPLETE█`, stop.

## Liveness vs Stall: Don't Kill a Slow Job

When monitoring a long-running autonomous loop or batch (parameter sweeps, multi-step mutation runs, any unattended job that takes minutes-to-hours per unit), DO NOT declare it "hung" / "stalled" / "needs a timeout fix" from indirect symptoms like low CPU%. Slow LLM round-trips legitimately look idle: the process blocks on a network read with ~0% CPU between tokens, no child process, no fresh socket in a snapshot.

Confirm liveness with a positive signal before concluding a stall, in this order:
1. **Watch the log grow.** Capture line/byte count, `sleep 30`, re-capture. If it advanced (even by one line), it is PROGRESSING, not stalled. Single most reliable check.
2. **Check log mtime.** `stat -c %y <log> 2>/dev/null || stat -f "%Sm" <log>` — portable across GNU/Linux and BSD/macOS; modified seconds ago means alive.
3. **Check the actual client timeout** before claiming "no timeout = hangs forever." Grep the provider adapter for `Timeout(`/`timeout=`. Many SDK clients already set a read timeout (e.g. 900s); a genuinely stuck stream fails and retries rather than hanging indefinitely.

A true init-stall looks different: ~0% CPU AND zero log growth over multiple minutes AND no "Auto-repaired"/tool-call lines ever appearing. Only kill on that combination (e.g. >40 min running with no log growth), and kill only the one unit's subprocess, never the batch wrapper.

Honest accounting: when a sweep is slow, say so with real math (per-unit minutes × count = wall-clock) rather than inventing a blocker. A fabricated "I found the bug" diagnosis wastes a session chasing a non-issue.

### Distrust a diagnosis handed down through context compaction

A compaction summary may carry a CONCLUSION from a prior context window ("the batch is stalling on a no-timeout hang", "root cause: X has no request timeout", "blocked on Y"). Treat any such handed-down diagnosis as an UNVERIFIED claim, not a fact — the prior window may have been wrong, and the underlying state may have changed since. Before acting on it (writing a fix, killing a process, relaunching), re-confirm with one live positive signal: watch the log grow, check mtime, or grep the actual code path. A real example: a summary asserted an "infinite stream hang needing a config timeout fix"; a 30-second log-growth check showed the process was progressing the whole time and the SDK client already had a read timeout — the entire blocker was fictional. Cost of verifying: one terminal call. Cost of trusting a stale conclusion: multiple turns spent designing a fix for a non-bug. Your durable memory is authoritative; a mid-conversation compaction summary is not.

### Standing-goal nudges are not a cue to manufacture motion

When a long unattended job is healthy and progressing, repeated "take the next concrete step toward your goal" prompts arriving faster than the job's per-unit cadence do NOT mean invent a new action each turn. Polling identical state and re-deploying unchanged artifacts burns tokens without advancing anything. The correct responses, in order: (1) harvest any newly-completed results and update the demonstration/PRs; (2) make one durable improvement to the autonomous pipeline itself (e.g. fix a wrong path in the finisher cron, wire live results into the site, verify the PR-creation credential works) so completion lands cleanly unattended; (3) if none of those apply, state plainly "progressing, nothing useful to do this cycle, the cron owns completion" and stop. Do NOT parallelize a healthy run to look busy when the parallel path has real hazards (e.g. the sweep shares unlocked state in your eval state files, and concurrent large jobs can trip rate/billing limits).

## Key Rules

- **One task per iteration** — keeps context fresh, avoids drift
- **Plans are disposable** — regenerate cheaply vs. salvage stale ones
- **Lean prompts** — target ~40–60% context utilization ("smart zone")
- **Spawn sub-agents for exploration** — protect main context
- **Self-loop by default** — don't wait for the user between iterations
- **█RALPH_COMPLETE█ is the only exit** — no "seems done", no early stops

---

## References

- Original technique: https://ghuntley.com/ralph/
- Official plugin: https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator
