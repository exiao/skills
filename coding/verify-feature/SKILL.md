---
name: verify-feature
preloaded: true
description: Verify a code change actually works by building/running the app and observing it at its real surface (CLI, API, UI, library, agent), capturing runtime evidence rather than trusting tests. Make sure to use this skill whenever the user has changed code and wants to know it works, is about to merge/push and wants confidence, says "did this actually work", "verify this works", "prove it works", "confirm the change", "make sure it works", wants runtime evidence, or is re-running tests / importing-and-calling just to check behavior, even if they never say the word "verify". When in doubt after any code change, reach for this. For post-deploy production health checks use verify-deploy; for static correctness/quality review use simplify or code-review.
---

# Verify Feature

Verification is runtime observation. You build the app, run it, drive it to where
the changed code executes, and capture what you see. That capture is your evidence.
Nothing else is.

This is the difference between "I ran the tests" and "I drove the actual changed
code through its real interface and watched it behave." Only the second is
verification.

## What verification is NOT

- **Not running tests.** Running them proves you can run CI, not that the change
  works. Not as a warm-up, not "just to be sure," not as a regression sweep after.
  The time goes to running the app instead.
- **Not typechecking.** Same reason.
- **Not import-and-call.** `from src.foo import bar; print(bar(x))` is a unit test
  you just wrote. Calling a function in isolation only proves the function works in
  isolation. Find the real caller that reaches a user-facing surface.
- **Not re-reading the code or re-running CI.**

## Step 1 — Find the change

The diff is ground truth. Any description of it is a claim. Read both; if they
disagree, that's a finding.

```bash
git diff --stat origin/HEAD...   # committed vs base
git diff HEAD --stat             # uncommitted working tree
gh pr diff <n>                   # PR context
```

State the commit count. If the diff is large, redirect to a file and read it. If
there's no repo diff, say so and use the scope the user named.

## Step 2 — Identify the runtime surface

The surface is where a user or program interacts with the changed behavior. Map the
change to its surface and drive it there:

| Change reaches | Surface | What you do |
|----------------|---------|-------------|
| CLI / TUI | terminal | type the command, capture the pane (ShellExec; `interactive-cli-driving` for prompts) |
| Server / API | socket | send the request, capture the response (curl/httpie) |
| Web / UI (browser) | pixels | drive it and capture with **shot-scraper** — mandatory, see below |
| iOS-native GUI | pixels | drive it (`ios-simulator`), screenshot |

**Single component the full app can't build/reach?** When the change is one frontend
component and the production build OOMs or the surface sits behind auth/a paywall, mount
just that component in a throwaway Vite harness and screenshot the REAL component (not a
mock). Recipe in `references/isolated-component-harness.md`.
| Library | package boundary | exercise the public export — `import pkg`, NOT `import ./src/...` |
| Prompt / agent config | the agent | run the agent, capture its behavior |
| CI workflow | Actions | dispatch it, read the run |

**Internal functions are not surfaces.** Something in the repo calls the changed
function, and that caller ends at one of the rows above. Follow it there. A bash
auth gate is verified by observing the CLI prompt/auto-allow behavior, not by
inspecting the function's return value.

## Step 3 — Drive the changed code

Use the smallest path that makes the changed code execute:
- Changed a flag → run with that flag.
- Changed a handler → hit that route.
- Changed error handling → trigger that error.
- Changed an internal function → find the CLI/request/render path that reaches it.

Read your plan back before running: does this path actually execute the changed
lines? If not, pick a different entry point.

**Destructive path?** If the change touches code that deletes, publishes, sends, or
writes outside the workspace and there's no dry-run or safe target, don't drive it
live. Verify what you can around it and say in the report which path you did NOT
exercise and why.

## Web/UI surface — capture is mandatory, via shot-scraper

