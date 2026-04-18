---
name: hermes-agent
description: Complete guide to using and extending Hermes Agent — CLI usage, setup, configuration, spawning additional agents, gateway platforms, skills, voice, tools, profiles, and a concise contributor reference. Load this skill when helping users configure Hermes, troubleshoot issues, spawn agent instances, or make code contributions.
version: 2.0.0
author: Hermes Agent + Teknium
license: MIT
metadata:
  hermes:
    tags: [hermes, setup, configuration, multi-agent, spawning, cli, gateway, development]
    homepage: https://github.com/NousResearch/hermes-agent
    related_skills: [claude-code, codex, opencode]
---

# Hermes Agent

Hermes Agent is an open-source AI agent framework by Nous Research that runs in your terminal, messaging platforms, and IDEs. It belongs to the same category as Claude Code (Anthropic), Codex (OpenAI), and OpenClaw — autonomous coding and task-execution agents that use tool calling to interact with your system. Hermes works with any LLM provider (OpenRouter, Anthropic, OpenAI, DeepSeek, local models, and 15+ others) and runs on Linux, macOS, and WSL.

What makes Hermes different:

- **Self-improving through skills** — Hermes learns from experience by saving reusable procedures as skills. When it solves a complex problem, discovers a workflow, or gets corrected, it can persist that knowledge as a skill document that loads into future sessions. Skills accumulate over time, making the agent better at your specific tasks and environment.
- **Persistent memory across sessions** — remembers who you are, your preferences, environment details, and lessons learned. Pluggable memory backends (built-in, Honcho, Mem0, and more) let you choose how memory works.
- **Multi-platform gateway** — the same agent runs on Telegram, Discord, Slack, WhatsApp, Signal, Matrix, Email, and 8+ other platforms with full tool access, not just chat.
- **Provider-agnostic** — swap models and providers mid-workflow without changing anything else. Credential pools rotate across multiple API keys automatically.
- **Profiles** — run multiple independent Hermes instances with isolated configs, sessions, skills, and memory.
- **Extensible** — plugins, MCP servers, custom tools, webhook triggers, cron scheduling, and the full Python ecosystem.

People use Hermes for software development, research, system administration, data analysis, content creation, home automation, and anything else that benefits from an AI agent with persistent context and full system access.

**This skill helps you work with Hermes Agent effectively** — setting it up, configuring features, spawning additional agent instances, troubleshooting issues, finding the right commands and settings, and understanding how the system works when you need to extend or contribute to it.

**Docs:** https://hermes-agent.nousresearch.com/docs/

## Repository Stats (as of Apr 2026)
- ⭐ 70k stars | 🍴 9.3k forks | 403 contributors | 4,001 commits
- License: MIT | Language: Python 93.3%
- Latest: v0.8.0 | Lead maintainer: @teknium1

## Quick Start

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# Interactive chat (default)
hermes

# Single query
hermes chat -q "What is the capital of France?"

# Setup wizard
hermes setup

# Change model/provider
hermes model

# Check health
hermes doctor
```

---

## Architecture

### System Overview

```text
┌─────────────────────────────────────────────────────────────────────┐
│                        Entry Points                                  │
│  CLI (cli.py)    Gateway (gateway/run.py)    ACP (acp_adapter/)     │
│  Batch Runner    API Server                  Python Library          │
└──────────┬──────────────┬───────────────────────┬───────────────────┘
           │              │                       │
           ▼              ▼                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     AIAgent (run_agent.py)                           │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                │
│  │ Prompt        │ │ Provider     │ │ Tool         │                │
│  │ Builder       │ │ Resolution   │ │ Dispatch     │                │
│  │ (prompt_      │ │ (runtime_    │ │ (model_      │                │
│  │  builder.py)  │ │  provider.py)│ │  tools.py)   │                │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘                │
│  ┌──────┴───────┐ ┌──────┴───────┐ ┌──────┴───────┐                │
│  │ Compression  │ │ 3 API Modes  │ │ Tool Registry│                │
│  │ & Caching    │ │ chat_compl.  │ │ (registry.py)│                │
│  │              │ │ codex_resp.  │ │ 48 tools     │                │
│  │              │ │ anthropic    │ │ 40 toolsets   │                │
│  └──────────────┘ └──────────────┘ └──────────────┘                │
└─────────────────────────────────────────────────────────────────────┘
           │                                    │
           ▼                                    ▼
┌───────────────────┐              ┌──────────────────────┐
│ Session Storage   │              │ Tool Backends         │
│ (SQLite + FTS5)   │              │ Terminal (6 backends) │
│ hermes_state.py   │              │ Browser (5 backends)  │
│ gateway/session.py│              │ Web (4 backends)      │
└───────────────────┘              │ MCP (dynamic)         │
                                   └──────────────────────┘
```

### Agent Loop Internals

The core orchestration engine is `AIAgent` in `run_agent.py` — ~9,200 lines handling prompt assembly, tool dispatch, and provider failover.

**Core Responsibilities:**
- Assembling system prompt and tool schemas via `prompt_builder.py`
- Selecting correct provider/API mode
- Making interruptible model calls with cancellation support
- Executing tool calls (sequentially or concurrently via thread pool)
- Maintaining conversation history in OpenAI message format
- Handling compression, retries, and fallback model switching
- Tracking iteration budgets across parent and child agents
- Flushing persistent memory before context is lost

**Two Entry Points:**
```python
# Simple — returns final response string
response = agent.chat("Fix the bug in main.py")

