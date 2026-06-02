---
name: skill-improver
description: "Autonomously optimize any skill by running it repeatedly, scoring outputs against binary evals, mutating the prompt via structured edits, and keeping improvements. Inspired by Karpathy's autoresearch + Microsoft's SkillOpt (arxiv:2605.23904) + howtoeval.com floor-raising patterns. Supports cross-model optimization (separate optimizer/target models), three-way data splits, rejected-edit buffers, longitudinal regression checks, checkpoint resume, golden cases (regression-proof critical paths), refusal evals (calibration testing), trajectory evals (process assertions), self-diagnostics (agent confidence capture), post-failure self-diagnosis, and production log saturation passes. Use when: optimize this skill, improve this skill, run autoresearch on, make this skill better, self-improve skill, benchmark skill, eval my skill, run evals on. Outputs: an improved SKILL.md, results log, changelog, and a live HTML dashboard."
version: 2.1.0
---

> **Source:** Karpathy autoresearch + SkillOpt (Microsoft Research, arxiv:2605.23904) + howtoeval.com (Ben Hylak, May 2026). See `references/structured-edits.md` for edit op spec, `references/eval-guide.md` for eval writing (including refusal evals, trajectory evals, and golden cases), `references/pitfalls.md` for known failure modes, `references/self-diagnostics.md` for the diagnostic capture protocol.

# Skill Optimizer

Most skills work about 70% of the time. The other 30% you get garbage. The fix isn't to rewrite the skill from scratch. It's to let an agent run it dozens of times, score every output, and tighten the prompt until that 30% disappears.

This skill runs an autonomous optimization loop: generate outputs, score against binary evals, cluster failure patterns, propose structured edits, validate on held-out inputs, keep what improves, discard what doesn't. A separate (usually stronger) model analyzes failures while the target model executes, because the same model can't see its own blind spots.

---

## the core job

Take any existing skill, define what "good output" looks like as binary yes/no checks, then run an autonomous loop that:

1. Generates outputs from the skill using test inputs (target model)
2. Scores every output against the eval criteria
3. Clusters failure patterns across all failing outputs (optimizer model)
4. Proposes structured edits (append/insert_after/replace/delete) to fix the highest-impact pattern
5. Validates changes on held-out inputs before accepting
6. Keeps mutations that improve the validation score, discards the rest
7. Periodically runs a longitudinal regression check (slow update)
8. Repeats until the score ceiling is hit or the user stops it

**Output:** An improved SKILL.md + `results.tsv` log + `changelog.md` of every mutation attempted + a live HTML dashboard you can watch in your browser.

---

## before starting: gather context

**STOP. Do not run any experiments until all fields below are confirmed with the user. Ask for any missing fields before proceeding.**

1. **Target skill** -- Which skill do you want to optimize? (need the exact path to SKILL.md)
2. **Test inputs** -- What 8-12 different prompts/scenarios should we test the skill with? (variety matters. These get split into train/validation/test sets. Minimum 5 for graceful degradation, but 8-12 is the target for three-way splits. See [references/eval-guide.md](references/eval-guide.md) for why this matters.)
3. **Eval criteria** -- What 3-6 binary yes/no checks define a good output? (see [references/eval-guide.md](references/eval-guide.md) for how to write good evals)
4. **Model configuration** -- Pick one of three options:

   | Config | Optimizer (analyzes) | Target (executes) | Best for |
   |--------|---------------------|-------------------|----------|
   | **A (default)** | claude-opus-4-6 | gpt-5.5 | Skills that run on OpenAI models in production. Opus catches GPT blind spots. |
   | **B** | gpt-5.5 | claude-opus-4-6 | Skills that run on Anthropic models in production. GPT catches Opus blind spots. |
   | **C (same model)** | session model | session model | Quick runs, cost-sensitive, or when you just want to iterate fast. |

   Default is **A** (opus optimizes, gpt executes). The key principle: the optimizer should be a different architecture than the target so it can see systematic biases the target can't. If the user doesn't specify, use A. If they say "same model" or "no cross-model," use C.
