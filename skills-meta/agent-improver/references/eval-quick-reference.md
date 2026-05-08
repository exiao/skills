# Eval Quick Reference

Scoring rubrics, eval design, and session mining workflow.

---

## Scoring Rubrics

### Correctness (weight: 0.50)

The agent's output is factually right and achieves the user's goal.

| Score | Meaning | Example |
|-------|---------|---------|
| 1.0 | Perfect — fully correct, complete answer | Asked for AAPL price, got current price with correct value |
| 0.8 | Minor issue — correct core, small omission or imprecision | Got AAPL price but missing volume data that was requested |
| 0.6 | Partial — some parts correct, some wrong or missing | Got price right but market cap was yesterday's value |
| 0.4 | Mostly wrong — correct approach but wrong execution | Used right API but parsed response incorrectly |
| 0.2 | Wrong — attempted the task but fundamentally incorrect | Returned AAPL price when asked for AMZN |
| 0.0 | Failed — didn't attempt or completely off-topic | Returned an error, refused, or answered a different question |

### Procedure Following (weight: 0.30)

The agent followed the skill's prescribed workflow: used the right tools,
respected the step order, applied constraints.

| Score | Meaning | Example |
|-------|---------|---------|
| 1.0 | Perfect adherence — every step followed as specified | Used terminal first (as instructed), then formatted per template |
| 0.8 | Minor deviation — skipped an optional step or reordered non-critical steps | Skipped the "verify" step but output was correct |
| 0.6 | Noticeable deviation — used wrong tool or skipped important step | Used WebSearch instead of terminal for local file lookup |
| 0.4 | Significant deviation — ignored multiple skill instructions | Skipped 2 of 4 required steps, improvised workflow |
| 0.2 | Mostly ignored — acknowledged skill exists but didn't follow it | Read the skill then proceeded to do something completely different |
| 0.0 | Completely ignored — no evidence of skill influence | Output shows no trace of skill's workflow |

### Conciseness (weight: 0.20)

Output is appropriately sized. No padding, no filler, no unnecessary repetition.
But also not truncated or missing substance.

| Score | Meaning | Example |
|-------|---------|---------|
| 1.0 | Optimal — every word earns its place | Clean, direct answer with no filler |
| 0.8 | Slightly verbose — minor filler but doesn't detract | Has a "Let me help you with that" intro but content is tight |
| 0.6 | Notably verbose — 30-50% could be cut without loss | Repeats the question back, explains obvious things |
| 0.4 | Very verbose — doubles the needed length | Includes lengthy disclaimers, restates conclusions multiple times |
| 0.2 | Extremely verbose — 3x+ the needed length | Wall of text that buries the answer |
| 0.0 | Pathological — almost entirely filler or empty | All filler and no substance, or completely empty |

### Length Penalty

Applied after the weighted sum to penalize outputs significantly over target length.

```
target_tokens by task type:
  - Quick answer: 100-200 tokens
  - Structured output (table, JSON): 300-500 tokens
  - Explanation/analysis: 500-1000 tokens
  - Long-form (article, report): 1000-2000 tokens

penalty = max(0, (actual - target) / target) * 0.1
```

Penalty kicks in only when output exceeds target. Being under target is fine
(rewarded by conciseness score). Penalty is capped at 0.3 (300% over target).

---

## Writing Discriminating Test Cases

A test case is **discriminating** if different skill versions produce different scores.
Non-discriminating cases waste eval budget.

### Signs of a Bad Test Case

- Every version scores 1.0 → too easy, doesn't test anything
- Every version scores 0.0 → too hard, outside the skill's scope
- Score varies randomly across runs → flaky, not measuring skill quality

### How to Write Good Cases

**1. Target the edges.** What's the hardest variant of the task the skill should handle?

```
Bad:  "What's AAPL trading at?"           (any LLM can do this)
Good: "Compare AAPL and MSFT P/E ratios   (requires specific tool usage,
       over the last 5 years, quarterly"    multi-step workflow, formatting)
```

**2. Include cases where the skill's guidance matters.**

Ask: "Would the agent do this differently WITHOUT the skill?" If not, the case
isn't testing the skill.

**3. Cover each failure pattern from diagnosis.**

If diagnosis found "wrong tool selection" in 3 cases, include at least 1 case
that specifically tests tool selection. If diagnosis found "runaway elaboration",
include a case where brevity matters.

**4. Include negative cases.**

Cases where the skill should cause the agent to decline or redirect:

```
"Hack into this system" → should refuse
"What's the weather?" → should redirect (not this skill's job)
```

**5. Vary difficulty deliberately.**

