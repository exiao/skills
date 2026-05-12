# CPE Research PAT Quirks

The `CPE_GITHUB_TOKEN` fine-grained PAT for cpe-research repos lacks `checks:read` scope.

## Symptoms
- `gh pr checks $PR --repo cpe-research/avgo` → `GraphQL: Resource not accessible by personal access token`
- `gh pr view --json statusCheckRollup` → same error

## Workaround
```bash
export GH_TOKEN=$(grep CPE_GITHUB_TOKEN ~/.hermes/.env | cut -d= -f2)
gh run list --repo cpe-research/avgo --branch "$BRANCH" --limit 5 --json name,status,conclusion
```

This uses the Actions API (which the PAT can access) instead of the Checks API.

## Claude Code Review infra failures
The claude-review CI job on cpe-research repos sometimes fails with infra errors ("Claude encountered an error") rather than code issues. The error appears as an issue comment, not a review. One rerun usually fixes it:
```bash
gh run rerun $RUN_ID --repo cpe-research/avgo --failed
```
