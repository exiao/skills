# Eric's Skills — 90+ Claude Code Skill Templates

> **Source:** [github.com/exiao/skills](https://github.com/exiao/skills) | **License:** MIT

A battle-tested collection of **90+ prompt-template skills** for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) spanning content, marketing, design, development, investing, growth, and infrastructure.

> **Skills are prompt templates that Claude Code invokes on demand.** Each skill is a folder with a `SKILL.md` file. Resources: [Intro](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) | [Free course](https://anthropic.skilljar.com/introduction-to-agent-skills) | [Complete guide](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)

---

## Installation

**Install everything** — open Claude Code and say:
```
Install the skills from https://github.com/exiao/skills
```

**Pick and choose** — follow the [Interactive Install Guide](INSTALL.md) to select categories.

**Find more skills:** [OpenClaw native skills](https://github.com/openclaw/openclaw/tree/main/skills) | [ClawHub](https://clawhub.ai) | [skills.sh](https://skills.sh)

---

## Categories

| Category | Skills | Description |
|----------|--------|-------------|
| [**ai-tools**](ai-tools/) | 11 | AI agents, MCP integrations, web search, LLM tooling |
| [**app-store**](app-store/) | 28 | App Store tools, RevenueCat, Prometheus, ReelFarm |
| [**apple**](apple/) | 4 | Apple ecosystem (Shortcuts, UX guidelines, notarization) |
| [**bloom**](bloom/) | 3 | Bloom product-specific skills |
| [**coding**](coding/) | 24 | Programming, debugging, testing, code review, PR management |
| [**creative**](creative/) | 38 | Writing, editing, media production, content creation |
| [**devops**](devops/) | 52 | CI/CD, GitHub, Docker, MLOps, model training/inference |
| [**finance**](finance/) | 9 | Investing, market analysis, portfolio management |
| [**hermes**](hermes/) | 23 | Runtime internals, patches, skill creation/auditing |
| [**marketing**](marketing/) | 38 | Ads (Google/Meta/Apple), SEO, analytics, social media |
| [**productivity**](productivity/) | 12 | Email, notes, smart home, local search, gaming |
| [**research**](research/) | 12 | Deep research, competitive analysis, market intelligence |
| [**visual-design**](visual-design/) | 37 | UI/UX design, diagrams, image generation, frontend |

---

## Skill Structure

Every skill lives inside a category folder:

```
category/
└── skill-name/
    ├── SKILL.md              # Entry point (required)
    ├── references/           # Detailed docs, checklists, examples
    ├── scripts/              # Deterministic code (Python, JS, bash)
    └── assets/               # Templates, images, static resources
```

See [AGENTS.md](AGENTS.md) for full conventions.
