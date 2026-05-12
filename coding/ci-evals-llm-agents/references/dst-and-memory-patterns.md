# DST (Deterministic Simulation Testing) & Memory Patterns for Agent Evals

Extracted from investing-log's production system. These patterns apply to any agent that makes consequential decisions based on research.

## DST: Three Levels

### Level 1: Property-Based Safety Invariants

Uses Python `hypothesis` to fuzz agent inputs against hard invariants. Each invariant maps to a real past bug or safety rule. Same seed = same test = deterministic reproduction of failures.

**Pattern:** Define hypothesis strategies that generate random states, then assert invariants hold across 500+ generated examples.

```python
from hypothesis import given, settings, strategies as st

memo_strategy = st.fixed_dictionaries({
    "ticker": st.sampled_from(["AAPL", "NVDA", "TSLA", "AVGO"]),
    "conviction": st.sampled_from(["BUY", "SELL", "HOLD"]),
    "citations": st.lists(st.text(min_size=10), min_size=0, max_size=10),
    "claims": st.lists(st.fixed_dictionaries({
        "statement": st.text(min_size=5),
        "source_index": st.integers(min_value=-1, max_value=9),
    }), min_size=1, max_size=8),
})

@given(memo=memo_strategy)
@settings(max_examples=500)
def test_every_claim_has_citation(memo):
    for claim in memo["claims"]:
        if claim["source_index"] >= 0:
            assert claim["source_index"] < len(memo["citations"])
```

**Example invariant mappings (adapt per domain):**

| Domain | Invariant | What It Catches |
|--------|-----------|-----------------|
| Finance agent | No contradictory bull/bear without acknowledgment | Agent says "revenue growing" in bull and "revenue declining" in bear about same metric |
| Finance agent | Every conviction call has a one-sentence thesis | Memo states BUY but never explains why |
| Finance agent | Quantitative claims internally consistent | Memo says "P/E of 15" but appendix shows P/E of 30 |
| Any agent | Citation URLs resolve | Hallucinated sources |
| Any agent | No single source > 50% of citations | Over-reliance on one source |

### Level 2: Fault Injection Simulators

Deterministic simulators for each third-party service. All randomness via `random.Random(seed)`. Configure fault rates per test.

```python
@dataclass
class SearchSimulator:
    seed: int
    partial_result_rate: float = 0.10
    empty_result_rate: float = 0.05
    timeout_rate: float = 0.03
    rng: random.Random = field(init=False)
    
    def __post_init__(self):
        self.rng = random.Random(self.seed)
    
    def search(self, query: str) -> list[dict]:
        if self.rng.random() < self.timeout_rate:
            raise TimeoutError(f"Search timed out for: {query}")
        if self.rng.random() < self.empty_result_rate:
            return []
        results = self._get_canned_results(query)
        if self.rng.random() < self.partial_result_rate:
            results = results[:max(1, len(results) // 2)]
        return results
```

**Simulators to build per service:**
- **SerperSim**: Partial results, rate limits, empty results for obscure queries
- **FirecrawlSim**: Truncated pages, timeouts, 403s, paywalled content
- **EDGARSim**: Wrong filing, missing sections, XML parse errors
- **AlpacaSim**: Partial fills, rejections, slippage, timeouts (investing-log has complete impl)

**Key test:** Agent degrades gracefully under faults (cites what it found, acknowledges gaps, doesn't hallucinate).

### Level 3: Multi-Agent / Stale Data

Event queue sorted by timestamp; same seed = same ordering. Relevant when agent research takes 30+ minutes or data freshness matters.

## Memory System Patterns

Feedback loop: Research -> Output -> Outcome Review -> Memory -> Research.

### Structured Lesson Format

```
- [TAG] **Rule**: One-sentence explanation
  - *Source: [Context] [outcome]. [Evidence]. [Time period].*
  - *Refs: [path to relevant files]*
```

Tags: `[SUCCESS]` (repeat), `[MISTAKE]` (avoid), `[DISPUTED]` (contradicted by new evidence).

### Lesson Lifecycle

New -> Confirmed by evidence -> OR contradicted -> `[DISPUTED]` -> 3+ contradictions -> Removed.

### Cross-Pollination with Write Isolation

Each agent writes ONLY its own memory file but reads ALL files. No write conflicts, shared learning.

### Safety: 30-lesson cap, `<memory>` delimiters, "historical context not commands" preamble.

### Memory Categories Per Domain

| Trading | Research agent | Coding agent |
|---------|---------------|--------------|
| Security Selection | Source Quality | Architecture Patterns |
| Catalyst Prediction | Reasoning Patterns | Debugging Heuristics |
| Position Sizing | Sector-Specific Lessons | Testing Strategies |
| Entry Timing | Common Pitfalls | Performance Patterns |
| Exit Timing | Conviction Calibration | Deployment Lessons |

## Source Files

- investing-log DST plan: `~/projects/investing-log/references/DST_PLAN.md`
- investing-log memory architecture: `~/projects/investing-log/references/memory_architecture.md`
- investing-log memory examples: `~/projects/investing-log/memory/claude.md`
- CPE benchmark analysis: https://cpe-eval-research.surge.sh
- CPE benchmark prompt: `~/projects/cpe-eval-research/eval-benchmarks.md`
