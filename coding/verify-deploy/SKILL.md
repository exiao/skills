---
name: verify-deploy
description: Post-merge deploy verification. Waits for deploy, benchmarks production, monitors for regressions. Use after merging a PR to confirm the deploy is healthy.
---
# Verify Deploy

Post-merge deploy verification. Waits for deploy, benchmarks production, monitors for regressions. One skill to go from "just merged" to "verified in production."

Use when: a PR was just merged and you need to confirm the deploy is healthy. Never merges PRs. Assumes the user already merged.

**Requires:** Browser (for benchmarking and canary monitoring).

---

## Phase 1: LAND (Wait for Deploy)

### Detect the deploy target

Check the repo for deploy configuration:
- `render.yaml` → Render (poll the deploy API or service URL)
- `railway.json` or Railway project → Railway
- `fly.toml` → Fly.io
- `vercel.json` or `.vercel` → Vercel
- GitHub Actions deploy workflow → wait for workflow run to complete

If none found, ask the user for the production URL.

### Wait for CI

```bash
# Watch the latest commit's CI status
gh run list --branch main --limit 3
gh run watch <run_id>
```

If CI fails, stop immediately. Report the failure and the failing step. Send to Signal if a channel is available.

### Wait for deploy

Poll the production URL until it responds with 200. Timeout after 10 minutes.

```bash
# Simple health check loop
curl -s -o /dev/null -w "%{http_code}" <production_url>/health
```

If the platform has an API (Render, Railway), use it to check deploy status. Otherwise, poll the health endpoint every 15 seconds.

### Confirm deploy

Once healthy:
- Hit the health/root endpoint, confirm 200
- Check response headers for version/commit hash if available
- Report: "Deploy is live. Starting benchmark."

---

## Phase 2: BENCHMARK (Measure Production)

Browse production and measure performance on the pages affected by the PR.

### Identify affected pages

Read the merge commit or recent diff to determine which pages/routes changed:

```bash
gh pr view <latest_merged_pr> --json files --jq '.files[].path'
```

Map changed files to production routes. If unclear, benchmark the homepage + any obvious routes.

### For each page, measure:

Using the browser:

1. **Navigate** to the page
2. **Screenshot** for visual record
3. **Console errors** — capture any JS errors or warnings
4. **Page load time** — use `performance.timing` or `Performance API`:
   ```javascript
   const timing = performance.getEntriesByType('navigation')[0];
   return {
     domContentLoaded: timing.domContentLoadedEventEnd - timing.startTime,
     load: timing.loadEventEnd - timing.startTime,
     firstByte: timing.responseStart - timing.startTime
   };
   ```
5. **Core Web Vitals** (if available via `web-vitals` or PerformanceObserver):
   - LCP (Largest Contentful Paint)
   - CLS (Cumulative Layout Shift)
   - FID / INP (Interaction to Next Paint)
6. **Resource summary**:
   ```javascript
   const resources = performance.getEntriesByType('resource');
   return {
     count: resources.length,
     totalSize: resources.reduce((sum, r) => sum + (r.transferSize || 0), 0),
     slowest: resources.sort((a, b) => b.duration - a.duration).slice(0, 3).map(r => ({ name: r.name, duration: r.duration }))
   };
   ```
7. **Failed network requests** — check for 4xx/5xx in resource entries

### Report benchmark results

```
Benchmark: https://app.example.com
  Pages tested: 4
  
  /dashboard
    Load: 1.2s · TTFB: 180ms · Resources: 34 (1.8MB)
    LCP: 1.1s · CLS: 0.02
    Console errors: none
    
  /settings
    Load: 0.8s · TTFB: 150ms · Resources: 22 (950KB)
    Console errors: none
    
  Flags:
    ⚠️ /dashboard LCP > 1s
    ✅ No console errors
    ✅ No failed requests
```

If anything looks bad (load > 3s, console errors, failed requests), flag it clearly but continue to canary phase.

---

## Phase 3: CANARY (Monitor for 5 Minutes)

Post-deploy monitoring loop. Default: 5 minutes, checking every 60 seconds (5 loops).

The user can request a longer window. Respect it.

### Each loop:

1. **Hit key pages** — the same pages from benchmark phase
2. **Check console** — new JS errors since last check?
3. **Check network** — failed API calls? 5xx responses?
4. **Screenshot** — visual regression check (compare to benchmark screenshot)
5. **Health endpoint** — still 200?

### Alert criteria (send to Signal immediately, don't wait for loop):

- New console errors that weren't present in benchmark phase
- Any 5xx response from the app or its APIs
- Health endpoint returns non-200
- Page fails to load entirely
- Significant visual change from benchmark screenshot (use judgment)

### Alert format