5. **Runs per experiment** -- How many times should we run the skill per mutation? Default: 3. (more runs = more reliable scores, but slower. 3-5 is the sweet spot.)
6. **Budget cap** -- Optional. Max number of experiment cycles before stopping. Default: no cap (runs until you stop it).
7. **Golden cases** -- Optional but recommended. Which test inputs are golden cases? Golden cases are scenarios that MUST always pass, typically derived from real production failures or critical user paths. They represent "bugs you refuse to reintroduce." Golden cases are always placed in the training set (never held out) so regressions are caught immediately. Any mutation that causes a golden case to regress on ANY eval is discarded instantly, regardless of net score improvement. If the user doesn't specify, ask: "Are any of these inputs critical paths that should never regress? Those become golden cases."

### data split

Inputs get split into three sets:

| Set | Share | Purpose | When used |
|-----|-------|---------|-----------|
| **Training** | 50% | Rollout + failure analysis + success analysis | Every experiment |
| **Validation** | 25% | Accept/reject gate (keep vs discard decision) | Every experiment |
| **Test** | 25% | Final honest evaluation (never seen during optimization) | Only at the very end |

Example with 8 inputs: 4 train, 2 validation, 2 test.

**Graceful degradation:** If the user provides only 5-7 inputs, fall back to a two-way split (60% train, 40% validation, no test set). If 4 or fewer, use all inputs for both training and validation (no split). Always tell the user what split you're using and why more inputs would help.

**Golden case placement:** Golden cases are always assigned to the training set, never randomized into validation or test. They are scored every experiment alongside regular training inputs. In the dashboard, golden cases are marked with a 🔒 indicator. In `results.json`, each input has an `"is_golden": true/false` field.

---

## step 1: read the skill

Before changing anything, read and understand the target skill completely.

1. Read the full SKILL.md file
2. Read any files in `references/` that the skill links to
3. Identify the skill's core job, process steps, and output format
4. Note any existing quality checks or anti-patterns already in the skill

Do NOT skip this. You need to understand what the skill does before you can improve it.

---

## step 1.5: saturation pass (optional)

Before writing evals, review real executions of the skill to understand its actual failure modes. This step is **optional** for new or low-usage skills, but **mandatory** for high-value skills with production history (e.g. meta-ads, memory-gc, bloombot-access-gate).

1. Search episode logs and session transcripts for 10-20 real executions of the target skill. Use the `recall` skill or `grep` through `~/.hermes/episodes/` and `~/.hermes/sessions/`.
2. For each execution, note:
   - Did it succeed or fail?
   - What was the failure mode? (wrong output, wrong process, silent failure, confabulation, tool error)
   - Did the user correct or work around anything?
   - Were there any surprising successes?
3. Stop when you hit **saturation**: the same failure patterns start repeating.
4. Use these patterns to inform both your test inputs (step 2's scenarios) and eval criteria (step 2's binary checks). Production failures make excellent golden cases (see item 7 in context gathering).

The goal is to avoid designing evals in a vacuum. Real usage reveals failure modes that synthetic test inputs miss.

---

## step 2: build the eval suite

Convert the user's eval criteria into a structured test. Every check must be binary: pass or fail, no scales.

**Format each eval as:**

```
EVAL [number]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [What "yes" looks like — be specific]
Fail condition: [What triggers a "no"]
```

**Rules for good evals:**
- Binary only. Yes or no. No "rate 1-7" scales. Scales compound variability and give unreliable results.
- Specific enough to be consistent. "Is the text readable?" is too vague. "Are all words spelled correctly with no truncated sentences?" is testable.
- Not so narrow that the skill games the eval. "Contains fewer than 200 words" will make the skill optimize for brevity at the expense of everything else.
- 3-6 evals is the sweet spot. More than that and the skill starts parroting eval criteria back instead of actually improving.

See [references/eval-guide.md](references/eval-guide.md) for detailed examples of good vs bad evals.

### refusal evals (optional)

Some skills should refuse when they lack sufficient context, encounter out-of-domain queries, or receive stale/unreliable data. For these skills, add **refusal eval inputs**: test cases where the correct behavior is to say "I don't know" or "I can't reliably answer this."

```
REFUSAL_INPUT [number]: [Short description]
Scenario: [The input prompt]
Why refuse: [Why the skill should refuse rather than attempt an answer]
```

Refusal inputs use **inverted scoring**: the skill passes if it refuses (acknowledges uncertainty, declines to answer, flags insufficient data), and fails if it produces a confident answer. Include 2-3 refusal inputs alongside your normal test inputs. They participate in the same data split.

This matters most for skills that handle real data: financial data, user-facing research, production diagnostics. A confident wrong answer erodes trust faster than an honest refusal builds it.

