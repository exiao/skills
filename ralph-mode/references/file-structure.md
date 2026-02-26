# File Structure

Create this structure for each Ralph Mode project:

```
project-root/
├── IMPLEMENTATION_PLAN.md     # Shared state, updated each iteration
├── AGENTS.md                  # Build/test/lint commands (~60 lines)
├── specs/                     # Requirements (one file per topic)
│   ├── topic-a.md
│   └── topic-b.md
├── src/                        # Application code
└── src/lib/                    # Shared utilities
```

### IMPLEMENTATION_PLAN.md

Priority task list - single source of truth. Format:

```markdown
# Implementation Plan
