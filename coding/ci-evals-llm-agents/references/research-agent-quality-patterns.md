# Research Agent Quality Patterns

Reusable patterns for improving LLM-based equity research agents. Extracted from investing-log's multi-model research pipeline and applied to CPE Research Agent (avgo).

## Bear Challenge (Adversarial Stress-Test)

LLMs are sycophantic. An agent that decided BUY during screening produces polite, addressable bear cases, not genuine challenges. Fix: run the bear case in a **separate agent context** that:
- Receives the bull case + raw data but is NOT told the stock was pre-selected
- Counters each bull point with data + historical precedent
- Tags risks with severity: [CRITICAL] >25% drawdown, [MATERIAL] 10-25%, [MINOR] <10%
- Delivers a "kill shot": one sentence, most likely way thesis fails in 12 months
- Pipeline placement: between ANALYZE and SYNTHESIZE phases

Conviction score must be set AFTER reading both bull analyses AND bear challenge.

## Embedded Expectations Framework

Standard valuation sanity check:
```
Required FCF CAGR = [(Market Cap * 7%) / Current FCF]^(1/5) - 1
```
- 7% = terminal FCF yield (risk-free ~4% + equity premium)
- 5 = years of growth modeled (longer is speculative)
- Compare implied CAGR to historical 3-5yr CAGR
- Implied << Historical = market expects deceleration (potential opportunity)
- Implied >> Historical = market expects acceleration (potential overvaluation)
- Always use per-share FCF to account for dilution

## Persona Screening (Multi-Lens Validation)

Score each pick against 4 investment lenses. PASS/FAIL with one key metric:
- **Value:** P/FCF, implied vs historical CAGR gap >5pp
- **Growth:** Revenue acceleration, TAM penetration <10%
- **Contrarian:** Sentiment disconnect from fundamentals, short interest
- **Macro:** Sector alignment with current regime, policy tailwinds

Stock failing 3/4 requires exceptional conviction justification. 0/4 = thesis depends on hope.

## Ecosystem Signal Extraction (Intelligence Mosaic)

Don't analyze in isolation. For each target, identify 2-3 peripheral companies:
- Competitor: pricing trends = demand signal
- Supplier: input costs = margin pressure/tailwind
- Customer: spend patterns = revenue durability

Extract ONLY thesis-relevant data points. Ignore noise. Example for AVGO:
- NVDA: AI data center revenue trends (validates/challenges ASIC demand)
- GOOGL: capex guidance (direct customer signal)
- TSMC: advanced node capacity (supply chain signal)

## Structured Pre-Mortem

Replace vague "write scenarios" with:
1. **Thesis Invalidation:** specific events that prove thesis wrong (measurable, dated)
2. **Warning Signals:** early signs + metric thresholds + duration ("revenue growth <10% for 2Q")
3. **Hold Through:** acceptable volatility if thesis intact ("general sector weakness while outperforming peers")

## First-Principles Reasoning Enforcement

LLM agents default to descriptive analysis ("Revenue grew 20%, which is Strong"). Fix: force a 5-step methodology in every analysis skill:

1. **Hypothesize first.** Before looking at data, write what you'd EXPECT for this business type.
2. **Look up the data.** Read the raw files.
3. **Explain the delta.** Where reality differs from hypothesis, reason about WHY. This is where insight lives.
4. **Build causal chains.** Don't stop at "X grew." Ask: what drove it? Would the driver persist?
5. **Falsify.** Try to disprove your own conclusion before finalizing.

Add anti-patterns to each analysis skill: "Do NOT just describe numbers. Do NOT assign ratings without causal reasoning."

The evaluator must gate on this too. Check: does the memo build causal chains (X drives Y implies Z)? Can you identify the delta? Are arguments company-specific or could they apply to any large-cap?

## Source Hierarchy as Eval Gate

Define a 3-tier hierarchy and enforce it at eval time:

