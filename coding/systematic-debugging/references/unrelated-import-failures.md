# Unrelated import failures in tests

Use this when a focused test fails before exercising the code under test because an unrelated dependency gets imported.

## Pattern

A test for module A fails while importing module B/C/D, often through a package `__init__.py` barrel import. The deep error can look like an environment issue, e.g. a native dependency conflict (`matplotlib`, `bt`, `ffn`, pandas, torch), but the actionable bug may be the import graph.

## What to do

1. Read the full traceback from the test setup/import error.
2. Trace each import hop until you find the first broad or unnecessary import.
   - Example chain: `test imports bloom_backend.views.bloombot_v2_api` → Python loads `bloom_backend.views.__init__` → `__init__` imports backtest/correlation/agent modules → those import `bt` / `ffn` / `matplotlib`.
3. Ask: should this package/module import that dependency at import time?
4. Prefer shrinking the import surface over pinning or blaming the dependency.
   - Remove heavy modules from package barrel files when callers already import them directly.
   - Move heavy imports inside the functions/routes that need them if direct removal is unsafe.
5. Re-run the focused tests after the import graph change.
6. Only call it an environment blocker if the target module imports the dependency legitimately and the dependency itself is broken.

## Reporting rule

Do not summarize this as "tests blocked by unrelated dependency" until you have traced why that dependency entered the import graph. Say what imported it and whether you fixed or intentionally left that coupling.