### trajectory evals (optional)

Standard evals judge the final output. Trajectory evals judge the **process**: did the skill call the right tools in the right order? Did it retrieve context before generating? Did it check for errors?

```
TRAJECTORY_EVAL [number]: [Short name]
Question: [Yes/no question about the execution path, not the output]
Pass condition: [What the trajectory should include]
Fail condition: [What indicates a broken process]
```

Examples:
- "Did the skill load the reference file before generating output?" (context retrieval)
- "Did the skill call the data API before making claims about current prices?" (tool ordering)
- "Did the skill check for error responses before proceeding?" (error handling)

Trajectory evals require capturing the full tool-call sequence during each run. Log intermediate steps (tool names, order, key arguments) alongside the final output. A skill that produces correct output through a wrong process is fragile and will break on novel inputs.

**Max score calculation:**
```
max_score = [number of evals] × [runs per experiment] × [number of inputs in the active set]
```

---

## step 3: check for existing checkpoint (resume support)

Before creating anything new, check if `autoresearch-[skill-name]/` already exists with a `checkpoint.json` file.

**If checkpoint exists:**
1. Read `checkpoint.json` to get: last completed experiment, best score, best experiment number, slow update count
2. Read `results.json` for full experiment history
3. Read `rejected_edits.json` for the rejected-edit buffer
4. Read `slow_updates.json` for longitudinal comparison history
5. Read the working skill copy `[name].md` as-is (it has the latest accepted state)
6. Tell the user: "Found existing run at experiment [N] with best val_score [X]%. Resume or start fresh?"
7. If resume: skip baseline, load all state, continue from experiment N+1
8. If fresh: move the old directory to `autoresearch-[skill-name]-backup-[timestamp]/` and start over

**If no checkpoint:** proceed to step 4 (baseline).

---

## step 4: generate the live dashboard

Before running any experiments, create a live HTML dashboard at `autoresearch-[skill-name]/dashboard.html` and open it in the browser.

The dashboard must:
- Auto-refresh every 10 seconds (reads from results.json)
- Show TWO score progression lines: training score and validation score (experiment number on X axis, pass rate % on Y axis). Divergence between the two = overfitting signal.
- Show a colored bar for each experiment: green = keep, red = discard, blue = baseline, orange = slow update
- Show a table of all experiments with: experiment #, train_score, val_score, status, description, edit_ops applied
- Show per-eval breakdown: which evals pass most/least across all runs
- Show rejected-edit buffer contents (last 10)
- Show diagnostics frequency chart: how often each diagnostic category appears across all runs
- Show golden case status: a row per golden case with pass/fail history across experiments (🔒 indicator, green/red per experiment)
- Show current status: "Running experiment [N]..." or "Idle"
- Use clean styling with soft colors (white background, pastel accents, clean sans-serif font)

Generate the dashboard as a single self-contained HTML file with inline CSS and JavaScript. Use Chart.js loaded from CDN for the line chart. The JS should fetch `results.json` and re-render.

**Open it immediately** after creating it: `open dashboard.html` (macOS) so the user can see it in their browser.

**results.json format:**

```json
{
  "skill_name": "[name]",
  "status": "running",
  "current_experiment": 3,
  "optimizer_model": "claude-opus-4-6",
  "target_model": "gpt-5.5",
  "split": {"train": 4, "val": 2, "test": 2},
  "baseline": {"train_score": 70.0, "val_score": 65.0, "test_score": 68.0},
  "best": {"val_score": 90.0, "experiment": 5},
  "experiments": [
    {
      "id": 0,
      "train_score": 70.0,
      "val_score": 65.0,
      "max_score": 20,
      "status": "baseline",
      "description": "original skill — no changes",
      "edit_ops": [],
      "failure_patterns": [],
      "success_patterns": [],
      "diagnostics_summary": {"missing_context": 0, "guessed": 0, "tool_failure": 0, "low_confidence": 0, "none": 0},
      "golden_case_results": [],
      "self_diagnoses": []
    }
  ],
  "rejected_edits": [],
  "slow_updates": [],
  "eval_breakdown": [
    {"name": "Text legibility", "train_pass": 8, "val_pass": 3, "total_train": 12, "total_val": 6}
  ]
}
```

When the run finishes (user stops it or ceiling hit), update `status` to `"complete"`, run the held-out test set, and add `final_test_score`.

