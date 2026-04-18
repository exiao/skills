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

## Prerequisites

Requires `uv` (Python package manager):
```
which uv || brew install uv
```

## How to Call

Serena runs as a local stdio MCP server. Call via mcporter with `--stdio`:

```
mcporter call --stdio "uvx --from git+https://github.com/oraios/serena serena start-mcp-server --project-path <PATH>" <tool> [args]
```

Replace `<PATH>` with the repo root (e.g., `~/bloom`).

### Key Tools

**Find a symbol definition:**
```
mcporter call --stdio "uvx --from git+https://github.com/oraios/serena serena start-mcp-server --project-path ~/bloom" serena.find_symbol name=UserSerializer
```

**Find all references to a symbol:**
```
mcporter call --stdio "uvx --from git+https://github.com/oraios/serena serena start-mcp-server --project-path ~/bloom" serena.find_referencing_symbols name=get_portfolio
```

**Insert code after a symbol:**
```
mcporter call --stdio "uvx --from git+https://github.com/oraios/serena serena start-mcp-server --project-path ~/bloom" serena.insert_after_symbol name=MyClass code="    def new_method(self): ..."
```

**Replace a symbol body:**
```
mcporter call --stdio "uvx --from git+https://github.com/oraios/serena serena start-mcp-server --project-path ~/bloom" serena.replace_symbol_body name=calculate_returns new_body="..."
```

## Supported Languages

Python, TypeScript, JavaScript, Swift, Kotlin, Go, Rust, Java, C#, C/C++, Ruby, PHP, and 20+ more via LSP.

**Note:** Some languages need their LSP installed separately. Python and TypeScript work out of the box. Swift requires `sourcekit-lsp` (bundled with Xcode).

## First-Run Notes

- First invocation downloads Serena and language servers — takes 30-60s
- Subsequent calls are fast (uvx caches)
- For large repos, the initial indexing pass may take a few seconds

## Tips

- Always set `--project-path` to the repo root, not a subdirectory
- Serena uses the LSP for semantic understanding — make sure the project's dependencies are installed (e.g., run `pip install -e .` for Python, `npm install` for JS/TS) so the LSP can resolve imports
- For Bloom iOS work, Xcode must be installed for Swift LSP to function
