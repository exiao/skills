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
| [**ai-tools**](ai-tools/) | 10 | AI agents, MCP integrations, web search, LLM tooling |
| [**app-store**](app-store/) | 28 | App Store tools, RevenueCat, Prometheus, ReelFarm |
| [**bloom**](bloom/) | 3 | Bloom product-specific skills |
| [**coding**](coding/) | 25 | Programming, debugging, testing, code review, web scraping |
| [**creative**](creative/) | 38 | Writing, editing, media production, content creation |
| [**devops**](devops/) | 52 | CI/CD, GitHub, Docker, MLOps, model training/inference |
| [**finance**](finance/) | 9 | Investing, market analysis, portfolio management |
| [**runtime**](hermes/) | 23 | Runtime internals, patches, skill creation/auditing |
| [**marketing**](marketing/) | 38 | Ads (Google/Meta/Apple), SEO, analytics, social media |
| [**productivity**](productivity/) | 16 | Apple apps, email, notes, smart home, local search, gaming |
| [**research**](research/) | 12 | Deep research, competitive analysis, market intelligence |
| [**visual-design**](visual-design/) | 37 | UI/UX design, diagrams, image generation, frontend |

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

See [CLAUDE.md](CLAUDE.md) for full conventions.

---

---

## All Skills

### 🤖 AI Tools