---

## step 5: establish baseline

Run the skill AS-IS before changing anything. This is experiment #0.

1. **Ask the user what to name the new version.** Example: "What should I call the optimized version? (e.g., anti-slop-v2, anti-slop-optimized)" The user picks the name.
2. Create a working directory: `autoresearch-[skill-name]/` inside the skill's folder
3. **Copy the original SKILL.md into the working directory as `[user-chosen-name].md`** -- this is the copy you will mutate. NEVER edit the original SKILL.md. All mutations happen on this copy only.
4. Also save `SKILL.md.baseline` in the working directory (identical to the original -- this is your revert target and slow-update comparison anchor)
5. Create `results.tsv`, `results.json`, `rejected_edits.json` (empty array), `slow_updates.json` (empty array), `checkpoint.json`, and `dashboard.html`. Open the dashboard.
6. Run the skill using **all three sets** (train + val + test) with the **target model**. Score every output against every eval.
7. Record the baseline: `train_score`, `val_score`, `test_score` independently.
8. Save checkpoint.

**results.tsv format (tab-separated):**

```
experiment	train_score	val_score	max_train	max_val	status	description
0	70.0%	65.0%	12	6	baseline	original skill — no changes
```

**IMPORTANT:** After establishing baseline, confirm the score with the user before proceeding. If baseline is already 90%+, the skill may not need optimization. See [references/pitfalls.md](references/pitfalls.md) for why high baselines can be misleading.

---

## step 6: run the experiment loop

This is the core optimization loop. Once started, run autonomously until stopped.

### 6a. failure pattern clustering (optimizer model)

Collect ALL failing outputs from the training set into a single analysis prompt. Send to the **optimizer model**:

"Here are [N] outputs that failed evaluation. The current skill is: [skill content].

Group them by failure pattern. For each pattern:
(a) What went wrong
(b) How many outputs share this pattern
(c) What skill change would fix it

Then recommend which single pattern to fix first (highest impact).

Previously rejected edits (do not repeat these or minor variants):
[rejected-edit buffer contents]"

Log the failure patterns in the experiment record.

### 6a.5. post-failure self-diagnosis (target model)

For each failing run on the training set, replay the input to the **target model** (not the optimizer) with this prompt:

> "You previously attempted this task and produced: [failing output]. The expected behavior was: [eval criteria that failed]. You were wrong. What would need to change in your instructions for you to get this right?"

Collect all self-diagnoses and pass them to the optimizer model in step 6c (edit proposal) as additional signal alongside the failure clusters. The target model has information about its own reasoning chain that the optimizer can only infer from the outside.

**Key caveat:** Treat self-diagnoses as clues, not truth. The target model's self-analysis is biased (it rationalizes its own mistakes). The optimizer should weigh self-diagnoses alongside its own failure clustering, not defer to them. If the self-diagnosis contradicts the failure cluster analysis, the optimizer's analysis takes priority.

**Cost control:** This step adds one LLM call per failing run. If more than 5 runs failed, sample the 5 most representative failures (one per failure cluster from step 6a) rather than replaying all of them.

### 6b. success pattern analysis (optimizer model)

If there are passing outputs on the training set, also analyze them:

"Here are [N] successful outputs. The current skill is: [skill content].

Identify behavior patterns that are common across them and NOT already covered by the current skill. Only propose additions if the patterns are genuinely non-obvious and generalizable. Do not propose changes that would fix failures; that's handled separately."

Success-derived edits are lower priority than failure-derived edits. If both target the same area, keep the failure edit. Skip this step if all outputs are failing (nothing to analyze).

### 6c. propose structured edits (optimizer model)

Based on the failure clustering (and optionally success analysis), propose edits in structured JSON format:

```json
{
  "reasoning": "why these edits address the highest-impact failure pattern",
  "edits": [
    {"op": "replace", "target": "exact text to find in skill", "content": "replacement text"},
    {"op": "append", "content": "new section to add at end"},
    {"op": "insert_after", "target": "heading or text to insert after", "content": "new content"},
    {"op": "delete", "target": "exact text to remove"}
  ]
}
```

See [references/structured-edits.md](references/structured-edits.md) for the full edit op spec, protected region rules, and fallback behavior.