When the changed code renders in a browser (a web page, a React/Vue component, any
HTML surface), a PASS is **not valid without an attached shot-scraper capture** of the
changed UI. "It built" and "the console is clean" are not evidence a human can see; a
screenshot is. Screenshot is the floor; record a video when the change is an
interaction (a flow, an animation, a state transition), not just a static render.

```bash
command -v shot-scraper >/dev/null || uv tool install shot-scraper
shot-scraper install   # bundled chromium; no-op if already present

# static render → screenshot
shot-scraper "http://localhost:<port>/<route>" -o /tmp/verify-<change>.png --wait 1500

# interaction → video (drive it with a JS/selector script, or a shot-scraper
# YAML config that scripts clicks/waits before capturing)
shot-scraper video /tmp/verify-<change>.yml --mp4 --timeout 60000
```

Attach the PNG (or MP4) to the report/PR. If the surface is behind auth or a paywall or
the full build won't come up, mount just the changed component in a throwaway Vite
harness (see `references/isolated-component-harness.md`) and shot-scraper THAT — the real
component, never a mock. A UI change reported PASS with no attached capture is not
verified; downgrade it to BLOCKED and say the capture step didn't run.

## When you ARE the evaluator in a generator/evaluator loop

If verification is happening inside an agent loop (a separate evaluator judging a
generator's work), the rule sharpens: the evaluator's verification surface is the
RUNNING APP, never the diff. Anthropic's long-running-agent harness earns its keep
exactly here — its two highlighted catches were a FastAPI route-ordering bug that
returned 422 and a delete-key handler with `AND` where it needed `OR`. Both passed
every unit test and would have passed CI; they only surfaced because the evaluator
drove the live app (Playwright / computer-use) and observed the actual behavior. An
evaluator that reads diffs is doing code review, not verification. Drive the app, or
you miss the class of bug the loop exists to catch.

## The inert-feature trap (green tests, zero production effect)

A whole class of "verified" change does nothing in production even though every
test passes. The tests pass *because* they exercise the new code with synthetic
inputs the author constructed; the real corpus or pipeline never feeds it, so it
sits dead. Green CI is not evidence the feature *helps* — only that the code
runs when called. The user's standard is "try it on real data" / "does it
actually help", not "do the tests pass."

Three recurring shapes (all seen shipping as PRs with passing tests, all inert):

1. **Heuristic that never fires on real input.** A markdown-link/relationship
   extractor inferred edge types from keywords on the link's own line. Tests fed
   prose like "Apple competes with Samsung" → typed edges. Real memos put the
   relationship in the `## Competitors` / `## Suppliers` *header* and list bare
   links under it, so inference returned the `mentions` fallback for 100% of real
   edges. Tests green; feature useless.
2. **Validator/gate guarding a marker nothing uses.** A CI gate enforced that a
   sentinel comment appears only in allowlisted files — but the marker was in
   ZERO real files, and a bad actor adding a rogue write won't self-incriminate
   with the comment. It fires only on someone who labels their own violation.
   Pure theater.
3. **Correct engine with no fuel line.** A contradiction-probe eval had real
   logic and a working LLM judge, but nothing built its input objects from actual
   retrieval (zero constructors outside its own tests) and nothing in CI or the
   pipeline called it. An orphan module.

**The probe that catches all three — run it before claiming a feature helps:**

- **Feed it the REAL corpus, not the test fixture.** Run the new function over
  actual production data (real repo files, a real DB row, a live payload) and
  read the OUTPUT. For the extractor above: real output showed every edge came
  back as the `mentions` fallback — that one line was the whole verdict.
- **Count the population the feature acts on.** "Validates pages with a
  `## Timeline`" → `grep -rln '^## Timeline' real/` returned 0 of 58. A feature
  whose trigger population is zero is inert by construction.
- **Trace the wiring both directions.** Does anything PRODUCE the input
  (`grep "TheInputType("` outside tests)? Does anything CONSUME/CALL it
  (`grep` the CI workflows, the pipeline entrypoint, the eval runner)? An orphan
  with no producer and no caller is scaffolding, not a feature.
- **Adversary test for gates/validators.** A gate that only catches a violator
  who voluntarily labels their violation catches nothing. Ask: "what does the
  person doing the wrong thing actually do, and does this fire on THAT?"

If the feature is inert, say so plainly and either wire it or recommend closing
the PR — do not report it as "verified, tests pass." See
`references/inert-feature-probe.md` for the reusable shell recipe.

## The stale-evidence trap (a confident finding measured against old data)

The inert-feature trap is "the code runs but never fires on real input." Its mirror
image: you measure a finding against artifacts on disk (a fixture, a sample
workspace, a data dump, a cached export) and assert a conclusion, but the artifacts
are STALE — so the conclusion is confidently wrong and flips the moment you check
fresh data. This bites hardest when the thing you're measuring (a schema, a
vocabulary, a label set, an output format) is itself regenerated each run, so any
single snapshot is a sample of one, not the rule.

