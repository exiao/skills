---
name: render-cli
description: "Manage Render.com services, deploys, databases, logs, and infrastructure using the official Render CLI (`render`). Use this skill whenever the user asks about Render deployments, service management, viewing Render logs, restarting Render services, running database queries on Render Postgres, triggering deploys, managing environments/projects, or anything related to their Render infrastructure. Also use when the user mentions render.com, Render dashboard actions, or wants to automate Render workflows."
---

# Render CLI

Manage Render.com infrastructure from the command line using the official `render` CLI (Go binary, installed via `brew install render`).

Docs: https://render.com/docs/cli
Source: https://github.com/render-oss/cli

## Prerequisites

- `render` CLI installed (`brew install render`)
- Authenticated via `render login` (browser-based) or `RENDER_API_KEY` env var
- Active workspace set via `render workspace set`

## Non-Interactive Mode

AI agents cannot use interactive menus. Always pass `--output json --confirm` (or `-o json --confirm`) to every command. This disables prompts and returns structured output.

```bash
render <command> -o json --confirm
```

Output formats: `json`, `yaml`, `text`. Use `json` for parsing, `text` for human-readable.

## Commands

### Services

```bash
# List all services in active workspace
render services -o json --confirm

# Filter by environment
render services -e env-abc123 -o json --confirm

# Include preview environments
render services --include-previews -o json --confirm

# List instances for a service
render services instances <SERVICE_ID> -o json --confirm

# Create a service
render services create --name my-api --type web_service --repo https://github.com/org/repo -o json --confirm

# Clone from existing service
render services create --from srv-abc123 --name my-api-clone -o json --confirm

# Update a service
render services update <SERVICE_ID> -o json --confirm
```

Service types for `--type`: `web_service`, `static_site`, `private_service`, `background_worker`, `cron_job`.

### Deploys

```bash
# List deploys
render deploys list <SERVICE_ID> -o json --confirm

# Trigger a deploy
render deploys create <SERVICE_ID> -o json --confirm

# Deploy specific commit
render deploys create <SERVICE_ID> --commit <SHA> -o json --confirm

# Deploy specific Docker image
render deploys create <SERVICE_ID> --image <URL> -o json --confirm

# Deploy and wait for completion (non-zero exit on failure)
render deploys create <SERVICE_ID> --wait -o json --confirm

# Clear build cache before deploying
render deploys create <SERVICE_ID> --clear-cache -o json --confirm

# Cancel a running deploy
render deploys cancel <SERVICE_ID> -o json --confirm
```

### Restart

```bash
render restart <SERVICE_ID> -o json --confirm
```

### Logs

```bash
# Basic log fetch
render logs -r <SERVICE_ID> -o json --confirm

# Filter by time range
render logs -r <SERVICE_ID> --start "2026-04-01T00:00:00Z" --end "2026-04-02T00:00:00Z" -o json --confirm

# Filter by log level
render logs -r <SERVICE_ID> --level error -o json --confirm

# Filter by text search
render logs -r <SERVICE_ID> --text "connection refused" -o json --confirm

# Filter by HTTP status code
render logs -r <SERVICE_ID> --status-code 500,502 -o json --confirm

# Filter by HTTP method and path
render logs -r <SERVICE_ID> --method POST --path "/api/webhook" -o json --confirm

# Limit number of results
render logs -r <SERVICE_ID> --limit 50 -o json --confirm

# Multiple resources at once
render logs -r <SERVICE_ID_1>,<SERVICE_ID_2> -o json --confirm

# Tail/stream logs (interactive only, won't work in automation)
render logs -r <SERVICE_ID> --tail
```

The `-r` / `--resources` flag is required in non-interactive mode.

### Database Sessions

```bash
# Open psql session (interactive)
render psql <DATABASE_ID>

# Run a single query
render psql <DATABASE_ID> -c "SELECT NOW();" -o text --confirm

# Query as JSON
render psql <DATABASE_ID> -c "SELECT id, name FROM users LIMIT 5;" -o json --confirm

# CSV output via psql passthrough
render psql <DATABASE_ID> -c "SELECT id, email FROM users;" -o text --confirm -- --csv

# Open redis/valkey CLI
render kv-cli <KV_ID>
```

### SSH

```bash
# SSH into running instance
render ssh <SERVICE_ID>

# Ephemeral shell (isolated, no start command)
render ssh <SERVICE_ID> --ephemeral

# Pass args to ssh
render ssh <SERVICE_ID> -- -L 8080:localhost:8080
```

### One-Off Jobs

```bash
# List jobs for a service
render jobs list <SERVICE_ID> -o json --confirm

# Create a job
render jobs create <SERVICE_ID> --start-command "python manage.py migrate" -o json --confirm

# Cancel a running job
render jobs cancel <SERVICE_ID> -o json --confirm
```

### Projects & Environments

```bash
# List projects
render projects -o json --confirm

# List environments for a project
render environments <PROJECT_ID> -o json --confirm
```

### Workspaces

```bash
# List workspaces
render workspaces -o json --confirm

# Set active workspace
render workspace set

# Show current user/workspace
render whoami -o json --confirm
```

### Blueprints

```bash
# Validate render.yaml
render blueprints validate ./render.yaml -o json --confirm
```

### Workflows

```bash
# List workflows
render workflows list -o json --confirm

# List workflow versions
render workflows versions <WORKFLOW_ID> -o json --confirm

# List workflow tasks
render workflows tasks <WORKFLOW_ID> -o json --confirm

# View task runs
render workflows runs <WORKFLOW_ID> -o json --confirm
```

### Agent Skills

```bash
# List installed Render agent skills
render skills list -o json --confirm

# Install skills for coding tools
render skills install -o json --confirm

# Update installed skills
render skills update -o json --confirm

# Remove installed skills
render skills remove -o json --confirm
```

## Authentication

Two methods:

1. **CLI token** (interactive login): `render login` opens browser, generates token saved to `~/.render/cli.yaml`. Tokens expire periodically.

2. **API key** (automation/CI): Set `RENDER_API_KEY` env var. Keys don't expire. Takes precedence over CLI tokens.

```bash
export RENDER_API_KEY=rnd_xxxYourKeyHerexxx
```

## Multi-Workspace Setup

To switch between workspaces (e.g., team-staging vs team-production), set `RENDER_API_KEY` per-command:

```bash
# Staging workspace
RENDER_API_KEY=rnd_xxxStagingKeyxxx render services -o json --confirm

# Production workspace
RENDER_API_KEY=rnd_xxxProductionKeyxxx render services -o json --confirm
```

Or set the active workspace once and use the default key:

```bash
render workspace set <WORKSPACE_ID> -o json --confirm
```

The workspace persists in `~/.render/cli.yaml` across commands.

## Common Patterns

### Deploy and verify

```bash
# Trigger deploy, wait for it, check exit code
render deploys create <SERVICE_ID> --wait -o json --confirm
echo "Exit code: $?"
```

### Check recent errors

```bash
render logs -r <SERVICE_ID> --level error --limit 50 -o json --confirm
```

### List all services with their status

```bash
render services -o json --confirm | jq '.[] | {id, name: .service.name, type: .service.type, status: .service.suspended}'
```
