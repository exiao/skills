# Branch Preservation & CI Auth Patterns

## Preserving Dirty Work When Switching Branches

When a branch has many untracked files that conflict with the target branch (e.g., both branches added the same files), `git stash` won't work because untracked files aren't stashed by default, and even `git stash -u` will fail on the checkout if the target branch has those files tracked.

**Pattern: commit-to-preservation-branch:**
```bash
# 1. Create a preservation branch from current position
git checkout -b wip/<descriptive-name>-preserved

# 2. Add EVERYTHING (tracked modifications + untracked files)
git add -A
git commit -m "WIP: preserve <branch> changes (tracked + untracked)"

# 3. Now you can cleanly switch to main
git checkout main
git pull origin main
```

**Then to apply the delta to a fresh branch from main:**
```bash
# Generate a patch of what the old branch had vs main (excluding local state)
git diff origin/main..wip/<name> -- ':!.local-state/' ':!.curator_backups' ':!.hub' ':!*.json.lock' > /tmp/delta.patch

# Verify it applies cleanly (dry run)
git checkout -b new-branch origin/main
git apply --check /tmp/delta.patch
git apply /tmp/delta.patch
```

This is safer than merge because:
- No conflict markers to resolve
- You can exclude files (local state, caches) from the patch via pathspec
- The patch either applies cleanly or doesn't (no partial merge state)
- `git apply --check` is a dry run that tells you before modifying anything

**When to use:** You have a long-lived local branch with many untracked files, main has diverged significantly (e.g., a large snapshot PR landed), and you want to rebase your delta onto current main without resolving 60+ conflicts.

**Gotcha:** Always exclude local-only state files from the patch (`.curator_backups/`, `.hub/`, `.usage.json`, `*.lock`). These shouldn't go in PRs, especially on public repos.

## CI Auth Failures (claude-review 401)

The claude-review GitHub Action uses a GitHub App token exchange. When it fails with `401 Unauthorized - GitHub App authentication failed`, this is an infra/secrets issue, not a code problem.

**Response pattern:**
1. Retry the run once: `gh run rerun <RUN_ID> --repo <REPO>`
2. If it fails again with the same 401, report as infra blocker
3. Do NOT count this as a code CI failure; other checks (CodeQL, Analyze) passing = PR is functionally green
4. In final report: "claude-review: fail (401 auth infra issue, not code-related). All other CI green."

Per AGENTS.md: "CI failures from bad credentials (401) are infra issues. Retry the run."

## Public Repo Redaction Checklist (for skill cleanup PRs)

When preparing skills for a public repo, scan for:
- Email addresses (grep for `@gmail`, `@promptpm`, personal domains)
- Social handles used as identifiers (not just mentions)
- Hardcoded connection IDs, social set IDs, cron IDs
- Private key filenames (e.g., `AuthKey_XXXXX.p8`)
- Account-specific paths (Google Drive email-based mount paths)

Replace with `$ENV_VAR_NAME` or generic placeholders. The Gemini and Codex automated reviewers will catch these, but fixing proactively saves a review cycle.
