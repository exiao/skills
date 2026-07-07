---
name: claude-workflows
description: "Invoke Claude Code dynamic workflows (ultracode) headlessly from Hermes to orchestrate subagents at scale for a bug sweep, large migration, or cross-checked research. Use when the user wants to run a Claude Code workflow, use ultracode, fan out many agents on one task, or asks about agent teams from Hermes. Covers the token/cost traps behind the local billing proxy."
version: 1.0.0
author: Hermes Agent
metadata:
  hermes:
    tags: [Claude-Code, Workflows, ultracode, Orchestration, Subagents, Billing-Proxy]
    related_skills: [claude-code, codex]
---

# Claude Code Dynamic Workflows from Hermes

A [dynamic workflow](https://code.claude.com/docs/en/workflows) is a JavaScript script Claude Code writes to orchestrate subagents at scale (dozens to hundreds of agents), running in the background while the session stays free. The script holds the loop, branching, and intermediate results, so only the final answer returns. Reach for one on a codebase-wide bug sweep, a large migration, or a research question that needs sources cross-checked against each other. For a handful of independent tasks, plain `TaskDelegate` fan-out is simpler and cheaper.

Workflows run in headless mode (`claude -p`), so Hermes can trigger them through the terminal. Agent teams cannot, meaningfully (see the bottom).

## Prerequisites (one-time)

- Claude Code **v2.1.154+** (`claude --version`).
- Workflows enabled. They're on by default; to be explicit set `"disableWorkflows": false` in `~/.claude/settings.json`. Disabled if `"disableWorkflows": true`, `CLAUDE_CODE_DISABLE_WORKFLOWS=1`, or the `/config` toggle is off.

## Run a workflow headlessly

```bash
claude -p 'ultracode: <your task>' \
  --model haiku \
  --allowedTools 'Read,Workflow' \
  --max-turns 15 \
  --output-format json 2>&1 | tail -30
```

Three things make or break this:

1. **`ultracode:` prefix triggers the workflow.** The keyword `ultracode` in the prompt (or plain English like "use a workflow" / "run a workflow") makes Claude write and run a workflow script instead of working turn by turn. Without it you get an ordinary agentic run.

2. **`Workflow` MUST be in `--allowedTools`.** The workflow itself is executed via a `Workflow` tool. If it isn't whitelisted, headless mode permission-denies the tool and Claude silently falls back to doing the task directly (you still get an answer, but the workflow never ran). Check the JSON result: `permission_denials` should be `[]`, and a denied entry with `"tool_name":"Workflow"` means you forgot to allow it. Add whatever else the task needs (`Read,Write,Bash,WebSearch,Workflow`).

3. **Force a cheap model with `--model haiku` (or `sonnet`).** The default here is `opus-4-8[1m]` (1M-context Opus). Its system-prompt cache creation alone tokenizes huge, so even a trivial workflow reports ~$0.50+ and moves ~9x more priced tokens than haiku. Only omit `--model` when the task genuinely needs Opus reasoning.

## Bound the run with --max-turns, never --max-budget-usd

`--max-budget-usd` is a trap whenever `claude` traffic is routed through a local billing proxy (an `ANTHROPIC_BASE_URL` pointing at `127.0.0.1`) that authenticates with a Claude **subscription** OAuth token instead of a metered API key. In that setup no per-token API dollars are ever spent, but the CLI doesn't know that: `total_cost_usd` is a **client-side estimate** it computes locally by multiplying observed tokens by Anthropic's published API list prices, unconditionally. `--max-budget-usd` is enforced against that same estimate, so a legit run aborts with `error_max_budget_usd` at an imaginary "$0.50" while nothing was actually charged. (On a plain metered API key the number is real, ignore this section.)

Consequences:
- **Bound runaway loops with `--max-turns`** (start 10-15), not a dollar cap.
- **Read `total_cost_usd` as a relative token gauge only**, not real spend. Haiku ~$0.06 vs Opus-1M ~$0.54 tells you haiku moved far fewer priced tokens; neither is money out the door. The real constraint is subscription rate-limits.
- If you must use a budget cap as a safety net, set it generously (e.g. `--max-budget-usd 3`) since it fires on inflated estimates.

## Watch progress / bundled workflow

There's a built-in `/deep-research` workflow (fans out web searches, cross-checks sources, votes on each claim, returns a cited report with unsupported claims filtered out). In interactive mode `/workflows` lists runs and drills into phases. Headless `-p` just returns the final report.

## Verify it actually ran a workflow

Parse the `--output-format json` result:
- `subtype: "success"` and `is_error: false`.
- `permission_denials: []` (a `Workflow` denial = the tool wasn't allowed, so it fell back).
- To confirm the workflow path fired (not the fallback), either allow `Workflow` and look for it in the transcript, or run with `--verbose` and watch for the `Workflow` tool_use.

## Agent teams: don't bother from Hermes

[Agent teams](https://code.claude.com/docs/en/agent-teams) (peer Claude sessions with a shared task list, gated behind `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) are built around interactive terminal control: the agent panel, arrow-key teammate selection, split panes via tmux/iTerm2. Headless `claude -p` loses all of that, and the docs flag known limits on session resumption and shutdown. You *can* spawn a team from a prompt, but you can't drive it the way it's designed for. For Hermes parallelism use `TaskDelegate` fan-out or kanban lanes instead. The one thing a workflow adds over plain fan-out is the adversarial cross-check pattern (independent agents review each other's findings before reporting).

## How it works under the hood

No JSON file, no saved artifact for ad-hoc runs. A workflow is a **JS/TS script string** carried in a `Workflow` tool_use, executed in a sandboxed Node VM (no eval/wasm). The script calls injected globals to spawn and coordinate subagents: `agent(prompt, opts)` (one subagent; pass `opts.schema` for a validated object), `parallel([...])`, `pipeline(...)`, `phase(title)`, and `budget` (shared token ceiling). For an ad-hoc `ultracode` run the script lives only in the session transcript at `~/.claude/projects/<slug>/<uuid>.jsonl` (grep `tool_use` name `Workflow`, field `script`); saved workflows become `.claude/commands/*.md`; bundled ones are in the binary. Nesting is one level deep; runs are resumable via `Workflow({scriptPath, resumeFromRunId})`. Full runtime API, deep-research reference shape, and a transcript-extraction snippet: `references/workflow-runtime-internals.md`.

## Skill source

- https://code.claude.com/docs/en/workflows
- https://code.claude.com/docs/en/agent-teams

To update: re-fetch the two docs URLs and diff against the flags/behavior above.
