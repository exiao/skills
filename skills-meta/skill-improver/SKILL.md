---
name: skill-improver
description: "Eval-driven skill optimizer: runs a skill repeatedly, scores outputs against binary evals, mutates the prompt via structured edits, and keeps only changes that improve a held-out validation score (cross-model optimizer/target, three-way splits, golden cases, checkpoint resume). Use when: optimize/improve this skill, make this skill better, run autoresearch on, self-improve skill, benchmark/eval my skill, run evals on."
---

> **Source:** Karpathy autoresearch + SkillOpt (Microsoft Research, arxiv:2605.23904) + howtoeval.com (Ben Hylak, May 2026). See `references/structured-edits.md` for edit op spec, `references/eval-guide.md` for eval writing (including refusal evals, trajectory evals, and golden cases), `references/pitfalls.md` for known failure modes, `references/self-diagnostics.md` for the diagnostic capture protocol, `references/skillopt-architecture.md` for the SkillOpt comparison and roadmap, `references/dashboard-and-data-formats.md` for the dashboard spec and artifact schemas, `references/worked-example.md` for a full run walkthrough and operational tips, `references/mutation-principles.md` for how to mutate well.

# Skill Optimizer

## the loop

Take any existing skill, define what "good output" looks like as binary yes/no checks, then run this loop:

1. **Audit and read the skill.** Run `skill-audit` on the target skill, then read SKILL.md and linked references. Capture obvious structural/routing issues, but do not edit yet.
2. **Gather the eval setup.** Confirm 8-12 test inputs, 3-6 binary evals, model config, run count, budget cap, and golden cases. Split inputs into train/validation/test.
3. **Establish the baseline.** Copy the unchanged skill into the working directory, run train + validation with the target model, score it, and create the dashboard/checkpoint.
4. **Score outputs with binary evals.** Include refusal evals and trajectory evals when the skill's failure mode depends on uncertainty or process, not just final text.
5. **Diagnose failures.** Cluster failing outputs, self-diagnostics, and success patterns with the optimizer model.
6. **Propose one structured edit.** Apply an append/insert_after/replace/delete mutation to the working copy only, starting with audit-found obvious fixes when they are high-confidence.
7. **Validate before keeping.** Reject any golden-case regression and any mutation that fails to improve held-out validation. Keep only measured improvements; log all rejects.
8. **Repeat, then seal it.** Use the rejected-edit buffer and slow updates until plateau/budget/user stop, then score the sealed test set once and deliver the improved file plus artifacts.

**Output:** An improved skill copy + `results.tsv` log + `changelog.md` of every mutation attempted + a live HTML dashboard you can watch in your browser. The original SKILL.md is never overwritten.

---

## why this exists

Most skills work about 70% of the time. The other 30% you get garbage. The fix isn't to rewrite the skill from scratch. It's to let an agent run it dozens of times, score every output, and tighten the prompt until that 30% disappears.

A separate (usually stronger) model analyzes failures while the target model executes, because the same model can't see its own blind spots.

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

**Persist the split assignments.** Record which inputs landed in train/val/test (by ID or prompt text) in `checkpoint.json`, not just the counts. On resume, reuse that exact membership; reshuffling can leak a sealed test prompt into training.

---

## step 1: audit and read the skill

Before changing anything, audit and understand the target skill completely.

1. Run `skill-audit` on the target skill directory. Capture the scorecard and recommended fixes.
2. Read the full SKILL.md file.
3. Read any files in `references/` that the skill links to.
4. Identify the skill's core job, process steps, and output format.
5. Note any existing quality checks or anti-patterns already in the skill.
6. Separate audit findings into:
   - **Deterministic obvious fixes** (broken references, stale commands, malformed frontmatter, routing description issues)
   - **Behavioral hypotheses** that need eval evidence before changing

Do NOT skip this. The audit pre-pass finds low-hanging structural problems, but it does not replace the eval loop. Do not edit the original SKILL.md; pass deterministic audit fixes into the experiment loop by applying them only to the working copy as the first candidate mutation, or by including them in the optimizer prompt context as required edit context. They still pass through the baseline/validation gate.

---

## step 1.5: saturation pass (optional)

Before writing evals, review real executions of the skill to understand its actual failure modes. This step is **optional** for new or low-usage skills, but **mandatory** for high-value skills with production history (e.g. meta-ads-cli, memory-gc).

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

**Max score calculation:** Train and validation sets differ in size, so compute their ceilings separately:
```
max_train = [number of evals] × [runs per experiment] × [number of training inputs]
max_val   = [number of evals] × [runs per experiment] × [number of validation inputs]
```
The test ceiling is computed the same way but only used at final evaluation.

---

## step 3: check for existing checkpoint (resume support)

Before creating anything new, check if `autoresearch-[skill-name]/` already exists with a `checkpoint.json` file.

