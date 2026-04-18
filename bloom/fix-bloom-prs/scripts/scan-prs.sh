#!/bin/bash
# fix-bloom-prs: Scan open Bloom PRs for CI failures and review comments
# Usage: fix-bloom-prs [--json]
#
# Shows open PRs with:
#   - Failing CI checks
#   - Unresolved review comments (from Cursor Bugbot, Seer, Claude, etc.)
#   - Actionable feedback

REPO="Bloom-Invest/bloom"
JSON_MODE="${1:-}"

# Get all open PRs with their check status and reviews
data=$(gh pr list --repo "$REPO" --state open --json number,title,headRefName,statusCheckRollup,reviews,comments --limit 30 2>/dev/null)

if [ -z "$data" ]; then
  echo "Error: Could not fetch PRs from $REPO"
  exit 1
fi

if [ "$JSON_MODE" = "--json" ]; then
  echo "$data" | jq '[.[] | {
    number,
    title,
    branch: .headRefName,
    failing_checks: [.statusCheckRollup[] | select(.conclusion == "FAILURE") | .name],
    review_comments: [.reviews[] | select(.body != "" and .state == "COMMENTED") | {author: .author.login, body: .body[0:200]}],
    needs_attention: (([.statusCheckRollup[] | select(.conclusion == "FAILURE")] | length) > 0 or ([.reviews[] | select(.state == "CHANGES_REQUESTED")] | length) > 0)
  } | select(.failing_checks | length > 0 or .review_comments | length > 0)]'
  exit 0
fi

# Human-readable output
echo "=== Open Bloom PRs needing attention ==="
echo ""

echo "$data" | jq -r '.[] | select(
  ([.statusCheckRollup[] | select(.conclusion == "FAILURE")] | length) > 0 or
  ([.reviews[] | select(.body != "")] | length) > 0
) | "PR #\(.number): \(.title)\n  Branch: \(.headRefName)\n  Failing: \([.statusCheckRollup[] | select(.conclusion == "FAILURE") | .name] | join(", "))\n  Reviews: \([.reviews[] | select(.body != "") | .author.login] | unique | join(", "))\n"'

echo "Run 'gh api repos/$REPO/pulls/{PR_NUMBER}/comments | jq' for review details"
