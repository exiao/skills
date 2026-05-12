# research-cli Reference

**Repo:** `cpe-research/research-cli` (private, GitHub)
**Local:** `~/projects/research-cli`
**Git SSH:** `github-charles` alias (`~/.ssh/id_ed25519_charles`)
**GitHub PAT:** `CPE_GITHUB_TOKEN` in `~/.hermes/.env` (for repo admin via `gh`)
**Stack:** Python 3.10+, Typer, httpx, Rich, diskcache, uv
**FMP Plan:** Ultimate ($99/mo) — all endpoints available

## Installation
```bash
cd ~/projects/research-cli && uv pip install -e .
```

## Sources (4 total, AV dropped May 2026)

| Source | Client | Auth | Notes |
|--------|--------|------|-------|
| FMP | `FMPClient` | `FMP_API_KEY` | Primary. Ultimate plan. All structured data. |
| SEC EDGAR | `EDGARClient` | None (User-Agent header) | Free. Filings, XBRL, EFTS search, 13F holders. See references/sec-edgar-api.md. |
| AlphaSense | `AlphaSenseClient` | OAuth + API key (5 env vars) | Optional. GenSearch. |
| Serper | `SerperClient` | `SERPER_API_KEY` | News supplement. |

## Source Routing

Commands with both FMP and EDGAR sources accept `--source auto|edgar|fmp` (default: `auto`).
Registry at `src/research/sources/registry.py`. All outputs include a `"source"` field.

| Command | Default | Also available |
|---------|---------|----------------|
| `insider` | fmp | edgar (Form 4 via EFTS) |
| `holders` | edgar (13F via EFTS) | fmp (stub) |
| `financials` | fmp (normalized) | edgar (raw XBRL) |
| `info` | fmp (richer) | edgar (submissions) |

## Commands (25 total)

| Command | Source | Description |
|---------|--------|-------------|
| `info TICKER` | FMP | Company profile (beta, range, dividend, market cap) |
| `financials TICKER` | FMP | Income/balance/cashflow. `--type`, `--period`, `--limit` |
| `metrics TICKER` | FMP | ROIC, EV/EBITDA, FCF yield |
| `ratios TICKER` | FMP | Full ratio suite |
| `scores TICKER` | FMP | Altman Z, Piotroski |
| `dcf TICKER` | FMP | Discounted cash flow |
| `enterprise-value TICKER` | FMP | Historical EV |
| `earnings TICKER` | FMP | EPS actual vs estimate, revenue actual vs estimate |
| `transcript TICKER` | FMP | Earnings call transcript. `--quarter 2025-Q1` |
| `ratings TICKER` | FMP | Grades + estimates + price target consensus/summary |
| `insider TICKER` | FMP/EDGAR | SEC Form 4 insider trades. `--source edgar` for EFTS-based. |
| `holders TICKER` | EDGAR | 13F institutional holders via EFTS search. `--source fmp` for FMP fallback. |
| `peers TICKER` | FMP | Peer companies |
| `quote TICKER` | FMP | Real-time quote (5min cache) |
| `price-history TICKER` | FMP | Historical EOD. `--days 365` |
| `compare T1 T2 T3` | FMP | Side-by-side profiles (parallel fetch) |
| `screen FILTERS` | FMP | Screener. `market_cap>100B sector=Technology` |
| `filings TICKER` | EDGAR | SEC filings. `--type 10-K` |
| `filing ACCESSION` | EDGAR | Filing index + document text. `--text` fetches content. `--max N` limits chars. |
| `xbrl TICKER` | EDGAR | XBRL concept data. `--concept revenue,net_income,eps` (comma-separated for multi). |
| `search "QUERY"` | EDGAR | EFTS full-text search across all filings since 2001. `--forms 10-K --start YYYY-MM-DD` |
| `edgar-screen` | EDGAR | Cross-company screen by XBRL concept. `--concept Revenues --min 1B --period CY2024` |
| `ask "QUESTION"` | AlphaSense | GenSearch. `--mode auto/fast/thinkLonger/deepResearch` |
| `news TICKER` | FMP+Serper | Merged news, deduped by URL |
| `cache clear/stats` | — | Cache management |

## FMP Stable Endpoints (verified May 2026)

These are the correct stable API paths. Several differ from what older docs show:

