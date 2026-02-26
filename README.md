# Eric's Skills

My [Clawdbot](https://clawdbot.com) skills collection — prompt templates and tools I invoke on demand across 70+ domains.

## Quick Start

Clone this repo and copy skills to your Clawdbot skills directory:

```bash
git clone https://github.com/exiao/erics-skills ~/Projects/erics-skills
cp -r ~/Projects/erics-skills/skills/* ~/.clawdbot/skills/
```

Or install individual skills:

```bash
cp -r ~/Projects/erics-skills/skills/ad-copy ~/.clawdbot/skills/
```

## Skills

### Content & Writing

| Skill | Description |
|-------|-------------|
| [ad-copy](ad-copy/SKILL.md) | write ad copy: App Store listings, Google Ads, landing pages, TikTok/Meta scripts, push, email. |
| [article-writer](article-writer/SKILL.md) | write article drafts from approved outlines with SEO and brand voice. |
| [content-atomizer](content-atomizer/SKILL.md) | repurpose long-form content into platform-native pieces for 8+ channels. |
| [editor-in-chief](editor-in-chief/SKILL.md) | autonomous editing orchestrator: diagnose, fix, and iterate drafts to quality. |
| [evaluate-content](evaluate-content/SKILL.md) | judge content quality: shareability, readability, voice, cuttability, angle. |
| [headlines](headlines/SKILL.md) | generate headlines, titles, and hooks for content. |
| [outline-generator](outline-generator/SKILL.md) | generate structured article outlines from approved headlines. |
| [substack-draft](substack-draft/SKILL.md) | save finished articles to Substack as drafts. |
| [tweet-ideas](tweet-ideas/SKILL.md) | generate standalone tweet ideas about a topic (Aaron Levie playbook). |

### Design & Media

| Skill | Description |
|-------|-------------|
| [visual-design](visual-design/SKILL.md) | router skill for all visual design and creative output tasks. |
| [visual-design/browser-animation-video](visual-design/browser-animation-video/SKILL.md) | create browser-based motion graphics with Framer Motion, GSAP, and Tailwind. |
| [visual-design/canvas-design](visual-design/canvas-design/SKILL.md) | create visual art and designs as .png/.pdf files. |
| [visual-design/d3js-visualization](visual-design/d3js-visualization/SKILL.md) | create interactive D3.js data visualizations. |
| [visual-design/frontend-design](visual-design/frontend-design/SKILL.md) | build production-grade frontend interfaces with high design quality. |
| [visual-design/frontend-slides](visual-design/frontend-slides/SKILL.md) | create animation-rich HTML presentations or convert PPT to web. |
| [visual-design/gemini-svg](visual-design/gemini-svg/SKILL.md) | generate interactive SVG animations via Gemini. |
| [visual-design/image-generator](visual-design/image-generator/SKILL.md) | generate article visuals: diagrams, hero images, screenshots. |
| [visual-design/remotion-videos](visual-design/remotion-videos/SKILL.md) | create animated marketing videos with Remotion (renders to MP4). |
| [visual-design/slideshow-creator](visual-design/slideshow-creator/SKILL.md) | create and post TikTok slideshows via ReelFarm. |
| [visual-design/sora](visual-design/sora/SKILL.md) | generate, remix, and manage Sora AI videos. |
| [visual-design/kling](visual-design/kling/SKILL.md) | generate AI video prompts for Kling 3.0 using cinematic directing techniques. |
| [video-production](video-production/SKILL.md) | router skill — dispatches video tasks to the right sub-skill. |
| [video-production/demo-video](video-production/demo-video/SKILL.md) | create product demo videos by automating browser interactions and capturing frames. |

### Analytics & Research

| Skill | Description |
|-------|-------------|
| [appfigures](appfigures/SKILL.md) | query Appfigures for app store analytics (downloads, revenue, reviews, rankings). |
| [competitive-analysis](competitive-analysis/SKILL.md) | research competitors and build interactive battlecards. |
| [copilot-money](copilot-money/SKILL.md) | query Copilot Money for finances, transactions, net worth, and holdings. |
| [dataforseo](dataforseo/SKILL.md) | keyword research, App Store/Google Play rankings, SERP rankings, ASO. |
| [grok-search](grok-search/SKILL.md) | search the web or X/Twitter using xAI Grok. |
| [last30days](last30days/SKILL.md) | research topics, manage watchlists, get briefings. Sources: Reddit, X, YouTube, web. |
| [phoenix-cli](phoenix-cli/SKILL.md) | debug LLM apps with Phoenix CLI: traces, errors, experiments. |
| [polymarket](polymarket/SKILL.md) | query Polymarket prediction markets. |
| [seo-research](seo-research/SKILL.md) | SEO: keyword research, AI search optimization, technical audits, schema markup. |
| [stock-research](stock-research/SKILL.md) | stock/equity research, earnings analysis, daily market briefings. |
| [trend-research](trend-research/SKILL.md) | find trending content on TikTok, YouTube, Instagram, Twitter, etc. |
| [web-search](web-search/SKILL.md) | search the web via Serper (Google Search) API. |

### Advertising

| Skill | Description |
|-------|-------------|
| [content-strategy](content-strategy/SKILL.md) | Paid and organic content creative strategy: research-driven concepts, 6 Elements framework, lo-fi formats, A/B testing. Works across Meta, TikTok, YouTube, X, and organic social. |
| [google-ads](google-ads/SKILL.md) | manage Google Ads campaigns: performance checks, keyword pausing, optimization. |
| [typefully](typefully/SKILL.md) | create, schedule, and manage social posts via Typefully. |
| [whop-content-rewards](whop-content-rewards/SKILL.md) | set up and manage Content Rewards UGC campaigns on Whop. |

### Development

| Skill | Description |
|-------|-------------|
| [claude-md-management](claude-md-management/SKILL.md) | audit, improve, and maintain CLAUDE.md files across repos. |
| [context7](context7/SKILL.md) | fetch version-specific library/framework docs via Context7 MCP. |
| [deploy-bloom](deploy-bloom/SKILL.md) | deploy Bloom OTA updates via bloom-updater pipeline. |
| [documents](documents/SKILL.md) | work with .docx, .pdf, .pptx, .xlsx files. |
| [fix-bloom-prs](fix-bloom-prs/SKILL.md) | fix CI failures, review code, squash Bloom PRs. |
| [fix-sentry-issues](fix-sentry-issues/SKILL.md) | scan Sentry issues for Bloom and create fix PRs. |
| [ios-simulator](ios-simulator/SKILL.md) | iOS simulator scripts for app testing and build automation. |
| [ralph-mode](ralph-mode/SKILL.md) | autonomous dev loops with iteration gates and test validation. |
| [serena](serena/SKILL.md) | navigate/edit complex codebases at the symbol level via Serena MCP. |
| [superpowers-coding](superpowers-coding/SKILL.md) | TDD-first feature implementation and systematic debugging. |
| [superpowers-planning](superpowers-planning/SKILL.md) | explore intent and create detailed plans before touching code. |
| [superpowers-reviews](superpowers-reviews/SKILL.md) | code review, branch finishing, batch execution with checkpoints. |
| [superpowers-writing-skills](superpowers-writing-skills/SKILL.md) | create, edit, or verify agent skills before deployment. |

### Strategy & Growth

| Skill | Description |
|-------|-------------|
| [ad-copy](ad-copy/SKILL.md) | direct response copy for any platform. |
| [content-management](content-management/SKILL.md) | plan, schedule, distribute, and optimize content across platforms. |
| [create-a-sales-asset](visual-design/create-a-sales-asset/SKILL.md) | generate sales assets (landing pages, decks, one-pagers). |
| [dogfood](dogfood/SKILL.md) | QA and exploratory test web applications, produce structured reports. |
| [growth](growth/SKILL.md) | full-funnel growth: CRO, onboarding, paywalls, churn, launches, pricing. |
| [positioning-angles](positioning-angles/SKILL.md) | define product positioning angles and strategic frames. |
| [wealth-management](wealth-management/SKILL.md) | client reviews, financial plans, investment proposals, portfolio rebalancing, tax-loss harvesting. |

## Installation

Skills live in `~/clawd/skills/`. Each skill is a folder with a `SKILL.md` file.

To sync from this repo:

```bash
git clone https://github.com/exiao/skills ~/clawd/skills
```

## Contributing

Fork and adapt for your own workflow. Replace any account-specific credentials and API keys.

## License

MIT