# Full — returns dict with messages, metadata, usage stats
result = agent.run_conversation(
    user_message="Fix the bug in main.py",
    system_message=None,           # auto-built if omitted
    conversation_history=None,      # auto-loaded from session if omitted
    task_id="task_abc123"
)
```

**Three API Modes** (resolved from provider selection, explicit args, and base URL heuristics):

| API mode | Used for | Client type |
|---|---|---|
| `chat_completions` | OpenAI-compatible endpoints (OpenRouter, custom, most providers) | `openai.OpenAI` |
| `codex_responses` | OpenAI Codex / Responses API | `openai.OpenAI` with Responses format |
| `anthropic_messages` | Native Anthropic Messages API | `anthropic.Anthropic` via adapter |

Mode resolution order (highest → lowest priority):
1. Explicit `api_mode` constructor arg
2. Provider-specific detection (e.g., `anthropic` → `anthropic_messages`)
3. Base URL heuristics (e.g., `api.anthropic.com` → `anthropic_messages`)
4. Default: `chat_completions`

**Turn Lifecycle:**
```
run_conversation()
  1. Generate task_id if not provided
  2. Append user message to conversation history
  3. Build or reuse cached system prompt (prompt_builder.py)
  4. Check if preflight compression is needed (>50% context)
  5. Build API messages from conversation history
  6. Inject ephemeral prompt layers (budget warnings, context pressure)
  7. Apply prompt caching markers if on Anthropic
  8. Make interruptible API call (_api_call_with_interrupt)
  9. Parse response:
     - If tool_calls: execute them, append results, loop back to step 5
     - If text response: persist session, flush memory if needed, return
```

**Message Format (OpenAI-compatible internally):**
```json
{"role": "system", "content": "..."}
{"role": "user", "content": "..."}
{"role": "assistant", "content": "...", "tool_calls": [...]}
{"role": "tool", "tool_call_id": "...", "content": "..."}
```

**Message Alternation Rules:**
- `User → Assistant → User → Assistant → ...`
- During tool calling: `Assistant (with tool_calls) → Tool → Tool → ... → Assistant`
- Never two assistant or two user messages in a row
- Only `tool` role can have consecutive entries (parallel tool results)

**Interruptible API Calls:** API requests run in a background thread via `_api_call_with_interrupt()`. When interrupted (new user message, `/stop`, or signal), the API thread is abandoned and no partial response is injected.

**Tool Execution — Sequential vs Concurrent:**
- Single tool call → executed directly in main thread
- Multiple tool calls → concurrent via `ThreadPoolExecutor`
  - Exception: interactive tools (e.g., `clarify`) force sequential
  - Results reinserted in original call order regardless of completion order

**Tool Execution Flow:**
```
for each tool_call in response.tool_calls:
    1. Resolve handler from tools/registry.py
    2. Fire pre_tool_call plugin hook
    3. Check if dangerous command (tools/approval.py)
       - If dangerous: invoke approval_callback, wait for user
    4. Execute handler with args + task_id
    5. Fire post_tool_call plugin hook
    6. Append {"role": "tool", "content": result} to history
```

**Agent-Level Tools (Intercepted Before Registry):**

| Tool | Why intercepted |
|---|---|
| `todo` | Reads/writes agent-local task state |
| `memory` | Writes to persistent memory files with character limits |
| `session_search` | Queries session history via FTS5 |
| `delegate_task` | Spawns child agent with shared iteration budget |

---

## Persistent Memory

Two files make up the agent's memory:

| File | Purpose | Char Limit |
|---|---|---|
| **MEMORY.md** | Agent's personal notes — environment facts, conventions, things learned | 2,200 chars (~800 tokens) |
| **USER.md** | User profile — preferences, communication style, expectations | 1,375 chars (~500 tokens) |

Both stored in `~/.hermes/memories/` and injected into the system prompt as a frozen snapshot at session start.

**How Memory Appears in the System Prompt:**
```text
══════════════════════════════════════════════
MEMORY (your personal notes) [67% — 1,474/2,200 chars]
══════════════════════════════════════════════
User's project is a Rust web service at ~/code/myapi using Axum + SQLx
§
This machine runs Ubuntu 22.04, has Docker and Podman installed
§
User prefers concise responses, dislikes verbose explanations
```

**Frozen snapshot pattern:** The system prompt injection is captured once at session start and never changes mid-session. This preserves the LLM's prefix cache. When the agent adds/removes memory during a session, changes persist to disk immediately but won't appear in the system prompt until the next session. Tool responses always show the live state.

**Memory Tool Actions:**
- **add** — Add a new memory entry
- **replace** — Replace an existing entry (uses substring matching via `old_text`)
- **remove** — Remove an entry (uses substring matching via `old_text`)
- No `read` action — memory is automatically injected into the system prompt

**Two Targets:**
- `memory` — Agent's personal notes (environment facts, project conventions, tool quirks, completed task diary, techniques)
- `user` — User profile (name, role, timezone, communication preferences, pet peeves, workflow habits, technical skill level)

**What to Save:** Long-lived facts, environment details, user preferences, lessons learned, recurring patterns.
**What to Skip:** Session-specific data, transient state, things already in AGENTS.md or skills.

**Memory Nudges:** The agent periodically gets nudged to persist important knowledge. The nudge system is part of the agent loop — when the conversation reaches certain checkpoints, the agent evaluates whether there's anything worth remembering.

### Memory Providers (8 third-party plugins)

Only one third-party provider active at a time. Built-in memory always active alongside it.

```bash
hermes memory setup      # interactive picker
hermes memory status     # check what's active
hermes memory off        # disable third-party provider
```

| Provider | Best for | Requires |
|---|---|---|
| **Honcho** | Multi-agent systems, user modeling | `pip install honcho-ai` + API key |
| **Mem0** | Simple persistent memory | `pip install mem0ai` + API key |
| **OpenViking** | Semantic search memory | API key |
| **Hindsight** | Timeline-based recall | API key |
| **Holographic** | Associative memory | API key |
| **RetainDB** | Structured memory | API key |
| **ByteRover** | Web-augmented memory | API key |
| **SuperMemory** | AI-native memory | API key |

When active, Hermes automatically: injects provider context into system prompt, prefetches relevant memories before each turn, syncs conversation turns after each response, extracts memories on session end, mirrors built-in memory writes, and adds provider-specific tools.

---

## Context Files

Hermes auto-discovers and loads context files that shape behavior.

| File | Purpose | Discovery |
|---|---|---|
| **.hermes.md** / **HERMES.md** | Project instructions (highest priority) | Walks to git root |
| **AGENTS.md** | Project instructions, conventions, architecture | CWD at startup + subdirectories progressively |
| **CLAUDE.md** | Claude Code context files (also detected) | CWD at startup + subdirectories progressively |
| **SOUL.md** | Global personality and tone | `HERMES_HOME/SOUL.md` only |
| **.cursorrules** | Cursor IDE coding conventions | CWD only |
| **.cursor/rules/*.mdc** | Cursor IDE rule modules | CWD only |

**Priority:** Only one project context type loaded per session (first match wins): `.hermes.md` → `AGENTS.md` → `CLAUDE.md` → `.cursorrules`. SOUL.md always loaded independently as agent identity (slot #1).

### Progressive Subdirectory Discovery

At session start, Hermes loads `AGENTS.md` from your working directory. As the agent navigates into subdirectories (via `read_file`, `terminal`, `search_files`, etc.), it progressively discovers context files and injects them at the moment they become relevant.

```text
my-project/
├── AGENTS.md              ← Loaded at startup (system prompt)
├── frontend/
│   └── AGENTS.md          ← Discovered when agent reads frontend/ files
├── backend/
│   └── AGENTS.md          ← Discovered when agent reads backend/ files
└── shared/
    └── AGENTS.md          ← Discovered when agent reads shared/ files