**Key rules:**
- Edits targeting content between `<!-- SLOW_UPDATE_START -->` and `<!-- SLOW_UPDATE_END -->` are automatically skipped (protected region).
- `append` inserts before the SLOW_UPDATE markers if they exist.
- If the LLM produces freeform text instead of JSON, treat the entire response as an `append` op.
- Generate a per-edit apply report: `{op, target_preview, content_preview, status}` where status is one of: `applied`, `skipped_protected`, `skipped_not_found`, `error`.

### 6d. apply edits and run training set (target model)

1. Apply the structured edits to `[user-chosen-name].md` with protected-region checks.
2. Log the apply report.
3. Run the updated skill on **training inputs** using the **target model**.
4. Score every output against every eval.

### 6d.5. self-diagnostics capture

After each run completes but before scoring, ask the **target model** to report on its own execution:

> "You just completed this task. Before I score your output, report any moments where you: (a) lacked sufficient context to be confident, (b) guessed or assumed instead of verifying, (c) had a tool call fail or return unexpected data, (d) were unsure which approach to take. Report each as: `DIAGNOSTIC: [category] [one-line description]`. Categories: `missing_context`, `guessed`, `tool_failure`, `low_confidence`, `none`. If everything went smoothly, report `DIAGNOSTIC: none`."

Log diagnostics alongside eval scores in `results.json` under a `"diagnostics"` array per run:

```json
{"input": "...", "diagnostics": [
  {"category": "missing_context", "description": "No reference file for enterprise pricing tiers"},
  {"category": "guessed", "description": "Assumed USD currency without checking"}
]}
```

During failure clustering (step 6a), the optimizer model receives diagnostics alongside failing outputs. A failure where the agent reported low confidence is a higher-signal fix target than a silent failure, because the agent already knows what went wrong. Surface diagnostic frequency in the dashboard: a skill that reports `guessed` on 40% of runs has a calibration problem, not just an output quality problem.

Self-diagnostics also feed into refusal eval design: if the agent consistently reports `missing_context` on certain input types, those are candidates for refusal inputs.

### 6e. regression guard

Before proceeding to validation, check for regressions on the training set:

1. Compare per-eval pass/fail results against the previous experiment.
2. **Golden case check (strict):** If ANY golden case regresses on ANY eval, **discard immediately**. No exceptions, regardless of net score improvement. Golden cases are the "memory of bugs you refuse to reintroduce." Log the discard reason as `"golden_case_regression"` in the rejected-edit buffer.
3. If any non-golden eval that was previously passing now fails on any training input: regression detected.
4. If the net training score is lower or equal after the regression: **discard immediately** (skip validation gate, add to rejected-edit buffer with "regression" tag). This saves the cost of a validation run on a clearly-broken mutation.
5. If the net training score is still higher despite the regression: proceed to validation gate (the improvement outweighs the regression).

Track per-eval pass history across experiments so you always know what was passing before.

### 6f. validation gate (target model)

Run the updated skill on **validation inputs** using the **target model**. Score every output.

**Keep/discard decision based on validation score:**
- Val score improved over previous best → **KEEP.** Update the working copy as the new best.
- Val score stayed the same → **DISCARD.** Revert working copy. The change added complexity without measurable improvement on held-out data.
- Val score got worse → **DISCARD.** Revert working copy.

### 6g. handle discard: rejected-edit buffer

When an edit is discarded, add it to `rejected_edits.json`:

```json
{
  "experiment_id": 3,
  "edits": [{"op": "replace", "target": "...", "content": "..."}],
  "hypothesis": "why this was expected to help",
  "train_score_before": 75.0,
  "train_score_after": 70.0,
  "val_score_before": 65.0,
  "val_score_after": 60.0,
  "reason": "regression on eval 2: text legibility",
  "evals_regressed": ["Text legibility"]
}
```

Cap the buffer at the last 10 entries. Inject the buffer into the failure clustering prompt (step 6a) so the optimizer model doesn't repeat ineffective edits.

### 6h. log and checkpoint

After every experiment (kept or discarded):
1. Append to `results.tsv`
2. Update `results.json` (dashboard data)
3. Update `rejected_edits.json` (if discarded)
4. Update `checkpoint.json`: `{last_experiment, best_val_score, best_experiment, slow_update_count}`
5. Append to `changelog.md` (see step 7)

### 6i. slow update (every 5 experiments)

Every 5th experiment, pause the fast loop and run a longitudinal regression check:

