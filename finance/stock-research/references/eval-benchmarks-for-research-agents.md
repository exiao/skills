# Evaluation Benchmarks for Equity Research Agents

Compiled May 2026. For the full interactive report: cpe-eval-research.surge.sh. For the implementation plan: ~/.hermes/plans/cpe-eval-implementation.md.

## 6-Layer Eval Stack (Priority Order)

### Layer 1: Financial Research Accuracy — Vals.ai Finance Agent v1.1
- **What:** 537 questions across 9 financial analyst task types (quant retrieval, qual retrieval, numerical reasoning, complex retrieval, GAAP/non-GAAP adjustments, beat-or-miss, trends, financial modeling, market analysis)
- **Baseline:** Opus 4.6 (thinking) = 60.05%. Top = Opus 4.7 at 64.37%.
- **Harness:** github.com/vals-ai/finance-agent (open-source, swap Tavily for Serper)
- **Run:** 50-question public validation set first. Private set (150) via license.
- **QC by:** Goldman Sachs, Silver Lake, Citadel finance experts.

### Layer 2: Citation Quality — FinanceBench (Patronus AI)
- **What:** 150 financial QA questions where every answer must trace to a specific SEC filing passage.
- **Why:** Only benchmark testing citation traceability. Score on two axes: answer accuracy AND citation accuracy.
- **Access:** Fully open-source (GitHub + HuggingFace). ACL publication.

### Layer 3: Hard Financial Reasoning — Mercor APEX IB
- **What:** 160 IB analyst tasks (merger models, sensitivity analysis, accretion/dilution). ReAct harness.
- **Baseline:** Opus 4.6 = 32.8-33.4%. Top = GPT 5.5 at 41.7%. Extremely hard.
- **Caveat:** Skews toward IB (deal analysis), not equity research. Use financial modeling + market analysis subsets.

### Layer 4: Retrieval Quality — OBLIQ-Bench
- **What:** 5 oblique search problems testing retrieval of latent-pattern documents (not keyword matches).
- **Why:** Equity research requires oblique queries ("find filings where management signaled margin compression"). Tests Serper+Firecrawl retrieval layer.
- **Custom extension:** Build 20 oblique financial queries and measure recall.

### Layer 5: Agent Endurance — METR Time Horizon
- **What:** Measures the longest task an agent can complete at 50% success. Best models: ~1 hour.
- **How to use:** Apply methodology to your own tasks. Time human analysts per memo, run agent on same tickers, fit logistic curve.
- **Infra:** github.com/METR/vivaria (open-source agent eval infrastructure).

### Layer 6: Custom Memo Quality (Build This)
- **What:** No benchmark tests "is this a good one-page memo?" Build your own.
- **Rubric:** 5 dimensions scored 1-5: conviction clarity, first-principles reasoning, directional accuracy, source quality, information density.
- **Method:** LLM-as-judge (Opus 4.7), 3 trials per memo, median scores. Validate against 2-3 human expert scores on 10-memo calibration set.

## Eval Harness Architecture (from Anthropic + Bloom)

### Three grader types (use all three):
1. **Code-based:** Format checks, URL resolution, tool call verification, transcript metrics
2. **Model-based:** Rubric scoring, reference comparison, multi-judge consensus
3. **Human:** SME review on calibration set, spot-check sampling, inter-annotator agreement

### Capability vs. regression split:
- **Capability evals** start at LOW pass rate. Give you a hill to climb. (APEX IB tasks, complex analysis, oblique retrieval)
- **Regression evals** must stay ~100%. Drop = something broke. (Basic retrieval, format compliance, tool usage)
- **Graduation:** Capability eval at >95% consistently -> promote to regression suite.

### From Bloom's eval system (steal these patterns):
- Plain markdown (EVAL_SCENARIOS.md) as single source of truth
- Category-based coverage (17 categories, each tests a different failure mode)
- Adversarial tests at 100% threshold (any failure = guardrail gap)
- Transcript grading (grade the path, not just the output)
- CI-triggered on prompt changes, failures auto-open GitHub issues

## DST (from investing-log)

Three levels of deterministic simulation testing:
1. **Property-based invariants** (Hypothesis): Fuzz portfolio/recommendation states against hard rules. Same seed = reproducible.
2. **Fault injection simulators** (SerperSim, FirecrawlSim, EDGARSim): Test graceful degradation under data source failures.
3. **Stale data detection**: What happens when research takes 30min but data changes mid-research?

## ACE Framework (Self-Improving Playbook)

github.com/ace-agent/ace (ICLR 2026). Three roles:
- **Generator:** Produces research trajectory, surfaces strategies and pitfalls
- **Reflector:** Scores memo against rubric, extracts what strategies led to high/low scores
- **Curator:** Converts insights into delta updates with helpful/harmful counters. Auto-dedup, auto-prune.

Finance results: +8.6% on FiNER/XBRL, -91.5% latency, -83.6% token cost. 3 methods to add a custom task.

## Opus 4.6 Scorecard

| Benchmark | Score | Rank |
|-----------|-------|------|
| Vals.ai Finance Agent | 60.05% | #5 |
| APEX IB | 32.8-33.4% | #7-8 |
| ECI (Epoch) | 155 | #8 |
| LiveBench | 76.33 | #5 |
| EQ-Bench 3 | 1807.9 Elo | #3 |
| LMArena Document | 1514 Elo | #2 (tie) |

## Also Evaluated (Lower Priority)

- **SimpleBench** (simple-bench.com): Problem-solving trick questions. Opus 4.6 = 67.6%. Good sanity check, not pipeline material.
- **EQBench** (eqbench.com): Emotional intelligence. Opus 4.6 = #3. Irrelevant for financial research.
- **IFBench** (Ai2): Instruction following. Mildly useful for format compliance.
- **LMArena** (lmarena.ai): Human preference Elo. Document + Search leaderboards give signal.
- **LiveBench** (livebench.ai): Contamination-free general benchmarks. Good for model selection.
- **Scale AI, Deeptune, Fleet AI, Contra, DesignArena**: Wrong domain. Skip.