```

Advantages: no system prompt bloat, prompt cache preservation. Each subdirectory checked at most once per session.

### SOUL.md (Personality)

`SOUL.md` is the agent's primary identity — slot #1 in the system prompt. Lives in `~/.hermes/SOUL.md` (or `$HERMES_HOME/SOUL.md`).

- Hermes seeds a default `SOUL.md` automatically if one doesn't exist
- Existing files are never overwritten
- Loaded only from `HERMES_HOME`, NOT from CWD (keeps personality predictable across projects)
- If empty, falls back to built-in default identity
- Content goes through prompt-injection scanning and truncation

**Good SOUL.md content:** Tone, communication style, directness level, how to handle uncertainty/disagreement. NOT for project-specific instructions (those belong in AGENTS.md).

Example:
```markdown
# Personality
You are a pragmatic senior engineer with strong taste.
You optimize for truth, clarity, and usefulness over politeness theater.

## Style
- Be direct without being cold
- Prefer substance over filler
- Push back when something is a bad idea
- Admit uncertainty plainly

## What to avoid
- Sycophancy, hype language
- Repeating the user's framing if it's wrong
- Overexplaining obvious things
```

---

## Skills System (Deep Dive)

Skills are on-demand knowledge documents following a **progressive disclosure** pattern, compatible with [agentskills.io](https://agentskills.io/specification). All skills live in `~/.hermes/skills/`.

### Progressive Disclosure
```text
Level 0: skills_list()           → [{name, description, category}, ...]   (~3k tokens)
Level 1: skill_view(name)        → Full content + metadata                (varies)
Level 2: skill_view(name, path)  → Specific reference file                (varies)
```

### SKILL.md Format
```markdown
---
name: my-skill
description: Brief description
version: 1.0.0
platforms: [macos, linux]     # Optional — restrict to specific OS
metadata:
  hermes:
    tags: [python, automation]
    category: devops
    fallback_for_toolsets: [web]    # Show ONLY when these toolsets unavailable
    requires_toolsets: [terminal]   # Show ONLY when these toolsets available
    config:                          # Optional config.yaml settings
      - key: my.setting
        description: "What this controls"
        default: "value"
        prompt: "Prompt for setup"
---

# Skill Title
## When to Use
## Procedure
## Pitfalls
## Verification
```

### Conditional Activation (Fallback Skills)
Skills can auto-show/hide based on which tools are available:
- `fallback_for_toolsets: [web]` — Show ONLY when web toolset is unavailable (free alternative)
- `requires_toolsets: [terminal]` — Show ONLY when terminal toolset is available

### External Skill Directories
Point Hermes at additional folders:
```yaml
# In config.yaml
skills:
  third-party_directories:
    - /path/to/shared-skills
    - ~/my-org-skills
