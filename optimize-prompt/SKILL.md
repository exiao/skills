---
name: optimize-prompt
description: Iteratively optimize Bloom's chat agent system prompt using a keep/revert autoresearch loop. Use when asked to optimize, improve, or tune Bloom's system prompt, run prompt optimization, or do a Karpathy-style autoresearch loop on the agent prompt. Also use when asked to run evals and improve the prompt based on results.
---

# optimize-prompt

Optimize Bloom's `CHAT_AGENT_PROMPT` through iterative single-change experiments. Inspired by Karpathy's autoresearch pattern: one artifact (system prompt), one metric (eval score), keep what improves it, revert what doesn't.

## The Loop

```
1. Read current prompt
2. Run eval suite → read results → score each response
3. Identify weaknesses
4. Propose ONE surgical prompt change
5. Apply change → re-run evals → re-score
6. Score improved? → Keep. Same score but shorter prompt? → Keep. Otherwise → Revert.
7. Goto 4. Repeat until max iterations or stopped.
```

You are the judge. Read each eval response yourself and score it against the pass_criteria. No separate scoring script needed.

## Setup

Before starting, copy `prompts.py` as a backup:

```bash
cp ~/bloom/bloom_backend/prompts.py ~/bloom/llm_tests/prompt_backups/prompts_$(date +%Y%m%d_%H%M%S).py
```

## Step 1: Read the Current Prompt

Read `~/bloom/bloom_backend/prompts.py` and find the `CHAT_AGENT_PROMPT` variable. It's an f-string with `{TODAY_DATE}` and `{VALUE_INVESTING_FRAMEWORK}` placeholders that must be preserved in all edits. Note its length.

## Step 2: Run Baseline Eval Suite

```bash
cd ~/bloom
uv run python llm_tests/eval_runner.py --output /tmp/eval_baseline.json
```

This runs all scenarios (37+ across Task Completion, Hallucination, Trajectory, Edge Cases, News Routing, Investment Ideas, Off-Topic, Beginner Onboarding, plus adversarial categories) concurrently with semaphore=5.

## Step 3: Score the Results

Read `/tmp/eval_baseline.json`. For each scenario result, evaluate the response against its `pass_criteria`:

- **Score 0.0-1.0** per scenario
- **Pass/fail** verdict
- Note specific weaknesses and failure modes
- **Check response length**: simple queries (price lookups, off-topic redirects) should be concise. Analysis queries can be longer. See `references/adversarial-scenarios.md` for word count expectations by category.

Compute the average score across all scenarios. This is your baseline.

## Step 4: Propose ONE Change

Based on the failures, propose exactly ONE surgical edit to the prompt. Rules:

- Do NOT rewrite the entire prompt. Make a targeted edit.
- If a previous change was reverted, do NOT try the same thing again.
- Simpler is better: removing text that doesn't help is a great experiment.
- Preserve `{TODAY_DATE}` and `{VALUE_INVESTING_FRAMEWORK}` placeholders.
- Think like a researcher: form a hypothesis, test it, learn from the result.

## Step 5: Apply the Change

Edit `CHAT_AGENT_PROMPT` in `~/bloom/bloom_backend/prompts.py` directly. The eval runner starts a fresh process each time, so it picks up the change automatically:

```bash
cd ~/bloom
uv run python llm_tests/eval_runner.py --output /tmp/eval_experiment_N.json
```

## Step 6: Keep or Revert

Read the new results, score them. Compare to the best score so far:

| Condition | Action |
|-----------|--------|
| Score improved by >0.02 | **Keep** |
| Score unchanged but prompt is 20+ chars shorter | **Keep** (simpler is better) |
| Score decreased or unchanged | **Revert** to previous best prompt |

## Step 7: Record and Repeat

After each experiment, log:

```json
{
  "experiment": 1,
  "description": "Added explicit instruction to keep price queries under 50 words",
  "change_type": "add",
  "score": 0.82,
  "delta": +0.04,
  "status": "keep",
  "prompt_len": 2340,
  "response_word_counts": {"TC-1": 32, "TC-2": 280, ...},
  "failures": ["RL-1: still 80 words for price query"]
}
```

Save to `~/bloom/llm_tests/prompt_optimization/experiments.json`.

Repeat from Step 4 until:
- Max iterations reached (default: 10)
- No improvement for 3 consecutive experiments
- Score is above target (e.g., 0.95)

## Step 8: Cleanup

When done:
1. Save the best prompt to `~/bloom/llm_tests/prompt_optimization/best_prompt.txt`
2. **Restore the original prompt** in `prompts.py` (don't leave experiments in the repo)
3. Report results: baseline score → best score, kept/reverted counts, prompt length change

The best prompt can then be reviewed and applied manually via PR.

```bash
cp ~/bloom/llm_tests/prompt_backups/prompts_<timestamp>.py ~/bloom/bloom_backend/prompts.py
```

## Key Principles

- **One change at a time.** Multiple changes make it impossible to attribute improvement.
- **The agent is the judge.** Read the responses yourself and score against criteria. No separate judge script.
- **Always restore.** Never leave a modified prompt in the repo after the loop ends.
- **Track everything.** Log each experiment with score, delta, description, and word counts.
- **Shorter is better.** At equal quality, prefer the shorter prompt. Every token costs money at inference time.
- **Response length matters.** A perfect answer that's 5x too long is not perfect. Bloom users read on phones.

## Files

| File | Purpose |
|------|---------|
| `references/adversarial-scenarios.md` | Adversarial scenarios rationale + response length expectations by category |
| `references/autoresearch-pattern.md` | How the keep/revert optimization pattern works |
