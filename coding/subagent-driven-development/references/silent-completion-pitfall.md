# Silent Completion Pitfall (delegate_task)

## The Problem

Subagents given abstract goals complete in 2-5 seconds, returning a summary of what they *would* do instead of actually doing it. They load skills, read some context, and return a plan. No files written.

This is the #1 failure mode for programmatic multi-phase agent pipelines (e.g., CPE Research Agent).

## Signals It Happened

- Task completed in <10s (real analysis takes 30-120s)
- No `write_file` calls in the subagent session
- Output directories remain empty
- Subagent's summary says "I would analyze..." or "Here's my plan..."

## Root Cause

The delegate_task goal reads like a planning prompt rather than an execution prompt. The subagent interprets it as "describe what you'd do" not "do it now."

## Fix: Explicit Tool Instructions + Absolute Paths + Verification

```python
# BAD — subagent "completes" in 3s, writes nothing
delegate_task(
    goal="Load skill lens-business. Read all files in workspace/raw/. Write analysis to workspace/analysis/business.md"
)

# GOOD — explicit tool calls, absolute paths, verification step
delegate_task(
    goal="Write the AVGO business quality analysis",
    context=f"""
    You must produce a written analysis file. Follow these steps exactly:

    1. Use read_file to load these files:
       - {workspace}/raw/info.json
       - {workspace}/raw/income.json
       - {workspace}/raw/metrics.json
       - {workspace}/raw/ratios.json

    2. Analyze the data for: revenue trends, margin trajectory, ROIC, competitive moat

    3. Use write_file to save your complete analysis to:
       {workspace}/analysis/business_quality.md

    4. Verify with terminal: ls -la {workspace}/analysis/business_quality.md
       (confirm file exists and is >1KB)

    Your task is NOT complete until the file exists on disk.
    """,
    toolsets=["terminal", "file", "skills"]
)
```

## Key Patterns

1. **Absolute paths always** — agent CWD is `~`, not your project directory
2. **Name the tools** — "Use read_file to...", "Use write_file to..."
3. **Add verification** — "Run ls -la to confirm the file exists"
4. **State completion criteria** — "Task is NOT complete until the file exists on disk"
5. **Provide file list explicitly** — don't say "read all files in dir", list them

## Observed in CPE Research Agent (2026-05-11)

- Phase 2 (ANALYZE) dispatched 3 delegate_tasks for lens analyses
- All 3 completed in 2-4 seconds each
- Zero analysis files written
- Parent agent had to retry with longer-running delegates that eventually produced output
- Second round took 5-8 seconds per subagent (still marginal), parent ended up doing most work inline