```

### Agent-Created Skills
The agent can create skills autonomously when it discovers reusable procedures. Skills are saved to `~/.hermes/skills/` and immediately available.

### Skills Hub
```bash
hermes skills search QUERY    # Search community skills
hermes skills install ID      # Install from hub
hermes skills publish PATH    # Publish your skill
hermes skills tap add REPO    # Add a GitHub repo as skill source
```

---

## Plugin System

Drop a directory into `~/.hermes/plugins/` with a `plugin.yaml` and Python code:

```text
~/.hermes/plugins/my-plugin/
├── plugin.yaml      # manifest
├── __init__.py      # register() — wires schemas to handlers
├── schemas.py       # tool schemas (what the LLM sees)
└── tools.py         # tool handlers (what runs when called)
```

**What plugins can do:**

| Capability | How |
|---|---|
| Add tools | `ctx.register_tool(name, schema, handler)` |
| Add hooks | `ctx.register_hook("post_tool_call", callback)` |
| Add CLI commands | `ctx.register_cli_command(name, help, setup_fn, handler_fn)` |
| Inject messages | `ctx.inject_message(content, role="user")` |
| Ship data files | `Path(__file__).parent / "data" / "file.yaml"` |
| Bundle skills | Copy `skill.md` to `~/.hermes/skills/` at load time |
| Gate on env vars | `requires_env: [API_KEY]` in plugin.yaml |
| Distribute via pip | `[project.entry-points."hermes_agent.plugins"]` |

**Available Hooks:** `pre_tool_call`, `post_tool_call`, `pre_llm_call` (can inject context), plus lifecycle hooks.

**Plugin Discovery:**

| Source | Path | Use case |
|---|---|---|
| User | `~/.hermes/plugins/` | Personal plugins |
| Project | `.hermes/plugins/` | Project-specific (requires `HERMES_ENABLE_PROJECT_PLUGINS=true`) |
| pip | `hermes_agent.plugins` entry_points | Distributed packages |

**Minimal plugin example:**
```python
def register(ctx):
    schema = {
        "name": "hello_world",
        "description": "Returns a greeting.",
        "parameters": {
            "type": "object",
            "properties": {"name": {"type": "string", "description": "Name to greet"}},
            "required": ["name"],
        },
    }
    def handle_hello(params):
        return f"Hello, {params.get('name', 'World')}! 👋"
    ctx.register_tool("hello_world", schema, handle_hello)
    ctx.register_hook("post_tool_call", lambda name, params, result: print(f"[plugin] {name} called"))
```

---

## Security Model (7 Layers)

1. **User authorization** — allowlists, DM pairing
2. **Dangerous command approval** — human-in-the-loop for destructive operations
3. **Container isolation** — Docker/Singularity/Modal sandboxing
4. **MCP credential filtering** — env var isolation for MCP subprocesses
5. **Context file scanning** — prompt injection detection in project files
6. **Cross-session isolation** — sessions can't access each other's data; path traversal hardened
7. **Input sanitization** — working directory params validated against allowlist

### Dangerous Command Approval

Three modes via `approvals.mode` in config.yaml:

| Mode | Behavior |
|---|---|
| **manual** (default) | Always prompt user for approval on dangerous commands |
| **smart** | Auxiliary LLM assesses risk. Low-risk auto-approved, dangerous auto-denied, uncertain escalates to manual |
| **off** | Disable all approval checks (equivalent to `--yolo`) |

**What triggers approval:** `rm -r`, `rm ... /`, `chmod 777/666`, `chown -R root`, `mkfs`, `dd if=`, `DROP TABLE/DATABASE`, `DELETE FROM` (without WHERE), `TRUNCATE TABLE`, `> /etc/`, `systemctl stop/disable/mask`, `kill -9 -1`, `pkill -9`, and more (defined in `tools/approval.py`).

**YOLO Mode:** Bypasses all approval prompts. Activate via:
- CLI flag: `hermes --yolo`
- Slash command: `/yolo` (toggle)
- Environment: `HERMES_YOLO_MODE=1`

**Approval Timeout:** Configurable (default 60s). If no response, command is denied (fail-closed).

---

## CLI Reference

### Global Flags

```
hermes [flags] [command]

  --version, -V             Show version
  --resume, -r SESSION      Resume session by ID or title
  --continue, -c [NAME]     Resume by name, or most recent session
  --worktree, -w            Isolated git worktree mode (parallel agents)
  --skills, -s SKILL        Preload skills (comma-separate or repeat)
  --profile, -p NAME        Use a named profile
  --yolo                    Skip dangerous command approval
  --pass-session-id         Include session ID in system prompt
```

No subcommand defaults to `chat`.

### Chat

```
hermes chat [flags]
  -q, --query TEXT          Single query, non-interactive
  -m, --model MODEL         Model (e.g. anthropic/claude-sonnet-4)
  -t, --toolsets LIST       Comma-separated toolsets
  --provider PROVIDER       Force provider (openrouter, anthropic, nous, etc.)
  -v, --verbose             Verbose output
  -Q, --quiet               Suppress banner, spinner, tool previews
  --checkpoints             Enable filesystem checkpoints (/rollback)
  --source TAG              Session source tag (default: cli)
```

### Configuration

```
hermes setup [section]      Interactive wizard (model|terminal|gateway|tools|agent)
hermes model                Interactive model/provider picker
hermes config               View current config
hermes config edit          Open config.yaml in $EDITOR
hermes config set KEY VAL   Set a config value
hermes config path          Print config.yaml path
hermes config env-path      Print .env path
hermes config check         Check for missing/outdated config
hermes config migrate       Update config with new options
hermes login [--provider P] OAuth login (nous, openai-codex)
hermes logout               Clear stored auth
hermes doctor [--fix]       Check dependencies and config
hermes status [--all]       Show component status
```

### Tools & Skills

```
hermes tools                Interactive tool enable/disable (curses UI)
hermes tools list           Show all tools and status
hermes tools enable NAME    Enable a toolset
hermes tools disable NAME   Disable a toolset

