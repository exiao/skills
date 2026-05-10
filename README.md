# Skills — 90+ Claude Code Skill Templates

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
| [**coding**](coding/) | 23 | Programming, debugging, testing, code review, web scraping |
| [**creative**](creative/) | 37 | Writing, editing, media production, content creation |
| [**devops**](devops/) | 55 | CI/CD, GitHub, Docker, MLOps, model training/inference |
| [**finance**](finance/) | 13 | Investing, market analysis, portfolio management |
| [**marketing**](marketing/) | 38 | Ads (Google/Meta/Apple), SEO, analytics, social media |
| [**memory**](memory/) | 3 | Memory management — GC, setup, and recall |
| [**productivity**](productivity/) | 16 | Apple apps, email, notes, smart home, local search, gaming |
| [**research**](research/) | 10 | Deep research, competitive analysis, market intelligence |
| [**skills-meta**](skills-meta/) | 7 | Skills about skills — creating, auditing, improving, testing |
| [**visual-design**](visual-design/) | 38 | UI/UX design, diagrams, image generation, frontend |
| [**video-production**](video-production/) | 2 | Video production workflows and clip generation |
| [**external-services**](external-services/) | 17 | External service CLIs and API integrations |
| [**media**](media/) | 1 | Media content tools (Spotify, audio) |
| [**ops-center**](ops-center/) | 1 | Ops center codebase review and reference |
| [**reference**](reference/) | 2 | Reference notes for specific projects |
| [**software-development**](software-development/) | 5 | Frameworks, debugging, architecture patterns |
| [**yuanbao**](yuanbao/) | 1 | Yuanbao group management |

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

See [CLAUDE.md](CLAUDE.md) for full conventions.

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

### 💻 Coding & Development

| Skill | Description |
|-------|-------------|
| [babysit-open-prs](coding/babysit-open-prs/) | Scan all open PRs across tracked repos, triage them, check for scope drift, and spawn babysit-pr sub-agents for fixable ones. Use when: babysit all PRs, check all open PRs, nightly PR review. |
| [babysit-pr](coding/babysit-pr/) | Monitor a PR until it's ready to merge. Watches CI, reads reviews, checks scope, fixes issues, and repeats. Use when: babysit this PR, watch this PR, monitor PR, fix and watch PR, keep this PR green. |
| [claude-md-management](coding/claude-md-management/) | Use when asked to audit, improve, or maintain CLAUDE.md files across repos. Triggers on "audit my CLAUDE.md", "check if my CLAUDE.md is up to date", capturing session learnings, or keeping project memory current. |
| [context7](coding/context7/) | Use when writing code that uses a specific library or framework and you need accurate, current API docs — not year-old training data. Fetches version-specific documentation via Context7 MCP. |
| [fastapi-piccolo-typer-testing](coding/fastapi-piccolo-typer-testing/) | Patterns for writing fast, DB-free pytest suites against FastAPI routers, Piccolo ORM queries, Typer CLI commands, and service-layer code. Use when adding test coverage to a FastAPI + Piccolo + Typer app, mocking async ORM query chains, or testing Typer commands that lazily import services.… |
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
| [ci-evals-llm-agents](coding/ci-evals-llm-agents/) | Build CI eval pipelines for LLM agent systems. Use when adding evals to repos with LLM agents, creating SimulatorBac

... [OUTPUT TRUNCATED - 39840 chars omitted out of 89840 total] ...

