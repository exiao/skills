---
name: hermes-context-files
description: How Hermes discovers and loads context files (SOUL.md, AGENTS.md, HERMES.md, CLAUDE.md). Use when asked how Hermes loads context, which files are auto-loaded vs on-demand, how SOUL.md/AGENTS.md discovery works, symlink patterns for context files, or how to configure cwd-based context file loading. Trigger phrases include "context files", "how does Hermes load", "SOUL.md", "AGENTS.md", "CLAUDE.md", "auto-loaded", "context file discovery".
---

# Hermes Context File Discovery

## Auto-loaded files
- **SOUL.md**: Always loaded from `~/.hermes/SOUL.md`. Identity, tone, style. Follows you everywhere.
- **AGENTS.md**: Loaded from cwd. Gateway cwd = `~/`. Walks parent directories when agent touches files. Project architecture, coding conventions, tool preferences.
- Discovery order in cwd: HERMES.md → AGENTS.md → CLAUDE.md → .cursorrules (first match wins).

## NOT auto-loaded
TOOLS.md, PLAYBOOK.md, DEBUGGING.md, IDENTITY.md, WRITING-STYLE.md — Hermes ignores these unless the agent manually reads them.

## Pattern for non-auto-loaded files
Reference them in AGENTS.md with pointers: "Read ~/.hermes/WRITING-STYLE.md for content tasks". This way the agent knows to read them contextually.

## Symlink pattern for AGENTS.md
Real file at `~/.hermes/AGENTS.md` (gets backed up with hermes-backup repo). Symlink at `~/AGENTS.md` (where gateway discovers it). Python Path follows symlinks by default.

## Tool Progress / Verbose
- Modes cycle via `/verbose`: off → new → all → verbose
- `new`: only when tool changes. `all`: every call, short preview. `verbose`: every call, full args.
- `tool_preview_length`: chars of tool args shown (0 = unlimited)
- Signal is Tier 3 (no message editing) — each progress update is a permanent message.