Real shape (seen this session): a "should we add a deterministic check on appendix
H's reliability tiers" question. The conclusion flipped FOUR times, each flip forced
by checking a fresher / more authoritative source:
- #1 "the two tier vocabularies don't align" — measured against a 3-week-old test
  fixture. WRONG.
- #2 "a constrained tier-1 check ships with zero false-fails" — measured against ONE
  real but 3-week-old workspace. WRONG.
- #3 "the taxonomy is LLM-authored fresh every run, no stable schema, BLOCKED" —
  measured across 2-3 older runs whose section headers genuinely drifted. Still WRONG,
  because those runs predated a format change.
- #4 (correct) — only when I read the NEWEST output by mtime AND the CANONICAL SPEC
  (the compiler/evaluator SKILL.md that defines the lint-gated H table + fixed five-tier
  vocabulary) did it resolve: the schema IS pinned, the older "drift" was pre-pinning,
  and the check is shippable. Proven by cross-checking the freshest fixture: 28/30 rows
  matched, 0 inflation.

Four flipped conclusions, every flip because the evidence wasn't current, wasn't
plural, OR wasn't anchored to the source-of-truth spec. The user had to push three
times ("check the latest workspace", "isn't there one from today", "just look for the
latest report.md") to force each correction. Lesson beyond freshness: when the artifact
is generated by a process that has a SPEC (a prompt, a schema definition, a skill that
dictates the format), the spec is the ground truth — a drifting sample means the sample
is old or the spec changed, NOT that there's no rule. Read the spec before concluding
"no stable structure exists."

**Before asserting a finding measured from on-disk artifacts, run the freshness gate:**

- **Date the artifact.** `ls -lt` / check the dir name / read the timestamp. If it's
  a `fixtures/` or `evals/` file, assume it's frozen and possibly months behind prod
  — fixtures are pinned on purpose. Never generalize from a fixture to "what the
  pipeline does now."
- **Find the actually-newest instance.** `find . -name <artifact> -newermt '<yesterday>'`,
  or sort the candidate dirs by mtime. "Newest I assumed" != "newest that exists" — check
  by real mtime, not by the path that came to mind first.
- **Check more than one.** If the artifact is regenerated per run, a single snapshot
  can't tell you what's stable vs incidental. Compare 2-3 recent ones; a property that
  differs across them is NOT something you can write a deterministic check against.
- **Know where the real artifacts live.** If runs execute remotely (Modal/CI/cloud)
  and only land in object storage or a DB, the local copies are whatever someone
  happened to pull down — usually old. Say "freshest on disk is X (stale); to measure
  on a current run I need to pull from <store>" rather than silently measuring the stale
  local copy.
- **State the basis in the finding.** "Measured against QRVO_2026-05-27 (3 weeks old)"
  lets the reader (and you, next turn) catch a stale-basis conclusion before it ships.
  A finding with no named, dated basis is a guess wearing a measurement's clothes.

If you can't get current data, say the conclusion is provisional on stale input and
name what you'd need to confirm it — don't launder a stale-data guess into a verdict.
Reusable freshness-gate recipe in `references/stale-evidence-gate.md`.

## The false-FAIL trap (red tests that are your machine, not the code)

The mirror of "green tests prove nothing": a batch of RED tests can be entirely
your local environment, not a regression — and reporting them as failures (or
worse, "fixing" the source to make them pass) is as wrong as a false PASS. Before
you treat a test failure as a real finding, ask: would this fail on a clean CI
runner too, or only on THIS box right now?

Seen this session: a broad sweep returned `59 failed, 7277 passed`. Every one of
the 59 traced to local environment state, not the branch (which didn't even touch
the failing files):

- **Exported env var flipped behavior.** `HERMES_ALLOW_PRIVATE_URLS=true` was
  exported in the shell, which disables the SSRF block the tests assert. 16 url/
  vision tests "failed." `env -u HERMES_ALLOW_PRIVATE_URLS pytest ...` -> 200/200 pass.
- **macOS tmp path vs Linux assumptions.** pytest's `tmp_path` lives under
  `/var/folders/...` on macOS, which a sensitive-path guard correctly blocks, and
  `AF_UNIX` socket paths there exceed macOS's 104-char `sun_path` limit
  (`OSError: AF_UNIX path too long`). ~43 file-tool + voice tests "failed."
  `TMPDIR=/tmp pytest ...` dropped the file-tool failures from 10 to 1.
- **OS-specific tests.** Linux-only socket/pulse tests can't pass on macOS at all;
  they're skipped on the real CI matrix, not failures.

**The triage gate — run it before reporting any red test as a regression:**

1. **Does my branch touch the failing file?** `git diff origin/<base>...HEAD -- <file>`.
   Empty diff = the failure is pre-existing or environmental, NOT introduced by you.
   Say so; do not "fix" source you didn't change to silence a test.
2. **Re-run with a clean env.** Strip suspect exports: `env -u VAR1 -u VAR2 pytest`.
   Check `env | grep -i <PROJECT>` for vars that override config defaults (the config
   file says `false`, your shell exports `true` -> tests lose). The config file is
   ground truth for what CI sees; an exported override is your box only.
3. **Re-run with Linux-like paths.** `TMPDIR=/tmp pytest ...`. macOS `/var/folders`
   and long socket paths break tests written against Linux `/tmp`.
4. **Group the failures first.** Don't read 59 tracebacks. Bucket by file/class,
   pull ONE representative traceback per bucket, and classify the bucket. Three
   buckets explained all 59 here.

If a red bucket is environmental, the verdict is still PASS for the change — report
"N failures, all environmental (exported env var / macOS tmp paths / OS-specific),
none touch the changed files, green on CI's clean Linux runners." Never patch source
or weaken an assertion to make a machine-specific failure go away. Reusable triage
recipe in `references/false-fail-triage.md`.

## Step 4 — Push on it (probe)

Confirming the happy path is the first half, not the job. Once the claim checks out,
deliberately try to break it at the **same surface you just drove** — you know exactly
what changed, so probe around it. Pick the probes the change points at:

- **New flag / option** → empty value, passed twice, combined with a conflicting flag,
  typo'd (does the error name it?).
- **New handler / route** → wrong method, malformed body, missing required field,
  oversized payload.
- **Changed error path** → the adjacent errors it didn't touch — did the refactor catch
  them too, or only the one in the diff?
- **Interactive / TUI** → Ctrl-C mid-op, resize the pane, paste garbage, Esc at the
  wrong moment.
- **State / persistence** → do it twice, do it with stale state underneath, do it in two
  sessions at once.

At least one probe. A Steps list that's all ✅ and no 🔍 is a happy-path replay — still
worth reporting, but you stopped at the first half. Every probe gets a report line even
when it HOLDS: "🔍 passed `--from ''` → clean `error: --from requires a value`, exit 2"
tells the author what was covered, which a bare PASS can't.

**The verdict is table stakes; your observations are the signal.** You're the only
reviewer who actually *ran* the thing. Lower the bar for findings to "would I mention
this if they were sitting next to me" — friction, surprises, odd defaults, not just
bugs. But the pause has to be yours, from running the app. A red CI check, a review
comment, another bot's output: visible to anyone already; relaying it isn't an
observation.

## Step 5 — Report a verdict

- **PASS** — drove the change through its real surface and it did what it should; here's
  the captured evidence (pane output, response body, screenshot, agent transcript, run
  link) plus any 🔍 probe lines. (Older runs say VERIFIED — same thing.) Not: tests pass,
  builds clean, code looks right. **Web/UI change → the evidence MUST include a
  shot-scraper capture (PNG floor, MP4 for interactions); no capture = not a PASS.**
- **FAIL** — ran it and it doesn't do what it should, or it breaks something else, or the
  claim and diff disagree materially. Attach the raw capture; don't interpret ambiguous
  output into a pass.
- **BLOCKED — (exact failure point).** Couldn't reach a state where the change is
  observable (build broke, missing dep, handle wouldn't come up) after a real attempt
  (~15 min timebox). Not a verdict on the change — say precisely where it stopped.
- **SKIP — no runtime surface: (reason).** Docs-only, type-declarations-with-no-emit,
  build config with no behavioral diff. Tests-in-the-diff are the author's evidence,
  not a surface; a tests-only PR is SKIP, one line. Mixed source + tests → verify the
  source, ignore the test files.

**No partial pass.** "3 of 4 passed" is FAIL until the 4th passes or is explained away.
**When in doubt, FAIL** — a false PASS ships broken code; a false FAIL costs one more
human look.

## Mode: Understanding gate (quiz me before I merge)

A separate concern from "does the code run": **does the user actually understand
what changed?** After a long agent-driven session, the diff can be large and much
of the behavior depends on existing code paths the user never saw execute. Reading
the diff gives a shallow understanding; the user can merge something they can't
explain. Trigger this mode when the user says "quiz me on this change", "make sure
I understand what happened", "I want to understand this before I merge", or after
any session where the agent did substantially more than the user watched.

Source: Thariq (@trq212), "Finding Your Unknowns" (Jul 2026) — "I only merge after
I pass the quiz perfectly."

How to run it:

1. **Give context first, then test.** Produce a short report of what changed and
   *why*: the intent, what each meaningful piece does, how it hooks into existing
   code paths, and the intuition behind the non-obvious decisions. The user can't
   pass a quiz on code they were never walked through.
2. **Then quiz.** Ask questions the user must answer correctly to prove they
   understand the change: what happens in edge case X, why was Y done this way,
   what would break if Z changed, which existing code path does this new function
   depend on. Prioritize questions where a wrong answer means they'd merge
   something they don't actually grasp.
3. **Grade honestly and don't wave it through.** If the user gets one wrong,
   explain the real answer and let them re-answer. The gate exists to catch a
   misunderstanding *before* merge, so a soft pass defeats it.
4. **An HTML report + quiz reads better than a chat wall** for a large change,
   render it (per `~/.hermes/VISUAL-IDENTITY.md`) with the explainer up top and the
   quiz at the bottom. Inline chat is fine for a small one.

This mode is orthogonal to runtime verification above: that proves the *code*
works, this proves the *user* understands it. A big merge often wants both.

## Boundaries with neighboring skills

- **verify-deploy** — production health checks after a release (HTTP status, latency,
  Render cron health) on already-deployed apps. This skill is about a *local change*
  you're trying to prove works, pre-merge.
- **simplify / code-review** — correctness and quality review by reading the diff.
  Verification is the complement: observe it running, don't reason about it statically.
