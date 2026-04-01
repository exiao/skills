---
name: skill-audit
description: "Audit and score any skill against best practices. Use when: audit this skill, review this skill, check this skill, score this skill, is this skill good, skill health check, skill review, rate this skill. Takes a skill directory path, evaluates structure/content/patterns against a checklist, and outputs a scorecard with specific fixes."
---

# Skill Audit

Evaluate a skill against the checklist in [references/checklist.md](references/checklist.md). Read that file first.

## Process

1. **Locate the skill.** Get the path from the user. Read the entire directory: SKILL.md, all subdirectories, all files.
2. **Run the checklist.** Score each of the 10 items (S1-S4, C1-C4, D1-D2). Each item is 1 point. Binary: pass or fail.
3. **Classify the skill type.** Determine which type it is (Library/API, Verification, Data Fetching, Business Process, Scaffolding). If it doesn't fit cleanly, note that.
4. **Generate the scorecard.** Use the format below.
5. **Offer to fix.** List recommended actions in priority order. Ask before making any changes.

## Scorecard Format

```
# Skill Audit: [skill-name]
## Type: [skill type]
## Score: [X]/10

### ✅ Passing
- [item]: [brief note on what's good]

### ⚠️ Warnings
- [item]: [what's borderline and why]

### ❌ Failing
- [item]: [what's wrong + specific fix]

### Recommended Actions (priority order)
1. [highest impact fix]
2. [next fix]
3. [next fix]
```

## Scoring Rules

- Be honest. A typical first-draft skill scores 4-6/10.
- Don't inflate scores to be nice. The audit is useless if everything passes.
- For D2 (Advanced Patterns): score as pass if the skill doesn't need those patterns. Only fail if it needs them and doesn't use them.
- When in doubt, fail. It's better to flag something that turns out fine than miss a real issue.

## Gotchas

- Don't confuse this with skill-improver. Skill-improver runs the skill repeatedly and evals output quality. This audits the skill's structure and design.
- Don't confuse this with skill-creator. Skill-creator builds skills. This reviews them.
- Some skills are intentionally minimal (a 20-line SKILL.md with no references). That's fine if the task is simple. Don't penalize brevity when the skill's job is small.
- The description field is the #1 thing people get wrong. It's a routing instruction for the model, not a human-readable summary. Audit it critically.