ng-context/) | When the user wants to create or update their product marketing context document. Use at the start of any new project before using other marketing skills. Creates a context file that all other skills reference for product, audience, and positioning info. |
| [prometheus](marketing/prometheus/) | Search TikTok viral videos, App Store rankings, hook analysis, app strategy, and content research via SGE Prometheus MCP. Requires SGE_API_KEY. Use when researching viral video hooks, benchmarking app rankings, analyzing content trends, or pulling App Store review data. Trigger phrases include… |
| [referral-program](marketing/referral-program/) | When the user wants to create, optimize, or analyze a referral program, affiliate program, or word-of-mouth strategy. Use when someone mentions 'referral,' 'affiliate,' 'ambassador,' 'word of mouth,' 'viral loop,' 'refer a friend,' or 'partner program.' |
| [seo-research](marketing/seo-research/) | Use when doing SEO research: keyword research, AI search optimization, technical audits, schema markup. |
| [trend-research](marketing/trend-research/) | Use when researching what's trending, viral content, social media trends, content ideas from trends, or platform-specific trends on TikTok, YouTube, Instagram, X/Twitter, Substack, LinkedIn, Reddit, and Lemon8. Also use for 'what's viral', 'what's working on social', 'trend report', 'what hooks… |
| [tweet-ideas](marketing/tweet-ideas/) | Use when generating 10-20 standalone tweets to build topical authority on a subject. Not for threads or promos. Uses the Aaron Levie playbook. |
| [typefully](marketing/typefully/) | Use when creating, scheduling, or managing social posts via Typefully. |
| [whop-content-rewards](marketing/whop-content-rewards/) | Set up and manage Content Rewards UGC campaigns on Whop for Bloom. Use when launching new campaigns, adding budget, reviewing submissions, or checking campaign performance. |
| [summarize-timeline](marketing/summarize-timeline/) | Summarize an X/Twitter timeline into a themed daily digest for Signal delivery. |
| [xurl](marketing/xurl/) | Interact with X/Twitter via xurl, the official X API CLI. Posting, replying, quoting, searching, timelines, mentions, likes, bookmarks, follows, DMs. |
| [xitter](marketing/xitter/) | Interact with X/Twitter via the x-cli terminal client using official X API credentials. Use for posting, reading timelines, searching tweets, liking, retweeting, bookmarks, mentions, and user lookups. |

### 🔌 External Services

| Skill | Description |
|-------|-------------|
| [appfigures-cli](external-services/appfigures-cli/) | Use when querying Appfigures for app store analytics (downloads, revenue, reviews, rankings). |
| [apple-search-ads](external-services/apple-search-ads/) | Create, optimize, and scale Apple Search Ads campaigns with API automation, attribution integration, and bid strategy recommendations. |
| [bird-twitter](external-services/bird-twitter/) | Read X/Twitter timelines, tweets, and threads using the bird CLI (cookie-based GraphQL). Use when the user mentions "bird", wants to read their Following/For You timeline, fetch tweets, search X, or pull timeline data for summarization. |
| [copilot-money-cli](external-services/copilot-money-cli/) | Use when querying Copilot Money for finances, transactions, net worth, and holdings. |
| [dataforseo-cli](external-services/dataforseo-cli/) | Use when doing keyword research (volume, difficulty, ideas), checking App Store or Google Play rankings, or looking up Google SERP rankings for content/landing pages. |
| [firecrawl](external-services/firecrawl/) | Scrape, crawl, search, and interact with web pages using Firecrawl CLI and API. Use for JS-rendered pages, full site crawls, sitemaps, form interaction, and login-required pages. |
| [google-ads-cli](external-services/google-ads-cli/) | Use when managing Google Ads campaigns: performance checks, keyword pausing, report downloads, or campaign optimization via browser or API. |
| [gsc-cli](external-services/gsc-cli/) | Query Google Search Console data via MCP and mcporter for verified properties. |
| [grok-imagine](external-services/grok-imagine/) | Generate or edit images via xAI Grok Imagine (Aurora). Supports text-to-image, single-image editing, and multi-image composition (up to 3). |
| [meta-ads-cli](external-services/meta-ads-cli/) | Daily Meta ad operations via Marketing API: check performance, kill losers, promote winners, generate fresh creatives, upload as new ads. |
| [porkbun-cli](external-services/porkbun-cli/) | Manage Porkbun domains, DNS records, SSL certificates, URL forwarding, and hosting blueprints via the Porkbun API. |
| [prometheus-cli](external-services/prometheus-cli/) | Search TikTok viral videos, App Store rankings, hook analysis, app strategy, and content research via SGE Prometheus MCP. |
| [stably-cli](external-services/stably-cli/) | Use the Stably CLI to create, run, fix, and maintain Playwright tests. Use for running tests, auto-fixing failures, or generating new tests from a prompt. |

### 📋 Productivity

