# SEC EDGAR API Reference

Complete reference for all free SEC EDGAR API endpoints. No API key needed; just a User-Agent header.

**Rate limit:** ~10 req/sec per SEC fair access policy. Add 0.1s sleep between batch calls.

## Endpoints in research-cli

All endpoints below are implemented in `EDGARClient` (`src/research/sources/edgar.py`).

### Core Data APIs (data.sec.gov)

| Endpoint | Client Method | CLI Command | What It Does |
|----------|--------------|-------------|--------------|
| `data.sec.gov/submissions/CIK{cik}.json` | `submissions(ticker)` | `research filings TICKER` | Recent filings list (1yr or 1000, whichever is more) |
| `data.sec.gov/api/xbrl/companyconcept/CIK{cik}/{taxonomy}/{concept}.json` | `company_concept(ticker, concept)` | `research xbrl TICKER -c concept` | Single XBRL concept time series for a company |
| `data.sec.gov/api/xbrl/companyfacts/CIK{cik}.json` | `company_facts(ticker)` | (internal) | All XBRL concepts for a company (can be 5MB+) |
| `data.sec.gov/api/xbrl/frames/{taxonomy}/{concept}/{unit}/{period}.json` | `frames(concept, unit, period)` | (internal) | Cross-company data for one concept in one period |

### EFTS Full-Text Search (efts.sec.gov)

| Endpoint | Client Method | CLI Command |
|----------|--------------|-------------|
| `efts.sec.gov/LATEST/search-index` | `efts_search(query, forms, start_date, end_date, size, offset)` | `research search "query"` |

Searches the actual text of any filing since 2001. **Different domain** from `data.sec.gov`; uses a separate `efts_client` httpx instance.

| Param | Type | Description |
|-------|------|-------------|
| `q` | string | Search query. Supports exact phrases (`"material weakness"`) and boolean (`AND`, `OR`) |
| `forms` | string | Comma-separated form types: `10-K,10-Q,8-K,DEF 14A` |
| `dateRange` | string | `custom` (with startdt/enddt) |
| `startdt` | string | Start date `YYYY-MM-DD` |
| `enddt` | string | End date `YYYY-MM-DD` |
| `from` | int | Pagination offset (default 0) |
| `size` | int | Results per page (default 10, max 100) |

