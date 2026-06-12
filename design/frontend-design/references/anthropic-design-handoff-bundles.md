# Anthropic design handoff bundles

Use this when a user provides a URL like `https://api.anthropic.com/v1/design/h/<id>` as visual/design-system guidance.

## What the endpoint returns

The endpoint can return `application/gzip` containing a gzipped tar archive, not plain text. The first bytes may look like binary garbage if read directly.

Fetch and inspect safely:

```bash
python3 - <<'PY'
import gzip, pathlib, urllib.request
url = 'https://api.anthropic.com/v1/design/h/<id>'
raw = urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent':'Mozilla/5.0'}), timeout=30).read()
out = gzip.decompress(raw)
path = pathlib.Path('/tmp/design-bundle.tar')
path.write_bytes(out)
print(path, path.stat().st_size)
PY

tar -tf /tmp/design-bundle.tar | head -100
mkdir -p /tmp/design-bundle && tar -xf /tmp/design-bundle.tar -C /tmp/design-bundle
```

Use a unique temp directory for extraction. Do not put extracted archives inside the repo unless the design assets are intentionally part of the implementation.

## Reading order

1. `README.md` at bundle root. It explains the handoff and often says to read chat transcripts first.
2. `chats/*.md`. These capture intent and iteration history.
3. `project/README.md`. Usually summarizes product, visual foundations, copy rules, and caveats.
4. Token/theme files such as `colors_and_type.css`.
5. Primary prototypes under `project/preview/` or `project/ui_kits/` only as needed.

## Implementation rules

- Treat bundle files as prototypes, not production code.
- Copy visual decisions, tokens, spacing, typography, and component behavior. Do not blindly copy structure.
- If the bundle says not to render screenshots unless asked, respect that for inspection. Rendering the target implementation for verification is still fine when working on a live UI.
- Preserve existing product behavior while applying the design system.

## Typical token notes from a design bundle

A handoff bundle usually defines a tokenized palette. Common patterns worth preserving:

- Use a warm off-white canvas like `#FFFEFA` instead of pure white.
- Use a near-black text color like `#171616` instead of pure black.
- Define a secondary text ramp (e.g., `#504E4B` / `#74726D`) rather than a single gray.
- Pick one primary action color and keep it consistent across CTAs.
- Use tinted borders (e.g., `#CBCAC9`), often 2px on cards.
- Cards: warm light background, ~8px radius, ~16px padding, a very soft shadow such as `0 2px 3px rgba(203,202,201,0.5)`.
- Avoid gradients, glow, blur, heavy shadows, emoji, and unicode-as-icon in product UI.
- Honor the bundle's canonical font when licensing allows; fall back to a platform sans if a static page cannot ship the licensed font.
