---
name: coding-agent
description: Run Codex CLI, Claude Code, OpenCode, or Pi Coding Agent via acpx (Agent Client Protocol) for structured, non-PTY agent communication. Use when delegating coding tasks, PR reviews, or iterative code work to a coding agent.
metadata: {"openclaw":{"emoji":"🧩","requires":{"anyBins":["acpx","claude","codex","opencode","pi"]}}}
---

# Coding Agent (acpx-first)

Use **acpx** for all coding agent work. It's a headless ACP client that replaces PTY scraping with structured protocol communication — persistent sessions, prompt queueing, named parallel streams, and clean JSON output.

**Fallback:** If acpx fails or a specific agent isn't ACP-compatible, use PTY (see bottom of this skill).

## Install check

```bash
acpx --version   # should be installed globally
```

If missing: `npm install -g acpx@latest`

---

## Quick Start

```bash
# One-shot (no session state)
acpx codex exec 'summarize this repo in 3 bullets'
acpx claude exec 'what does this repo do?'

# Persistent session (create first, then prompt)
cd ~/bloom && acpx codex sessions new
acpx codex 'fix the failing auth tests'
acpx codex 'now run the tests and report'   # continues same session

# Named parallel sessions
acpx codex -s backend 'fix API pagination bug'
acpx codex -s frontend 'update the chart component'
```

---

## Built-in Agents

| Name | Wraps |
|---|---|
| `codex` | Codex CLI (default) |
| `claude` | Claude Code |
| `gemini` | Gemini CLI |
| `opencode` | OpenCode |
| `pi` | Pi Coding Agent |

---

## Core Commands

### Session lifecycle

```bash
acpx codex sessions new              # create session for current dir
acpx codex sessions new --name api   # named session
acpx codex sessions list             # list all sessions
acpx codex sessions show             # inspect current session metadata
acpx codex sessions history          # recent turn history
acpx codex sessions close            # soft-close (keeps history)
acpx codex status                    # is the agent process alive?
```

### Prompting

```bash
acpx codex 'your prompt'                         # persistent session
acpx codex exec 'your prompt'                    # one-shot, no session
acpx codex --no-wait 'enqueue and return now'    # fire-and-forget
acpx codex cancel                                # cancel in-flight prompt
echo 'prompt text' | acpx codex                  # prompt from stdin
acpx codex --file prompt.md                      # prompt from file
```

### Permissions

```bash
acpx --approve-all codex 'apply fix and run tests'     # auto-approve everything
acpx --approve-reads codex 'inspect and propose'       # default: prompt for writes
acpx --deny-all codex 'what can you see?'              # deny all tool access
```

### Output formats

```bash
acpx --format quiet codex exec 'summarize in 3 lines'         # final text only
acpx --format json codex exec 'review changes' > events.ndjson  # machine-readable NDJSON
acpx --format json codex exec 'review' | jq -r 'select(.type=="tool_call") | [.status,.title] | @tsv'
```

---

## Patterns

### PR Review (safe — temp worktree)

```bash
git worktree add /tmp/pr-130-review pr-130-branch
acpx --cwd /tmp/pr-130-review --approve-reads codex sessions new
acpx --cwd /tmp/pr-130-review codex 'Review this branch vs main. Flag regressions, suggest minimal fix.'
git worktree remove /tmp/pr-130-review
```

### Batch PR Reviews (parallel)

```bash
git worktree add /tmp/pr-86 origin/pr/86
git worktree add /tmp/pr-87 origin/pr/87

acpx --cwd /tmp/pr-86 --approve-reads codex sessions new
acpx --cwd /tmp/pr-87 --approve-reads codex sessions new

acpx --cwd /tmp/pr-86 --no-wait codex 'Review PR #86 vs main. Output findings.'
acpx --cwd /tmp/pr-87 --no-wait codex 'Review PR #87 vs main. Output findings.'

# Check results when done
acpx --cwd /tmp/pr-86 codex sessions history
acpx --cwd /tmp/pr-87 codex sessions history
```

### Parallel Issue Fixing (git worktrees)

```bash
git worktree add -b fix/issue-78 /tmp/issue-78 main
git worktree add -b fix/issue-99 /tmp/issue-99 main

acpx --cwd /tmp/issue-78 codex sessions new
acpx --cwd /tmp/issue-99 codex sessions new

acpx --cwd /tmp/issue-78 --approve-all --no-wait codex 'Fix issue #78: <description>. Commit when done.'
acpx --cwd /tmp/issue-99 --approve-all --no-wait codex 'Fix issue #99: <description>. Commit when done.'

# Poll when done, then PR
cd /tmp/issue-78 && git push -u origin fix/issue-78
gh pr create --repo user/repo --head fix/issue-78 --title "fix: ..."

git worktree remove /tmp/issue-78
git worktree remove /tmp/issue-99
```

### Queue follow-up without blocking

```bash
acpx codex 'run full test suite and investigate failures'
acpx codex --no-wait 'after tests, summarize root causes and next steps'
```

---

## Config

Global config at `~/.acpx/config.json` (create with `acpx config init`):

```json
{
  "defaultAgent": "codex",
  "defaultPermissions": "approve-all",
  "ttl": 300
}
```

Project config at `<cwd>/.acpxrc.json` overrides global.

---

## PTY Fallback

Use PTY only when acpx fails or an agent doesn't support ACP:

```bash
# Codex/Pi/OpenCode (need PTY)
exec pty:true workdir:~/project command:"codex exec --full-auto 'Your task'"

# Claude Code (no PTY needed — use --print flag)
exec workdir:~/project command:"claude --permission-mode bypassPermissions --print 'Your task'"
```

> **Note:** `--dangerously-skip-permissions` with PTY can exit after the confirmation dialog. Use `--print --permission-mode bypassPermissions` for Claude Code instead.

---

## ⚠️ Rules

1. **acpx first** — always try ACP before falling back to PTY scraping.
2. **Create a session before prompting** — `acpx codex sessions new` in the target dir, or use `exec` for one-shots.
3. **Use `--cwd` when working outside current dir** — session scope is tied to directory.
4. **Respect tool choice** — if user asks for Codex, use `acpx codex`. Don't silently swap agents.
5. **Never start agents in `~/clawd/`** — they'll read soul docs and get weird ideas about the org chart.
6. **Never checkout branches in the live OpenClaw workspace** — use worktrees.
7. **Parallel is fine** — named sessions + `--no-wait` makes it easy.

---

## Progress Updates

Keep Eric in the loop when running background work:

- Send 1 message when you start (what + where).
- Update only when something changes: milestone done, agent needs input, error, or finished.
- On finish: include what changed and where to find it.

---

## Auto-Notify on Completion

For long-running tasks, append a wake trigger to the prompt:

```bash
acpx --approve-all codex 'Build a REST API for todos.

When completely finished, run: openclaw gateway wake --text "Done: Built todos REST API" --mode now'
```
