# 2026-05-11 Optional Refresh DB Pool Exhaustion Pattern

Session outcome: PR #1666 fixed INVEST-5V8 plus related INVEST-5V7, INVEST-5V6, INVEST-5V5, INVEST-5VA, and INVEST-5V9.

## Symptom

Django/Huey optional investment refresh paths raised PostgreSQL pool exhaustion errors:

```text
OperationalError: connection to server at "localhost" (::1), port 5432 failed: FATAL: remaining connection slots are reserved for non-replication superuser connections
```

These appeared in `update_symbol_data_in_background` / `build_basic_investment_info` optional refresh work. Retrying via Huey just adds pressure to an already exhausted DB pool.

## Fix pattern

For optional background refreshes, handle pool exhaustion as graceful degradation:

1. Detect pool exhaustion with a narrow helper, e.g. string-match `OperationalError` for `remaining connection slots are reserved`.
2. In each catch site that can observe this error, call `close_old_connections()` immediately.
3. Log at warning level with lazy interpolation, not f-strings:
   ```python
   logger.warning(
       "Skipping optional investment refresh for %s because database connection pool is exhausted: %s",
       symbol,
       exc,
   )
   ```
4. Return without re-raising for optional refresh work so Huey does not retry into pool pressure.
5. Let non-pool-exhaustion exceptions keep their existing behavior.

## Places that needed coverage in this run

- Inner async/thread caller path in `build_basic_investment_info`
- Post-thread-join error handling path
- Outer Huey task-level exception path in `update_symbol_data_in_background`

## Tests that caught regressions

- Focused sync tests are enough. Avoid fighting async pytest plugin config when unrelated async-test setup fails.
- Assert `close_old_connections()` is called in pool exhaustion paths.
- Assert warnings use lazy interpolation arguments. Existing tests may need updates if they asserted f-string-rendered log text.

## Review notes

Claude review approved this pattern because it avoids double-reporting and prevents unnecessary Huey retries for optional work. Gemini flagged lazy logging interpolation, so keep logger calls in `%s` style for Sentry grouping and performance.
