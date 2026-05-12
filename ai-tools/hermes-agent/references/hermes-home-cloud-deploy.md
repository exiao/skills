# Deploying Hermes as a Library with HERMES_HOME in Repo

## Pattern

Use Hermes as a `pip install` dependency with `HERMES_HOME` pointing to a directory bundled in the repo. Everything is self-contained, version-controlled, and deployable to any cloud service.

```
my-agent/
├── server.py                # FastAPI/Flask wrapper
├── orchestrator.py          # Business logic using AIAgent
├── Dockerfile
├── requirements.txt         # includes hermes-agent
│
├── hermes_home/             # ← HERMES_HOME points here
│   ├── config.yaml          # model, agent, compression, delegation
│   ├── SOUL.md              # agent persona
│   ├── .env                 # API keys (gitignored!)
│   ├── skills/              # domain-specific skills
│   ├── plugins/             # custom tool plugins
│   ├── memories/.gitkeep    # persistent (symlink to cloud disk)
│   ├── sessions/.gitkeep    # persistent (symlink to cloud disk)
│   └── logs/.gitkeep
```

## Key Mechanism

Hermes resolves all paths via `get_hermes_home()` from `hermes_constants.py`. Set `HERMES_HOME` env var before importing any Hermes module:

```python
import os
from pathlib import Path
os.environ["HERMES_HOME"] = str(Path(__file__).parent / "hermes_home")

# NOW import Hermes
from run_agent import AIAgent
```

## Persistence on Render (or similar)

Use a persistent disk mounted at `/data`. Symlink mutable directories at container startup:

```bash
#!/bin/bash
# setup_persistence.sh — run before app starts
HERMES_HOME="${HERMES_HOME:-/app/hermes_home}"
DATA_DIR="/data"

mkdir -p "$DATA_DIR/memories" "$DATA_DIR/sessions" "$DATA_DIR/workspace"

rmdir "$HERMES_HOME/memories" 2>/dev/null || true
rmdir "$HERMES_HOME/sessions" 2>/dev/null || true

ln -sfn "$DATA_DIR/memories" "$HERMES_HOME/memories"
ln -sfn "$DATA_DIR/sessions" "$HERMES_HOME/sessions"

[ ! -f "$DATA_DIR/memories/MEMORY.md" ] && touch "$DATA_DIR/memories/MEMORY.md"
```

## Dockerfile Pattern

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV HERMES_HOME=/app/hermes_home
RUN chmod +x scripts/setup_persistence.sh
CMD ["sh", "-c", "./scripts/setup_persistence.sh && uvicorn server:app --host 0.0.0.0 --port 8000"]
```

## vs. Profiles

Profiles (`hermes profile create NAME`) work great for local multi-instance use but are tied to `~/.hermes/profiles/`. The HERMES_HOME pattern is better when:
- Deploying to cloud (Render, Railway, ECS, etc.)
- Version-controlling the entire agent config
- Running in containers where `~/.hermes` doesn't exist
- Shipping the agent as a self-contained application

## Resolved Questions (2026-05-11, end-to-end AVGO test)

1. **`get_hermes_home()` respects env var** — confirmed. Setting `os.environ["HERMES_HOME"]` before import correctly routes skills, sessions, logs, config, and memory.
2. **Import path:** `from run_agent import AIAgent` works when `PYTHONPATH` includes the hermes-agent checkout (e.g., `~/.hermes/hermes-agent`). Not yet pip-installable as a package.
3. **delegate_task inherits HERMES_HOME config** — confirmed. Subagents spawned via delegate_task use the same HERMES_HOME, load skills from `hermes_home/skills/`, and write sessions to `hermes_home/sessions/`.

## Pitfalls (proven in end-to-end testing)

### AIAgent.__init__ parameter name
The parameter is `ephemeral_system_prompt`, NOT `system_message`. Using `system_message` raises TypeError. However, `run_conversation(system_message=...)` IS valid (overrides ephemeral_system_prompt for that call).

```python
# WRONG — raises TypeError
agent = AIAgent(model="claude-opus-4-6", system_message="You are a researcher")

# CORRECT
agent = AIAgent(model="claude-opus-4-6", ephemeral_system_prompt="You are a researcher")

# ALSO CORRECT — per-call override
agent.run_conversation(user_message="...", system_message="You are a researcher")
```

### Terminal CWD defaults to home directory
The agent's terminal backend defaults to `~` (home), NOT the directory where the Python script runs. All file paths in prompts MUST be absolute, or the agent will create files in `~/workspace/...` instead of `./workspace/...`.

```python
# WRONG — agent creates ~/workspace/AVGO/raw/info.json
f"research info {ticker} -o workspace/{ticker}/raw/info.json"

# CORRECT — absolute paths
workspace = Path(f"workspace/{ticker}").resolve()
f"research info {ticker} -o {workspace}/raw/info.json"
```

### delegate_task subagents need explicit tool instructions
Subagents given vague goals like "Load skill X and write analysis" complete in 2-4 seconds without producing output. They load the skill, "plan" the work, and return a summary. You must explicitly instruct them to use specific tools:

```python
# WRONG — completes instantly, writes nothing
delegate_task(goal="Load skill lens-business. Read raw data. Write analysis to /path/output.md")

# CORRECT — explicit tool usage, absolute paths, verification
delegate_task(
    goal="Write the business quality analysis for AVGO",
    context=f"""
    1. Use read_file to load each JSON file in {abs_raw_dir}/
    2. Analyze the data following these criteria: [...]
    3. Use write_file to save the analysis to {abs_output_path}
    4. Use terminal to verify: ls -la {abs_output_path}
    """,
    toolsets=["terminal", "file", "skills"]
)
```

### hermes_home/.env must exist separately
The agent loads API keys from `HERMES_HOME/.env` (via `load_hermes_dotenv()`). If your `hermes_home/` is inside a project repo, you need a separate `.env` there. It does NOT automatically read `~/.hermes/.env`. Add `hermes_home/.env` to `.gitignore`.

### Python venv mismatch
If using `source venv/bin/activate` in a shell script, subprocesses may still use system Python. The hermes-agent venv at `~/.hermes/hermes-agent/venv/` has all dependencies (anthropic, etc.). Set `PYTHONPATH` explicitly rather than relying on venv activation:

```bash
export PYTHONPATH=~/.hermes/hermes-agent
export HERMES_HOME="$(pwd)/hermes_home"
python3 run_research.py
```

### Tool name auto-repair overhead
The model consistently calls tools as `mcp_terminal`, `mcp_read_file`, etc. The runtime auto-repairs these (`mcp_X -> X`) but it wastes tokens on every call. In your SOUL.md, explicitly list available tool names without the `mcp_` prefix.
