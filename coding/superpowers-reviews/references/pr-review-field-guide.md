# PR Review Field Guide

Reusable checklist distilled from reviewing Hermes Agent PR #14.

## Scope
Use for small-to-medium PR reviews where the user asks for correctness, minimality, tests, regressions, or an independent subagent-style review.

## Checklist
1. Identify the base and head with `gh pr view <num> --json baseRefName,headRefName,baseRefOid,headRefOid,state,url,title`.
2. Check all review channels, not just formal review bodies:
   - Formal reviews: `gh pr view <num> --json reviews`
   - Inline PR comments: `gh api repos/<owner>/<repo>/pulls/<num>/comments`
   - Issue comments: `gh api repos/<owner>/<repo>/issues/<num>/comments`
3. Inspect the actual diff against the PR base, not local assumptions:
   - `git diff --stat origin/<base>...HEAD`
   - `git diff --unified=80 origin/<base>...HEAD -- <files>`
4. Read changed code with line numbers around each proposed finding.
5. Reproduce reviewer claims when feasible with tiny probes. Example patterns:
   - Numeric parser accepts `NaN`: run a one-off Python snippet and verify `math.isfinite` behavior.
   - URL normalization claim: call the helper with mixed-case input and observe output.
6. Run targeted tests and `git diff --check`. Do not claim approval without fresh output.
7. Final report should be concise: approval status, findings by severity, exact file:line references, verification commands and results.

## Review standards
- Do not merge, push, rewrite, or clean worktrees during review unless explicitly asked.
- Treat automated reviewer comments as leads, not truth. Verify each one against code and tests.
- Prefer actionable findings. If a concern is only theoretical and low-impact, mark it Low or omit it.
- Include “I approve” only when no blocking or meaningful medium issues remain.