| Skill | Description |
|-------|-------------|
| [airtable](productivity/airtable/) | Airtable REST API via curl. Records CRUD, filters, upserts. |
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
| [another-perspective](research/another-perspective/) | Run multi-perspective council analysis on any question, plan, or decision. Spawns parallel cognitive perspectives and synthesizes findings. |
| [quick-brainstorm](research/quick-brainstorm/) | Lightweight brainstorm: 5 versions with estimated probabilities and assumption surfacing. |
| [arxiv](research/arxiv/) | Search and retrieve academic papers from arXiv using their free REST API. No API key needed. Search by keyword, author, category, or ID. Combine with web_extract or the ocr-and-documents skill to read full paper content. |
| [blogwatcher](research/blogwatcher/) | Monitor blogs and RSS/Atom feeds for updates using the blogwatcher-cli tool. Add blogs, scan for new articles, track read status, and filter by category. |
| [hotel-price-research](research/hotel-price-research/) | Research hotel pricing across OTAs for a booking decision. Use when the user is comparing hotels for specific dates and wants real prices (not fabricated). Covers known OTA blockers (Trip.com, IHG.com, Google Hotels) and the Booking.com interactive-form workflow that actually works. Trigger on… |
| [llm-wiki](research/llm-wiki/) | Karpathy's LLM Wiki — build and maintain a persistent, interlinked markdown knowledge base. Ingest sources, query compiled knowledge, and lint for consistency. |
| [research-paper-writing](research/research-paper-writing/) | End-to-end pipeline for writing ML/AI research papers — from experiment design through analysis, drafting, revision, and submission. Covers NeurIPS, ICML, ICLR, ACL, AAAI, COLM. Integrates automated experiment monitoring, statistical analysis, iterative writing, and citation verification. |
| [sahil-office-hours](research/sahil-office-hours/) | Startup advice frameworks from Sahil Lavingia (Gumroad) based on The Minimalist Entrepreneur. Use when someone is starting a business, validating an idea, finding customers, setting prices, building an MVP, creating a marketing plan, defining company values, or making any business decision… |
| [synthetic-userstudies](research/synthetic-userstudies/) | Run synthetic user research sessions natively — no backend required. The agent plays an AI-generated persona and simulates a user interview based on the 4 Ps framework (Persona, Problem, Promise, Product). Use when a user wants to run a user research session, interview a synthetic persona,… |
| [trip-planner](research/trip-planner/) | Generate detailed day-by-day travel itineraries with neighborhood-by-neighborhood routing, budget scaling, dietary-aware meal picks, proximity checks, and post-generation quality validation. Use when: plan a trip, travel itinerary, trip to [destination], vacation planning, travel planner. |
| [yc-office-hours](research/yc-office-hours/) | Product discovery via YC-style forcing questions and 10-star product thinking. Use when starting a new feature, evaluating a product idea, or reframing a request into its most ambitious version. |

### 🎬 Video Production

| Skill | Description |
|-------|-------------|
| [clipify](video-production/clipify/) | Find funny moments in videos, cut clips, reframe vertical, and burn word-by-word captions. |
| [editframe](video-production/editframe/) | Build, preview, and render videos with Editframe, the HTML/CSS/React video composition tool. Use for code-generated videos, Editframe projects, HTML/CSS video compositions, MP4 rendering, and Node.js/FFmpeg video automation. |

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
| [product-design](visual-design/product-design/) | Strategic product design thinking: information architecture, interaction design, AI-native patterns, and quality checklists. Use before building any interface to ensure the right thing gets built. |

### 🔌 External Services

| Skill | Description |
|-------|-------------|
| [appfigures-cli](external-services/appfigures-cli/) | Query Appfigures for app store analytics (downloads, revenue, reviews, rankings). |
| [apple-search-ads](external-services/apple-search-ads/) | Create, optimize, and scale Apple Search Ads campaigns with API automation. |
| [bird-twitter](external-services/bird-twitter/) | Read X/Twitter timelines, tweets, and threads using the bird CLI (cookie-based GraphQL). |
| [copilot-money-cli](external-services/copilot-money-cli/) | Query Copilot Money for finances, transactions, net worth, and holdings. |
| [dataforseo-cli](external-services/dataforseo-cli/) | Keyword research (volume, difficulty, ideas), App Store/Google Play rankings, Google SERP rankings. |
| [firecrawl](external-services/firecrawl/) | Scrape, crawl, search, and interact with web pages using Firecrawl CLI and API. |
| [google-ads-cli](external-services/google-ads-cli/) | Manage Google Ads campaigns: performance checks, keyword pausing, report downloads, campaign optimization. |
| [higgsfield-generate](external-services/higgsfield-generate/) | Generate AI videos and images using Higgsfield. |
| [higgsfield-marketplace-cards](external-services/higgsfield-marketplace-cards/) | Create marketplace-style product cards with Higgsfield. |
| [higgsfield-product-photoshoot](external-services/higgsfield-product-photoshoot/) | AI product photoshoot generation with Higgsfield. |
| [higgsfield-soul-id](external-services/higgsfield-soul-id/) | Manage Soul ID character consistency for Higgsfield generations. |
| [meta-ads-cli](external-services/meta-ads-cli/) | Daily Meta ad operations via Marketing API: Ad Library research, performance checks, creative generation, and reporting. |
| [porkbun-cli](external-services/porkbun-cli/) | Manage Porkbun domains, DNS records, SSL certificates, URL forwarding, and hosting blueprints. |
| [prometheus-cli](external-services/prometheus-cli/) | Search TikTok viral videos, App Store rankings, hook analysis via SGE Prometheus MCP. |
| [stably-cli](external-services/stably-cli/) | Create, run, fix, and maintain Playwright tests using the Stably CLI. |
| [usefastlane-ai](external-services/usefastlane-ai/) | Short-form content platform and REST API for generating, remixing, scheduling TikTok, Reels, and Shorts. |

