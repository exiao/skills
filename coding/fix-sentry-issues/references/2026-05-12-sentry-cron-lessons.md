# 2026-05-12 Sentry cron lessons

Context: scheduled Bloom Sentry fixer scanned the 10 most recent backend issues using only the official Sentry CLI, audited recently resolved issues, wrote a plan, and opened PR #1667.

## Open PR dedupe matters before fixing

The required pre-scan PR checks prevented duplicate work:

```bash
gh pr list --state open --search "sentry" --json number,title,headRefName,url
gh pr list --state open --search "fix:" --json number,title,headRefName,url
```

Findings in this run:
- PR #1666 already covered the optional refresh PostgreSQL pool-exhaustion family: INVEST-5V8, INVEST-5V7, INVEST-5VA, INVEST-5V9, plus siblings INVEST-5V5/5V6.
- PR #1662 was already merged and covered stale closed-connection issues: INVEST-5JS, INVEST-5JD, INVEST-5JC, INVEST-5N8, INVEST-5KV.

When an issue is still unresolved in Sentry but the fix has merged recently, skip creating a duplicate PR and call out that it needs post-deploy monitoring.

## CLI list counts can be null, view has real counts

`issue list --json` compact output showed `count` and `userCount` as null for the top 10, but `sentry issue view <id> --json` returned useful counts such as INVEST-5JS `count: "1089"` and `userCount: 0`.

Use `issue view` as the authoritative count source in the plan when list output is sparse.

## Missing auth headers on public server-to-server endpoints

INVEST-5VB was a single warning from `/api/bloombot/v2/check-access/` where a `curl` request omitted `Authorization`:

- title: `BloomBot auth failed: has_bearer_prefix=False, header_empty=True`
- helper: `bloom_backend/services/bloombot_secret_auth.py::verify_bloombot_secret`
- previous behavior: every auth mismatch called `sentry_sdk.capture_message(..., level="warning")`

Treat missing `Authorization` on public endpoints as legitimate internet noise if the endpoint still returns 401. The contained fix is:

```python
if auth_header:
    sentry_sdk.capture_message(
        f"BloomBot auth failed: has_bearer_prefix={has_bearer}, "
        "header_empty=False",
        level="warning",
    )
else:
    logger.info("BloomBot auth failed: missing Authorization header")
```

Keep Sentry reporting for non-empty wrong or malformed bearer tokens because those can indicate a real integration/config mismatch. Do not suppress server misconfiguration messages like a missing shared secret.

Focused tests used:

```bash
uv run black bloom_backend/services/bloombot_secret_auth.py bloom_backend/tests/services/test_bloombot_secret_auth.py
uv run python -m pytest -n0 bloom_backend/tests/services/test_bloombot_secret_auth.py -q
uv run python -m compileall -q bloom_backend/services/bloombot_secret_auth.py bloom_backend/tests/services/test_bloombot_secret_auth.py
```

## Resolved issue audit: compact commit extraction

Raw `statusDetails.inCommit` can contain huge commit and PR bodies. Extract only these fields first:

```bash
jq -r '.data[] | [
  .shortId,
  .title,
  .status,
  ((.statusDetails.inCommit.id // "")|tostring),
  ((.statusDetails.inCommit.pullRequest.externalUrl // .statusDetails.inCommit.pullRequest.id // "")|tostring),
  (.metadata.filename // ""),
  (.metadata.function // "")
] | @tsv' /tmp/sentry_resolved_compact.json
```

Then inspect only the relevant PR diff or commit stat:

```bash
gh pr diff <pr-number> --repo Bloom-Invest/bloom > /tmp/sentry_resolved_diffs/pr-<pr-number>.diff
git show --stat --oneline <commit>
```

Some Sentry resolving commits still point at unrelated releases or merge commits. Classify these as unrelated/noise-only, but only create a new fix if the issue is hot in the current scan and has a traceable app-code root cause.
