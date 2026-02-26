---
name: fix-bloom-prs
description: Use when fixing CI failures, reviewing code, or squashing Bloom PRs into clean commits.
---

# Fix Bloom PRs

Scan open PRs on Bloom-Invest/bloom for CI failures and review comments, then fix them.

## Workflow

### 1. Scan open PRs (last 24h by default)

```bash
# List open PRs created or updated in the last 72h
gh pr list --repo Bloom-Invest/bloom --state open --json number,title,headRefName,createdAt,updatedAt \
  --jq '[.[] | select(.createdAt > (now - 259200 | strftime("%Y-%m-%dT%H:%M:%SZ")) or .updatedAt > (now - 259200 | strftime("%Y-%m-%dT%H:%M:%SZ")))]'
```

**Note:** By default, only process PRs created in the last 72 hours. If the user asks to check older PRs or specifies a different timeframe, adjust accordingly.

### 2. For each PR needing attention, always fetch the LATEST review comments

Bugbot/Seer comments are tied to specific commits. After pushing a fix, old comments remain but may be stale. Always check:

```bash
# Get latest CI status (reflects most recent commit)
gh pr checks <PR_NUMBER> --repo Bloom-Invest/bloom

# Get ALL review comments (may include stale ones from old commits)
gh api repos/Bloom-Invest/bloom/pulls/<PR_NUMBER>/comments | \
  jq '.[] | {author: .user.login, created: .created_at, path: .path, line: .line, body: .body[0:300]}'

# Get the commit SHA the comment was made on vs current HEAD
gh api repos/Bloom-Invest/bloom/pulls/<PR_NUMBER>/comments | \
  jq '.[] | {author: .user.login, commit: .original_commit_id, body: .body[0:200]}'

# Get current HEAD of the PR
gh pr view <PR_NUMBER> --repo Bloom-Invest/bloom --json headRefOid -q '.headRefOid'
```

**Critical:** Compare `original_commit_id` on each comment against the PR's current HEAD. If they differ, the comment may be stale — verify the issue still exists in the latest code before fixing.

### 3. Fix issues

For each PR with real (non-stale) issues:

1. `cd ~/bloom && git checkout <branch> && git pull origin <branch>`
2. Fix the issues (lint, review feedback, test failures)
3. Run lint: `uv run black <file>` (backend) or check frontend lint
4. Commit with descriptive message referencing what was fixed
5. `git push origin <branch>`

**Spawn sub-agents** for multiple PRs to fix in parallel:
```
sessions_spawn with label "fix-pr-<number>"
```

### 4. Verify after push

After fixing, confirm CI passes on the new commit:
```bash
gh pr checks <PR_NUMBER> --repo Bloom-Invest/bloom
```

## Common fixes

- **Backend Lint** → `uv run black <file>`
- **Frontend Lint** → `cd frontend && bun run lint --fix`
- **Cursor Bugbot** → Read the comment, fix the code, verify with tests
- **Seer** → Similar to Bugbot, usually suggests a fix in the comment
- **claude-review** → Usually informational, fix if actionable

## Excluding PRs

Skip PRs that:
- Were created more than 72 hours ago (unless user explicitly asks for older PRs)
- Have fundamental architecture issues requiring Eric's input
- Are drafts or WIP

Ask Eric before fixing PRs by other authors.

---

# Review PR

Review a Bloom PR with the same criteria as the GitHub Actions `claude-code-review.yml`.

## Inputs

- PR number or URL (ask if not provided)
- Repo defaults to `Bloom-Invest/bloom`

## Setup

Use a worktree for isolated review — never switch branches in the main checkout:

```bash
cd ~/bloom
PR_NUM=<number>
git fetch origin pull/${PR_NUM}/head:pr-${PR_NUM}
git worktree add /tmp/bloom-worktrees/review-${PR_NUM} pr-${PR_NUM}
cd /tmp/bloom-worktrees/review-${PR_NUM}
```

## Review Criteria

**Flag these:**
- Correctness — does it implement the feature spec properly?
- Bugs or logic errors that produce wrong results
- Security risks
- Reliability issues that cause crashes or failures
- Performance or latency issues
- Complexity that makes code actively misleading or error-prone
- Missing test coverage

**Do NOT flag:**
- Style, naming, or structural preferences
- Missing error handling for unlikely multi-condition scenarios
- "This could be slightly better" suggestions
- Linting, formatting, or type annotation issues
- Premature optimizations

## Steps

1. **Read PR metadata and diff:**
   ```bash
   gh pr view ${PR_NUM} --repo Bloom-Invest/bloom --json title,body,files,author,labels
   gh pr diff ${PR_NUM} --repo Bloom-Invest/bloom
   ```

2. **Understand context** — read the changed files in full, not just the diff.

3. **Check CI status:**
   ```bash
   gh pr checks ${PR_NUM} --repo Bloom-Invest/bloom
   ```

