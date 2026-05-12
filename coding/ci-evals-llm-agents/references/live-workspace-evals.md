# Running Regression Evals Against Live Agent Output

When an agent produces workspace output (files on disk), point regression evals at the output directory rather than requiring CI-generated fixtures.

## Usage

```bash
# Auto-detect latest workspace
pytest evals/regression/ -v

# Point at specific workspace
pytest evals/regression/ -v --workspace ~/workspace/AVGO_2026-05-11
```

## conftest.py Pattern

```python
def find_latest_workspace(ticker=None, base="workspace"):
    base_path = Path(base)
    if not base_path.exists():
        return None
    dirs = sorted(base_path.iterdir(), key=lambda d: d.name, reverse=True)
    for d in dirs:
        if ticker and not d.name.startswith(ticker):
            continue
        if d.is_dir():
            return d
    return None

@pytest.fixture
def workspace_path(request):
    ws = request.config.getoption("--workspace", default=None)
    if ws:
        return Path(ws)
    path = find_latest_workspace()
    if not path:
        pytest.skip("No workspace found. Run the agent first or pass --workspace.")
    return path
```

This lets the same eval suite run in CI (pre-generated artifacts), locally (fresh agent output), and gracefully skip when no workspace exists.

## Pitfall: URL Resolution Tests

Tests verifying cited URLs return HTTP 200 fail on rate-limited (429) and bot-blocking (403) sites. Options: allow 4xx, mark as `@pytest.mark.flaky`, or only fail on 5xx/connection errors.

## Reference: CPE Research (cpe-research/avgo)

Working implementation: `evals/conftest.py` (workspace auto-detect + --workspace arg), `evals/regression/test_format.py` (memo structure), `evals/regression/test_citations.py` (URL resolution), `evals/regression/test_tool_usage.py` (raw JSON validity). First live run: 19/21 passed.
