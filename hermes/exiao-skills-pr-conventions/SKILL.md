---
name: exiao-skills-pr-conventions
description: Use when contributing a skill to the public exiao/skills GitHub repo. Covers repo layout rules, frontmatter, sanitization (no creds/personal data), README updates, and PR workflow. Trigger on "PR to exiao/skills", "publish this skill", "contribute skill", or any request to push a skill upstream.
---

# exiao/skills PR Conventions

Use when contributing a skill to the public `exiao/skills` GitHub repo. Does not apply to local skill edits.

## Repo structure rules

- Skills live at **repo root**, NOT nested under category subdirs. Example: `sentry-debug/SKILL.md`, not `software-development/sentry-debug/SKILL.md`.
- `README.md` at repo root lists every skill — must be updated with a row for the new skill.
- Standard layout: `<skill>/SKILL.md`, `<skill>/scripts/*.sh`, `<skill>/references/*.md`.

## SKILL.md frontmatter

Use only standard keys:

```yaml
---
name: skill-name
description: One-liner with triggers.
---
```

Do NOT include Hermes-specific keys (`openclaw:`, `hermes:`, `triggers:`). Those belong in local Hermes copies only.

## Sanitization checklist (repo is PUBLIC)

Before pushing, grep for and remove personal data and secrets. Check for:
- Any leftover API tokens (Sentry, GitHub, etc.)
- Personal org names (e.g. getbloom, bloom-frontend-web)
- Personal emails
- Hermes-specific absolute paths — rewrite to `~/clawd/skills/<skill>/`
- Any logic that reads user-local Hermes dotfiles — rely on plain environment variables instead
- No hardcoded org defaults in scripts; make them required vars with a clear error

## PR workflow

1. Clone to `~/projects/skills/` (per user repo-cloning rule).
2. Branch: `add-<skill-name>-skill` or `fix-<skill>`.
3. Copy sanitized skill files.
4. Add row to `README.md` under the right category heading.
5. Test the script end-to-end with a real token before pushing.
6. Commit, push, open PR.
7. **PR body**: write to a file, pass via `gh pr create --body-file body.md`. Shell heredocs get eaten by `gh`.

## Position vs existing skills

Check for overlap before adding. Example: `sentry-debug` (primitive, ad-hoc queries) sits alongside `fix-sentry-issues` (end-to-end scan→PR workflow). Frame the PR to clarify the division.

## Pre-push verification

```bash
bash -n scripts/<skill>.sh                              # syntax
<TOKEN_VAR>=... ./scripts/<skill>.sh <subcommand>       # live
unset <TOKEN_VAR> && ./scripts/<skill>.sh <subcommand>  # clean failure
```

## Precedent

- PR #92 — `sentry-debug` skill added 2026. Followed all rules above.
- Migration note lives in the local Hermes patches directory.
