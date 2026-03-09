---
name: excalidraw-mcp
description: Use when creating hand-drawn style Excalidraw diagrams via the Excalidraw MCP at https://mcp.excalidraw.com/mcp. Use for flow diagrams, architecture diagrams, slide visuals, and any time a sketchy/hand-drawn diagram is needed as a PNG file.
---

# Excalidraw MCP

Streams hand-drawn Excalidraw diagrams via MCP. Remote endpoint: `https://mcp.excalidraw.com/mcp`

## Connecting via mcporter

**Critical:** The `--server` flag auto-corrects to configured server names. Always use `--http-url` for the Excalidraw endpoint:

```bash
# List tools
mcporter list --http-url https://mcp.excalidraw.com/mcp

# Call a tool
mcporter call 'https://mcp.excalidraw.com/mcp.create_view' --args '{"elements": "[...]"}'
```

## Tools

| Tool | Purpose |
|------|---------|
| `read_me` | Returns element format reference. Call once per conversation. |
| `create_view` | Renders diagram in Clawdbot canvas panel (visible to user in chat). |
| `export_to_excalidraw` | Uploads to excalidraw.com, returns shareable URL you can screenshot. |
| `save_checkpoint` | Save user-edited state by ID. |
| `read_checkpoint` | Read checkpoint state for restore. |

## Getting a PNG File

`create_view` renders into a canvas panel — not a file. To get an embeddable image:

1. Use `export_to_excalidraw` → get shareable URL (e.g. `https://excalidraw.com/#json=...`)
2. Open URL in browser (`browser action=open profile=clawd`)
3. **Dismiss the "Load from link" dialog** — it always appears. Take a snapshot to get the button ref, then click "Replace my content"
4. Wait ~1.5s for diagram to render
5. Screenshot
6. Crop with ffmpeg: `ffmpeg -y -i input.jpg -vf 'crop=in_w:HEIGHT:0:0' -update 1 -frames:v 1 out.png`

```python
# Step 3 automation — snapshot then click
snapshot = browser(action="snapshot", targetId=tid)
# Find button "Replace my content" in snapshot, note its ref (e.g. e218)
browser(action="act", request={"kind":"click","ref":"e218"}, targetId=tid)
browser(action="act", request={"kind":"wait","timeMs":1500}, targetId=tid)
```

## Element Format

Elements are passed as a **JSON string** (double-encoded), not an array:

```python
import json, subprocess

elements = [...]  # list of element dicts
args = {"elements": json.dumps(elements)}  # elements MUST be a string

result = subprocess.run([
    "mcporter", "call",
    "https://mcp.excalidraw.com/mcp.create_view",
    "--args", json.dumps(args),
    "--output", "raw"
], capture_output=True, text=True)
```

## Element Reference

### Rectangle / Box + Bound Text (CORRECT for export_to_excalidraw)

The `label` shorthand only works in `create_view`. For `export_to_excalidraw`, use a separate bound text element with `containerId`:

```json
[
  {
    "type": "rectangle",
    "id": "r1",
    "x": 40, "y": 60, "width": 160, "height": 80,
    "angle": 0,
    "strokeColor": "#1e1e1e",
    "backgroundColor": "#e8f5e9",
    "fillStyle": "solid",
    "strokeWidth": 2, "strokeStyle": "solid",
    "roughness": 1, "opacity": 100,
    "roundness": {"type": 3}
  },
  {
    "type": "text",
    "id": "t1",
    "x": 40, "y": 60, "width": 160, "height": 80,
    "angle": 0,
    "strokeColor": "#1e1e1e",
    "backgroundColor": "transparent",
    "fillStyle": "solid",
    "strokeWidth": 1, "strokeStyle": "solid",
    "roughness": 1, "opacity": 100,
    "text": "My Label",
    "fontSize": 22,
    "fontFamily": 1,
    "textAlign": "center",
    "verticalAlign": "middle",
    "containerId": "r1",
    "originalText": "My Label"
  }
]
```

**fontFamily values:** 1=Virgil (hand-drawn) ← use this for the Excalidraw look, 2=Helvetica, 3=Cascadia (monospace)

Text element x/y/width/height must match the containing rectangle exactly.

### Arrow
```json
{
  "type": "arrow",
  "id": "a1",
  "x": 182, "y": 105,
  "width": 60, "height": 0,
  "angle": 0,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "points": [[0, 0], [60, 0]],
  "startArrowhead": null,
  "endArrowhead": "arrow"
}
```

### Text
```json
{
  "type": "text",
  "id": "t1",
  "x": 50, "y": 80,
  "width": 120, "height": 25,
  "text": "Hello",
  "fontSize": 20,
  "fontFamily": 1,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#1e1e1e"
}
```

### Export JSON wrapper
```python
excalidraw_json = json.dumps({
    "type": "excalidraw",
    "version": 2,
    "source": "https://excalidraw.com",
    "elements": elements,
    "appState": {"viewBackgroundColor": "#fffce8", "gridSize": None}
})
args = {"json": excalidraw_json}
```

## Color Palette (from read_me)

| Name | Hex | Use |
|------|-----|-----|
| Blue | `#4a9eed` | Primary actions |
| Amber | `#f59e0b` | Warnings, highlights |
| Green | `#22c55e` | Success |
| Red | `#ef4444` | Errors |
| Purple | `#8b5cf6` | Accents |

Background fills: `#e8f5e9` (green pastel), `#fff3e0` (orange pastel), `#ffd6d6` (red pastel), `#fffce8` (cream/default canvas)

## Layouts

### Left-to-right flow (4 boxes)
Spacing: box width ~155px, gap ~60px for arrows. Start x=20, y=60.
- Box 1: x=20
- Arrow: x=177 (box1.x + width + 2)
- Box 2: x=237 (arrow.x + 60)
- Arrow: x=394
- Box 3: x=454
- etc.

### Fan-in (3 sources → 1 center)
Use SVG `<path>` curves for the converging lines — Excalidraw arrows can't curve natively in the JSON format. Use `export_to_excalidraw` then screenshot.

## Common Mistakes

- **Passing elements as array** — `create_view` and `export_to_excalidraw` expect `elements` as a JSON *string*, not an array. Double-encode: `json.dumps(elements)`
- **Using `--server` flag** — it auto-corrects to a configured server. Use `--http-url https://mcp.excalidraw.com/mcp` instead
- **Expecting `create_view` to return an image** — it renders in the canvas panel only. Use `export_to_excalidraw` + screenshot for PNG files
- **Inline SVG marker ID conflicts** — when embedding multiple SVGs in one HTML doc, each `<marker id="...">` must be unique (ah-d1, ah-d2, ah-d3)