hermes skills list          List installed skills
hermes skills search QUERY  Search the skills hub
hermes skills install ID    Install a skill
hermes skills inspect ID    Preview without installing
hermes skills config        Enable/disable skills per platform
hermes skills check         Check for updates
hermes skills update        Update outdated skills
hermes skills uninstall N   Remove a hub skill
hermes skills publish PATH  Publish to registry
hermes skills browse        Browse all available skills
hermes skills tap add REPO  Add a GitHub repo as skill source
```

### MCP Servers

```
hermes mcp serve            Run Hermes as an MCP server
hermes mcp add NAME         Add an MCP server (--url or --command)
hermes mcp remove NAME      Remove an MCP server
hermes mcp list             List configured servers
hermes mcp test NAME        Test connection
hermes mcp configure NAME   Toggle tool selection
```

### Gateway (Messaging Platforms)

```
hermes gateway run          Start gateway foreground
hermes gateway install      Install as background service
hermes gateway start/stop   Control the service
hermes gateway restart      Restart the service
hermes gateway status       Check status
hermes gateway setup        Configure platforms
```

Supported platforms: Telegram, Discord, Slack, WhatsApp, Signal, Email, SMS, Matrix, Mattermost, Home Assistant, DingTalk, Feishu, WeCom, API Server, Webhooks, Open WebUI.

Platform docs: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/

### Sessions

```
hermes sessions list        List recent sessions
hermes sessions browse      Interactive picker
hermes sessions export OUT  Export to JSONL
hermes sessions rename ID T Rename a session
hermes sessions delete ID   Delete a session
hermes sessions prune       Clean up old sessions (--older-than N days)
hermes sessions stats       Session store statistics
```

### Cron Jobs

```
hermes cron list            List jobs (--all for disabled)
hermes cron create SCHED    Create: '30m', 'every 2h', '0 9 * * *'
hermes cron edit ID         Edit schedule, prompt, delivery
hermes cron pause/resume ID Control job state
hermes cron run ID          Trigger on next tick
hermes cron remove ID       Delete a job
hermes cron status          Scheduler status
```

### Webhooks

```
hermes webhook subscribe N  Create route at /webhooks/<name>
hermes webhook list         List subscriptions
hermes webhook remove NAME  Remove a subscription
hermes webhook test NAME    Send a test POST
```

### Profiles

```
hermes profile list         List all profiles
hermes profile create NAME  Create (--clone, --clone-all, --clone-from)
hermes profile use NAME     Set sticky default
hermes profile delete NAME  Delete a profile
hermes profile show NAME    Show details
hermes profile alias NAME   Manage wrapper scripts
hermes profile rename A B   Rename a profile
hermes profile export NAME  Export to tar.gz
hermes profile import FILE  Import from archive
```

### Credential Pools

```
hermes auth add             Interactive credential wizard
hermes auth list [PROVIDER] List pooled credentials
hermes auth remove P INDEX  Remove by provider + index
hermes auth reset PROVIDER  Clear exhaustion status
```

### Other

```
hermes insights [--days N]  Usage analytics
hermes update               Update to latest version
hermes pairing list/approve/revoke  DM authorization
hermes plugins list/install/remove  Plugin management
hermes honcho setup/status  Honcho memory integration
hermes memory setup/status/off  Memory provider config
hermes completion bash|zsh  Shell completions
hermes acp                  ACP server (IDE integration)
hermes claw migrate         Migrate from OpenClaw
hermes uninstall            Uninstall Hermes
```

---

## Slash Commands (In-Session)

Type these during an interactive chat session.

### Session Control
```
/new (/reset)        Fresh session
/clear               Clear screen + new session (CLI)
/retry               Resend last message
/undo                Remove last exchange
/title [name]        Name the session
/compress            Manually compress context
/stop                Kill background processes
/rollback [N]        Restore filesystem checkpoint
/background <prompt> Run prompt in background
/queue <prompt>      Queue for next turn
/resume [name]       Resume a named session
```

### Configuration
```
/config              Show config (CLI)
/model [name]        Show or change model
/provider            Show provider info
/personality [name]  Set personality
/reasoning [level]   Set reasoning (none|minimal|low|medium|high|xhigh|show|hide)
/verbose             Cycle: off → new → all → verbose
/voice [on|off|tts]  Voice mode
/yolo                Toggle approval bypass
/skin [name]         Change theme (CLI)
/statusbar           Toggle status bar (CLI)
```

### Tools & Skills
```
/tools               Manage tools (CLI)
/toolsets            List toolsets (CLI)
/skills              Search/install skills (CLI)
/skill <name>        Load a skill into session
/cron                Manage cron jobs (CLI)
/reload-mcp          Reload MCP servers
/plugins             List plugins (CLI)
```

### Info
```
/help                Show commands
/commands [page]     Browse all commands (gateway)
/usage               Token usage
/insights [days]     Usage analytics
/status              Session info (gateway)
/profile             Active profile info
```

### Exit
```
/quit (/exit, /q)    Exit CLI
```

---

## Key Paths & Config

```
~/.hermes/config.yaml       Main configuration
~/.hermes/.env              API keys and secrets
~/.hermes/skills/           Installed skills
~/.hermes/sessions/         Session transcripts
~/.hermes/logs/             Gateway and error logs
~/.hermes/auth.json         OAuth tokens and credential pools
~/.hermes/hermes-agent/     Source code (if git-installed)
```

Profiles use `~/.hermes/profiles/<name>/` with the same layout.

### Config Sections

Edit with `hermes config edit` or `hermes config set section.key value`.

| Section | Key options |
|---------|-------------|
| `model` | `default`, `provider`, `base_url`, `api_key`, `context_length` |
| `agent` | `max_turns` (90), `tool_use_enforcement` |
| `terminal` | `backend` (local/docker/ssh/modal), `cwd`, `timeout` (180) |
| `compression` | `enabled`, `threshold` (0.50), `target_ratio` (0.20) |
| `display` | `skin`, `tool_progress`, `show_reasoning`, `show_cost` |
| `stt` | `enabled`, `provider` (local/groq/openai) |
| `tts` | `provider` (edge/elevenlabs/openai/kokoro/fish) |
| `memory` | `memory_enabled`, `user_profile_enabled`, `provider` |
| `security` | `tirith_enabled`, `website_blocklist` |
| `delegation` | `model`, `provider`, `max_iterations` (50) |
| `smart_model_routing` | `enabled`, `cheap_model` |
| `checkpoints` | `enabled`, `max_snapshots` (50) |

Full config reference: https://hermes-agent.nousresearch.com/docs/user-guide/configuration

### Providers

18 providers supported. Set via `hermes model` or `hermes setup`.

| Provider | Auth | Key env var |
|----------|------|-------------|
| OpenRouter | API key | `OPENROUTER_API_KEY` |
| Anthropic | API key | `ANTHROPIC_API_KEY` |
| Nous Portal | OAuth | `hermes login --provider nous` |
| OpenAI Codex | OAuth | `hermes login --provider openai-codex` |
| GitHub Copilot | Token | `COPILOT_GITHUB_TOKEN` |
| DeepSeek | API key | `DEEPSEEK_API_KEY` |
| Hugging Face | Token | `HF_TOKEN` |
| Z.AI / GLM | API key | `GLM_API_KEY` |
| MiniMax | API key | `MINIMAX_API_KEY` |
| Kimi / Moonshot | API key | `KIMI_API_KEY` |
| Alibaba / DashScope | API key | `DASHSCOPE_API_KEY` |
| Kilo Code | API key | `KILOCODE_API_KEY` |
| Custom endpoint | Config | `model.base_url` + `model.api_key` in config.yaml |

Plus: AI Gateway, OpenCode Zen, OpenCode Go, MiniMax CN, GitHub Copilot ACP.

Full provider docs: https://hermes-agent.nousresearch.com/docs/integrations/providers

### Toolsets

Enable/disable via `hermes tools` (interactive) or `hermes tools enable/disable NAME`.

| Toolset | What it provides |
|---------|-----------------|
| `web` | Web search and content extraction |
| `browser` | Browser automation (Browserbase, Camofox, or local Chromium) |
| `terminal` | Shell commands and process management |
| `file` | File read/write/search/patch |
| `code_execution` | Sandboxed Python execution |
| `vision` | Image analysis |
| `image_gen` | AI image generation |
| `tts` | Text-to-speech |
| `skills` | Skill browsing and management |
| `memory` | Persistent cross-session memory |
| `session_search` | Search past conversations |
| `delegation` | Subagent task delegation |
| `cronjob` | Scheduled task management |
| `clarify` | Ask user clarifying questions |
| `moa` | Mixture of Agents (off by default) |
| `homeassistant` | Smart home control (off by default) |

Tool changes take effect on `/reset` (new session). They do NOT apply mid-conversation to preserve prompt caching.

---

## Voice & Transcription

### STT (Voice → Text)

Voice messages from messaging platforms are auto-transcribed.

Provider priority (auto-detected):
1. **Local faster-whisper** — free, no API key: `pip install faster-whisper`
2. **Groq Whisper** — free tier: set `GROQ_API_KEY`
3. **OpenAI Whisper** — paid: set `VOICE_TOOLS_OPENAI_KEY`

Config:
```yaml
stt:
  enabled: true
  provider: local        # local, groq, openai
  local:
    model: base          # tiny, base, small, medium, large-v3