### 🎵 Media

| Skill | Description |
|-------|-------------|
| [spotify](media/spotify/) | Spotify: play, search, queue, manage playlists and devices. |

### 🏢 Ops Center

| Skill | Description |
|-------|-------------|
| [ops-center-codebase-review](ops-center/ops-center-codebase-review/) | Reference notes from full ops-center codebase review. |

### 📚 Reference

| Skill | Description |
|-------|-------------|
| [fintary-dashboard-notes](reference/fintary-dashboard-notes/) | Reference notes for Fintary ops-center dashboard rebuild. |
| [ops-center-reference](reference/ops-center-reference/) | Fintary ops-center v2 architecture, API proxy pattern, infrastructure, env vars, and related repos. |

### 🛠️ Software Development

| Skill | Description |
|-------|-------------|
| [debugging-hermes-tui-commands](software-development/debugging-hermes-tui-commands/) | Debug Hermes Agent TUI slash commands: Python, gateway, Ink UI. |
| [hermes-agent-skill-authoring](software-development/hermes-agent-skill-authoring/) | Author in-repo SKILL.md: frontmatter, validator, structure. |
| [node-inspect-debugger](software-development/node-inspect-debugger/) | Debug Node.js via --inspect + Chrome DevTools Protocol CLI. |
| [python-debugpy](software-development/python-debugpy/) | Debug Python: pdb REPL + debugpy remote (DAP). |
| [spike](software-development/spike/) | Throwaway experiments to validate an idea before building. |

### 🀄 Yuanbao

| Skill | Description |
|-------|-------------|
| [yuanbao](yuanbao/) | Yuanbao (元宝) groups: @mention users, query info/members. |

---

## Adapted Skills

These started from other open-source projects, modified and extended for these workflows.

### From [Anthropic](https://github.com/anthropics)

| Skill | Original |
|-------|----------|
| [documents](devops/documents/) | [anthropics/skills](https://github.com/anthropics/skills) |
| [wealth-management](finance/wealth-management/) | [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) |
| [earnings-analysis](finance/earnings-analysis/) | [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) |
| [idea-generation](finance/idea-generation/) | [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) |
| [thesis-tracker](finance/thesis-tracker/) | [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) |
| [comps-analysis](finance/comps-analysis/) | [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) |
| [skill-creator](skills-meta/skill-creator/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) |
| [skill-audit](skills-meta/skill-audit/) | Original (inspired by Anthropic's skill patterns) |
| [agent-improver](skills-meta/agent-improver/) | Original (inspired by [NousResearch/hermes-agent-self-evolution](https://github.com/NousResearch/hermes-agent-self-evolution) GEPA methodology) |
| [skill-improver](skills-meta/skill-improver/) | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) |
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
| [impeccable](visual-design/impeccable/) | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| [app-store-screenshots](app-store/app-store-screenshots/) | [ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) |
| [remotion-best-practices](creative/remotion-best-practices/) | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| [remotion-videos](creative/video-production/remotion-videos/) | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| [frontend-slides](visual-design/frontend-slides/) | [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) |
| [last30days](marketing/last30days/) | [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) |
| [stably-sdk-rules](devops/stably-sdk-rules/) | [skills.sh/stablyai](https://skills.sh/stablyai/agent-skills/stably-sdk-rules) |
| [sahil-office-hours](research/sahil-office-hours/) | [slavingia/skills](https://github.com/slavingia/skills) |
| [design-md](creative/design-md/) | [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) + [Google Stitch DESIGN.md spec](https://stitch.withgoogle.com/docs/design-md/overview/) |
| [design-mode](visual-design/design-mode/) | [elder-plinius/CL4R1T4S](https://github.com/elder-plinius/CL4R1T4S/blob/main/ANTHROPIC/Claude-Design-Sys-Prompt.txt) (Anthropic design-surface system prompt) |

## License

MIT