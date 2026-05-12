# Category Reorganization Workflow

Use when the user says the skills repo has too many top-level categories, categories are in the wrong place, or categories should be merged/deleted.

## Bloat detection

A category is bloat if any of the following hold:

1. **Zero skills.** A directory has no `SKILL.md` files anywhere inside it (only DESCRIPTION.md stubs, scripts/, or assets/).
2. **DESCRIPTION-only subdirs.** Subdirectories contain only a DESCRIPTION.md with no actual skills beneath them (e.g. `mlops/evaluation/DESCRIPTION.md` but no skill dir).
3. **Namespace collision.** A category name exists both at root and as a subcategory elsewhere (`last30days/` at root and `marketing/last30days/`).
4. **Missing DESCRIPTION.md.** Categories without DESCRIPTION.md lack self-documentation.
5. **Project-specific content at root.** Categories like `ops-center/`, `reference/`, `yuanbao/` that are not reusable skill classes.

To audit quickly:
```python
import os
root = os.environ.get("REPO_ROOT", ".")
for name in sorted(os.listdir(root)):
    path = os.path.join(root, name)
    if os.path.isdir(path) and not name.startswith("."):
        skill_count = sum(1 for dp, dn, fn in os.walk(path) if "SKILL.md" in fn)
        has_desc = os.path.exists(os.path.join(path, "DESCRIPTION.md"))
        print(f"{name:30s} skills={skill_count} has_desc={has_desc}")
```

## Reorganization playbook

### 1. Decide destination for each category

- **Project-specific skills** (ops-center, reference, fintary, yuanbao) → move to `~/.hermes/skills/internal/` (already gitignored in `.gitignore`).
- **Overlapping category** with few skills (software-development, video-production) → merge skills into the richer existing category (`coding/`, `creative/video-production/`).
- **Empty bloat** (mlops with only DESCRIPTION stubs) → `git rm -r` the entire category.
- **Namespace collision** (last30days at root vs marketing/last30days/) → delete the one with 0 actual skills; the real skill lives under marketing/.

### 2. Always use a worktree

```bash
cd ~/projects/skills
git worktree add ~/projects/_worktrees/skills-reorg -b reorganize-categories origin/main
```

Work in the worktree. Do NOT copy/move files in the main working directory; accidental writes there pollute the runtime checkout.

### 3. Move/merge skills safely

```bash
cd ~/projects/_worktrees/skills-reorg

# Copy (do NOT move) skills into target category
# Use cp -R so the source stays intact until git rm is staged
cp -R software-development/spike coding/

# For project-specific skills, copy to ~/.hermes/skills/internal/
cp -R ops-center/ops-center-codebase-review ~/.hermes/skills/internal/
```

### 4. Remove old categories (git rm, never rm -rf)

```bash
# For tracked directories only
git rm -r ops-center reference yuanbao software-development video-production mlops

# If a directory is untracked (not in git), do NOT use git rm.
# Just remove it with your system's safe delete (trash/rm -d), then rm the empty dir.
```

Pitfall: `git rm` fails if the pathspec doesn't match tracked files. Check first:
```bash
git ls-files --error-unmatch "$dir" >/dev/null 2>&1 && echo tracked || echo untracked
```

### 5. Update README.md categories table

- Remove deleted category rows.
- Update skill counts for merged categories (e.g. coding 23 → 28).
- Keep the table sorted by the actual root directory listing.

### 6. Update README.md sections

Remove whole dead sections and their skill tables. Also remove or update the `## All Skills` subsections that list individual skills from deleted categories.

### 7. Update CLAUDE.md category table

CLAUDE.md usually has a smaller category table near the top. Remove rows for deleted categories there too, or they become stale instructions.

### 8. Stage and verify

```bash
git add coding/ creative/ README.md CLAUDE.md
git status --short
```

Expected: only renames (R), deletions (D), and modifications (M). No `??` untracked additions from the old paths.

### 9. Commit and PR

One logical change per PR. Do not mix skill content edits with category reorganization.
