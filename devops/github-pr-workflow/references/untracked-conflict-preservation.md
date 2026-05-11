# Preserving Dirty Work When Untracked Files Conflict

## Problem

A branch can have tracked modifications plus untracked files that now exist on `main`, usually after another PR merged overlapping content. In that state, stash/apply or branch switching can fail with:

```
error: The following untracked working tree files would be overwritten by merge:
```

Do not keep working in the dirty runtime checkout. Preserve the content, then curate it in a fresh project worktree.

## Safer pattern: preserve, then curate in a worktree

```bash
# 1. Start from the canonical project checkout, not the runtime checkout
cd ~/projects/<repo>
git fetch origin main

# 2. Create a fresh worktree from main
BRANCH="wip/<descriptive-name>-preserved"
git worktree add ~/projects/_worktrees/$BRANCH -b "$BRANCH" origin/main

# 3. Copy or patch only intentional changes into the worktree
cd ~/projects/_worktrees/$BRANCH
git diff --name-status

# 4. Stage explicit files after inspection
git add path/to/intentional-file.md
git commit -m "WIP: preserve intentional changes"
```

Avoid `git add -A` on a runtime checkout. It can sweep generated state, locks, local reports, or private config into a public PR.

## If a dirty branch already exists

Generate a patch from the preserved branch and exclude generated/runtime state before applying it to a clean worktree:

```bash
git diff origin/main..wip/<preserved-branch> -- \
  ':!.curator_backups' \
  ':!.hub' \
  ':!.usage.json' \
  ':!.usage.json.lock' \
  ':!.curator_state' \
  ':!*.lock' \
  > /tmp/delta.patch

cd ~/projects/_worktrees/$BRANCH
git apply --check /tmp/delta.patch
git apply /tmp/delta.patch
```

Then review before staging:

```bash
git diff --name-status origin/main
git diff --check origin/main
git add path/to/file1 path/to/file2
git commit -m "chore: <description>"
```

## When to use this

| Situation | Use |
|-----------|-----|
| Only tracked modifications in a normal project worktree | A normal commit on a branch |
| Untracked files conflict with the target branch | Preserve/curate pattern above |
| Large working tree with many changed files | Preserve/curate pattern above |
| Runtime checkout has generated files | Fresh project worktree, explicit staging only |

## Key insight

When another PR merges content that your local branch also has, the delta between your preserved branch and updated main may be small even if the raw file count is large. Check `git diff --stat origin/main..HEAD` from the curated worktree before deciding what belongs in the PR.

## Pitfall: merge conflicts when both sides add the same file

If the preserved branch and main both added the same file, `git merge origin/main` may produce add/add conflicts. Prefer the curated patch approach above for snapshot-style PRs. It lets you exclude generated state and reapply only intentional deltas to a clean worktree.
