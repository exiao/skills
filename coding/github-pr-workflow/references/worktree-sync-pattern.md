# Worktree Sync Pattern

Sync uncommitted local changes from a repo's main checkout into a clean worktree branch, then PR. Use when: the main checkout has accumulated dirty changes (modified + untracked files) and you need to PR them without committing directly to main.

## Why This Exists

SOUL.md and many AGENTS.md files mandate: "never work directly in a repo's main checkout." But skills, scripts, and config files often accumulate local edits in the main checkout over time. This pattern bridges that gap.

## Steps

```bash
REPO=~/projects/<repo>
WORKTREE_BASE=~/.hermes/.worktrees/<repo>  # or per AGENTS.md
DATE=$(date +%Y%m%d)
BRANCH="sync-<repo>-$DATE"

cd "$REPO"

# 1. Check for changes
CHANGES=$(git status --porcelain)
if [ -z "$CHANGES" ]; then
  echo "No local changes to sync."
  exit 0
fi

# 2. Pull latest main
git pull origin main --quiet

# 3. Create worktree from origin/main
mkdir -p "$WORKTREE_BASE"
git worktree add "$WORKTREE_BASE/$BRANCH" -b "$BRANCH" origin/main

WTREE="$WORKTREE_BASE/$BRANCH"

# 4. Copy changed files (modified + untracked) into worktree
cd "$REPO"
git status --porcelain | while read -r status file; do
  dir=$(dirname "$file")
  mkdir -p "$WTREE/$dir"
  if [ -f "$file" ]; then
    cp "$file" "$WTREE/$file"
  fi
done

# 5. Commit in worktree
cd "$WTREE"
git add -A

if git diff --cached --quiet; then
  echo "No diff after copy. Cleaning up."
  cd "$REPO"
  git worktree remove "$WTREE" --force 2>/dev/null
  git branch -D "$BRANCH" 2>/dev/null
  exit 0
fi

SUMMARY=$(git diff --cached --stat | tail -1)
git commit -m "sync: daily update ($SUMMARY)"
git push origin "$BRANCH"

# 6. Open PR
gh pr create \
  --title "sync: daily update $(date +%Y-%m-%d)" \
  --body "Automated sync of local changes." \
  --base main
```

## Key Details

- **Worktree location:** Check AGENTS.md for per-repo conventions. Default: `~/projects/_worktrees/<branch>`. The skills repo uses `~/.hermes/.worktrees/skills/`.
- **Deleted files:** The `git status --porcelain` loop only copies files that exist. If a file was deleted locally, it won't appear in the worktree (which is correct for additions/modifications). For explicit deletions, add: `if [ "${status:0:1}" = "D" ] || [ "${status:1:1}" = "D" ]; then git -C "$WTREE" rm "$file"; fi`
- **Branch collision:** If the date-named branch already exists, `git worktree add` fails. The script should exit gracefully (already synced today).
- **Don't clean up:** Per SOUL.md, never remove worktrees or branches after the task unless asked.

## Cron Automation

This pattern pairs well with a daily cron job. Example cron config:
- Schedule: `0 2 * * *` (2am daily)
- Deliver: `signal:<channel>`
- The script lives at `~/.hermes/cron/scripts/sync-<repo>.sh`
- Script exits 0 with "No local changes" when clean, so cron reports are concise.