1. Re-run ALL train+val inputs through TWO skills using the **target model**:
   - (a) the original `SKILL.md.baseline`
   - (b) the current best `[user-chosen-name].md`
2. Classify each input into one of four categories:
   - **improved**: was failing with baseline, now passes with current
   - **regressed**: was passing with baseline, now fails with current
   - **persistent_fail**: fails with both
   - **stable_success**: passes with both
3. If previous slow-update guidance exists, include it for reflection.
4. Send the comparison to the **optimizer model**:

   "Here is a longitudinal comparison of the same [N] tasks under the original skill vs the current optimized skill after [M] experiments.

   Improved: [list]
   Regressed: [list]
   Persistent failures: [list]
   Stable successes: [list]

   Previous guidance (active during the last round of optimization):
   [previous guidance or '(none, this is the first slow update)']

   Which parts of the previous guidance helped? Which hurt? Which persistent failures remain unaddressed?

   Write 2-4 high-level guidance notes for the next round of optimization. These will be injected into a protected section of the skill that step-level edits cannot modify."

5. Write the guidance into the working skill copy between `<!-- SLOW_UPDATE_START -->` and `<!-- SLOW_UPDATE_END -->` markers. If these markers don't exist yet, add them at the end of the skill.
6. Each slow update overwrites the previous guidance (not accumulating).
7. Log to `slow_updates.json`.

### 6j. stopping criteria

**NEVER STOP to ask the user if you should continue.** They may be away from the computer. Run autonomously until:
- The user manually stops you
- You hit the budget cap (if one was set)
- You hit 95%+ val_score for 3 consecutive experiments (diminishing returns)

---

## step 7: write the changelog

After each experiment (whether kept or discarded), append to `changelog.md`:

```markdown
## Experiment [N] — [keep/discard/regression/slow-update]

**Train score:** [X]% | **Val score:** [Y]%
**Edit ops:** [list of ops applied, e.g., "replace: swapped vague instruction for specific hex codes"]
**Apply report:** [N applied, M skipped, K errors]
**Hypothesis:** [Why this change was expected to help]
**Result:** [What actually happened — which evals improved/declined]
**Failure patterns:** [Clusters identified this round]
**Rejected-edit buffer:** [N entries, most recent: "..."]
```

This changelog is the most valuable artifact. It's a research log that any future agent (or smarter future model) can pick up and continue from.

---

## step 8: final evaluation and delivery

When the loop stops:

### 8a. run held-out test set

Run the **test inputs** (never seen during optimization) through the best skill using the **target model**. Score every output. This is the honest improvement number. Compare against the baseline test score from step 5.

**Overfitting warning:** If val_score improved significantly but test_score didn't, the optimization overfit to the validation set. Flag this explicitly in the summary.

### 8b. deliver results

Present:

1. **Score summary:** Baseline → Final for all three sets (train, val, test)
2. **Total experiments run:** How many mutations were tried
3. **Keep rate:** How many mutations were kept vs discarded
4. **Top 3 changes that helped most** (from the changelog)
5. **Remaining failure patterns** (what the skill still gets wrong)
6. **Slow update history** (how many longitudinal checks, what regressions were caught)
7. **Rejected-edit buffer** (what was tried and failed, for future reference)
8. **The improved [user-chosen-name].md** (in the working directory, original SKILL.md untouched)
9. **Location of all artifacts** for reference

**The original SKILL.md is NEVER modified.** Do NOT offer to overwrite it. Do NOT copy the working file over it. The user decides what to do with the improved version.

---

## mutation principles

When improving a skill, optimize for durable agent behavior rather than adding brittle rules:

- **Subtract before adding.** The default instinct is to append more rules. Resist it. Long skills dilute the instructions that matter. If a skill is over 200 lines, the first mutation should be moving secondary content to `references/` files. A 50% shorter skill that scores the same is a strict improvement.
- **Gotchas are the highest-signal part of a skill.** If failures repeat, capture the specific footgun and the correct recovery path. But gotchas belong in `references/` unless they affect the core loop.
- **Don't state the obvious.** Assume the model knows generic advice. Add only context that changes behavior for this skill.
- **Use progressive disclosure with linked files.** Keep SKILL.md lean, then point to `references/`, `scripts/`, or `assets/` when deeper context is needed. The core process should be readable in under 2 minutes.
- **Include scripts when repeated work appears.** If runs keep recreating the same helper code, bundle it in `scripts/`.
- **Avoid over-specific instructions that railroad the agent.** Prefer explaining the why and giving flexible patterns over narrow rules that only pass the current evals.
- **Structural rules beat phrase bans.** Banning specific phrases triggers whack-a-mole. Structural rules ("if the brand is mentioned in the first sentence, you've failed") are more durable. See [references/pitfalls.md](references/pitfalls.md).

