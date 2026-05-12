# Hermes Agent Session JSON Format

Session files are stored in `{HERMES_HOME}/sessions/` as `session_{YYYYMMDD}_{HHMMSS}_{hex6}.json`.

## Top-Level Schema

```json
{
  "session_id": "20260511_194549_f0b620",
  "model": "claude-opus-4-6",
  "base_url": null,
  "platform": null,
  "session_start": "2026-05-11T19:45:49.123456",
  "last_updated": "2026-05-11T20:10:32.654321",
  "message_count": 82,
  "system_prompt": "...",
  "tools": [ /* tool schemas */ ],
  "messages": [ /* see below */ ]
}
```

## Message Format

Messages follow OpenAI format with extensions:

```json
{"role": "user", "content": "Run 5 independent analyses..."}

{"role": "assistant", "content": "", "tool_calls": [
  {
    "id": "toolu_01NrZ5XYPi...",
    "call_id": "toolu_01NrZ5XYPi...",
    "response_item_id": "fc_toolu_01NrZ5XYPi...",
    "type": "function",
    "function": {
      "name": "delegate_task",
      "arguments": "{\"goal\": \"...\", \"context\": \"...\"}"
    }
  }
]}

{"role": "tool", "content": "{\"output\": \"...\", \"exit_code\": 0}"}

{"role": "assistant", "content": "Here are the results..."}
```

## Key Properties

- **No parent-child linking.** Delegated sub-agent sessions get their own session files but there's no `parent_session_id` field. Infer relationships from timestamp proximity and first-message content patterns.
- **Phase detection from first user message:**
  - Contains "data gatherer" -> GATHER phase
  - Contains "research coordinator" -> ANALYZE (coordinator)
  - Contains "Load skill synthesizer" -> SYNTHESIZE
  - Contains "Load skill evaluator" -> EVAL
  - Other delegated tasks -> LEAF sub-agent
- **tool_calls[].function.arguments** is a JSON string (double-encoded). Parse with `json.loads()`.
- **Large sessions** can be 300-400KB (60-110 messages with full tool outputs).

## Programmatic AIAgent Usage

When running AIAgent from Python (not CLI), use `quiet_mode=True` to suppress Rich spinners, tool result banners, and status output. Essential for server/pipeline contexts.

**Critical: pass `session_db` for SQLite session persistence.** Without it, sessions only write to JSON files, not the SQLite store that powers `hermes dashboard`, FTS5 search, and the session API. The `session_db` parameter is optional and only auto-populated by CLI/gateway. Direct AIAgent callers must provide it explicitly:

```python
from run_agent import AIAgent
from hermes_state import SessionDB

db = SessionDB()  # uses HERMES_HOME/state.db
agent = AIAgent(
    model="claude-opus-4-6",
    provider="anthropic",
    quiet_mode=True,   # no stdout noise
    session_db=db,     # enables SQLite session persistence
)
```

Without `session_db`, the agent still writes JSON files to `{HERMES_HOME}/sessions/` via `_save_session_log()`, but `SessionDB.session_count()` returns 0 and `hermes dashboard` shows no sessions. This is the #1 gotcha when embedding AIAgent in a custom pipeline.

## Backfilling JSON Sessions into SQLite

If you have existing JSON session files and need them in SessionDB (e.g., from runs before `session_db` was passed), import them:

```python
import json
from hermes_state import SessionDB

db = SessionDB()
for f in Path(SESSIONS_DIR).glob("session_*.json"):
    data = json.loads(f.read_text())
    sid = data.get("session_id", f.stem)
    if db.get_session(sid):
        continue  # already imported
    db.create_session(
        session_id=sid,
        source="pipeline",
        model=data.get("model", "unknown"),
        system_prompt=data.get("system_prompt", ""),
    )
    for msg in data.get("messages", []):
        db.append_message(
            session_id=sid,
            role=msg.get("role", "user"),
            content=msg.get("content", ""),
            tool_calls=msg.get("tool_calls"),
            tool_name=msg.get("tool_name"),
            tool_call_id=msg.get("tool_call_id"),
        )
db.close()
```

## Grouping Sessions into Runs

For multi-phase pipelines (like CPE research), group sessions by timestamp proximity (within ~3 hours) since there's no explicit run ID linking them. Sort by `session_start` within each group.
