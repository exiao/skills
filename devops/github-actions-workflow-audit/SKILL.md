---
name: github-actions-workflow-audit
description: "Deep-inspect GitHub Actions workflow chains for correctness and cost: verify trigger names match, workflow_run chains are complete, cron schedules are logical, concurrency groups prevent duplicates, no dead code exists, and expensive jobs are properly gated. Also provides canonical workflow templates for new repos. Use when asked to verify workflows will run, audit CI/CD pipelines, debug why a workflow isn't triggering, validate workflow_run chains, optimize CI costs, or add standard CI/code-review workflows to a repo."
---

# GitHub Actions Workflow Audit

Verify that a repo's GitHub Actions workflows will actually fire correctly and aren't burning money unnecessarily. Catches: mismatched workflow names in `workflow_run` triggers, broken chains, missing cron fallbacks, dead `if: false` steps, duplicate execution risks, and ungated expensive jobs.

## When to Use

- "Will these workflows actually run?"
- "Why isn't my workflow triggering?"
- "Verify the pipeline chain"
- "How expensive is my CI?"
- "Make CI run on demand"
- "Add CI to this repo" / "Add code review workflow"
- After merging workflow changes to confirm correctness
- Debugging silent workflow failures (workflow_run name mismatches produce no error)

## Canonical Workflow Templates

Copy-and-adapt templates for new repos:

- `templates/claude-code-review.yml` — Claude Code Action PR review. Prompt-only (no plugins, no CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS). Includes check-author bot-loop prevention, concurrency per PR number, sticky comments, opus+sonnet fallback, scoped allowed-tools, auto-fix guardrails, and formal `gh pr review` submission. Adapt the `prompt:` section for each repo's domain and review focus areas.
- `templates/ci-python-uv.yml` — Python CI with uv, ruff linting, and pytest. Adapt python-version, ruff target path (`.` vs `src/`), and env vars per repo. Ensure ruff is in the repo's dev/test dependencies in pyproject.toml.
- `references/adding-ci-to-new-repo.md` — Checklist for adding CI to repos that never had a linter. Covers adding ruff as a dependency, fixing common lint errors (F841, F401, E402), per-file-ignores for Typer CLI apps, and committing lint fixes with the CI workflow.

## Audit Steps

### 1. Extract All Workflow Names

```bash
cd <repo>
echo "=== Actual workflow names ==="
grep "^name:" .github/workflows/*.yml | sed 's/.*name: //' | sort -u
```

### 2. Extract All workflow_run References

```bash
echo "=== Referenced names in workflow_run triggers ==="
grep -r "workflows:" .github/workflows/ | grep -v "#" | \
  sed 's/.*workflows: \[//' | sed 's/\]//' | tr ',' '\n' | \
  sed 's/^ *//;s/ *$//' | sed 's/"//g' | sort -u
```

### 3. Cross-Reference (Critical)

Every name in step 2 MUST appear exactly in step 1. A single character mismatch (case, space, punctuation) silently breaks the chain — GitHub won't error, the downstream workflow simply never triggers.

### 4. Map the Chain

For each pipeline, trace: cron/dispatch → Phase 1 → Phase 2 → ... → validate

```bash
for f in .github/workflows/*.yml; do
  name=$(grep "^name:" "$f" | head -1 | sed 's/^name: //')
  triggers=$(sed -n '/^on:/,/^[a-z]/p' "$f" | grep -E "workflows:|cron:|workflow_dispatch" | head -5)
  echo "$name: $triggers"
done
```

### 5. Check Gate Logic

If a workflow waits for multiple upstream workflows (AND gate), verify:
- The gate job checks `listWorkflowRunsForRepo` for today's successful runs
- It correctly identifies the "other" workflow name
- It handles both `workflow_run` and `schedule/dispatch` triggers

### 6. Check for Duplicate Execution Risks

When a workflow has BOTH `workflow_run` AND `schedule` triggers:
- Does it have a dedup guard? (check for existing output files before executing)
- Does `concurrency` group prevent parallel runs?
- Is `cancel-in-progress: false`? (prevents killing a running job when cron fires)

