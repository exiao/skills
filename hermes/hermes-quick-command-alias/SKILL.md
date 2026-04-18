---
name: hermes-quick-command-alias
description: How to set up slash command aliases in Hermes via quick_commands config
tags: [hermes, config, alias, commands]
---

# Hermes Quick Command Aliases

## How it works
In `~/.hermes/config.yaml`, under `quick_commands`, you can define aliases:

```yaml
quick_commands:
  m:
    type: alias
    target: model
```

## Dispatch order (gateway)
1. `event.get_command()` extracts command name (e.g., "m")
2. `_resolve_cmd()` does **exact lookup** in `_COMMAND_LOOKUP` — no prefix matching
3. If no match, falls through to `quick_commands` check
4. If alias found, rewrites `event.text` to `/model <args>` and re-dispatches

## Key facts
- Gateway uses **exact matching only** — prefix matching is CLI-only (prompt_toolkit autocomplete)
- `quick_commands` supports both `type: alias` and `type: exec` (docs only mention exec, but code supports both)
- After editing config, gateway restart/reload is needed

## Current user config
- `/m` → `/model` (added to config)
- Allows: `/m opus`, `/m sonnet`, `/m gpt5`