| Skill | Description |
|-------|-------------|
| [agent-browser](ai-tools/agent-browser/) | Use when automating browsers via agent-browser CLI: headless browsing, web scraping with accessibility trees, CDP-based automation, filling forms, clicking buttons, navigating pages, or running isolated browser sessions for sub-agents. Prefer over Playwright browser tool when compact context and… |
| [claude-code](ai-tools/claude-code/) | Delegate coding tasks to Claude Code (Anthropic's CLI agent). Use for building features, refactoring, PR reviews, and iterative coding. Requires the claude CLI installed. |
| [claude-code-routines](ai-tools/claude-code-routines/) | Set up and manage Claude Code Routines — scheduled, API-triggered, and GitHub webhook automations that run on Anthropic's cloud. Use when asked about routines, scheduled tasks in Claude Code, automating with Claude, or setting up triggers for code review, deploys, alerts, or recurring tasks. |
| [codex](ai-tools/codex/) | Delegate coding tasks to OpenAI Codex CLI agent. Use for building features, refactoring, PR reviews, and batch issue fixing. Requires the codex CLI and a git repository. |
| [grok-search](ai-tools/grok-search/) | Search the web or X/Twitter using xAI Grok server-side tools (web_search, x_search) via the xAI Responses API. Use when you need tweets/threads/users from X, want Grok as an alternative to Brave, or you need structured JSON + citations. |
| [hermes-agent](ai-tools/hermes-agent/) | Complete guide to using and extending Hermes Agent — CLI usage, setup, configuration, spawning additional agents, gateway platforms, skills, voice, tools, profiles, and a concise contributor reference. Load this skill when helping users configure Hermes, troubleshoot issues, spawn agent… |
| [mcporter](ai-tools/mcporter/) | Use the mcporter CLI to list, configure, auth, and call MCP servers/tools directly (HTTP or stdio), including ad-hoc servers, config edits, and CLI/type generation. |
| [native-mcp](ai-tools/native-mcp/) | Built-in MCP (Model Context Protocol) client that connects to external MCP servers, discovers their tools, and registers them as native Hermes Agent tools. Supports stdio and HTTP transports with automatic reconnection, security filtering, and zero-config tool injection. |
| [opencode](ai-tools/opencode/) | Delegate coding tasks to OpenCode CLI agent for feature implementation, refactoring, PR review, and long-running autonomous sessions. Requires the opencode CLI installed and authenticated. |
| [web-search](ai-tools/web-search/) | Search the web via Serper (Google Search) API. Default web search tool — use this first for recent releases, news, and general queries. |

### 📱 App Store

| Skill | Description |
|-------|-------------|
| [app-store-connect](app-store/app-store-connect/) | Use the asc CLI for all App Store Connect tasks — releases, TestFlight, builds, metadata, screenshots, signing, subscriptions, IAPs, pricing, analytics, users, notarization, and more. Primary catch-all for any App Store Connect work. For deep workflows, also see specialized asc-* skills. |
| [app-create-ui](app-store/app-store-connect/app-create-ui/) | Create a new App Store Connect app record via browser automation. Use when there is no public API for app creation and you need an agent to drive the New App form. |
| [build-lifecycle](app-store/app-store-connect/build-lifecycle/) | Track build processing, find latest builds, and clean up old builds with asc. Use when managing build retention or waiting on processing. |
| [cli-usage](app-store/app-store-connect/cli-usage/) | Guidance for using asc cli in this repo (flags, output formats, pagination, auth, and discovery). Use when asked to run or design asc commands or interact with App Store Connect via the CLI. |
| [crash-triage](app-store/app-store-connect/crash-triage/) | Triage TestFlight crashes, beta feedback, and performance diagnostics using asc. Use when the user asks about TF crashes, TestFlight crash reports, beta tester feedback, app hangs, disk writes, launch diagnostics, or wants a crash summary for a build or app. |
| [id-resolver](app-store/app-store-connect/id-resolver/) | Resolve App Store Connect IDs (apps, builds, versions, groups, testers) from human-friendly names using asc. Use when commands require IDs. |
| [localize-metadata](app-store/app-store-connect/localize-metadata/) | Automatically translate and sync App Store metadata (description, keywords, what's new, subtitle) to multiple languages using LLM translation and asc CLI. Use when asked to localize an app's App Store listing, translate app descriptions, or add new languages to App Store Connect. |
| [metadata-sync](app-store/app-store-connect/metadata-sync/) | Sync and validate App Store metadata and localizations with asc, including legacy metadata format migration. Use when updating metadata or translations. |
| [notarization](app-store/app-store-connect/notarization/) | Archive, export, and notarize macOS apps using xcodebuild and asc. Use when you need to prepare a macOS app for distribution outside the App Store with Developer ID signing and Apple notarization. |
| [ppp-pricing](app-store/app-store-connect/ppp-pricing/) | Set territory-specific pricing for subscriptions and in-app purchases using current asc setup, pricing summary, price import, and price schedule commands. Use when adjusting prices by country or implementing localized PPP strategies. |
| [release-flow](app-store/app-store-connect/release-flow/) | End-to-end release workflows for TestFlight and App Store using asc publish, builds, versions, and submit commands. Use when asked to upload a build, distribute to TestFlight, or submit to App Store. |
| [revenuecat-catalog-sync](app-store/app-store-connect/revenuecat-catalog-sync/) | Reconcile App Store Connect subscriptions and in-app purchases with RevenueCat products, entitlements, offerings, and packages using the asc CLI and the revenuecat-cli skill (mcporter). Use when setting up or syncing subscription catalogs across ASC and RevenueCat. |
| [shots-pipeline](app-store/app-store-connect/shots-pipeline/) | Orchestrate iOS screenshot automation with xcodebuild/simctl for build-run, AXe for UI actions, JSON settings and plan files, Go-based framing (`asc screenshots frame`), and screenshot upload (`asc screenshots upload`). Use when users ask for automated screenshot capture, AXe-driven simulator… |
| [signing-setup](app-store/app-store-connect/signing-setup/) | Set up bundle IDs, capabilities, signing certificates, and provisioning profiles with the asc cli. Use when onboarding a new app or rotating signing assets. |
| [submission-health](app-store/app-store-connect/submission-health/) | Preflight App Store submissions, submit builds, and monitor review status with asc. Use when shipping or troubleshooting review submissions. |
| [subscription-localization](app-store/app-store-connect/subscription-localization/) | Bulk-localize subscription and in-app purchase display names across all App Store locales using asc. Use when you want to fill in subscription/IAP names for every language without clicking through App Store Connect manually. |
| [testflight-orchestration](app-store/app-store-connect/testflight-orchestration/) | Orchestrate TestFlight distribution, groups, testers, and What to Test notes using asc. Use when rolling out betas. |
| [wall-submit](app-store/app-store-connect/wall-submit/) | Submit or update a Wall of Apps entry in the App-Store-Connect-CLI repository using the existing generate-and-PR flow. Use when the user says "submit to wall of apps", "add my app to the wall", "wall-of-apps", or asks for make generate app + PR help. |
| [workflow](app-store/app-store-connect/workflow/) | Define, validate, and run repo-local multi-step automations with `asc workflow` and `.asc/workflow.json`. Use when migrating from lane tools, wiring CI pipelines, or orchestrating repeatable `asc` + shell release flows with hooks, conditionals, and sub-workflows. |
| [xcode-build](app-store/app-store-connect/xcode-build/) | Build, archive, and export iOS/macOS apps with xcodebuild before uploading to App Store Connect. Use when you need to create an IPA or PKG for upload. |
| [app-store-screenshots](app-store/app-store-screenshots/) | Generate production-ready App Store marketing screenshots for iOS apps using a Next.js generator. Screenshots are designed as ads (not UI showcases) and exported at all 4 Apple-required sizes (6.9", 6.5", 6.3", 6.1"). Use when asked to create App Store screenshots, generate marketing screenshot… |
| [aso](app-store/aso/) | ASO skills for Bloom — keyword research, audits, metadata optimization, competitor analysis using DataForSEO. Use when the user asks about App Store Optimization, improving Bloom's App Store ranking, keyword strategy, metadata, or competitor analysis for mobile apps. |
| [aso-audit](app-store/aso/aso-audit/) | When the user wants a full ASO health audit, review their App Store listing quality, or diagnose why their app isn't ranking. Also use when the user mentions "ASO audit", "ASO score", "why am I not ranking", "listing review", or "optimize my app store page". For keyword-specific research, see… |
| [competitor-analysis](app-store/aso/competitor-analysis/) | When the user wants to analyze competitors' App Store strategy, find keyword gaps, or understand competitive positioning. Also use when the user mentions "competitor analysis", "competitive research", "keyword gap", "what are my competitors doing", or "compare my app to". For keyword-specific… |
| [keyword-research](app-store/aso/keyword-research/) | When the user wants to discover, evaluate, or prioritize App Store keywords. Also use when the user mentions "keyword research", "find keywords", "search volume", "keyword difficulty", "keyword ideas", or "what keywords should I target". For implementing keywords into metadata, see… |
| [metadata-optimization](app-store/aso/metadata-optimization/) | When the user wants to optimize App Store metadata — title, subtitle, keyword field, or description. Also use when the user mentions "optimize my title", "ASO metadata", "keyword field", "character limits", "app description", or "write my subtitle". For keyword discovery, see keyword-research.… |
| [ios-simulator](app-store/ios-simulator/) | Use when automating iOS Simulator tasks with 21 accessibility-driven scripts: building and running iOS apps, device lifecycle management, screenshot capture, UI navigation via accessibility, gesture replay, app install/launch, status bar configuration, and health checks. Also use for iOS testing… |
| [revenuecat-cli](app-store/revenuecat-cli/) | Use when querying RevenueCat for projects, apps, products, entitlements, offerings, packages, customers, subscriptions, purchases, webhooks, or overview metrics via mcporter. Triggers on "revenuecat", "RC project", "list RC products", "check customer entitlement", "RC offering", "subscription… |

### 🌸 Bloom

| Skill | Description |
|-------|-------------|
| [bloom-cli](bloom/bloom-cli/) | Use when fetching stock data, company fundamentals, market data, earnings, SEC filings, price history, analyst ratings, peer comparisons, or financial research via the Bloom CLI. Use for 'what's AAPL trading at', 'show me TSLA earnings', 'compare tech stocks', or 'get market data'. |
| [demo-pr-feature](bloom/demo-pr-feature/) | Capture a demo screenshot or video of a Bloom PR's feature, deploy to Surge.sh, and post the URL as a GitHub PR comment. Use after pushing a fix to a frontend PR. |
| [fix-bloom-prs](bloom/fix-bloom-prs/) | Use when fixing CI failures, reviewing code, or addressing review comments on open PRs. Scans all tracked repos (Bloom, investing-log, skills), not just Bloom. |

### 💻 Coding & Development

| Skill | Description |
|-------|-------------|
| [babysit-open-prs](coding/babysit-open-prs/) | Scan all open PRs across tracked repos, triage them, check for scope drift, and spawn babysit-pr sub-agents for fixable ones. Use when: babysit all PRs, check all open PRs, nightly PR review. |
| [babysit-pr](coding/babysit-pr/) | Monitor a PR until it's ready to merge. Watches CI, reads reviews, checks scope, fixes issues, and repeats. Use when: babysit this PR, watch this PR, monitor PR, fix and watch PR, keep this PR green. |
| [claude-md-management](coding/claude-md-management/) | Use when asked to audit, improve, or maintain CLAUDE.md files across repos. Triggers on "audit my CLAUDE.md", "check if my CLAUDE.md is up to date", capturing session learnings, or keeping project memory current. |
| [codex](coding/codex/) | Get a second opinion from OpenAI Codex CLI — code review (pass/fail), adversarial challenge, or open consultation. Use when asked for "codex review", "second opinion", or "ask codex". |
| [context7](coding/context7/) | Use when writing code that uses a specific library or framework and you need accurate, current API docs — not year-old training data. Fetches version-specific documentation via Context7 MCP. |
| [fastapi-piccolo-typer-testing](coding/fastapi-piccolo-typer-testing/) | Patterns for writing fast, DB-free pytest suites against FastAPI routers, Piccolo ORM queries, Typer CLI commands, and service-layer code. Use when adding test coverage to a FastAPI + Piccolo + Typer app, mocking async ORM query chains, or testing Typer commands that lazily import services.… |
| [fintary-ops-center-context](coding/fintary-ops-center-context/) | Context and backlog for Fintary ops-center project |
| [firecrawl](coding/firecrawl/) | Scrape, crawl, search, and interact with web pages using Firecrawl CLI and API. Use when the user mentions "firecrawl", "scrape a website", "crawl a site", "map a site", "web scraping", "extract web data", "interact with a page", or needs richer web extraction than WebExtract (JS-rendered pages,… |
| [fix-sentry-issues](coding/fix-sentry-issues/) | Use when scanning Sentry issues for Bloom and creating fix PRs. |
| [godmode](coding/godmode/) | Jailbreak API-served LLMs using G0DM0D3 techniques — Parseltongue input obfuscation (33 techniques), GODMODE CLASSIC system prompt templates, ULTRAPLINIAN multi-model racing, encoding escalation, and Hermes-native prefill/system prompt integration. Use when a user wants to bypass safety filters,… |
| [jupyter-live-kernel](coding/jupyter-live-kernel/) | Use a live Jupyter kernel for stateful, iterative Python execution via hamelnb. Load this skill when the task involves exploration, iteration, or inspecting intermediate results — data science, ML experimentation, API exploration, or building up complex code step-by-step. Uses terminal to run… |
| [optimize-prompt](coding/optimize-prompt/) | Iteratively optimize Bloom's chat agent system prompt using a keep/revert autoresearch loop. Use when asked to optimize, improve, or tune Bloom's system prompt, run prompt optimization, or do a Karpathy-style autoresearch loop on the agent prompt. Also use when asked to run evals and improve the… |
| [plan](coding/plan/) | Plan mode for Hermes — inspect context, write a markdown plan into the active workspace's `.hermes/plans/` directory, and do not execute the work. |
| [ralph-mode](coding/ralph-mode/) | Run iterative self-referential development loops using the Ralph Wiggum technique. Use when tasks need repeated iteration, TDD cycles, greenfield builds, or autonomous refinement until tests pass or completion criteria are met. Triggers on ralph loop, ralph mode, iterative loop, autonomous loop. |
| [react-doctor](coding/react-doctor/) | Diagnose and fix React codebase health issues. Use when reviewing React code, fixing performance problems, auditing security, or improving code quality. |
| [requesting-code-review](coding/requesting-code-review/) | Pre-commit verification pipeline — static security scan, baseline-aware quality gates, independent reviewer subagent, and auto-fix loop. Use after code changes and before committing, pushing, or opening a PR. |
| [sentry-debug](coding/sentry-debug/) | Use when debugging production errors via Sentry — listing and searching issues, inspecting events and stack traces, checking release distribution, running Seer root-cause analysis, or resolving/assigning issues. Trigger phrases include "sentry", "production error", "what's crashing", "recent… |
| [serena](coding/serena/) | Use when navigating or editing a complex codebase at the symbol level — symbol lookup, references, precise edits via Serena MCP. Prefer over grepping files for accurate code navigation. |
| [simplify](coding/simplify/) | Review changed code for reuse, quality, and efficiency, then fix any issues found. TRIGGER when user says "simplify", "clean up code", "review my changes", "code review and fix", or "/simplify". |
| [superpowers-coding](coding/superpowers-coding/) | Use when implementing any feature or bugfix (TDD required before writing code), encountering any bug, test failure, or unexpected behavior (systematic debugging before proposing fixes), creating isolated git worktrees, or executing independent plan tasks via sub-agents. |
| [superpowers-planning](coding/superpowers-planning/) | You MUST use this before any creative work, feature, or implementation — explores intent and requirements first, creates detailed plans before touching code. Also use when establishing how to find and use skills at session start. |
| [superpowers-reviews](coding/superpowers-reviews/) | Use when requesting or receiving code review, verifying work before claiming it's done, finishing a development branch (merge/PR/discard), executing written plans with batch checkpoints, or dispatching parallel agents for independent tasks. |
| [systematic-debugging](coding/systematic-debugging/) | Use when encountering any bug, test failure, or unexpected behavior. 4-phase root cause investigation — NO fixes without understanding the problem first. |
| [test-driven-development](coding/test-driven-development/) | Use when implementing any feature or bugfix, before writing implementation code. Enforces RED-GREEN-REFACTOR cycle with test-first approach. |
| [writing-plans](coding/writing-plans/) | Use when you have a spec or requirements for a multi-step task. Creates comprehensive implementation plans with bite-sized tasks, exact file paths, and complete code examples. |

### 🎨 Creative & Content

| Skill | Description |
|-------|-------------|
| [architecture-diagram](creative/architecture-diagram/) | Generate dark-themed SVG diagrams of software systems and cloud infrastructure as standalone HTML files with inline SVG graphics. Semantic component colors (cyan=frontend, emerald=backend, violet=database, amber=cloud/AWS, rose=security, orange=message bus), JetBrains Mono font, grid background.… |
| [article-writer](creative/article-writer/) | Use when writing article drafts from approved outlines with SEO and brand voice. |
| [ascii-art](creative/ascii-art/) | Generate ASCII art using pyfiglet (571 fonts), cowsay, boxes, toilet, image-to-ascii, remote APIs (asciified, ascii.co.uk), and LLM fallback. No API keys required. |
| [ascii-video](creative/ascii-video/) | Production pipeline for ASCII art video — any format. Converts video/audio/images/generative input into colored ASCII character video output (MP4, GIF, image sequence). Covers: video-to-ASCII conversion, audio-reactive music visualizers, generative ASCII art animations, hybrid video+audio… |
| [character-creation](creative/character-creation/) | Create and manage consistent AI video characters — define the persona, generate the portrait with Nano Banana, and store the config for reuse across all videos in the series. |
| [creative-ideation](creative/creative-ideation/) | Generate project ideas through creative constraints. Use when the user says 'I want to build something', 'give me a project idea', 'I'm bored', 'what should I make', 'inspire me', or any variant of 'I have tools but no direction'. Works for code, art, hardware, writing, tools, and anything that… |
| [editor-in-chief](creative/editor-in-chief/) | Use when a first draft is complete and all Phase 1 gates are done: topic selected (seo-research), title approved (hooks), outline approved (outline-generator), draft written (article-writer). Runs autonomous diagnosis-prescribe-rewrite loop before Substack. |
| [evaluate-content](creative/evaluate-content/) | Use when judging content quality OR editing/improving existing copy: shareability, readability, voice, cuttability, angle, copy sweeps. |
| [excalidraw](creative/excalidraw/) | Create hand-drawn style diagrams using Excalidraw JSON format. Generate .excalidraw files for architecture diagrams, flowcharts, sequence diagrams, concept maps, and more. Files can be opened at excalidraw.com or uploaded for shareable links. |
| [gif-search](creative/gif-search/) | Search and download GIFs from Tenor using curl. No dependencies beyond curl and jq. Useful for finding reaction GIFs, creating visual content, and sending GIFs in chat. |
| [heartmula](creative/heartmula/) | Set up and run HeartMuLa, the open-source music generation model family (Suno-like). Generates full songs from lyrics + tags with multilingual support. |
| [klingai](creative/klingai/) | Official Kling AI Skill. Call Kling AI for video generation, image generation, and subject management. Use subcommand video / image / element by user intent. Use when the user mentions "Kling", "可灵", "文生视频", "图生视频", "文生图", "图生图", "AI 画图", "视频生成", "图片生成", "主体", "角色", "多镜头", "4K", "组图",… |
| [manim-video](creative/manim-video/) | Production pipeline for mathematical and technical animations using Manim Community Edition. Creates 3Blue1Brown-style explainer videos, algorithm visualizations, equation derivations, architecture diagrams, and data stories. Use when users request: animated explanations, math animations,… |
| [nano-banana-pro](creative/nano-banana-pro/) | Generate or edit images via Gemini 3 Pro Image Preview (Nano Banana Pro). Use when asked to generate an image, create artwork, edit a photo, add/remove elements from an image, compose multiple images, style transfer, create avatars, illustrations, or any visual content generation. Also use for… |
| [outline-generator](creative/outline-generator/) | Use when generating outlines, article structures, content outlines, blog outlines, planning article sections, structuring posts, breaking down topics into sections, or organizing ideas for long-form content. Also use for 'outline this', 'structure this article', or 'plan the sections'. |
| [p5js](creative/p5js/) | Production pipeline for interactive and generative visual art using p5.js. Creates browser-based sketches, generative art, data visualizations, interactive experiences, 3D scenes, audio-reactive visuals, and motion graphics — exported as HTML, PNG, GIF, MP4, or SVG. Covers: 2D/3D rendering,… |
| [popular-web-designs](creative/popular-web-designs/) | 54 production-quality design systems extracted from real websites. Load a template to generate HTML/CSS that matches the visual identity of sites like Stripe, Linear, Vercel, Notion, Airbnb, and more. Each template includes colors, typography, components, layout rules, and ready-to-use CSS values. |
| [remotion-best-practices](creative/remotion-best-practices/) | Use when writing or reviewing Remotion code — compositions, animations, captions, audio, charts, 3D, fonts, transitions, or any React-based video creation. Trigger phrases: Remotion, video in React, composition, useCurrentFrame, interpolate. |
| [screen-recording](creative/screen-recording/) | Record macOS screen via CLI with ffmpeg. Pair with peekaboo for automated UI demos. Use when recording tutorials, product walkthroughs, or automated demo videos. |
| [seedance](creative/seedance/) | Generate videos using ByteDance Seedance 2.0 via PiAPI. Triggers on "Seedance", "ByteDance video", "video generation", "text-to-video", "image-to-video". Supports text-to-video, image-to-video, video editing, and video extension. |
| [songsee](creative/songsee/) | Generate spectrograms and audio feature visualizations (mel, chroma, MFCC, tempogram, etc.) from audio files via CLI. Useful for audio analysis, music production debugging, and visual documentation. |
| [songwriting-and-ai-music](creative/songwriting-and-ai-music/) | Songwriting craft, AI music generation prompts (Suno focus), parody/adaptation techniques, phonetic tricks, and lessons learned. These are tools and ideas, not rules. Break any of them when the art calls for it. |
| [stock-footage](creative/stock-footage/) | Search and download free stock video footage from Pexels and Pixabay for B-roll and video production. Use when the user mentions "stock footage", "B-roll", "b-roll", "stock video", "find clips", "Pexels", "background footage", "video clips for", "find me a video of", "download stock video", or… |
| [substack-draft](creative/substack-draft/) | Use when saving a finished article to Substack as a draft for manual review and publishing. Does NOT publish automatically — always saves as draft. |
| [video-editor](creative/video-editor/) | Programmatic video editing via ffmpeg CLI. Handles trimming clips, merging/concatenating videos, overlays (picture-in-picture, watermarks, logos), crossfade transitions between clips, speed ramping (speed up/slow motion), cropping to aspect ratios (16:9 to 9:16), scaling/resizing, adding or… |
| [video-production](creative/video-production/) | Use when making videos, creating clips, voiceovers, talking avatars, AI video generation, text-to-video, lip sync, motion graphics, screen recordings, or video editing. Covers Sora, Kling, ElevenLabs, InfiniteTalk, Remotion, and ffmpeg workflows. Use for any request involving video creation,… |
| [browser-animation-video](creative/video-production/browser-animation-video/) | Use when create browser-based motion graphics with Framer Motion, GSAP, and Tailwind. |
| [demo-video](creative/video-production/demo-video/) | Create product demo videos by automating browser interactions and capturing frames. Use when the user wants to record a demo, walkthrough, product showcase, or interactive video of a web application. Supports Playwright CDP screencast for high-quality capture and FFmpeg for video encoding. |
| [elevenlabs](creative/video-production/elevenlabs/) | Generate voiceover audio from a script using ElevenLabs v3 via Fal.ai. Outputs an MP3 file for use with InfiniteTalk or standalone audio. |
| [gemini-svg](creative/video-production/gemini-svg/) | Use when generate interactive SVG animations via Gemini. |
| [infinitetalk](creative/video-production/infinitetalk/) | Generate a talking avatar video from a character image + audio file using InfiniteTalk via Fal.ai. Lip-syncs the audio to the character with full-body animation. |
| [kling](creative/video-production/kling/) | Generate AI videos with Kling 3.0 using cinematic directing techniques. Supports direct API execution (text-to-video, image-to-video, multi-shot, elements), Higgsfield browser automation, and prompt engineering. |
| [remotion-videos](creative/video-production/remotion-videos/) | Use when create animated marketing videos with Remotion (renders to MP4). |
| [sora](creative/video-production/sora/) | Use when generate, remix, and manage Sora AI videos. |
| [thumbnail](creative/video-production/thumbnail/) | Generate video cover frames and thumbnails for YouTube, TikTok, Reels, and social media. Use when asked for a video thumbnail, cover frame, YouTube thumbnail, or to extract a still from a video. |
| [video-script](creative/video-script/) | Generate structured scene-by-scene video scripts with production metadata (visuals, audio, sources, transitions, captions) ready to feed into the video-production pipeline (Sora, Kling, ElevenLabs, InfiniteTalk, Remotion, stock-footage, video-editor). Use when asked to "write a video script",… |
| [writer](creative/writer/) | Write content in Eric's voice — articles, blog posts, tweets, social media posts, marketing copy, newsletter drafts. Loads WRITING-STYLE.md and enforces kill phrases. |
| [youtube-content](creative/youtube-content/) | Fetch YouTube video transcripts and transform them into structured content (chapters, summaries, threads, blog posts). Use when the user shares a YouTube URL or video link, asks to summarize a video, requests a transcript, or wants to extract and reformat content from any YouTube video. |

### ⚙️ DevOps & Infrastructure

| Skill | Description |
|-------|-------------|
| [bulk-import-skills-from-git](devops/bulk-import-skills-from-git/) | Import skills from a GitHub repository (like exiao/skills or any skills bundle) into ~/.hermes/skills/, resolving naming conflicts and preserving directory structure. Use when a user shares a skills repo URL or wants to install a skills pack. |
| [cloud-migration](devops/cloud-migration/) | Execute full cloud provider migrations end-to-end — provision the new environment, migrate all data (Postgres, Redis, object storage), transfer env vars/secrets, deploy the app, verify data parity, cut over DNS, and clean up the old provider. Use this skill whenever someone wants to move their… |
| [modal](devops/cloud/modal/) | Serverless GPU cloud platform for running ML workloads. Use when you need on-demand GPU access without infrastructure management, deploying ML models as APIs, or running batch jobs with automatic scaling. |
| [codebase-inspection](devops/codebase-inspection/) | Inspect and analyze codebases using pygount for LOC counting, language breakdown, and code-vs-comment ratios. Use when asked to check lines of code, repo size, language composition, or codebase stats. |
| [dependabot-stuck-pr-rebase](devops/dependabot-stuck-pr-rebase/) | Manually rebase Dependabot PRs that are stuck in CONFLICTING state because @dependabot rebase / recreate isn't firing. Use when multiple Dependabot PRs show mergeStateStatus=CONFLICTING after main has moved, and waiting for Dependabot is taking too long. |
| [deploy-bloom](devops/deploy-bloom/) | Use when deploying Bloom OTA updates via the bloom-updater pipeline. |
| [document-release](devops/document-release/) | Update all project documentation to match what was just shipped. Use after merging a PR or shipping a feature to catch stale READMEs and drifted docs. |
| [documents](devops/documents/) | Use when working with any office document format: .docx Word files (creating, editing, tracked changes, reports, memos, templates); PDF files (reading, merging, splitting, OCR, watermarks, form filling, creating); .pptx presentations (decks, slides, editing templates, speaker notes); .xlsx… |
| [lm-evaluation-harness](devops/evaluation/lm-evaluation-harness/) | Evaluates LLMs across 60+ academic benchmarks (MMLU, HumanEval, GSM8K, TruthfulQA, HellaSwag). Use when benchmarking model quality, comparing models, reporting academic results, or tracking training progress. Industry standard used by EleutherAI, HuggingFace, and major labs. Supports… |
| [weights-and-biases](devops/evaluation/weights-and-biases/) | Track ML experiments with automatic logging, visualize training in real-time, optimize hyperparameters with sweeps, and manage model registry with W&B - collaborative MLOps platform |
| [github-auth](devops/github-auth/) | Set up GitHub authentication for the agent using git (universally available) or the gh CLI. Covers HTTPS tokens, SSH keys, credential helpers, and gh auth — with a detection flow to pick the right method automatically. |
| [github-code-review](devops/github-code-review/) | Review code changes by analyzing git diffs, leaving inline comments on PRs, and performing thorough pre-push review. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-issues](devops/github-issues/) | Create, manage, triage, and close GitHub issues. Search existing issues, add labels, assign people, and link to PRs. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-pr-workflow](devops/github-pr-workflow/) | Full pull request lifecycle — create branches, commit changes, open PRs, monitor CI status, auto-fix failures, and merge. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-repo-management](devops/github-repo-management/) | Clone, create, fork, configure, and manage GitHub repositories. Manage remotes, secrets, releases, and workflows. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-rulesets-bulk-apply](devops/github-rulesets-bulk-apply/) | Apply a branch-protection ruleset (deletion + non_fast_forward, no bypass) to the default branch of every repo an account admins. Use when the user wants to protect all their repos from accidental branch deletion or force-push across an entire GitHub account/org footprint. Handles the GitHub… |
| [hermes-proxy-routing-fix](devops/hermes-proxy-routing-fix/) | Fix for Hermes not routing Anthropic requests through local billing proxy |
| [huggingface-hub](devops/huggingface-hub/) | Hugging Face Hub CLI (hf) — search, download, and upload models and datasets, manage repos, query datasets with SQL, deploy inference endpoints, manage Spaces and buckets. |
| [gguf](devops/inference/gguf/) | GGUF format and llama.cpp quantization for efficient CPU/GPU inference. Use when deploying models on consumer hardware, Apple Silicon, or when needing flexible quantization from 2-8 bit without GPU requirements. |
| [guidance](devops/inference/guidance/) | Control LLM output with regex and grammars, guarantee valid JSON/XML/code generation, enforce structured formats, and build multi-step workflows with Guidance - Microsoft Research's constrained generation framework |
| [llama-cpp](devops/inference/llama-cpp/) | Runs LLM inference on CPU, Apple Silicon, and consumer GPUs without NVIDIA hardware. Use for edge deployment, M1/M2/M3 Macs, AMD/Intel GPUs, or when CUDA is unavailable. Supports GGUF quantization (1.5-8 bit) for reduced memory and 4-10× speedup vs PyTorch on CPU. |
| [obliteratus](devops/inference/obliteratus/) | Remove refusal behaviors from open-weight LLMs using OBLITERATUS — mechanistic interpretability techniques (diff-in-means, SVD, whitened SVD, LEACE, SAE decomposition, etc.) to excise guardrails while preserving reasoning. 9 CLI methods, 28 analysis modules, 116 model presets across 5 compute… |
| [outlines](devops/inference/outlines/) | Guarantee valid JSON/XML/code structure during generation, use Pydantic models for type-safe outputs, support local models (Transformers, vLLM), and maximize inference speed with Outlines - dottxt.ai's structured generation library |
| [vllm](devops/inference/vllm/) | Serves LLMs with high throughput using vLLM's PagedAttention and continuous batching. Use when deploying production LLM APIs, optimizing inference latency/throughput, or serving models with limited GPU memory. Supports OpenAI-compatible endpoints, quantization (GPTQ/AWQ/FP8), and tensor parallelism. |
| [audiocraft](devops/models/audiocraft/) | PyTorch library for audio generation including text-to-music (MusicGen) and text-to-sound (AudioGen). Use when you need to generate music from text descriptions, create sound effects, or perform melody-conditioned music generation. |
| [clip](devops/models/clip/) | OpenAI's model connecting vision and language. Enables zero-shot image classification, image-text matching, and cross-modal retrieval. Trained on 400M image-text pairs. Use for image search, content moderation, or vision-language tasks without fine-tuning. Best for general-purpose image… |
| [segment-anything](devops/models/segment-anything/) | Foundation model for image segmentation with zero-shot transfer. Use when you need to segment any object in images using points, boxes, or masks as prompts, or automatically generate all object masks in an image. |
| [stable-diffusion](devops/models/stable-diffusion/) | State-of-the-art text-to-image generation with Stable Diffusion models via HuggingFace Diffusers. Use when generating images from text prompts, performing image-to-image translation, inpainting, or building custom diffusion pipelines. |
| [whisper](devops/models/whisper/) | OpenAI's general-purpose speech recognition model. Supports 99 languages, transcription, translation to English, and language identification. Six model sizes from tiny (39M params) to large (1550M params). Use for speech-to-text, podcast transcription, or multilingual audio processing. Best for… |
| [openclaw-docker-debug](devops/openclaw-docker-debug/) | Debug OpenClaw issues when deployed via Docker Compose. Covers finding containers, reading logs, health checks, config inspection, and diagnosing channel crash loops. Use when OpenClaw is running in Docker and something is wrong (channels down, crashes, auth issues). |
| [phoenix-cli](devops/phoenix-cli/) | Use when debugging LLM apps with Phoenix CLI: traces, errors, experiments. |
| [porkbun](devops/porkbun/) | Manage Porkbun domains, DNS records, SSL certificates, URL forwarding, and hosting blueprints via the Porkbun API. Use when the user asks about domain management, DNS, SSL certs, URL redirects, or connecting a domain to a hosting provider. |
| [porkbun-dns](devops/porkbun/porkbun-dns/) | Use this skill to manage DNS records (A, CNAME, MX, TXT, etc.). It prioritizes safety by backing up records before major changes and explaining technical concepts in plain English. |
| [porkbun-domains](devops/porkbun/porkbun-domains/) | Use this skill to list domains, check their status, viewing expiration dates, and seeing nameserver configuration. |
| [porkbun-forwards](devops/porkbun/porkbun-forwards/) | Use this skill to redirect one domain or subdomain to another URL. |
| [porkbun-hosting-blueprints](devops/porkbun/porkbun-hosting-blueprints/) | Use this skill to apply complete, vendor-recommended DNS configurations for popular hosting platforms (Vercel, Netlify, GitHub Pages, etc.) in one go. |
| [porkbun-setup](devops/porkbun/porkbun-setup/) | Use this skill to configure Porkbun API credentials or troubleshoot connection issues. It securely stores API keys in ~/.porkbun/credentials.json and verifies connectivity. |
| [porkbun-ssl](devops/porkbun/porkbun-ssl/) | Use this skill to retrieve and download SSL certificates for domains. |
| [railway](devops/railway/) | Deploy, manage, and operate Railway projects via CLI and MCP. Use when creating Railway services, deploying code, adding databases (Postgres, Redis), setting environment variables, viewing logs, managing domains, or doing anything with Railway infrastructure. Also use when asked about the Bloom… |
| [render-cli](devops/render-cli/) | Manage Render.com services, deploys, databases, logs, and infrastructure using the official Render CLI (`render`). Use this skill whenever the user asks about Render deployments, service management, viewing Render logs, restarting Render services, running database queries on Render Postgres,… |
| [dspy](devops/research/dspy/) | Build complex AI systems with declarative programming, optimize prompts automatically, create modular RAG systems and agents with DSPy - Stanford NLP's framework for systematic LM programming |
| [security-audit](devops/security-audit/) | Run a codebase security audit using OWASP Top 10 and STRIDE threat modeling. Use when auditing code for vulnerabilities or preparing for a pentest. |
| [stably-cli](devops/stably-cli/) | Use the Stably CLI to create, run, fix, and maintain Playwright tests in the bloom-tests repo. Use when running tests (stably test), auto-fixing failures (stably fix), or generating new tests from a prompt (stably create). |
| [stably-sdk-rules](devops/stably-sdk-rules/) | Best practices for writing Stably AI-powered Playwright tests. Use when writing, reviewing, or debugging tests in bloom-tests that use @stablyai/playwright-test — covers when to use aiAssert vs raw Playwright, agent.act, extract, getLocatorsByAI, and email flows. |
| [axolotl](devops/training/axolotl/) | Expert guidance for fine-tuning LLMs with Axolotl - YAML configs, 100+ models, LoRA/QLoRA, DPO/KTO/ORPO/GRPO, multimodal support |
| [grpo-rl-training](devops/training/grpo-rl-training/) | Expert guidance for GRPO/RL fine-tuning with TRL for reasoning and task-specific model training |
| [peft](devops/training/peft/) | Parameter-efficient fine-tuning for LLMs using LoRA, QLoRA, and 25+ methods. Use when fine-tuning large models (7B-70B) with limited GPU memory, when you need to train <1% of parameters with minimal accuracy loss, or for multi-adapter serving. HuggingFace's official library integrated with… |
| [pytorch-fsdp](devops/training/pytorch-fsdp/) | Expert guidance for Fully Sharded Data Parallel training with PyTorch FSDP - parameter sharding, mixed precision, CPU offloading, FSDP2 |
| [trl-fine-tuning](devops/training/trl-fine-tuning/) | Fine-tune LLMs using reinforcement learning with TRL - SFT for instruction tuning, DPO for preference alignment, PPO/GRPO for reward optimization, and reward model training. Use when need RLHF, align model with preferences, or train from human feedback. Works with HuggingFace Transformers. |
| [unsloth](devops/training/unsloth/) | Expert guidance for fast fine-tuning with Unsloth - 2-5x faster training, 50-80% less memory, LoRA/QLoRA optimization |
| [verify-deploy](devops/verify-deploy/) | Post-merge deploy verification. Waits for deploy, benchmarks production, monitors for regressions. Use after merging a PR to confirm the deploy is healthy. |
| [webhook-subscriptions](devops/webhook-subscriptions/) | Create and manage webhook subscriptions for event-driven agent activation. Use when the user wants external services to trigger agent runs automatically. |

