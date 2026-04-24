---
name: signal-table-render
description: Auto-render markdown tables to PNG before sending on Signal. Signal's chat UI does not render markdown tables — pipes and dashes show as literal text. When an outgoing message to a Signal chat contains a markdown table (pipe-and-dash format), pipe it through `~/.hermes/bin/md-table-png` and attach the PNG using a `MEDIA:<path>` tag in the reply. Use this skill any time a response to a Signal user would include a markdown table, comparison grid, or multi-column structured data.
---

# signal-table-render

Signal only renders inline formatting (bold, italic, monospace, strikethrough). Markdown tables come through as garbled pipes. Any outgoing message that contains a table must be rendered to PNG first.

## When to trigger

- Active platform is Signal (check the channel / platform context)
- Outgoing message contains a block matching `^\s*\|.*\|\s*$` followed by a separator row `|---|---|`
- Or the user explicitly asks for a table, comparison, or side-by-side

Do NOT trigger for single-column lists, code blocks, or quoted tables from another message.

## How to render

Single command — no subprocess chain, no headless browser:

```bash
echo '<markdown here>' | ~/.hermes/bin/md-table-png - /tmp/table-<timestamp>.png
```

Or from a file:

```bash
~/.hermes/bin/md-table-png input.md /tmp/table.png
```

Performance: ~400ms warm, ~1s cold. No network, no subprocess chain.

## How to send — use the `MEDIA:` tag

Do **NOT** use the `FileSend` / `send_file` tool — its schema in gateway sessions is broken (no `file_path` param surfaced) and errors with "Not a file (maybe a directory?): ".

Instead, include a bare line in your reply text:

```
MEDIA:/tmp/table-<ts>.png
```

The gateway's `extract_media()` regex (see `hermes-agent/tools/send_file_tool.py`) picks up the tag and routes the file to Signal's `_send_attachment` as a native image attachment. Surrounding prose becomes the caption.

### Example reply body

```
Here's the side-by-side:

MEDIA:/tmp/table-1234.png
```

Do NOT also include the raw markdown table in the message body — that defeats the point.

## What the renderer supports

- Pipe-separated markdown tables with `|---|` separator row
- Bold via `**text**` (in cells and surrounding prose)
- Monospace throughout (Menlo, retina-crisp via 2x supersample)
- Multiple tables + prose blocks in one message
- Auto column widths

## What it does NOT support (intentional — keep it fast)

- Nested markdown inside cells (links, code backticks → rendered literally)
- Images, HTML
- Color theming
- Non-macOS font fallback (Menlo only)

If the user wants something fancier, escalate to `wkhtmltopdf` or `matplotlib` — but default is Pillow for latency.

## Script location

`~/.hermes/bin/md-table-png` — self-contained Python, depends only on Pillow (already installed).

## Full worked example

User on Signal asks for a comparison of two tools. Draft response contains:

```
**Side-by-side**

| Dimension | A | B |
|-----------|---|---|
| **Cost** | $10 | $20 |
| **Speed** | Fast | Slow |
```

Correct flow:
1. Write that markdown to `/tmp/msg.md`
2. `~/.hermes/bin/md-table-png /tmp/msg.md /tmp/out.png`
3. Reply body:
   ```
   Side-by-side comparison:

   MEDIA:/tmp/out.png
   ```
4. Do not also send the raw pipes as text.
