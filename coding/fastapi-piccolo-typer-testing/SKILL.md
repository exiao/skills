---
name: fastapi-piccolo-typer-testing
category: coding
description: Patterns for writing fast, DB-free pytest suites against FastAPI routers, Piccolo ORM queries, Typer CLI commands, and service-layer code. Use when adding test coverage to a FastAPI + Piccolo + Typer app, mocking async ORM query chains, or testing Typer commands that lazily import services. Proven at scale — grew a real-world suite from 270 → 442 passing tests in under 4 seconds.
---

# FastAPI + Piccolo + Typer Testing Patterns

Fast, DB-free, no-network test patterns. Target: entire suite runs in seconds.

## Core Principles

1. **Separate test files** — use `*_extended.py` or `test_<area>_*.py` naming per coverage area; don't bloat existing files.
2. **Scenario/Given/When/Then docstrings** on each test.
3. **AsyncMock + `@patch` decorators** — avoid fixtures when a patch at function scope is clearer.
4. **No DB, no network** — mock ORM query chains and service-layer calls.
5. **One patch-target discovery pass per router** — router files import services with varying aliases (`svc`, `ingest`, `pay`, `calculate`, `reconcile`), so `grep "from app.services" app/api/*.py` before writing patches.

## Pattern: FastAPI router with auth overrides

```python
import pytest
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock, patch
from app.main import app
from app.auth import get_current_user, get_manager_user

FAKE_USER = {"id": str(uuid4()), "email": "t@t.com", "role": "manager"}  # id MUST be str

@pytest.fixture
def client():
    app.dependency_overrides[get_current_user] = lambda: FAKE_USER
    app.dependency_overrides[get_manager_user] = lambda: FAKE_USER
    transport = ASGITransport(app=app)
    yield AsyncClient(transport=transport, base_url="http://test")
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_list_carriers_happy_path(client):
    """Scenario: authed manager lists carriers
    Given a mocked service returning 2 carriers
    When GET /api/carriers
    Then 200 + 2-item JSON array"""
    with patch("app.api.carriers.svc.list_carriers", new=AsyncMock(return_value=[{"id": 1}, {"id": 2}])):
        async with client as c:
            r = await c.get("/api/carriers")
    assert r.status_code == 200
    assert len(r.json()) == 2
```

## Pattern: Piccolo fluent query chain mock

Piccolo's builder is `Table.select().where(...).order_by(...).run()`. AsyncMock alone breaks on chained calls — use a self-referencing MagicMock:

```python
from unittest.mock import MagicMock, AsyncMock, patch

# Chain where().order_by().run() all resolve
chain = MagicMock()
chain.where.return_value = chain          # self-reference so .where(...).where(...) works
chain.order_by.return_value.run = AsyncMock(return_value=[{"id": 1}])

with patch("app.api.policies.Policy") as MockPolicy:
    MockPolicy.select.return_value = chain
    # now code `Policy.select().where(...).order_by(...).run()` returns [{"id": 1}]
```

Simple single-row variant:

```python
MockTable.select.return_value.where.return_value.first.return_value.run = AsyncMock(return_value={"id": 1})
```

## Pattern: Typer CLI with lazy service imports

Many CLI commands do `from app.services import X` **inside** the function body (delaying DB setup). Patching `app.cli.ingest.X` fails because the name doesn't exist at module scope.

**Fix:** pre-import all services at the top of the test module so `app.services.X` is loadable, then patch at the service-module level:

```python
# tests/test_cli_commands.py
import app.services.ingest       # noqa: F401 — force import so patch target resolves
import app.services.calculate    # noqa: F401
import app.services.pay          # noqa: F401
import app.services.reconcile    # noqa: F401

from typer.testing import CliRunner
from unittest.mock import patch, AsyncMock
from app.cli.main import app as cli

runner = CliRunner()

def test_ingest_run():
    """Scenario: ingest CLI parses args and delegates to service"""
    with patch("app.services.ingest.run_ingestion", new=AsyncMock(return_value={"ok": True})):
        result = runner.invoke(cli, ["ingest", "run", "--file", "a.pdf"])
    assert result.exit_code == 0
```

## Pattern: Piccolo model validation (no DB)

Enum/column/default introspection runs entirely in-process:

```python
def test_carrier_has_name_column():
    from app.models.tables import Carrier
    cols = {c._meta.name for c in Carrier._meta.columns}
    assert "name" in cols

def test_policy_status_default():
    from app.models.tables import Policy
    col = next(c for c in Policy._meta.columns if c._meta.name == "status")
    assert col._meta.params["default"] == "active"  # NOT col._meta.default
```

Parametrize across tables for bulk coverage:

```python
@pytest.mark.parametrize("table_name,expected", [
    ("Carrier", "carrier"), ("Agent", "agent"), ...
])
def test_tablename(table_name, expected):
    from app.models import tables
    cls = getattr(tables, table_name)
    assert cls._meta.tablename == expected
```

## Patch-target cheatsheet (per-project; discover with grep)

- API routers: find `from app.services.X import Y as alias` — patch target is `app.api.<router>.<alias>.<method>`
- CLI commands with lazy imports: patch `app.services.<svc>.<method>`, pre-import module
- Page data helpers: usually patch `app.page_data.<TableName>` directly (ORM imports at top)
- ORM models: no patching — pure introspection

## Debugging loop

```bash
uv run pytest tests/test_foo.py --tb=line -q | tail -60
```

Short traceback shows which chain call returned a MagicMock instead of a coroutine. Most failures trace to:
1. Wrong patch target (service aliased differently in router)
2. Query chain not self-referencing (`chain.where.return_value = chain` missing)
3. `id` field is raw `UUID` not `str(uuid4())` → JSON serialization error
4. Wrong method name (e.g. `get_levels` vs `get_all_levels`) — grep the service file

## Verification command pattern

```bash
# fast full suite, excluding UI tests that need a browser
uv run pytest tests/ --ignore=tests/test_pages.py -q

# per-file with short tb
uv run pytest tests/test_api_extended.py --tb=short -q
```

## Commit rhythm

One commit per coverage area (API / CLI / page_data / models) with bullet-point body listing routers or modules touched. Conventional format: `test: <area> coverage (+N tests)`.
