# Design Review Patterns

Pitfalls caught during review that go beyond security/logic errors into design quality.
These are recurring anti-patterns the reviewer subagent should flag.

## Premature Specificity (Hardcoded Context)

When building features that operate on dynamic context (selected account, active user,
current date), do NOT bake specific values into the code even as "defaults" or "fallbacks".

### Anti-patterns caught in practice

| What was done wrong | What it should have been |
|---|---|
| `ALEVO_ACCOUNT_ID` env var with account-name regex fallback | Use the active admin context from the session — no env var needed |
| Hardcoded report IDs (`333`, `334`, `335`) in tests and PR body | Match by `dataset_id` string; use fake IDs in tests to prove decoupling |
| Property names `signedPremium2025` / `signedPremium2026` | `signedPremiumPrior` / `signedPremiumCurrent` — computed from `refDate` |
| Template text "2025 vs 2026 monthly" | "Prior vs Current Year" — chart legends already use dynamic labels |

### The principle

If a value is derived at runtime (current year, selected account, resolved report ID),
the code should never name variables, properties, or UI text after a specific instance of
that value. The test should prove the code works with *any* valid input, not just today's.

### Review checklist addition

- [ ] No env vars introduced for values that come from session/context
- [ ] No numeric IDs hardcoded that are resolved dynamically at runtime
- [ ] Property/variable names don't embed specific dates, years, or entity names
- [ ] Template/UI text doesn't hardcode values that the code computes dynamically
- [ ] Tests use synthetic/fake IDs to prove resolution is by logical key, not by ID

## Dead Code

Functions defined but never called. Common when porting from a static HTML template
where not all features are implemented yet.

- [ ] Every function/method in the diff is actually called somewhere
- [ ] Utility functions like `pct()`, `yearOf()` that were scaffolded but unused — remove them

## Dataset/API Resolver Pattern (Fintary-specific)

When building pages backed by the Reports API:
- Resolve by `dataset_id` string, never by numeric report `id`
- The numeric `id` changes per account; `dataset_id` is the stable contract
- Flow: `GET /reports` → find by `dataset_id` → use returned `id` for `GET /reports/{id}`
- Tests should use arbitrary fake IDs and assert on `dataset_id` matching
- Required vs optional datasets: fail early with actionable error listing missing `dataset_id`s
- Fallback chain for agent data: `pivoted` → `production` → `agentTotals`

(Source: Alevo Business Insights PR #87, May 2026)
