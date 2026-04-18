---
name: claude-md-management
description: Use when asked to audit, improve, or maintain CLAUDE.md files across repos. Triggers on "audit my CLAUDE.md", "check if my CLAUDE.md is up to date", capturing session learnings, or keeping project memory current.
---

# CLAUDE.md Management

CLAUDE.md files are the project memory for coding agents. Stale or thin CLAUDE.md = wasted context and repeated mistakes. This skill audits quality and captures learnings.

## Two Workflows

### 1. Audit (`audit my CLAUDE.md`)

Scan a repo's CLAUDE.md files and grade them against quality criteria.

**Steps:**

1. Find all CLAUDE.md and .claude.local.md files in the repo:
   ```
   find <repo-root> -name "CLAUDE.md" -o -name ".claude.local.md" | sort
   ```

2. Read each file.

3. Score each against these criteria:

| Criterion | What to look for | Max |
|-----------|-----------------|-----|
| **Commands** | Build, test, lint, dev commands with exact syntax | 25 |
| **Architecture** | Key modules, patterns, data flow, conventions | 25 |
| **Gotchas** | Known pitfalls, environment quirks, non-obvious behavior | 25 |
| **Conciseness** | No fluff; dense, actionable info; <500 lines | 25 |

4. Generate a report:
   - Score (0-100) and grade (A/B/C/D/F) per file
   - List of gaps found
   - Proposed additions as a diff

5. Show proposed changes. Only write with explicit approval.

**Grade thresholds:** A=90+, B=75+, C=60+, D=45+, F=<45

---

### 2. Capture Learnings (`/revise-claude-md` or "update CLAUDE.md with what we learned")

After a productive session, capture discoveries before they're forgotten.

**Steps:**

1. Review the session for:
   - New bash commands discovered (exact syntax that worked)
   - Code patterns followed or established
   - Environment quirks or setup steps encountered
   - Gotchas hit (and how they were resolved)
   - Architecture clarifications

2. Determine the right file:
   - Repo-wide patterns → `<repo-root>/CLAUDE.md`
   - Local env/personal prefs → `<repo-root>/.claude.local.md`
   - Submodule-specific → `<subdir>/CLAUDE.md`

3. Propose additions as a diff. Don't add noise — only things that will save time next session.

4. Apply only with approval.

---

## What Good CLAUDE.md Looks Like

**High-value entries:**
```markdown
## Commands
- Run tests: `pytest tests/ --create-db -x`  (use --create-db in new worktrees)
- Lint: `ruff check . && mypy bloom/`
- Dev server: `cd frontend && npm run dev`

## Architecture
- API: Django REST Framework. Views in `bloom/api/views/`, serializers in `bloom/api/serializers/`
- Auth: JWT via SimpleJWT. Token refresh handled in middleware.
- Async tasks: Celery workers. Queue: Redis on localhost:6379.

## Gotchas
- Never run migrations in a worktree without --fake-initial on the first run
- Sentry DSN is loaded from env; missing in local = silent failures in error tracking
- iOS simulator must be booted before running UI tests
```

**Low-value (skip these):**
- Generic descriptions ("this project uses React")
- Things obvious from the code
- Instructions that belong in README
- Anything over 2-3 lines that could be a link instead

---

## Tips

- For Bloom repo: check both `~/bloom/CLAUDE.md` and any subdirectory CLAUDE.md files
- `.claude.local.md` is gitignored — use it for machine-specific paths, API keys, personal workflow notes
- After fixing a non-obvious bug, add the gotcha immediately while it's fresh
- Keep commands 100% copy-pasteable — no placeholders unless clearly labeled
