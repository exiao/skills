# Mutation Playbook

Detailed recipes for each mutation type. Pick the one that matches your diagnosis.

---

## 1. Prompt Rewording

**When to use:** Agent misinterprets instructions. Trace shows the agent understood
words differently than intended.

**Technique:**
- Identify the exact phrase that caused misinterpretation (from trace)
- Rewrite using more concrete, action-oriented language
- Replace abstract nouns with verbs: "perform analysis" → "read the file, count rows, compute mean"
- Add disambiguating context if a term has multiple meanings

**Example:**
```
Before: "Analyze the data and produce insights"
After:  "Read the CSV. For each numeric column: compute mean, median, min, max.
         Flag any column where stddev > 2x mean. Output a markdown table."
```

**Risk:** Low. Rewording rarely breaks things.
**Expected impact:** High when misinterpretation is the root cause.

---

## 2. Example Injection

**When to use:** Agent produces wrong format, wrong structure, or misses edge cases.
Traces show the agent guessing at output format.

**Technique:**
- Add 1-2 concrete input/output examples in the skill
- Place examples immediately after the instruction they illustrate
- Use realistic data, not toy examples
- Show both the happy path AND one edge case

**Example:**
```markdown
### Output Format

**Example 1 — Standard case:**
Input: "What's AAPL trading at?"
Output: AAPL: $187.42 (+1.2%) | Vol: 52.3M | MCap: $2.89T

**Example 2 — Market closed:**
Input: "What's AAPL trading at?" (asked on Saturday)
Output: AAPL: $186.20 (last close, Fri May 2) | Market reopens Mon 9:30 ET
```

**Risk:** Medium. Too many examples cause overfitting to example format.
**Expected impact:** Very high for format/structure issues. Less useful for logic errors.