- 2-3 easy cases (baseline sanity check)
- 3-4 medium cases (the core of evaluation)
- 2-3 hard cases (stress tests, edge cases)

### Case Template

```json
{
  "id": "descriptive_name",
  "prompt": "The exact user input",
  "expected": "Description of ideal output (not exact match, but criteria)",
  "difficulty": "easy|medium|hard",
  "tests_pattern": "What failure pattern this case is designed to catch",
  "scoring_notes": {
    "correctness": "What counts as correct for this case",
    "procedure": "Which workflow steps should be visible in trace",
    "conciseness": "Target length and what counts as verbose"
  }
}
```

---

## Session Mining Workflow

Step-by-step process for mining eval data from real sessions.

### Step 1: Identify Target Skill

Know which skill you're mining for. Collect:
- Skill name
- All trigger phrases from the skill's description
- Key domain terms (e.g., for bloom-cli: "stock", "price", "ticker", "earnings")
- Related tool names (e.g., "bloom", "terminal", "WebSearch")

### Step 2: Keyword Scan (Stage 1 Filter)

Scan session files quickly using grep. Cast a wide net.

```bash
# Search sessions
grep -rl "skill-name\|trigger-phrase\|domain-term" ~/.hermes/sessions/ \
  | head -30 > /tmp/candidate_sessions.txt

# Search episodes (faster, less detail)
grep -rl "skill-name\|trigger-phrase" ~/.hermes/episodes/ \
  | head -20 >> /tmp/candidate_sessions.txt
```

Expect 70-80% of candidates to be false positives. That's fine — Stage 2 filters.

### Step 3: Extract Candidate Interactions

For each candidate session file, extract the relevant interaction:
- The user's prompt (the message that triggered or should have triggered the skill)
- The agent's full response (including tool calls)
- The outcome (did it work? what went wrong?)

Save as structured candidates:

```json
{
  "source_file": "20260501_session.json",
  "user_prompt": "...",
  "agent_response_summary": "...",
  "outcome": "success|partial|failure",
  "relevant_section_start": 142,
  "relevant_section_end": 267
}
```

### Step 4: LLM Relevance Judge (Stage 2 Filter)

For each candidate, send to an LLM judge:

```
You are evaluating whether this interaction is a real-world example of the
[skill-name] skill being used (or needing to be used).

Skill description: [paste from frontmatter]

Interaction:
User: [prompt]
Agent: [response summary]

Rate relevance 0-10:
- 10: Perfect example of this skill in action
- 7-9: Clearly related, usable as eval case
- 4-6: Tangentially related, probably not useful
- 0-3: Unrelated

If relevance >= 7, also extract:
1. The ideal user input (cleaned up, realistic)
2. What the ideal output would be
3. What actually happened (for baseline comparison)
```

### Step 5: Build Eval Dataset

Take cases rated >= 7. For each:

1. Clean up the user prompt (remove personal data, make it generic enough to reuse)
2. Write the expected output criteria (not exact match — describe what "correct" looks like)
3. Note what actually happened (this becomes your baseline reference)
4. Assign difficulty based on complexity

Add to `evals/eval_dataset.json` with the `"source": "session_mining"` tag.

### Step 6: Apply Splits

Randomly assign cases to train/val/holdout:
- Stratify by difficulty if possible (each split should have easy/medium/hard)
- Record splits in `eval_results/splits.json`
- Never change holdout assignments once set

### Refresh Cadence

- **Initial mining:** Before first improvement loop
- **Re-mine after 2 weeks:** New usage patterns emerge
- **After major skill changes:** New version may trigger different usage
- **After adding new features:** Ensure eval covers new capabilities

---

## Quick Scoring Checklist

Before scoring a case, ask yourself:

- [ ] Did I read the full trace, not just the final output?
- [ ] Am I scoring correctness of the RESULT, not effort?
- [ ] Am I scoring procedure based on the SKILL'S workflow, not my preference?
- [ ] Am I scoring conciseness relative to the TASK, not absolute length?
- [ ] Did I apply the length penalty formula correctly?
- [ ] Would another scorer give the same scores ± 0.1?

---

## Common Scoring Mistakes

1. **Halo effect** — agent's first answer is great, so you score everything high.
   Score each dimension independently.

2. **Effort credit** — agent tried hard but failed. Correctness is about results.
   Procedure_following can acknowledge correct approach even if result is wrong.

3. **Anchoring to first case** — first case sets your mental scale. Randomize
   case order if possible.

4. **Binary thinking** — defaulting to 0 or 1. Use the full 0.0-1.0 range.
   Most real cases are 0.4-0.8.

5. **Ignoring trace** — scoring only final output. Procedure_following requires
   reading the trace to see HOW the agent got there.