### 💰 Finance & Investing

| Skill | Description |
|-------|-------------|
| [alpaca](finance/alpaca/) | Trade stocks and crypto via Alpaca API. Use for market data (quotes, bars, news), placing orders (market, limit, stop), checking positions, portfolio management, and account info. Supports both paper and live trading. Use when user asks about stock prices, wants to buy/sell securities, check… |
| [copilot-money](finance/copilot-money/) | Use when querying Copilot Money for finances, transactions, net worth, and holdings. |
| [earnings-card-pipeline](finance/earnings-card-pipeline/) | Use when the cron fires at 8am ET on Mondays — pulls the week's major earnings events, generates a die-cut sticker style card for each, creates Typefully drafts, and reports to Signal. |
| [market-daily-briefing](finance/market-daily-briefing/) | Use when delivering a daily market briefing — covering earnings results, macro news, and notable stock moves. Runs automatically at 10am ET Mon-Fri via cron, or on-demand when asked for a market update. |
| [polymarket](finance/polymarket/) | Query Polymarket prediction markets via the polymarket CLI. Browse markets, search topics, check prices, order books, and view events. Use when a user asks about prediction markets, odds, or "what does Polymarket say about X". |
| [post-insider-trades](finance/post-insider-trades/) | Use when the cron fires at 9am or 2pm ET on weekdays — scrapes OpenInsider for significant recent insider buys, generates a brokerage-receipt trade card, writes a tweet, creates a Typefully draft, and reports to Signal. |
| [post-investinglog-trades](finance/post-investinglog-trades/) | Use when the cron fires at 4pm ET on weekdays — picks the best unposted trade from the investing-log repo, generates a trade card, creates a Typefully draft, and reports to Signal. |
| [stock-research](finance/stock-research/) | Use when performing stock or equity research, earnings analysis, coverage reports, or generating daily market briefings for Bloom. Covers on-demand research tasks and the scheduled daily market briefing cron job. |
| [wealth-management](finance/wealth-management/) | Wealth management workflows — client review prep, financial plans, investment proposals, portfolio rebalancing, and tax-loss harvesting. Adapted from Anthropic's financial-services-plugins (github.com/anthropics/financial-services-plugins). |

