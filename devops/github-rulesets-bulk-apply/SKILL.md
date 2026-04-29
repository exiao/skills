---
name: github-rulesets-bulk-apply
description: Apply a branch-protection ruleset (deletion + non_fast_forward, no bypass) to the default branch of every repo an account admins. Use when the user wants to protect all their repos from accidental branch deletion or force-push across an entire GitHub account/org footprint. Handles the GitHub Free private-repo limitation.
---

# Bulk-apply GitHub branch rulesets

## When to use

User wants "apply these rulesets to all my codebases" / "protect every repo" / "lock down main across the org" style requests. Safe, idempotent, skips archived repos.

## Enumerate admin-capable repos

```bash
gh api --paginate 'user/repos?affiliation=owner,organization_member&per_page=100' \
  --jq '.[] | select(.archived==false) | select(.permissions.admin==true) | [.full_name, .default_branch, .private] | @tsv' \
  > /tmp/repos.tsv
```

Filter rows with empty default_branch (repos with no pushed commits — rulesets can't apply).

## Ruleset payload

```json
{
  "name": "protect-default-branch",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"}
  ],
  "bypass_actors": []
}
```

`~DEFAULT_BRANCH` is a magic ref that always resolves to the repo's current default, so the ruleset survives default-branch renames.

## Apply loop

```bash
while IFS=$'\t' read -r repo default_branch private; do
  # Idempotency: skip if protect-default-branch already exists
  existing=$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name=="protect-default-branch") | .id' 2>/dev/null)
  if [ -n "$existing" ]; then
    echo "SKIP $repo (ruleset exists: $existing)"
    continue
  fi
  result=$(gh api "repos/$repo/rulesets" -X POST --input /tmp/ruleset.json 2>&1)
  if echo "$result" | grep -q '"id"'; then
    echo "OK   $repo"
  else
    echo "FAIL $repo: $(echo "$result" | head -1)"
  fi
done < /tmp/repos.tsv
```

## GitHub Free limitation (important)

**Private repos on Free plan reject ruleset creation** with:
> "Upgrade to GitHub Pro or make this repository public to enable this feature."

Same for orgs on the Free plan. The listing endpoint (`GET /repos/{repo}/rulesets`) on a Free private repo returns 403 which the idempotency check above will misread as "ruleset exists." Fix: check specifically for a 200 response with matching name, not just any non-empty body. Or catch 403 during POST and surface clearly.

Upgrade URLs:
- Personal: https://github.com/settings/billing/plans
- Org: https://github.com/organizations/{ORG}/billing/plans

## Verification

```bash
# Confirm enforcement is active and nobody can bypass
gh api "repos/$repo/rulesets/$id" --jq '{name, enforcement, bypass: .current_user_can_bypass}'
# Expect: enforcement=active, bypass=never
```

## Attempt-delete test (proves it's real)

```bash
gh api -X DELETE "repos/$repo/git/refs/heads/$default_branch"
# Expect: 422 "GH013: Cannot delete this branch"
```
