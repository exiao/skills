---
name: sentry-debug
preloaded: true
description: Use when debugging production errors via Sentry — listing and searching issues, inspecting events and stack traces, checking release distribution, running Seer root-cause analysis, or resolving/assigning issues. Trigger phrases include "sentry", "production error", "what's crashing", "recent crashes", "error in <project>", "resolve sentry issue", "sentry autofix".
---

# Sentry Debug

Uses the official `sentry` CLI (v0.31.0+, installed via cli.sentry.dev). Authenticated via SENTRY_AUTH_TOKEN env var.

## Org context

- Org slug: `$SENTRY_ORG`
- Projects: set `$SENTRY_PROJECT` to the target project slug (for example backend, frontend, updater, bot, or pipeline projects).
- Default target for most commands: `$SENTRY_ORG/$SENTRY_PROJECT`

## Key commands

```bash
# List unresolved issues
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10

# View a specific issue
sentry issue view PROJECT-123

# Get latest event (stack trace + breadcrumbs)
sentry issue events PROJECT-123

# AI root cause analysis (Seer)
sentry issue explain PROJECT-123

# AI fix plan
sentry issue plan PROJECT-123

# Resolve / unresolve / archive
sentry issue resolve PROJECT-123
sentry issue unresolve PROJECT-123
sentry issue archive PROJECT-123

# Merge duplicate issues
sentry issue merge PROJECT-123 PROJECT-456

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
- Short IDs like `PROJECT-123` work as issue identifiers everywhere
- `sentry schema <resource>` to discover API endpoints without third-party docs

## Common playbooks

**"What's crashing?"**
```bash
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10
```

**"Debug a specific issue"**
```bash
sentry issue view PROJECT-XXX
sentry issue events PROJECT-XXX
sentry issue explain PROJECT-XXX
sentry issue plan PROJECT-XXX
```

**"Which release introduced this?"**
```bash
sentry issue view PROJECT-XXX --json | jq '.firstRelease'
sentry release list $SENTRY_ORG/$SENTRY_PROJECT --limit 5
```

## Creating new Sentry projects

Use the REST API via `sentry api`:

```bash
# Create a project (team slug required)
sentry api /api/0/teams/$SENTRY_ORG/$SENTRY_TEAM_SLUG/projects/ --method POST \
  --data '{"name": "my-project", "platform": "python-fastapi"}'

# Get the DSN for the new project
sentry api /api/0/projects/$SENTRY_ORG/my-project/keys/ --method GET
# Look for .dsn.public in the response — that's what goes in sentry_sdk.init(dsn=...)
```

Platform values: `python-django`, `python-fastapi`, `python`, `javascript-react`, `javascript`, etc.

## Adding Sentry to GitHub Actions

For CI/CD pipeline error tracking, use the `getsentry/action-setup-sentry-cli@v2` action (never `curl -sL https://sentry.io/get-cli/ | bash`). Create a composite action that calls `sentry-cli send-event` on failure.

Key pitfall: `if: ${{ failure() }}` on a dependent job does NOT run when upstream jobs are skipped or cancelled. Use `if: ${{ always() && contains(needs.*.result, 'failure') }}` instead.

Another pitfall: `${{ github.job }}` in a `report-failure` job resolves to `"report-failure"`, not the name of the job that actually failed. Don't use it as a tag; `workflow` + `run_id` are sufficient.


## Legacy

The old curl-based `scripts/sentry.sh` wrapper still exists in the skill directory but is deprecated. Use the `sentry` CLI for everything.
