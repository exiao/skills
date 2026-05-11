# Skills: Claude Code Skill Templates

> Source: [github.com/exiao/skills](https://github.com/exiao/skills) | License: MIT

A collection of 300+ prompt-template skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Hermes Agent](https://github.com/NousResearch/hermes-agent), and other skill-aware agents.

Skills are folders with a `SKILL.md` entry point. Agents load them on demand when a task matches the skill description.

Resources: [Intro](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) | [Free course](https://anthropic.skilljar.com/introduction-to-agent-skills) | [Complete guide](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)

## Installation

Install everything. Open Claude Code and say:

```text
Install the skills from https://github.com/exiao/skills
```

Pick specific categories with the [Interactive Install Guide](INSTALL.md).

Find more skills: [OpenClaw native skills](https://github.com/openclaw/openclaw/tree/main/skills) | [ClawHub](https://clawhub.ai) | [skills.sh](https://skills.sh)

## Browse

The README only lists categories. The full skill index is generated in [CATALOG.md](CATALOG.md).

| Category | Skills | Description |
|---|---:|---|
| [ai-tools](ai-tools/) | 10 | AI agents, MCP integrations, web search, and LLM tooling |
| [app-store](app-store/) | 28 | App Store Connect, ASO, RevenueCat, screenshots, and simulators |
| [coding](coding/) | 29 | Programming, debugging, testing, code review, and PR workflows |
| [creative](creative/) | 49 | Writing, editing, media production, video, and content creation |
| [devops](devops/) | 54 | CI/CD, GitHub workflows, Docker, MLOps, cloud deployment, and infrastructure |
| [external-services](external-services/) | 17 | External service CLIs and API integrations |
| [finance](finance/) | 11 | Investing, market analysis, portfolio management, earnings, and comps |
| [marketing](marketing/) | 39 | Ads, SEO, analytics, social media, content strategy, and growth |
| [media](media/) | 2 | Media content tools |
| [memory](memory/) | 3 | Memory management, setup, garbage collection, and recall |
| [productivity](productivity/) | 17 | Email, notes, Apple apps, smart home, local search, documents, and gaming |
| [research](research/) | 12 | Deep research, competitive analysis, market intelligence, and papers |
| [skills-meta](skills-meta/) | 7 | Skills about creating, auditing, improving, testing, and cleaning up skills |
| [visual-design](visual-design/) | 35 | UI/UX design, diagrams, image generation, frontend design, and design systems |

## Skill structure

Every skill lives inside a category folder:

```text
category/
└── skill-name/
    ├── SKILL.md              # Entry point, required
    ├── references/           # Detailed docs, checklists, examples
    ├── scripts/              # Deterministic code: Python, JS, bash
    └── assets/               # Templates, images, static resources
```

## Full catalog

Generate the full catalog after adding, removing, or renaming skills:

```bash
python scripts/generate_catalog.py
```

This updates [CATALOG.md](CATALOG.md) from `SKILL.md` frontmatter. Do not hand-edit the catalog.

## Contributing

See [CLAUDE.md](CLAUDE.md) for repo conventions, skill authoring rules, and PR expectations.
