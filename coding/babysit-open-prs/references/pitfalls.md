# Babysit-Open-PRs Pitfalls & Session Learnings

## `pr-preflight.sh` may not exist

The skill references `~/clawd/scripts/pr-preflight.sh`. If it doesn't exist, fall back to manually querying each tracked repo:

```bash
# Scan tracked repos for open PRs by exiao
gh pr list --repo bloom-invest/bloom --author exiao --state open --json number,title,headRefName
gh pr list --repo bloom-invest/investing-log --author exiao --state open --json number,title,headRefName
gh pr list --repo exiao/skills --author exiao --state open --json number,title,headRefName
```

## `gh pr diff --stat` does not exist

Use `gh pr diff <N> --repo <repo> --name-only` instead. The `--stat` flag is not a valid option for `gh pr diff`.

## Dismissing stale CHANGES_REQUESTED reviews

After fixing all issues, GitHub may still show CHANGES_REQUESTED from bot reviews. Dismiss via GraphQL:

```bash
# Find review IDs
gh api graphql -f query='{ repository(owner:"OWNER",name:"REPO") { pullRequest(number:N) { reviews(last:20) { nodes { id state author { login } } } } } }' \
  --jq '.data.repository.pullRequest.reviews.nodes[] | select(.state == "CHANGES_REQUESTED") | "\(.id) \(.author.login)"'

# Dismiss (can batch multiple in one mutation with aliases a:, b:, etc.)
gh api graphql -f query='mutation { dismissPullRequestReview(input: {pullRequestReviewId: "ID", message: "Issues addressed in COMMIT"}) { pullRequestReview { state } } }'
```

## Triage shortcuts

Quick CI/review status without full JSON:
```bash
gh pr view <N> --repo <repo> --json mergeable,reviewDecision,statusCheckRollup | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(f'mergeable={d[\"mergeable\"]} review={d[\"reviewDecision\"]}'); checks=[c for c in d.get('statusCheckRollup',[]) if c.get('conclusion') not in ('SUCCESS','SKIPPED','')]; print(f'failing: {[c[\"name\"] for c in checks]}' if checks else 'CI: all green')"
```

## User preference: do work directly for skills repo

Eric prefers doing PR fixes directly rather than spawning sub-agents for skills repo PRs (markdown-only, quick fixes). Sub-agents are acceptable for larger repos (bloom, investing-log) with code changes that need test verification.

## exiao/skills worktrees

Existing worktrees are frequently at:
- `~/projects/_worktrees/<branch-name>`
- `~/projects/skills/.worktrees/<name>`
- `/private/tmp/skills-pr-<N>`

Check `git -C ~/projects/skills worktree list` before creating new ones.