### 🔧 Runtime & Platform

| Skill | Description |
|-------|-------------|
| [claude-auth-remote-login](hermes/claude-auth-remote-login/) | Remote Claude Code OAuth login flow when token expires. Use when `claude auth status` reports logged in but `claude -p` returns 401, or when needing to re-authenticate over SSH. Trigger phrases include "claude auth", "claude login", "token expired", "claude 401", "remote login", "oauth claude". |
| [dogfood](hermes/dogfood/) | Use when asked to dogfood, QA, exploratory test, find issues, bug hunt, or review the quality of a web application. Produces a structured report with full reproduction evidence (screenshots, repro steps) so findings can be handed directly to responsible teams. |
| [exiao-skills-pr-conventions](hermes/exiao-skills-pr-conventions/) | Use when contributing a skill to the public exiao/skills GitHub repo. Covers repo layout rules, frontmatter, sanitization (no creds/personal data), README updates, and PR workflow. Trigger on "PR to exiao/skills", "publish this skill", "contribute skill", or any request to push a skill upstream. |
| [hermes-add-tool-pattern](hermes/hermes-add-tool-pattern/) | Pattern for adding a new tool to the Hermes agent framework |
| [hermes-context-files](hermes/hermes-context-files/) | How Hermes discovers and loads context files (SOUL.md, AGENTS.md, HERMES.md, CLAUDE.md). Use when asked how Hermes loads context, which files are auto-loaded vs on-demand, how SOUL.md/AGENTS.md discovery works, symlink patterns for context files, or how to configure cwd-based context file… |
| [hermes-model-alias-config](hermes/hermes-model-alias-config/) | Configure custom model aliases in Hermes to bypass buggy catalog resolution |
| [hermes-model-aliases](hermes/hermes-model-aliases/) | Fix broken Hermes model switching shortcuts with custom aliases in config.yaml |
| [hermes-quick-command-alias](hermes/hermes-quick-command-alias/) | How to set up slash command aliases in Hermes via quick_commands config |
| [hermes-signal-italic-fix](hermes/hermes-signal-italic-fix/) | Fix false-positive italics in Signal adapter caused by snake_case underscores. Use when Signal messages show random italics around snake_case identifiers like `config_file` or `OPENAI_API_KEY`. Trigger phrases include "signal italics", "snake_case italic", "Signal formatting bug", "underscore… |
| [hermes-signal-reply-fix](hermes/hermes-signal-reply-fix/) | Fix for Signal reply context not being passed into Hermes gateway |
| [hermes-signal-streaming-cursor-fix](hermes/hermes-signal-streaming-cursor-fix/) | Diagnose and fix black-square / cursor artifacts in Hermes Signal conversations caused by edit-based streaming assumptions on non-editable platforms. |
| [memory-gc](hermes/memory-gc/) | Daily memory garbage collection for MEMORY.md / USER.md. Apply decay rules, drain .pending.md, consolidate near-duplicates, maintain canonical theme tags, prune old episode and session files. Invoke when asked to "run memory GC", "clean up memory", "apply memory decay", or from the scheduled… |
| [openclaw-billing-proxy-client-support](hermes/openclaw-billing-proxy-client-support/) | Extend the openclaw-billing-proxy to support a new client fingerprint (for example Hermes) by adding trigger-string sanitization, tool renames, reverse mappings, docs, and a regression test. |
| [openclaw-memory-setup](hermes/openclaw-memory-setup/) | Set up a complete memory system for an OpenClaw instance. Covers workspace files, vector search with embeddings, compaction with automatic memory flush, heartbeat-driven memory maintenance, and daily/long-term memory patterns. Use when someone wants their OpenClaw agent to remember things across… |
| [openclaw-resiliency](hermes/openclaw-resiliency/) | Set up a gateway watchdog that monitors OpenClaw health and auto-recovers from failures. Covers 3-tier health checks (process, HTTP, channel deep health), exponential backoff, signal-cli special handling, and launchd/systemd integration. Use when someone wants their OpenClaw instance to… |
| [recall](hermes/recall/) | Retrieve memory from past sessions. Use whenever the user asks about past conversations, prior decisions, "what did we do about X", "when did we last...", "do you remember...", or anything where the answer might live outside the current session's context. Uses progressive disclosure across six… |
| [signal-message-splitting-bug](hermes/signal-message-splitting-bug/) | Investigation and fix plan for Signal splitting short bot responses into multiple bubbles |
| [signal-send-file](hermes/signal-send-file/) | Send files (images, PNGs, PDFs, videos, documents, anything) as native attachments on Signal, Telegram, Discord, Slack, WhatsApp, or any messaging gateway. Use whenever a user asks to "send", "share", "attach", "send again", or "resend" a file or image, or when your reply needs to include a… |
| [signal-table-render](hermes/signal-table-render/) | Auto-render markdown tables to PNG before sending on Signal. Signal's chat UI does not render markdown tables — pipes and dashes show as literal text. When an outgoing message to a Signal chat contains a markdown table (pipe-and-dash format), pipe it through `~/.hermes/bin/md-table-png` and… |
| [skill-audit](hermes/skill-audit/) | Audit and score any skill against best practices. Use when: audit this skill, review this skill, check this skill, score this skill, is this skill good, skill health check, skill review, rate this skill. Takes a skill directory path, evaluates structure/content/patterns against a checklist, and… |
| [skill-improver](hermes/skill-improver/) | Autonomously optimize any Claude Code skill by running it repeatedly, scoring outputs against binary evals, mutating the prompt, and keeping improvements. Based on Karpathy's autoresearch methodology. Use when: optimize this skill, improve this skill, run autoresearch on, make this skill better,… |
| [watchdog-status-cleanup](hermes/watchdog-status-cleanup/) | Inspect Hermes/OpenClaw watchdog LaunchAgents on macOS and clean up stale signal-cli send jobs or proxy launcher shells that make status output noisy. |

