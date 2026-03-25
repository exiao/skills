---
name: agent-browser
description: "Use when automating browsers via agent-browser CLI: headless browsing, web scraping with accessibility trees, CDP-based automation, filling forms, clicking buttons, navigating pages, or running isolated browser sessions for sub-agents. Prefer over Playwright browser tool when compact context and agent-first design matter."
---

---
name: agent-browser
description: "Use when automating browsers via agent-browser CLI: headless browsing, web scraping with accessibility trees, CDP-based automation, filling forms, clicking buttons, navigating pages, or running isolated browser sessions for sub-agents. Prefer over Playwright browser tool when compact context and agent-first design matter."
---

# agent-browser Skill

Browser automation via `agent-browser` CLI (v0.14.0). Native Rust, CDP-based, agent-first design. Uses compact accessibility tree snapshots to minimize context usage.

## When to Use

Use `agent-browser` for headless browser automation tasks where you need to:
- Navigate, click, fill forms, screenshot pages programmatically
- Keep token usage low (text snapshots ~200-400 tokens vs full DOM ~3000-5000)
- Run isolated browser sessions (e.g., separate auth contexts)

Prefer the built-in `browser` tool for interactive tasks in the main OpenClaw session. Use `agent-browser` for scripted, headless, or sub-agent browser work.

## Setup

Already installed via Homebrew. Chromium downloaded.

```bash
agent-browser --version   # 0.14.0
```

## Core Commands

```bash
# Navigate
agent-browser open <url>

# Get accessibility snapshot (compact text with refs)
agent-browser snapshot -i

# Interact via refs from snapshot
agent-browser click @e2
agent-browser type @e3 "search text"
agent-browser fill @e4 "form value"

# Screenshot
agent-browser screenshot output.png

# Close browser
agent-browser close
```

## Typical Flow

```bash
agent-browser open https://example.com
agent-browser snapshot -i
# Output: - heading "Example Domain" [ref=e1]
#         - link "More information..." [ref=e2]
agent-browser click @e2
agent-browser screenshot result.png
agent-browser close
```

## Sessions

Multiple isolated instances with separate auth:

```bash
agent-browser --session work open https://app.example.com
agent-browser --session personal open https://other.com
```

## Notes

- Daemon starts automatically, persists between commands (fast subsequent calls)
- 50+ commands: navigation, forms, screenshots, network, storage
- All platforms: macOS ARM64/x64, Linux, Windows
- Refs are snapshot-specific — always re-snapshot after navigation before using refs