**EFTS Response Field Mapping (critical: API fields differ from what you'd expect):**

| API field | What it contains | Notes |
|-----------|-----------------|-------|
| `_source.display_names` | Array of `"Company Name  (TICKER)  (CIK 0001234567)"` | First element is the filer. Strip `  (CIK ...)` suffix for clean display. |
| `_source.form` | Form type (`10-K`, `4`, `13F-HR`) | NOT `form_type` |
| `_source.adsh` | Accession number | NOT derived from `_id`. `_id` is `{accession}:{filename}`. |
| `_source.period_ending` | Period of report date | NOT `period_of_report` |
| `_source.file_date` | Filing date | This one matches expectations |
| `_source.file_description` | Document description | |
| `_source.ciks` | Array of CIK strings | |
| `_source.biz_locations` | Array like `["Palo Alto, CA"]` | |
| `_source.sics` | Array of SIC codes | |
| `_source.root_forms` | Array of parent form types | |

Cache TTL: 1 day (86400s), since new filings arrive constantly.

### Filing Document Fetch (sec.gov Archives)

| Endpoint | Client Method | CLI Command |
|----------|--------------|-------------|
| `sec.gov/Archives/edgar/data/{cik}/{accession_no_dashes}/{accession}-index.json` | `filing_index(accession)` | `research filing ACCESSION` |
| `sec.gov/Archives/edgar/data/{cik}/{accession_no_dashes}/{document}` | `filing_text(accession, document, max_chars)` | `research filing ACCESSION --text` |

CIK is extracted from the first 10 digits of the accession number (zero-padded). `filing_text` strips HTML tags via regex, collapses whitespace, and truncates to `max_chars` (default 50K).

### Frames Screening

| Endpoint | Client Method | CLI Command |
|----------|--------------|-------------|
| Same frames endpoint as above | `frames_screen(concept, unit, period, min_val, max_val, limit)` | `research edgar-screen` |

Like `frames()` but returns all data (no 50-result cap), applies min/max value filters, sorts descending by value, and enriches with ticker symbols via `CIKLookup.cik_to_ticker()` reverse lookup.

### Multi-Concept XBRL

| Client Method | CLI Command |
|--------------|-------------|
| `multi_concept(ticker, concepts, taxonomy)` | `research xbrl TICKER -c revenue,net_income,eps` |

Calls `company_concept()` for each concept, merges into rows grouped by `(fiscal_year, fiscal_period)`. Each row has one column per concept. Sorted by fiscal year descending.

### EDGAR-Sourced Insider + Holdings (via EFTS)

| Client Method | CLI Command | What It Does |
|--------------|-------------|--------------|
| `insider_forms(ticker, limit)` | `research insider TICKER --source edgar` | Search EFTS for Form 4 filings for the company |
| `institutional_holders(ticker, limit)` | `research holders TICKER` | Search EFTS for 13F-HR filings mentioning the company |

Both use `efts_search()` under the hood, searching by company name. Results show filing metadata (institution name, dates, accession numbers), not parsed transaction details.

**Data quality comparison (FMP vs EDGAR for insider/holders):**

| Data type | FMP | EDGAR (EFTS) | Best default |
|-----------|-----|--------------|--------------|
| Insider trades | Person name, transaction type (S-Sale/A-Award), shares, price, securities owned, security name, direct/indirect | Person name, filing date, accession number, description only. No shares/price/type. | **FMP** |
| Institutional holders | Not implemented (stub) | Institution name, filing date, period, accession. Text-search based (not CUSIP), so returns any 13F mentioning the company name. | **EDGAR** (only option) |

For detailed insider transaction parsing from EDGAR, you'd need to fetch the Form 4 XML and parse it (not yet implemented).

## Source Routing

Commands with both FMP and EDGAR sources accept `--source auto|edgar|fmp`:

| Command | FMP | EDGAR | Default (auto) |
|---------|-----|-------|----------------|
| `insider` | Yes (cleaner) | Yes (Form 4 via EFTS) | fmp |
| `holders` | Stub | Yes (13F via EFTS) | edgar |
| `financials` | Yes (normalized) | Yes (raw XBRL) | fmp |
| `info` | Yes (richer) | Yes (submissions) | fmp |

All outputs include a `"source"` field for data provenance. Registry at `src/research/sources/registry.py`.

## XBRL Details

**Taxonomies:** `us-gaap`, `ifrs-full`, `dei`, `srt` (no custom taxonomies in API)

**Period format for frames:**
| Format | Type | Tolerance |
|--------|------|-----------|
| `CY####` | Annual | 365 days +/- 30 |
| `CY####Q#` | Quarterly | 91 days +/- 30 |
| `CY####Q#I` | Instantaneous | Point-in-time |

**Units:** Compound units use `-per-` separator (e.g., `USD-per-shares`). Default XBRL unit is `pure`.

**Concept aliases in research-cli:**
revenue, revenues, net_income, net-income, assets, liabilities, equity, eps, operating_income, operating-income, cash, debt

## CIK Lookup

`CIKLookup` class in `src/research/utils/cik_lookup.py`:
- `ticker_to_cik(ticker)`: Forward lookup (ticker to zero-padded 10-digit CIK)
- `cik_to_ticker(cik)`: Reverse lookup (CIK to ticker, returns None if not found)
- Source: `https://www.sec.gov/files/company_tickers.json` (cached 7 days)

## Bulk Data (nightly at ~3am ET)
- `https://www.sec.gov/Archives/edgar/daily-index/xbrl/companyfacts.zip` (all XBRL data)
- `https://www.sec.gov/Archives/edgar/daily-index/bulkdata/submissions.zip` (all filing history)
