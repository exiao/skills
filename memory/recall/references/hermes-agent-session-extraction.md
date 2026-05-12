# Extracting Outputs from Hermes Agent Session Files

When a Hermes Agent pipeline (like CPE Research) runs but workspace files are empty or missing, the actual outputs still exist inside session JSON files. The agent's `write_file` tool calls contain the full file content in their arguments.

## When This Happens

- Pipeline logs show all phases completed (e.g., `[GATHER] Complete`, `[SYNTHESIZE] Complete`)
- But the workspace directories are empty (files written to wrong path, cleaned up, or path mismatch)
- Common with first runs, Docker/Render deployments, or path configuration issues

## Where to Look

Project-local Hermes sessions live at:
```
<project>/hermes_home/sessions/session_*.json
```

NOT `~/.hermes/sessions/` -- those are the main agent's sessions. Each project with its own `HERMES_HOME` has its own session directory.

## Extraction Pattern

```python
import json, os

sessions_dir = '<project>/hermes_home/sessions'
for fname in sorted(os.listdir(sessions_dir)):
    with open(os.path.join(sessions_dir, fname)) as f:
        data = json.load(f)
    for m in data.get('messages', []):
        if m.get('role') == 'assistant':
            for tc in m.get('tool_calls', []):
                args = tc.get('function', {}).get('arguments', '')
                if '<target_filename>' in args:
                    parsed = json.loads(args)
                    content = parsed.get('content', '')
                    if len(content) > 500:  # filter out small/empty writes
                        print(f"Found in {fname}: {len(content)} chars")
                        with open('<output_path>', 'w') as out:
                            out.write(content)
```

## Key Details

- Session files are `.json` (not `.jsonl`) in project-local hermes_home
- Tool calls are nested: `message.tool_calls[].function.arguments` (JSON string that needs double-parse)
- Filter by target filename in arguments (e.g., `'memo.md'`, `'quality_report'`)
- Multiple sessions may contain writes to the same file (retries); take the latest or largest
- Tool results (role=tool) contain the write confirmation with `bytes_written`

## CPE Research Agent Specifics

The AVGO pipeline produces outputs across multiple sessions:
- Phase 1 (GATHER): session with `research info`, `research financials` commands
- Phase 2 (ANALYZE): subagent sessions with lens analysis writes
- Phase 3 (SYNTHESIZE): session containing `memo.md` write
- Phase 4 (EVAL): session containing `eval/quality_report.md` write

To find the eval session specifically, search for sessions where the user prompt mentions "Load skill evaluator" and the assistant writes to `quality_report`.
