---
name: superpowers-coding
description: "Use when implementing any feature or bugfix (TDD required before writing code), encountering any bug, test failure, or unexpected behavior (systematic debugging before proposing fixes), creating isolated git worktrees, or executing independent plan tasks via sub-agents."
---

# Superpowers Coding

Covers four coding discipline skills: Test-Driven Development, Systematic Debugging, Git Worktrees, and Subagent-Driven Development.

---

## Test-Driven Development (superpowers-test-driven-development)

### Overview

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

**Violating the letter of the rules is violating the spirit of the rules.**

### When to Use

**Always:**
- New features
- Bug fixes
- Refactoring
- Behavior changes

**Exceptions (ask your human partner):**
- Throwaway prototypes
- Generated code
- Configuration files

Thinking "skip TDD just this once"? Stop. That's rationalization.

### The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete

### Red-Green-Refactor

#### RED — Write Failing Test

Write one minimal test showing what should happen.

```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };
  const result = await retryOperation(operation);
  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```

**Requirements:** One behavior. Clear name. Real code (no mocks unless unavoidable).

#### Verify RED — Watch It Fail

**MANDATORY. Never skip.**

```bash
npm test path/to/test.test.ts
```

Confirm: Test fails (not errors). Failure message is expected. Fails because feature missing (not typos).

**Test passes?** You're testing existing behavior. Fix test.

#### GREEN — Minimal Code

Write simplest code to pass the test. Don't add features, refactor other code, or "improve" beyond the test.

#### Verify GREEN — Watch It Pass

**MANDATORY.**

```bash
npm test path/to/test.test.ts
```

Confirm: Test passes. Other tests still pass. Output pristine (no errors, warnings).

**Test fails?** Fix code, not test.

#### REFACTOR — Clean Up

After green only: remove duplication, improve names, extract helpers. Keep tests green. Don't add behavior.

### Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| **Minimal** | One thing. "and" in name? Split it. | Tests multiple behaviors |
| **Clear** | Name describes behavior | `test('test1')` |
| **Shows intent** | Demonstrates desired API | Obscures what code should do |

### Why Order Matters

**"I'll write tests after to verify it works"** — Tests written after code pass immediately. Passing immediately proves nothing. Test-first forces you to see the test fail, proving it actually tests something.

**"Tests after achieve the same goals"** — No. Tests-after answer "What does this do?" Tests-first answer "What should this do?" Tests-after are biased by your implementation.

### Verification Checklist

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

Can't check all boxes? You skipped TDD. Start over.

### Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Already manually tested" | Ad-hoc ≠ systematic. No record, can't re-run. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "TDD will slow me down" | TDD faster than debugging. Pragmatic = test-first. |
| "Existing code has no tests" | You're improving it. Add tests for existing code. |

### Red Flags — STOP and Start Over

- Code before test
- Test after implementation
- Test passes immediately
- Can't explain why test failed
- "Tests after achieve the same purpose"
- "Keep as reference" or "adapt existing code"
- "Already spent X hours, deleting is wasteful"
- "This is different because..."

### Bug Fix Example

```typescript
// RED
test('rejects empty email', async () => {
  const result = await submitForm({ email: '' });
  expect(result.error).toBe('Email required');
});

// Verify RED: npm test → FAIL: expected 'Email required', got undefined

// GREEN
function submitForm(data: FormData) {
  if (!data.email?.trim()) {
    return { error: 'Email required' };
  }
}

// Verify GREEN: npm test → PASS
```

### When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write wished-for API. Write assertion first. |
| Test too complicated | Design too complicated. Simplify interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify design. |

### Testing Anti-Patterns

When adding mocks or test utilities, read `testing-anti-patterns.md` to avoid common pitfalls:
- Testing mock behavior instead of real behavior
- Adding test-only methods to production classes
- Mocking without understanding dependencies

### Final Rule

```
Production code → test exists and failed first
Otherwise → not TDD
```

No exceptions without your human partner's permission.

---

## Systematic Debugging (superpowers-systematic-debugging)

### Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

### The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

