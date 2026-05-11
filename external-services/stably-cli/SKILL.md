---
name: stably-cli
preloaded: true
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
| List recent runs | `stably runs list` |
| View run details | `stably runs view <runId>` |
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

Env var precedence (highest to lowest): Stably auth (`STABLY_API_KEY`) > `--env` > `--env-file` > `process.env`

## Inspecting Runs

Use `stably runs` to investigate failures without browser auth (dashboard requires login we can't automate):

```bash
stably runs list                    # recent runs with status
stably runs view <runId>            # details: status, branch, commit, pass/fail/timeout counts, failed test names + errors
```

The run ID is the slug from the dashboard URL (e.g. `ss8xdbaac1rcwm3ikcnkge0u` from `.../history/ss8xdbaac1rcwm3ikcnkge0u`).

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

Run ID resolution: explicit arg > CI env (`GITHUB_RUN_ID`) > `.stably/last-run.json` (24h cache). Requires git repo.

```bash
stably fix           # auto-detect last run
stably fix abc123    # explicit run ID
```

Typical workflow: `stably test` > (failures?) > `stably fix` > `stably test`

**Agent fix workflow (recommended):**
1. `stably runs view <runId>` to understand failures before fixing
2. `git pull origin main` to ensure you're on latest (stably fix edits files in-place)
3. `stably fix <runId>` with 600s+ timeout (can take 10+ min; output is mostly spinner noise)
4. Check `git diff` to see what stably actually changed. The terminal output is too noisy to parse
5. If main was updated since the failing run, stably's edits may conflict. Create a worktree from origin/main, manually apply the relevant changes, and PR from there
6. Review the diff critically: stably sometimes uses brittle selectors (`.nth(5)`, `.first()`) or overly generic `aiAssert`. Prefer explicit selectors (ticker symbols, role+name) over AI-driven assertions when possible

## Long-Running Commands (Important for Agents)

`stably create` and `stably fix` are AI-powered and can take **several minutes**.
- Use `exec` with a long timeout (600s+) or background mode
- All other commands complete in seconds

## Bloom-Specific Setup

Prefer the repo-local CLI if `stably` is not globally installed. Install dependencies first, then call `./node_modules/.bin/stably` directly so verification does not depend on global npm state.

```bash
cd ~/projects/bloom-tests
npm install --no-audit --no-fund
source ~/.hermes/.env
STABLY_API_KEY=$STABLY_API_KEY \
STABLY_PROJECT_ID=$STABLY_PROJECT_ID \
BASE_URL=https://bloom.onrender.com \
./node_modules/.bin/stably test
```

To fix after a failing run:
```bash
source ~/.hermes/.env
STABLY_API_KEY=$STABLY_API_KEY STABLY_PROJECT_ID=$STABLY_PROJECT_ID ./node_modules/.bin/stably fix
```

If a test run URL is produced but `stably runs view` fails because `stably` is not on PATH, use the local binary:

```bash
source ~/.hermes/.env
STABLY_API_KEY=$STABLY_API_KEY STABLY_PROJECT_ID=$STABLY_PROJECT_ID \
./node_modules/.bin/stably runs view <runId>
```

## Playwright Pitfalls

**`isVisible({ timeout })` does NOT wait.** Playwright's `locator.isVisible()` returns immediately regardless of any timeout option passed. The timeout is silently ignored. To wait for an optional element, use `locator.waitFor({ state: 'visible', timeout: 3000 })` inside a try/catch. This is the #1 cause of race conditions in modal dismissal guards.

```ts
// WRONG — returns immediately, modal may not have rendered yet
if (await modal.isVisible({ timeout: 3000 })) { ... }

// RIGHT — actually waits up to 3s for the element
try {
  await modal.waitFor({ state: 'visible', timeout: 3000 });
  await page.keyboard.press('Escape');
  try {
    await modal.waitFor({ state: 'hidden', timeout: 1000 });
  } catch {
    await modal.locator('..').locator('button').first().click({ force: true });
  }
} catch {
  // Modal never appeared — nothing to do
}
```

**Strict mode violations with `getByRole('button')`.** If a row or container has multiple buttons, `getByRole('button')` without `.first()` or a name filter throws a strict mode error. Always scope: `.getByRole('button').first()` or `.getByRole('button', { name: 'Bookmark' })`.

**afterAll cleanup is mandatory for state-mutating tests.** Tests that bookmark stocks, create portfolios, or modify user state MUST have an `afterAll` hook to undo those changes. Watchlist/bookmark state persists across runs and causes cascading failures in other tests. Pattern:

```ts
test.afterAll(async ({ browser }) => {
  const page = await browser.newPage();
  try {
    // Navigate and undo state changes
  } catch {
    // Cleanup target doesn't exist — nothing to do
  } finally {
    await page.close();
  }
});
```

## Bloom Test Failure Patterns

Common failure modes in bloom-tests and fixes:

**Feedback Modal Overlay:** A "Bloom experience" feedback modal overlays form elements (portfolio creation, edit flows), causing timeouts. Dismiss early using the waitFor pattern above with `page.getByRole('heading', { name: /Bloom experience/i })`.

**Company Name vs Ticker Selectors:** Bloom UI renders ticker symbols (GOOGL, MSFT) as link text, not company names. Use `{ name: /GOOGL/ }` not `{ name: 'Alphabet' }`.

**agent.act() Failures:** Replace with explicit Playwright selectors when possible. Reserve `agent.act()` for genuinely dynamic interactions where the exact selector isn't predictable.

**Search/Algolia Flakiness:** Avoid making critical Bloom QA flows depend on live search results when the same state can be reached through deterministic in-app navigation. In Stably/headless runs, stock search for `AAPL` has returned ETF-like results (`AAPW`, `AAPY`, `AAPD`) or hung before `Apple Inc` appeared. Prefer direct collection pages, ticker rows, or “Copy collection to portfolio” flows when testing portfolio mechanics. See `references/bloom-search-and-collections-flakiness.md` for a concrete repro and refactor pattern.

**Back Button Fragility:** `.getByRole('button').first()` is brittle. Use name or aria-label selectors instead.

## Required Env Vars

```bash
STABLY_API_KEY=<your-stably-api-key>
STABLY_PROJECT_ID=<your-stably-project-id>
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
| Dashboard URL but no browser auth | Use `stably runs view <runId>` via CLI instead |

## Links

- Docs: https://docs.stably.ai
- CLI Quickstart: https://docs.stably.ai/stably2/cli-quickstart
- Dashboard: https://app.stably.ai
- API Keys: https://auth.stably.ai/org/api_keys/
