# Skills Repo Conventions

A public repo of skills for Claude Code, [Hermes Agent](https://github.com/NousResearch/hermes-agent), and other skill-aware agents (Codex, OpenClaw). Every directory at root is a **category** containing related skills (except `.github/`).

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
| **app-store** | App Store Connect API, ASO keyword optimization, screenshots, iOS simulators |
| **coding** | PR babysitting, Sentry issue fixes, code simplification, deploy verification, QA dogfooding |
| **design** | UI/UX design, design systems (Impeccable), frontend design, slides, Excalidraw diagrams, brand identity, stickers |
| **external-services** | CLI integrations for third-party APIs (Appfigures, Apple Search Ads, DataForSEO, Firecrawl, Google Ads, Grok, Higgsfield, Meta Ads, Porkbun, Prometheus, Render, Stably, Typefully, etc.) |
| **investing** | Stock research, portfolio analysis, market intelligence (coming soon) |
| **memory** | Memory management — garbage collection, setup, and recall from past sessions |
| **skills-meta** | Creating, auditing, improving skills; MCP port management; prompt optimization |
| **thinking** | Brainstorming, office hours frameworks (YC, Sahil), synthetic user studies, planning, perspective shifts |
| **video** | Character creation, video editing, production (Kling, Sora, Remotion, ElevenLabs), YouTube content, thumbnails |
| **writing** | Copywriting, content strategy, editing, content evaluation, hooks, outlines, positioning, content pipeline, research (last30days) |

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
---
```

Only `name` and `description` are required. No metadata block needed.

## Writing Good Descriptions

The `description` field is the primary routing signal. When a user says "help me with X," the agent picks a skill based on description match. Bad descriptions cause misroutes or skills that never get invoked.

**Do:**
- Start with what the skill does, then when to use it
- Include literal trigger phrases ("Use when: babysit this PR, watch PR, monitor PR")
- Mention the specific tools/CLIs involved ("via the Serper API", "using bloom-cli")
- Be specific about scope boundaries ("For visual execution, use frontend-design instead")

**Don't:**
- Write marketing copy ("A powerful toolkit for...")
- Be vague ("Helps with development tasks")
- Duplicate another skill's trigger phrases

## Cross-Referencing Other Skills or CLIs

When a skill references third-party tools or CLIs, verify the commands actually exist. Common mistakes:

- `bloom quote` → doesn't exist, use `bloom info` (includes price, ratings, peers)
- `bloom peers` → doesn't exist, use `bloom info`
- `bloom ratings` → doesn't exist, use `bloom info`

For bloom CLI command discovery, run `bloom --help` or `bloom <command> --help`. Common commands include: `bloom info`, `bloom price`, `bloom financials`, `bloom screen`, `bloom earnings`, `bloom technicals`, `bloom news`, `bloom sentiment`.

When referencing another skill, use its exact `name` from frontmatter (not folder name or a guess).

## Rules

1. **No hardcoded credentials.** Use `$ENV_VAR_NAME` for tokens, API keys, auth strings, product IDs. This repo is public.
2. **No personal data.** No emails, phone numbers, account balances, or internal URLs.
3. **Update README.md** when adding, removing, or renaming skills.
4. **Don't rename product names.** "Hermes Agent", "OpenClaw", "Claude Code", "Codex" etc. are real product names. Use them as-is in skill content. Don't bulk-rename references to match a metadata convention.
5. **Prefer portable paths.** Use workspace-relative paths or well-known config paths (`~/.hermes/`, `~/.openclaw/`, `~/clawd/`). Avoid paths to personal directories (e.g. `~/Documents/personal/...`).

## PR Guidelines

- One logical change per PR. Don't stack unrelated changes.
- Branch from `main`. Don't stack branches on other feature branches.
- If CI (claude-review) flags issues, fix them before requesting merge.
- Check all three comment sources for review feedback: inline comments, issue comments, and review verdicts.

## CI

`claude-code-review.yml` runs on every PR. It checks:

- Frontmatter validity (name + description present, description is a routing instruction)
- Hardcoded secrets or personal data
- Broken internal references (referenced files that don't exist)
- Accuracy of CLI commands and tool references
- Scope and coherence (does the PR do one thing?)

CI failures from bad credentials (401) are infra issues — retry the run, don't change code.

The reviewer posts as `github-actions[bot]`. It may request changes. Fix real issues; dismiss stale reviews after fixing.
