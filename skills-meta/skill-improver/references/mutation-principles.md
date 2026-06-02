# Mutation Principles

When improving a skill, optimize for durable agent behavior rather than adding brittle rules. SKILL.md points here.

- **Subtract before adding.** The default instinct is to append more rules. Resist it. Long skills dilute the instructions that matter. If a skill is over 200 lines, the first mutation should be moving secondary content to `references/` files. A 50% shorter skill that scores the same is a strict improvement.
- **Gotchas are the highest-signal part of a skill.** If failures repeat, capture the specific footgun and the correct recovery path. But gotchas belong in `references/` unless they affect the core loop.
- **Don't state the obvious.** Assume the model knows generic advice. Add only context that changes behavior for this skill.
- **Use progressive disclosure with linked files.** Keep SKILL.md lean, then point to `references/`, `scripts/`, or `assets/` when deeper context is needed. The core process should be readable in under 2 minutes.
- **Include scripts when repeated work appears.** If runs keep recreating the same helper code, bundle it in `scripts/`.
- **Avoid over-specific instructions that railroad the agent.** Prefer explaining the why and giving flexible patterns over narrow rules that only pass the current evals.
- **Structural rules beat phrase bans.** Banning specific phrases triggers whack-a-mole. Structural rules ("if the brand is mentioned in the first sentence, you've failed") are more durable. See `pitfalls.md`.
