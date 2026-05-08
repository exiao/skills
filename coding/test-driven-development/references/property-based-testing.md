# Property-Based Testing with Hypothesis

Patterns from investing-log DST (Deterministic Simulation Testing) suite.

## Core Pattern: Simulators + Fault Injection + Hypothesis

Build deterministic simulators that mirror real services (APIs, databases, brokers), derive outputs from a single ground-truth dataclass (MarketScenario), and inject configurable faults on top.

```
Ground Truth (MarketScenario)
  -> Simulator (BloomSimulator, AlpacaSimulator)
    -> Fault Injection (stale_price_rate, timeout_rate, etc.)
      -> Property Tests (Hypothesis)
```

Key design decisions:
- **Separate RNG for faults** (`seed + 9999`) so fault patterns don't affect scenario data
- **Fault presets** (clean/mild/moderate/chaos) with ordered rates for progressive stress testing
- **Same seed = same faults** enables reproduction of any failure
- **call_log** tracks every fault that fires for post-hoc analysis

## Test Levels (bottom-up)

| Level | What | Tests |
|-------|------|-------|
| L1 | Validation functions in isolation | S1-S10 safety properties |
| L2 | Single simulator with faults | Trade execution + slippage |
| L3 | Multi-agent simulation | N models x M days x random events |
| L4a | Golden path (clean data) | Research pipeline correctness |
| L4b | Fault injection verification | White-box simulator tests |
| L5 | Invariants under faults | Research process with adversarial data |
| L6 | End-to-end | All simulators + all fault levels |

## Non-Tautological Test Pattern

**Bad (tautological):** Filter candidates, then assert filtered candidates pass the filter criteria. This tests the filter against itself.

```python
# BAD: circular
candidates = filter_by_persona(stocks, "value")
for c in candidates:
    assert passes_value_criteria(c)  # same logic as filter!
```

**Good:** Verify the filter against ground-truth data in BOTH directions:
1. Accepted items must pass criteria per ground truth
2. Rejected items must FAIL at least one criterion per ground truth

```python
# GOOD: bidirectional verification against ground truth
accepted = set(filter_by_persona(stocks, "value"))
rejected = set(stocks) - accepted

for s in accepted:
    fund = scenario.fundamentals[s]  # ground truth, not filter output
    assert fund["implied_fcf_cagr"] < fund["historical_fcf_cagr"]
    assert fund["debt_equity"] < 2.0

for s in rejected:
    fund = scenario.fundamentals[s]
    overvalued = fund["implied_fcf_cagr"] >= fund["historical_fcf_cagr"]
    high_debt = fund["debt_equity"] >= 2.0
    assert overvalued or high_debt  # must fail at least one
```

The rejection check is the real value: it proves the filter doesn't accidentally exclude valid candidates.

## Adding New Fields Without Breaking Determinism

When adding fields to a scenario generator that uses seeded RNG:
- Use a **derived RNG** (`random.Random(seed + N)`) for new fields
- This preserves all existing field values (same seed = same old data)
- Without this, inserting new `rng.uniform()` calls shifts all subsequent random values

```python
# Existing fields use main rng (unchanged)
price = rng.uniform(0.85, 1.15)

# New fields use separate rng (preserves determinism of old fields)
persona_rng = random.Random(seed + 7777)
short_interest = persona_rng.uniform(0.01, 0.25)
```

## Hypothesis Settings

- `max_examples=200` for core invariants (balance coverage vs speed)
- `max_examples=500` for safety-critical properties (S1-S10)
- `max_examples=1000` for trade simulation (high variance from fault injection)
- `deadline=None` for any test involving simulation (avoids flaky timeouts)
- Use `assume()` to skip degenerate inputs (e.g., portfolio value = 0)

## Dead Code in Test Helpers

Constants like `PERSONAS = [...]` defined for test parameterization but never referenced are dead code. Either use them (e.g., `@pytest.mark.parametrize("persona", PERSONAS)`) or don't define them. Reviewers flag this.

## Pitfall: Simulators That Don't Test Production Code

DST suites that only test simulators and validation functions answer "does our checking logic work," not "does our production system follow the rules." If the production pipeline is LLM agents writing markdown (not importable Python), the DST tests are well-built infrastructure with nothing plugged in.

**Symptom:** All DST tests pass, but a production run violates invariants and nobody notices until the LLM-as-judge validator catches it (or doesn't).

**Options to bridge the gap:**

1. **Structured sidecar output.** Have agents write machine-readable JSON alongside human-readable markdown. DST validators read the JSON. Cleanest contract, but agents could produce inconsistent md vs json.

2. **LLM-powered parsing.** Use a cheap model (Gemini Flash, Haiku) to extract structured fields from prose reports, then run DST invariant checks on the parsed data. Robust to format drift but adds latency, cost, and non-determinism. Effectively another layer of evals.

3. **Validate only already-structured files.** Skip parsing prose entirely. If sector snapshots are already JSON and allocation tables follow a rigid template, validate those. Leave subjective checks (thesis quality, catalyst reasoning) to LLM validators.

**Where each validator runs:**
- DST tests (simulators + validation functions): CI, on every PR
- Production validators (parsed real output): post-research/trade workflow, not CI
- LLM-as-judge validators: post-research/trade workflow, for subjective quality checks

CI has no production data to validate. Production validation is a separate concern that runs after research/trade workflows complete.
