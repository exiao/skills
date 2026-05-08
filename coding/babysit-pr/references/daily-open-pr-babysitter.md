# Daily Open PR Babysitter

Use this when a cron asks to babysit all open PRs involving the user.

## Qualification sweep

1. Enumerate open PRs:
   ```bash
   gh search prs --state=open --involves=@me --limit=100 \
     --json=repository,number,title,updatedAt,url,author > /tmp/prs.json
   ```
2. Compute the 72h cutoff with Python when portability matters. GNU/BSD `date` flags differ:
   ```bash
   python3 - <<'PY'
   import datetime
   print((datetime.datetime.now(datetime.timezone.utc)-datetime.timedelta(hours=72)).isoformat().replace('+00:00','Z'))
   PY
   ```
3. For each PR, collect checks. `gh pr checks --json` is version-sensitive, so if the requested fields fail or return empty, fall back to:
   ```bash
   gh pr view $PR --repo $REPO \
     --json statusCheckRollup,mergeStateStatus,reviewDecision,headRefOid
   ```
4. Qualify PRs that are recent or have any non-green CI. Treat skipped checks as non-blocking.

## Delegation discipline

- Respect the runtime's actual `max_concurrent_children`. If 5-way delegation is requested but the runtime caps at 3, batch PRs in groups of 3 rather than stopping.
- Subagents frequently time out on large PRs after doing useful work. A timeout is not a failure report. The parent should run a verification sweep before finalizing.
- If a subagent says it pushed a fix but could not poll CI or resolve threads, the parent owns the follow-up: check `gh pr view`, fetch unresolved GraphQL threads, resolve only the thread fixed by the pushed commit, then report the true current state.
- Do not trust child summaries alone for final status. Verify every qualifying PR at the end with `gh pr view --json statusCheckRollup,mergeStateStatus,reviewDecision,headRefOid` plus unresolved review-thread count.

## Final verification sweep

For every qualifying PR, run:

```bash
gh pr view $PR --repo $REPO \
  --json url,title,headRefOid,reviewDecision,mergeStateStatus,isDraft,statusCheckRollup \
  --jq '{url,title,headRefOid,reviewDecision,mergeStateStatus,isDraft,checks:[.statusCheckRollup[]? | {name:.name, status:(.status // .state), conclusion:.conclusion}]}'

OWNER=${REPO%/*}; NAME=${REPO#*/}
gh api graphql \
  -f query='query($owner:String!,$name:String!,$number:Int!){ repository(owner:$owner,name:$name){ pullRequest(number:$number){ reviewThreads(first:100){ nodes{ id isResolved isOutdated path line comments(last:1){nodes{author{login} body}} } } } } }' \
  -f owner="$OWNER" -f name="$NAME" -F number=$PR \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false)] | {unresolved:length, threads:.[:5]}'
```

Use this sweep to classify results:
- `ready`: CI green or skipped, merge state clean, approved or no blocking review, zero unresolved actionable threads.
- `pushed fix`: a commit was pushed and CI is pending or a bot re-review is pending.
- `blocked`: current review decision is changes requested with unresolved actionable issues that are too large or ambiguous for cron.
- `monitoring`: CI still pending after reasonable wait.

## Resolving a timed-out child’s fixed thread

If a child pushed a fix and left an outdated bot thread unresolved, reply and resolve it from the parent:

```bash
gh api graphql \
  -f query='mutation($threadId: ID!, $body: String!) { addPullRequestReviewThreadReply(input: { pullRequestReviewThreadId: $threadId, body: $body }) { comment { id } } }' \
  -f threadId="$THREAD_ID" \
  -f body="Resolved -- fixed in $SHORT_SHA: <specific evidence>"

gh api graphql \
  -f query='mutation($threadId: ID!) { resolveReviewThread(input: { threadId: $threadId }) { thread { isResolved } } }' \
  -f threadId="$THREAD_ID"
```

Only do this for the exact issue fixed by the commit. Leave product-intent questions and follow-up suggestions unresolved but mention them in the digest.