### 📈 Marketing & Growth

| Skill | Description |
|-------|-------------|
| [appfigures](marketing/appfigures/) | Use when querying Appfigures for app store analytics (downloads, revenue, reviews, rankings). |
| [apple-search-ads](marketing/apple-search-ads/) | Create, optimize, and scale Apple Search Ads campaigns with API automation, attribution integration, and bid strategy recommendations. |
| [brand-identity](marketing/brand-identity/) | Build a complete brand identity from scratch or refresh an existing one — for solopreneurs, apps, and consumer products. Covers brand purpose, values, personality, voice and tone, visual identity system (colors, typography, logo direction, imagery style), and brand guidelines. Includes a… |
| [churn-prevention](marketing/churn-prevention/) | When the user wants to reduce churn, build cancellation flows, set up save offers, improve retention, or recover failed payments. Also use when the user mentions 'churn,' 'cancel flow,' 'offboarding,' 'save offer,' 'dunning,' 'failed payment recovery,' 'win-back,' 'retention,' 'exit survey,'… |
| [cold-email](marketing/cold-email/) | Write B2B cold emails and follow-up sequences that get replies. Use when someone wants cold outreach, prospecting emails, SDR emails, or says 'nobody's replying to my emails.' |
| [common-crawl-backlinks](marketing/common-crawl-backlinks/) | Use when pulling backlinks for any domain for free using Common Crawl's web graph — instead of paying for Ahrefs/Majestic/SEMrush. Triggers on 'backlinks for', 'who links to', 'backlink check', 'common crawl backlinks', 'free backlinks', or any backlink discovery task. Replaces $hundreds/mo SEO… |
| [competitive-analysis](marketing/competitive-analysis/) | Use when researching competitors and building interactive battlecards. |
| [content-performance-report](marketing/content-performance-report/) | Use when the cron fires at 9am ET on Mondays — pulls Typefully published posts from the last 30 days, classifies them by content pillar, pulls Appfigures download data, scores each pillar, and sends a weekly report to Signal. |
| [content-pipeline](marketing/content-pipeline/) | Orchestrator for the 3-article content pipeline — runs research phase, spawns parallel article sub-agents, creates Typefully drafts. Use when running the full content pipeline (usually via cron at 3am). |
| [content-strategy](marketing/content-strategy/) | Use when building content strategy: hooks, angles, and ideas from what's trending now. Covers organic and paid creative across TikTok, X, YouTube, Meta, LinkedIn. |
| [copywriting](marketing/copywriting/) | Write or improve marketing copy for any surface: pages, ads, app stores, landing pages, TikTok/Meta scripts, push notifications, UGC. Combines page copy frameworks with direct response principles. |
| [create-app-onboarding](marketing/create-app-onboarding/) | TRIGGER when the user asks to design, build, or improve an app onboarding flow, onboarding questionnaire, first-run experience, or signup funnel. Also trigger on "conversion optimization for onboarding", "reduce onboarding drop-off", "questionnaire-style onboarding", or "subscription app… |
| [dataforseo](marketing/dataforseo/) | Use when doing keyword research (volume, difficulty, ideas), checking App Store or Google Play rankings for Bloom or competitors, or looking up Google SERP rankings for content/landing pages. Also use when building ASO keyword lists or finding App Store competitors. |
| [email-sequence](marketing/email-sequence/) | When the user wants to create or optimize an email sequence, drip campaign, push notification flow, or lifecycle messaging program. Also use when the user mentions 'email sequence,' 'drip campaign,' 'onboarding emails,' 'welcome sequence,' 're-engagement emails,' 'lifecycle emails,' 'push… |
| [google-ads](marketing/google-ads/) | Use when managing Google Ads campaigns: performance checks, keyword pausing, report downloads, or campaign optimization via browser or API. |
| [google-ads-scripts](marketing/google-ads-scripts/) | Expert guidance for Google Ads Script development including AdsApp API, campaign management, ad groups, keywords, bidding strategies, performance reporting, budget management, automated rules, and optimization patterns. Use when automating Google Ads campaigns, managing keywords and bids,… |
| [growth](marketing/growth/) | Use when optimizing growth across the full funnel: in-product CRO (signup, onboarding, paywalls, churn) and go-to-market strategy (launches, pricing, email, referrals, A/B tests, psychology). |
| [hooks](marketing/hooks/) | Use when generating hooks, headlines, titles, and scroll-stopping openers for content. |
| [last30days](marketing/last30days/) | Use when researching what happened in the last 30 days on a topic. Also triggered by 'last30'. Sources: Reddit, X, YouTube, web. Produces expert-level summary with copy-paste-ready prompts. |
| [open](marketing/last30days/variants/open/) | Research topics, manage watchlists, get briefings, query history. Also triggered by 'last30'. Sources: Reddit, X, YouTube, web. |
| [launch-strategy](marketing/launch-strategy/) | When the user wants to plan a product launch, feature announcement, or release strategy. Use when someone mentions 'launch,' 'Product Hunt,' 'feature release,' 'go-to-market,' 'beta launch,' 'early access,' 'waitlist,' or 'launch checklist.' |
| [marketing-psychology](marketing/marketing-psychology/) | When the user wants to apply psychological principles, mental models, or behavioral science to marketing. Use when someone mentions 'psychology,' 'mental models,' 'cognitive bias,' 'persuasion,' 'behavioral science,' 'anchoring,' 'social proof,' 'scarcity,' 'loss aversion,' 'framing,' or 'nudge.' |
| [meta-ads](marketing/meta-ads/) | Daily Meta ad operations via Marketing API — check performance, kill losers, promote winners, generate 6 fresh creatives via Nano Banana Pro, upload as new ads, and report to Signal. Runs as cron at 4am ET. |
| [meta-ads-creative](marketing/meta-ads-creative/) | Create high-converting Meta (Facebook/Instagram) ad creative using the 6 Elements framework, proven ad formats, and research-driven copywriting. Use when creating Facebook ads, Instagram ad creative, writing ad copy for Meta campaigns, A/B testing ad variations, or optimizing ad performance.… |
| [notebooklm](marketing/notebooklm/) | Use this skill to query your Google NotebookLM notebooks directly from Claude Code for source-grounded, citation-backed answers from Gemini. Also use to generate slide decks, mind maps, audio overviews, and other Studio outputs from YouTube videos or any source. Two approaches available - CLI… |
| [paid-ads](marketing/paid-ads/) | When the user wants help with paid advertising campaigns on Google Ads, Meta, LinkedIn, Twitter/X, or other platforms. Use when someone mentions 'PPC,' 'paid media,' 'ROAS,' 'CPA,' 'ad campaign,' 'retargeting,' 'Google Ads,' 'Facebook ads,' 'ad budget,' or 'should I run ads.' For Meta API… |
| [positioning-angles](marketing/positioning-angles/) | Use when defining product positioning, choosing strategic angles, crafting value propositions, competitive positioning, product messaging, differentiation strategy, or go-to-market angles. Also use for 'how should I position my app', 'what angle should I use', 'painkiller vs vitamin', or 'market… |
| [post-bloom-features](marketing/post-bloom-features/) | Use when the cron fires at 1am ET on Tuesday or Thursday — runs preflight to find user-facing PRs, screenshots the feature in iOS simulator, renders a Remotion video, creates an unscheduled Typefully draft, and reports to Signal. |
| [pricing-strategy](marketing/pricing-strategy/) | When the user wants help with pricing decisions, packaging, or monetization strategy. Use when someone mentions 'pricing,' 'pricing tiers,' 'freemium,' 'free trial,' 'value metric,' 'willingness to pay,' 'how much should I charge,' 'annual vs monthly,' or 'should I offer a free plan.' |
| [product-marketing-context](marketing/product-marketing-context/) | When the user wants to create or update their product marketing context document. Use at the start of any new project before using other marketing skills. Creates a context file that all other skills reference for product, audience, and positioning info. |
| [prometheus](marketing/prometheus/) | Search TikTok viral videos, App Store rankings, hook analysis, app strategy, and content research via SGE Prometheus MCP. Requires SGE_API_KEY. Use when researching viral video hooks, benchmarking app rankings, analyzing content trends, or pulling App Store review data. Trigger phrases include… |
| [referral-program](marketing/referral-program/) | When the user wants to create, optimize, or analyze a referral program, affiliate program, or word-of-mouth strategy. Use when someone mentions 'referral,' 'affiliate,' 'ambassador,' 'word of mouth,' 'viral loop,' 'refer a friend,' or 'partner program.' |
| [seo-research](marketing/seo-research/) | Use when doing SEO research: keyword research, AI search optimization, technical audits, schema markup. |
| [trend-research](marketing/trend-research/) | Use when researching what's trending, viral content, social media trends, content ideas from trends, or platform-specific trends on TikTok, YouTube, Instagram, X/Twitter, Substack, LinkedIn, Reddit, and Lemon8. Also use for 'what's viral', 'what's working on social', 'trend report', 'what hooks… |
| [tweet-ideas](marketing/tweet-ideas/) | Use when generating 10-20 standalone tweets to build topical authority on a subject. Not for threads or promos. Uses the Aaron Levie playbook. |
| [typefully](marketing/typefully/) | Use when creating, scheduling, or managing social posts via Typefully. |
| [whop-content-rewards](marketing/whop-content-rewards/) | Set up and manage Content Rewards UGC campaigns on Whop for Bloom. Use when launching new campaigns, adding budget, reviewing submissions, or checking campaign performance. |
| [xitter](marketing/xitter/) | Interact with X/Twitter via the x-cli terminal client using official X API credentials. Use for posting, reading timelines, searching tweets, liking, retweeting, bookmarks, mentions, and user lookups. |