```

### TTS (Text → Voice)

| Provider | Env var | Free? |
|----------|---------|-------|
| Edge TTS | None | Yes (default) |
| ElevenLabs | `ELEVENLABS_API_KEY` | Free tier |
| OpenAI | `VOICE_TOOLS_OPENAI_KEY` | Paid |
| Kokoro (local) | None | Free |
| Fish Audio | `FISH_AUDIO_API_KEY` | Free tier |

Voice commands: `/voice on` (voice-to-voice), `/voice tts` (always voice), `/voice off`.

---

## Spawning Additional Hermes Instances

Run additional Hermes processes as fully independent subprocesses — separate sessions, tools, and environments.

### When to Use This vs delegate_task

| | `delegate_task` | Spawning `hermes` process |
|-|-----------------|--------------------------|
| Isolation | Separate conversation, shared process | Fully independent process |
| Duration | Minutes (bounded by parent loop) | Hours/days |
| Tool access | Subset of parent's tools | Full tool access |
| Interactive | No | Yes (PTY mode) |
| Use case | Quick parallel subtasks | Long autonomous missions |

### One-Shot Mode

```
terminal(command="hermes chat -q 'Research GRPO papers and write summary to ~/research/grpo.md'", timeout=300)

# Background for long tasks:
terminal(command="hermes chat -q 'Set up CI/CD for ~/myapp'", background=true)
```

### Interactive PTY Mode (via tmux)

Hermes uses prompt_toolkit, which requires a real terminal. Use tmux for interactive spawning:

```
# Start
terminal(command="tmux new-session -d -s agent1 -x 120 -y 40 'hermes'", timeout=10)

# Wait for startup, then send a message
terminal(command="sleep 8 && tmux send-keys -t agent1 'Build a FastAPI auth service' Enter", timeout=15)

# Read output
terminal(command="sleep 20 && tmux capture-pane -t agent1 -p", timeout=5)

