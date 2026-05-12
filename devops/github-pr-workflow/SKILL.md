---
name: github-pr-workflow
description: Full pull request lifecycle — create branches, commit changes, open PRs, monitor CI status, auto-fix failures, and merge. Works with gh CLI or falls back to git + GitHub REST API via curl.
version: 1.1.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [GitHub, Pull-Requests, CI/CD, Git, Automation, Merge]
    related_skills: [github-auth, github-code-review]
---

# GitHub Pull Request Workflow

Complete guide for managing the PR lifecycle. Each section shows the `gh` way first, then the `git` + `curl` fallback for machines without `gh`.

## Prerequisites

- Authenticated with GitHub (see `github-auth` skill)
- Inside a git repository with a GitHub remote

### Quick Auth Detection

```bash
# Determine which method to use throughout this workflow
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  AUTH="gh"
else
  AUTH="git"
  # Ensure we have a token for API calls
  if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ~/.hermes/.env ] && grep -q "^GITHUB_TOKEN=" ~/.hermes/.env; then
      GITHUB_TOKEN=$(grep "^GITHUB_TOKEN=" ~/.hermes/.env | head -1 | cut -d= -f2 | tr -d '\n\r')
    elif grep -q "github.com" ~/.git-credentials 2>/dev/null; then
      GITHUB_TOKEN=$(grep "github.com" ~/.git-credentials 2>/dev/null | head -1 | sed 's|https://[^:]*:\([^@]*\)@.*|\1|')
    fi
  fi
fi
echo "Using: $AUTH"
```

### Extracting Owner/Repo from the Git Remote

Many `curl` commands need `owner/repo`. Extract it from the git remote:

```bash
# Works for both HTTPS and SSH remote URLs
REMOTE_URL=$(git remote get-url origin)
OWNER_REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]||; s|\.git$||')
OWNER=$(echo "$OWNER_REPO" | cut -d/ -f1)
REPO=$(echo "$OWNER_REPO" | cut -d/ -f2)
echo "Owner: $OWNER, Repo: $REPO"
```

---

## 1. Branch Creation

This part is pure `git` — identical either way:

```bash
# Make sure you're up to date
git fetch origin
git checkout main && git pull origin main

# Create and switch to a new branch
git checkout -b feat/add-user-authentication
```

Branch naming conventions:
- `feat/description` — new features
- `fix/description` — bug fixes
- `refactor/description` — code restructuring
- `docs/description` — documentation
- `ci/description` — CI/CD changes

## 2. Making Commits

Use the agent's file tools (`write_file`, `patch`) to make changes, then commit:

```bash
# Stage specific files
git add src/auth.py src/models/user.py tests/test_auth.py

# Commit with a conventional commit message
git commit -m "feat: add JWT-based user authentication

- Add login/register endpoints
- Add User model with password hashing
- Add auth middleware for protected routes
- Add unit tests for auth flow"
```

Commit message format (Conventional Commits):
```
type(scope): short description

Longer explanation if needed. Wrap at 72 characters.
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `ci`, `chore`, `perf`

## 3. Pushing and Creating a PR

### Push the Branch (same either way)

```bash
git push -u origin HEAD
```

### Create the PR

**With gh:**

Run `gh pr create` from inside the repository or worktree. `gh pr create` does not support `-C`; use the shell/tool `workdir` instead.

Always write markdown PR bodies to a file and pass `--body-file` to avoid shell quoting bugs:

```bash
cat > /tmp/pr-body.md << 'EOF'
## Summary
- Adds login and register API endpoints
- Adds JWT token generation and validation

## Test Plan
- [ ] Unit tests pass

Closes #42
EOF

gh pr create \
  --title "feat: add JWT-based user authentication" \
  --body-file /tmp/pr-body.md
```

Options: `--draft`, `--reviewer user1,user2`, `--label "enhancement"`, `--base develop`

**With git + curl:**

```bash
BRANCH=$(git branch --show-current)

curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$OWNER/$REPO/pulls \
  -d "{
    \"title\": \"feat: add JWT-based user authentication\",
    \"body\": \"## Summary\nAdds login and register API endpoints.\n\nCloses #42\",
    \"head\": \"$BRANCH\",
    \"base\": \"main\"
  }"
