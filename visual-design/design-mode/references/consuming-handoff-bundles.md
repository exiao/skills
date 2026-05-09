# Consuming Claude Design Handoff Bundles

When a user shares a claude.ai/design handoff URL (format: `api.anthropic.com/v1/design/h/<id>?open_file=<filename>`), follow this workflow to extract, understand, and implement the design.

## Bundle Format

The URL returns a gzip-compressed tar archive. Extract it. If curl/gunzip naming gets awkward, use Python so you can inspect content type and write a normal `.tar` file:

```bash
python3 - <<'PY'
import gzip, pathlib, urllib.request
url = '<url>'
raw = urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent':'Mozilla/5.0'}), timeout=30).read()
out = gzip.decompress(raw)
path = pathlib.Path('/tmp/design-bundle.tar')
path.write_bytes(out)
print(path, path.stat().st_size)
PY

tar -tf /tmp/design-bundle.tar | head -100
mkdir -p /tmp/design-extracted
tar -xf /tmp/design-bundle.tar -C /tmp/design-extracted
```

Use a unique `/tmp` directory. Do not extract archives into the target repo unless the assets are intentionally part of the implementation.

## Bundle Structure

```
<project-name>/
├── README.md              # Instructions for coding agents (read first)
├── chats/                 # Conversation transcripts (intent lives here)
│   └── chat1.md           # Full back-and-forth with design decisions
└── project/               # Design prototype files
    ├── <Primary>.html     # Main file (indicated in README + URL param)
    ├── *.jsx              # React components (Babel-transpiled inline)
    ├── <brand>/           # Design system assets
    │   ├── style.css      # Component styles
    │   ├── colors_and_type.css  # Tokens, type scale, dark mode
    │   ├── fonts/         # Webfont files
    │   ├── illustrations/ # SVG assets
    │   ├── icons/         # Icon SVGs
    │   └── screens.jsx    # Screen components
    └── ios-frame.jsx      # Device frame (ignore for implementation)
```

## Reading Order

1. **README.md** - processing instructions, which file was open at handoff
2. **chats/*.md** - conversation transcripts showing user intent and iteration
3. **Primary HTML file** - orchestration, flow logic, tweak defaults
4. **Imported JSX files** - screen components (the actual UI to implement)
5. **CSS files** - design tokens, component styles (the visual spec)
6. **Assets** - SVGs, fonts, images to potentially port

## Key Concepts

- **Tweaks panel**: A design-time control panel for toggling variants (theme, flow length, providers). Maps to feature flags or A/B test configs in production.
- **`TWEAK_DEFAULTS`**: The JSON block between `/*EDITMODE-BEGIN*/` and `/*EDITMODE-END*/` shows the designer's recommended default configuration.
- **Starter components** (ios-frame.jsx, tweaks-panel.jsx): Presentation scaffolding; ignore for implementation. Only the brand-specific screens.jsx and style files matter.
- **`window` exports**: Components are shared between Babel scripts via `Object.assign(window, {...})`. In production, use normal imports.

## Implementation Strategy

1. **Don't copy prototype structure.** The HTML/Babel/CDN setup is for prototyping only. Implement in whatever framework the target codebase uses.
2. **Extract design tokens first.** The `colors_and_type.css` contains the authoritative token values (colors, spacing, type scale, radii, shadows). Map these to the existing design system.
3. **Match visual output, not code.** CSS class names like `.bloom-btn` define the visual spec. Implement those specs in whatever styling approach the codebase uses (Emotion, Chakra, Tailwind, etc.).
4. **Port SVG illustrations.** Copy relevant SVGs into the target project's asset directory.
5. **Translate flow logic.** The main HTML file's `computeSteps()` function and state management show the intended flow. Implement using the target's routing/state approach.

## Comparison Workflow

When asked to compare a design bundle against existing code:

1. Extract the bundle and read its flow/screens
2. Find the existing implementation in the codebase (search for onboarding/flow keywords)
3. Map screens 1:1 between design and existing code
4. Report: what's new, what's changed, what's removed, what's better in each
5. Recommend which changes are highest-impact to adopt

## Bloom light-mode token notes

A May 2026 Bloom design bundle established these production UI defaults:

- Canvas: `#FFFEFA` (Bloom sugar), not pure white.
- Primary text: `#171616` (liquorice), not pure black.
- Secondary text: `#504E4B` and `#74726D`.
- Action/accent: `#118383` petrol blue.
- Borders: `#CBCAC9`, commonly 2px on cards.
- Cards: warm light surface, 8px radius, 16px-ish padding, very soft `0 2px 3px rgba(203,202,201,0.5)` shadow.
- Product UI should avoid gradients, glow, blur, heavy shadows, emoji, and unicode-as-icon. Use SVG/CSS icons instead.
- Helvetica Now is canonical when licensed and available. Static marketing pages can fall back to platform sans rather than shipping licensed fonts.

## Sharing Design Previews

Users often can't open multi-file HTML prototypes locally (JSX imports and relative paths break). Deploy to Surge for instant preview:

```bash
cd /tmp/<extracted>/project
cp "<Primary>.html" index.html    # Surge needs index.html
npx surge . <descriptive-name>.surge.sh
```

This preserves relative asset paths (fonts, SVGs, JSX imports) since Surge serves the whole directory. Send the user the URL so they can interact with the prototype in-browser.

## Pitfalls

- The bundle URL returns `application/gzip` content-type. WebExtract/Firecrawl will fail; use curl or Python directly.
- If the first bytes look like binary garbage, you probably decompressed neither gzip nor tar yet. Save/decompress first, then `tar -tf` to list files.
- Chat transcripts contain `[tool: ...]` markers for Claude's tool calls. Skip those; focus on user messages and assistant's summary text.
- `[tool: snip]` markers mean context was compressed during design. Ignore gaps.
- Some assets may be referenced but missing (e.g. `bloom-mark.svg`). Check the target codebase for existing equivalents.
- Fonts in the bundle may not be licensed for production use. Verify before copying.
- When sending the raw HTML file to the user (e.g. via Signal), they likely can't open it because it has JSX/CSS imports with relative paths. Use the Surge deploy method above instead.
