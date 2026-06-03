# SkillOpt Architecture — Comparison & Lessons

**Source:** Microsoft Research, arxiv:2605.23904 (May 2026)
**Code:** github.com/microsoft/SkillOpt
**Paper:** https://microsoft.github.io/SkillOpt/

SkillOpt treats natural-language skill documents as trainable artifacts. Instead of fine-tuning model weights, a separate optimizer model runs gradient-descent-style loops on the text of a skill doc itself. Won 52/52 evaluated cells across 6 benchmarks, 7 models, 3 harnesses.

## 6-Stage Pipeline (ReflACT)

```
1. Rollout   — target model executes tasks with current skill
2. Reflect   — optimizer model analyzes trajectories, generates patches (minibatch)
3. Aggregate — hierarchical parallel merge of patches (failure-first priority)
4. Select    — rank and clip edits to budget (gradient clipping analog)
5. Update    — apply typed edits (append/insert_after/replace/delete)
6. Evaluate  — validation gate on held-out set, accept/reject
```

## Key Mechanisms (in priority order for adoption)

### 1. Rejected-edit buffer (step_buffer)
When edits are rejected, the specific edits AND their score drops are logged and fed back to the optimizer in subsequent steps. Formatted by `_format_step_buffer()` in `engine/trainer.py`. Buffer includes: step number, action (accept/reject), failure count, failure patterns with task IDs, and rejected edit details with before/after scores. Cap at epoch boundary (resets each epoch).

### 2. Separate optimizer vs target model
Completely separate API paths: `chat_optimizer()` and `chat_target()` in `model/__init__.py`. Optimizer handles 7 stages (analyst, merge, ranking, rewrite, slow_update, meta_skill, lr_autonomous). Target only does rollout. Optimizer can use reasoning-heavy models (`reasoning_effort="high"` for rewrites) while target runs on whatever the skill will actually serve. Key insight: the same model both executing and analyzing can't see its own systematic blind spots. 15-20% improvement from this alone.

### 3. Held-out validation gate
`evaluation/gate.py` — pure function comparing candidate score to current/best on held-out set. Three outcomes: accept_new_best, accept, reject. Combined with hash-based caching (`skill_hash()`) to skip re-evaluation of previously-seen skill content. Default split ratio is 2:1:7 (train:val:test). The massive test set is never seen during training.

### 4. Slow update (epoch-level longitudinal)
At epoch boundaries, `optimizer/slow_update.py` compares same tasks under previous vs current skill. Classifies each as: improved, regressed, persistent_fail, stable_success. Writes guidance into protected `<!-- SLOW_UPDATE_START -->` / `<!-- SLOW_UPDATE_END -->` markers. Step-level edits cannot modify this region (enforced by `_is_in_slow_update_region()` in `optimizer/skill.py`). Each slow update overwrites the previous (not accumulating).

### 5. Structured edit operations
Four ops: append, insert_after, replace, delete. Each with explicit target text matching. `apply_patch_with_report()` returns per-edit status (applied, skipped_protected, skipped_target_not_found, error). Critical for: (a) preventing LLM from rewriting sections it shouldn't touch, (b) protecting slow update regions, (c) observability of exactly what changed.

### 6. Failure pattern clustering (minibatch reflect)
`gradient/reflect.py` — groups failures into minibatches of size M, has optimizer analyze them together in one call. Prompt: "identify the most important COMMON failure patterns across the batch." Produces `failure_summary` with failure_type, count, description. Much better hypotheses than analyzing one failure at a time.

### 7. Hierarchical patch merging
`gradient/aggregate.py` — tree-reduce merge with parallel execution. Separate prompts for failure-driven vs success-driven patches. Final merge explicitly gives failure patches priority. Each edit carries `support_count` (how many independent patches proposed something similar = gradient magnitude in text space). Edits supported by 4/5 minibatches are more likely correct than 1/5.

### 8. Success trajectory analysis
`analyst_success.md` prompt: "identify generalizable behavior patterns that are COMMON across the batch and worth encoding in the skill." Failure-driven edits get priority in final merge, but success insights fill gaps not addressed by failure analysis.

