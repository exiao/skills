# Backend 5xx Triage — crash vs. isolated error vs. transient restart

When an API probe returns a 5xx during dogfooding, do NOT report it raw. Classify it
first, because the severity and the owning team differ wildly. A 502 can mean "this one
route is buggy," "this route takes the whole worker down," or "the service just happened
to be restarting." Each gets a different writeup.

## The triage sequence (run this every time you see a 5xx)

1. **Probe a cheap unrelated route immediately** — `/health` or `/`.
   - If it ALSO returns 5xx → the worker is down, not just the route. This is a
     **service-wide crash** (P1: a single request brownouts everything).
   - If it returns 200 → the failing route is **isolated** (handled error or 404-as-500),
     much lower severity.
2. **Time the failure.** A crash returns fast (~0.3–0.5s — the process dies, no work
     done). A genuine timeout/overload sits near your `-m` ceiling. Fast 502 + health
     also down = the request killed the worker.
3. **Poll `/health` until recovery** (e.g. 5 tries × 5s). If it comes back on its own in
     5–15s, the platform auto-restarted the worker. Confirm the route is the trigger by
     re-hitting it once in isolation: if it crashes again deterministically, it's a real
     bug, not a coincidental restart.
4. **Re-hit the suspect route alone** to prove determinism. Reproduced twice = report it.
     Happened once and never again = likely a coincidental deploy/restart; note it but
     don't over-rank it.

## Distinguishing a real crash from a coincidental restart

Many hosting platforms restart on deploys and OOM. A lone 502 that never
reproduces is probably a restart you happened to catch, NOT your repro. Only call it a
bug after step 4 reproduces it. Conversely, if `/health` was 200 right before your probe,
went 502 right after, and the route reproduces the 502 — your request caused it.

## Common server-side crash signature: async route calls sync DB/ORM

A frequent root cause of "one GET takes the whole worker down" is an `async def` route
that calls a **synchronous** DB/ORM function inside the running event loop. Examples:
Piccolo `.run_sync()`, sync SQLAlchemy `Session`, blocking `sqlite3` writes. These raise
"cannot run inside a running loop" (or just block the loop) and can kill the worker.

- **Smell:** an `async def` handler that calls a helper which internally does `.run_sync()`
  / blocking I/O without `await asyncio.to_thread(...)`.
- **Why dogfood catches it but unit tests don't:** tests often call the helper directly
  (sync context), so the loop conflict never fires. Only a live async request triggers it.
- **The fix to recommend:** wrap the sync call in `await asyncio.to_thread(...)` — the
  same offload pattern used for blocking file/network I/O. When a PR already adds
  to_thread for SOME calls on a route, check whether it covers ALL the sync calls; a
  partial fix (e.g. wraps the file download but not the ORM staleness check) still crashes.
- **DON'T assume `.run_sync()` is the culprit — it usually isn't.** Many ORMs (Piccolo
  included) run `.run_sync()` fine from inside an async route by dispatching to their own
  thread; you'll find it used in dozens of working routes. The real worker-killer is any
  **long synchronous call that blocks the loop long enough for the platform health check
  to time out** — most often a **synchronous LLM / third-party HTTP call** (e.g.
  a blocking SDK call), not a fast DB query. Tell-tale: the
  crashing route only dies on the code path that does the slow work (e.g. the no-cache
  branch that calls the LLM) and returns 200 on the cached path. If a route calls a
  run_sync helper FIRST and survives, then dies later at an LLM call, the run_sync was
  never the problem.

## Diagnose before you write the fix (do not ship a guessed root cause)

Reproducing a crash is not the same as knowing why it crashes. Before recommending or
coding a fix:
1. **Grep the actual call path.** Read the failing route and every helper it calls. Find
   which line does slow/blocking work. Check sibling working routes to rule out your first
   guess (e.g. "is `.run_sync()` really unique to this route? No — 20 others use it").
2. **Reproduce deterministically and isolate the trigger.** Hit the route on a cached vs.
   un-cached run, or with each suspect operation toggled, until exactly one operation
   correlates with the crash. A 502 you saw once during a burst of cold requests may be a
   coincidental restart, not the route.
3. **Only then write the fix + a regression test that fails on the old code and passes on
   the new.** For an async-blocking fix, the durable test invokes the route with the
   blocking helpers monkeypatched to record `threading.get_ident()`, and asserts they ran
   off the event-loop thread. Verify it red-then-green by temporarily reverting the route.

A confidently-wrong root cause wastes a PR and erodes trust. Confirm the mechanism
empirically rather than asserting it.

## Don't let an open PR give false comfort

When verifying a migration/cutover, an open PR may be advertised as "the fix." Check
whether it actually closes the specific failure you reproduced. Read the PR's version of
the failing route and trace whether the crashing line is the one it changes. A PR can fix
a *related* gap (e.g. a 404 read-path) while leaving a *different* crash on the same route
untouched. Report that explicitly: "merging #N closes ISSUE-A but NOT ISSUE-B."

## Reporting

- Service-wide crash from one request → **P1**, even if no UI calls the route today
  (any probe/curl brownouts prod). State the blast radius honestly: "API-only, no UI
  caller, but hitting it 502s the whole worker for ~10s."
- Isolated handled error / wrong-but-graceful state → P2/P3.
- Always cite: the exact request, the response time, what `/health` did during, and how
  many times it reproduced.