**If checkpoint exists:**
0. If it has no `best_skill_hash` or the `[name].md.best` snapshot is missing, it's a half-written pre-baseline run — start fresh (step 4).
1. Read `checkpoint.json`: last experiment, best score/experiment, slow update count, and the split membership (which inputs are train/val/test). Reuse that exact membership; never re-split.
2. Read `results.json` for full experiment history
3. Read `rejected_edits.json` for the rejected-edit buffer
4. Read `slow_updates.json` for longitudinal comparison history
5. Restore `[name].md` from `[name].md.best` if it no longer matches `best_skill_hash` (a prior run was interrupted mid-mutation). Resume only from the last accepted state.
6. Tell the user: "Found existing run at experiment [N] with best val_score [X]%. Resume or start fresh?"
7. If resume: skip baseline, load all state, continue from experiment N+1
8. If fresh: move the old directory to `autoresearch-[skill-name]-backup-[timestamp]/` and start over

**If no checkpoint:** proceed to step 4 (baseline).

---

## step 4: generate the live dashboard

Before running any experiments, create the working directory `autoresearch-[skill-name]/` if it does not already exist (step 5 populates it; the dashboard write below needs it to exist first). Then create a live HTML dashboard at `autoresearch-[skill-name]/dashboard.html` and open it in the browser. It auto-refreshes from `results.json` and shows the train/validation score curves, per-experiment keep/discard bars, per-eval breakdown, rejected-edit buffer, diagnostics frequency, and golden case status.

The full dashboard requirements, the `results.json` schema, and the `results.tsv` schema are in [references/dashboard-and-data-formats.md](references/dashboard-and-data-formats.md).

**Critical:** the held-out test set is NEVER scored during the run. `results.json` carries only train and validation scores throughout; `final_test_score` is added once, at the very end (step 8).

---

## step 5: establish baseline

Run the skill AS-IS before changing anything. This is experiment #0.

1. **Ask the user what to name the new version.** Example: "What should I call the optimized version? (e.g., anti-slop-v2, anti-slop-optimized)" The user picks the name.
2. Create a working directory: `autoresearch-[skill-name]/` inside the skill's folder
3. **Copy the original SKILL.md into the working directory as `[user-chosen-name].md`** -- this is the copy you will mutate. NEVER edit the original SKILL.md. All mutations happen on this copy only.
4. Also save `SKILL.md.baseline` in the working directory (identical to the original -- this is your revert target and slow-update comparison anchor)
5. Create `results.tsv`, `results.json`, `rejected_edits.json` (empty array), `slow_updates.json` (empty array), and `dashboard.html`. Open the dashboard. Don't create `checkpoint.json` yet (step 9).
6. Run the skill using **only the train + validation sets** with the **target model**. Score every output against every eval. Leave the test set sealed until final evaluation (step 8).
7. Record the baseline: `train_score` and `val_score` independently. The test set is scored once, at step 8.
8. **Snapshot the baseline as the initial accepted best:** copy `[user-chosen-name].md` to `[user-chosen-name].md.best` and record its hash. This is the accepted state until the first KEEP.
9. Create `checkpoint.json` now (after the `.best` snapshot), with `best_skill_hash` and the split membership (schema in [references/dashboard-and-data-formats.md](references/dashboard-and-data-formats.md)).

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

Collect ALL failing outputs from the training set. For each failure include the **input**, the **output**, and **which evals failed** (by name) plus any self-diagnosis notes, so the optimizer fixes the actual failure instead of guessing. Send to the **optimizer model**:

"Here are [N] failures. The current skill is: [skill content].

Each failure:
- Input: [original input]
- Output: [output]
- Failed evals: [names of the eval criteria that failed, and why]
- Diagnosis (if any): [self-diagnosis from 6a.5]

Group them by failure pattern. For each pattern:
(a) What went wrong
(b) How many outputs share this pattern
(c) What skill change would fix it

Then recommend which single pattern to fix first (highest impact).

Previously rejected edits (do not repeat these or minor variants), plus audit-found deterministic fixes to seed this mutation (if any; phrase them as required working-copy edits):
[rejected-edit buffer contents; step 1 deterministic obvious fixes or empty]"

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

Based on the failure clustering (and optionally success analysis), propose edits in structured JSON format. If step 1 found deterministic obvious fixes, seed the first proposal with those deterministic fixes as the candidate mutation before proposing behavioral hypotheses:

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

1. Compare per-eval pass/fail against the **last ACCEPTED (kept) experiment's** pass history, not just the previous record (which may be a discarded candidate). Track per-eval pass history keyed to the accepted-best state.
2. **Golden case check (strict):** If ANY golden case regresses on ANY eval, **discard immediately**: revert `[user-chosen-name].md` to the accepted best (`[user-chosen-name].md.best`) and log the discard reason as `"golden_case_regression"` in the rejected-edit buffer. No exceptions, regardless of net score improvement. Golden cases are the "memory of bugs you refuse to reintroduce."
3. If any non-golden eval that was previously passing now fails on any training input: regression detected.
4. If the net training score is lower or equal after the regression: **discard immediately** — revert `[user-chosen-name].md` to the accepted best (mandatory, or the next experiment builds on the rejected edit), skip the validation gate, and add to the rejected-edit buffer with a "regression" tag.
5. If the net training score is still higher despite the regression: proceed to validation gate (the improvement outweighs the regression).

