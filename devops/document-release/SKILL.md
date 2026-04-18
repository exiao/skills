---
name: document-release
description: Update all project documentation to match what was just shipped. Use after merging a PR or shipping a feature to catch stale READMEs and drifted docs.
---
# Document Release

Update all project documentation to match what was just shipped. Catches stale READMEs, outdated file paths, wrong command references, and drifted project structure.

Use when: a PR is ready or just merged, after shipping a feature, or anytime docs might be out of sync with code.

## How It Works

### Step 1: Identify the Diff

Read the git diff to understand what changed:

```bash
git diff main --stat
git diff main --name-only
```

If on main, diff against the last tag or recent commits:

```bash
git log --oneline -20
git diff HEAD~5 --name-only
```

### Step 2: Find All Documentation Files

Scan the repo for documentation:

```bash
find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" | head -50
```

Common targets:
- `README.md` (root and subdirectories)
- `CLAUDE.md` / `AGENTS.md` / `GEMINI.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `TODOS.md` / `TODO.md`
- `docs/` directory
- `API.md` or `api/` docs
- `.github/` templates

### Step 3: Cross-Reference

For each documentation file, check against the diff:

| Check | What to look for |
|-------|-----------------|
| **File paths** | Does the doc reference files that were moved, renamed, or deleted? |
| **Command lists** | Do CLI docs list commands that were added, removed, or changed? |
| **Project structure** | Do tree diagrams match the actual directory layout? |
| **Feature lists** | Do feature tables include new capabilities? Remove deprecated ones? |
| **Config references** | Do config docs match the actual config schema? |
| **API endpoints** | Do API docs reflect new/changed/removed endpoints? |
| **Install instructions** | Do setup steps still work with the new dependencies? |
| **Screenshots** | Are visual references still accurate? (Flag, don't fix) |
| **Version numbers** | Do version references need bumping? (Ask, don't assume) |
| **Cross-doc consistency** | Do multiple docs agree on the same facts? |

### Step 4: Classify Changes

For each finding:

- **Mechanical** (wrong path, stale count, outdated command) → Fix automatically. These are facts, not opinions.
- **Subjective** (rewording descriptions, changing emphasis, restructuring sections) → Surface as a question. Let the user decide.
- **Version/changelog** → Ask whether to bump and what to write. Never auto-write changelog entries without approval.

### Step 5: Apply and Commit

- One commit for all doc updates: `docs: update documentation for [feature/PR name]`
- If touching many files, group by type: `docs(readme): ...`, `docs(api): ...`
- Show a summary of every change made

## CHANGELOG Rules

If the repo has a `CHANGELOG.md`:
- Add an entry under `## [Unreleased]` (or the appropriate version section)
- Match the existing voice and format exactly
- Never rewrite or "polish" existing entries
- Keep entries factual and concise: what changed, not why

## TODOS / TODO.md Rules

If the repo tracks TODOs:
- Mark completed items based on the diff
- Add new items only if the diff clearly introduces them
- Don't invent TODOs that aren't evidenced by the code

## Output

End with a summary:

```
Documentation updated:
  README.md — updated skill count from 9 to 10, added new skill to table
  CLAUDE.md — added new directory to project structure  
  CONTRIBUTING.md — current, no changes needed
  CHANGELOG.md — added entry for [feature name]
  TODOS.md — marked 2 items complete

Questions for you:
  - VERSION: bump from 1.2.0 to 1.3.0? (new feature)
  - README: rewrite the "Getting Started" section? (still works but could be clearer)
```

## Anti-Patterns

- Don't rewrite docs that are already correct just to "improve" them
- Don't add marketing language or puffery to technical docs
- Don't restructure documentation without asking
- Don't touch files outside the repo (MEMORY.md, TOOLS.md, etc.) unless explicitly asked
- Don't assume version bump strategy. Ask.