---

## output format

The skill produces these files in `autoresearch-[skill-name]/`:

```
autoresearch-[skill-name]/
├── dashboard.html           # live browser dashboard (train + val curves, test bar)
├── results.json             # data powering the dashboard
├── results.tsv              # score log with train_score and val_score columns
├── changelog.md             # detailed mutation log with edit ops and apply reports
├── rejected_edits.json      # buffer of failed mutations with structured edit details
├── slow_updates.json        # longitudinal comparison history
├── checkpoint.json          # resume state
├── SKILL.md.baseline        # original skill before optimization (untouched)
└── [user-chosen-name].md    # working copy with protected guidance section
```

---

## example: optimizing a diagram-generator skill

**Context gathered:**
- Target skill: `~/.hermes/skills/visual-design/diagram-generator/SKILL.md`
- Optimizer model: claude-opus-4-6 (session model)
- Target model: gpt-5.5 (cross-architecture)
- Test inputs (10): "OAuth flow", "CI/CD pipeline", "microservices arch", "onboarding funnel", "DB schema", "payment flow", "auth sequence", "deploy pipeline", "event system", "API gateway"
- Split: 5 train, 3 val, 2 test
- Evals: (1) All text legible? (2) Pastel/soft colors only? (3) Linear layout? (4) No numbers or ordinals?
- Runs per experiment: 3

**Baseline (experiment 0):**
Ran all 10 inputs with gpt-5.5. Scored against 4 evals.
Train: 65% | Val: 60% | Test: 70%

**Experiment 1 — KEEP (train 80%, val 75%):**
Failure clustering (opus): "3/5 training failures share the same pattern: numbered steps appear in flow diagrams. This is the highest-impact cluster."
Edit proposed:
```json
{"edits": [{"op": "append", "content": "## Anti-patterns\n\nNEVER include step numbers, ordinal numbers (1st, 2nd), or sequential numbering in diagrams."}]}
```
Apply report: 1 applied, 0 skipped.
Regression guard: no regressions on previously-passing evals.
Val score improved 60% → 75%. **KEEP.**

**Experiment 2 — DISCARD (train 85%, val 70%):**
Edit: `{"op": "replace", "target": "pastel colors", "content": "all text minimum 14px font"}`
Apply report: 1 applied.
Train improved (80→85%), but val dropped (75→70%). **DISCARD.**
Added to rejected-edit buffer: "font size rule — improved training but hurt validation, likely overfit to training inputs."

**Experiment 3 — KEEP (train 90%, val 85%):**
Failure clustering (opus): "2/5 training failures: bright red elements. Rejected-edit buffer says don't try font size. Recommend: replace vague 'pastel colors' with specific hex codes."
Edit: `{"op": "replace", "target": "Use pastel, soft colors", "content": "Use these exact colors: #A8D8EA, #AA96DA, #FCBAD3, #FFFFD2, #B5EAD7"}`
Val improved 75% → 85%. **KEEP.**

**Slow update (after experiment 5):**
Longitudinal comparison (baseline vs current, all 8 train+val inputs):
- Improved: 3 inputs (numbering fixed, colors fixed)
- Regressed: 1 input (complex diagram labels now overlap)
- Persistent fail: 1 input (always too small text)
- Stable success: 3 inputs

Guidance written to protected section:
```
<!-- SLOW_UPDATE_START -->
When generating complex diagrams with many nodes, increase spacing between elements
to prevent label overlap. The color hex codes are working well; do not revert them.
The persistent small-text issue on dense diagrams needs a different approach than
font-size rules (which regressed validation scores in experiment 2).
<!-- SLOW_UPDATE_END -->
```

**Final test evaluation:**
Test score: baseline 70% → final 85%. Honest improvement: +15 points.
Val improved +25 points but test only +15 — some val-specific optimization, but test still improved meaningfully. No overfitting flag.

