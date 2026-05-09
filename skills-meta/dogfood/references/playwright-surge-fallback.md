# Playwright + Surge fallback for dogfood reports

Use this when `agent-browser` is unavailable or fails before exploration, or when the user explicitly asks to publish findings to Surge.

## When to use

- `command -v agent-browser` returns empty.
- Agent-browser session cannot start, but browser/playwright tooling is available.
- User says "publish findings to Surge", "put the report on Surge", or asks for a public QA report URL.

## Workflow

1. Create a durable output directory under `~/projects/dogfood/<target-slug>/` with `screenshots/`, `videos/`, `report.md`, and `index.html`.
2. Use browser tools or Playwright to explore as a user. Do not read target source code.
3. Capture:
   - full-page screenshots for overview pages,
   - viewport screenshots for each issue,
   - console messages and failed requests,
   - link inventory with `href` and accessible text,
   - form validation state when testing forms.
4. For static/visible issues, screenshot evidence is enough. For interactive issues, capture before/action/result screenshots. Use video only when it adds value and the tooling supports it.
5. Write both:
   - `report.md` for portable markdown evidence,
   - `index.html` for a readable public report.
6. Publish from the output directory:

```bash
surge . <target-slug>-dogfood-$(date +%Y%m%d).surge.sh
```

7. Verify the deployed report returns HTTP 200 before replying:

```bash
python - <<'PY'
import urllib.request
url='https://<domain>/'
with urllib.request.urlopen(url, timeout=20) as r:
    print(r.status, r.geturl())
PY
```

## Playwright probes that worked well

Capture page inventory and screenshots:

```js
const { chromium, devices } = require('playwright');
const fs = require('fs');
const path = require('path');

const out = `${process.env.HOME}/projects/dogfood/<target-slug>`;
const shots = path.join(out, 'screenshots');
fs.mkdirSync(shots, { recursive: true });

const pages = [
  ['home', 'https://example.com/'],
  ['about', 'https://example.com/about'],
  ['contact', 'https://example.com/contact-us'],
];

(async () => {
  const browser = await chromium.launch({ headless: true });
  const results = [];
  for (const [name, url] of pages) {
    const page = await browser.newPage({ viewport: { width: 1440, height: 1200 }, deviceScaleFactor: 1 });
    const messages = [];
    page.on('console', msg => messages.push({ type: msg.type(), text: msg.text() }));
    page.on('pageerror', err => messages.push({ type: 'pageerror', text: err.message }));
    page.on('requestfailed', req => messages.push({ type: 'requestfailed', url: req.url(), failure: req.failure()?.errorText }));
    const response = await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 45000 });
    await page.waitForTimeout(5000);
    await page.screenshot({ path: path.join(shots, `${name}-desktop.png`), fullPage: true });
    const data = await page.evaluate(() => ({
      title: document.title,
      url: location.href,
      bodyText: document.body.innerText,
      links: Array.from(document.querySelectorAll('a')).map(a => ({
        text: (a.innerText || a.getAttribute('aria-label') || '').trim().replace(/\s+/g, ' '),
        href: a.getAttribute('href'),
        abs: a.href
      })),
      buttons: Array.from(document.querySelectorAll('button')).map(b => (b.innerText || b.getAttribute('aria-label') || '').trim().replace(/\s+/g, ' ')),
      inputs: Array.from(document.querySelectorAll('input, textarea, select')).map(el => ({
        tag: el.tagName, type: el.getAttribute('type'), name: el.getAttribute('name'),
        placeholder: el.getAttribute('placeholder'), label: el.getAttribute('aria-label'), required: el.required
      }))
    }));
    results.push({ name, status: response && response.status(), messages, data, screenshot: `screenshots/${name}-desktop.png` });
    await page.close();
  }
  await browser.close();
  fs.writeFileSync(path.join(out, 'observations.json'), JSON.stringify(results, null, 2));
})();
```

Form validation probe:

```js
const state = await page.evaluate(() => ({
  validation: Array.from(document.querySelectorAll('input,textarea')).map(el => ({
    name: el.name,
    value: el.value,
    valid: el.validity.valid,
    validationMessage: el.validationMessage,
    required: el.required
  }))
}));
```

## Notes

- Avoid false positives from headless-only WebGL failures. Report WebGL issues as console/performance noise unless the visible UI is broken for a normal user.
- For Webflow sites, link inventories often reveal stale aria-label text, `href="#"` placeholders, and duplicated hidden responsive content. These are valid findings if they affect accessibility, SEO, or clickable navigation.
- Surge needs an `index.html` at the project root. If the main report is markdown, still generate a readable `index.html` that links to `report.md` and artifacts.
