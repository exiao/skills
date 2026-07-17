# Isolated component harness (screenshot one React component the app can't build)

When the change is a single frontend component but driving it through the full app
is blocked — the production build OOMs, the route sits behind auth/a paywall, or
booting the whole SPA is slow — mount JUST that component in a throwaway harness and
screenshot it. This still counts as runtime evidence: you render the REAL component
(not a mock) with realistic props and observe pixels.

## Why not the alternatives

- **Full `vite build` / `bun run build`** can OOM on a large SPA (V8 "FatalProcessOutOfMemory",
  SIGABRT/exit 134). A dev server serving one entry is far lighter and won't OOM.
- **The live app** may need login + a paid tier to reach the surface (e.g. Bloom chat
  behind RevenueCat). The harness sidesteps auth entirely.
- **A hand-written mock** proves nothing about the real component. Import the actual
  source file.

## Recipe (Vite 4 + React 17 + Emotion, e.g. Bloom frontend)

The component used `@emotion/react` css-prop and design-token imports (woff2/otf/svg),
so it needs Vite's `@vitejs/plugin-react` transform with `jsxImportSource: '@emotion/react'`.
A bare esbuild bundle does NOT work: old esbuild (0.9.x) rejects `--jsx=automatic`, and
the css prop needs the emotion babel transform.

Put everything under a gitignored/untracked `.harness/` dir inside `frontend/` so it
never lands in the commit. Steps:

1. `frontend/.harness/main.tsx` — import the REAL component and mount it with realistic
   props. React 17 uses `ReactDOM.render`, NOT `react-dom/client` `createRoot`:
   ```tsx
   import React from 'react';
   import ReactDOM from 'react-dom';
   import ComparisonChart, { COMPARISON_COLORS } from '../src/components/ChatPage/Tools/ComparisonChart';
   // ...build realistic series data...
   ReactDOM.render(<App />, document.getElementById('root'));
   ```
2. `frontend/.harness/index.html`:
   ```html
   <!doctype html><html><head><meta charset="utf-8"></head>
   <body><div id="root"></div><script type="module" src="/main.tsx"></script></body></html>
   ```
3. `frontend/.harness/vite.harness.config.mjs` — a minimal config rooted at the harness
   so the whole app never boots:
   ```js
   import { defineConfig } from 'vite';
   import react from '@vitejs/plugin-react';
   export default defineConfig({
     root: '.harness',
     cacheDir: '../.vite-harness',
     server: { port: 9123, host: '127.0.0.1' },
     plugins: [react({ jsxImportSource: '@emotion/react' })],
   });
   ```
4. Run it (background): `node_modules/.bin/vite --config .harness/vite.harness.config.mjs`
5. `browser_navigate` to `http://127.0.0.1:9123/`, then confirm the DOM via
   `browser_console` (e.g. count `document.querySelectorAll('path').length` for chart
   lines), `browser_vision` to describe it, and capture the screenshot path it returns.
6. `file_send` the screenshot to the user.
7. **Clean up**: `trash .harness .vite-harness` and confirm `git status --short` shows
   only the real source files. The harness must never be committed.

## Honest framing in the report

Say plainly that this is the isolated component, NOT a live end-to-end session, and why
(auth/paywall/OOM). It proves the rendering path (props → output). The data/contract
feeding it in production is covered separately by the backend tests, not by this shot.