**Final delivery:**
- Baseline: train 65%, val 60%, test 70% → Final: train 95%, val 90%, test 85%
- 8 experiments, 5 kept, 3 discarded
- 1 slow update pass
- Top changes: hex color codes, anti-numbering rule, worked example
- Remaining issue: dense diagrams occasionally get overlapping labels (flagged in slow update)

---

## operational tips

**Cross-model setup:** Default is Config A: opus as optimizer (current session), gpt-5.5 as target. For the target model, use `hermes chat -q` with a `--model` flag, or delegate to a subagent with the target model specified. To flip it (Config B: gpt optimizes, opus executes), tell the user to start the session on gpt-5.5 and set opus as target. Config C (same model) skips cross-architecture entirely. The optimizer makes ~2 calls per experiment (analysis + edit proposal). The target makes ~N x runs calls per experiment (rollouts). Cost difference is small.

**Operational skills (API calls, uploads, deploys):** If the target skill makes real third-party calls, extract the testable section into a standalone mini-skill for optimization. See `references/ad-creative-ideation-case-study.md` for a worked example (43% → 95%).

**Timeout risk for expensive skills:** If each test run is slow, subagents will timeout at 600s. Mitigations: (1) truncate test inputs to a representative subset, (2) reduce runs-per-experiment to 2-3, (3) pre-compute the filtering step, (4) run the loop in the main context instead of delegating. Plan your time budget: if one run takes ~60s, 3 runs × 10 experiments = 30 minutes minimum.

**If you run out of ideas:** Re-read the failing outputs. Check the rejected-edit buffer for patterns in what didn't work. Try combining two previous near-miss mutations. Try removing things instead of adding them. Simplification that maintains the score is a win. Check the slow update guidance for persistent failures you haven't addressed.

---

## how this connects to other skills

**What feeds into skill-improver:**
- Any existing skill that needs optimization
- User-defined eval criteria (or help them define evals using the eval guide)

**What skill-improver feeds into:**
- The improved skill replaces the original (user's decision)
- The changelog can be passed to future models for continued optimization
- The eval suite can be reused whenever the skill is updated
- The rejected-edit buffer prevents future runs from repeating failed approaches

**Techniques adopted by other systems:**
- CPE Research's `hill_climb.py` adopted structured edit ops, failure clustering, rejected-edit buffer, and report content analysis from this skill (PR #205, 2026-05-27). Key adaptation: their evals are deterministic pytest tests rather than LLM-judged binary checks, so the structured edits operate against a more stable scoring function. Their per-test regression guard (reject if ANY previously-passing test regresses) is stricter than the validation-gate approach here and worth considering for skills where eval stability is high.

---

## future directions (v2.1)

Not implemented in the current flow, but worth adding later:

- **Periodic full rewrite.** Every 10 experiments, produce a complete clean rewrite of the skill from accumulated suggestions instead of incremental edits. Consolidates redundancies from many small changes. (SkillOpt's `rewrite_skill.md` mode.)
- **Support count tracking.** Attach confidence scores to edits based on how many independent analyses support them. Like gradient magnitude in text space. (SkillOpt's `support_count` field.)
- **Meta skill (optimizer memory).** Optimizer-side memory about what edit strategies work for this specific skill type. Persists across optimization runs. (SkillOpt's `meta_skill.py`.)
- **Multi-edit steps with LR control.** Allow 2-4 edits per step when evidence is strong, with the optimizer deciding how many. Autonomous learning rate. (SkillOpt's `lr_autonomous.py` and `scheduler.py`.)

---

## the test

A good optimization run:

1. **Started with a baseline** -- never changed anything before measuring the starting point
2. **Used binary evals only** -- no scales, no vibes, no "rate this 1-10"
3. **Split the data** -- training, validation, and (ideally) test sets are separate
4. **Used structured edits** -- every mutation is a typed operation with a target, not freeform rewriting
5. **Tracked rejections** -- the rejected-edit buffer prevented repeating failed approaches
6. **Checked for regressions** -- both per-experiment (regression guard) and longitudinally (slow update)
7. **Kept a complete log** -- every experiment recorded, kept or discarded, with edit ops and apply reports
8. **Improved the honest score** -- test set score improved, not just training or validation
9. **Ran autonomously** -- didn't stop to ask permission between experiments

If the skill "passes" all evals but the actual output quality hasn't improved, the evals are bad, not the skill. Go back to step 2 and write better evals.