```

The response JSON includes the PR `number` — save it for later commands.

To create as a draft, add `"draft": true` to the JSON body.

## 4. Monitoring CI Status

### Check CI Status

**With gh:**

```bash
# One-shot check
gh pr checks

# Watch until all checks finish (polls every 10s)
gh pr checks --watch
```

**With git + curl:**

```bash
# Get the latest commit SHA on the current branch
SHA=$(git rev-parse HEAD)

# Query the combined status
curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/commits/$SHA/status \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Overall: {data['state']}\")
for s in data.get('statuses', []):
    print(f\"  {s['context']}: {s['state']} - {s.get('description', '')}\")"

# Also check GitHub Actions check runs (separate endpoint)
curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/commits/$SHA/check-runs \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
for cr in data.get('check_runs', []):
    print(f\"  {cr['name']}: {cr['status']} / {cr['conclusion'] or 'pending'}\")"
```

### Poll Until Complete (git + curl)

```bash
# Simple polling loop — check every 30 seconds, up to 10 minutes
SHA=$(git rev-parse HEAD)
for i in $(seq 1 20); do
  STATUS=$(curl -s \
    -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$OWNER/$REPO/commits/$SHA/status \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['state'])")
  echo "Check $i: $STATUS"
  if [ "$STATUS" = "success" ] || [ "$STATUS" = "failure" ] || [ "$STATUS" = "error" ]; then
    break
  fi
  sleep 30
done
```

## 5. Auto-Fixing CI Failures

When CI fails, diagnose and fix. This loop works with either auth method.

### Step 1: Get Failure Details

**With gh:**

```bash
# List recent workflow runs on this branch
gh run list --branch $(git branch --show-current) --limit 5

# View failed logs
gh run view <RUN_ID> --log-failed
```

**With git + curl:**

```bash
BRANCH=$(git branch --show-current)

# List workflow runs on this branch
curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs?branch=$BRANCH&per_page=5" \
  | python3 -c "
import sys, json
runs = json.load(sys.stdin)['workflow_runs']
for r in runs:
    print(f\"Run {r['id']}: {r['name']} - {r['conclusion'] or r['status']}\")"

# Get failed job logs (download as zip, extract, read)
RUN_ID=<run_id>
curl -s -L \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/actions/runs/$RUN_ID/logs \
  -o /tmp/ci-logs.zip
cd /tmp && unzip -o ci-logs.zip -d ci-logs && cat ci-logs/*.txt
```

### Step 2: Fix and Push

After identifying the issue, use file tools (`patch`, `write_file`) to fix it:

```bash
git add <fixed_files>
git commit -m "fix: resolve CI failure in <check_name>"
git push
```

### Step 3: Verify

Re-check CI status using the commands from Section 4 above.

### Auto-Fix Loop Pattern

When asked to auto-fix CI, follow this loop:

1. Check CI status → identify failures
2. Read failure logs → understand the error
3. Use `read_file` + `patch`/`write_file` → fix the code
4. `git add . && git commit -m "fix: ..." && git push`
5. Wait for CI → re-check status
6. Repeat if still failing (up to 3 attempts, then ask the user)

## 6. Merging

**With gh:**

```bash
# Squash merge + delete branch (cleanest for feature branches)
gh pr merge --squash --delete-branch

# Enable auto-merge (merges when all checks pass)
gh pr merge --auto --squash --delete-branch
```

**With git + curl:**

```bash
PR_NUMBER=<number>

# Merge the PR via API (squash)
curl -s -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/merge \
  -d "{
    \"merge_method\": \"squash\",
    \"commit_title\": \"feat: add user authentication (#$PR_NUMBER)\"
  }"

# Delete the remote branch after merge
BRANCH=$(git branch --show-current)
git push origin --delete $BRANCH

# Switch back to main locally
git checkout main && git pull origin main
git branch -d $BRANCH
```

Merge methods: `"merge"` (merge commit), `"squash"`, `"rebase"`

### Enable Auto-Merge (curl)

```bash
# Auto-merge requires the repo to have it enabled in settings.
# This uses the GraphQL API since REST doesn't support auto-merge.
PR_NODE_ID=$(curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['node_id'])")

curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/graphql \
  -d "{\"query\": \"mutation { enablePullRequestAutoMerge(input: {pullRequestId: \\\"$PR_NODE_ID\\\", mergeMethod: SQUASH}) { clientMutationId } }\"}"
```

## 7. Complete Workflow Example

```bash
# 1. Start from clean main
git checkout main && git pull origin main

# 2. Branch
git checkout -b fix/login-redirect-bug

# 3. (Agent makes code changes with file tools)

# 4. Commit
git add src/auth/login.py tests/test_login.py
git commit -m "fix: correct redirect URL after login

Preserves the ?next= parameter instead of always redirecting to /dashboard."

# 5. Push
git push -u origin HEAD

# 6. Create PR (picks gh or curl based on what's available)
# ... (see Section 3)

# 7. Monitor CI (see Section 4)

# 8. Merge when green (see Section 6)
```

## Worktree Sync Pattern

When a repo's main checkout has accumulated uncommitted changes (common with skills, config, scripts), use the worktree sync pattern to PR them cleanly without committing to main directly. See `references/worktree-sync-pattern.md` for the full script and cron setup.

Key idea: create a clean worktree from `origin/main`, copy dirty files from the main checkout into it, commit + push + PR from the worktree.

### Applying a stash to a different worktree

When a stash was created in the main checkout but needs to be PRed cleanly, pipe it into a fresh worktree: `git stash show -p stash@{0} | (cd worktree && git apply --3way -)`. See `references/stash-across-worktrees.md`.

### When stash/checkout fails due to untracked conflicts

If stash/apply or branch switching refuses because untracked files conflict with the target branch, stop working in the dirty checkout. Use the preserve-then-curate worktree pattern in `references/untracked-conflict-preservation.md`.

Key idea: create a fresh worktree from `origin/main`, copy or patch only intentional changes into it, exclude generated runtime state, and stage explicit files after inspecting `git diff --name-status`. For broad snapshot PR curation, also see `references/curating-snapshot-prs.md`.

## Pitfalls

### Never amend/squash a pushed commit when force-push is blocked

If a commit is already pushed and force-push is forbidden (common in fork workflows with merge-protection plugins), you CANNOT `git reset --soft HEAD~1` + re-commit, because the new commit diverges and `git push` will be rejected as non-fast-forward. The fix:

- **Make review fixes as a NEW commit on top**, not by amending the original.
- If you accidentally reset and re-committed, recover with: `git fetch origin <branch> && git reset --soft origin/<branch>` which stages your working-tree changes as a diff on top of the remote's version. Then commit those as a clean follow-up.
- `git pull --rebase` after a divergent reset often causes merge conflicts on the same files. Prefer the `fetch + reset --soft` approach.

### `gh` CLI auth vs non-default remotes

When a repo's remote uses a PAT in the URL (e.g. `https://user:ghp_xxx@github.com/org/repo.git`) or a custom SSH host alias (e.g. `git@github-charles:org/repo.git`), `git push` works but `gh pr create` may fail with "Could not resolve to a Repository" because `gh` uses its own auth store and can't resolve non-standard remote URLs.

Fix: pass the token via `GH_TOKEN` env var and explicitly specify `--repo`:

```bash
GH_TOKEN=ghp_xxx gh pr create --repo org/repo --title "..." --body-file /tmp/pr-body.md
```

Or source it from `.env` if stored there:

```bash
source ~/.hermes/.env
GH_TOKEN=$SOME_ORG_TOKEN gh pr create --repo org/repo ...
```

Common case: CPE Research repos use `github-charles` SSH alias and `CPE_GITHUB_TOKEN`:
```bash
GH_TOKEN=$CPE_GITHUB_TOKEN gh pr create --repo cpe-research/avgo ...
```

### "No common history" when creating a PR

If your feature branch was created independently (e.g. `git init` + push, or orphan branch), `gh pr create` fails with:

```
pull request create failed: GraphQL: The <branch> branch has no history in common with main (createPullRequest)
```

Fix: rebase your branch onto `origin/main` first:

```bash
git fetch origin main
git rebase origin/main
# Resolve conflicts as they come
```

If force-push is blocked after rebase (the rebased branch diverges from the remote), push under a new branch name instead:

```bash
git checkout -b <branch>-v2
git push origin <branch>-v2
gh pr create --base main --head <branch>-v2 --title "..." --body-file /tmp/pr-body.md
```

This avoids the force-push restriction entirely while preserving the clean rebased history.

### PR body with markdown

Never inline markdown in `--body` (shell quoting breaks it). Always write to a temp file and use `--body-file`:

```bash
cat > /tmp/pr-body.md << 'EOF'
## Summary
...
EOF
gh pr create --body-file /tmp/pr-body.md
```

### Public repo PRs: scan for personal data before pushing

When PRing changes that originated from a private/local context into a public repo, always scan before committing:

```bash
# Check for personal emails, handles, internal URLs
git diff --name-only | xargs grep -l '@gmail\|@company\|personal-handle\|internal\.url' 2>/dev/null
# Also check new untracked files
git status --short | grep "^?" | sed 's/^?? //' | xargs grep -rl 'pattern' 2>/dev/null
```

Redact with `sed -i '' 's/personal@email/USER_EMAIL/g'` before committing. The AGENTS.md for public repos typically specifies what must be redacted.

### Review status can be stale after follow-up commits

GitHub keeps old `CHANGES_REQUESTED` reviews in `.reviews[]` even after a later commit receives an approval. Do not stop at `reviewDecision` or the first changes-requested review. Check all comment sources, then interpret review state by chronology:

```bash
gh pr view $PR_NUMBER --json reviews,comments,statusCheckRollup,url \
  -q '{url: .url, checks: [.statusCheckRollup[] | {name: .name, status: .status, conclusion: .conclusion}], reviews: [.reviews[] | {author: .author.login, state: .state, submittedAt: .submittedAt, body: .body}], comments: [.comments[] | {author: .author.login, body: .body}]}'

gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments \
  --jq '.[] | {user: .user.login, path: .path, line: .line, body: .body}'
```

If an older review requested changes and a later review says approved or LGTM after the fix commits, treat the older request as resolved unless there are still unresolved inline comments on the current diff. Mention that stale review history exists rather than claiming the PR is blocked.

### `gh pr edit` silently failing on some repos

On some organization repos (for example `$YOUR_REPO`) `gh pr edit --title` and `gh pr edit --body-file` exit 0 with a stderr warning about "Projects (classic) being deprecated" but the title/body are NOT updated. The underlying GraphQL mutation fails on `repository.pullRequest.projectCards` and the rest of the mutation never runs. You'll only notice if you re-fetch the PR and see the old title.

Workaround: skip `gh pr edit` and patch via REST API directly. This always works:

```bash
gh api -X PATCH /repos/$OWNER/$REPO/pulls/$PR_NUMBER \
  -f title="New title" \
  -F body=@/tmp/pr-body-full.md
```

Notes: `-f` is for plain string fields, `-F` with `@file` reads file contents into the field. Combine both in one call. Verify with `gh pr view $PR_NUMBER --json title,body -q '.title + "\n---\n" + .body'`.

## Useful PR Commands Reference

| Action | gh | git + curl |
|--------|-----|-----------|
| List my PRs | `gh pr list --author @me` | `curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$OWNER/$REPO/pulls?state=open"` |
| View PR diff | `gh pr diff` | `git diff main...HEAD` (local) or `curl -H "Accept: application/vnd.github.diff" ...` |
| Add comment | `gh pr comment N --body "..."` | `curl -X POST .../issues/N/comments -d '{"body":"..."}'` |
| Request review | `gh pr edit N --add-reviewer user` | `curl -X POST .../pulls/N/requested_reviewers -d '{"reviewers":["user"]}'` |
| Close PR | `gh pr close N` | `curl -X PATCH .../pulls/N -d '{"state":"closed"}'` |
| Check out someone's PR | `gh pr checkout N` | `git fetch origin pull/N/head:pr-N && git checkout pr-N` |
