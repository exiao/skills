# Automated review final sweep

Use this when CI is green but the PR still shows `CHANGES_REQUESTED`, `BLOCKED`, or unresolved bot threads.

## Why this matters

Automated reviewers can leave feedback in several places at once:

- formal review bodies from `repos/:repo/pulls/:pr/reviews`
- top-level issue comments from `repos/:repo/issues/:pr/comments`
- inline review threads from GraphQL `reviewThreads`
- check output from `gh pr checks`

A later `claude-review` check can pass while older non-outdated review threads remain unresolved. GitHub can also show `CHANGES_REQUESTED` because of an older formal review even when the latest check is green. Do not call the PR clean until you have reconciled all of these sources.

## Final sweep commands

```bash
REPO=owner/repo
PR=123
OWNER=${REPO%/*}
NAME=${REPO#*/}

# Current aggregate state and checks
gh pr view "$PR" --repo "$REPO" \
  --json headRefOid,reviewDecision,mergeStateStatus,statusCheckRollup,url \
  --jq '{url,headRefOid,reviewDecision,mergeStateStatus,checks:[.statusCheckRollup[]? | {name:.name,status:.status,conclusion:.conclusion}]}'

# Latest formal review. Empty COMMENTED reviews are often created by thread replies.
gh api --paginate "repos/$REPO/pulls/$PR/reviews" \
  --slurp --jq 'add | sort_by(.submitted_at // "") | last | {author:.user.login,state:.state,body:(.body // "")}'

# Latest top-level issue comment. Automated reviewers often put the real summary here.
gh api --paginate "repos/$REPO/issues/$PR/comments" \
  --slurp --jq 'add | sort_by(.created_at // "") | last | {author:.user.login,created:.created_at,body:(.body // "")}'

# Unresolved, non-outdated threads
gh api graphql \
  -f query='query($owner: String!, $name: String!, $number: Int!) {
    repository(owner:$owner,name:$name){ pullRequest(number:$number){ reviewThreads(first:100){ nodes {
      id isResolved isOutdated path comments(last:1){nodes{author{login} body}}
    } } } }
  }' \
  -f owner="$OWNER" -f name="$NAME" -F number="$PR" > /tmp/pr_threads.json
python - <<'PY'
import json
nodes=json.load(open('/tmp/pr_threads.json'))['data']['repository']['pullRequest']['reviewThreads']['nodes']
un=[n for n in nodes if not n['isResolved'] and not n['isOutdated']]
print('count', len(un))
for n in un:
    c=n['comments']['nodes'][-1]
    print(n['id'], n['path'], c['author']['login'], c['body'][:220].replace('\n',' '))
PY
```

## Decision rules

1. If CI is green but the latest issue comment or review body lists `Must Fix` items, keep working. The PR is not clean.
2. If `reviewDecision` is `CHANGES_REQUESTED`, inspect the latest review and latest issue comment before assuming it is stale. New actionable comments may live only in issue comments.
3. If unresolved non-outdated threads remain, handle each one:
   - concrete bug or broken link: fix it and push
   - already fixed by current HEAD: reply with the fixing SHA, then resolve
   - stale summary thread now superseded by a later passing review: reply that the latest review/check passed and resolve only if the referenced issue is demonstrably fixed
   - follow-up or intent question: leave unresolved and report it as non-blocking
4. If the latest formal review is an empty `COMMENTED` review, ignore it as substance, but do not skip the latest issue comment. Thread replies can create empty formal reviews.
5. Only report `Ready to merge` when checks pass and unresolved non-outdated actionable threads count is zero.