---
name: sentry-debug
preloaded: true
description: Use when debugging production errors via Sentry — listing and searching issues, inspecting events and stack traces, checking release distribution, running Seer root-cause analysis, or resolving/assigning issues. Trigger phrases include "sentry", "production error", "what's crashing", "recent crashes", "error in <project>", "resolve sentry issue", "sentry autofix".
---

# Sentry Debug

Uses the official `sentry` CLI (v0.31.0+, installed via cli.sentry.dev). Authenticated via SENTRY_AUTH_TOKEN env var.

## Org context

- Org slug: `$SENTRY_ORG`
- Projects: `invest` (Django backend), `bloom-frontend-web` (React), `bloom-updater` (FastAPI), `whatsgpt` (BloomBot), `choices-dev`, `bible-app`, `jotter`, `user-studies`, `userstudies-frontend`
- Default target for most commands: `$SENTRY_ORG/$SENTRY_PROJECT`

## Key commands

```bash
# List unresolved issues
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10

# View a specific issue
sentry issue view INVEST-5PY

# Get latest event (stack trace + breadcrumbs)
sentry issue events INVEST-5PY

# AI root cause analysis (Seer)
sentry issue explain INVEST-5PY

# AI fix plan
sentry issue plan INVEST-5PY

# Resolve / unresolve / archive
sentry issue resolve INVEST-5PY
sentry issue unresolve INVEST-5PY
sentry issue archive INVEST-5PY

# Merge duplicate issues
sentry issue merge INVEST-5PY INVEST-4SR

# List projects
sentry project list $SENTRY_ORG/

# Releases
sentry release list $SENTRY_ORG/$SENTRY_PROJECT --limit 5

# Traces and spans
sentry trace list $SENTRY_ORG/$SENTRY_PROJECT --period 1h
sentry trace view <trace-id>
sentry span list <trace-id>

# Logs
sentry log list $SENTRY_ORG/$SENTRY_PROJECT --period 1h

# Explore (aggregate queries)
sentry explore $SENTRY_ORG/$SENTRY_PROJECT --query count --period 24h

# Dashboards
sentry dashboard list $SENTRY_ORG/
sentry dashboard view $SENTRY_ORG/<dashboard-id>

# Raw API access (for anything the CLI doesn't cover)
sentry api /api/0/organizations/$SENTRY_ORG/issues/ --method GET

# Browse API schema
sentry schema issues
```

## Query syntax (for --query flag on issue list)

| Query | Meaning |
|-------|---------|
| `is:unresolved` | Open issues |
| `is:resolved` | Closed issues |
| `assigned:me` / `assigned:<email>` | Assignment filter |
| `release:<version>` | Specific release |
| `environment:production` | Production only |
| `firstSeen:-24h` | Seen in the last 24h |
| `error.type:TypeError` | By exception class |

Combine with spaces (AND): `is:unresolved firstSeen:-7d`.

## Tips

- Use `--json` for machine-readable output, pipe through `jq`
- Use `--fields` to select specific fields and reduce output
- Use `-w` / `--web` to open in browser
- Use `--period` / `-t` for time filtering (e.g. `1h`, `24h`, `7d`)
- The CLI auto-detects org/project from env/DSN, but always pass `$SENTRY_ORG/<project>` explicitly for reliability
- Short IDs like `INVEST-5PY` work as issue identifiers everywhere
- `sentry schema <resource>` to discover API endpoints without third-party docs

## Common playbooks

**"What's crashing?"**
```bash
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10
```

**"Debug a specific issue"**
```bash
sentry issue view INVEST-XXX
sentry issue events INVEST-XXX
sentry issue explain INVEST-XXX
sentry issue plan INVEST-XXX
```

**"Which release introduced this?"**
```bash
sentry issue view INVEST-XXX --json | jq '.firstRelease'
sentry release list $SENTRY_ORG/$SENTRY_PROJECT --limit 5
```

## Legacy

The old curl-based `scripts/sentry.sh` wrapper still exists in the skill directory but is deprecated. Use the `sentry` CLI for everything.