**Guideline:** Max 3 examples per section. If you need more, the instruction is
probably unclear and needs rewording (Recipe #1) instead.

---

## 3. Tool Description Tweaks

**When to use:** Agent picks wrong tools. Trace shows it reaching for `WebSearch`
when it should use `terminal`, or calling tools in wrong order.

**Technique:**
- Add an explicit "Tool Priority" section listing tools in order of preference
- Specify which tool for which subtask
- Add negative guidance: "Do NOT use X for Y"

**Example:**
```markdown
### Tool Priority
1. `terminal` — for file operations, running scripts, git commands
2. `read_file` — for inspecting file contents before editing
3. `WebSearch` — ONLY for external/live data not available locally
Never use `WebSearch` to find information that exists in local files.
```

**Risk:** Low-medium. Over-constraining tool choice can hurt novel situations.
**Expected impact:** High when wrong-tool-selection is the dominant failure.

---

## 4. Workflow Reordering

**When to use:** Agent does the right things but in wrong order. Trace shows it
backtracking, re-reading files it already read, or producing outputs before
gathering all inputs.

**Technique:**
- Number the steps explicitly
- Add dependencies: "Step 3 requires output from Step 2"
- Move validation/checks earlier ("fail fast")
- Group related operations to minimize context switches

**Example:**
```
Before:
  1. Generate report
  2. Gather data
  3. Validate data
  4. Fix validation errors

After:
  1. Gather data
  2. Validate data (stop here if invalid, report errors)
  3. Generate report
```

**Risk:** Medium. Changing order can break implicit dependencies.
**Expected impact:** Medium. Fixes efficiency but rarely fixes correctness.

---

## 5. Constraint Addition

**When to use:** Agent goes off the rails. Trace shows runaway elaboration,
dangerous operations, or ignoring boundaries.

**Technique:**
- Add explicit constraints with reasoning (WHY the constraint exists)
- Place constraints near the relevant instruction, not in a separate section
- Use positive framing when possible: "Keep responses under 200 words" vs "Don't be verbose"

**Types of constraints:**
- **Length constraints:** "Output should be 3-5 bullet points"
- **Scope constraints:** "Only modify files in the `src/` directory"
- **Safety constraints:** "Never delete files without confirmation"
- **Quality constraints:** "Every claim must cite a source"
- **Time constraints:** "If no answer after 3 tool calls, report what you have"

**Risk:** Medium-high. Over-constraining kills flexibility. Add the minimum needed.
**Expected impact:** High for runaway/safety issues. Low for correctness issues.

---

## 6. Constraint Removal

**When to use:** Agent is overcautious, asks too many confirmations, or refuses
valid requests. Trace shows it stopping at a constraint that doesn't apply.

**Technique:**
- Identify the constraining language in the skill
- Assess if the constraint was added to fix a past issue (check history.json)
- If the constraint is still needed for some cases, narrow its scope instead of removing
- Replace absolute constraints with conditional ones

**Example:**
```
Before: "ALWAYS ask the user before running any shell command"
After:  "Ask before running destructive commands (rm, drop, delete).
         Read-only commands (ls, cat, grep, git status) can run without asking."
```

**Risk:** Medium. Removing constraints can reintroduce old failures.
**Expected impact:** High for overcaution issues. Always re-eval after removal.

---

## 7. Reference File Restructuring

**When to use:** SKILL.md is approaching size limits, or agent is overwhelmed by
too much information loaded at once.

**Technique:**
- Move detailed reference content to `references/` files
- Keep decision logic and workflow in SKILL.md
- Add clear pointers: "For detailed API reference, read `references/api.md`"
- Use progressive disclosure: agent reads reference only when needed

**When to move content to references:**
- Detailed examples (> 3 per section)
- API documentation
- Error code tables
- Platform-specific variations
- Historical context that's rarely needed

**When to keep content in SKILL.md:**
- Core workflow steps
- Decision trees
- Tool selection guidance
- Output format specs
- Constraints and guardrails

**Risk:** Low. Restructuring rarely changes behavior if pointers are clear.
**Expected impact:** Medium. Helps with size constraints and focus, less with correctness.

---

## 8. Conditional Branching

**When to use:** Skill handles multiple scenarios but treats them identically.
Traces show the agent applying wrong approach because it didn't distinguish cases.

**Technique:**
- Add explicit if/then decision points
- Use a decision table or flowchart
- Make the distinguishing criteria concrete and observable

**Example:**
```markdown
### Choosing the Approach

| Input Type | Approach |
|-----------|----------|
| Single file, < 1MB | Read entire file, process in memory |
| Single file, > 1MB | Stream line-by-line, process in chunks |
| Directory of files | List files first, process top 10 by size |
| URL | Fetch with web_extract, then treat as single file |
```

**Risk:** Medium. Too many branches make the skill brittle.
**Expected impact:** High when the skill conflates distinct scenarios.

---

## 9. Error Recovery Addition

**When to use:** Agent hits an error and gives up, or enters a retry loop.
Traces show the agent stuck after a tool failure.

**Technique:**
- Add fallback paths for common error scenarios
- Specify max retries (usually 2)
- Provide alternative approaches when primary fails

**Example:**
```markdown
If `terminal` command fails:
1. Read the error message. If permission denied → try with different path
2. If command not found → check if tool is installed, suggest installation
3. If timeout → retry once with simpler input
4. After 2 failures → report what you tried and ask the user
```

**Risk:** Low. Error recovery paths are additive.
**Expected impact:** Medium-high for robustness, less for happy-path correctness.

---

## 10. Trigger Description Optimization

**When to use:** Skill isn't being activated when it should be, or activates
for wrong queries. Not a SKILL.md body change — this modifies the frontmatter
`description` field.

**Technique:**
- Add more trigger phrases to description
- Add negative triggers ("not for X")
- Make the description more specific about WHEN to use it
- Use the skill-creator's description optimization loop for systematic improvement

**Risk:** Low for the skill's behavior. Can affect other skills' triggering.
**Expected impact:** High for activation issues. Zero for quality-once-activated.

---

## Mutation Combinations

Sometimes you need multiple recipes in one mutation. Valid combinations:

- **Rewording + Example** — clarify instruction AND show what you mean
- **Tool tweak + Workflow reorder** — fix tool choice AND step order
- **Constraint add + Error recovery** — add guardrails AND fallback paths

Avoid combining more than 2 recipes per mutation. If you need 3+, use population
mode (3 separate candidates each with 1-2 recipes).

---

## Anti-Patterns

Mutations that usually make things worse:

1. **Kitchen sink** — applying 5 recipes at once. Can't tell what helped.
2. **Cargo cult examples** — adding examples that don't match real failure patterns.
3. **Constraint avalanche** — adding 10 constraints because 1 case went wrong.
4. **Rewrite from scratch** — loses everything that was working. Always patch, never rebuild.
5. **Copying competitor format** — another skill's structure may not fit this task.
6. **Optimizing for train only** — mutation scores 0.95 on train but 0.60 on val = overfit.
