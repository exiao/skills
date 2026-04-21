---
name: serena
description: Use when navigating or editing a complex codebase at the symbol level — symbol lookup, references, precise edits via Serena MCP. Prefer over grepping files for accurate code navigation.
---

# Serena

Serena gives coding agents IDE-like tools: find symbols, follow references, insert/replace at the symbol level. More token-efficient than reading whole files or regex-searching. Strongest on large, structured codebases.

## When to Use

- Complex codebase navigation (find where a function is defined/used across the project)
- Precise code edits at the symbol level (replace a method body, insert after a class definition)
- Refactoring across multiple files
- When grep-based search is too noisy and reading full files wastes context

**Skip Serena when:** writing code from scratch in a new empty repo, or working with very small single-file tasks.

## Setup (already done on this machine)

Serena is installed as a `uv` tool and registered as a Claude Code MCP server at user scope. Available subagents spawned via `delegate_task` (which run `claude-agent-acp`) inherit the MCP registration.

```
# already executed once:
uv tool install -p 3.13 serena-agent@latest --prerelease=allow
serena init
serena setup claude-code   # registers `serena start-mcp-server --context=claude-code --project-from-cwd`
```

To verify: `claude mcp list` should show `serena ... ✓ Connected`.

## Per-Project Setup

Each repo needs a `.serena/project.yml` so Serena knows which language servers to load. Already configured:

- `~/bloom` — python + typescript
- `~/fintary/ops-center` — python

For a new repo, run from inside it:

```bash
serena project create --language python --language typescript
```

Use multiple `--language` flags as needed. Skipping the flag triggers an interactive prompt for every detected language, which usually aborts.

Optional pre-index (Bloom takes 5+ minutes; skip unless you want zero latency on the first symbolic call):

```bash
serena project index
```

The MCP server will index incrementally on first use otherwise.

## Calling Serena

Inside a Claude Code session run from the repo root, Serena tools are auto-discovered. You'll see them in the tool list as `mcp__serena__*` (Anthropic naming) or under the `serena` server. Common ones:

- `find_symbol` — look up a function/class/method by name
- `get_symbols_overview` — file outline (top-level defs)
- `find_referencing_symbols` — all callers of a symbol
- `replace_symbol_body` — atomic edit to a method/function
- `insert_after_symbol` / `insert_before_symbol` — insert near a definition
- `rename_symbol` — LSP-backed rename (single language)
- `search_for_pattern` — regex search (used when symbolic search isn't enough)

Project context is auto-detected from cwd because of `--project-from-cwd`. If running outside a Serena project, Serena will refuse — `cd` into the right repo first.

## Outside Claude Code

Serena is also registered with the Hermes parent agent via native MCP — see `mcp_servers.serena` in `~/.hermes/config.yaml`. The gateway spawns Serena once at startup and tools are exposed as `mcp_serena_*` (29 tools total: find_symbol, replace_symbol_body, find_referencing_symbols, activate_project, etc.).

Because Hermes runs from `~/` (not from a project root), `--project-from-cwd` doesn't work. Instead, call `mcp_serena_activate_project` first whenever you need Serena to operate on a specific repo:

```
mcp_serena_activate_project project="bloom"            # uses registered project name
mcp_serena_activate_project project="/Users/testuser/fintary/ops-center"  # absolute path also works
```

Then use the symbol tools normally. The active project persists for the session.

For quick one-shot use without going through Hermes or Claude Code, `mcporter` still works but respawns the LSP per call:

```bash
mcporter call --stdio "serena start-mcp-server --project ~/bloom" find_symbol name=PortfolioSerializer
```

## Backends

- Default: SolidLSP (open language servers). Free. Supports 40+ languages.
- Optional: JetBrains plugin backend (`-b JetBrains` at install). Better refactoring tools but requires a paid IDE.

Bloom and ops-center are on the default LSP backend.

## Troubleshooting

- **First call hangs for 30–60s** — LSP cold start. Subsequent calls are fast.
- **`find_symbol` returns empty** — language server didn't index. Check `~/bloom/.serena/` logs or run `serena project health-check` from the repo.
- **Wrong project picked up** — verify cwd. `--project-from-cwd` looks for `.serena/project.yml` or `.git` in parents.
