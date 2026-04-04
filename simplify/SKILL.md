# Simplify: Code Review and Cleanup

Review all changed files for reuse, quality, and efficiency.
Fix any issues found.

## Phase 1: Identify Changes
Run `git diff` (or `git diff HEAD` if staged) to see what changed.

## Phase 2: Launch Three Review Agents in Parallel
Uses the SubAgent tool to run all three concurrently,
each getting the full diff:

Agent 1: Code Reuse Review
- Search for existing utilities that could replace new code
- Flag duplicated functionality
- Flag inline logic that could use existing utils

Agent 2: Code Quality Review
- Redundant state, parameter sprawl, copy-paste
- Leaky abstractions, stringly-typed code
- Unnecessary JSX nesting, unnecessary comments

Agent 3: Efficiency Review
- Redundant computations, duplicate API calls, N+1 patterns
- Missed concurrency (sequential → parallel)
- Hot-path bloat, recurring no-op updates
- TOCTOU anti-patterns, memory leaks
- Overly broad operations

## Phase 3: Fix Issues
Aggregate findings from all three agents, fix each one.

Skip false positives without arguing.