4. **Read existing review comments:**
   ```bash
   gh api repos/Bloom-Invest/bloom/pulls/${PR_NUM}/comments | \
     jq '.[] | {author: .user.login, path: .path, line: .line, body: .body[0:300]}'
   gh api repos/Bloom-Invest/bloom/pulls/${PR_NUM}/reviews | \
     jq '.[] | {author: .user.login, state: .state, body: .body[0:500]}'
   ```

5. **Review the code** against the criteria above.

6. **If issues found** — 1-2 sentences each: problem, fix, location.

7. **If no issues** — "LGTM" + one sentence of what you reviewed.

## Auto-fix Policy

**May auto-fix (commit + push):** Clear bugs, typos, null checks, missing imports, simple logic errors, security issues with obvious fixes.

**Do NOT auto-fix:** Behavior clarifications, design decisions, API changes, DB migrations, architecture changes, new dependencies.

## Output

```bash
gh pr comment ${PR_NUM} --repo Bloom-Invest/bloom --body "<review>"
```

## Cleanup

```bash
cd ~/bloom
git worktree remove /tmp/bloom-worktrees/review-${PR_NUM}
git branch -D pr-${PR_NUM} 2>/dev/null
```

---

# Squash PR

Squash all commits into one clean commit, update the PR description, and resolve all review threads.

## Inputs

- PR number or URL (ask if not provided)
- Repo defaults to `Bloom-Invest/bloom`

## Steps

### 1. Gather context

```bash
PR_NUM=<number>
gh pr view ${PR_NUM} --repo Bloom-Invest/bloom --json title,body,headRefName,baseRefName,state,comments,reviews
gh api repos/Bloom-Invest/bloom/pulls/${PR_NUM}/commits --paginate | \
  jq '.[] | {sha: .sha[0:12], message: .commit.message[0:120]}'
gh pr diff ${PR_NUM} --repo Bloom-Invest/bloom --stat
gh api repos/Bloom-Invest/bloom/pulls/${PR_NUM}/comments --paginate | \
  jq '[.[] | select(.body | startswith("_(Addressed") | not) | {author: .user.login, path: .path, line: .line, body: .body[0:300]}]'
gh pr checks ${PR_NUM} --repo Bloom-Invest/bloom
```

### 2. Set up worktree

```bash
cd ~/bloom
git fetch origin pull/${PR_NUM}/head:pr-${PR_NUM}-squash
git worktree add /tmp/bloom-worktrees/squash-${PR_NUM} pr-${PR_NUM}-squash
cd /tmp/bloom-worktrees/squash-${PR_NUM}
```

### 3. Fix unresolved review issues

Read code for any unresolved comments and fix them before squashing. Run tests after.

### 4. Squash commits

```bash
cd /tmp/bloom-worktrees/squash-${PR_NUM}
MERGE_BASE=$(git merge-base master HEAD)
git reset --soft $MERGE_BASE
git commit -m "<type>: <concise title>

<detailed body covering all changes>"
```

**Commit message format:** `feat:`/`fix:`/`refactor:` + summary. Body: organized by file/area, what changed and why, setup instructions if relevant.

### 5. Update PR description

```bash
gh api repos/Bloom-Invest/bloom/pulls/${PR_NUM} -X PATCH \
  -f title="<clean title>" \
  -f body='<comprehensive description>'
```

PR description: summary, changes by area, config tables, setup/run instructions, breaking changes.

### 6. Resolve all review threads

```bash
gh api graphql -f query='{
  repository(owner: "Bloom-Invest", name: "bloom") {
    pullRequest(number: PR_NUM) {
      reviewThreads(first: 100) { nodes { id isResolved } }
    }
  }
}'
gh api graphql -f query='mutation {
  resolveReviewThread(input: {threadId: "THREAD_ID"}) {
    thread { isResolved }
  }
}'
```

### 7. Force push and verify

```bash
git push --force origin pr-${PR_NUM}-squash:BRANCH_NAME
```

### 8. Cleanup

```bash
cd ~/bloom
git worktree remove /tmp/bloom-worktrees/squash-${PR_NUM}
git branch -D pr-${PR_NUM}-squash 2>/dev/null
```

## Common Mistakes

1. **Acting on stale review comments** — Bugbot/Seer comments are tied to specific commits. Always compare `original_commit_id` against the PR's current HEAD before fixing a "comment". If the commit SHA differs, the issue may already be resolved.
2. **Forgetting to resolve review threads** — Fixing the code without marking the GitHub review thread as resolved leaves the PR looking unfinished. Always run the GraphQL mutation to resolve threads after addressing them.
3. **Using `--reuse-db` in new worktrees** — First test run in a fresh worktree must use `--create-db`. `--reuse-db` hangs on new worktrees.
4. **Not cleaning up worktrees** — Leaving worktrees in `/tmp/bloom-worktrees/` causes clutter and can cause git conflicts. Always remove with `git worktree remove` after finishing.
5. **Force pushing to the wrong branch** — Verify `BRANCH_NAME` matches the PR's `headRefName` before `git push --force`. Double-check with `gh pr view`.

## Output

Report: commits squashed, review issues fixed, threads resolved, PR link, CI status.