# Send follow-up
terminal(command="tmux send-keys -t agent1 'Add rate limiting middleware' Enter", timeout=5)

# Exit
terminal(command="tmux send-keys -t agent1 '/exit' Enter && sleep 2 && tmux kill-session -t agent1", timeout=10)
```

### Multi-Agent Coordination

```
# Agent A: backend
terminal(command="tmux new-session -d -s backend -x 120 -y 40 'hermes -w'", timeout=10)
terminal(command="sleep 8 && tmux send-keys -t backend 'Build REST API for user management' Enter", timeout=15)

# Agent B: frontend
terminal(command="tmux new-session -d -s frontend -x 120 -y 40 'hermes -w'", timeout=10)
terminal(command="sleep 8 && tmux send-keys -t frontend 'Build React dashboard for user management' Enter", timeout=15)

# Check progress, relay context between them
terminal(command="tmux capture-pane -t backend -p | tail -30", timeout=5)
terminal(command="tmux send-keys -t frontend 'Here is the API schema from the backend agent: ...' Enter", timeout=5)
```

### Session Resume

```
# Resume most recent session
terminal(command="tmux new-session -d -s resumed 'hermes --continue'", timeout=10)

# Resume specific session
terminal(command="tmux new-session -d -s resumed 'hermes --resume 20260225_143052_a1b2c3'", timeout=10)
```

### Tips

- **Prefer `delegate_task` for quick subtasks** — less overhead than spawning a full process
- **Use `-w` (worktree mode)** when spawning agents that edit code — prevents git conflicts
- **Set timeouts** for one-shot mode — complex tasks can take 5-10 minutes
- **Use `hermes chat -q` for fire-and-forget** — no PTY needed
- **Use tmux for interactive sessions** — raw PTY mode has `\r` vs `\n` issues with prompt_toolkit
- **For scheduled tasks**, use the `cronjob` tool instead of spawning — handles delivery and retry

---

## Troubleshooting

### Voice not working
1. Check `stt.enabled: true` in config.yaml
2. Verify provider: `pip install faster-whisper` or set API key
3. Restart gateway: `/restart`

### Tool not available
1. `hermes tools` — check if toolset is enabled for your platform
2. Some tools need env vars (check `.env`)
3. `/reset` after enabling tools

### Model/provider issues
1. `hermes doctor` — check config and dependencies
2. `hermes login` — re-authenticate OAuth providers
3. Check `.env` has the right API key

### Anthropic base_url / local proxy not being honored
Use this when `config.yaml` points Anthropic at a local proxy (for example `providers.anthropic.base_url: http://127.0.0.1:18801`) but live Hermes traffic still appears to hit `https://api.anthropic.com`.

1. Check the effective runtime provider resolution, not just `config.yaml`:
```bash
source venv/bin/activate
python - <<'PY'
from hermes_cli.runtime_provider import resolve_runtime_provider
print(resolve_runtime_provider(requested='anthropic'))
PY
```
Expected: the printed `base_url` should be your local proxy URL.

2. If runtime resolution still shows `https://api.anthropic.com`, inspect `hermes_cli/runtime_provider.py` first. The key path is `_get_model_config()` → `resolve_runtime_provider()`.

3. Important pitfall: Hermes may read `model.base_url` but ignore `providers.anthropic.base_url` unless `_get_model_config()` merges provider-section settings into the effective model config. The fix is:
- read `config["providers"][active_provider]`
- when `model.base_url` / `model.api_key` are unset, fill them from the provider section
- keep `model.*` values higher priority than `providers.*`

4. Add a focused regression test in `tests/hermes_cli/test_runtime_provider_resolution.py` that proves `resolve_runtime_provider(requested="anthropic")` returns the provider-section proxy URL when only `providers.anthropic.base_url` is configured.

5. Re-test live after the fix:
```bash
hermes chat -q "Reply with exactly: HERMES_PROXY_OK" --quiet
```
Then verify whether your proxy receives requests. If the proxy now shows incoming `POST /v1/messages` traffic, the Hermes-side routing bug is fixed and any remaining failure is proxy-side, not Hermes-side.

### Changes not taking effect
- **Tools/skills:** `/reset` starts a new session with updated toolset
- **Config changes:** `/restart` reloads gateway config
- **Code changes:** Restart the CLI or gateway process

### Skills not showing
1. `hermes skills list` — verify installed
2. `hermes skills config` — check platform enablement
3. Load explicitly: `/skill name` or `hermes -s name`

### Gateway issues
Check logs first:
```bash
grep -i "failed to send\|error" ~/.hermes/logs/gateway.log | tail -20
```

### Messaging platform triage (local Hermes)
When a user says to inspect their "own Hermes" messaging setup, verify the local Hermes instance first before checking any remote box.

Use this sequence:
```bash
hermes status --all
hermes gateway status
hermes doctor
```
Then inspect:
- `~/.hermes/config.yaml` for platform config blocks
- `~/.hermes/.env` for platform env vars (`SIGNAL_*`, `WHATSAPP_*`, etc.)
- `~/.hermes/logs/gateway.log`
- `~/.hermes/logs/gateway.err.log`

Key pitfalls learned:
- `platform_toolsets.whatsapp: [hermes-whatsapp]` plus `whatsapp: {}` does **not** mean WhatsApp is configured. Treat `hermes status --all` as authoritative; if it says `WhatsApp ✗ not configured`, there is no active local WhatsApp integration to debug.
- Repeated `Gateway already running` messages in `gateway.log` usually mean duplicate startup attempts, not a WhatsApp bug.
- `Another local Hermes gateway is already using this Signal account` means a second local gateway tried to bind the same Signal account; fix the duplicate process before debugging message handling.
- If `gateway.err.log` shows agent crashes, inspect those separately from platform transport issues. In this session the real local failures were model/config/runtime errors, not WhatsApp transport.

