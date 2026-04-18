---
name: hermes-add-tool-pattern
description: Pattern for adding a new tool to the Hermes agent framework
tags: [hermes, tools, development]
---

# How to Add a New Tool to Hermes

## Pattern (4-step)

1. **Create tool file** in `tools/` directory (e.g. `tools/send_file_tool.py`)
   - Use `@tool_def` decorator with name, description, parameters
   - Return result string (e.g. `MEDIA:<path>` for gateway pickup)

2. **Register in `model_tools.py`** — add import line alongside other tool imports (around line 159)

3. **Register in `toolsets.py`**:
   - Add to `_HERMES_CORE_TOOLS` list (line ~37) for always-available tools
   - OR add to a specific toolset dict (line ~149) for conditional loading

4. **Test**: Import and verify with `ToolRegistry.get_tool("tool_name")`

## Key files
- `tools/` — individual tool definitions
- `model_tools.py` — import registry
- `toolsets.py` — toolset groupings and core tools list

## Extension patterns for gateway
- `extract_media()` at `base.py:1216` — regex for detecting file paths in messages
- `extract_local_files()` at `base.py:1250` — extension set for bare path auto-detection
- Both feed into routing at lines 1758/1788 which has `else → send_document()` for non-media files