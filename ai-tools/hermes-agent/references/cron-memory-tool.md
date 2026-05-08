# Cron memory tool availability

## Symptom
A cron job has `enabled_toolsets` including `memory`, but a run reports:

```text
Memory is not available. It may be disabled in config or this environment.
```

or a memory-gc report says the cron environment has no `memory` tool.

## Diagnosis pattern
Do not stop at the cron job config. There are two separate questions:

1. Was the `memory` tool schema exposed to the model?
2. Was `AIAgent._memory_store` constructed so the tool can execute?

Useful checks:

```bash
python - <<'PY'
import json, pathlib
p = pathlib.Path('~/.hermes/cron/jobs.json').expanduser()
data = json.loads(p.read_text())
for job in data.get('jobs', data if isinstance(data, list) else []):
    if job.get('name') == 'memory-gc':
        print(json.dumps(job.get('enabled_toolsets'), indent=2))
PY

grep -n "tool_name='memory'" ~/.hermes/logs/agent.log | tail
```

If logs show `tool_name='memory'`, the tool was loaded and invoked. The remaining failure is the backing store.

## Root cause seen in May 2026
Cron constructed `AIAgent(..., skip_memory=True, enabled_toolsets=[..., "memory", ...])` in `cron/scheduler.py`. `skip_memory=True` was intended to keep MEMORY.md and USER.md out of cron prompts so cron output would not corrupt user representation. But `AIAgent.__init__` also used `skip_memory` to avoid constructing `self._memory_store`. The memory tool is an agent-level tool, so `_invoke_tool('memory', ...)` passed `store=None` and the handler returned the unavailable-memory error.

## Correct fix shape
Keep `skip_memory=True` for cron prompt hygiene, but allow an explicitly enabled memory tool to construct a backing `MemoryStore`.

In `run_agent.py`, after tool definitions and `valid_tool_names` are built:

```python
_memory_tool_enabled = "memory" in self.valid_tool_names
if not skip_memory or _memory_tool_enabled:
    mem_config = _agent_cfg.get("memory", {})
    # Only set prompt injection flags when not skip_memory.
    if not skip_memory:
        self._memory_enabled = mem_config.get("memory_enabled", False)
        self._user_profile_enabled = mem_config.get("user_profile_enabled", False)
    # Still construct MemoryStore when the memory tool is explicitly available.
```

Regression expectations:
- `skip_memory=True` plus `enabled_toolsets=["memory"]` constructs `_memory_store`.
- `_memory_enabled` and `_user_profile_enabled` remain false, so memory is not injected into the system prompt.
- The memory tool no longer returns `Memory is not available`.

Focused test idea:

```bash
python -m pytest tests/run_agent/test_run_agent.py::test_skip_memory_still_loads_store_when_memory_tool_enabled -q
```
