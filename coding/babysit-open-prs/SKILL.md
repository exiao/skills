---
name: babysit-open-prs
description: "Scan all open PRs across tracked repos, triage them, check for scope drift, and fix issues directly (or spawn babysit-pr sub-agents when parallelism helps). Use when: babysit all PRs, check all open PRs, nightly PR review."
---

# Babysit Open PRs

Scan open PRs across tracked repos, triage each one (scope check + CI + reviews), fix what you can, and report results.

## Step 1: Discover Open PRs

```bash
for REPO in $BLOOM_REPO $INVESTING_LOG_REPO $SKILLS_REPO; do
  echo "=== $REPO ==="
  gh pr list --repo "$REPO" --author $GH_USER --state open --json number,title,headRefName
done
```

Tracked repos: $BLOOM_REPO, $INVESTING_LOG_REPO, $SKILLS_REPO. Add $OPS_CENTER_REPO or other repos if they have open PRs.

If no output: no PRs need attention. Reply NO_REPLY.

## Step 2: Triage (do this yourself, do NOT spawn sub-agents yet)

For each PR, gather context:

```bash
# CI and merge status
gh pr view <number> --repo <repo> --json title,body,statusCheckRollup,reviewDecision,headRefName,mergeable,commits

# Check results
gh pr checks <number> --repo <repo>

# Commit count
gh api "repos/<repo>/pulls/<number>/commits?per_page=100" --jq 'length'

# Changed files (for scope check) — NOTE: gh pr diff does NOT support --stat
gh pr diff <number> --repo <repo> --name-only
```

### Scope Check (per PR)

Compare the changed files and commit messages against the PR title and description:

1. Do the files relate to the PR's stated purpose?
2. Are there commits that introduce unrelated work?
3. Is there bulk formatting noise beyond the PR's actual changes?
4. Are multiple distinct features bundled together?

### Classify each PR:

- **CLEAN**: CI green, no unaddressed comments, scope is tight. No action needed.
- **FIXABLE**: CI failure with identifiable root cause, or unaddressed review comments pointing to real bugs, or merge conflicts with clear resolution. Scope is acceptable.
- **SCOPE_DRIFT**: PR includes changes that don't match its description. Commits touch unrelated files, bundle multiple features, or include unnecessary formatting noise. Do NOT fix. Report what's wrong and recommend how to fix (split PRs, revert commits, etc.).
- **SKIP**: Merge conflicts needing design decisions, architectural issues, or draft/WIP PRs. Note for the report but do NOT fix.

## Step 3: Fix FIXABLE PRs

**Default: fix PRs yourself, sequentially.** This is faster, cheaper, and avoids sub-agent coordination overhead. For each fixable PR:

1. Create or use an existing worktree for the PR branch
2. Read the repo's CLAUDE.md/AGENTS.md first
3. Make the fix, verify, commit, push
4. Dismiss stale CHANGES_REQUESTED reviews after fixing their issues

**Only spawn sub-agents when:** there are 4+ fixable PRs AND they're in different repos (genuinely parallelizable). Use babysit-pr skill for spawned agents. Max 3 sub-agents.

### Dismissing Stale Reviews

After fixing issues that triggered CHANGES_REQUESTED, dismiss stale reviews so the PR's reviewDecision clears:

```bash
# Find stale CHANGES_REQUESTED review IDs
gh api graphql -f query='{ repository(owner:"<owner>",name:"<name>") { pullRequest(number:<N>) { reviews(last:20) { nodes { id state author { login } } } } } }' \
  --jq '.data.repository.pullRequest.reviews.nodes[] | select(.state == "CHANGES_REQUESTED") | .id'

# Dismiss each one
gh api graphql -f query='mutation { dismissPullRequestReview(input: {pullRequestReviewId: "<ID>", message: "Issues addressed in latest commit"}) { pullRequestReview { state } } }'
```

### Worktree Paths

Check these locations for existing worktrees before creating new ones:
- `~/projects/_worktrees/<branch-name>`
- `~/projects/<repo-name>` (main checkout)
- `/tmp/<repo>-pr-<N>` (babysit-pr convention)

Create new worktrees at `~/projects/_worktrees/<branch-name>`.

## Step 4: Report

Do NOT send via the message tool. Output the summary as your reply. Cron delivery handles routing.

**Format:**

```
🔧 Nightly PR Babysit — [date]

[For each PR, one of:]

✅ PR #N (repo): title — clean
🔧 PR #N (repo): title — fixed (what was done)
⚠️ PR #N (repo): title — scope drift
   Description says: X
   Actually includes: Y, Z
   Recommendation: split/revert/remove
🚫 PR #N (repo): title — blocked (why)
⏭️ PR #N (repo): title — skipped (why)
```

If all PRs were already clean, keep it brief.

## Gotchas

- **`gh pr diff` does not support `--stat`.** Use `--name-only` for file lists. For full diff stats, use `git diff --stat origin/main...HEAD` inside a worktree.
- **Scope check is mandatory.** Every PR gets checked for drift, even if CI is green. A green CI on a bloated PR is still a problem.
- **Don't fix scope drift.** Splitting PRs, reverting commits, or removing files from a PR requires human judgment on what belongs where. Always escalate.
- **Sub-agents can over-apply repo rules.** In the skills repo, CI reviewers and sub-agents have renamed product names (e.g. "Hermes Agent" → "openclaw") based on stale AGENTS.md rules. Always review sub-agent diffs before reporting success.
- **Dismiss stale reviews.** GitHub's reviewDecision stays CHANGES_REQUESTED even after fixing all issues unless the blocking reviews are dismissed via GraphQL.
- **Prefer doing the work yourself.** Sub-agents cost latency, tokens, and review overhead. One agent fixing 5 PRs sequentially is usually faster than spawning 5 sub-agents.
