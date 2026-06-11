# Deferable review comments must become real follow-up PRs

Use this when babysitting a PR or sweeping open PRs and reviewer comments are low priority but not worth blocking the current PR.

## Core rule

Do not leave deferable comments as a recommendation, TODO, digest note, or memory. If a comment is safe to defer, open a real follow-up PR and link it from the original review thread. Otherwise it will be forgotten.

## Classify first

- **Blocking:** correctness, crash, security/privacy, data loss/corruption, regression, failing test, deploy break, API contract break, semantic conflict, `CHANGES_REQUESTED`, or any plausible bot-flagged bug. Fix on the current PR or escalate.
- **Deferable:** style, naming, docs, test ergonomics, small cleanup/refactor, dedupe, logging polish, non-critical perf, or a nice-to-have improvement that does not affect correctness. Open follow-up PR.
- **Human-intent:** product/design/API judgment or multiple valid approaches. Ask/escalate unless the user explicitly says to defer via follow-up.
- **Addressed:** fixed, stale, outdated, false positive, or already handled. Reply/resolve with evidence.

If unsure whether a comment is harmless, treat it as blocking.

## A reviewer's "non-blocking nit" can still be a same-PR fix when a repo rule mandates it

Bots often phrase a finding as "minor / non-blocking" while the repo's `AGENTS.md`/`CLAUDE.md` actually requires it in the same PR. Classic: a PR adds a new eval check or pipeline step, the reviewer says "minor: also add it to the doc table," and `AGENTS.md` carries an explicit rule like "When any PR changes the eval suite, update the doc index in the same PR." That makes it a same-PR fix, not a follow-up. Before deferring any doc/table/registry-currency nit, grep the repo rules for a same-PR-update mandate (`grep -ni "same PR\|update.*table\|keep.*doc.*current\|in the same PR" AGENTS.md CLAUDE.md`). If a rule applies, make the one-line fix on the current PR, verify with the repo's doc-consistency script if it has one, and push — do not open a follow-up PR for something the repo says must ship together.

## Where to branch

- Source PR still open: branch from the source PR branch and open a stacked follow-up PR with `--base <source-pr-branch>`. This keeps the source PR unchanged while tracking the cleanup.
- Source PR already merged: branch from the updated default branch and open the follow-up PR against default.

Never push deferable cleanup onto the current PR branch unless the user explicitly asked to fix the current PR instead.

## Follow-up PR body

Include:

- `Follow-up to #<source PR>`
- Original reviewer/comment link or quoted finding
- What this PR changes
- Why it was safe not to block the source PR: no correctness risk, no failing test, no deploy/API/security risk
- Verification run

## Thread reply

After creating the follow-up PR, reply to the original thread:

`Deferred to follow-up PR #<n>: <one-line summary>. This is non-blocking for the current PR because <reason>.`

Resolve bot threads after linking the follow-up PR. For human threads, resolve only if the reviewer clearly framed it as non-blocking (`nit`, `optional`, `follow-up`, approval/praise) or the user explicitly told you to resolve it.

## Re-verify an open follow-up PR before declaring it ready — a sibling may have made it redundant

When multiple agents babysit the same source PR in parallel, one of them may land the *same* deferred fixes directly on the source/base branch while your follow-up PR sits open. Your follow-up then becomes a full no-op against its base, but `gh pr diff` still shows a non-empty diff because the follow-up branched *before* the sibling's commit landed — the apparent diff is just your branch being behind base, not unique work.

Before reporting a follow-up PR as ready, confirm it still carries unique change:
1. `git fetch origin <base-branch>` and check whether the base already contains the fix: `git show origin/<base-branch>:path/to/file | grep '<the token your follow-up adds>'`. If the base already has it, the follow-up is redundant.
2. Also `git log --oneline <your-follow-up-base-sha>..origin/<base-branch>` to see what siblings pushed since you branched, and `git show <sibling-sha> --stat` to see if it touched your files.
3. If redundant, **close the follow-up PR with an explanation** (`gh pr close <n> --comment "Closing as redundant — <fix> already landed on <base> via <sibling-sha>, which addressed all the deferred items at once. No unique change remains."`) and re-point the original review thread reply at the sibling's commit instead of your closed PR.

Do not merge or leave open a follow-up PR whose entire content already exists on its base. Verify uniqueness, don't assume the diff view means real work remains.

## Reporting

Final status should say one of:

- `Ready`: no blocking issues, no deferable comments remain.
- `Ready with follow-ups opened`: no blocking issues, follow-up PRs opened and linked.
- `Blocked`: blocking issue or human-intent question remains.

Never report `ready with follow-ups recommended`. The PR either exists or it does not.
