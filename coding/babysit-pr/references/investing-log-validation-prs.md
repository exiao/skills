# investing-log validation PR patterns

Use this when babysitting or issue-fixing PRs in `Bloom-Invest/investing-log`, especially cron prompts that say to diagnose open validation failures and open PRs.

## Deduplicate before creating a PR

1. List open issues and open PRs first:
   ```bash
   gh issue list --repo Bloom-Invest/investing-log --state open --limit 20 --json number,title,labels,body,createdAt
   gh pr list --repo Bloom-Invest/investing-log --state open --json number,title,headRefName,body,url
   ```
2. Group issues by root cause, not by issue number. Common buckets:
   - BUY price hallucinations or `$0` prices
   - broken-chart BUYs missing Working Chart validation
   - false NOACTION trades that claim missing same-day research
   - sector snapshots with wrong-direction 1-month performance
3. If an open PR already fixes most of the class, extend that PR instead of opening a duplicate. Update its PR body with every issue number it now fixes.

## Sector snapshot validation fix pattern

For wrong-direction sector data in `research/<model>/<date>_sector_snapshot.json`:

- Root cause is usually prompt-only synthesis: workflow pulls `/tmp/pipeline/macro/sectors-1m.json`, but no deterministic gate compares the model's JSON back to Bloom before commit.
- Add a `sector` mode to `scripts/validate_outputs.sh` that reads the sector snapshot and a `SECTOR_REFERENCE_FILE` (default `/tmp/pipeline/macro/sectors-1m.json`).
- Fail when a sector's `1m_performance` has the wrong sign, differs by more than 1 percentage point, is missing, or favor/avoid lists contradict verdicts.
- Add a workflow step in `.github/workflows/sector_multi.yml` after the agent writes the snapshot and before git staging/commit:
  ```yaml
  - name: Validate sector snapshot
    run: bash scripts/validate_outputs.sh sector ${{ matrix.model_name }}
    env:
      SECTOR_REFERENCE_FILE: /tmp/pipeline/macro/sectors-1m.json
  ```
- If the Deep Agents wrapper has write middleware, add the same check there so bad snapshots are blocked at write time as well as pre-commit.

## Verification notes

- Run focused guard tests first, then the repo's DST suite.
- In Hermes shared venvs, `python -m pip install -r requirements-test.txt` may fail with `No module named pip`; direct `pytest` can still pass if deps are already installed. Report this as an environment limitation, not a code failure.
- If `pytest --timeout=60` is unavailable locally because `pytest-timeout` is missing, rerun without the flag and rely on CI for the exact plugin set.
