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

## All Skills

### 🤖 AI Tools

| Skill | Description |
|-------|-------------|
| [agent-browser](ai-tools/agent-browser/) | Use when automating browsers via agent-browser CLI: headless browsing, web scraping with accessibility trees, CDP-based automation, filling forms, clicking buttons, navigating pages, or running iso... |
| [claude-code](ai-tools/claude-code/) | Delegate coding tasks to Claude Code (Anthropic's CLI agent). Use for building features, refactoring, PR reviews, and iterative coding. Requires the claude CLI installed. |
| [claude-code-routines](ai-tools/claude-code-routines/) | Set up and manage Claude Code Routines — scheduled, API-triggered, and GitHub webhook automations that run on Anthropic's cloud. Use when asked about routines, scheduled tasks in Claude Code, autom... |
| [codex](ai-tools/codex/) | Delegate coding tasks to OpenAI Codex CLI agent. Use for building features, refactoring, PR reviews, and batch issue fixing. Requires the codex CLI and a git repository. |
| [grok-search](ai-tools/grok-search/) | Search the web or X/Twitter using xAI Grok server-side tools (web_search, x_search) via the xAI Responses API. Use when you need tweets/threads/users from X, want Grok as an alternative to Brave, o... |
| [hermes-agent](ai-tools/hermes-agent/) | Complete guide to using and extending Hermes Agent — CLI usage, setup, configuration, spawning additional agents, gateway platforms, skills, voice, tools, profiles, and a concise contributor refere... |
| [mcporter](ai-tools/mcporter/) | Use the mcporter CLI to list, configure, auth, and call MCP servers/tools directly (HTTP or stdio), including ad-hoc servers, config edits, and CLI/type generation. |
| [native-mcp](ai-tools/native-mcp/) | Built-in MCP (Model Context Protocol) client that connects to external MCP servers, discovers their tools, and registers them as native Hermes Agent tools. Supports stdio and HTTP transports with a... |
| [opencode](ai-tools/opencode/) | Delegate coding tasks to OpenCode CLI agent for feature implementation, refactoring, PR review, and long-running autonomous sessions. Requires the opencode CLI installed and authenticated. |
| [web-search](ai-tools/web-search/) | Search the web via Serper (Google Search) API. Default web search tool — use this first for recent releases, news, and general queries. |

### 📱 App Store

| Skill | Description |
|-------|-------------|
| [app-store-connect](app-store/app-store-connect/) | Use the asc CLI for all App Store Connect tasks — releases, TestFlight, builds, metadata, screenshots, signing, subscriptions, IAPs, pricing, analytics, users, notarization, and more. Primary catch... |
| [app-store-screenshots](app-store/app-store-screenshots/) | Generate production-ready App Store marketing screenshots for iOS apps using a Next.js generator. Screenshots are designed as ads (not UI showcases) and exported at all 4 Apple-required sizes (6.9"... |
| [aso](app-store/aso/) | ASO skills for Bloom — keyword research, audits, metadata optimization, competitor analysis using DataForSEO. Use when the user asks about App Store Optimization, improving Bloom's App Store rankin... |
| [ios-simulator](app-store/ios-simulator/) | Use when automating iOS Simulator tasks with 21 accessibility-driven scripts: building and running iOS apps, device lifecycle management, screenshot capture, UI navigation via accessibility, gestur... |
| [revenuecat-cli](app-store/revenuecat-cli/) | Use when querying RevenueCat for projects, apps, products, entitlements, offerings, packages, customers, subscriptions, purchases, webhooks, or overview metrics via mcporter. Triggers on "revenueca... |

### 🌸 Bloom

| Skill | Description |
|-------|-------------|
| [bloom-cli](bloom/bloom-cli/) | Use when fetching stock data, company fundamentals, market data, earnings, SEC filings, price history, analyst ratings, peer comparisons, or financial research via the Bloom CLI. Use for 'what's AA... |
| [demo-pr-feature](bloom/demo-pr-feature/) | Capture a demo screenshot or video of a Bloom PR's feature, deploy to Surge.sh, and post the URL as a GitHub PR comment. Use after pushing a fix to a frontend PR. |
| [fix-bloom-prs](bloom/fix-bloom-prs/) | Use when fixing CI failures, reviewing code, or addressing review comments on open PRs. Scans all tracked repos (Bloom, investing-log, skills), not just Bloom. |

### 💻 Coding & Development

| Skill | Description |
|-------|-------------|
| [babysit-open-prs](coding/babysit-open-prs/) | Scan all open PRs across tracked repos, triage them, check for scope drift, and spawn babysit-pr sub-agents for fixable ones. Use when: babysit all PRs, check all open PRs, nightly PR review. |
| [babysit-pr](coding/babysit-pr/) | Monitor a PR until it's ready to merge. Watches CI, reads reviews, checks scope, fixes issues, and repeats. Use when: babysit this PR, watch this PR, monitor PR, fix and watch PR, keep this PR green. |
| [claude-md-management](coding/claude-md-management/) | Use when asked to audit, improve, or maintain CLAUDE.md files across repos. Triggers on "audit my CLAUDE.md", "check if my CLAUDE.md is up to date", capturing session learnings, or keeping project ... |
| [codex](coding/codex/) | Get a second opinion from OpenAI Codex CLI — code review (pass/fail), adversarial challenge, or open consultation. Use when asked for "codex review", "second opinion", or "ask codex". |
| [context7](coding/context7/) | Use when writing code that uses a specific library or framework and you need accurate, current API docs — not year-old training data. Fetches version-specific documentation via Context7 MCP. |
| [fastapi-piccolo-typer-testing](coding/fastapi-piccolo-typer-testing/) | Patterns for writing fast, DB-free pytest suites against FastAPI routers, Piccolo ORM queries, Typer CLI commands, and service-layer code. Use when adding test coverage to a FastAPI + Piccolo + Typ... |
| [fintary-ops-center-context](coding/fintary-ops-center-context/) | Context and backlog for Fintary ops-center project |
| [firecrawl](coding/firecrawl/) | Scrape, crawl, search, and interact with web pages using Firecrawl CLI and API. Use when the user mentions \"firecrawl\", \"scrape a website\", \"crawl a site\", \"map a site\", \"web scraping\", \... |
| [fix-sentry-issues](coding/fix-sentry-issues/) | Use when scanning Sentry issues for Bloom and creating fix PRs. |
| [godmode](coding/godmode/) | Jailbreak API-served LLMs using G0DM0D3 techniques — Parseltongue input obfuscation (33 techniques), GODMODE CLASSIC system prompt templates, ULTRAPLINIAN multi-model racing, encoding escalation, a... |
| [jupyter-live-kernel](coding/jupyter-live-kernel/) | > |
| [optimize-prompt](coding/optimize-prompt/) | Iteratively optimize Bloom's chat agent system prompt using a keep/revert autoresearch loop. Use when asked to optimize, improve, or tune Bloom's system prompt, run prompt optimization, or do a Kar... |
| [plan](coding/plan/) | Plan mode for Hermes — inspect context, write a markdown plan into the active workspace's `.hermes/plans/` directory, and do not execute the work. |
| [ralph-mode](coding/ralph-mode/) | Run iterative self-referential development loops using the Ralph Wiggum technique. Use when tasks need repeated iteration, TDD cycles, greenfield builds, or autonomous refinement until tests pass o... |
| [react-doctor](coding/react-doctor/) | Diagnose and fix React codebase health issues. Use when reviewing React code, fixing performance problems, auditing security, or improving code quality. |
| [requesting-code-review](coding/requesting-code-review/) | > |
| [sentry-debug](coding/sentry-debug/) | Use when debugging production errors via Sentry — listing and searching issues, inspecting events and stack traces, checking release distribution, running Seer root-cause analysis, or resolving/ass... |
| [serena](coding/serena/) | Use when navigating or editing a complex codebase at the symbol level — symbol lookup, references, precise edits via Serena MCP. Prefer over grepping files for accurate code navigation. |
| [simplify](coding/simplify/) | Review changed code for reuse, quality, and efficiency, then fix any issues found. TRIGGER when user says "simplify", "clean up code", "review my changes", "code review and fix", or "/simplify". |
| [superpowers-coding](coding/superpowers-coding/) | Use when implementing any feature or bugfix (TDD required before writing code), encountering any bug, test failure, or unexpected behavior (systematic debugging before proposing fixes), creating is... |
| [superpowers-planning](coding/superpowers-planning/) | You MUST use this before any creative work, feature, or implementation — explores intent and requirements first, creates detailed plans before touching code. Also use when establishing how to find ... |
| [superpowers-reviews](coding/superpowers-reviews/) | Use when requesting or receiving code review, verifying work before claiming it's done, finishing a development branch (merge/PR/discard), executing written plans with batch checkpoints, or dispatc... |
| [systematic-debugging](coding/systematic-debugging/) | Use when encountering any bug, test failure, or unexpected behavior. 4-phase root cause investigation — NO fixes without understanding the problem first. |
| [test-driven-development](coding/test-driven-development/) | Use when implementing any feature or bugfix, before writing implementation code. Enforces RED-GREEN-REFACTOR cycle with test-first approach. |
| [writing-plans](coding/writing-plans/) | Use when you have a spec or requirements for a multi-step task. Creates comprehensive implementation plans with bite-sized tasks, exact file paths, and complete code examples. |

### 🎨 Creative & Content

| Skill | Description |
|-------|-------------|
| [architecture-diagram](creative/architecture-diagram/) | Generate dark-themed SVG diagrams of software systems and cloud infrastructure as standalone HTML files with inline SVG graphics. Semantic component colors (cyan=frontend, emerald=backend, violet=d... |
| [article-writer](creative/article-writer/) | Use when writing article drafts from approved outlines with SEO and brand voice. |
| [ascii-art](creative/ascii-art/) | Generate ASCII art using pyfiglet (571 fonts), cowsay, boxes, toilet, image-to-ascii, remote APIs (asciified, ascii.co.uk), and LLM fallback. No API keys required. |
| [ascii-video](creative/ascii-video/) | Production pipeline for ASCII art video — any format. Converts video/audio/images/generative input into colored ASCII character video output (MP4, GIF, image sequence). Covers: video-to-ASCII conve... |
| [character-creation](creative/character-creation/) | Create and manage consistent AI video characters — define the persona, generate the portrait with Nano Banana, and store the config for reuse across all videos in the series. |
| [creative-ideation](creative/creative-ideation/) | Generate project ideas through creative constraints. Use when the user says 'I want to build something', 'give me a project idea', 'I'm bored', 'what should I make', 'inspire me', or any variant of... |
| [editor-in-chief](creative/editor-in-chief/) | Use when a first draft is complete and all Phase 1 gates are |
| [evaluate-content](creative/evaluate-content/) | Use when judging content quality OR editing/improving existing copy: shareability, readability, voice, cuttability, angle, copy sweeps. |
| [excalidraw](creative/excalidraw/) | Create hand-drawn style diagrams using Excalidraw JSON format. Generate .excalidraw files for architecture diagrams, flowcharts, sequence diagrams, concept maps, and more. Files can be opened at ex... |
| [gif-search](creative/gif-search/) | Search and download GIFs from Tenor using curl. No dependencies beyond curl and jq. Useful for finding reaction GIFs, creating visual content, and sending GIFs in chat. |
| [heartmula](creative/heartmula/) | Set up and run HeartMuLa, the open-source music generation model family (Suno-like). Generates full songs from lyrics + tags with multilingual support. |
| [klingai](creative/klingai/) | Official Kling AI Skill. Call Kling AI for video generation, image generation, and subject management. Use subcommand video / image / element by user intent. Use when the user mentions "Kling", "可灵... |
| [manim-video](creative/manim-video/) | Production pipeline for mathematical and technical animations using Manim Community Edition. Creates 3Blue1Brown-style explainer videos, algorithm visualizations, equation derivations, architecture... |
| [nano-banana-pro](creative/nano-banana-pro/) | Generate or edit images via Gemini 3 Pro Image Preview (Nano Banana Pro). Use when asked to generate an image, create artwork, edit a photo, add/remove elements from an image, compose multiple imag... |
| [outline-generator](creative/outline-generator/) | Use when generating outlines, article structures, content outlines, blog outlines, planning article sections, structuring posts, breaking down topics into sections, or organizing ideas for long-for... |
| [p5js](creative/p5js/) | Production pipeline for interactive and generative visual art using p5.js. Creates browser-based sketches, generative art, data visualizations, interactive experiences, 3D scenes, audio-reactive vi... |
| [popular-web-designs](creative/popular-web-designs/) | > |
| [remotion-best-practices](creative/remotion-best-practices/) | Use when writing or reviewing Remotion code — compositions, animations, captions, audio, charts, 3D, fonts, transitions, or any React-based video creation. Trigger phrases: Remotion, video in React... |
| [screen-recording](creative/screen-recording/) | Record macOS screen via CLI with ffmpeg. Pair with peekaboo for automated UI demos. Use when recording tutorials, product walkthroughs, or automated demo videos. |
| [seedance](creative/seedance/) | Generate videos using ByteDance Seedance 2.0 via PiAPI. Triggers on "Seedance", "ByteDance video", "video generation", "text-to-video", "image-to-video". Supports text-to-video, image-to-video, vid... |
| [songsee](creative/songsee/) | Generate spectrograms and audio feature visualizations (mel, chroma, MFCC, tempogram, etc.) from audio files via CLI. Useful for audio analysis, music production debugging, and visual documentation. |
| [songwriting-and-ai-music](creative/songwriting-and-ai-music/) | > |
| [stock-footage](creative/stock-footage/) | Search and download free stock video footage from Pexels and Pixabay for B-roll and video production. Use when the user mentions "stock footage", "B-roll", "b-roll", "stock video", "find clips", "P... |
| [substack-draft](creative/substack-draft/) | Use when saving a finished article to Substack as a draft for manual review and publishing. Does NOT publish automatically — always saves as draft. |
| [video-editor](creative/video-editor/) | Programmatic video editing via ffmpeg CLI. Handles trimming clips, merging/concatenating videos, overlays (picture-in-picture, watermarks, logos), crossfade transitions between clips, speed ramping... |
| [video-production](creative/video-production/) | Use when making videos, creating clips, voiceovers, talking avatars, AI video generation, text-to-video, lip sync, motion graphics, screen recordings, or video editing. Covers Sora, Kling, ElevenLa... |
| [video-script](creative/video-script/) | Generate structured scene-by-scene video scripts with production metadata (visuals, audio, sources, transitions, captions) ready to feed into the video-production pipeline (Sora, Kling, ElevenLabs,... |
| [writer](creative/writer/) | Write content in Eric's voice — articles, blog posts, tweets, social media posts, marketing copy, newsletter drafts. Loads WRITING-STYLE.md and enforces kill phrases. |
| [youtube-content](creative/youtube-content/) | > |

### ⚙️ DevOps & Infrastructure

| Skill | Description |
|-------|-------------|
| [bulk-import-skills-from-git](devops/bulk-import-skills-from-git/) | Import skills from a GitHub repository (like exiao/skills or any skills bundle) into ~/.hermes/skills/, resolving naming conflicts and preserving directory structure. Use when a user shares a skill... |
| [cloud-migration](devops/cloud-migration/) | Execute full cloud provider migrations end-to-end — provision the new environment, migrate all data (Postgres, Redis, object storage), transfer env vars/secrets, deploy the app, verify data parity,... |
| [codebase-inspection](devops/codebase-inspection/) | Inspect and analyze codebases using pygount for LOC counting, language breakdown, and code-vs-comment ratios. Use when asked to check lines of code, repo size, language composition, or codebase stats. |
| [dependabot-stuck-pr-rebase](devops/dependabot-stuck-pr-rebase/) | Manually rebase Dependabot PRs that are stuck in CONFLICTING state because @dependabot rebase / recreate isn't firing. Use when multiple Dependabot PRs show mergeStateStatus=CONFLICTING after main ... |
| [deploy-bloom](devops/deploy-bloom/) | Use when deploying Bloom OTA updates via the bloom-updater pipeline. |
| [document-release](devops/document-release/) | Update all project documentation to match what was just shipped. Use after merging a PR or shipping a feature to catch stale READMEs and drifted docs. |
| [documents](devops/documents/) | Use when working with any office document format: .docx Word files (creating, editing, tracked changes, reports, memos, templates); PDF files (reading, merging, splitting, OCR, watermarks, form fil... |
| [github-auth](devops/github-auth/) | Set up GitHub authentication for the agent using git (universally available) or the gh CLI. Covers HTTPS tokens, SSH keys, credential helpers, and gh auth — with a detection flow to pick the right ... |
| [github-code-review](devops/github-code-review/) | Review code changes by analyzing git diffs, leaving inline comments on PRs, and performing thorough pre-push review. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-issues](devops/github-issues/) | Create, manage, triage, and close GitHub issues. Search existing issues, add labels, assign people, and link to PRs. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-pr-workflow](devops/github-pr-workflow/) | Full pull request lifecycle — create branches, commit changes, open PRs, monitor CI status, auto-fix failures, and merge. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-repo-management](devops/github-repo-management/) | Clone, create, fork, configure, and manage GitHub repositories. Manage remotes, secrets, releases, and workflows. Works with gh CLI or falls back to git + GitHub REST API via curl. |
| [github-rulesets-bulk-apply](devops/github-rulesets-bulk-apply/) | Apply a branch-protection ruleset (deletion + non_fast_forward, no bypass) to the default branch of every repo an account admins. Use when the user wants to protect all their repos from accidental ... |
| [hermes-proxy-routing-fix](devops/hermes-proxy-routing-fix/) | Fix for Hermes not routing Anthropic requests through local billing proxy |
| [huggingface-hub](devops/huggingface-hub/) | Hugging Face Hub CLI (hf) — search, download, and upload models and datasets, manage repos, query datasets with SQL, deploy inference endpoints, manage Spaces and buckets. |
| [openclaw-docker-debug](devops/openclaw-docker-debug/) | Debug OpenClaw issues when deployed via Docker Compose. Covers finding containers, reading logs, health checks, config inspection, and diagnosing channel crash loops. Use when OpenClaw is running i... |
| [phoenix-cli](devops/phoenix-cli/) | Use when debugging LLM apps with Phoenix CLI: traces, errors, experiments. |
| [porkbun](devops/porkbun/) | Manage Porkbun domains, DNS records, SSL certificates, URL forwarding, and hosting blueprints via the Porkbun API. Use when the user asks about domain management, DNS, SSL certs, URL redirects, or ... |
| [railway](devops/railway/) | Deploy, manage, and operate Railway projects via CLI and MCP. Use when creating Railway services, deploying code, adding databases (Postgres, Redis), setting environment variables, viewing logs, ma... |
| [render-cli](devops/render-cli/) | Manage Render.com services, deploys, databases, logs, and infrastructure using the official Render CLI (`render`). Use this skill whenever the user asks about Render deployments, service management... |
| [security-audit](devops/security-audit/) | Run a codebase security audit using OWASP Top 10 and STRIDE threat modeling. Use when auditing code for vulnerabilities or preparing for a pentest. |
| [stably-cli](devops/stably-cli/) | Use the Stably CLI to create, run, fix, and maintain Playwright tests in the bloom-tests repo. Use when running tests (stably test), auto-fixing failures (stably fix), or generating new tests from ... |
| [stably-sdk-rules](devops/stably-sdk-rules/) | Best practices for writing Stably AI-powered Playwright tests. Use when writing, reviewing, or debugging tests in bloom-tests that use @stablyai/playwright-test — covers when to use aiAssert vs raw... |
| [verify-deploy](devops/verify-deploy/) | Post-merge deploy verification. Waits for deploy, benchmarks production, monitors for regressions. Use after merging a PR to confirm the deploy is healthy. |
| [webhook-subscriptions](devops/webhook-subscriptions/) | Create and manage webhook subscriptions for event-driven agent activation. Use when the user wants external services to trigger agent runs automatically. |

### 💰 Finance & Investing

| Skill | Description |
|-------|-------------|
| [alpaca](finance/alpaca/) | Trade stocks and crypto via Alpaca API. Use for market data (quotes, bars, news), placing orders (market, limit, stop), checking positions, portfolio management, and account info. Supports both pap... |
| [copilot-money](finance/copilot-money/) | Use when querying Copilot Money for finances, transactions, net worth, and holdings. |
| [earnings-card-pipeline](finance/earnings-card-pipeline/) | Use when the cron fires at 8am ET on Mondays — pulls the week's major earnings events, generates a die-cut sticker style card for each, creates Typefully drafts, and reports to Signal. |
| [market-daily-briefing](finance/market-daily-briefing/) | Use when delivering a daily market briefing — covering earnings results, macro news, and notable stock moves. Runs automatically at 10am ET Mon-Fri via cron, or on-demand when asked for a market up... |
| [polymarket](finance/polymarket/) | Query Polymarket prediction markets via the polymarket CLI. Browse markets, search topics, check prices, order books, and view events. Use when a user asks about prediction markets, odds, or "what ... |
| [post-insider-trades](finance/post-insider-trades/) | Use when the cron fires at 9am or 2pm ET on weekdays — scrapes OpenInsider for significant recent insider buys, generates a brokerage-receipt trade card, writes a tweet, creates a Typefully draft, ... |
| [post-investinglog-trades](finance/post-investinglog-trades/) | Use when the cron fires at 4pm ET on weekdays — picks the best unposted trade from the investing-log repo, generates a trade card, creates a Typefully draft, and reports to Signal. |
| [stock-research](finance/stock-research/) | Use when performing stock or equity research, earnings analysis, coverage reports, or generating daily market briefings for Bloom. Covers on-demand research tasks and the scheduled daily market bri... |
| [wealth-management](finance/wealth-management/) | Wealth management workflows — client review prep, financial plans, investment proposals, portfolio rebalancing, and tax-loss harvesting. Adapted from Anthropic's financial-services-plugins (github.... |

### 🔧 Runtime & Platform

| Skill | Description |
|-------|-------------|
| [claude-auth-remote-login](hermes/claude-auth-remote-login/) | Remote Claude Code OAuth login flow when token expires. Use when `claude auth status` reports logged in but `claude -p` returns 401, or when needing to re-authenticate over SSH. Trigger phrases inc... |
| [dogfood](hermes/dogfood/) | Use when asked to dogfood, QA, exploratory test, find issues, bug hunt, or review the quality of a web application. Produces a structured report with full reproduction evidence (screenshots, repro ... |
| [exiao-skills-pr-conventions](hermes/exiao-skills-pr-conventions/) | Use when contributing a skill to the public exiao/skills GitHub repo. Covers repo layout rules, frontmatter, sanitization (no creds/personal data), README updates, and PR workflow. Trigger on "PR t... |
| [hermes-add-tool-pattern](hermes/hermes-add-tool-pattern/) | Pattern for adding a new tool to the Hermes agent framework |
| [hermes-context-files](hermes/hermes-context-files/) | How Hermes discovers and loads context files (SOUL.md, AGENTS.md, HERMES.md, CLAUDE.md). Use when asked how Hermes loads context, which files are auto-loaded vs on-demand, how SOUL.md/AGENTS.md dis... |
| [hermes-model-alias-config](hermes/hermes-model-alias-config/) | Configure custom model aliases in Hermes to bypass buggy catalog resolution |
| [hermes-model-aliases](hermes/hermes-model-aliases/) | Fix broken Hermes model switching shortcuts with custom aliases in config.yaml |
| [hermes-quick-command-alias](hermes/hermes-quick-command-alias/) | How to set up slash command aliases in Hermes via quick_commands config |
| [hermes-signal-italic-fix](hermes/hermes-signal-italic-fix/) | Fix false-positive italics in Signal adapter caused by snake_case underscores. Use when Signal messages show random italics around snake_case identifiers like `config_file` or `OPENAI_API_KEY`. Tri... |
| [hermes-signal-reply-fix](hermes/hermes-signal-reply-fix/) | Fix for Signal reply context not being passed into Hermes gateway |
| [hermes-signal-streaming-cursor-fix](hermes/hermes-signal-streaming-cursor-fix/) | Diagnose and fix black-square / cursor artifacts in Hermes Signal conversations caused by edit-based streaming assumptions on non-editable platforms. |
| [memory-gc](hermes/memory-gc/) | \| |
| [openclaw-billing-proxy-client-support](hermes/openclaw-billing-proxy-client-support/) | Extend the openclaw-billing-proxy to support a new client fingerprint (for example Hermes) by adding trigger-string sanitization, tool renames, reverse mappings, docs, and a regression test. |
| [openclaw-memory-setup](hermes/openclaw-memory-setup/) | Set up a complete memory system for an OpenClaw instance. Covers workspace files, vector search with embeddings, compaction with automatic memory flush, heartbeat-driven memory maintenance, and dai... |
| [openclaw-resiliency](hermes/openclaw-resiliency/) | Set up a gateway watchdog that monitors OpenClaw health and auto-recovers from failures. Covers 3-tier health checks (process, HTTP, channel deep health), exponential backoff, signal-cli special ha... |
| [recall](hermes/recall/) | \| |
| [signal-message-splitting-bug](hermes/signal-message-splitting-bug/) | Investigation and fix plan for Signal splitting short bot responses into multiple bubbles |
| [signal-send-file](hermes/signal-send-file/) | \| |
| [signal-table-render](hermes/signal-table-render/) | Auto-render markdown tables to PNG before sending on Signal. Signal's chat UI does not render markdown tables — pipes and dashes show as literal text. When an outgoing message to a Signal chat cont... |
| [skill-audit](hermes/skill-audit/) | Audit and score any skill against best practices. Use when: audit this skill, review this skill, check this skill, score this skill, is this skill good, skill health check, skill review, rate this ... |
| [skill-creator](hermes/skill-creator/) | Create new skills, modify and improve existing skills, and measure skill performance. Use when creating or editing ANY skill — including rewrites, description tweaks, or adding examples. TDD pre-fl... |
| [skill-improver](hermes/skill-improver/) | Autonomously optimize any Claude Code skill by running it repeatedly, scoring outputs against binary evals, mutating the prompt, and keeping improvements. Based on Karpathy's autoresearch methodolo... |
| [watchdog-status-cleanup](hermes/watchdog-status-cleanup/) | Inspect Hermes/OpenClaw watchdog LaunchAgents on macOS and clean up stale signal-cli send jobs or proxy launcher shells that make status output noisy. |

### 📈 Marketing & Growth

| Skill | Description |
|-------|-------------|
| [appfigures](marketing/appfigures/) | Use when querying Appfigures for app store analytics (downloads, revenue, reviews, rankings). |
| [apple-search-ads](marketing/apple-search-ads/) | Create, optimize, and scale Apple Search Ads campaigns with API automation, attribution integration, and bid strategy recommendations. |
| [brand-identity](marketing/brand-identity/) | Build a complete brand identity from scratch or refresh an existing one — for solopreneurs, apps, and consumer products. Covers brand purpose, values, personality, voice and tone, visual identity s... |
| [churn-prevention](marketing/churn-prevention/) | When the user wants to reduce churn, build cancellation flows, set up save offers, improve retention, or recover failed payments. Also use when the user mentions 'churn,' 'cancel flow,' 'offboardin... |
| [cold-email](marketing/cold-email/) | Write B2B cold emails and follow-up sequences that get replies. Use when someone wants cold outreach, prospecting emails, SDR emails, or says 'nobody's replying to my emails.' |
| [common-crawl-backlinks](marketing/common-crawl-backlinks/) | Use when pulling backlinks for any domain for free using Common Crawl's web graph — instead of paying for Ahrefs/Majestic/SEMrush. Triggers on 'backlinks for', 'who links to', 'backlink check', 'co... |
| [competitive-analysis](marketing/competitive-analysis/) | Use when researching competitors and building interactive battlecards. |
| [content-performance-report](marketing/content-performance-report/) | Use when the cron fires at 9am ET on Mondays — pulls Typefully published posts from the last 30 days, classifies them by content pillar, pulls Appfigures download data, scores each pillar, and send... |
| [content-pipeline](marketing/content-pipeline/) | Orchestrator for the 3-article content pipeline — runs research phase, spawns parallel article sub-agents, creates Typefully drafts. Use when running the full content pipeline (usually via cron at ... |
| [content-strategy](marketing/content-strategy/) | Use when building content strategy: hooks, angles, and ideas from what's trending now. Covers organic and paid creative across TikTok, X, YouTube, Meta, LinkedIn. |
| [copywriting](marketing/copywriting/) | Write or improve marketing copy for any surface: pages, ads, app stores, landing pages, TikTok/Meta scripts, push notifications, UGC. Combines page copy frameworks with direct response principles. |
| [create-app-onboarding](marketing/create-app-onboarding/) | >- |
| [dataforseo](marketing/dataforseo/) | Use when doing keyword research (volume, difficulty, ideas), checking App Store or Google Play rankings for Bloom or competitors, or looking up Google SERP rankings for content/landing pages. Also ... |
| [email-sequence](marketing/email-sequence/) | When the user wants to create or optimize an email sequence, drip campaign, push notification flow, or lifecycle messaging program. Also use when the user mentions 'email sequence,' 'drip campaign,... |
| [google-ads](marketing/google-ads/) | Use when managing Google Ads campaigns: performance checks, keyword pausing, report downloads, or campaign optimization via browser or API. |
| [google-ads-scripts](marketing/google-ads-scripts/) | Expert guidance for Google Ads Script development including AdsApp API, campaign management, ad groups, keywords, bidding strategies, performance reporting, budget management, automated rules, and ... |
| [growth](marketing/growth/) | Use when optimizing growth across the full funnel: in-product CRO |
| [hooks](marketing/hooks/) | Use when generating hooks, headlines, titles, and scroll-stopping openers for content. |
| [last30days](marketing/last30days/) | Use when researching what happened in the last 30 days on a topic. Also triggered by 'last30'. Sources: Reddit, X, YouTube, web. Produces expert-level summary with copy-paste-ready prompts. |
| [launch-strategy](marketing/launch-strategy/) | When the user wants to plan a product launch, feature announcement, or release strategy. Use when someone mentions 'launch,' 'Product Hunt,' 'feature release,' 'go-to-market,' 'beta launch,' 'early... |
| [marketing-psychology](marketing/marketing-psychology/) | When the user wants to apply psychological principles, mental models, or behavioral science to marketing. Use when someone mentions 'psychology,' 'mental models,' 'cognitive bias,' 'persuasion,' 'b... |
| [meta-ads](marketing/meta-ads/) | Daily Meta ad operations via Marketing API — check performance, kill losers, promote winners, generate 6 fresh creatives via Nano Banana Pro, upload as new ads, and report to Signal. Runs as cron a... |
| [meta-ads-creative](marketing/meta-ads-creative/) | Create high-converting Meta (Facebook/Instagram) ad creative using the 6 Elements framework, proven ad formats, and research-driven copywriting. Use when creating Facebook ads, Instagram ad creativ... |
| [notebooklm](marketing/notebooklm/) | Use this skill to query your Google NotebookLM notebooks directly from Claude Code for source-grounded, citation-backed answers from Gemini. Also use to generate slide decks, mind maps, audio overv... |
| [paid-ads](marketing/paid-ads/) | When the user wants help with paid advertising campaigns on Google Ads, Meta, LinkedIn, Twitter/X, or other platforms. Use when someone mentions 'PPC,' 'paid media,' 'ROAS,' 'CPA,' 'ad campaign,' '... |
| [positioning-angles](marketing/positioning-angles/) | Use when defining product positioning, choosing strategic angles, crafting value propositions, competitive positioning, product messaging, differentiation strategy, or go-to-market angles. Also use... |
| [post-bloom-features](marketing/post-bloom-features/) | Use when the cron fires at 1am ET on Tuesday or Thursday — runs preflight to find user-facing PRs, screenshots the feature in iOS simulator, renders a Remotion video, creates an unscheduled Typeful... |
| [pricing-strategy](marketing/pricing-strategy/) | When the user wants help with pricing decisions, packaging, or monetization strategy. Use when someone mentions 'pricing,' 'pricing tiers,' 'freemium,' 'free trial,' 'value metric,' 'willingness to... |
| [product-marketing-context](marketing/product-marketing-context/) | When the user wants to create or update their product marketing context document. Use at the start of any new project before using other marketing skills. Creates a context file that all other skil... |
| [prometheus](marketing/prometheus/) | Search TikTok viral videos, App Store rankings, hook analysis, app strategy, and content research via SGE Prometheus MCP. Requires SGE_API_KEY. Use when researching viral video hooks, benchmarking ... |
| [referral-program](marketing/referral-program/) | When the user wants to create, optimize, or analyze a referral program, affiliate program, or word-of-mouth strategy. Use when someone mentions 'referral,' 'affiliate,' 'ambassador,' 'word of mouth... |
| [seo-research](marketing/seo-research/) | Use when doing SEO research: keyword research, AI search optimization, technical audits, schema markup. |
| [trend-research](marketing/trend-research/) | Use when researching what's trending, viral content, social media trends, content ideas from trends, or platform-specific trends on TikTok, YouTube, Instagram, X/Twitter, Substack, LinkedIn, Reddit... |
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
| [google-workspace](productivity/google-workspace/) | Gmail, Calendar, Drive, Contacts, Sheets, and Docs integration for Hermes. Uses Hermes-managed OAuth2 setup, prefers the Google Workspace CLI (`gws`) when available for broader API coverage, and fa... |
| [himalaya](productivity/himalaya/) | CLI to manage emails via IMAP/SMTP. Use himalaya to list, read, write, reply, forward, search, and organize emails from the terminal. Supports multiple accounts and message composition with MML (MI... |
| [imessage](productivity/imessage/) | Send and receive iMessages/SMS via the imsg CLI on macOS. |
| [linear](productivity/linear/) | Manage Linear issues, projects, and teams via the GraphQL API. Create, update, search, and organize issues. Uses API key auth (no OAuth needed). All operations via curl — no dependencies. |
| [minecraft-modpack-server](productivity/minecraft-modpack-server/) | Set up a modded Minecraft server from a CurseForge/Modrinth server pack zip. Covers NeoForge/Forge install, Java version, JVM tuning, firewall, LAN config, backups, and launch scripts. |
| [nano-pdf](productivity/nano-pdf/) | Edit PDFs with natural-language instructions using the nano-pdf CLI. Modify text, fix typos, update titles, and make content changes to specific pages without manual editing. |
| [notion](productivity/notion/) | Notion API for creating and managing pages, databases, and blocks via curl. Search, create, update, and query Notion workspaces directly from the terminal. |
| [obsidian](productivity/obsidian/) | Read, search, and create notes in the Obsidian vault. |
| [ocr-and-documents](productivity/ocr-and-documents/) | Extract text from PDFs and scanned documents. Use web_extract for remote URLs, pymupdf for local text-based PDFs, marker-pdf for OCR/scanned docs. For DOCX use python-docx, for PPTX see the powerpo... |
| [openhue](productivity/openhue/) | Control Philips Hue lights, rooms, and scenes via the OpenHue CLI. Turn lights on/off, adjust brightness, color, color temperature, and activate scenes. |
| [pokemon-player](productivity/pokemon-player/) | Play Pokemon games autonomously via headless emulation. Starts a game server, reads structured game state from RAM, makes strategic decisions, and sends button inputs — all from the terminal. |
| [powerpoint](productivity/powerpoint/) | Use this skill any time a .pptx file is involved in any way — as input, output, or both. This includes: creating slide decks, pitch decks, or presentations; reading, parsing, or extracting text fro... |

### 🔍 Research

| Skill | Description |
|-------|-------------|
| [another-perspective](research/another-perspective/) | Run a multi-perspective council analysis on any question, plan, or decision. Spawns parallel cognitive perspectives (Architect, Skeptic, Pragmatist, Innovator, User Advocate, Temporal Analyst) and ... |
| [arxiv](research/arxiv/) | Search and retrieve academic papers from arXiv using their free REST API. No API key needed. Search by keyword, author, category, or ID. Combine with web_extract or the ocr-and-documents skill to r... |
| [blogwatcher](research/blogwatcher/) | Monitor blogs and RSS/Atom feeds for updates using the blogwatcher-cli tool. Add blogs, scan for new articles, track read status, and filter by category. |
| [hotel-price-research](research/hotel-price-research/) | Research hotel pricing across OTAs for a booking decision. Use when the user is comparing hotels for specific dates and wants real prices (not fabricated). Covers known OTA blockers (Trip.com, IHG.... |
| [llm-wiki](research/llm-wiki/) | Karpathy's LLM Wiki — build and maintain a persistent, interlinked markdown knowledge base. Ingest sources, query compiled knowledge, and lint for consistency. |
| [polymarket](research/polymarket/) | Query Polymarket prediction market data — search markets, get prices, orderbooks, and price history. Read-only via public REST APIs, no API key needed. |
| [research-paper-writing](research/research-paper-writing/) | End-to-end pipeline for writing ML/AI research papers — from experiment design through analysis, drafting, revision, and submission. Covers NeurIPS, ICML, ICLR, ACL, AAAI, COLM. Integrates automate... |
| [sahil-office-hours](research/sahil-office-hours/) | Startup advice frameworks from Sahil Lavingia (Gumroad) based on The Minimalist Entrepreneur. Use when someone is starting a business, validating an idea, finding customers, setting prices, buildin... |
| [synthetic-userstudies](research/synthetic-userstudies/) | Run synthetic user research sessions natively — no backend required. The agent plays an AI-generated persona and simulates a user interview based on the 4 Ps framework (Persona, Problem, Promise, P... |
| [trip-planner](research/trip-planner/) | Generate detailed day-by-day travel itineraries with neighborhood-by-neighborhood routing, budget scaling, dietary-aware meal picks, proximity checks, and post-generation quality validation. Use wh... |
| [yc-office-hours](research/yc-office-hours/) | Product discovery via YC-style forcing questions and 10-star product thinking. Use when starting a new feature, evaluating a product idea, or reframing a request into its most ambitious version. |

### 🎯 Visual Design

| Skill | Description |
|-------|-------------|
| [apple-ux-guidelines](visual-design/apple-ux-guidelines/) | Use when apple HIG reference for UI/UX decisions on Apple platforms. |
| [canvas-design](visual-design/canvas-design/) | Use when create visual art and designs as .png/.pdf files. |
| [create-a-sales-asset](visual-design/create-a-sales-asset/) | Use when generating sales assets (landing pages, decks, one-pagers) from deal context. |
| [d3js-visualization](visual-design/d3js-visualization/) | Use when creating interactive D3.js data visualizations. |
| [design-md](visual-design/design-md/) | Create a DESIGN.md file at the project root — a plain-text design system document that AI coding agents read to produce consistent, on-brand UI. Follows the Google Stitch DESIGN.md format (visual t... |
| [design-mode](visual-design/design-mode/) | Complement to frontend-design — embodies Anthropic's design-surface system prompt (the "expert designer" persona that produces HTML artifacts, decks, prototypes, and animations in a filesystem-base... |
| [design-review](visual-design/design-review/) | Run a product design review on a feature or site. Answers 13 design questions, runs Nielsen Norman heuristic evaluation, builds before/after visual fixes, and deploys a shareable report to Surge. U... |
| [excalidraw-mcp](visual-design/excalidraw-mcp/) | Use when creating hand-drawn style Excalidraw diagrams via the Excalidraw MCP at https://mcp.excalidraw.com/mcp. Use for flow diagrams, architecture diagrams, slide visuals, and any time a sketchy/... |
| [frontend-design](visual-design/frontend-design/) | Use when build production-grade frontend interfaces with high design quality. |
| [frontend-slides](visual-design/frontend-slides/) | Use when creating animation-rich HTML presentations or convert PPT to web. |
| [image-generator](visual-design/image-generator/) | Use when generate article visuals: diagrams, hero images, screenshots. |
| [impeccable](visual-design/impeccable/) | Run impeccable design quality commands on frontend code — audit, critique, polish, animate, normalize, and more. Built on top of the frontend-design skill with 21 steering commands and 10 domain-sp... |
| [slideshow-creator](visual-design/slideshow-creator/) | Create and post TikTok slideshows via ReelFarm. Use for generating slideshow content, setting up automations, and publishing to TikTok. For strategy, scheduling, analytics, and optimization — use t... |
| [sticker-creator](visual-design/sticker-creator/) | Create die-cut sticker style cards via Nano Banana Pro. Use for social media cards, earnings cards, brand stickers, announcement cards, and any content formatted as a bold, clean sticker with a thi... |
| [userinterface-wiki](visual-design/userinterface-wiki/) | UI/UX best practices for web interfaces. Use when reviewing animations, CSS, audio, typography, UX patterns, prefetching, or icon implementations. Covers 11 categories from animation principles to ... |

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
