# Skills Repo Conventions

This is a public repo of OpenClaw skills. Every directory at root is a **category** containing related skills (except `.github/`).

## Repo Structure

```
category-name/
├── DESCRIPTION.md            # Category description
└── skill-name/
    ├── SKILL.md              # Entry point (required)
    ├── references/           # Detailed docs, checklists, examples
    ├── scripts/              # Deterministic code (Python, JS, bash)
    └── assets/               # Templates, images, static resources
```

## Categories

| Category | What's inside |
|----------|--------------|
| **ai-tools** | AI agents, MCP integrations, web search, LLM tooling |
| **app-store** | App Store tools, RevenueCat, Prometheus, ReelFarm |
| **bloom** | Bloom product-specific skills |
| **coding** | Programming, debugging, testing, code review, web scraping |
| **creative** | Writing, editing, media production, content creation |
| **devops** | CI/CD, GitHub workflows, Docker, MLOps, model training/inference |
| **finance** | Investing, market analysis, portfolio management |
| **hermes** | Runtime internals, patches, skill creation/auditing |
| **marketing** | Ads (Google/Meta/Apple), SEO, analytics, social media |
| **productivity** | Apple apps, email, notes, smart home, local search, gaming |
| **research** | Deep research, competitive analysis, market intelligence |
| **visual-design** | UI/UX design, diagrams, image generation, frontend design |

## Skill Conventions

- `SKILL.md` must have YAML frontmatter with `name` and `description`.
- `description` is a routing instruction for the model, not a human summary. Include trigger phrases.
- Keep `SKILL.md` under 500 lines. Move details to `references/`.
- No README.md, CHANGELOG.md, or human-facing docs inside skill directories.

## Rules

1. **No hardcoded credentials.** Use `$ENV_VAR_NAME` for tokens, API keys, auth strings, product IDs. This repo is public.
2. **No personal data.** No emails, phone numbers, account balances, or internal URLs.
3. **Update README.md** when adding, removing, or renaming skills. Every skill directory must appear in the README under the correct category.
4. **Use `openclaw` naming** (not `clawdbot`). Config path: `~/.openclaw/openclaw.json`. Metadata key: `openclaw`.
5. **Paths use `~/clawd/skills/`** for workspace references (not `/opt/homebrew/lib/node_modules/`).

## PR Guidelines

- One logical change per PR. Don't stack unrelated changes.
- Branch from `main`. Don't stack branches on other feature branches. Use git worktrees for feature work, placed in `~/.hermes/.worktrees/skills/` (outside the repo to avoid duplicating repo content).
- If CI (claude-review) flags issues, fix them before requesting merge.
- Check all three comment sources for review feedback: inline comments, issue comments, and review verdicts.

## CI

- `claude-code-review.yml` runs on every PR. It checks frontmatter, hardcoded secrets, broken references, and accuracy.
- CI failures from bad credentials (401) are infra issues. Retry the run.
