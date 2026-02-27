---
name: superpowers-writing-skills
description: Use when creating, editing, or verifying agent skills before deployment.
---
# Writing Skills

## Purpose

This skill applies **Test-Driven Development to process documentation**. You write test cases (pressure scenarios), watch agents fail without the skill, write the skill, verify agents now comply, then refactor to close loopholes. If you didn't watch an agent fail without the skill first, you don't know if the skill teaches the right thing.

**Prerequisite:** Understand `superpowers:test-driven-development` before using this skill. That skill defines the RED-GREEN-REFACTOR cycle this skill adapts to documentation.

## What Is a Skill?

A **skill** is a reusable reference guide for proven techniques, patterns, or tools — helping future Claude instances find and apply effective approaches.

- **Skills ARE:** Reusable techniques, patterns, tools, reference guides
- **Skills ARE NOT:** Narratives about how you solved a problem once

**Where skills live:** Agent-specific directories (`~/.claude/skills` for Claude Code, `~/.agents/skills/` for Codex)

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

This applies to new skills AND edits to existing skills. No exceptions — not for "simple additions," "documentation updates," or "just adding a section." Write skill before testing? Delete it. Start over.

## SKILL.md Structure

### Frontmatter (YAML)
- Only two fields: `name` and `description` (max 1024 chars total)
- `name`: letters, numbers, hyphens only (no parentheses or special chars)
- `description`: starts with "Use when..." — describes **triggering conditions only**, never summarizes workflow or process

```markdown
---
name: Skill-Name-With-Hyphens
description: Use when [specific triggering conditions and symptoms]
---

# Skill Name
```

### Body Content
- Clear overview with core principle
- Address the specific failure patterns identified in RED phase
- Keywords throughout for search (errors, symptoms, tools)
- One excellent example (not multi-language sprawl)
- Common mistakes section
- Small flowchart only if decision logic is non-obvious
- No narrative storytelling

## Core Workflow (TDD Cycle)

### 🔴 RED — Write Failing Test First
1. Create pressure scenarios (3+ combined pressures for discipline skills)
2. Run scenarios **without** the skill — document baseline behavior verbatim
3. Identify patterns in failures and rationalizations

### 🟢 GREEN — Write Minimal Skill
1. Name with only letters/numbers/hyphens
2. YAML frontmatter: `name` + `description` only (max 1024 chars)
3. Description: "Use when..." with specific triggers/symptoms, third person
4. Content directly addresses baseline failures from RED phase
5. Run scenarios **with** the skill — verify agents now comply

### 🔵 REFACTOR — Close Loopholes
1. Identify new rationalizations from testing
2. Add explicit counters for discipline skills
3. Build rationalization table from all test iterations
4. Create red flags list
5. Re-test until bulletproof

## Skill Creation Checklist

**RED Phase:**
- [ ] Pressure scenarios created (3+ combined pressures)
- [ ] Baseline behavior documented verbatim (ran without skill)
- [ ] Failure patterns identified

**GREEN Phase:**
- [ ] Name: letters/numbers/hyphens only
- [ ] Frontmatter: only `name` + `description`, max 1024 chars
- [ ] Description: "Use when..." + specific triggers, third person
- [ ] Keywords throughout for search
- [ ] Addresses specific baseline failures
- [ ] One excellent example
- [ ] Agents now comply (ran with skill)

**REFACTOR Phase:**
- [ ] New rationalizations identified and countered
- [ ] Common mistakes section added
- [ ] Re-tested until bulletproof

**Deployment:**
- [ ] Committed and pushed to git
- [ ] Consider contributing via PR if broadly useful

## Output Format

A `SKILL.md` file with YAML frontmatter + structured content that directly causes agents to avoid the failure patterns documented in the RED phase. Supporting reference files in `references/` for heavy content.

---

## References

This skill content is modularized into reference docs for readability.

- [Overview](references/overview.md)
- [What is a Skill?](references/what-is-a-skill.md)
- [TDD Mapping for Skills](references/tdd-mapping-for-skills.md)
- [When to Create a Skill](references/when-to-create-a-skill.md)
- [Skill Types](references/skill-types.md)
- [Directory Structure](references/directory-structure.md)
- [SKILL.md Structure](references/skill-md-structure.md)
- [Overview](references/overview-2.md)
- [When to Use](references/when-to-use.md)
- [Core Pattern (for techniques/patterns)](references/core-pattern-for-techniques-patterns.md)
- [Quick Reference](references/quick-reference.md)
- [Implementation](references/implementation.md)
- [Common Mistakes](references/common-mistakes.md)
- [Real-World Impact (optional)](references/real-world-impact-optional.md)
- [Claude Search Optimization (CSO)](references/claude-search-optimization-cso.md)
- [Flowchart Usage](references/flowchart-usage.md)
- [Code Examples](references/code-examples.md)
- [File Organization](references/file-organization.md)
- [The Iron Law (Same as TDD)](references/the-iron-law-same-as-tdd.md)
- [Testing All Skill Types](references/testing-all-skill-types.md)
- [Common Rationalizations for Skipping Testing](references/common-rationalizations-for-skipping-testing.md)
- [Bulletproofing Skills Against Rationalization](references/bulletproofing-skills-against-rationalization.md)
- [Red Flags - STOP and Start Over](references/red-flags-stop-and-start-over.md)
- [RED-GREEN-REFACTOR for Skills](references/red-green-refactor-for-skills.md)
- [Anti-Patterns](references/anti-patterns.md)
- [STOP: Before Moving to Next Skill](references/stop-before-moving-to-next-skill.md)
- [Skill Creation Checklist (TDD Adapted)](references/skill-creation-checklist-tdd-adapted.md)
- [Discovery Workflow](references/discovery-workflow.md)
- [The Bottom Line](references/the-bottom-line.md)
