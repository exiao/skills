---
name: babysit-open-prs
description: "Scan all open PRs across tracked repos, triage them, check for scope drift, and spawn babysit-pr sub-agents for fixable ones. Use when: babysit all PRs, check all open PRs, nightly PR review."
---

# Babysit Open PRs

Scan open PRs across tracked repos, triage each one (scope check + CI + reviews), and spawn `babysit-pr` sub-agents for PRs that need fixing. Report results.

## Step 1: Preflight

Run the preflight script to discover PRs that need attention:

```bash
bash ~/clawd/scripts/pr-preflight.sh
```

This scans bloom-invest/bloom, bloom-invest/investing-log, exiao/skills, plus other repos under bloom-invest, prompt-pm, and exiao orgs with open PRs by exiao. It handles skip state and deduplication.

If no output: no PRs need attention. Reply NO_REPLY.

## Step 2: Triage (do this yourself, do NOT spawn sub-agents yet)

For each PR in the preflight output, gather context:

```bash
# CI and merge status
gh pr view <number> --repo <repo> --json title,body,statusCheckRollup,reviewDecision,headRefName,mergeable,commits

# Check results
gh pr checks <number> --repo <repo>

# Commit count
gh api "repos/<repo>/pulls/<number>/commits?per_page=100" --jq 'length'

# Changed files (for scope check)
gh pr diff <number> --repo <repo> --stat
```

### Scope Check (per PR)

Compare the changed files and commit messages against the PR title and description:

1. Do the files relate to the PR's stated purpose?
2. Are there commits that introduce unrelated work?
3. Is there bulk formatting noise beyond the PR's actual changes?
4. Are multiple distinct features bundled together?

### Classify each PR:

- **CLEAN**: CI green, no unaddressed comments, scope is tight. No sub-agent needed.
- **FIXABLE**: CI failure with identifiable root cause, or unaddressed review comments pointing to real bugs, or merge conflicts with clear resolution. Scope is acceptable. Spawn a sub-agent.
- **SCOPE_DRIFT**: PR includes changes that don't match its description. Commits touch unrelated files, bundle multiple features, or include unnecessary formatting noise. Do NOT spawn a sub-agent. Report what's wrong and recommend how to fix (split PRs, revert commits, etc.).
- **SKIP**: Merge conflicts needing design decisions, architectural issues, or draft/WIP PRs. Note for the report but do NOT spawn a sub-agent.

## Step 3: Spawn sub-agents for FIXABLE PRs only

For each fixable PR (max 5), spawn a sub-agent using the babysit-pr skill:

```
sessions_spawn({
  task: "Use the babysit-pr skill. PR #<number>, repo <repo>. Max cycles: 5. Reasons flagged: <reasons>. Running via nightly cron (use pr-mark-skip.sh if escalating). Read the repo's CLAUDE.md/AGENTS.md first.",
  cwd: "<local-path>",
  runTimeoutSeconds: 1800
})
```

Local paths:
- bloom-invest/bloom → ~/bloom
- bloom-invest/investing-log → ~/agentd/investing-log
- exiao/skills → ~/clawd/skills
- Fintary/ops-center → ~/fintary/ops-center
- Other repos → check ~/clawd/<repo> or ~/<repo>, clone to /tmp/<repo> if not found

Wait for all sub-agents to complete.

## Step 4: Report

Do NOT send via the message tool. Output the summary as your reply. Cron delivery handles routing.

**Format:**

```
🔧 Nightly PR Babysit — [date]

[For each PR, one of:]

✅ PR #N (repo): title — clean
🔧 PR #N (repo): title — fixed (what was done)
⚠️ PR #N (repo): title — scope drift
   Description says: X
   Actually includes: Y, Z
   Recommendation: split/revert/remove
🚫 PR #N (repo): title — blocked (why)
⏭️ PR #N (repo): title — skipped (why)
```

If all PRs were already clean, keep it brief.

## Gotchas

- **Scope check is mandatory.** Every PR gets checked for drift, even if CI is green. A green CI on a bloated PR is still a problem.
- **Don't fix scope drift.** Splitting PRs, reverting commits, or removing files from a PR requires human judgment on what belongs where. Always escalate.
- **Max 5 sub-agents.** If more than 5 PRs are fixable, prioritize by: CI failures first, then review comments, then oldest.
- **Preflight script handles skip state.** If a PR was previously marked as skip (via pr-mark-skip.sh), it won't appear in the preflight output.
- **Sub-agents run babysit-pr which includes its own scope check.** The triage-level scope check here is a quick pass; babysit-pr does a deeper per-commit analysis.
