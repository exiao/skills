# Case Study: Meta Ads Creative Ideation (May 2026)

Baseline 43.3% → Validated 95.0% in 8 experiments. The target skill generated ad concepts for Bloom (AI investing app). Since the skill makes real API calls and generates images, we extracted the creative ideation section into a standalone mini-skill for testing.

## What worked

### 1. Content-first gates replaced angle categories (+47pp)
The original skill used generic SaaS angle categories (pain point, outcome, social proof, curiosity, comparison, identity, contrarian). These are product-marketing frameworks that push toward feature descriptions. Replacing them with two mandatory gates (Educational: teaches something real, Identity: makes someone feel seen) was the single biggest improvement.

### 2. Structural rules over phrase bans (+7pp)
"If Bloom is mentioned in the first sentence, you've already failed" is more effective than listing banned phrases. It targets the structural problem (product-first copy) rather than surface patterns.

### 3. Positive examples + structural test over kill phrases (+3pp)
Providing preferred CTA templates ("Data via Bloom", "See yours → Bloom") and a structural test ("cover up the brand name; does the copy still work?") outperformed adding more items to a kill phrase list.

## What failed

### Named personas as directives (caused regression)
Adding 5 specific personas (The Checker, The Concentrator, etc.) pulled the model toward "person has problem, product solves it" framing. Personas are useful context but harmful as directives in the skill body.

### Narrow kill phrases (model workaround)
Banning "Bloom [verb] for you" just made the model use "Bloom actually [verb]s." Whack-a-mole with phrase patterns doesn't work for structural issues.

## Methodology notes

- **Extracted testable section:** The full skill was too operational (API calls, uploads) to run end-to-end. Extracting the ideation section into a mini-skill let us iterate fast.
- **Self-scoring bias:** When the same model generates and scores, it passes its own work. Counter: explicit "be harsh" instructions, failure-mode-specific scoring rubrics, and validation on unseen inputs.
- **Timeout risk:** Each experiment needed 2 test inputs × 5 concepts × 6 evals. Subagents timed out at 600s with ~6 experiments done. For expensive skills: run the loop in main context or reduce runs-per-experiment.
- **Validation drop is healthy:** 100% on training inputs, 93-97% on unseen inputs. The ~5% drop means the skill isn't overfit to the test scenarios.
