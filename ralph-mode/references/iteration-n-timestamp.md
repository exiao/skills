# Iteration [N] - [Timestamp]

### Status
- [ ] In Progress | [ ] Blocked | [ ] Complete

### What Was Done
- [Item 1]
- [Item 2]

### Blockers
- None | [Description]

### Next Step
[Specific next task from IMPLEMENTATION_PLAN.md]

### Files Changed
- `path/to/file.ts` - [brief description]
```

**Why:** External observers (parent agents, crons, humans) can tail one file instead of scanning directories or inferring state from session logs.

### 2. Session Isolation & Cleanup

Before spawning a new Ralph session:
- Check for existing Ralph sub-agents via `sessions_list`
- Kill or verify completion of previous sessions
- Do NOT spawn overlapping Ralph sessions on same codebase

**Anti-pattern:** Spawning Ralph v2 while v1 is still running = file conflicts, race conditions, lost work.

### 3. Explicit Path Verification

Never assume directory structure. At start of each iteration:

```typescript
// Verify current working directory
const cwd = process.cwd();
console.log(`Working in: ${cwd}`);

// Verify expected paths exist
if (!fs.existsSync('./src/app')) {
  console.error('Expected ./src/app, found:', fs.readdirSync('.'));
  // Adapt or fail explicitly
}
```

**Why:** Ralph may be spawned from different contexts with different working directories.

### 4. Completion Signal Protocol

When done, Ralph MUST:

1. Write final `PROGRESS.md` with "## Status: COMPLETE"
2. List all created/modified files
3. Exit cleanly (no hanging processes)

Example completion PROGRESS.md:

```markdown
# Ralph: Influencer Detail Page
