# 2026-05 DB pool exhaustion catch-all fixes

Session learning from the Bloom Sentry cron run on 2026-05-10.

## Sentry/MCP quirks

- `mcporter call sentry.get_issue_details` worked reliably with Sentry short IDs like `INVEST-5V0`.
- Passing numeric issue IDs caused validation errors in this environment because `issueId` expected a string and the CLI parsed unquoted digits as numbers.
- `sentry.get_latest_event` was not exposed by the configured MCP server even though the old skill mentioned it. Fallback worked:
  ```bash
  sentry issue events INVEST-5V0 --json > /tmp/sentry_cli_events/INVEST-5V0.json
  ```

## Pattern fixed

Several Bloom paths already had shared connection-pool middleware, but catch-all handlers still bypassed it and explicitly created Sentry events:

- `bloom_backend/views/investments.py` decorators `handle_investment_errors` and `handle_investment_errors_async`
- `bloom_backend/views/user_subscription.py` catch-all in `register_user_subscription`
- `bloom_backend/dbos_config.py` startup logging for DBOS/SQLAlchemy connection exhaustion

Good fix shape:

1. Keep the existing middleware helper for Django `OperationalError`.
2. Add a type-agnostic helper for DBOS/SQLAlchemy exceptions whose text or SQLSTATE indicates pool exhaustion.
3. Add a shared response helper returning JSON 503 with `Retry-After: 5`.
4. In catch-all handlers, detect pool exhaustion before `capture_exception` and return the shared 503.
5. In DBOS init, log pool exhaustion at warning without `exc_info`; keep `logger.error(..., exc_info=True)` for unexpected failures.

## Test pitfalls

Importing `bloom_backend.views` can transitively import `backtest`, `bt`, and `matplotlib`. In the same pytest process this produced:

```text
ImportError: generic_type: type "_InterpolationType" is already registered!
```

Safer approaches:

- Reuse `sys.modules["bloom_backend.views.investments"]` if a prior import already loaded it.
- Use `importlib.import_module("bloom_backend.views.investments")` only when it will not re-execute package-level heavy imports.
- For simple leaf modules like `views/user_subscription.py`, `importlib.util.spec_from_file_location` can load the file directly for isolated unit tests.

## PR result

PR #1659 covered `INVEST-5QD`, `INVEST-5QG`, `INVEST-5V1`, and `INVEST-5QK`. CI and Claude review passed.