Track per-eval pass history across experiments so you always know what was passing before.

### 6f. validation gate (target model)

Run the updated skill on **validation inputs** using the **target model**. Score every output.

**Keep/discard decision based on validation score:**
- Val score improved over previous best → **KEEP.** Update the working copy as the new best, then snapshot it: copy `[user-chosen-name].md` to `[user-chosen-name].md.best` and record its hash in `checkpoint.json` as `best_skill_hash`. This is the validated state an interrupted resume restores from (see step 3).
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
4. Update `checkpoint.json`: `{last_experiment, best_val_score, best_experiment, slow_update_count, best_skill_hash, split}` (keep the persisted split membership intact across saves)
5. Append to `changelog.md` (see step 7)

### 6i. slow update (every 5 experiments)

Every 5th experiment, pause the fast loop and run a longitudinal regression check:

1. Re-run the **training inputs only** through TWO skills using the **target model**:
   - (a) the original `SKILL.md.baseline`
   - (b) the current best `[user-chosen-name].md`

   Training only — validation stays a pure gate (6i.6), so val outcomes never feed the guidance prompt.
2. Classify each training input into one of four categories:
   - **improved**: was failing with baseline, now passes with current
   - **regressed**: was passing with baseline, now fails with current
   - **persistent_fail**: fails with both
   - **stable_success**: passes with both
3. If previous slow-update guidance exists, include it for reflection.
4. Send the comparison to the **optimizer model**:

   "Here is a longitudinal comparison of the same [N] training tasks under the original skill vs the current optimized skill after [M] experiments.

   Improved: [list]
   Regressed: [list]
   Persistent failures: [list]
   Stable successes: [list]

   Previous guidance (active during the last round of optimization):
   [previous guidance or '(none, this is the first slow update)']

   Which parts of the previous guidance helped? Which hurt? Which persistent failures remain unaddressed?

   Write 2-4 high-level guidance notes for the next round of optimization. These will be injected into a protected section of the skill that step-level edits cannot modify."

5. Write the guidance into the working skill copy between `<!-- SLOW_UPDATE_START -->` and `<!-- SLOW_UPDATE_END -->` markers. If these markers don't exist yet, add them at the end of the skill.
6. **Gate the guidance like any other mutation.** Re-score train and validation independently. Keep the guidance only if train improves and validation doesn't regress; otherwise revert it (or remove it on the first slow update) and log `"rejected"` in `slow_updates.json`. Update `[user-chosen-name].md.best`/`best_skill_hash` if kept.
7. Each accepted slow update overwrites the previous guidance (not accumulating).
8. Log to `slow_updates.json`.

### 6j. stopping criteria

**NEVER STOP to ask the user if you should continue.** They may be away from the computer. Run autonomously until:
- The user manually stops you
- You hit the budget cap (if one was set)
- You hit 95%+ val_score for 3 consecutive experiments (diminishing returns)
- **Saturated training set:** all training outputs pass but validation still fails or
  stays below threshold. The optimizer then has no training failure clusters to drive
  6a/6c, so the loop has no actionable signal. When this happens, stop and report an
  overfitting / data-coverage warning, and recommend adding or reshuffling more
  training inputs rather than looping with nothing to fix.

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

**Only if a held-out test set exists.** The degraded splits (5-7 inputs create no
test set; 4 or fewer create no split at all) leave nothing to score here. In those
minimum-input runs, skip this step and report "no honest test score (insufficient
inputs for a held-out set)" instead of inventing a test result — deliver the train
and validation deltas only.

When a test set exists, score the **test inputs** (never seen during optimization)
for the first time. Run them through BOTH `SKILL.md.baseline` (to get the honest
baseline test score) and the best optimized skill, using the **target model**. The
delta between the two is the honest improvement number.

**Overfitting warning:** If val_score improved significantly but test_score didn't, the optimization overfit to the validation set. Flag this explicitly in the summary.

### 8b. deliver results

Present:

1. **Score summary:** Baseline → Final for each set that exists (train, val, and test when a held-out test set was created; otherwise state the test score is unavailable)
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

## reference material

- **Mutation principles** (how to mutate well: subtract before adding, structural rules over phrase bans): [references/mutation-principles.md](references/mutation-principles.md)
- **Output file tree** (what the run produces): [references/dashboard-and-data-formats.md](references/dashboard-and-data-formats.md)
- **Worked example** (full diagram-generator run walkthrough), **operational tips** (cross-model setup, timeout handling, idea recovery), and **how this connects to other skills**: [references/worked-example.md](references/worked-example.md)
- **SkillOpt architecture comparison and roadmap** (mechanisms not yet implemented): [references/skillopt-architecture.md](references/skillopt-architecture.md)

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
