# Eric's Skills

90+ skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) covering content, marketing, design, development, investing, and growth. Battle-tested daily.

> **New to skills?** Skills are prompt templates that Claude Code invokes on demand. Each skill is a folder with a `SKILL.md` file. Learn more: [Intro](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) | [Free course](https://anthropic.skilljar.com/introduction-to-agent-skills) | [Complete guide](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)

## Install

**Install everything** — open Claude Code and say:

```
Install the skills from https://github.com/exiao/skills
```

**Pick and choose** — follow the [Interactive Install Guide](INSTALL.md) to select only the categories you need.

**Find more skills:**
[OpenClaw native skills](https://github.com/openclaw/openclaw/tree/main/skills) | [ClawHub](https://clawhub.ai) | [skills.sh](https://skills.sh)

---

## Skills

### Content & Writing

| Skill | Description |
|-------|-------------|
| [article-writer](article-writer/) | Write article drafts from approved outlines with SEO and brand voice |
| [brand-identity](brand-identity/) | Build a complete brand identity: purpose, values, voice, visual system, guidelines |
| [content-pipeline](content-pipeline/) | Orchestrator for the 3-article content pipeline with parallel sub-agents |
| [content-strategy](content-strategy/) | Build content strategy: hooks, angles, and ideas from what's trending now |
| [editor-in-chief](editor-in-chief/) | Autonomous editing orchestrator: diagnose, fix, and iterate drafts to quality |
| [evaluate-content](evaluate-content/) | Judge content quality: shareability, readability, voice, cuttability, angle |
| [hooks](hooks/) | Generate headlines, titles, and scroll-stopping openers |
| [outline-generator](outline-generator/) | Generate structured article outlines from approved hooks |
| [substack-draft](substack-draft/) | Save finished articles to Substack as drafts |
| [tweet-ideas](tweet-ideas/) | Generate standalone tweet ideas (Aaron Levie playbook) |

### Marketing & Growth

| Skill | Description |
|-------|-------------|
| [aso](aso/) | App Store Optimization: keyword research, audits, metadata, competitor analysis via DataForSEO |
| [cold-email](cold-email/) | B2B cold email writing and follow-up sequences |
| [competitive-analysis](competitive-analysis/) | Research competitors and build interactive battlecards |
| [content-performance-report](content-performance-report/) | Weekly content pillar performance report (cron) |
| [copywriting](copywriting/) | Write or improve marketing copy for any surface: pages, ads, app stores, landing pages, video scripts, push notifications. Combines page copy frameworks with direct response principles. |
| [dogfood](dogfood/) | QA and exploratory test web applications, produce structured reports |
| [launch-strategy](launch-strategy/) | Product launches, feature announcements, Product Hunt, go-to-market |
| [market-daily-briefing](market-daily-briefing/) | Daily market briefing: earnings, macro, notable moves (cron) |
| [marketing-psychology](marketing-psychology/) | Psychological principles, mental models, and behavioral science for marketing |
| [meta-ads](meta-ads/) | Daily Meta ad operations via Marketing API |
| [optimize-prompt](optimize-prompt/) | Iteratively optimize system prompts via autoresearch loop |
| [paid-ads](paid-ads/) | Paid advertising strategy: platform selection, targeting, creative, optimization |
| [pricing-strategy](pricing-strategy/) | Pricing decisions, tier packaging, value metrics, monetization strategy |
| [product-marketing-context](product-marketing-context/) | Create product marketing context doc referenced by all marketing skills |
| [referral-program](referral-program/) | Referral and affiliate program design, optimization, and measurement |
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
| [impeccable](impeccable/) | Design quality layer: 21 commands (audit, critique, polish, animate, etc.) with 10 reference files for systematic frontend QA |

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
| [google-ads-scripts](google-ads-scripts/) | Google Ads Script development: AdsApp API, campaign automation, bid optimization, reporting |
| [meta-ads-creative](meta-ads-creative/) | Create high-converting Meta ad creative using the 6 Elements framework and proven formats |
| [apple-search-ads](apple-search-ads/) | Apple Search Ads campaigns with API automation and bid strategy |

### Development & Coding

| Skill | Description |
|-------|-------------|
| [agent-browser](agent-browser/) | Automate browsers via agent-browser CLI |
| [babysit-open-prs](coding/babysit-open-prs/) | Scan open PRs across tracked repos, triage, and spawn babysit-pr sub-agents |
| [babysit-pr](babysit-pr/) | Monitor a PR through CI, reviews, and fixes until it's ready to merge |
| [bloom-cli](bloom-cli/) | Fetch stock data, fundamentals, earnings, SEC filings via Bloom CLI |
| [claude-md-management](claude-md-management/) | Audit, improve, and maintain CLAUDE.md files across repos |
| [coding-agent](coding-agent/) | Run coding agents (Codex, Claude Code, etc.) via ACP |
| [context7](context7/) | Fetch version-specific library docs via Context7 MCP |
| [demo-pr-feature](demo-pr-feature/) | Capture PR demo screenshots, deploy to Surge.sh, post as PR comment |
| [deploy-bloom](deploy-bloom/) | Deploy Bloom OTA updates via bloom-updater |
| [documents](documents/) | Work with .docx, .pdf, .pptx, .xlsx files |
| [fix-bloom-prs](fix-bloom-prs/) | Fix CI failures, review code, and address review comments on PRs across tracked repos |
| [fix-sentry-issues](fix-sentry-issues/) | Scan Sentry issues and create fix PRs |
| [app-store-connect](app-store-connect/) | App Store Connect via `asc` CLI: releases, TestFlight, builds, metadata, subscriptions |
| [ios-simulator](ios-simulator/) | iOS simulator automation: builds, screenshots, device management |
| [ralph-mode](ralph-mode/) | Autonomous dev loops with iteration gates and test validation |
| [react-doctor](react-doctor/) | Diagnose and fix React codebase health issues: performance, security, code quality |
| [serena](serena/) | Navigate and edit complex codebases at the symbol level via Serena MCP |
| [simplify](simplify/) | Review changed code for reuse, quality, and efficiency, then fix issues |
| [stably-cli](stably-cli/) | Create, run, fix, and maintain Playwright tests via Stably CLI |
| [stably-sdk-rules](stably-sdk-rules/) | Best practices for writing Stably AI-powered Playwright tests |
| [superpowers-coding](superpowers-coding/) | TDD-first feature implementation and systematic debugging |
| [superpowers-planning](superpowers-planning/) | Explore intent and create detailed plans before touching code |
| [superpowers-reviews](superpowers-reviews/) | Code review, branch finishing, batch execution with checkpoints |
| [verify-deploy](verify-deploy/) | Post-merge deploy verification and production benchmarking |

### Strategy & Business

| Skill | Description |
|-------|-------------|
| [alpaca](alpaca/) | Trade stocks and crypto via Alpaca API |
| [another-perspective](another-perspective/) | Multi-perspective council analysis on decisions |
| [cloud-migration](cloud-migration/) | Full cloud provider migrations end-to-end |
| [porkbun](porkbun/) | Manage domains, DNS, SSL via Porkbun API |
| [railway](railway/) | Deploy and manage Railway projects via CLI and MCP |
| [render-cli](render-cli/) | Deploy and manage Render services via official Render CLI |
| [sahil-office-hours](sahil-office-hours/) | Startup advice frameworks from Sahil Lavingia (Gumroad) |
| [yc-office-hours](yc-office-hours/) | YC office hours prep |

### OpenClaw & Infrastructure

| Skill | Description |
|-------|-------------|
| [openclaw-memory-setup](openclaw-memory-setup/) | Set up a complete memory system for an OpenClaw instance |
| [openclaw-resiliency](openclaw-resiliency/) | Gateway watchdog for health monitoring and auto-recovery |
| [security-audit](security-audit/) | Security audit for codebases and deployments |

### Automated Pipelines (Cron)

| Skill | Description |
|-------|-------------|
| [earnings-card-pipeline](earnings-card-pipeline/) | Weekly earnings event cards for social (Mon 8 AM ET) |
| [post-bloom-features](post-bloom-features/) | Screenshot new features, render social cards (Tue/Thu 1 AM ET) |
| [post-insider-trades](post-insider-trades/) | Scrape insider buys, generate trade cards (weekdays 9 AM + 2 PM ET) |
| [post-investinglog-trades](post-investinglog-trades/) | Post trade cards from investing-log (weekdays 4 PM ET) |

### UI/UX

| Skill | Description |
|-------|-------------|
| [create-app-onboarding](marketing/create-app-onboarding/) | Design and build high-converting questionnaire-style app onboarding flows |
| [userinterface-wiki](userinterface-wiki/) | UI/UX best practices: animations, CSS, typography, UX patterns |

### Other

| Skill | Description |
|-------|-------------|
| [document-release](document-release/) | Document release processes |
| [trip-planner](trip-planner/) | Generate day-by-day travel itineraries with neighborhood routing and budget scaling |

---

## Adapted Skills

These started from other open-source projects. I've modified and extended them for my workflows. Links to the originals:

### From [Anthropic](https://github.com/anthropics)

| Skill | Original |
|-------|----------|
| [documents](documents/) | [anthropics/skills](https://github.com/anthropics/skills) |
| [wealth-management](wealth-management/) | [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) |
| [skill-creator](skill-creator/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) |
| [skill-audit](skill-audit/) | Original (inspired by Anthropic's skill patterns) |
| [skill-improver](skill-improver/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) |
| [visual-design/frontend-design](visual-design/frontend-design/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design) |
| [ralph-mode](ralph-mode/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) |

### From [obra/superpowers](https://github.com/obra/superpowers)

| Skill | Description |
|-------|-------------|
| [superpowers-coding](superpowers-coding/) | TDD-first feature implementation and systematic debugging |
| [superpowers-planning](superpowers-planning/) | Explore intent and create detailed plans before touching code |
| [superpowers-reviews](superpowers-reviews/) | Code review, branch finishing, batch execution with checkpoints |

### From [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)

| Skill | Description |
|-------|-------------|
| [growth](growth/) | Full-funnel growth: CRO, onboarding, paywalls, churn, launches, pricing |
| [churn-prevention](churn-prevention/) | Subscription retention, cancel flows, save offers, dunning |
| [email-sequence](email-sequence/) | Email sequences, drip campaigns, lifecycle messaging |
| [positioning-angles](positioning-angles/) | Product positioning, strategic angles, value propositions |

### From Other Projects

| Skill | Original |
|-------|----------|
| [codex](codex/) | [garrytan/gstack](https://github.com/garrytan/gstack) (MIT) |
| [impeccable](impeccable/) | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| [app-store-screenshots](app-store-screenshots/) | [ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) |
| [remotion-best-practices](remotion-best-practices/) | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| [video-production/remotion-videos](video-production/remotion-videos/) | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| [visual-design/frontend-slides](visual-design/frontend-slides/) | [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) |
| [last30days](last30days/) | [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) |
| [stably-cli](stably-cli/) | [skills.sh/stablyai](https://skills.sh/stablyai/agent-skills/stably-cli) |
| [stably-sdk-rules](stably-sdk-rules/) | [skills.sh/stablyai](https://skills.sh/stablyai/agent-skills/stably-sdk-rules) |
| [sahil-office-hours](sahil-office-hours/) | [slavingia/skills](https://github.com/slavingia/skills) |

## License

MIT