### 9. Meta skill (optimizer memory)
`optimizer/meta_skill.py` — separate from the skill itself, this is memory FOR the optimizer about what edit strategies work. "Which kinds of edits tend to help in this environment. Which kinds tend to be too vague, redundant, brittle, or harmful." Persists across epochs. Injected into all optimizer prompts via `format_meta_skill_context()`.

### 10. LR scheduling
`optimizer/scheduler.py` — constant, linear, cosine, autonomous modes. Autonomous mode (`lr_autonomous.py`) asks optimizer LLM to decide edit count per step based on evidence. Textual learning rate prevents destructive rewrites while keeping enough plasticity.

### 11. Rewrite mode
Three update strategies in `optimizer/update_modes.py`: patch (individual edits), rewrite_from_suggestions (optimizer proposes suggestions, then separate rewrite step produces full new skill at `reasoning_effort="high"` with 64K tokens), full_rewrite_minibatch (each minibatch produces complete skill candidate). Periodic full rewrite cleans up accumulated cruft from many small edits.

## Prompts (all in skillopt/prompts/)

| File | Role | Key design |
|------|------|------------|
| analyst_error.md | Failure analyst | "identify COMMON failure patterns across the batch" |
| analyst_success.md | Success analyst | "identify generalizable behavior patterns worth encoding" |
| merge_failure.md | Merge failure patches | "Prevalent-pattern bias: edits appearing consistently = HIGH priority" |
| merge_final.md | Final merge | "FAILURE PATCHES TAKE PRIORITY" |
| ranking.md | Edit ranking | Systematic impact > Complementarity > Generality > Actionability |
| slow_update.md | Epoch-level guidance | "Reflect on previous guidance effectiveness before writing new" |
| meta_skill.md | Optimizer coach | "Address the FUTURE OPTIMIZER, not the target" |
| lr_autonomous.md | LR decision | "Do not assume any default update size" |
| rewrite_skill.md | Full rewrite | "Prefer consolidation and clarity over making the document longer" |

## What to adopt vs skip

### Must-adopt (in skill-improver v2 plan)
1. Rejected-edit buffer
2. Held-out validation split (three-way: train/val/test)
3. Slow update with protected guidance sections
4. Regression guard on passing cases
5. Failure pattern clustering
6. Resume from checkpoint
7. Separate optimizer model
8. Structured edit operations with protected regions

### Should-adopt (medium impact)
- Success trajectory analysis alongside failure analysis
- Periodic full rewrite pass (every 10 experiments)
- Support count / edit confidence tracking

### Skip (low impact at our scale)
- LR scheduling (lr=1 is fine for short runs, but revisit for long runs)
- Hierarchical merge (only matters with multiple edits per step)
- Hash-based eval caching (unlikely to trigger often)
- Ray parallelism (sequential is fine)
- Gradient accumulation (we fit all inputs in one pass)
- Epochs (we see full dataset every experiment)

## Results reference

| Target Model | Harness | Avg Gain over no-skill |
|---|---|---|
| GPT-5.5 | Direct chat | +23.5 points |
| GPT-5.5 | Codex | +21.8 points |
| GPT-5.5 | Claude Code | +18.6 points |
| GPT-5.4-nano | Direct chat | +24.9 points |
| Qwen3.5-4B | Direct chat | +19.2 points |

Cross-transfer: Codex-trained SpreadsheetBench skill → Claude Code: +31.8 points without re-optimization.

## Roadmap (not yet implemented in skill-improver)

These SkillOpt mechanisms are not in the current skill-improver flow, but are worth adding later:

- **Periodic full rewrite.** Every 10 experiments, produce a complete clean rewrite of the skill from accumulated suggestions instead of incremental edits. Consolidates redundancies from many small changes. (SkillOpt's `rewrite_skill.md` mode.)
- **Support count tracking.** Attach confidence scores to edits based on how many independent analyses support them. Like gradient magnitude in text space. (SkillOpt's `support_count` field.)
- **Meta skill (optimizer memory).** Optimizer-side memory about what edit strategies work for this specific skill type. Persists across optimization runs. (SkillOpt's `meta_skill.py`.)
- **Multi-edit steps with LR control.** Allow 2-4 edits per step when evidence is strong, with the optimizer deciding how many. Autonomous learning rate. (SkillOpt's `lr_autonomous.py` and `scheduler.py`.)
