---
name: optimize-prompt
description: Iteratively optimize an AI agent's system prompt using a keep/revert autoresearch loop. Use when asked to optimize, improve, or tune a system prompt, run prompt optimization, or do a Karpathy-style autoresearch loop on an agent prompt. Also use when asked to run evals and improve the prompt based on results.
---

# optimize-prompt

Optimize an AI agent's system prompt through iterative single-change experiments. Inspired by Karpathy's autoresearch pattern: one artifact (system prompt), one metric (eval score), keep what improves it, revert what doesn't.

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

Before starting, back up the current prompt file:

```bash
cp <prompt_file> <backup_dir>/prompt_backup_$(date +%Y%m%d_%H%M%S).py
```

## Step 1: Read the Current Prompt

Read the prompt file and find the system prompt variable. Note any template placeholders (e.g., `{TODAY_DATE}`, `{CONTEXT}`) that must be preserved in all edits. Note its length.

## Step 2: Run Baseline Eval Suite

```bash
# Run your eval suite — adapt the command to your project
python eval_runner.py --output /tmp/eval_baseline.json
```

This should run all scenarios concurrently. Categories might include: Task Completion, Hallucination, Edge Cases, Off-Topic handling, etc.

## Step 3: Score the Results

Read the results file. For each scenario result, evaluate the response against its `pass_criteria`:

- **Score 0.0-1.0** per scenario
- **Pass/fail** verdict
- Note specific weaknesses and failure modes
- **Check response length**: simple queries should be concise, complex queries can be longer

Compute the average score across all scenarios. This is your baseline.

## Step 4: Propose ONE Change

Based on the failures, propose exactly ONE surgical edit to the prompt. Rules:

- Do NOT rewrite the entire prompt. Make a targeted edit.
- If a previous change was reverted, do NOT try the same thing again.
- Simpler is better: removing text that doesn't help is a great experiment.
- Preserve all template placeholders.
- Think like a researcher: form a hypothesis, test it, learn from the result.

## Step 5: Apply the Change

Edit the system prompt directly. The eval runner should start a fresh process each time so it picks up the change automatically:

```bash
python eval_runner.py --output /tmp/eval_experiment_N.json
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
  "description": "Added explicit instruction to keep simple queries under 50 words",
  "change_type": "add",
  "score": 0.82,
  "delta": 0.04,
  "status": "keep",
  "prompt_len": 2340,
  "failures": ["scenario-1: still too verbose for simple query"]
}
```

Repeat from Step 4 until:
- Max iterations reached (default: 10)
- No improvement for 3 consecutive experiments
- Score is above target (e.g., 0.95)

## Step 8: Cleanup

When done:
1. Save the best prompt to a separate file for review
2. **Restore the original prompt** (don't leave experiments in the codebase)
3. Report results: baseline score, best score, kept/reverted counts, prompt length change

The best prompt can then be reviewed and applied manually via PR.

## Key Principles

- **One change at a time.** Multiple changes make it impossible to attribute improvement.
- **The agent is the judge.** Read the responses yourself and score against criteria. No separate judge script.
- **Always restore.** Never leave a modified prompt in the repo after the loop ends.
- **Track everything.** Log each experiment with score, delta, description.
- **Shorter is better.** At equal quality, prefer the shorter prompt. Every token costs money at inference time.
- **Response length matters.** A perfect answer that's 5x too long is not perfect. Users read on phones.

## References

| File | Purpose |
|------|---------|
| `references/adversarial-scenarios.md` | Example adversarial scenarios and response length expectations |
| `references/autoresearch-pattern.md` | How the keep/revert optimization pattern works |
