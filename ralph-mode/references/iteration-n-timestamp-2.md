# Iteration [N] - [Timestamp]

### Status: Complete ✅ | Blocked ⛔ | Failed ❌

### What Was Done
- [Specific changes made]

### Validation
- [Test/lint/typecheck results]

### Next Step
- [What should happen next]
```

**Why this matters:** Cron job reads PROGRESS.md for status updates. If not updated, status appears stale/repetitive.

### Debugging Ralph Stalls
If Ralph stalls:
1. Check session logs (should show tool calls within 60s)
2. If empty after spawn → instructions too complex
3. Reduce: ONE file, ONE line number, ONE change
4. Shorter timeout forces smaller tasks (300s not 600s)

### Fixing Stale Status Reports
If cron reports same status repeatedly:
1. Check PROGRESS.md was updated by sub-agent
2. If not updated → sub-agent skipped documentation step
3. Update skill: Add "MANDATORY PROGRESS.md update" to prompt
4. Manual fix: Update PROGRESS.md to reflect actual state
