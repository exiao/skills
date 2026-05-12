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
hermes config set skills.path ./skills
```

Find more skills: [OpenClaw](https://github.com/openclaw/openclaw/tree/main/skills) | [ClawHub](https://clawhub.ai) | [skills.sh](https://skills.sh)

## Categories

| Category | Skills | Description |
|----------|--------|-------------|
| [app-store](app-store/) | 28 | App Store Connect, ASO, screenshots, iOS simulators |
| [coding](coding/) | 8 | PR babysitting, Sentry fixes, simplification, deploy verification |
| [design](design/) | 32 | UI/UX, Impeccable design system, Excalidraw, slides, Remotion |
| [external-services](external-services/) | 21 | Third-party API integrations and CLIs |
| [investing](investing/) | 0 | Coming soon |
| [memory](memory/) | 3 | Memory management for persistent agents |
| [skills-meta](skills-meta/) | 8 | Meta-skills for creating and improving other skills |
| [thinking](thinking/) | 7 | Brainstorming, office hours, user studies, planning |
| [video](video/) | 18 | Character creation, video editing, production (Kling, Sora, Remotion, ElevenLabs), YouTube content |
| [writing](writing/) | 11 | Copywriting, content strategy, editing, hooks, outlines, content pipeline |

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

### Skill origins

Some skills are adapted from or inspired by other open-source projects:

| Skill | Original |
|-------|----------|
| [app-store-screenshots](app-store/app-store-screenshots/) | [ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) |
| [copywriting](writing/copywriting/) | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) |
| [frontend-design](design/frontend-design/) | [anthropics/claude-code/plugins/frontend-design](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design) |
| [frontend-slides](design/frontend-slides/) | [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) |
| [impeccable](design/impeccable/) | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| [last30days](writing/last30days/) | [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) |
| [positioning-angles](writing/positioning-angles/) | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) |
| [ralph-mode](coding/ralph-mode/) | [anthropics/claude-code/plugins/ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) |
| [remotion-videos](design/remotion/) | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| [skill-creator](skills-meta/skill-creator/) | [anthropics/claude-code/plugins/plugin-dev](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) |
| [stably-cli](external-services/stably-cli/) | [skills.sh/stablyai](https://skills.sh/stablyai/agent-skills/stably-cli) |

### Services and tools

Skills in this repo integrate with the following third-party services and tools:

| Skill | Service |
|-------|---------|
| [apple-search-ads](external-services/apple-search-ads/) | [Apple Search Ads](https://searchads.apple.com) |
| [app-store-connect](app-store/app-store-connect/) | [App Store Connect API](https://developer.apple.com/app-store-connect/api/) |
| [appfigures-cli](external-services/appfigures-cli/) | [Appfigures](https://appfigures.com) |
| [bird-twitter](external-services/bird-twitter/) | [X / Twitter](https://x.com) via [nickaknudson/bird-cli](https://github.com/nickaknudson/bird-cli) |
| [copilot-money-cli](external-services/copilot-money-cli/) | [Copilot Money](https://copilot.money) |
| [dataforseo-cli](external-services/dataforseo-cli/) | [DataForSEO](https://dataforseo.com) |
| [editframe](video/editframe/) | [Editframe](https://editframe.com) |
| [elevenlabs](video/elevenlabs/) | [ElevenLabs](https://elevenlabs.io) via [Fal.ai](https://fal.ai) |
| [excalidraw](design/excalidraw/) | [Excalidraw MCP](https://mcp.excalidraw.com) |
| [firecrawl](external-services/firecrawl/) | [Firecrawl](https://firecrawl.dev) |
| [google-ads-cli](external-services/google-ads-cli/) | [Google Ads](https://ads.google.com) |
| [grok-search](external-services/grok-search/) | [xAI Grok](https://docs.x.ai/docs/guides/tools/search-tools) |
| [gsc-cli](external-services/gsc-cli/) | [Google Search Console](https://search.google.com/search-console) |
| [higgsfield-*](external-services/higgsfield-generate/) | [Higgsfield AI](https://higgsfield.ai) |
| [hyperframes](design/hyperframes/) | [HyperFrames](https://hyperframes.dev) |
| [infinitetalk](video/infinitetalk/) | [InfiniteTalk](https://fal.ai) via Fal.ai |
| [kling](video/kling/) | [Kling AI](https://klingai.com) |
| [mcporter](skills-meta/mcporter/) | [mcporter](https://mcporter.dev) |
| [meta-ads-cli](external-services/meta-ads-cli/) | [Meta Marketing API](https://developers.facebook.com/docs/marketing-apis/) |
| [phoenix-cli](external-services/phoenix-cli/) | [Arize Phoenix](https://phoenix.arize.com) |
| [porkbun-cli](external-services/porkbun-cli/) | [Porkbun](https://porkbun.com) |
| [prometheus-cli](external-services/prometheus-cli/) | [Social Growth Engineers](https://socialgrowthengineers.com) |
| [remotion](design/remotion/) | [Remotion](https://remotion.dev) |
| [render-cli](external-services/render-cli/) | [Render](https://render.com) |
| [sora](video/sora/) | [OpenAI Sora](https://sora.com) |
| [stably-cli](external-services/stably-cli/) | [Stably AI](https://stably.ai) |
| [typefully](external-services/typefully/) | [Typefully](https://typefully.com) |
| [usefastlane-ai](external-services/usefastlane-ai/) | [Fastlane AI](https://usefastlane.ai) |
| [yt-dlp](video/yt-dlp/) | [yt-dlp](https://github.com/yt-dlp/yt-dlp) |
