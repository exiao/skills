# Backporting PR Review Fixes to Runtime

When PRs are created FROM a runtime directory (like ~/.hermes/skills), CI reviewers may request changes that get applied to the PR branch but never make it back to the source runtime. This creates drift.

## When to backport

After babysitting PRs that originated from a runtime snapshot:
1. Identify which changes in the PR were review fixes (not original content)
2. Check if those fixes exist in the runtime version
3. Apply missing fixes back to runtime

## Systematic comparison

```bash
SRC=~/projects/_worktrees/<pr-branch>
DST=~/.hermes/skills  # or wherever the runtime lives

# For each file the PR touches:
for f in $(git -C "$SRC" diff --name-only origin/main); do
  RUNTIME="$DST/$f"
  PR_FILE="$SRC/$f"
  
  if [ ! -e "$PR_FILE" ]; then
    echo "DELETED in PR: $f"        # Was removal intentional?
  elif [ ! -e "$RUNTIME" ]; then
    echo "MISSING from runtime: $f" # New file created in PR
  elif ! diff -q "$RUNTIME" "$PR_FILE" >/dev/null 2>&1; then
    LINES=$(diff "$RUNTIME" "$PR_FILE" | grep -c '^[<>]')
    echo "DIFFERS ($LINES lines): $f"
  fi
done
```

## Direction of truth

- Runtime is the source of truth for content that evolves continuously
- PR branch is the source of truth for review fixes (dangling refs, path fixes, missing frontmatter)
- When PR stripped content for public repo sanitization, runtime should keep its fuller version
- When PR added new sections/pitfalls from review feedback, runtime should get those

## Common backport patterns

1. Dangling references removed by reviewer (e.g., related_skills pointing to deleted skill)
2. Hardcoded paths fixed by safety scanner
3. New sections added to address reviewer feedback (e.g., missing frontmatter, new skill sub-sections)
4. Router/index updates when a new sub-skill was added

## What NOT to backport

- README/INSTALL/CATALOG changes (repo-only files)
- Content stripped for public repo sanitization (runtime keeps full private version)
- Renamed files for public consumption (runtime keeps specific names like `click-to-whatsapp-bloombot.md`)
