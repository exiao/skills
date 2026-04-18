---
name: claude-code-routines
description: "Set up and manage Claude Code Routines — scheduled, API-triggered, and GitHub webhook automations that run on Anthropic's cloud. Use when asked about routines, scheduled tasks in Claude Code, automating with Claude, or setting up triggers for code review, deploys, alerts, or recurring tasks."
tags: [claude-code, routines, automation, scheduling, github, api, webhooks]
---

# Claude Code Routines

Routines are Claude Code automations — a prompt, repo(s), and connectors — that run on Anthropic's cloud infrastructure. They keep working when your laptop is closed.

**Availability:** Pro, Max, Team, and Enterprise plans with Claude Code on the web enabled.
**Status:** Research preview — behavior, limits, and API surface may change.

## Trigger Types

A routine can combine **multiple triggers**:

### 1. Scheduled
Recurring cadence: hourly, daily, weekdays, weekly, or custom cron (minimum 1 hour).

```
Example: "Every night at 2am: pull the top bug from Linear, attempt a fix, and open a draft PR."
```

### 2. API
Every routine gets its own endpoint + bearer token. POST a message, get back a session URL. Wire into alerting, deploy hooks, internal tools.

```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/trig_01ABCDEFG/fire \
  -H "Authorization: Bearer sk-ant-oat01-xxxxx" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"text": "Sentry alert SEN-4521 fired in prod."}'
```

Response:
```json
{
  "type": "routine_fire",
  "claude_code_session_id": "session_01HJKLMNOPQRSTUVWXYZ",
  "claude_code_session_url": "https://claude.ai/code/session_01HJKLMNOPQRSTUVWXYZ"
}
```

- Optional `text` field appended as a one-shot user turn
- Token shown once — store securely; can be regenerated
- Requires `anthropic-beta: experimental-cc-routine-2026-04-01` header
- Available to claude.ai users only (not Claude Platform API)

### 3. GitHub Webhook
Subscribe to repo events (PRs, pushes, issues, workflow runs). Claude opens **one session per PR** and feeds updates to it (comments, CI failures). Requires the Claude GitHub App installed on the repo.

```
Example: "Flag PRs that touch /auth-provider. Summarize changes and post to #auth-changes."
```

## Creating a Routine

### Web UI (all trigger types)
1. Go to [claude.ai/code/routines](https://claude.ai/code/routines) → **New routine**
2. Set **name & prompt** (must be self-contained and explicit; includes model selector)
3. Select **repositories** (cloned at run start from default branch; Claude creates `claude/`-prefixed branches)
4. Configure **environment** (network access, env variables, setup scripts)
5. Add **trigger(s)** — can combine schedule + API + GitHub
6. Configure **connectors** (MCP connectors included by default)
7. Click **Create** → **Run now** for immediate test

### CLI (scheduled only)
```
/schedule                    # Create a scheduled routine conversationally
/schedule daily at 9am       # Create with cadence inline
/schedule list               # View all routines
/schedule update             # Modify or set custom cron
/schedule run                # Trigger immediately
```

API and GitHub triggers require the web UI.

### Desktop App
Schedule page → **New task** → **New remote task**
("New local task" runs on your machine instead of cloud)

## Example Use Cases

| Use Case | Trigger | Prompt Idea |
|----------|---------|-------------|
| Backlog triage | Nightly schedule | Read new issues, label, assign, post summary to Slack |
| Alert triage | API (from Datadog/PagerDuty) | Correlate stack trace with recent commits, draft fix |
| Code review | GitHub (PR opened) | Run team's security/perf checklist, leave inline comments |
| Deploy verification | API (from CD pipeline) | Run smoke checks, scan error logs, post go/no-go |
| Docs drift | Weekly schedule | Scan merged PRs, flag stale docs, open update PRs |
| Library port | GitHub (PR merged) | Port changes from Python SDK to Go SDK |
| Feedback resolution | API (from docs widget) | Open session with issue in context, draft the change |

## Daily Limits

| Plan | Routines/Day |
|------|-------------|
| Pro | 5 |
| Max | 15 |
| Team/Enterprise | 25 |

- Routines draw down normal subscription usage limits
- Extra runs beyond daily limits use extra usage

## Key Details

- Routines run **autonomously** — no approval prompts, no permission mode
- Sessions can run shell commands, use committed skills, and call connectors
- Routines belong to your **individual** claude.ai account (not shared with teammates)
- Actions appear **as you** (commits carry your GitHub user, Slack messages use your linked account)
- Custom cron via `/schedule update` (minimum 1-hour interval)
- Repos get `claude/`-prefixed branches; optionally enable unrestricted branch pushes
- Schedule times entered in local timezone, converted automatically
- Runs may start a few minutes late (consistent stagger per routine)

## References
- Blog: https://claude.com/blog/introducing-routines-in-claude-code
- Docs: https://code.claude.com/docs/en/routines
- Management: https://claude.ai/code/routines
