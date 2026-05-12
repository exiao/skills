# Skills

> License: MIT | [Intro to agent skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) | [Free course](https://anthropic.skilljar.com/introduction-to-agent-skills) | [Complete guide](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)

A curated collection of 136 skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Hermes Agent](https://github.com/NousResearch/hermes-agent), and other skill-aware AI agents.

Skills are structured prompts that teach AI agents specialized workflows, from App Store optimization to video production to stock research. Each skill is a folder with a `SKILL.md` entry point that agents load on demand when a task matches the skill description.

## Install

Open Claude Code and say:

```text
Install the skills from https://github.com/exiao/skills
```

Or clone and point your agent at them:

```bash
git clone https://github.com/exiao/skills.git
# Hermes Agent
runtime config set skills.path ./skills
```

Find more skills: [OpenClaw](https://github.com/openclaw/openclaw/tree/main/skills) | [ClawHub](https://clawhub.ai) | [skills.sh](https://skills.sh)

## Categories

| Category | Skills | Description |
|----------|--------|-------------|
| [app-store](app-store/) | 28 | App Store Connect, ASO, screenshots, iOS simulators |
| [coding](coding/) | 8 | PR babysitting, Sentry fixes, simplification, deploy verification |
| [thinking](thinking/) | 7 | Brainstorming, office hours, user studies, planning |
| [writing](writing/) | 11 | Copywriting, content strategy, editing, hooks, outlines, content pipeline |
| [design](design/) | 32 | UI/UX, Impeccable design system, Excalidraw, slides, Remotion |
| [video](video/) | 18 | Character creation, video editing, production (Kling, Sora, Remotion, ElevenLabs), YouTube content |
| [external-services](external-services/) | 21 | Third-party API integrations and CLIs |
| [memory](memory/) | 3 | Memory management for persistent agents |
| [investing](investing/) | 0 | Coming soon |
| [skills-meta](skills-meta/) | 8 | Meta-skills for creating and improving other skills |

## Skill structure

```text
category/
└── skill-name/
    ├── SKILL.md              # Entry point (required)
    ├── references/           # Detailed docs, checklists, examples
    ├── scripts/              # Deterministic code (Python, JS, bash)
    └── assets/               # Templates, images, static resources
```

## Contributing

PRs welcome. See [CLAUDE.md](CLAUDE.md) for conventions. CI runs automated review on every PR.

## Attribution

Some skills are forked from or inspired by third-party sources:

| Skill | Source |
|-------|--------|
| [last30days](writing/last30days/) | [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) |
| [grok-search](external-services/grok-search/) | [xAI docs](https://docs.x.ai/docs/guides/tools/search-tools) |
| [mcporter](skills-meta/mcporter/) | [mcporter.dev](https://mcporter.dev) |
| [apple-search-ads](external-services/apple-search-ads/) | [ClawHub](https://clawhub.ai) |
| [google-ads-cli](external-services/google-ads-cli/) | [ClawHub](https://clawhub.ai) |
| [meta-ads-cli](external-services/meta-ads-cli/) | [ClawHub](https://clawhub.ai) |
| [demo-video](video/demo-video/) | [ClawHub](https://clawhub.ai) |
