# Autoresearch Pattern: Keep/Revert Optimization Loop

## Overview

The autoresearch pattern is a simple but effective optimization loop for system prompts. Instead of rewriting the entire prompt at once, it makes ONE surgical change per iteration and evaluates whether the change helped.

This is inspired by Karpathy's autoresearch methodology and adapted from [autovoiceevals](https://github.com/AugmentedBrainLLC/autovoiceevals) for text-based chat agents.

## The Algorithm

```
1. BASELINE
   - Read current system prompt
   - Run full eval suite
   - Score all responses with LLM judge
   - Record baseline score

2. LOOP (repeat until max_iterations or Ctrl+C):
   a. PROPOSE
      - Give Claude the current prompt + eval results + history
      - Claude proposes ONE specific change (add/modify/remove/reorder)
      
   b. APPLY
      - Write the modified prompt to the codebase
      
   c. EVALUATE
      - Re-run the full eval suite against modified agent
      - Score with LLM judge
      
   d. DECIDE
      - If score improved by > threshold: KEEP
      - If score unchanged but prompt is shorter: KEEP
      - Otherwise: REVERT to previous best prompt
      
   e. LOG
      - Save experiment to JSON (crash-safe)

3. CLEANUP
   - Restore original prompt (don't leave modified code)
   - Save best prompt to separate file
   - Print summary report
```

## Key Design Decisions

### One change at a time
The most important principle. Multi-change proposals make it impossible to know what helped and what hurt. Each experiment tests a single hypothesis.

### Keep/revert is binary
No partial keeps. Either the entire change stays or the entire change goes. This prevents prompt drift from accumulating marginal changes.

### Shorter prompts are rewarded
When score doesn't change, shorter wins. This creates a natural pressure toward concise, effective prompts rather than bloated ones. The threshold is typically 20+ characters shorter (not trivial whitespace changes).

### History prevents loops
The proposer sees the last 15 experiments. If a change was discarded, it shouldn't propose the same thing again. If many experiments are being discarded, it should try a fundamentally different approach.

### Crash-safe logging
The full experiment log is saved to JSON after every iteration. If the process crashes, `--resume` picks up exactly where it left off.

## Scoring

### LLM Judge
Each scenario response is scored independently by Claude:
- **Score**: 0.0 to 1.0 continuous
- **Pass/fail**: Binary (does it satisfy ALL pass criteria?)
- **Failure modes**: Tagged categories (HALLUCINATION, EMPTY_RESPONSE, etc.)

### Aggregate Score
The optimization target is the **average score across all scenarios**:
```
aggregate_score = mean(scenario_scores)
```

The pass rate and failure modes are tracked for diagnosis but don't directly affect the keep/revert decision.

### Improvement Threshold
Default: 0.02 (2 percentage points). This prevents keeping noise-level improvements that might just be LLM judge variance.

## Prompt Change Types

The proposer categorizes changes as:

| Type | Description | Example |
|------|-------------|---------|
| `add` | Add new text/instructions | "Add a rule about not revealing tool names" |
| `modify` | Change existing text | "Reword the safety section to be more explicit" |
| `remove` | Delete text | "Remove redundant formatting instructions" |
| `reorder` | Move sections around | "Move safety rules above formatting rules" |

## Adapting for Your Project

### Key considerations:
1. **Text-based, not voice**: No latency scoring. Score is purely response quality.
2. **File-based prompts**: Prompt lives in your source code (e.g., `prompts.py`), not a remote API.
3. **Existing eval suite**: Use your project's hand-written scenarios instead of generating new ones.
4. **Template placeholders**: Your prompt may contain template variables (e.g., `{TODAY_DATE}`, `{CONTEXT}`) that must be preserved.

### Things to watch for:
- If the prompt includes large injected sections (e.g., a knowledge framework), changes to the main prompt may interact with injected content.
- Many scenarios may test tool usage (routing, API calls). Prompt changes can affect which tools get called.
- Full eval suites can take 20-40 minutes depending on scenario count and concurrency.

## Running an Optimization Session

Typical session:
```bash
cd ~/your-project

# First run: 10 iterations
python scripts/optimize_loop.py \
  --max-iterations 10 \
  --threshold 0.02

# Review results
cat results/optimization/results.tsv
cat results/optimization/best_prompt.txt

# If the best prompt looks good, apply it manually:
# 1. Read best_prompt.txt
# 2. Replace the system prompt in your source
# 3. Commit the change

# Continue optimizing from where we left off:
python scripts/optimize_loop.py \
  --max-iterations 20 \
  --resume
```

## Expected Results

Based on autovoiceevals benchmarks:
- **First 5 iterations**: Usually find 1-2 impactful changes (score jumps 5-15%)
- **Iterations 5-15**: Diminishing returns, smaller improvements
- **Beyond 15**: Most proposals get discarded. Good sign to stop.
- **Prompt length**: Often decreases by 10-20% (removing redundancy improves clarity)

## Limitations

1. **LLM judge variance**: The same response may get slightly different scores across runs. The threshold helps, but some noise is unavoidable.
2. **Local optima**: The single-change approach can get stuck. If you see 5+ consecutive discards, consider resetting with a manually improved prompt.
3. **Eval suite coverage**: The optimization can only improve what the eval suite tests. Gaps in scenarios = gaps in optimization.
4. **Cost**: Each iteration costs ~$2-5 in API calls (eval suite + judge + proposer). A 10-iteration run costs ~$30-50.