### When to Use

Use for ANY technical issue: test failures, bugs in production, unexpected behavior, performance problems, build failures, integration issues.

**Use ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work

### The Four Phases

#### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully** — don't skip past errors or warnings; read stack traces completely
2. **Reproduce Consistently** — can you trigger it reliably? What are the exact steps?
3. **Check Recent Changes** — what changed that could cause this? Git diff, recent commits, new dependencies
4. **Gather Evidence in Multi-Component Systems** — for systems with multiple components (CI → build → signing, API → service → database):
   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer
   Run once to gather evidence showing WHERE it breaks
   THEN analyze to identify failing component
   ```
5. **Trace Data Flow** — where does bad value originate? Trace backward up the call stack until you find the source. See `systematic-debugging/root-cause-tracing.md` for complete technique.

#### Phase 2: Pattern Analysis

1. **Find Working Examples** — locate similar working code in same codebase
2. **Compare Against References** — read reference implementations COMPLETELY, not skimming
3. **Identify Differences** — list every difference, however small
4. **Understand Dependencies** — what settings, config, environment does this need?

#### Phase 3: Hypothesis and Testing

1. **Form Single Hypothesis** — state clearly: "I think X is the root cause because Y"
2. **Test Minimally** — make the SMALLEST possible change to test hypothesis. One variable at a time.
3. **Verify Before Continuing** — did it work? Yes → Phase 4. Didn't work? Form NEW hypothesis.
4. **When You Don't Know** — say "I don't understand X." Don't pretend to know.

#### Phase 4: Implementation

1. **Create Failing Test Case** — simplest possible reproduction. Use superpowers:test-driven-development.
2. **Implement Single Fix** — address root cause. ONE change at a time. No "while I'm here" improvements.
3. **Verify Fix** — test passes? No other tests broken?
4. **If Fix Doesn't Work** — STOP. Count: How many fixes tried?
   - If < 3: Return to Phase 1 with new information
   - **If ≥ 3: STOP and question the architecture**
5. **If 3+ Fixes Failed: Question Architecture** — is this pattern fundamentally sound? Should we refactor vs. continue fixing symptoms? Discuss with human partner before attempting more fixes.

### Supporting Techniques

- **`systematic-debugging/root-cause-tracing.md`** — trace bugs backward through call stack
- **`systematic-debugging/defense-in-depth.md`** — add validation at multiple layers
- **`systematic-debugging/condition-based-waiting.md`** — replace timeouts with condition polling

### Red Flags — STOP and Follow Process

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "One more fix attempt" (when already tried 2+)
- Each fix reveals new problem in different place

**ALL of these mean: STOP. Return to Phase 1.**

### Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check. |
| "Just try this first" | First fix sets the pattern. Do it right. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "One more fix attempt" (after 2+) | 3+ failures = architectural problem. |

### Your Human Partner's Signals You're Doing It Wrong

**Watch for these redirections:**
- "Is that not happening?" — You assumed without verifying
- "Will it show us...?" — You should have added evidence gathering
- "Stop guessing" — You're proposing fixes without understanding
- "Ultrathink this" — Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) — Your approach isn't working

**When you see these:** STOP. Return to Phase 1.

### Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

### When Process Reveals "No Root Cause"

If systematic investigation reveals the issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

---

## Git Worktrees (superpowers-using-git-worktrees)

### Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

### Directory Selection Process

Follow this priority order:

#### 1. Check Existing Directories

```bash
ls -d .worktrees 2>/dev/null     # Preferred (hidden)
ls -d worktrees 2>/dev/null      # Alternative
```

If found: use that directory. If both exist, `.worktrees` wins.

#### 2. Check CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

If preference specified: use it without asking.

#### 3. Ask User

If no directory exists and no CLAUDE.md preference:

```
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/.config/superpowers/worktrees/<project-name>/ (global location)

Which would you prefer?
```

### Safety Verification

**MUST verify directory is ignored before creating project-local worktree:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:** Add appropriate line to .gitignore, commit the change, then proceed.

**Why critical:** Prevents accidentally committing worktree contents to repository.

### Creation Steps

```bash
# Detect project name
project=$(basename "$(git rev-parse --show-toplevel)")

