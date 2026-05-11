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

<!-- BEGIN GENERATED CATEGORY TABLE -->
| Category | Skills | Description |
|---|---:|---|
| [ai-tools](ai-tools/) | 10 | AI agents (Claude Code, Codex, OpenCode), MCP integrations, web search tools, and LLM-powered utilities. |
| [app-store](app-store/) | 28 | App Store skills — App Store Connect API, ASO keyword optimization, screenshots, iOS simulators, and RevenueCat subscription management. |
| [coding](coding/) | 29 | Programming, debugging, testing, code review, PR management, prompt optimization, and software development workflows. |
| [creative](creative/) | 49 | Writing, editing, content pipelines, media production (video via Kling/Seedance/Remotion/Manim, audio, GIFs), AI image generation (Nano Banana), content evaluation, Substack drafts, and YouTube content. |
| [devops](devops/) | 54 | CI/CD, GitHub workflows (PRs, reviews, issues, rulesets), Docker debugging, MLOps (training, inference, evaluation), cloud deployment (Render, Railway), DNS/domains (Porkbun), security audits, webhook management, and Playwright testing (Stably). |
| [external-services](external-services/) | 17 | External service CLIs and API integrations — Porkbun domains, Copilot Money finances, Appfigures analytics, DataForSEO keywords, Google Ads, Meta Ads, Apple Search Ads, Prometheus/PAssistant, Stably testing, Firecrawl scraping, Bird (X/Twitter), and Higgsfield AI video/image generation. |
| [finance](finance/) | 11 | Finance and investing — Alpaca trading, stock research, wealth management (Copilot Money), earnings card pipeline, market daily briefings, Polymarket predictions, and insider/investing log trade posting. |
| [marketing](marketing/) | 39 | Advertising (Google, Meta, Apple Search Ads), SEO, analytics, social media (X/Twitter via Bird and xitter, Typefully scheduling), content strategy and pipelines, hooks, trend research, positioning, pricing strategy, brand identity, NotebookLM, email sequences, and growth. |
| [media](media/) | 2 | Skills for working with media content — YouTube transcripts, GIF search, music generation, and audio visualization. |
| [memory](memory/) | 3 | Memory management — garbage collection, setup, and recall from past sessions. |
| [productivity](productivity/) | 17 | Email (Himalaya), notes (Obsidian, Apple Notes, Notion), Apple apps (Reminders, FindMy, iMessage), Google Workspace, smart home (OpenHue), Linear project management, PDF tools, PowerPoint, OCR, local search, and leisure/gaming (Minecraft, Pokemon). |
| [research](research/) | 12 | Academic research (arXiv, paper writing), brainstorming, blog/content monitoring, LLM knowledge base, synthetic user studies, hotel/trip planning, and office hours frameworks (YC, Sahil). |
| [skills-meta](skills-meta/) | 7 | Skills about skills — creating, auditing, improving, testing skill quality, preloading optimization, cleanup, and QA dogfooding. |
| [visual-design](visual-design/) | 35 | Visual design skills — Excalidraw diagrams, D3.js visualizations, canvas design, slides, frontend design, image generation, Apple UX guidelines, design review, sticker creation, sales assets, and Impeccable design system. The SKILL.md at this level acts as a router that triages to the right sub-skill. |
<!-- END GENERATED CATEGORY TABLE -->

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
