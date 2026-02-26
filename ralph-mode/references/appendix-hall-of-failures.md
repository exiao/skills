# Appendix: Hall of Failures

Common anti-patterns observed:

| Anti-Pattern | Consequence | Prevention |
|--------------|-------------|------------|
| No progress logging | Parent agent cannot determine status | Mandatory PROGRESS.md |
| Silent failure | Work lost, time wasted | Explicit error logging |
| Overlapping sessions | File conflicts, corrupt state | Check/cleanup before spawn |
| Path assumptions | Wrong directory, wrong files | Explicit verification |
| No completion signal | Parent waits indefinitely | Clear COMPLETE status |
| Infinite iteration | Resource waste, no progress | Time limits + blockers |
| Complex initial prompts | Sub-agent never starts (empty session logs) | SIMPLIFY instructions |
