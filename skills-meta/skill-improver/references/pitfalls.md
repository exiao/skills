# Skill-Improver Pitfalls

## Self-scoring bias
When the same agent generates outputs AND scores them, scores inflate by 15-25%. The agent is generous with its own work. The failure analysis is more valuable than the score itself. If baseline comes back 90%+, be skeptical: read the actual outputs and failure patterns before concluding the skill doesn't need work. The three most useful artifacts from a baseline run are: (1) which evals fail most, (2) what the failing outputs look like, and (3) what class of question triggers the weakest responses.

## High baseline doesn't mean stop
A 95%+ baseline with self-scoring often masks real gaps. In one session, a content-strategy skill scored 96% (24/25) but the failure analysis revealed: anti-slop leakage on conversion advice, research steps getting skipped on format-focused questions, and framework over-recitation instead of synthesis. The targeted fixes from failure analysis improved the skill more than 10 mutation experiments would have. When baseline is high, shift from the autoresearch loop to targeted fixes informed by the failure patterns.

## Subagent timeouts on heavy-output skills
Skills that produce long outputs from large inputs (e.g. summarizing 500 tweets into a digest) will timeout subagents at the default 600s limit. Each "run" requires the agent to read hundreds of items, triage, format, and output thousands of chars; a single run can take 3-5 minutes. With 3 runs per experiment, one experiment can exhaust the timeout. Mitigations: (1) reduce runs-per-experiment to 2 for heavy skills, (2) pre-filter the test input to a smaller representative sample (e.g. 100 tweets instead of 500), (3) use the orchestrator role so the subagent can delegate individual runs, or (4) run experiments sequentially in the parent agent instead of delegating the full loop. The parent agent continuing from where the subagent left off (checking results.tsv) is the pragmatic fallback.

## Skills with reference files
Large skills (500+ lines with references/) need evals that test whether the agent correctly routes to reference files rather than trying to cover everything inline. Add an eval like: "Does the output point to specific reference files for deeper implementation?" This prevents the skill from becoming a recitation engine.

## Eval-able vs taste-dependent improvements
Some skill gaps are eval-able (missing research step, broken skill references, generic CTA advice). Others are taste-dependent (does the strategy feel like genuine advice vs framework recitation?). The autoresearch loop handles the first kind well. The second kind needs human review of actual outputs and targeted rewrites, not more mutation cycles.

## Structural rules beat phrase bans
When a skill produces outputs with unwanted patterns (e.g. product-centric copy in an ad skill), banning specific phrases via kill lists triggers whack-a-mole: the model works around banned phrases with equivalent constructions. More effective: (1) structural rules ("if the brand is mentioned in the first sentence, you've failed"), (2) positive examples of the desired pattern, and (3) structural self-tests ("cover up the brand name; does the copy still work as content?"). One structural rule replaced 12 kill phrases in the meta-ads case study.

## Persona directives can cause regression
Adding named personas (e.g. "The Checker: checks portfolio 5x/day") as directives in a skill can pull the model toward problem-solution framing ("this person has problem X, product solves it"). Personas work as context in reference files but harm output quality when embedded as generation directives. If persona targeting is needed, frame it as "who this is for" metadata, not as the creative starting point.

## Self-diagnosis bias (step 6a.5)
When the target model is asked "what would need to change for you to get this right?", it rationalizes. Common biases: (1) blaming missing context when the real issue is a bad instruction, (2) suggesting surface-level fixes (add a rule) when the issue is structural (wrong process), (3) proposing changes that would fix this specific case but break others. The optimizer model should treat self-diagnoses as one signal among several, not as ground truth. If the self-diagnosis contradicts failure cluster analysis, the cluster analysis wins because it's based on patterns across multiple failures, not one model's introspection about a single case.

## False confidence in self-diagnostics (step 6d.5)
The most dangerous diagnostic is `DIAGNOSTIC: none` on a run that fails evals. This means the agent was confidently wrong and didn't notice. Track the correlation between `none` diagnostics and eval failures. A high false-confidence rate (>20%) suggests the skill is actively misleading the agent, giving it enough surface-level structure to feel confident while producing wrong outputs. This is harder to fix than missing context because the agent doesn't know it needs help.

## Public repo skill names differ from runtime names
When running autoresearch on skills that exist in both a public repo (exiao/skills) and a private runtime (~/.hermes/skills/), skill cross-references may use names that only exist in one context. The runtime uses aliases like `tweet-ideas`, `article-writer`, `slideshow-creator` that don't exist in the public repo (which uses `writer`, `video skills`). Always verify cross-referenced skill names exist in the target context before scoring reference-routing evals.

## Additive bias: more rules = worse performance
The optimizer's default is to append instructions when evals fail. This is a trap. In babysit-pr optimization (May 2026), adding explicit triage templates, concrete staleness verification steps, and scope check enforcement improved training from 78% to 100% but validation dropped from 87% to 77%. The added instructions crowded out the core loop structure, causing the model to skip scope checks and batch-classify comments instead of triaging individually. The fix was radical subtraction: moving 163 lines of gotchas to a reference file and rewriting the 632-line skill as 123 lines. The shorter version scored 91.7% train with a simpler, more followable structure. When multiple additive edits fail to improve validation, try cutting the skill in half instead. A model that reads 123 focused lines outperforms one drowning in 632 lines of edge cases.