### 📋 Productivity

| Skill | Description |
|-------|-------------|
| [apple-notes](productivity/apple-notes/) | Manage Apple Notes via the memo CLI on macOS (create, view, search, edit). |
| [apple-reminders](productivity/apple-reminders/) | Manage Apple Reminders via remindctl CLI (list, add, complete, delete). |
| [find-nearby](productivity/find-nearby/) | Find nearby places (restaurants, cafes, bars, pharmacies, etc.) using OpenStreetMap. Works with coordinates, addresses, cities, zip codes, or Telegram location pins. No API keys needed. |
| [findmy](productivity/findmy/) | Track Apple devices and AirTags via FindMy.app on macOS using AppleScript and screen capture. |
| [google-workspace](productivity/google-workspace/) | Gmail, Calendar, Drive, Contacts, Sheets, and Docs integration for Hermes. Uses Hermes-managed OAuth2 setup, prefers the Google Workspace CLI (`gws`) when available for broader API coverage, and falls back to the Python client libraries otherwise. |
| [himalaya](productivity/himalaya/) | CLI to manage emails via IMAP/SMTP. Use himalaya to list, read, write, reply, forward, search, and organize emails from the terminal. Supports multiple accounts and message composition with MML (MIME Meta Language). |
| [imessage](productivity/imessage/) | Send and receive iMessages/SMS via the imsg CLI on macOS. |
| [linear](productivity/linear/) | Manage Linear issues, projects, and teams via the GraphQL API. Create, update, search, and organize issues. Uses API key auth (no OAuth needed). All operations via curl — no dependencies. |
| [minecraft-modpack-server](productivity/minecraft-modpack-server/) | Set up a modded Minecraft server from a CurseForge/Modrinth server pack zip. Covers NeoForge/Forge install, Java version, JVM tuning, firewall, LAN config, backups, and launch scripts. |
| [nano-pdf](productivity/nano-pdf/) | Edit PDFs with natural-language instructions using the nano-pdf CLI. Modify text, fix typos, update titles, and make content changes to specific pages without manual editing. |
| [notion](productivity/notion/) | Notion API for creating and managing pages, databases, and blocks via curl. Search, create, update, and query Notion workspaces directly from the terminal. |
| [obsidian](productivity/obsidian/) | Read, search, and create notes in the Obsidian vault. |
| [ocr-and-documents](productivity/ocr-and-documents/) | Extract text from PDFs and scanned documents. Use web_extract for remote URLs, pymupdf for local text-based PDFs, marker-pdf for OCR/scanned docs. For DOCX use python-docx, for PPTX see the powerpoint skill. |
| [openhue](productivity/openhue/) | Control Philips Hue lights, rooms, and scenes via the OpenHue CLI. Turn lights on/off, adjust brightness, color, color temperature, and activate scenes. |
| [pokemon-player](productivity/pokemon-player/) | Play Pokemon games autonomously via headless emulation. Starts a game server, reads structured game state from RAM, makes strategic decisions, and sends button inputs — all from the terminal. |
| [powerpoint](productivity/powerpoint/) | Use this skill any time a .pptx file is involved in any way — as input, output, or both. This includes: creating slide decks, pitch decks, or presentations; reading, parsing, or extracting text from any .pptx file (even if the extracted content will be used elsewhere, like in an email or… |

### 🔍 Research

| Skill | Description |
|-------|-------------|
| [arxiv](research/arxiv/) | Search and retrieve academic papers from arXiv using their free REST API. No API key needed. Search by keyword, author, category, or ID. Combine with web_extract or the ocr-and-documents skill to read full paper content. |
| [blogwatcher](research/blogwatcher/) | Monitor blogs and RSS/Atom feeds for updates using the blogwatcher-cli tool. Add blogs, scan for new articles, track read status, and filter by category. |
| [hotel-price-research](research/hotel-price-research/) | Research hotel pricing across OTAs for a booking decision. Use when the user is comparing hotels for specific dates and wants real prices (not fabricated). Covers known OTA blockers (Trip.com, IHG.com, Google Hotels) and the Booking.com interactive-form workflow that actually works. Trigger on… |
| [llm-wiki](research/llm-wiki/) | Karpathy's LLM Wiki — build and maintain a persistent, interlinked markdown knowledge base. Ingest sources, query compiled knowledge, and lint for consistency. |
| [polymarket](research/polymarket/) | Query Polymarket prediction market data — search markets, get prices, orderbooks, and price history. Read-only via public REST APIs, no API key needed. |
| [research-paper-writing](research/research-paper-writing/) | End-to-end pipeline for writing ML/AI research papers — from experiment design through analysis, drafting, revision, and submission. Covers NeurIPS, ICML, ICLR, ACL, AAAI, COLM. Integrates automated experiment monitoring, statistical analysis, iterative writing, and citation verification. |
| [sahil-office-hours](research/sahil-office-hours/) | Startup advice frameworks from Sahil Lavingia (Gumroad) based on The Minimalist Entrepreneur. Use when someone is starting a business, validating an idea, finding customers, setting prices, building an MVP, creating a marketing plan, defining company values, or making any business decision… |
| [synthetic-userstudies](research/synthetic-userstudies/) | Run synthetic user research sessions natively — no backend required. The agent plays an AI-generated persona and simulates a user interview based on the 4 Ps framework (Persona, Problem, Promise, Product). Use when a user wants to run a user research session, interview a synthetic persona,… |
| [trip-planner](research/trip-planner/) | Generate detailed day-by-day travel itineraries with neighborhood-by-neighborhood routing, budget scaling, dietary-aware meal picks, proximity checks, and post-generation quality validation. Use when: plan a trip, travel itinerary, trip to [destination], vacation planning, travel planner. |
| [yc-office-hours](research/yc-office-hours/) | Product discovery via YC-style forcing questions and 10-star product thinking. Use when starting a new feature, evaluating a product idea, or reframing a request into its most ambitious version. |

### 🎯 Visual Design

| Skill | Description |
|-------|-------------|
| [apple-ux-guidelines](visual-design/apple-ux-guidelines/) | Use when apple HIG reference for UI/UX decisions on Apple platforms. |
| [canvas-design](visual-design/canvas-design/) | Use when create visual art and designs as .png/.pdf files. |
| [create-a-sales-asset](visual-design/create-a-sales-asset/) | Use when generating sales assets (landing pages, decks, one-pagers) from deal context. |
| [d3js-visualization](visual-design/d3js-visualization/) | Use when creating interactive D3.js data visualizations. |
| [design-review](visual-design/design-review/) | Run a product design review on a feature or site. Answers 13 design questions, runs Nielsen Norman heuristic evaluation, builds before/after visual fixes, and deploys a shareable report to Surge. Use when asked to review a design, audit UX, do a design review, or analyze a product's user experience. |
| [excalidraw-mcp](visual-design/excalidraw-mcp/) | Use when creating hand-drawn style Excalidraw diagrams via the Excalidraw MCP at https://mcp.excalidraw.com/mcp. Use for flow diagrams, architecture diagrams, slide visuals, and any time a sketchy/hand-drawn diagram is needed as a PNG file. |
| [frontend-design](visual-design/frontend-design/) | Use when build production-grade frontend interfaces with high design quality. |
| [frontend-slides](visual-design/frontend-slides/) | Use when creating animation-rich HTML presentations or convert PPT to web. |
| [image-generator](visual-design/image-generator/) | Use when generate article visuals: diagrams, hero images, screenshots. |
| [impeccable](visual-design/impeccable/) | Run impeccable design quality commands on frontend code — audit, critique, polish, animate, normalize, and more. Built on top of the frontend-design skill with 21 steering commands and 10 domain-specific reference files. Use when doing a design QA pass, reviewing UI quality, or refining a… |
| [adapt](visual-design/impeccable/commands/adapt/) | Adapt designs to work across different screen sizes, devices, contexts, or platforms. Implements breakpoints, fluid layouts, and touch targets. Use when the user mentions responsive design, mobile layouts, breakpoints, viewport adaptation, or cross-device compatibility. |
| [animate](visual-design/impeccable/commands/animate/) | Review a feature and enhance it with purposeful animations, micro-interactions, and motion effects that improve usability and delight. Use when the user mentions adding animation, transitions, micro-interactions, motion design, hover effects, or making the UI feel more alive. |
| [arrange](visual-design/impeccable/commands/arrange/) | Improve layout, spacing, and visual rhythm. Fixes monotonous grids, inconsistent spacing, and weak visual hierarchy. Use when the user mentions layout feeling off, spacing issues, visual hierarchy, crowded UI, alignment problems, or wanting better composition. |
| [audit](visual-design/impeccable/commands/audit/) | Run technical quality checks across accessibility, performance, theming, responsive design, and anti-patterns. Generates a scored report with P0-P3 severity ratings and actionable plan. Use when the user wants an accessibility check, performance audit, or technical quality review. |
| [bolder](visual-design/impeccable/commands/bolder/) | Amplify safe or boring designs to make them more visually interesting and stimulating. Increases impact while maintaining usability. Use when the user says the design looks bland, generic, too safe, lacks personality, or wants more visual impact and character. |
| [clarify](visual-design/impeccable/commands/clarify/) | Improve unclear UX copy, error messages, microcopy, labels, and instructions to make interfaces easier to understand. Use when the user mentions confusing text, unclear labels, bad error messages, hard-to-follow instructions, or wanting better UX writing. |
| [colorize](visual-design/impeccable/commands/colorize/) | Add strategic color to features that are too monochromatic or lack visual interest, making interfaces more engaging and expressive. Use when the user mentions the design looking gray, dull, lacking warmth, needing more color, or wanting a more vibrant or expressive palette. |
| [critique](visual-design/impeccable/commands/critique/) | Evaluate design from a UX perspective, assessing visual hierarchy, information architecture, emotional resonance, cognitive load, and overall quality with quantitative scoring, persona-based testing, and actionable feedback. Use when the user asks to review, critique, evaluate, or give feedback… |
| [delight](visual-design/impeccable/commands/delight/) | Add moments of joy, personality, and unexpected touches that make interfaces memorable and enjoyable to use. Elevates functional to delightful. Use when the user asks to add polish, personality, animations, micro-interactions, delight, or make an interface feel fun or memorable. |
| [distill](visual-design/impeccable/commands/distill/) | Strip designs to their essence by removing unnecessary complexity. Great design is simple, powerful, and clean. Use when the user asks to simplify, declutter, reduce noise, remove elements, or make a UI cleaner and more focused. |
| [extract](visual-design/impeccable/commands/extract/) | Extract and consolidate reusable components, design tokens, and patterns into your design system. Identifies opportunities for systematic reuse and enriches your component library. Use when the user asks to create components, refactor repeated UI patterns, build a design system, or extract tokens. |
| [frontend-design](visual-design/impeccable/commands/frontend-design/) | Create distinctive, production-grade frontend interfaces with high design quality. Generates creative, polished code that avoids generic AI aesthetics. Use when the user asks to build web components, pages, artifacts, posters, or applications, or when any design skill requires project context. |
| [harden](visual-design/impeccable/commands/harden/) | Improve interface resilience through better error handling, i18n support, text overflow handling, and edge case management. Makes interfaces robust and production-ready. Use when the user asks to harden, make production-ready, handle edge cases, add error states, or fix overflow and i18n issues. |
| [normalize](visual-design/impeccable/commands/normalize/) | Audits and realigns UI to match design system standards, spacing, tokens, and patterns. Use when the user mentions consistency, design drift, mismatched styles, tokens, or wants to bring a feature back in line with the system. |
| [onboard](visual-design/impeccable/commands/onboard/) | Designs and improves onboarding flows, empty states, and first-run experiences to help users reach value quickly. Use when the user mentions onboarding, first-time users, empty states, activation, getting started, or new user flows. |
| [optimize](visual-design/impeccable/commands/optimize/) | Diagnoses and fixes UI performance across loading speed, rendering, animations, images, and bundle size. Use when the user mentions slow, laggy, janky, performance, bundle size, load time, or wants a faster, smoother experience. |
| [overdrive](visual-design/impeccable/commands/overdrive/) | Pushes interfaces past conventional limits with technically ambitious implementations — shaders, spring physics, scroll-driven reveals, 60fps animations. Use when the user wants to wow, impress, go all-out, or make something that feels extraordinary. |
| [polish](visual-design/impeccable/commands/polish/) | Performs a final quality pass fixing alignment, spacing, consistency, and micro-detail issues before shipping. Use when the user mentions polish, finishing touches, pre-launch review, something looks off, or wants to go from good to great. |
| [quieter](visual-design/impeccable/commands/quieter/) | Tones down visually aggressive or overstimulating designs, reducing intensity while preserving quality. Use when the user mentions too bold, too loud, overwhelming, aggressive, garish, or wants a calmer, more refined aesthetic. |
| [teach-impeccable](visual-design/impeccable/commands/teach-impeccable/) | One-time setup that gathers design context for your project and saves it to your AI config file. Run once to establish persistent design guidelines. |
| [typeset](visual-design/impeccable/commands/typeset/) | Improves typography by fixing font choices, hierarchy, sizing, weight, and readability so text feels intentional. Use when the user mentions fonts, type, readability, text hierarchy, sizing looks off, or wants more polished, intentional typography. |
| [slideshow-creator](visual-design/slideshow-creator/) | Create and post TikTok slideshows via ReelFarm. Use for generating slideshow content, setting up automations, and publishing to TikTok. For strategy, scheduling, analytics, and optimization — use the content-strategy skill first. |
| [sticker-creator](visual-design/sticker-creator/) | Create die-cut sticker style cards via Nano Banana Pro. Use for social media cards, earnings cards, brand stickers, announcement cards, and any content formatted as a bold, clean sticker with a thick white border. |
| [userinterface-wiki](visual-design/userinterface-wiki/) | UI/UX best practices for web interfaces. Use when reviewing animations, CSS, audio, typography, UX patterns, prefetching, or icon implementations. Covers 11 categories from animation principles to typography. Outputs file:line findings. |

---

## Adapted Skills

These started from other open-source projects, modified and extended for these workflows.

### From [Anthropic](https://github.com/anthropics)

| Skill | Original |
|-------|----------|
| [documents](devops/documents/) | [anthropics/skills](https://github.com/anthropics/skills) |
| [wealth-management](finance/wealth-management/) | [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) |
| [skill-creator](hermes/skill-creator/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) |
| [skill-audit](hermes/skill-audit/) | Original (inspired by Anthropic's skill patterns) |
| [skill-improver](hermes/skill-improver/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) |
| [frontend-design](visual-design/frontend-design/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design) |
| [ralph-mode](coding/ralph-mode/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) |

### From [obra/superpowers](https://github.com/obra/superpowers)

| Skill | Description |
|-------|-------------|
| [superpowers-coding](coding/superpowers-coding/) | TDD-first feature implementation and systematic debugging |
| [superpowers-planning](coding/superpowers-planning/) | Explore intent and create detailed plans before touching code |
| [superpowers-reviews](coding/superpowers-reviews/) | Code review, branch finishing, batch execution with checkpoints |

### From [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)

| Skill | Description |
|-------|-------------|
| [growth](marketing/growth/) | Full-funnel growth: CRO, onboarding, paywalls, churn, launches, pricing |
| [churn-prevention](marketing/churn-prevention/) | Subscription retention, cancel flows, save offers, dunning |
| [email-sequence](marketing/email-sequence/) | Email sequences, drip campaigns, lifecycle messaging |
| [positioning-angles](marketing/positioning-angles/) | Product positioning, strategic angles, value propositions |

### From Other Projects

| Skill | Original |
|-------|----------|
| [codex](coding/codex/) | [garrytan/gstack](https://github.com/garrytan/gstack) (MIT) |
| [impeccable](visual-design/impeccable/) | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| [app-store-screenshots](app-store/app-store-screenshots/) | [ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) |
| [remotion-best-practices](creative/remotion-best-practices/) | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| [remotion-videos](creative/video-production/remotion-videos/) | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| [frontend-slides](visual-design/frontend-slides/) | [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) |
| [last30days](marketing/last30days/) | [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) |
| [stably-cli](devops/stably-cli/) | [skills.sh/stablyai](https://skills.sh/stablyai/agent-skills/stably-cli) |
| [stably-sdk-rules](devops/stably-sdk-rules/) | [skills.sh/stablyai](https://skills.sh/stablyai/agent-skills/stably-sdk-rules) |
| [sahil-office-hours](research/sahil-office-hours/) | [slavingia/skills](https://github.com/slavingia/skills) |
| [design-md](visual-design/design-md/) | [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) + [Google Stitch DESIGN.md spec](https://stitch.withgoogle.com/docs/design-md/overview/) |
| [design-mode](visual-design/design-mode/) | [elder-plinius/CL4R1T4S](https://github.com/elder-plinius/CL4R1T4S/blob/main/ANTHROPIC/Claude-Design-Sys-Prompt.txt) (Anthropic design-surface system prompt) |

## License

MIT
