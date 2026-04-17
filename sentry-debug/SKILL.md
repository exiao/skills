---
name: sentry-debug
description: Use when debugging production errors via Sentry — listing and searching issues, inspecting events and stack traces, checking release distribution, running Seer root-cause analysis, or resolving/assigning issues. Trigger phrases include "sentry", "production error", "what's crashing", "recent crashes", "error in <project>", "resolve sentry issue", "sentry autofix".
---

# Sentry Debug

Thin `curl` wrapper around the Sentry REST API. Covers the full debug loop — list, drill in, triage, resolve — without running an MCP server.

## When to use

- **Triage:** "what's crashing in production", "recent errors in <project>"
- **Drill-in:** "show me the stack trace for `<SHORT-ID>`"
- **Impact:** "how many users affected", "which release introduced this"
- **Resolve:** "mark this issue as resolved", "assign this to <user>"
- **AI analysis:** "run Seer on this issue" (Sentry's hosted root-cause AI)

## Setup

One-time:

```bash
export SENTRY_AUTH_TOKEN=<sentry user auth token with event:read/write, project:read, alerts:write>
export SENTRY_ORG=<your-org-slug>   # optional; required if you don't want to pass it every call
```

Required token scopes: `event:read` and `project:read` at minimum. Add `event:write` / `alerts:write` for resolve/assign, `org:read` for `orgs list`.

Generate a token at: `https://sentry.io/settings/account/api/auth-tokens/`.

## Quick start

All commands go through `scripts/sentry.sh`:

```bash
cd ~/clawd/skills/sentry-debug

# List unresolved issues across all projects
./scripts/sentry.sh issues list "is:unresolved" --limit 10

# Filter to one project (by slug)
./scripts/sentry.sh issues list "is:unresolved project:<project-slug>"

# Get details for one issue (by shortId or numeric id)
./scripts/sentry.sh issues get <SHORT-ID>

# Latest event — full stack trace + breadcrumbs
./scripts/sentry.sh issues events <SHORT-ID> --latest

# Release distribution — which version is this happening on?
./scripts/sentry.sh issues tags <SHORT-ID> release

# Resolve / assign
./scripts/sentry.sh issues resolve <SHORT-ID>
./scripts/sentry.sh issues assign <SHORT-ID> <username-or-email>

# Seer root-cause AI (kicks off analysis; poll with --status)
./scripts/sentry.sh autofix <SHORT-ID>
./scripts/sentry.sh autofix <SHORT-ID> --status

# Admin / scope
./scripts/sentry.sh whoami
./scripts/sentry.sh orgs list
./scripts/sentry.sh projects list
./scripts/sentry.sh releases list --project <project-slug> --limit 5
./scripts/sentry.sh trace <trace_id>
```

## Query syntax

The `query` argument is raw Sentry search syntax. Most common patterns:

| Query | Meaning |
|-------|---------|
| `is:unresolved` | Open issues |
| `is:resolved` | Closed issues |
| `project:<slug>` | Scope to one project |
| `assigned:me` / `assigned:<email>` | Assignment filter |
| `release:<version>` | Specific release |
| `environment:production` | Production only |
| `firstSeen:-24h` | Seen in the last 24h |
| `error.type:TypeError` | By exception class |
| `has:stack` | Only events with stack traces |

Combine with spaces (AND): `is:unresolved project:<slug> firstSeen:-7d`.

See `references/query-syntax.md` for the full cheatsheet and `references/endpoints.md` for the raw endpoint map (if `sentry.sh` is missing something).

## Output shape

By default, output is pretty-printed JSON through `jq`. Add `--json` to any command to get the raw API response for piping or parsing.

## Common playbooks

**"What's crashing?"** →
```bash
./scripts/sentry.sh issues list "is:unresolved" --limit 10 --sort freq
```

**"Top issue with full context"** →
```bash
ID=$(./scripts/sentry.sh issues list "is:unresolved" --limit 1 --json | jq -r '.[0].shortId')
./scripts/sentry.sh issues get $ID
./scripts/sentry.sh issues events $ID --latest
./scripts/sentry.sh issues tags $ID release
```

**"Debug this specific issue"** →
```bash
./scripts/sentry.sh issues events <SHORT-ID> --latest   # stack trace
./scripts/sentry.sh autofix <SHORT-ID>                  # kick off Seer analysis
./scripts/sentry.sh autofix <SHORT-ID> --status         # poll
```

## Notes

- `shortId` (e.g. `MY-PROJECT-42`) resolves to numeric ID via a dedicated `shortids/{id}/` endpoint — single hop, unambiguous.
- Seer (`autofix`) returns a run handle immediately. Poll with `--status`. Typical analysis time: 30s–3min. If your org doesn't have Seer billing enabled, Sentry responds with `"No budget for Seer Autofix."`
- Releases list requires numeric project ID internally; the script resolves `--project <slug>` for you.
- Every command is a single HTTP call. No subprocess, no npx, no MCP boot cost.

## References

- `references/query-syntax.md` — Sentry search DSL cheatsheet
- `references/endpoints.md` — endpoint → subcommand map
