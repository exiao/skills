# 2026-05-08 Sentry cron lessons

Context: scheduled `fix-sentry-issues` run for Bloom, scanning recent issues and auditing resolved issues.

## Sentry tool quirks

- `mcporter call sentry.get_latest_event` did not exist. Use `sentry issue events <SHORT_ID> --json` instead.
- `sentry issue events --json` returns an object with `.data[]`, not a top-level array.
- `sentry issue list ... --json` can return extremely large payloads because `statusDetails.inCommit.message` and PR bodies are included. Pipe through `jq` immediately to keep only `shortId`, `title`, `statusDetails.inCommit.id`, `statusDetails.inCommit.pullRequest.externalUrl`, metadata, type, and project.

## Resolved issue audit pattern

- Do not trust `statusDetails.inCommit` blindly. An issue can be resolved by an unrelated commit or a large PR whose title has nothing to do with the issue.
- Verify by reading `git show --stat --name-only <commit>` and, when needed, the actual diff.
- Classify unrelated resolving commits as `NOISE_SUPPRESSION / unrelated resolution`, then decide whether the underlying bug is current enough to fix in this run.

## Useful triage examples

- Repeated `OperationalError: remaining connection slots are reserved` across many endpoints usually points to DB pool/capacity/runtime incident, not endpoint-specific code. Skip app-code PR unless a contained leak is visible.
- Firebase Remote Config `remoteconfig/storage-get` on iOS WKWebView is legitimate SDK IndexedDB race noise when frontend `beforeSend` and `ignoreErrors` already filter it.
- External URL fetch 404/410 should be a structured tool miss, not a Sentry error. Treat it like expected fetch noise.
- AlphaVantage exhausted rate limits should log warnings and raise typed errors for callers. Avoid explicit `sentry_sdk.capture_message` for expected provider throttling.

## Testing pitfall

Some Bloom async tests fail locally with `async def functions are not natively supported` if pytest async support is not active in that invocation. For focused noise-classification tests, write synchronous tests that use `asyncio.run(...)` when possible.
