---
name: gemini-svg
description: Use when generate interactive SVG animations via Gemini.
---

# Gemini SVG Generator

Generate beautiful, interactive SVG animations by sending prompts to Gemini 3.1 Pro Preview and extracting the SVG output.

## Why Gemini 3.1 Pro

Gemini 3.1 Pro Preview is exceptionally good at generating self-contained SVGs with embedded CSS animations, JavaScript interactivity, and clean visual design. It handles complex animation logic (hover states, transitions, particle effects, morphing) that other models struggle with.

## API Key

Use the Gemini API key from nano-banana-pro skill config: get it from `skills.entries.nano-banana-pro.apiKey` in the gateway config, or set `GEMINI_API_KEY` in env.

## How It Works

1. Take the user's description of what they want
2. Build an optimized prompt for SVG generation
3. Call Gemini 3.1 Pro Preview via the API
4. Extract the SVG from the response
5. Save to a file and open in browser for preview

## API Call

Use `GEMINI_API_KEY` from environment. Model: `gemini-3.1-pro-preview`.

```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "PROMPT_HERE"}]}],
    "generationConfig": {
      "temperature": 1.0,
      "maxOutputTokens": 65536
    }
  }'
```

Response path: `.candidates[0].content.parts[0].text`

Extract the SVG block from between `<svg` and `</svg>` (inclusive). If the response wraps it in markdown code fences, strip those.

## Prompt Engineering

Always prepend the user's request with this system context:

```
Generate a single, self-contained SVG file. Requirements:
- All styles must be embedded in a <style> tag inside the SVG
- All interactivity must use inline <script> tags inside the SVG
- Use CSS animations and transitions for smooth motion
- Use clean, modern visual design with attention to detail
- Include hover states and micro-interactions where appropriate
- The SVG must work standalone when opened in a browser
- Use viewBox for responsive sizing
- Prefer clean flat UI style unless the user specifies otherwise

User request: [USER'S DESCRIPTION]
```

### Prompt Tips for Better Results

Add these modifiers to the prompt based on what the user wants:

| Want | Add to prompt |
|------|--------------|
| Smooth animations | "Use CSS keyframe animations with ease-in-out timing" |
| Hover effects | "Add hover state transitions with transform and opacity changes" |
| Dark theme | "Use a dark background (#1a1a2e or similar) with light elements" |
| Glowing effects | "Add CSS filter: drop-shadow with colored glow on key elements" |
| Particles | "Include floating particle effects using CSS animations with staggered delays" |
| Morphing shapes | "Use CSS or SMIL animations to morph between shapes" |
| Interactive | "Add JavaScript click/hover handlers that trigger state changes" |
| Looping | "Make all animations loop infinitely with animation-iteration-count: infinite" |
| Staggered | "Stagger animation delays across elements for a wave/cascade effect" |

## Output Process

1. Call the API
2. Parse the response JSON with `python3` or `jq`
3. Extract SVG content
4. Save to file (default: `/tmp/gemini-svg-output.svg`, or user-specified path)
5. Open in browser: `open /tmp/gemini-svg-output.svg` (macOS)
6. Show the user the file path

### Extraction Script

Use Python for the full flow (reliable JSON handling, proper timeout):

```python
import json, re, urllib.request, os, sys

prompt = sys.argv[1]  # User's prompt with system prefix

payload = json.dumps({
    "contents": [{"parts": [{"text": prompt}]}],
    "generationConfig": {"temperature": 1.0, "maxOutputTokens": 65536}
})

url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key={os.environ['GEMINI_API_KEY']}"
req = urllib.request.Request(url, data=payload.encode(), headers={"Content-Type": "application/json"})

# Gemini 3.1 Pro can take 30-90s for complex SVG generation
resp = urllib.request.urlopen(req, timeout=120)
data = json.loads(resp.read())
text = data['candidates'][0]['content']['parts'][0]['text']

# Strip markdown code fences
text = re.sub(r'^```(?:svg|xml|html)?\n', '', text.strip())
text = re.sub(r'\n```\s*$', '', text.strip())

# Extract SVG
match = re.search(r'(<svg[\s\S]*?</svg>)', text)
svg = match.group(1) if match else text

output_path = sys.argv[2] if len(sys.argv) > 2 else '/tmp/gemini-svg-output.svg'
with open(output_path, 'w') as f:
    f.write(svg)

print(f"Saved to {output_path} ({len(svg)} bytes)")
```

**Important: Gemini 3.1 Pro takes 60-120 seconds for complex SVG generation.** Use `timeout=180` on exec calls. The sandbox may kill long-running processes; if that happens, run the Python script on the host directly or use `exec` with `host: "gateway"` if available. Always set the env var: `GEMINI_API_KEY=<key from TOOLS.md>`

## Example Prompts

These produce excellent results with Gemini 3.1 Pro Preview:

**UI Components:**
- "Generate an SVG of a sliding toggle switch where hovering over the sun icon turns it into a glowing moon, smoothly fading the background from light to dark. Clean flat UI style"
- "Create an animated loading spinner with three dots that bounce in sequence with a slight elastic overshoot"
- "Design a circular progress bar that fills from 0 to 75% with a gradient stroke and a counting number in the center"

**Decorative/Art:**
- "Create an animated galaxy with slowly rotating spiral arms, twinkling stars, and a glowing core. Dark background, blues and purples"
- "Generate a geometric pattern of hexagons that pulse with color on hover, creating a ripple effect outward from the hovered hex"
- "Design an animated wave pattern like a sound equalizer with bars that smoothly oscillate at different frequencies"

**Data Viz:**
- "Create an animated bar chart showing monthly revenue growing from Jan to Dec, bars slide up one by one with values appearing above each"
- "Generate a network graph with nodes connected by lines, nodes gently float and connections stretch elastically"

**Icons/Logos:**
- "Design an animated envelope icon that opens on hover to reveal a letter sliding up"
- "Create a hamburger menu icon that morphs into an X when hovered"

## Iteration

If the first result isn't right:
1. Show the user the result (open in browser)
2. Ask what to change
3. Re-prompt with the original request plus specific adjustments
4. Don't start from scratch. Include "Modify the previous design to..." in the prompt and describe the changes

## File Naming

- Default: `/tmp/gemini-svg-[short-description].svg`
- If user specifies a project context, save to an appropriate location
- For tweet/social media use: also render to PNG via `rsvg-convert` or browser screenshot if needed

## Limitations

- SVGs with JavaScript may not render in all contexts (e.g., embedding in markdown, some social media). For those cases, convert to GIF/video using browser screenshot + ffmpeg.
- Very complex animations (50+ animated elements) may produce large files. Keep it focused.
- Gemini may occasionally produce malformed SVG. If the file doesn't render, try regenerating with a slightly simplified prompt.