| Method | Endpoint | Notes |
|--------|----------|-------|
| profile | `/stable/profile` | Full profile with beta, range, lastDividend, volume |
| income_statement | `/stable/income-statement` | `period` param: annual/quarterly |
| balance_sheet | `/stable/balance-sheet-statement` | Same |
| cash_flow | `/stable/cash-flow-statement` | Same |
| key_metrics | `/stable/key-metrics` | ROIC, EV/EBITDA, FCF yield |
| ratios | `/stable/ratios` | Full ratio suite |
| financial_scores | `/stable/financial-scores` | Altman Z, Piotroski |
| dcf | `/stable/discounted-cash-flow` | Response key: `Stock Price` not `stockPrice` |
| enterprise_value | `/stable/enterprise-values` | |
| earnings | `/stable/earnings` | **NOT** `/stable/earnings-surprises` (404). Returns: epsActual, epsEstimated, revenueActual, revenueEstimated |
| transcript | `/stable/earning-call-transcript` | **NOT** `/stable/earnings-transcript` (404). Uses `period` (string "Q1") |
| analyst_estimates | `/stable/analyst-estimates` | **Requires `period` param** (annual/quarterly) |
| grades | `/stable/grades` | **NOT** `/stable/analyst-stock-recommendations` (404). Returns gradingCompany, newGrade, action |
| price_target | `/stable/price-target-consensus` | **NOT** `/stable/price-target` (404). Returns targetHigh/Low/Consensus/Median |
| price_target_summary | `/stable/price-target-summary` | Monthly/quarterly/yearly avg targets |
| insider_trading | `/stable/insider-trading/search` | **NOT** `/stable/insider-trading` (404) |
| stock_peers | `/stable/stock-peers` | Returns peersList with price/mktCap |
| quote | `/stable/quote` | |
| historical_price | `/stable/historical-price-eod/full` | `from`/`to` date params |
| screener | `/stable/company-screener` | |
| stock_news | `/stable/news/stock` | `symbols` param (not `symbol`) |

## Global Options
- `--format json|table|csv|markdown` (default: json)
- `-o FILE` write to file
- `-q` quiet (suppress non-data output)
- `--no-cache` bypass cache (must come before command)
- `--debug` show HTTP details
- `--source auto|edgar|fmp` on dual-source commands

## Cache TTLs
| Data | TTL |
|------|-----|
| Profile, financials, metrics | 24h |
| Transcripts, filings, XBRL | 7 days |
| Analyst ratings, insider | 6h |
| EFTS search, EDGAR insider/holders | 1 day |
| Quotes | 5 min |
| News | 1h |
| AlphaSense | No cache |

## Architecture
```
src/research/
├── cli.py          # Typer app, error handler wraps all commands
├── config.py       # Config dataclass, error classes, .env loading
├── output.py       # JSON/table/CSV/markdown formatting
├── sources/        # One client class per API
│   ├── fmp.py, edgar.py, alphasense.py, serper.py
│   └── registry.py # Source routing: resolve_source(), source_option()
├── commands/       # One module per command group
│   ├── info.py, financials.py, metrics.py, valuation.py
│   ├── earnings.py, ownership.py, filings.py, ask.py
│   ├── market.py, news.py
└── utils/
    ├── cache.py       # diskcache with @cached decorator
    ├── cik_lookup.py  # Ticker<->CIK mapping (SEC), both directions
    └── merge.py       # merge_news() for FMP+Serper dedup
```

## Testing
```bash
uv run pytest -v  # 116 tests, ~6s
```
Tests use `respx` for httpx mocking. Fixture JSON in `fixtures/`.
Use `@respx.mock` (no args) for command tests — lenient URL matching.
`@respx.mock(assert_all_called=False)` enables strict matching and breaks on query params.

## Pitfalls
- `--no-cache` is a global option, must come BEFORE the subcommand: `research --no-cache info AVGO`
- FMP stable API endpoints differ significantly from legacy/v3 docs. Many old paths return 404. Always verify against the "FMP Stable Endpoints" table above.
- FMP 402 = premium-only endpoint. Clean error message points to pricing page.
- `analyst-estimates` requires `period` param or returns 400.
- FMP returns empty `[]` for unknown tickers; EDGAR returns 404. Both handled as `TickerNotFoundError`.
- Git push to main blocked by wrapper. Initial push of new repo requires `/usr/bin/git` directly.
- `gh` CLI is auth'd as `exiao`. For cpe-research org operations, set `GH_TOKEN=$CPE_GITHUB_TOKEN`.
- EFTS search uses `efts.sec.gov` (different domain from `data.sec.gov`). EDGARClient uses a separate httpx client instance for it.
- `filing_text` strips HTML via regex and truncates to 50K chars by default. For very large filings (10-K can be 10MB+), use `--max` to control output size.
- `cik_to_ticker()` reverse lookup iterates the full mapping dict. Fine for occasional use but not for bulk operations on thousands of CIKs.
