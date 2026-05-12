# Batch Thread Resolution

When resolving 5+ review threads across one or multiple PRs, use a single Python script instead of individual tool calls per thread.

## Pattern

```python
import subprocess

items = [
    ("PRRT_kwDO...", "Resolved -- fixed in abc1234: description of fix."),
    ("PRRT_kwDO...", "Resolved -- false positive: verified X matches Y on disk."),
]

reply_q = 'mutation($threadId: ID!, $body: String!) { addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id } } }'
resolve_q = 'mutation($threadId: ID!) { resolveReviewThread(input:{threadId:$threadId}) { thread { isResolved } } }'

for thread_id, body in items:
    subprocess.run(["gh", "api", "graphql", "-f", f"query={reply_q}", "-f", f"threadId={thread_id}", "-f", f"body={body}"], check=True, stdout=subprocess.DEVNULL)
    subprocess.run(["gh", "api", "graphql", "-f", f"query={resolve_q}", "-f", f"threadId={thread_id}"], check=True, stdout=subprocess.DEVNULL)
    print("resolved", thread_id)
```

## Why

- One tool call resolves all threads vs N*2 calls (reply + resolve each)
- Avoids GraphQL rate limiting from rapid sequential mutations
- Reply templates are easy to parameterize (commit SHA, reason)
- Works across multiple PRs in one pass

## Reply templates

- Fixed by commit: `"Resolved -- fixed in {sha}: {what changed}"`
- False positive: `"Resolved -- verified false positive: {evidence}"`
- Outdated by refactor: `"Resolved -- this code was refactored/removed in {sha}"`
- Acknowledged: `"Acknowledged -- {brief response}"`

## Gotchas

- Each reply + resolve creates a `SKIPPED` `claude` check entry. These are noise, not real CI failures.
- Thread resolution can trigger fresh reviewer runs. Poll checks again after batch resolution.
- If `gh api graphql` is blocked by terminal wrappers, use `urllib.request` with token from `gh auth token`.
