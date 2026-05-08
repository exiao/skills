# Semantic scope regression checks

Use this when a PR claims to make a narrow exception to an existing guardrail, feature flag, permission gate, or config switch.

## Pattern
A change says it applies only when something is "explicitly enabled," but the implementation checks a resolved or derived state instead. That can silently widen behavior.

Example from Hermes Agent:
- Intended: cron with `enabled_toolsets` including `memory` should get a MemoryStore even though cron uses `skip_memory=True` to suppress prompt injection.
- Risky implementation: `"memory" in self.valid_tool_names`.
- Why risky: `valid_tool_names` is the resolved set of loaded tools. When `enabled_toolsets=None`, Hermes means "all/default tools," so `memory` can be present even when nobody explicitly opted into the memory tool for a skip-memory run.
- Better review question: does the code distinguish explicit caller intent from resolved availability?

## Review steps
1. Compare PR body wording against the exact condition in code.
2. Trace how the condition is populated: raw input, config, default, resolved alias, or derived capability.
3. Search for other callers that set the surrounding guardrail (`skip_memory=True`, `ignore_rules`, `dry_run`, `no_network`, etc.).
4. For each caller, ask whether the new behavior is acceptable there too.
5. Request a negative regression test: default/all tools plus the guardrail should preserve the old behavior unless the PR intentionally changes it.

## Red flags
- `valid_*`, `available_*`, `resolved_*`, `effective_*`, or `loaded_*` used where the PR says "explicitly enabled" or "user opted in."
- A guardrail flag still disables prompt/display behavior but no longer disables side effects.
- Tests cover the desired positive path but not the old negative path.