# Create worktree with new branch
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"

# Run project setup (auto-detect)
if [ -f package.json ]; then npm install; fi
if [ -f Cargo.toml ]; then cargo build; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi
if [ -f go.mod ]; then go mod download; fi

# Verify clean baseline
npm test  # or cargo test / pytest / go test ./...
```

### Quick Reference

| Situation | Action |
|-----------|--------|
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check CLAUDE.md → Ask user |
| Directory not ignored | Add to .gitignore + commit |
| Tests fail during baseline | Report failures + ask |

### Integration

**Called by:** brainstorming (after design approval), subagent-driven-development, executing-plans

**Pairs with:** finishing-a-development-branch (cleanup after work complete)

---

## Subagent-Driven Development (superpowers-subagent-driven-development)

Execute plan by dispatching fresh subagent per task, with two-stage review after each: spec compliance review first, then code quality review.

**Core principle:** Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration

### When to Use

Use when you have an implementation plan, tasks are mostly independent, and you want to stay in the current session.

For parallel session execution instead, use superpowers:executing-plans.

### The Process

1. **Read plan, extract all tasks with full text, note context, create TodoWrite**
2. For each task:
   a. Dispatch implementer subagent (full task text + context) — use template at `subagent-driven/implementer-prompt.md`
   b. If subagent asks questions: answer clearly and completely before proceeding
   c. Implementer implements, tests, commits, self-reviews
   d. Dispatch spec compliance reviewer — use template at `subagent-driven/spec-reviewer-prompt.md`
   e. If spec issues found: implementer fixes → spec reviewer re-reviews
   f. Once spec ✅: dispatch code quality reviewer — use template at `subagent-driven/code-quality-reviewer-prompt.md`
   g. If quality issues found: implementer fixes → quality reviewer re-reviews
   h. Once quality ✅: mark task complete in TodoWrite
3. After all tasks: dispatch final code reviewer for entire implementation
4. Use superpowers:finishing-a-development-branch

### Prompt Templates

- `subagent-driven/implementer-prompt.md` — dispatch implementer subagent
- `subagent-driven/spec-reviewer-prompt.md` — dispatch spec compliance reviewer
- `subagent-driven/code-quality-reviewer-prompt.md` — dispatch code quality reviewer

### Example Workflow

```
You: I'm using Subagent-Driven Development to execute this plan.

[Read plan file once: docs/plans/feature-plan.md]
[Extract all 5 tasks with full text and context]
[Create TodoWrite with all tasks]

Task 1: Hook installation script
[Dispatch implementation subagent with full task text + context]

Implementer: "Before I begin - should the hook be installed at user or system level?"
You: "User level (~/.config/superpowers/hooks/)"
Implementer: [implements, tests, commits]

[Dispatch spec compliance reviewer]
Spec reviewer: ✅ Spec compliant

[Dispatch code quality reviewer]
Code reviewer: ✅ Approved

[Mark Task 1 complete]
...
```

### Advantages

- Fresh context per task (no confusion from accumulated state)
- Subagents follow TDD naturally
- Two-stage review: spec compliance, then code quality
- Review loops ensure fixes actually work
- No file reading overhead (controller provides full text)

### Red Flags

**Never:**
- Start implementation on main/master without explicit user consent
- Skip reviews (spec compliance OR code quality)
- Proceed with unfixed issues
- Dispatch multiple implementation subagents in parallel (conflicts)
- Make subagent read plan file (provide full text instead)
- Accept "close enough" on spec compliance
- **Start code quality review before spec compliance is ✅** (wrong order)

**If subagent asks questions:** Answer clearly before letting them proceed.

**If reviewer finds issues:** Implementer fixes → reviewer re-reviews. Don't skip the re-review.

### Integration

**Required before starting:** superpowers:using-git-worktrees

**Subagents should use:** superpowers:test-driven-development

**After all tasks:** superpowers:finishing-a-development-branch