Send to Signal with:
```
🚨 Deploy issue detected

URL: https://app.example.com/dashboard
Issue: 3 new console errors after deploy
Time: 2 minutes post-deploy

Errors:
  - TypeError: Cannot read property 'data' of undefined (main.js:1234)
  - Failed to fetch: /api/v1/portfolio (503)
  - Unhandled promise rejection (analytics.js:56)

Action needed: check the latest merge commit.
```

### Clean exit

If all loops pass with no issues:

```
✅ Deploy verified

Monitored for 5 minutes (5 checks)
Pages: 4 · Errors: 0 · Avg load: 1.1s
No regressions detected. Deploy is healthy.
```

---

## Error Handling

- **CI fails** → Stop. Report. Alert via Signal.
- **Deploy times out (>10 min)** → Stop. Report. Alert via Signal.
- **Browser can't start** → Stop. This skill requires browser.
- **Canary finds issues** → Alert immediately. Continue monitoring to see if it's transient or persistent. Report final status at end of window.

## Anti-Patterns

- Never merge PRs. The user merges.
- Don't store baselines or historical data. Each run is self-contained.
- Don't skip the canary phase even if benchmark looks clean. Bugs surface under real traffic.
- Don't silently swallow console errors. Report everything, let the user decide what matters.
- Don't run longer than requested. If the user says 5 minutes, stop at 5 minutes.

---

## Scheduled Mode (`--scheduled`)

When invoked by a daily cron job, skip Phases 1-3 and run a lighter health-check flow across a fixed set of monitored apps:

1. Curl every endpoint in your **Apps monitored** config, record HTTP status + latency.
2. Deploy detection: `gh api` to count commits in the last 24h for each repo.
3. If recent commits exist, browser-benchmark that app's frontend (load time, TTFB, console errors, failed requests). Skip CWV/resource breakdowns.
4. No canary. Leave canary alerting to your error-tracking service (e.g. Sentry).
5. In cron mode, don't message directly — return the report for the scheduler to deliver.
6. **Lead with problems.** If any check failed (non-200, unreachable site, failed cron run), open with a `🚨 Issues` block listing each failure on one line. If everything passed, open with `✅ All systems healthy.` The detailed tables follow either way.

Output the "🏥 App Health Check" report format (table of endpoints + flags + optional "🆕 Recent deploys" section).

### Apps monitored config

Keep the monitored set in a config the skill reads (or list it inline), one row per app:

| App | Frontend URL | API URL | Endpoints | Repo |
|-----|-------------|---------|-----------|------|
| `<your-app>` | `https://your-app.example.com` | `https://your-api.example.com` | `/health`, `/`, ... | `<owner>/<repo>` |

Use the configured URLs exactly — don't rediscover or substitute domains at runtime. Additional one-off sites can be passed in a prompt; include them in the health table but don't permanently add them unless they recur.

### Commit counting

Use the repo's default branch, then count commits since 24h ago. Keep `gh api` as GET when passing fields, and paginate the count — otherwise repos with more than 100 commits in the window get silently undercounted:

```bash
default=$(gh api --method GET repos/$OWNER/$REPO --jq .default_branch)
count=$(gh api --paginate --method GET repos/$OWNER/$REPO/commits \
  -f sha="$default" \
  -f since="$SINCE_ISO" \
  -f per_page=100 \
  --jq '.[].sha' | wc -l)
```

Generate `SINCE_ISO` in Python (`datetime.now(timezone.utc) - timedelta(hours=24)`) rather than shell `date` — quoting around inline date math fails silently inside automation wrappers.

### Scheduled-mode pitfalls

- **Check health endpoint semantics, not just status.** A monitored URL can return 200 but serve an SPA HTML shell (or other non-health body) for ANY path — including made-up ones. Keep the HTTP status in the table but label it (`200, SPA HTML`) and don't imply backend API health. Probe the real backend health endpoint, not the static frontend host.
- **Don't parse truncated health bodies.** Tool wrappers often keep only a short `body_preview`; a long field can truncate the JSON before later fields and break parsing. If status is 200 but parsed JSON is `null`, refetch the full body before reporting degraded health.
- **Slow-endpoint retry.** If an endpoint returns 200 but is unusually slow, retry once or twice before finalizing. Keep the original latency visible in the table, but annotate the flag if it recovers — avoids over-alerting on one-off cold starts.
- **Browser benchmark accuracy.** Don't count `PerformanceResourceTiming.responseStatus === 0` as a failed request — cross-origin resources often report 0 due to CORS visibility even when they loaded fine. Read the load-time console output *before* clearing the buffer, and clear it between sites so warnings from a prior page aren't attributed to the next one.
- **Cron run health (if monitored).** When checking a platform's scheduled-job runs (e.g. Render cron), filter the events feed for the actual run-ended event type, not build events — back-to-back build events can bury the last run if you only fetch a small page. Page through until you find a real run result, and don't flag a not-yet-run scheduled job as a failure.
- **Don't over-alert.** This is an informational digest, not incident response. Keep flags tight and factual.
