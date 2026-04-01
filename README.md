# Eric's Skills

90+ [OpenClaw](https://github.com/openclaw/openclaw) skills I use daily for content, marketing, development, investing, and growth. Some are original, some are adapted from great open-source projects. All are battle-tested.

## What's Here

This repo is my personal skills directory. Skills are prompt templates that OpenClaw (or any Claude Code-compatible agent) invokes on demand. Each skill is a folder with a `SKILL.md` file.

**Looking for more skills?**
- [OpenClaw native skills](https://github.com/openclaw/openclaw/tree/main/skills) ship with the platform (GitHub, Slack, Apple Notes, weather, etc.)
- [ClawHub](https://clawhub.ai) is the community skill marketplace
- [skills.sh](https://skills.sh) has third-party skills from tool vendors

---

## Skills

### Content & Writing

| Skill | Description |
|-------|-------------|
| [copywriting](copywriting/) | Page copy frameworks + direct response for any platform (ads, App Store, landing pages, scripts). |
| [article-writer](article-writer/) | write article drafts from approved outlines with SEO and brand voice. |
| [editor-in-chief](editor-in-chief/) | autonomous editing orchestrator: diagnose, fix, and iterate drafts to quality. |
| [evaluate-content](evaluate-content/) | judge content quality: shareability, readability, voice, cuttability, angle. |
| [hooks](hooks/) | generate hooks, titles, and scroll-stopping openers for content. |
| [outline-generator](outline-generator/) | generate structured article outlines from approved hooks. |
| [substack-draft](substack-draft/) | save finished articles to Substack as drafts. |
| [tweet-ideas](tweet-ideas/) | generate standalone tweet ideas about a topic (Aaron Levie playbook). |

### Marketing & Growth

| Skill | Description |
|-------|-------------|
| [aso](aso/) | App Store Optimization: keyword research, audits, metadata, competitor analysis via DataForSEO |
| [competitive-analysis](competitive-analysis/) | Research competitors and build interactive battlecards |
| [content-performance-report](content-performance-report/) | Weekly content pillar performance report (cron) |
| [dogfood](dogfood/) | QA and exploratory test web applications, produce structured reports |
| [market-daily-briefing](market-daily-briefing/) | Daily market briefing: earnings, macro, notable moves (cron) |
| [meta-ads](meta-ads/) | Daily Meta ad operations via Marketing API |
| [optimize-prompt](optimize-prompt/) | Iteratively optimize system prompts via autoresearch loop |
| [synthetic-userstudies](synthetic-userstudies/) | Run synthetic user research sessions with AI personas |
| [typefully](typefully/) | Create, schedule, and manage social posts via Typefully |
| [whop-content-rewards](whop-content-rewards/) | Set up and manage UGC campaigns on Whop |

### Design & Visual

| Skill | Description |
|-------|-------------|
| [visual-design](visual-design/) | Router skill for all visual design tasks (dispatches to sub-skills below) |
| [visual-design/canvas-design](visual-design/canvas-design/) | Create visual art and designs as .png/.pdf files |
| [visual-design/create-a-sales-asset](visual-design/create-a-sales-asset/) | Generate sales assets: landing pages, decks, one-pagers |
| [visual-design/d3js-visualization](visual-design/d3js-visualization/) | Create interactive D3.js data visualizations |
| [visual-design/image-generator](visual-design/image-generator/) | Generate article visuals: diagrams, hero images, screenshots |
| [visual-design/slideshow-creator](visual-design/slideshow-creator/) | Create and post TikTok slideshows via ReelFarm |
| [visual-design/sticker-creator](visual-design/sticker-creator/) | Create die-cut sticker style cards via Nano Banana Pro |
| [visual-design/apple-ux-guidelines](visual-design/apple-ux-guidelines/) | Apple HIG reference for UI/UX decisions |
| [design-review](design-review/) | Product design review: 13 questions + Nielsen Norman heuristic eval |
| [nano-banana-pro](nano-banana-pro/) | Generate or edit images via Gemini native image generation |
| [excalidraw-mcp](excalidraw-mcp/) | Create hand-drawn style diagrams via Excalidraw MCP |
| [impeccable](impeccable/) | Design quality commands for frontend code: audit, critique, polish, animate, normalize |

### Video Production

| Skill | Description |
|-------|-------------|
| [video-production](video-production/) | Router skill for all video tasks (dispatches to sub-skills below) |
| [video-production/demo-video](video-production/demo-video/) | Create product demo videos via browser automation |
| [video-production/elevenlabs](video-production/elevenlabs/) | Generate voiceover audio via ElevenLabs + Fal.ai |
| [video-production/infinitetalk](video-production/infinitetalk/) | Generate talking avatar videos with lip sync via Fal.ai |
| [video-production/browser-animation-video](video-production/browser-animation-video/) | Browser-based motion graphics with Framer Motion, GSAP, Tailwind |
| [video-production/gemini-svg](video-production/gemini-svg/) | Generate interactive SVG animations via Gemini |
| [video-production/hook-frames](video-production/hook-frames/) | Generate hook frames for video content |
| [video-production/kling](video-production/kling/) | Kling 3.0 cinematic directing prompts (sub-skill of video-production) |
| [video-production/sora](video-production/sora/) | Generate, remix, and manage Sora AI videos |
| [screen-recording](screen-recording/) | Record macOS screen via CLI with ffmpeg |
| [character-creation](character-creation/) | Create consistent AI video characters for reuse across content |
| [seedance](seedance/) | Generate videos using ByteDance Seedance 2.0 via PiAPI |
| [klingai](klingai/) | Kling AI video/image generation via API (standalone entry point) |

### Analytics & Research

| Skill | Description |
|-------|-------------|
| [appfigures](appfigures/) | App store analytics: downloads, revenue, reviews, rankings |
| [copilot-money](copilot-money/) | Query Copilot Money for finances, transactions, net worth |
| [dataforseo](dataforseo/) | Keyword research, app rankings, SERP data via DataForSEO API |
| [grok-search](grok-search/) | Search web or X/Twitter using xAI Grok |
| [notebooklm](notebooklm/) | Query Google NotebookLM for source-grounded answers |
| [phoenix-cli](phoenix-cli/) | Debug LLM apps with Phoenix CLI: traces, errors, experiments |
| [polymarket](polymarket/) | Query Polymarket prediction markets |
| [seo-research](seo-research/) | SEO: keyword research, AI search optimization, technical audits |
| [stock-research](stock-research/) | Stock/equity research, earnings analysis, daily market briefings |
| [trend-research](trend-research/) | Find trending content across TikTok, YouTube, Instagram, X |
| [web-search](web-search/) | Search the web via Serper (Google Search) API |

### Advertising

| Skill | Description |
|-------|-------------|
| [google-ads](google-ads/) | Manage Google Ads campaigns: performance, keywords, optimization |
| [apple-search-ads](apple-search-ads/) | Apple Search Ads campaigns with API automation and bid strategy |

### Development & Coding

| Skill | Description |
|-------|-------------|
| [agent-browser](agent-browser/) | Automate browsers via agent-browser CLI |
| [bloom-cli](bloom-cli/) | Fetch stock data, fundamentals, earnings, SEC filings via Bloom CLI |
| [claude-md-management](claude-md-management/) | Audit, improve, and maintain CLAUDE.md files across repos |
| [coding-agent](coding-agent/) | Run coding agents (Codex, Claude Code, etc.) via ACP |
| [context7](context7/) | Fetch version-specific library docs via Context7 MCP |
| [demo-pr-feature](demo-pr-feature/) | Capture PR demo screenshots, deploy to Surge.sh, post as PR comment |
| [deploy-bloom](deploy-bloom/) | Deploy Bloom OTA updates via bloom-updater |
| [fix-bloom-prs](fix-bloom-prs/) | Fix CI failures and review code on Bloom PRs |
| [fix-sentry-issues](fix-sentry-issues/) | Scan Sentry issues and create fix PRs |
| [app-store-connect](app-store-connect/) | App Store Connect via `asc` CLI: releases, TestFlight, builds, metadata, subscriptions |
| [ios-simulator](ios-simulator/) | iOS simulator automation: builds, screenshots, device management |
| [serena](serena/) | Navigate and edit complex codebases at the symbol level via Serena MCP |
| [verify-deploy](verify-deploy/) | Post-merge deploy verification and production benchmarking |

### Strategy & Business

| Skill | Description |
|-------|-------------|
| [marketing-psychology](marketing-psychology/) | Psychological principles, mental models, and behavioral science for marketing. |
| [pricing-strategy](pricing-strategy/) | Pricing decisions, tier packaging, value metrics, monetization strategy. |
| [launch-strategy](launch-strategy/) | Product launches, feature announcements, Product Hunt, go-to-market. |
| [paid-ads](paid-ads/) | Paid advertising strategy: platform selection, targeting, creative, optimization. |
| [referral-program](referral-program/) | Referral and affiliate program design, optimization, and measurement. |
| [cold-email](cold-email/) | B2B cold email writing and follow-up sequences. |
| [product-marketing-context](product-marketing-context/) | Create product marketing context doc referenced by all marketing skills. |
| [growth](growth/) | full-funnel growth: CRO, onboarding, paywalls, churn, launches, pricing. |
| [positioning-angles](positioning-angles/) | define product positioning angles and strategic frames. |
| [wealth-management](wealth-management/) | client reviews, financial plans, investment proposals, portfolio rebalancing, tax-loss harvesting. |

## Installation

Skills live in your OpenClaw skills directory. Clone and point your config:

```bash
git clone https://github.com/exiao/skills ~/clawd/skills
```

Or grab individual skills:

```bash
cp -r ~/path/to/skills/ad-copy ~/clawd/skills/
```

Each skill is a folder with a `SKILL.md` file. OpenClaw auto-discovers them at startup.

## License

MIT