| Tier | Sources | Treatment |
|------|---------|-----------|
| Ground Truth | SEC filings, investor presentations, financial statements | Authoritative, anchor claims here |
| Biased View | Earnings transcripts | Management is selling a narrative. Note what they emphasize AND avoid. Forward-looking = aspirational, not factual. |
| Worth Reading | Expert commentary, substacks, sell-side, news | Contrarian insights possible but verify against primary. Headlines lag reality. |

**Weighting rule:** When sources conflict, always default UP the hierarchy. A 10-K overrides a transcript. A transcript overrides a Substack.

**Eval checks:**
- Source diversity: at least 1 source from each tier used
- Source hierarchy compliance: key claims anchored to ground truth, not tier 3
- If memo relies only on FMP + AlphaSense summaries = "Narrow sourcing" warning

## Required Content Gates

Some content is so important it should cause an eval FAIL if missing. Examples from equity research:

- **Supply/demand balance** with cycle positioning (trough/recovery/expansion/oversupply)
- **Competitive evolution timeline** (who entered/exited over 3-5 years, concentration trends)
- **Industry context** beyond the company in isolation

Add these as mechanical checks in the evaluator: scan appendix for required sections, FAIL with "Missing required content: {X}" if absent. This prevents the agent from producing a financially correct but contextually shallow memo.

## Pipeline Quality Audit Methodology

When auditing whether an agent pipeline actually delivers on stated quality claims, use this systematic approach:

1. **Define criteria as testable questions.** Convert vague goals ("high reasoning quality") into specific checks: "Does the evaluator gate on causal chains?" "Is supply/demand coverage required or optional?"
2. **Read every skill and prompt, not just the architecture.** Architecture diagrams show phases; skills show what each phase actually asks for. Gaps live in the skills.
3. **Classify findings by severity:**
   - MET: the pipeline reliably produces this
   - PARTIALLY MET: sometimes appears but not enforced/gated
   - NOT MET: absent from skills, prompts, and eval gates
4. **Fix through skills first, code second.** For research agents, methodology lives in skills. Edit skills to change behavior. Only touch orchestration code when the pipeline literally can't reach the needed data.
5. **Close the loop in evals.** Every new requirement must have a corresponding eval check, or the agent will silently regress. If the evaluator doesn't gate on it, it's aspirational, not required.

**Skill gap analysis for multi-phase research pipelines:** if analysis lenses exist but lack dedicated skills for transcript extraction, filing reading, industry mapping, peer comparisons, or incremental updates, the agent falls back to ad-hoc LLM reasoning for these tasks. Dedicated skills with structured output formats dramatically improve consistency. The CPE pipeline went from 8 to 15 skills after audit: added transcript-analyzer, filing-reader, industry-mapper, comparables, memo-updater.

## Cross-Verification Checklist (Citation Quality)

Before finalizing any research memo:
1. Recalculate every multiple at CURRENT price (raw data multiples are stale)
2. Verify every transcript quote: confirm speaker (CEO vs analyst question), exact words
3. Check denominators: "X% of segment Y" != X% of total revenue
4. Show math for every derived claim (reproducible calculations)
5. Internal consistency: same metric can't be ~27x in thesis and ~24x in argument
6. Catalyst existence: "good company" is not a catalyst; identify the specific event
7. Yellow flags: insider selling >1% market cap, SBC/revenue >10%, implied >> historical CAGR

## Common Citation Errors (from AVGO eval)

| Error Type | Example | Prevention |
|-----------|---------|------------|
| Fabricated quote | "12-18 months behind" (nowhere in transcript) | Regex search for exact phrase |
| Speaker misattribution | Analyst's question cited as management statement | Distinguish Q&A speakers |
| Denominator error | 78% of ASIC revenue applied to total AI revenue | Define denominator explicitly |
| Stale multiples | 50.6x EV/EBITDA at old price presented as current | Recalculate at current price |
| CAGR arithmetic | 58% CAGR produces $87B, not claimed $70B | Show full calculation |