Useful commands:
```bash
hermes status --all
hermes gateway status
search_files "SIGNAL_|WHATSAPP_" ~/.hermes/.env
search_files "whatsapp" ~/.hermes/logs/gateway.log
```

---

## Where to Find Things

| Looking for... | Location |
|----------------|----------|
| Config options | `hermes config edit` or [Configuration docs](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) |
| Available tools | `hermes tools list` or [Tools reference](https://hermes-agent.nousresearch.com/docs/reference/tools-reference) |
| Slash commands | `/help` in session or [Slash commands reference](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) |
| Skills catalog | `hermes skills browse` or [Skills catalog](https://hermes-agent.nousresearch.com/docs/reference/skills-catalog) |
| Provider setup | `hermes model` or [Providers guide](https://hermes-agent.nousresearch.com/docs/integrations/providers) |
| Platform setup | `hermes gateway setup` or [Messaging docs](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/) |
| MCP servers | `hermes mcp list` or [MCP guide](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp) |
| Profiles | `hermes profile list` or [Profiles docs](https://hermes-agent.nousresearch.com/docs/user-guide/profiles) |
| Cron jobs | `hermes cron list` or [Cron docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron) |
| Memory | `hermes memory status` or [Memory docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) |
| Env variables | `hermes config env-path` or [Env vars reference](https://hermes-agent.nousresearch.com/docs/reference/environment-variables) |
| CLI commands | `hermes --help` or [CLI reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) |
| Gateway logs | `~/.hermes/logs/gateway.log` |
| Session files | `~/.hermes/sessions/` or `hermes sessions browse` |
| Source code | `~/.hermes/hermes-agent/` |

---

## Contributor Quick Reference

For occasional contributors and PR authors. Full developer docs: https://hermes-agent.nousresearch.com/docs/developer-guide/

### Project Layout

```
hermes-agent/
├── run_agent.py          # AIAgent — core conversation loop
├── model_tools.py        # Tool discovery and dispatch
├── toolsets.py           # Toolset definitions
├── cli.py                # Interactive CLI (HermesCLI)
├── hermes_state.py       # SQLite session store
├── agent/                # Prompt builder, compression, display, adapters
├── hermes_cli/           # CLI subcommands, config, setup, commands
│   ├── commands.py       # Slash command registry (CommandDef)
│   ├── config.py         # DEFAULT_CONFIG, env var definitions
│   └── main.py           # CLI entry point and argparse
├── tools/                # One file per tool
│   └── registry.py       # Central tool registry
├── gateway/              # Messaging gateway
│   └── platforms/        # Platform adapters (telegram, discord, etc.)
├── cron/                 # Job scheduler
├── tests/                # ~3000 pytest tests
└── website/              # Docusaurus docs site
```

Config: `~/.hermes/config.yaml` (settings), `~/.hermes/.env` (API keys).

### Adding a Tool (3 files)

**1. Create `tools/your_tool.py`:**
```python
import json, os
from tools.registry import registry

def check_requirements() -> bool:
    return bool(os.getenv("EXAMPLE_API_KEY"))

def example_tool(param: str, task_id: str = None) -> str:
    return json.dumps({"success": True, "data": "..."})

registry.register(
    name="example_tool",
    toolset="example",
    schema={"name": "example_tool", "description": "...", "parameters": {...}},
    handler=lambda args, **kw: example_tool(
        param=args.get("param", ""), task_id=kw.get("task_id")),
    check_fn=check_requirements,
    requires_env=["EXAMPLE_API_KEY"],
)
```

**2. Add import** in `model_tools.py` → `_discover_tools()` list.

**3. Add to `toolsets.py`** → `_HERMES_CORE_TOOLS` list.

All handlers must return JSON strings. Use `get_hermes_home()` for paths, never hardcode `~/.hermes`.

### Adding a Slash Command

1. Add `CommandDef` to `COMMAND_REGISTRY` in `hermes_cli/commands.py`
2. Add handler in `cli.py` → `process_command()`
3. (Optional) Add gateway handler in `gateway/run.py`

All consumers (help text, autocomplete, Telegram menu, Slack mapping) derive from the central registry automatically.

### Agent Loop (High Level)

```
run_conversation():
  1. Build system prompt
  2. Loop while iterations < max:
     a. Call LLM (OpenAI-format messages + tool schemas)
     b. If tool_calls → dispatch each via handle_function_call() → append results → continue
     c. If text response → return
  3. Context compression triggers automatically near token limit
```

### Testing

```bash
source venv/bin/activate  # or .venv/bin/activate
python -m pytest tests/ -o 'addopts=' -q   # Full suite
python -m pytest tests/tools/ -q            # Specific area
```

- Tests auto-redirect `HERMES_HOME` to temp dirs — never touch real `~/.hermes/`
- Run full suite before pushing any change
- Use `-o 'addopts='` to clear any baked-in pytest flags

### Commit Conventions

```
type: concise subject line

Optional body.
```

Types: `fix:`, `feat:`, `refactor:`, `docs:`, `chore:`

### Key Rules

- **Never break prompt caching** — don't change context, tools, or system prompt mid-conversation
- **Message role alternation** — never two assistant or two user messages in a row
- Use `get_hermes_home()` from `hermes_constants` for all paths (profile-safe)
- Config values go in `config.yaml`, secrets go in `.env`
- New tools need a `check_fn` so they only appear when requirements are met