### 7. Check Dead Code

```bash
# if: false or if: "false" — actionlint will flag these
grep -rn 'if:.*"false"\|if:.*false' .github/workflows/

# Steps that reference removed/renamed workflows
# (manually compare dispatch targets against step 1)
```

### 8. Verify Concurrency Groups

```bash
grep -A2 "concurrency:" .github/workflows/*.yml
```

Each pipeline phase should have its own group. `cancel-in-progress: false` for sequential work (queue, don't kill).

### 9. Check Push Retry Patterns in Matrix Jobs

When parallel matrix jobs each commit to their own subdirectory and push to main:

```bash
# Find all push retry loops
grep -B5 -A10 "git rebase origin/main" .github/workflows/*.yml
```

Verify each retry loop cleans the working tree before rebasing. The agent step (Deep Agents, Claude Code, etc.) often writes scratch files outside the committed directory. If those aren't cleaned, `git rebase` fails with "You have unstaged changes" and all retries fail identically.

Correct pattern:
```bash
for i in 1 2 3; do
  git rebase --abort 2>/dev/null || true
  git checkout -- . 2>/dev/null || true
  git clean -fd 2>/dev/null || true
  git fetch origin main
  git rebase origin/main && git push origin main && exit 0
  echo "Push attempt $i failed, retrying..."
  sleep $((i * 2))
done
```

## CI Cost Optimization

When auditing workflows, also assess cost. Expensive jobs (LLM API calls, Claude Code Action, AI evals) should not run on every PR push by default.

### Diagnosing CI Cost

```bash
# List all PR-triggered workflows
grep -l "pull_request" .github/workflows/*.yml

# Find LLM API usage in CI
grep -rl "OPENAI_API_KEY\|ANTHROPIC_API_KEY\|GEMINI_API_KEY\|GROK_API_KEY\|claude-code-action" .github/workflows/

# Count matrix jobs (multiply scenarios x models for total API calls)
grep -A20 "matrix:" .github/workflows/*.yml | grep -E "scenario:|provider:|model:"
```

### Cost Estimation

| Job type | Typical cost per run | Gate by default? |
|----------|---------------------|-----------------|
| Linting, unit tests, actionlint | Free | No |
| Claude Code Action review | $5-15 | Yes |
| LLM eval matrix (N models x M scenarios) | $2-10 per cell | Yes |
| Integration tests (no API) | Free | No |
| Deploy previews | Free-$1 | Usually no |

### Title-Gated Pattern

Gate expensive CI jobs behind PR title tags like `[eval]`, `[review]`.

**Preferred (simple, no outputs needed):** Put the condition directly on the gate job's `if:`. Downstream jobs use `needs:` which auto-skips when the gate is skipped.

```yaml
jobs:
  check-title:
    if: github.event_name == 'workflow_dispatch' || contains(github.event.pull_request.title, '[eval]')
    runs-on: ubuntu-latest
    steps:
      - run: echo "Evals enabled via [eval] tag or manual dispatch"

  expensive-job:
    needs: check-title
    # ... rest of job (auto-skips when check-title is skipped)
```

**Alternative (with explicit outputs):** Use when you need finer control or multiple tags routing to different jobs:

```yaml
jobs:
  check-title:
    runs-on: ubuntu-latest
    outputs:
      should_run: ${{ steps.check.outputs.run }}
    steps:
      - id: check
        run: |
          TITLE="${{ github.event.pull_request.title }}"
          if [[ "$TITLE" == *"[eval]"* ]]; then
            echo "run=true" >> "$GITHUB_OUTPUT"
          else
            echo "run=false" >> "$GITHUB_OUTPUT"
            echo "⏭️ Skipping — add [eval] to PR title to enable"
          fi

  expensive-job:
    needs: check-title
    if: needs.check-title.outputs.should_run == 'true'
    # ... rest of job
```

Key points:
- **CRITICAL: Add `edited` to `pull_request` types.** Default `pull_request` only fires on `opened`, `synchronize`, `reopened`. If someone edits the PR title to add `[eval]`, no new run fires unless you explicitly include `types: [opened, synchronize, reopened, edited]`. Without this, the opt-in mechanism silently fails.
- Keep `workflow_dispatch` ungated so manual triggers always work
- Free jobs (linting, unit tests, actionlint) stay always-on
- Document tags in CLAUDE.md/AGENTS.md so AI agents and humans know the convention
- Common tags: `[eval]` (AI evals), `[review]` (AI code review), `[full-ci]` (everything)
- Path filters remain as belt-and-suspenders with title gating (note: `paths` filters still apply even with `edited` type, but `edited` events don't carry a file diff so the path filter is effectively bypassed on title edits; this is fine since the `check-title` gate handles it)
- When multiple jobs need the same gate (e.g. `agent-eval` and `claude-eval`), each adds `needs: check-title`

## Pitfalls

- **`workflow_run` is name-based, not filename-based.** The `workflows:` array uses the `name:` field value, NOT the .yml filename. Renaming a workflow's `name:` without updating all downstream `workflow_run` references silently breaks the chain.
- **`workflow_run` only fires on default branch.** If the triggering workflow runs on a non-default branch, downstream `workflow_run` listeners won't fire.
- **`gh pr diff --stat` doesn't exist.** Use `--name-only` or the API: `gh api "repos/$REPO/pulls/$PR/files" --jq '.[] | "\(.filename) +\(.additions) -\(.deletions)"'`
- **actionlint catches `if: "false"`** as an error. Remove dead steps entirely or use a dynamic condition instead.
- **GITHUB_TOKEN pushes don't trigger workflow_run.** Pushes from within a GitHub Actions job using the default token are suppressed. Use a PAT or app token if you need cascading triggers from push events.
- **Cron + workflow_run = double execution.** Always add a dedup guard (check if today's output already exists) when both triggers are active.
- **Matrix jobs pushing to main = rebase race.** When parallel matrix jobs (e.g. 3 AI models) each commit to their own subdirectory and push to main, the retry loop `git fetch && git rebase origin/main && git push` fails if the agent left unstaged files in the working tree. `git rebase` refuses with "You have unstaged changes." Fix: add `git checkout -- . 2>/dev/null || true` and `git clean -fd 2>/dev/null || true` before the rebase. Already-committed files are safe; the unstaged junk is scratch from the agent's shell access (temp files, CLI output, etc.). Each matrix job runs on its own runner so there's no cross-contamination; the dirty files come from within the same job's agent step.
- **Shellcheck in actionlint:** `ls | grep` triggers SC2010 (warning level), `ls -t | head` triggers SC2012 (info level). Use `find` with `-printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-` for sorted file lookups, and `shopt -s nullglob; FILES=( glob ); [ ${#FILES[@]} -gt 0 ]` for existence checks.
- **`continue-on-error: true` on eval jobs.** LLM outputs are nondeterministic. Eval failures (like allocation weights summing to 43% instead of 100%) are model quality issues, not code bugs. Use `continue-on-error: true` so they report but don't block PRs.

## Output Format

```
=== WORKFLOW CHAIN: <pipeline name> ===
Phase 1: <workflow> [cron: HH:MM UTC Mon-Fri]
  ↓ workflow_run (name match: ✅/❌)
Phase 2: <workflow> [cron fallback: HH:MM UTC | none ⚠️]
  ↓ workflow_run (name match: ✅/❌, gate: AND/simple)
Phase 3: <workflow> [cron fallback: HH:MM UTC | none ⚠️, dedup: ✅/❌]
  ↓ workflow_run (name match: ✅/❌)
Validate: <workflow>

=== CI COST ESTIMATE ===
Always-on (free): <list>
Gated on [eval]: <list> (~$X per run)
Gated on [review]: <list> (~$X per run)
Estimated savings: $X/PR (assuming Y pushes)

Issues found:
- <issue description>
```