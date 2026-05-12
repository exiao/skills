# Alternate GitHub Accounts (SSH Alias + Fine-Grained PAT)

Some repos use a different GitHub account than the default. Pattern discovered during CPE Research Agent PR babysitting (May 2026).

## Setup

The repo uses a custom SSH alias in ~/.ssh/config pointing to a different key.
Remote configured with alias: git@github-charles:cpe-research/avgo.git
Fine-grained PAT stored in .env as CPE_GITHUB_TOKEN.

## Usage

gh CLI needs GH_TOKEN set:
  source ~/.hermes/.env
  GH_TOKEN=$CPE_GITHUB_TOKEN gh pr view 1 --repo cpe-research/avgo

git push uses SSH alias (no PAT needed):
  git push origin evals

## Gotchas

- Fine-grained PATs may lack `checks:read`. `gh pr checks` fails with 403. Use `gh run list --branch $BRANCH` instead to poll CI status:
  ```bash
  gh run list --repo $REPO --branch "$BRANCH" --limit 5 --json name,status,conclusion \
    --jq '.[] | "\(.name)\t\(.status)\t\(.conclusion)"'
  ```
- `gh pr view --json statusCheckRollup` also fails with the same 403. Use `gh pr view --json mergeable,mergeStateStatus,reviewDecision` (drop statusCheckRollup) combined with `gh run list` for CI state.
- `gh api repos/$REPO/commits/$SHA/check-runs` and `repos/$REPO/commits/$SHA/status` also require checks:read — they 403 too. `gh run list` is the only reliable fallback.
- Repo moved warnings appear on every push if repo was renamed. Safe to ignore.
