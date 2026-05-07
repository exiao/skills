# Skills Repo Conventions

A public repo of skills for [Hermes Agent](https://github.com/NousResearch/hermes-agent) and other skill-aware agents (Claude Code, Codex, OpenClaw). Every directory at root is a **category** containing related skills (except `.github/`).

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
| **ai-tools** | AI agents (Claude Code, Codex, OpenCode, Hermes Agent), MCP integrations, web search, LLM tooling |
| **app-store** | App Store Connect, ASO, RevenueCat, screenshots, simulators |
| **coding** | Programming, debugging, testing, code review, PR workflows |
| **creative** | Writing, editing, media production, video (Kling, Seedance, Remotion), content creation |
| **devops** | CI/CD, GitHub workflows, Docker, MLOps, model training/inference, cloud deployment, OCPlatform debugging |
| **external-services** | External service CLIs and API integrations (Porkbun, Appfigures, DataForSEO, Firecrawl, Higgsfield, etc.) |
| **finance** | Investing, market analysis, portfolio management, earnings, comps |
| **marketing** | Ads (Google/Meta/Apple), SEO, analytics, social media, content strategy, last30days research |
| **memory** | Memory management — GC, setup, and recall from past sessions |
| **productivity** | Apple apps, email, notes, smart home, local search, gaming |
| **research** | Deep research, competitive analysis, market intelligence |
| **skills-meta** | Skills about skills — creating, auditing, improving, testing |
| **visual-design** | UI/UX design, diagrams, image generation, frontend design |

## Skill Conventions

- `SKILL.md` must have YAML frontmatter with `name` and `description`.
- `description` is a routing instruction for the model, not a human summary. Include trigger phrases.
- Keep `SKILL.md` under 500 lines. Move details to `references/`.
- No README.md, CHANGELOG.md, or human-facing docs inside skill directories.

## Frontmatter Format

```yaml
---
name: my-skill
description: What this skill does and when to invoke it. Include trigger phrases.
version: 1.0.0
metadata:
  runtime:
    tags: [relevant, tags]
    related_skills: [other-skill]
---
```

The nested metadata key can be either `runtime:` or `openclaw:` (both are valid in this repo). Most skills omit the metadata block entirely, which is fine.

## Rules

1. **No hardcoded credentials.** Use `$ENV_VAR_NAME` for tokens, API keys, auth strings, product IDs. This repo is public.
2. **No personal data.** No emails, phone numbers, account balances, or internal URLs.
3. **Update README.md** when adding, removing, or renaming skills. Every skill directory must appear in the README under the correct category.
4. **Don't rename product names.** "Hermes Agent", "OpenClaw", "Claude Code", "Codex" etc. are real product names. Use them as-is in skill content. Don't bulk-rename references to match a metadata convention.
5. **Prefer portable paths.** Use workspace-relative paths or well-known config paths (`~/.hermes/`, `~/.openclaw/`, `~/clawd/`). Avoid paths to personal directories (e.g. `~/Documents/personal/...`).

## PR Guidelines

- One logical change per PR. Don't stack unrelated changes.
- Branch from `main`. Don't stack branches on other feature branches.
- If CI (claude-review) flags issues, fix them before requesting merge.
- Check all three comment sources for review feedback: inline comments, issue comments, and review verdicts.

## CI

- `claude-code-review.yml` runs on every PR. It checks frontmatter, hardcoded secrets, broken references, and accuracy.
- CI failures from bad credentials (401) are infra issues. Retry the run.
