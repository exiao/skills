# Hermes as Embedded Library (Cloud Deployment)

Use Hermes as a pip dependency with `HERMES_HOME` pointing to a directory bundled in the repo. No local profile, no fork. Everything is version-controlled and deployable to Render/Railway/etc.

## Pattern

```
my-app/
├── hermes_home/           # HERMES_HOME — bundled in repo
│   ├── .env               # API keys (gitignored, see setup below)
│   ├── config.yaml        # Model, toolsets, delegation, compression
│   ├── SOUL.md            # Custom identity (replaces default Hermes prompt)
│   ├── skills/            # App-specific skills
│   ├── memories/.gitkeep  # Symlink to persistent disk in cloud
│   ├── sessions/.gitkeep
│   └── logs/.gitkeep
├── my_orchestrator.py     # Imports AIAgent, sets HERMES_HOME
├── run.sh                 # Helper script (venv, PYTHONPATH, .env setup)
├── scripts/setup_env.sh   # Copies keys from ~/.hermes/.env to hermes_home/.env
├── requirements.txt       # hermes-agent + app deps
└── Dockerfile / render.yaml
```

## Key Code

```python
import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.resolve()
os.environ["HERMES_HOME"] = str(PROJECT_ROOT / "hermes_home")

from run_agent import AIAgent

agent = AIAgent(model="claude-opus-4-6", provider="anthropic", quiet_mode=True)
# system_message goes in run_conversation(), NOT __init__()
result = agent.run_conversation(user_message="...", system_message="optional")
```

## AIAgent Constructor (common args)

model, provider, quiet_mode, max_iterations, enabled_toolsets, disabled_toolsets, skip_context_files, skip_memory, platform, ephemeral_system_prompt.

**Gotcha:** `system_message` is NOT a constructor param. Use `ephemeral_system_prompt` in __init__ or pass `system_message` to `run_conversation()`.

## Critical Pitfalls (from E2E testing)

### 1. Absolute paths everywhere
The agent's terminal CWD defaults to `~` (home directory), NOT the project directory. Any relative path in prompts like `workspace/TICKER_DATE/raw/` will resolve to `~/workspace/...` instead of your project dir. Always use absolute paths:

```python
WORKSPACE = PROJECT_ROOT / "workspace" / f"{TICKER}_{DATE}"
ws = str(WORKSPACE)  # Use in all prompts
```

### 2. hermes_home/.env is required
The agent loads API keys from `HERMES_HOME/.env`, not from the system environment or `~/.hermes/.env`. Create a setup script that copies needed keys. Use `grep` not `set -a` (avoids env pollution under `set -euo pipefail`):

```bash
# scripts/setup_env.sh — use || true on grep to survive pipefail
val=$(grep "^${key}=" "$SOURCE" 2>/dev/null | head -1 | cut -d= -f2- || true)
```

### 3. PYTHONPATH for hermes-agent
Unless hermes-agent is pip-installed, you need `PYTHONPATH=~/.hermes/hermes-agent` for `from run_agent import AIAgent` to resolve. The run.sh helper should handle this.

### 4. Use the hermes venv
The hermes-agent venv (`~/.hermes/hermes-agent/venv/`) has `anthropic`, `httpx`, etc. installed. Your script must activate it or the import chain fails with `ImportError: 'anthropic' package required`.

### 5. delegate_task subagents need explicit tool instructions
Subagents from `delegate_task` don't inherit context about what tools exist. Prompts must:
- Name tools explicitly: "Use `write_file` to save", "Use `read_file` to read", "Use `skill_view` to load"
- Specify toolsets: `["terminal", "file", "web", "skills", "code_execution"]`
- Include verification: "Do NOT skip writing the file"
- Avoid arbitrary word count minimums (causes padding). Instead, reference the skill's output format.

Without explicit tool names, subagents complete in 2-4 seconds having done nothing.

### 6. Tool name prefix mismatch
The model sometimes calls tools with `mcp_` prefix (`mcp_terminal`, `mcp_write_file`). The auto-repair catches this but it wastes tokens. SOUL.md should state correct tool names.

### 7. Security scan blocks
The terminal security scanner blocks patterns like piping to interpreters (`cat file.json | python3 -c "..."`). Agent will retry with a different approach. Not a bug, just adds latency.

### 8. Eval retry loop requires matching paths
If the orchestrator checks `workspace / "eval" / "quality_report.md"` but the agent wrote to a different resolved path (e.g. relative vs absolute), the retry loop silently falls through. The FAIL verdict is never detected, no re-synthesis happens. Always verify the path the orchestrator checks matches the path in the agent prompt.

### 9. Preflight CLI checks save tokens
Add `command -v research` (or whatever CLI) to run.sh. Without it, Phase 1 burns 17 API calls trying commands that all fail because the CLI isn't installed.

## SOUL.md

If `hermes_home/SOUL.md` exists, replaces built-in identity. Prompt builder still handles caching, compression, budget warnings, tool schemas, skill injection.

## No Plugin Needed for CLI Tools

Built-in terminal tool runs CLI commands directly. Skills instruct the agent what commands to use. Only create plugins for tools that need custom schemas or non-subprocess execution.

## Render Persistence

```bash
# setup_persistence.sh (run at container start)
ln -sfn /data/memories $HERMES_HOME/memories
ln -sfn /data/sessions $HERMES_HOME/sessions
```

## Private Repo Build Command

```
pip install git+https://${GITHUB_TOKEN}@github.com/org/repo.git && pip install git+https://github.com/NousResearch/hermes-agent.git
```

Set GITHUB_TOKEN as env var on Render for private repo access.

## What You Keep vs Lose

**Keep (no config needed):** Agent loop, tool dispatch, retries, context compression, prompt caching, subagent delegation, skills system, session persistence, memory.

**Keep (via SOUL.md):** Custom identity/persona replaces default.

**Lose (if you pass system_message directly):** Progressive skill discovery, prompt cache optimization, budget warnings, memory injection. Recommendation: keep the prompt builder on, customize via SOUL.md.

## Run Script Template

```bash
#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# Activate hermes-agent venv
source ~/.hermes/hermes-agent/venv/bin/activate
export PYTHONPATH="${HOME}/.hermes/hermes-agent:${PYTHONPATH:-}"

# Preflight
command -v research &>/dev/null || { echo "ERROR: research CLI not found" >&2; exit 1; }

# Ensure .env exists
[ -f hermes_home/.env ] || bash scripts/setup_env.sh

TICKER="${1:-AVGO}"
python3 run_research.py "$TICKER" 2>&1
```
