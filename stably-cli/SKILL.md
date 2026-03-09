---
name: stably-cli
description: Use the Stably CLI to create, run, fix, and maintain Playwright tests in the bloom-tests repo. Use when running tests (stably test), auto-fixing failures (stably fix), or generating new tests from a prompt (stably create).
---

# Stably CLI

Source: https://skills.sh/stablyai/agent-skills/stably-cli

AI-assisted Playwright test management: create, run, fix, and maintain tests via CLI.

## Pre-flight

```bash
stably --version   # verify installed
# If not found: npm install -g stably
```

Requires Node.js 20+, Playwright, and a Stably account.

## Command Reference

| Intent | Command |
|--------|---------|
| Generate test from prompt | `stably create "description"` |
| Generate test from branch diff | `stably create` (no prompt) |
| Run tests | `stably test` |
| Run tests with remote env | `stably --env staging test` |
| Fix failing tests | `stably fix [runId]` |
| Initialize project | `stably init` |
| Install browsers | `stably install [--with-deps]` |
| List remote environments | `stably env list` |
| Inspect env variables | `stably env inspect <name>` |
| Auth | `stably login / logout / whoami` |
| Update CLI | `stably upgrade [--check]` |

**Do NOT run `stably` (no args)** — that's an interactive AI chat for humans only.

## Global Options

| Option | Description |
|--------|-------------|
| `--cwd <path>` / `-C` | Change working directory |
| `--env <name>` | Load vars from remote Stably environment |
| `--env-file <path>` | Load vars from local file (repeatable) |
| `--verbose` / `-v` | Verbose logging |
| `--no-telemetry` | Disable telemetry |

Env var precedence (highest → lowest): Stably auth (`STABLY_API_KEY`) → `--env` → `--env-file` → `process.env`

## Core Commands

### stably create [prompt...]

Generates tests from a prompt or infers from branch diff when no prompt given.

```bash
stably create "test the checkout flow"
stably create              # infer from diff
stably create "test registration" --output ./e2e
```

Prompt tips: be specific about user flows, UI elements, auth requirements, and error states.

### stably test

Runs Playwright tests with Stably reporter. Auto-enables `--trace=on`. All Playwright CLI options pass through:

```bash
stably test --headed --project=chromium --workers=4
stably test --grep="login" tests/login.spec.ts
stably --env staging test --headed
```

### stably fix [runId]

Fixes failing tests using AI analysis of traces, screenshots, logs, and DOM state.

Run ID resolution: explicit arg → CI env (`GITHUB_RUN_ID`) → `.stably/last-run.json` (24h cache). Requires git repo.

```bash
stably fix           # auto-detect last run
stably fix abc123    # explicit run ID
```

Typical workflow: `stably test` → (failures?) → `stably fix` → `stably test`

## Long-Running Commands (Important for Agents)

`stably create` and `stably fix` are AI-powered and can take **several minutes**.
- Use `exec` with a long timeout (600s+) or background mode
- All other commands complete in seconds

## Bloom-Specific Setup

```bash
cd /tmp/bloom-tests-fix   # or wherever the repo is cloned
STABLY_API_KEY=48384c3ddb2c0ab40387decc80e345565b44b1556d232dd357466cf4e4376686c1397a99d5fc3e18a27027018a752163 \
STABLY_PROJECT_ID=cmddjs2fq0000l70473vyhuwf \
BASE_URL=https://bloom.onrender.com \
stably test
```

To fix after a failing run:
```bash
STABLY_API_KEY=... STABLY_PROJECT_ID=... stably fix
```

## Required Env Vars

```bash
STABLY_API_KEY=48384c3ddb2c0ab40387decc80e345565b44b1556d232dd357466cf4e4376686c1397a99d5fc3e18a27027018a752163
STABLY_PROJECT_ID=cmddjs2fq0000l70473vyhuwf
```

## Playwright Config (Reporter Setup)

```ts
import { defineConfig } from '@playwright/test';
import { stablyReporter } from '@stablyai/playwright-test';

export default defineConfig({
  use: { trace: 'on' },
  reporter: [
    ['list'],
    stablyReporter({
      apiKey: process.env.STABLY_API_KEY,
      projectId: process.env.STABLY_PROJECT_ID,
    }),
  ],
});
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Not authenticated" | `stably login` |
| API key not recognized | `stably whoami` to verify |
| Tests in wrong directory | `stably create "..." --output ./tests/e2e` |
| Missing browser | `stably install --with-deps` |
| Traces not uploading | Set `trace: 'on'` in `playwright.config.ts` |
| "Run ID not found" | Run `stably test` first, then `stably fix` |

## Links

- Docs: https://docs.stably.ai
- CLI Quickstart: https://docs.stably.ai/stably2/cli-quickstart
- Dashboard: https://app.stably.ai
- API Keys: https://auth.stably.ai/org/api_keys/
