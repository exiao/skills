# In-context previews: render the fix inside the real page chrome

The single biggest legibility failure when previewing a UX change for a decision
the user has to make: rendering the affected component **bare**, stripped of the
app's real surrounding chrome. It then looks nothing like production, and the user
can't judge the change. Real correction:

> "the component wasn't inside of the card, that's why it's so different than the
> site. Please re-make the surge page in context so I can choose an option again."

The first preview had rendered the component body alone. In production that body is
a white **card** (`markdown-body`: border + 8px radius + 32px padding) that lives
inside a 1140px `.container`, under the global header/nav, a breadcrumb, a sub-nav,
and a side panel. None of that was in the bare preview, so it read as a different
product.

## Rule

When the preview exists so the user can **choose** between fixes on a real surface,
reproduce the real page context, not just the component:

- Pull the app's **actual CSS** verbatim (the real `<style>` block / stylesheet),
  not a hand-approximated subset. Hand-rebuilt tokens drift.
- Include the real page **chrome**: container width, global header/nav, breadcrumbs,
  sub-nav, any panels that sit above the component. The component's own wrapper
  (card border/radius/padding) is part of the chrome too — don't drop it.
- Run the app's **actual transform** if the surface is built by client JS. Execute
  the real function rather than reimplementing it (see pitfall below).
- Feed it **real content** (a fixture or live payload), not lorem.

A bare-component render is fine for a pure component-library demo. It is wrong for
"help me pick how this looks on the page."

## Option switcher beats N separate pages

When offering the user multiple fix options, build ONE in-context preview with a
fixed (`position: fixed`) option switcher (radio groups) that toggles `body` data
attributes, and gate each variant's CSS on those attributes:

```css
body[data-hdr="a"] #md-content > details:first-of-type { margin-bottom: 28px; border-bottom: 1px solid var(--paper-warm); }
body[data-hdr="b"] #md-content > details:first-of-type { margin-bottom: 28px; }
body[data-rail="hover"] .section[open] { border-left-color: var(--border); }
body[data-rail="hover"] .section:hover { border-left-color: var(--accent); }
```

```js
function sync(){
  document.body.dataset.hdr  = document.querySelector('input[name=hdr]:checked').value;
  document.body.dataset.rail = document.querySelector('input[name=rail]:checked').value;
}
```

The user flips options live against the real surface and tells you the winner. Far
better than three near-identical pages they have to diff by eye. Include a
"Current" option so they can A/B against today's state.

## Build recipe (static, no app server needed)

A faithful preview can be a single static HTML file deployed to Surge, built by a
small Python script that reuses the real source:

1. Read the real template, regex out the `<style>…</style>` block, keep it verbatim.
2. Reproduce the page chrome HTML (header/nav/breadcrumb/sub-nav/panels) — copy the
   real markup from the route handler, swap live URLs for `#`.
3. If the surface is built by a JS transform that lives in a server helper as a
   returned string, **execute that helper to get the decoded string** — do NOT
   regex its source body out. The source carries Python-escaped sequences (e.g. a
   CSS caret `content: '\25BE'` is stored as `'\\25BE'`); only running the function
   decodes them. Pattern:
   ```python
   fn_src = re.search(r"(def _the_helper\(\) -> str:.*?)\n\n\n", src, re.S).group(1)
   ns = {}; exec(fn_src, ns)
   block = ns["_the_helper"]()
   assert "<script>" in block, "helper failed to build"
   ```
   When grabbing a whole function by regex, anchor the end on the next top-level
   `def` / blank-line gap — grabbing only up to the docstring's closing `"""`
   silently captures an empty body that `exec`s to a function returning `None`.
4. Render markdown the same way the app does (the app loads `marked` from a CDN, so
   render client-side with the same `marked` — including its GFM quirks like single
   `~text~` → strikethrough; that's faithful, not a bug to fix).
5. Inject the option switcher, write the file, deploy:
   `surge <dir> <name>.surge.sh`.

## Verify before sending the URL

Open the built file in the browser and screenshot/vision-check the top of the
surface before deploying. Catch the artifacts that only show at render time:
literal `\25BE` text where a caret glyph should be (the exec-decode bug above),
the transform not running (sections unwrapped), CDN-render quirks. A faithful
preview that renders garbage is worse than no preview. Then `curl -o /dev/null -w
"%{http_code}"` the live URL a couple times (a one-off 504 right after deploy is
normal; confirm it settles to 200).
