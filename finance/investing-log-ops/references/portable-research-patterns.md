# Portable Research Patterns from investing-log

These patterns from investing-log's `.agents/skills/` are general enough to port to any equity research agent. They were ported to CPE Research (avgo) in PR #11 (May 2026).

## Patterns Ported

### 1. Bear Challenge Agent (BEAR_CHALLENGE.md)
Separate adversarial agent in fresh context that stress-tests the bull case. Breaks LLM anchoring bias. Key elements: counter each bull point with data + precedent, blind spot identification with [CRITICAL/MATERIAL/MINOR] severity tags, kill shot (one sentence).

Source: `.agents/skills/deep-research/BEAR_CHALLENGE.md`

### 2. Embedded Expectations Framework
Formula: `Required FCF CAGR = [(Market Cap × 7%) / Current FCF]^(1/5) - 1`. Standardizes "What's Priced In" analysis. Prevents ad-hoc math errors.

Source: `.agents/skills/deep-research/RESEARCH_REFERENCE.md`

### 3. Persona Screening (4-lens check)
Score against value/growth/contrarian/macro personas with PASS/FAIL. Forces conviction justification when 3/4 fail. Lightweight enough to run during synthesis, not as a separate phase.

Source: `.agents/skills/personas/{value,growth,contrarian,macro}.md`

### 4. Ecosystem Signal Extraction (Intelligence Mosaic)
Identify 2-3 peripheral companies (competitors, suppliers, customers). Extract specific variables relevant to thesis. Produces corroborating or contradicting evidence that single-stock analysis would miss.

Source: `.agents/skills/deep-research/RESEARCH_PROCESS.md` (Intelligence Mosaic section)

### 5. Structured Pre-Mortem
Three-part template: Thesis Invalidation (specific events), Warning Signals (metrics + thresholds), Hold Through (acceptable volatility if thesis intact). Replaces vague "what could go wrong" with actionable monitoring.

Source: `.agents/skills/deep-research/RESEARCH_REFERENCE.md` (Pre-Mortem Template)

### 6. Common Pitfalls
13 cognitive biases and analytical errors (anchoring, recency, confirmation, FOMO, confusing good business with good stock, ignoring capital allocation, etc.).

Source: `.agents/skills/deep-research/RESEARCH_REFERENCE.md` (Common Pitfalls)

## Patterns NOT Ported (trading-specific)

- Devil's Advocate (portfolio-level trade challenge, not single-stock)
- Position sizing / Kelly criterion
- Safety rules / hard blocks
- Screening pipeline (uses Bloom collections, not research-cli)
- Sector analysis workflow (macro regime)
- Per-model memory / learning loop (deferred)

## Cross-Repo Porting Notes

- investing-log skills live in `.agents/skills/`, CPE Research in `hermes_home/skills/research/`
- investing-log uses Bloom CLI for data; CPE Research uses research-cli (FMP, EDGAR, AlphaSense)
- investing-log runs on GitHub Actions; CPE Research runs as standalone pipeline or Render service
- Adapt language from portfolio/trading context to institutional research context
