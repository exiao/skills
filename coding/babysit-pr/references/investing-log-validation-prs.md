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

## Existing PR extension pattern

When a scheduled issue-fixer finds new issues in a class already covered by an open PR:

1. Do not open a duplicate PR. Verify the existing PR's files and tests cover the new issue bodies.
2. Update the existing PR body to include every newly covered issue in the `Fixes #...` line.
3. If `gh pr edit --body-file` fails with the Projects classic GraphQL deprecation error (`repository.pullRequest.projectCards`), use the REST pull request update endpoint instead:
   ```bash
   gh auth token > /tmp/gh-token
   python - <<'PY'
   import json, urllib.request
   token = open('/tmp/gh-token').read().strip()
   body = open('/tmp/pr-body.md').read()
   req = urllib.request.Request(
       'https://api.github.com/repos/Bloom-Invest/investing-log/pulls/<PR>',
       data=json.dumps({'body': body}).encode(),
       method='PATCH',
       headers={
           'Authorization': f'Bearer {token}',
           'Accept': 'application/vnd.github+json',
           'X-GitHub-Api-Version': '2022-11-28',
           'Content-Type': 'application/json',
       },
   )
   with urllib.request.urlopen(req, timeout=30) as resp:
       print(resp.status)
   PY
   trash /tmp/gh-token
   ```
   Prefer reading the token at runtime. Never paste tokens into logs or skill text.
4. After body-only edits, re-check `mergeStateStatus`, `reviewDecision`, checks, and unresolved GraphQL review threads. Body edits should not require a new code commit, but they can still change PR metadata.

## Generated research archive PRs

For `reports/generated/**` archive PRs, reviewer bots may catch only a subset of systematic metadata corruption. Before calling the PR clean, run a deterministic archive scan:

```bash
python3 - <<'PY'
import json
from pathlib import Path
bad_symbol = []
action_mismatch = []
for p in Path('reports/generated').glob('**/*.json'):
    data = json.loads(p.read_text())
    if p.name == 'manifest.json':
        continue
    meta = data.get('meta') or {}
    symbol = meta.get('symbol') or data.get('symbol')
    parts = p.stem.split('_')
    filename_symbol = parts[1] if len(parts) >= 3 else None
    filename_action = parts[-1] if parts else None
    action = (data.get('thesis') or {}).get('action')
    # 10POSITION_PORTFOLIO is a special archive file, not a ticker report.
    if filename_symbol and symbol and symbol != filename_symbol and '10POSITION_PORTFOLIO' not in p.name:
        bad_symbol.append((str(p), symbol, filename_symbol))
    if filename_action in {'BUY', 'HOLD', 'SELL', 'WAIT'} and action and action != filename_action:
        action_mismatch.append((str(p), action, filename_action))
print('bad_symbol_vs_filename', len(bad_symbol), bad_symbol[:10])
print('thesis_action_mismatch_vs_filename', len(action_mismatch), action_mismatch[:10])
PY
```

If a single report has a clear filename-derived symbol mismatch, fix the report and matching `reports/generated/manifest.json` entry in one small commit. Example: `claude/2026-03-16_TMUS_SELL.json` had `meta.symbol: "SELL"` and manifest symbol `SELL`; the safe fix was `TMUS` plus a company name derived from the report prose. Do not try to auto-fix hundreds of one-character `company_name` values during cron babysitting unless there is a deterministic source of truth for every ticker; report that as a broader data-quality follow-up.

## Verification notes

- Run focused guard tests first, then the repo's DST suite.
- In Hermes shared venvs, `python -m pip install -r requirements-test.txt` may fail with `No module named pip`; direct `pytest` can still pass if deps are already installed. Report this as an environment limitation, not a code failure.
- If `pytest --timeout=60` is unavailable locally because `pytest-timeout` is missing, rerun without the flag and rely on CI for the exact plugin set.
