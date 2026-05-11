# Preserving a Dirty Worktree When Switching Branches (Untracked Conflict)

## Problem

When a branch has both modified tracked files AND untracked files that now exist on main (e.g., after a PR merged the same content), `git stash` + `git checkout main` + `git pull` will fail with:

```
error: The following untracked working tree files would be overwritten by merge:
```

`git stash` only handles tracked modifications and new staged files. Untracked files that conflict with the target branch are not stashed.

## Solution: Commit Everything to a Preservation Branch

```bash
# 1. Create a preservation branch from current position
git checkout -b wip/<original-branch>-preserved

# 2. Add EVERYTHING (tracked changes + untracked files)
git add -A

# 3. Commit with WIP marker
git commit -m "WIP: preserve <original-branch> changes (tracked + untracked)"

# 4. Now switch to main cleanly
git checkout main
git pull origin main
```

## When to Use This vs Stash

| Situation | Use |
|-----------|-----|
| Only tracked modifications | `git stash` is fine |
| Untracked files that don't conflict with target | `git stash -u` works |
| Untracked files that DO exist on target branch | **Commit to preservation branch** |
| Large working tree with 100+ changed files | **Commit to preservation branch** (safer, reviewable) |

## Recovering: Creating a Clean PR from Preserved Work

After preserving, to turn the delta into a PR:

```bash
# 1. Create a fresh branch from main
git worktree add ~/projects/_worktrees/<task> -b <new-branch> origin/main

# 2. Generate a patch of what your preserved branch has that main doesn't
# Exclude local state files that shouldn't be in the repo
git diff origin/main..wip/<preserved-branch> -- ':!.curator_backups' ':!.hub' ':!.usage.json' > /tmp/delta.patch

# 3. Check it applies cleanly
cd ~/projects/_worktrees/<task>
git apply --check /tmp/delta.patch

# 4. Apply, commit, push, PR
git apply /tmp/delta.patch
git add -A
git commit -m "chore: <description>"
git push origin <new-branch>
gh pr create --title "..." --body-file /tmp/pr-body.md
```

## Key Insight

When PR #X merges content that your local branch also has (e.g., a snapshot PR), the delta between your branch and updated main may be small even though the raw file count is large. Always check `git diff --stat origin/main..HEAD` to understand the true scope before deciding how to proceed.

## Pitfall: Merge Conflicts When Both Sides Add the Same File

If the preserved branch and main both added the same file (add/add conflict), `git merge origin/main` will produce many conflicts. Don't merge. Instead:

1. Abort the merge: `git merge --abort`
2. Use the patch approach above (diff against main, apply to fresh worktree)
3. `git apply` will cleanly skip files that are identical and apply only the deltas
