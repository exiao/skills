# NEW: Session Initialization Best Practices (2025-02-07)

### Problem: Sub-agents spawn but don't execute
**Evidence:** Empty session logs (2 bytes), no tool calls, 0 tokens used

### Root Causes
1. **Instructions too complex** - Overwhelms isolated session initialization
2. **No clear execution trigger** - Agent doesn't know to start
3. **Branching logic** - "If X do Y, if Z do W" confuses task selection
4. **Multiple files mentioned** - Can't decide which to start with

### Fix: SIMPLIFIED Ralph Task Template

```markdown
