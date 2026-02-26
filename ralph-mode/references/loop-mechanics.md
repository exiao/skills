# Loop Mechanics

### Outer Loop (You coordinate)

Your job as main agent: engineer setup, observe, course-correct.

1. **Don't allocate work to main context** - Spawn sub-agents
2. **Let Ralph Ralph** - LLM will self-identify, self-correct
3. **Use protection** - Sandbox is your security boundary
4. **Plan is disposable** - Regenerate when wrong/stale
5. **Move outside the loop** - Sit and watch, don't micromanage

### Inner Loop (Sub-agent executes)

Each sub-agent iteration:
1. **Study** - Read plan, specs, relevant code
2. **Select** - Pick most important uncompleted task
3. **Implement** - Write code, one task only
4. **Validate** - Run tests, lint, typecheck (backpressure)
5. **Update** - Mark task done, note discoveries, commit
6. **Exit** - Next iteration starts fresh

### Stopping Conditions

Loop ends when:
- ✅ All IMPLEMENTATION_PLAN.md tasks completed
- ✅ All acceptance criteria met
- ✅ Tests passing, no blocking issues
- ⚠️ Max iterations reached (configure limit)
- 🛑 Manual stop (Ctrl+C)
