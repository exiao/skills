# Status: COMPLETE ✅

**Finished:** [ISO timestamp]

### Final Verification
- [x] TypeScript: Pass
- [x] Tests: Pass  
- [x] Build: Pass

### Files Created
- `src/app/feature/page.tsx`
- `src/app/api/feature/route.ts`

### Testing Instructions
1. Run: `npm run dev`
2. Visit: `http://localhost:3000/feature`
3. Verify: [specific checks]
```

### 5. Error Handling Requirements

If Ralph encounters unrecoverable errors:

1. Log to PROGRESS.md with "## Status: BLOCKED"
2. Describe blocker in detail
3. List attempted solutions
4. Exit cleanly (don't hang)

**Do not silently fail.** A Ralph that stops iterating with no progress log is indistinguishable from one still working.

### 6. Iteration Time Limits

Set explicit iteration timeouts:

```markdown
