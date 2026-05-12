# Skills

A curated collection of skills for [Hermes Agent](https://github.com/NousResearch/hermes-agent), Claude Code, and other skill-aware AI agents.

Skills are structured prompts that teach AI agents specialized workflows, from App Store optimization to video production to stock research.

## What's a skill?

A skill is a markdown file (`SKILL.md`) with YAML frontmatter that an AI agent loads when it detects a matching task. Skills contain domain knowledge, step-by-step workflows, CLI commands, and decision trees that would otherwise require extensive prompting.

## Categories

| Category | Skills | Description |
|----------|--------|-------------|
| [app-store](app-store/) | 28 | App Store Connect, ASO, screenshots, iOS simulators |
| [coding](coding/) | 8 | PR babysitting, Sentry fixes, simplification, deploy verification |
| [thinking](thinking/) | 7 | Brainstorming, office hours, user studies, planning |
| [writing](writing/) | 11 | Copywriting, content strategy, editing, hooks, outlines, content pipeline |
| [design](design/) | 32 | UI/UX, Impeccable design system, Excalidraw, Remotion |
| [video](video/) | 18 | Character creation, video editing, production (Kling, Sora, Remotion, ElevenLabs), YouTube content |
| [external-services](external-services/) | 21 | Third-party API integrations and CLIs |
| [memory](memory/) | 3 | Memory management for persistent agents |
| [investing](investing/) | 0 | Coming soon |
| [skills-meta](skills-meta/) | 8 | Meta-skills for creating and improving other skills |

**Total: 136 skills**

## Usage

### With Hermes Agent

```bash
# Point your skills directory to this repo
runtime config set skills.path ./skills

# Skills are automatically loaded when relevant tasks are detected
```

### With Claude Code

```bash
# Add to your CLAUDE.md or .claude/settings.json
# Skills in this repo follow Claude Code's skill format
```

### Creating your own skills

See [CLAUDE.md](CLAUDE.md) for conventions, or use the `skill-creator` meta-skill.

## Contributing

PRs welcome. See [CLAUDE.md](CLAUDE.md) for conventions. CI runs automated review on every PR.
