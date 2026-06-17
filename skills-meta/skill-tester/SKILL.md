---
name: skill-tester
description: Test an interactive lesson/course (or any "instructions to an AI" skill) by self-play. An agent plays BOTH the instructor following the lesson script AND a calibrated student persona, producing full turn-by-turn transcripts of every lesson, then publishes the raw transcripts to a single static page. Use when asked to "run lesson transcripts", "test the course end to end", "self-play the lessons", "publish raw test transcripts", "walk a synthetic student through every lesson", or to QA an interactive-instruction skill by actually running it rather than just reviewing findings. Distinct from dogfood and adversarial-ux-test (web-app browser QA) and synthetic-userstudies (findings plus a few cherry-picked transcripts). This one captures the COMPLETE run of every lesson and ships them all raw.
---

# skill-tester — self-play lesson transcripts to a static page

Test an interactive course by RUNNING it, not reviewing it. Each lesson file is
"instructions to an AI on how to teach." A faithful test executes those instructions
against a simulated student and captures the whole conversation. Publish every transcript
raw so a human can read exactly how each lesson plays out and where it snags.

This is different from the QA skills you may already have:
- `dogfood` / `adversarial-ux-test` — browser automation against a deployed web app.
- `synthetic-userstudies` — produces ranked FINDINGS plus a couple of highest-signal
  transcripts. NOT full raw runs of every lesson.
- **skill-tester** — full turn-by-turn transcript of EVERY lesson, all published raw.

## When to run
After a lesson rewrite or new lessons, when the owner wants to SEE the lessons run rather
than read a findings memo. Run against the freshest source (pull the default branch, use a
worktree; local checkouts go stale).

## Step 1 — Grab the freshest source
Pull the repo, add a worktree on the default branch, confirm the lesson count matches the
latest merged work. Read any `CLAUDE.md` / `AGENTS.md` / `LESSON-FORMAT.md` / skill spec so
the instructor half follows the real teaching rules (e.g. "one step per message, STOP and
wait, DO the demo live, keep messages short").

## Step 2 — Self-play dispatch (parallel, read-only)
Group lessons (e.g. by section, ~4 each) and dispatch one read-only subagent per group,
toolsets limited to terminal + file, instructed NOT to edit anything except its own output
files. Each subagent, per lesson, writes a VERBATIM transcript where it plays both roles:
- **INSTRUCTOR**: follow the lesson file exactly — one step per message, run/narrate the
  demo, use the lesson's actual prompts and visuals, STOP after each step.
- **STUDENT**: a CALIBRATED persona (see below). Reacts in good faith, sometimes hits a
  snag, asks a clarifier, or pastes a plausible result.

Per-lesson transcript format: a `# Lesson N: title` heading, a one-line claimed magic
moment, the turn-by-turn body with `**INSTRUCTOR:**` / `**STUDENT:**` labels covering the
WHOLE lesson, then a `### Where it snagged` tail (1-3 real friction bullets, or "clean run").
Label every file SYNTHETIC.

## Step 3 — Calibrate the persona (the load-bearing decision)
The most fragile beginner persona is a FALSE FLOOR — it over-drives fixes and patronizes
the real audience. State the REAL audience explicitly before running (for an AI/dev course
it's typically a tool-literate professional: knows what a system prompt is, can install an
app and run a setup command). Assume competence. Keep skill-independent findings
(silent-failure bugs, missing-prerequisite fallbacks, overgeneralizations that lose a
skeptic); discount false-floor-only complaints.

## Step 4 — Publish raw
Build a single static page hosting ALL transcripts raw, collapsible per lesson, grouped by
section, with a SYNTHETIC warning header. See `references/build-transcripts-page.md` for the
build script and styling. A typical static-host deploy:
```
python3 build_transcripts.py        # writes index.html
cp index.html 200.html              # SPA fallback for hosts that need it
# deploy index.html + 200.html to any static host
```
Verify the live page with a real rendered screenshot, not just a DOM grep — static CDNs can
return a transient error on a cold first hit, retry after a few seconds.

## Pitfalls
- Local repo checkout is usually STALE. Always work from the remote default branch in a worktree.
- Read-only subagents get NO edit toolset beyond writing their own transcript files.
- Long URLs / code blocks force horizontal scroll on mobile — the build script sets
  `white-space:pre-wrap; word-break:break-word` and `overflow-wrap:anywhere` so they wrap.
- Don't cherry-pick. The whole point vs the findings-style test is that EVERY lesson ships
  raw, snags and all.
