# 2026-05 crypto DB pool Sentry noise

Session detail from PR #1660 (`fix/sentry-INVEST-5KN`).

## Symptom

`INVEST-5KN` reported:

```text
Error updating crypto price for BTC-USD: connection failed: FATAL: remaining connection slots are reserved for roles with the SUPERUSER attribute
```

The failing code path was `bloom_backend/investment_utils.py::fetch_and_save_crypto_prices()`. The per-symbol loop already degrades by skipping the symbol and continuing, but it logged every exception with `logger.error(...)`. Sentry's logging integration turned the transient DB pool exhaustion into an issue.

## Fix pattern

Reuse the shared pool exhaustion detector and downgrade only expected pool exhaustion:

```python
from bloom_backend.middleware.connection_pool import _is_connection_pool_exhaustion

try:
    ...
except Exception as e:
    if _is_connection_pool_exhaustion(e):
        logger.warning(
            "Skipping crypto price update for %s because PostgreSQL "
            "connection pool is exhausted: %s",
            symbol,
            e,
        )
    else:
        logger.error(f"Error updating crypto price for {symbol}: {e}")
    error_count += 1
    continue
```

Why: expected transient pool exhaustion should remain visible in logs, but not create Sentry error events. Unexpected crypto update failures still log as errors.

## Test pattern

`caplog` can be unreliable in the full xdist backend suite for this path. Mock the module logger directly for deterministic assertions:

```python
with patch("bloom_backend.investment_utils.logger") as mock_logger:
    fetch_and_save_crypto_prices(["SOL-USD"])

mock_logger.warning.assert_any_call(...)
assert not any(
    call_args.args and "Error updating crypto price for SOL-USD" in call_args.args[0]
    for call_args in mock_logger.error.call_args_list
)
```

Local targeted test passed before push, but CI fast suite initially failed when using `caplog.text == ''`. The logger mock version passed locally and in CI.

## Verification used

- `uv run black bloom_backend/investment_utils.py bloom_backend/tests/test_investment_utils.py`
- `uv run python -m pytest -n0 bloom_backend/tests/test_investment_utils.py::TestFetchAndSaveCryptoPrices::test_pool_exhaustion_logs_warning_not_error -q`
- `uv run python -m pytest -n0 bloom_backend/tests/test_investment_utils.py::TestFetchAndSaveCryptoPrices -q`
- `uv run python -m compileall bloom_backend/investment_utils.py`
- `gh pr checks <PR> --watch --interval 10`
- `gh pr view <PR> --json reviews`
- `gh api repos/<repo>/issues/<PR>/comments`
- `gh api repos/<repo>/pulls/<PR>/comments`
