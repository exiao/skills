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
  gh pr list --repo "$REPO" --author "$GH_USER" --state open --json number,title,headRefName
done
```

Tracked repos: $BLOOM_REPO, $INVESTING_LOG_REPO, $SKILLS_REPO. Add $OPS_CENTER_REPO or other repos if they have open PRs.

If no output: no PRs need attention. Reply NO_REPLY.

## Step 2: Triage (do this yourself, do NOT spawn sub-agents yet)

For each PR, gather context. **Batch queries per repo** to minimize tool calls:

```bash
for PR in <list of PR numbers>; do
  echo "=== PR #$PR ==="
  gh pr checks $PR --repo <repo> 2>&1 | head -20
  echo "---REVIEW---"
  gh pr view $PR --repo <repo> --json reviewDecision,mergeable,statusCheckRollup --jq '{reviewDecision,mergeable,checks: [.statusCheckRollup[]? | {name: .name, conclusion: .conclusion}]}'
  echo "---FILES---"
  gh pr diff $PR --repo <repo> --name-only 2>&1 | head -30
  echo "---COMMITS---"
  gh api "repos/<repo>/pulls/$PR/commits?per_page=100" --jq 'length'
  echo ""
done
```

### Large PR diffs (HTTP 406)

PRs with 300+ files or 20,000+ diff lines will fail `gh pr diff` with HTTP 406. Use instead:
```bash
gh api "repos/OWNER/REPO/pulls/N/files?per_page=100" --paginate --jq '.[].filename'
```

### Scope Check (per PR)

Compare the changed files and commit messages against the PR title and description:

1. Do the files relate to the PR's stated purpose?
2. Are there commits that introduce unrelated work?
3. Is there bulk formatting noise beyond the PR's actual changes?
4. Are multiple distinct features bundled together?

### Classify each PR:

- **CLEAN**: CI green, no unaddressed comments, scope is tight. No action needed. A pending `claude-review` with all other checks green is still CLEAN (it resolves on its own).
- **FIXABLE**: CI failure with identifiable root cause, or unaddressed review comments pointing to real bugs, or merge conflicts with clear resolution. Scope is acceptable.
- **SCOPE_DRIFT**: PR includes changes that don't match its description. Commits touch unrelated files, bundle multiple features, or include unnecessary formatting noise. Do NOT fix. Report what's wrong and recommend how to fix (split PRs, revert commits, etc.).
- **SKIP**: Merge conflicts needing design decisions, architectural issues, or draft/WIP PRs. Note for the report but do NOT fix.

## Step 3: Fix FIXABLE PRs

**Default: fix PRs yourself, sequentially.** This is faster, cheaper, and avoids sub-agent coordination overhead. For each fixable PR:

1. Check if an existing worktree exists for the PR branch (see worktree paths below)
2. **Pull latest first**: `git pull --rebase origin <branch>` — the fix may already be upstream from a prior agent run
3. Read the repo's CLAUDE.md/AGENTS.md first
4. Make the fix, verify, commit, push
5. Dismiss stale CHANGES_REQUESTED reviews after fixing their issues

**Only spawn sub-agents when:** there are 4+ fixable PRs AND they're in different repos (genuinely parallelizable). Use babysit-pr skill for spawned agents. Max 3 sub-agents.

### Resolving Merge Conflicts

Force-push is blocked by the git wrapper. For local fix commits, `git pull --rebase origin <branch>` is fine because it replays your own unpublished work on top of remote. For merge conflicts against `main`, prefer a normal merge commit so review history stays intact:

```bash
cd <worktree>
git fetch origin main
git merge origin/main --no-edit
# If conflicts, resolve them, then:
git add <resolved-files>
git commit --no-edit -m "merge: resolve conflicts with main (<brief description>)"
git push origin <branch>
```

If you accidentally create a messy local rebase state, stop and inspect `git status` before changing history. Do not force-push.

For `GIT_EDITOR` errors in non-interactive shells: use `GIT_EDITOR=true git rebase --continue` or just `git commit -m "..."`.

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

## Responding to "Fix Everything"

After the initial triage report, if user says "fix everything":
- **Blocked PRs** (merge conflicts) → resolve via merge commit (see above)
- **"Should fix" review items** → fix directly (lower priority but actionable)
- **Pre-existing issues** the review noted as "not introduced by this PR" → skip
- **Items requiring human judgment** (architecture, feature decisions) → skip and note

## Gotchas

- **`gh pr diff` does not support `--stat`.** Use `--name-only` for file lists. For full diff stats, use `git diff --stat origin/main...HEAD` inside a worktree.
- **`gh pr diff` HTTP 406 on large PRs.** PRs with 300+ files fail. Use `gh api` paginated files endpoint instead (see Step 2).
- **Force-push is fully blocked.** Even `HERMES_BACKUP_BYPASS=1` does not help for non-backup operations. Never attempt rebase for conflict resolution; always merge.
- **Check if fix already exists.** Always `git pull --rebase` before fixing. If rebase drops your commit as "patch contents already upstream," the fix was already applied. Don't blindly re-fix.
- **`claude-review` pending is not blocking.** If all test/lint checks are green and only `claude-review` is pending, classify as CLEAN.
- **Mergeable UNKNOWN → re-query.** GitHub computes mergeability lazily. UNKNOWN usually resolves to MERGEABLE on a second `gh pr view` call.
- **Scope check is mandatory.** Every PR gets checked for drift, even if CI is green. A green CI on a bloated PR is still a problem.
- **Don't fix scope drift.** Splitting PRs, reverting commits, or removing files from a PR requires human judgment on what belongs where. Always escalate.
- **Sub-agents can over-apply repo rules.** In the skills repo, CI reviewers and sub-agents have renamed product names (e.g. "Hermes Agent" → "openclaw") based on stale AGENTS.md rules. Always review sub-agent diffs before reporting success.
- **Dismiss stale reviews.** GitHub's reviewDecision stays CHANGES_REQUESTED even after fixing all issues unless the blocking reviews are dismissed via GraphQL.
- **Prefer doing the work yourself.** Sub-agents cost latency, tokens, and review overhead. One agent fixing 5 PRs sequentially is usually faster than spawning 5 sub-agents.
- **.gitignore conflicts:** Almost always resolved by keeping entries from both sides. The entries are independent ignore patterns with no ordering sensitivity.