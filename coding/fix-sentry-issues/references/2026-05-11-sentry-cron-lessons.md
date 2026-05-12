# 2026-05-11 Sentry cron lessons

Context: scheduled Bloom Sentry fixer scanned the 10 most recent backend issues using only the official Sentry CLI, audited resolved issues, wrote a plan, and opened PR #1662.

## Sentry CLI-only workflow

When the run explicitly forbids MCP/mcporter, the official CLI was sufficient:

```bash
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 12h --json > /tmp/sentry_recent.json
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 7d --query 'is:resolved' --json > /tmp/sentry_resolved.json
for id in $(jq -r '.data[].shortId' /tmp/sentry_recent.json); do
  sentry issue view "$id" --json > "/tmp/sentry_details/$id.json"
  sentry issue events "$id" --json > "/tmp/sentry_cli_events/$id.json" || true
done
```

Notes:
- `sentry issue events --json` may include only compact event metadata in `.data[]`; stack entries can be absent. In that case use issue metadata (`metadata.filename`, `metadata.function`, `culprit`, `logger`, counts, first/lastSeen) plus repo code search for root-cause analysis.
- `sentry issue list --json` can print Bun AVX warnings before JSON in this environment. Redirecting to files still produced valid JSON for the actual command output in this run, but be ready to inspect files if parsing fails.

## DB closed-connection issue family

Hot issues INVEST-5JD, INVEST-5JC, INVEST-5JS, INVEST-5KV, INVEST-5N8 were one root-cause family:

- Huey/Django background workers reused PostgreSQL connections after the server closed them.
- Existing retry logic called `close_old_connections()`, but after psycopg raises `OperationalError: the connection is closed`, that can leave the same broken connection object in place.
- The contained root-cause fix is to force-close the specific write connection before retrying, while preserving the guard that avoids touching a caller's active outer transaction.

Pattern used in `bloom_backend/utils.py::bulk_sync`:

```python
def _close_old_connections_if_safe(force_close=False):
    connection = connections[using or DEFAULT_DB_ALIAS]
    if not connection.in_atomic_block:
        if force_close:
            connection.close()
        close_old_connections()

# retry path
_close_old_connections_if_safe(force_close=is_connection_closed)
```

Finance-specific path:
- Call `_close_old_connections_safely()` before `optimized_bulk_sync_finance()` starts `transaction.atomic()`.
- In finance retry loops, `_reset_db_connections_safely()` was already called for `connection is closed`; avoid adding duplicate resets after sleep.
- Refresh connections before EOD market-cap `get_or_create` loops and reset on closed-connection exceptions.

### IMPORTANT: bulk_sync fix alone is not enough (PR #1668, 2026-05-12)

PR #1662 fixed `bulk_sync`'s internal retry path but INVEST-5JD kept firing (10K+ events). Root cause: the **outer** retry loop in `fetch_and_save_bottom_line` (investment_utils.py) still called `close_old_connections()`, which doesn't discard a broken psycopg connection object. When `bulk_sync`'s internal retries exhaust, the error propagates to this outer loop which retries on the same dead connection.

**The real fix** (PR #1668): use `connections.close_all()` instead of `close_old_connections()` in two places:
1. The retry handler in `fetch_and_save_bottom_line` (where OperationalError is caught)
2. The Huey `@db_task` entry point `async_fetch_and_save_bottom_line` so retries start with clean connections

**Why `close_old_connections()` fails here:** it only closes connections past `CONN_MAX_AGE`. A connection that was just used (but is now dead) doesn't meet that criterion, so it stays in the pool. `connections.close_all()` unconditionally drops all connections.

**General rule for Bloom Huey tasks:** when catching `OperationalError("connection is closed")`, always use `connections.close_all()` (not `close_old_connections()`) before retrying. Wrap in try/except to avoid masking the original error:

```python
# CORRECT: force-close dead connections before retry
try:
    connections.close_all()
except Exception:
    pass

# WRONG: leaves broken connection in pool
close_old_connections()
```

## Huey KeyError triage

Issues like INVEST-5GF, INVEST-5MM, INVEST-5KX, INVEST-5V4 showed only Huey internals (`huey/api.py::_execute`) and task-key `KeyError`s after retries. Treat these as symptoms unless the CLI payload exposes app frames:

- If a hot underlying app issue exists for the same task family, fix that root cause instead of patching Huey or suppressing Sentry.
- If no app frame/root cause is visible, skip as unclear rather than making speculative task bookkeeping changes.

## Benzinga interpreter-shutdown noise

INVEST-5MB showed `RuntimeError: cannot schedule new futures after interpreter shutdown` from Benzinga news fetching during worker shutdown. The function already returned `[]`, so the fix was legitimate noise reduction:

```python
except RuntimeError as e:
    if "cannot schedule new futures after interpreter shutdown" in str(e):
        logger.warning("Worker shutdown while fetching news ...")
        return []
```

Add a sync pytest using `asyncio.run(...)` to avoid async pytest plugin issues:

```python
def test_fetch_benzinga_news_treats_interpreter_shutdown_as_warning(monkeypatch, caplog):
    caplog.set_level(logging.WARNING, logger=benzinga.__name__)
    monkeypatch.setattr(benzinga.httpx, "AsyncClient", _ShutdownAsyncClient)
    result = asyncio.run(benzinga._fetch_benzinga_news([...]))
    assert result == []
```

## Testing commands that worked

```bash
uv run black bloom_backend/utils.py bloom_backend/finance_utils.py bloom_backend/externals/benzinga.py bloom_backend/tests/test_finance_utils.py bloom_backend/tests/test_benzinga_shutdown_noise.py
uv run python -m pytest -n0 bloom_backend/tests/test_finance_utils.py::TestOptimizedBulkSyncFinance bloom_backend/tests/test_finance_utils.py::TestSaveFinanceDataWithRetry bloom_backend/tests/test_benzinga_shutdown_noise.py -q
uv run python -m compileall -q bloom_backend/utils.py bloom_backend/finance_utils.py bloom_backend/externals/benzinga.py bloom_backend/tests/test_finance_utils.py bloom_backend/tests/test_benzinga_shutdown_noise.py
```

Black emitted a Python 3.11 vs Python 3.14 parsing warning but completed successfully.

## Resolved issue audit lesson

Resolved issues can point to unrelated commits. In this run:
- INVEST-5N9 resolved by an earnings-calendar PR, but current closed-connection issues were real and hot.
- INVEST-3AD resolved a prior missing-investment bottom-line bug, not the current closed DB connection family.

Classify unrelated resolutions as unrelated/noise-only, but only reopen/fix when the current issue is hot and has a traceable app-code root cause.
