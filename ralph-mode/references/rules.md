# Rules

1. Do NOT look at other files
2. Do NOT "check first"
3. Make the change, validate, exit
```

### BEFORE (Bad - causes stalls):
```
Fix all TypeScript errors across these files:
- lib/db.ts has 2 errors
- lib/proposal-service.ts has 5 errors
- route.ts has errors
Check which ones to fix first, then...
```

### AFTER (Good - executes):
```
Fix lib/db.ts line 27:
Change: PoolClient to pg.PoolClient
Validate: npm run typecheck
Exit immediately after
```

### CRITICAL: Single File Rule
Each Ralph iteration gets ONE file. Not "all errors", not "check then decide". ONE file, ONE change, validate, exit.

### CRITICAL: Update PROGRESS.md
**MANDATORY:** After EVERY iteration, update PROGRESS.md with:
```markdown
