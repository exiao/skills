---
name: github-actions-workflow-audit
description: "Deep-inspect GitHub Actions workflow chains for correctness: verify trigger names match, workflow_run chains are complete, cron schedules are logical, concurrency groups prevent duplicates, and no dead code exists. Use when asked to verify workflows will run, audit CI/CD pipelines, debug why a workflow isn't triggering, or validate workflow_run chains."
---

# GitHub Actions Workflow Audit

Verify that a repo's GitHub Actions workflows will actually fire correctly. Catches: mismatched workflow names in `workflow_run` triggers, broken chains, missing cron fallbacks, dead `if: false` steps, and duplicate execution risks.

## When to Use

- "Will these workflows actually run?"
- "Why isn't my workflow triggering?"
- "Verify the pipeline chain"
- After merging workflow changes to confirm correctness
- Debugging silent workflow failures (workflow_run name mismatches produce no error)

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

## Pitfalls

- **`workflow_run` is name-based, not filename-based.** The `workflows:` array uses the `name:` field value, NOT the .yml filename. Renaming a workflow's `name:` without updating all downstream `workflow_run` references silently breaks the chain.
- **`workflow_run` only fires on default branch.** If the triggering workflow runs on a non-default branch, downstream `workflow_run` listeners won't fire.
- **`gh pr diff --stat` doesn't exist.** Use `--name-only` or the API: `gh api "repos/$REPO/pulls/$PR/files" --jq '.[] | "\(.filename) +\(.additions) -\(.deletions)"'`
- **actionlint catches `if: "false"`** as an error. Remove dead steps entirely or use a dynamic condition instead.
- **GITHUB_TOKEN pushes don't trigger workflow_run.** Pushes from within a GitHub Actions job using the default token are suppressed. Use a PAT or app token if you need cascading triggers from push events.
- **Cron + workflow_run = double execution.** Always add a dedup guard (check if today's output already exists) when both triggers are active.
- **Shellcheck in actionlint:** `ls | grep` triggers SC2010 (warning level), `ls -t | head` triggers SC2012 (info level). Use `find` with `-printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-` for sorted file lookups, and `shopt -s nullglob; FILES=( glob ); [ ${#FILES[@]} -gt 0 ]` for existence checks.

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

Issues found:
- <issue description>
```
