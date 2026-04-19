---
name: dependabot-stuck-pr-rebase
description: Manually rebase Dependabot PRs that are stuck in CONFLICTING state because @dependabot rebase / recreate isn't firing. Use when multiple Dependabot PRs show mergeStateStatus=CONFLICTING after main has moved, and waiting for Dependabot is taking too long.
---

# Unstick Dependabot PRs by rebasing them yourself

## When to use

- 2+ Dependabot PRs are `CONFLICTING` after main moved (e.g., after merging a big branch-consolidation PR)
- `@dependabot rebase` or `@dependabot recreate` comments haven't produced action in 10+ minutes
- User says "just do it yourself"

Don't use for single-PR conflicts — commenting `@dependabot rebase` is fine there.

## Triage: is the bump still needed?

Before rebasing, check current main's version vs the PR's bump target. If main has caught up or passed:

```bash
# For Rust/Cargo:
grep '^name = "clap"' -A1 Cargo.lock
# For Node:
jq '.dependencies.clap' package.json
```

Close stale PRs with a comment explaining main already has equal-or-newer.

## Rebase workflow (Cargo example)

Requires the relevant toolchain to regenerate lockfiles. If not local, use Docker:

```bash
# One-shot rust container for the whole batch
docker run --rm -d --name rustbox -v $(pwd):/work -w /work \
  rust:1-slim sleep 3600
```

For each stuck PR:

```bash
PR=9
BRANCH=$(gh pr view $PR --json headRefName --jq .headRefName)
NEW_VERSION=4.5.60  # from PR title
DEP=clap

git fetch origin
git checkout -B $BRANCH origin/main

# Apply just the Cargo.toml bump — ignore dependabot's stale Cargo.lock
sed -i.bak -E "s/^($DEP = \")[^\"]+/\1$NEW_VERSION/" Cargo.toml
rm Cargo.toml.bak

# Regenerate lockfile cleanly against current main
docker exec rustbox cargo update -p $DEP --precise $NEW_VERSION

git add Cargo.toml Cargo.lock
git commit -m "Bump $DEP to $NEW_VERSION"
git push --force-with-lease origin $BRANCH
```

Force-push is required (Dependabot branches have their own history you're overwriting). `--force-with-lease` keeps you safe if Dependabot did push something while you weren't looking.

## After push

CI kicks off automatically. Watch with `gh pr checks $PR --watch`. When green, squash-merge and delete branch. Dependabot will detect its branch is gone and auto-close the PR.

## Don'ts

- Don't try to cherry-pick Dependabot's commit — the Cargo.lock diff is against old main and will conflict.
- Don't edit Cargo.lock by hand. Always regenerate with the real toolchain.
- Don't skip `--force-with-lease`; a plain `--force` will clobber concurrent Dependabot activity silently.

## Generalization

Same pattern works for any lockfile-ecosystem PR:

| Ecosystem | Manifest | Lockfile | Update command |
|---|---|---|---|
| Cargo | `Cargo.toml` | `Cargo.lock` | `cargo update -p <dep> --precise <ver>` |
| npm | `package.json` | `package-lock.json` | `npm install <dep>@<ver>` |
| pnpm | `package.json` | `pnpm-lock.yaml` | `pnpm up <dep>@<ver>` |
| Python/Poetry | `pyproject.toml` | `poetry.lock` | `poetry add <dep>@<ver>` |
| Bundler | `Gemfile` | `Gemfile.lock` | `bundle update <dep>` |
| Go modules | `go.mod` | `go.sum` | `go get <dep>@<ver> && go mod tidy` |

For GitHub Actions bumps (`actions/checkout` etc.), there's no lockfile — just edit the workflow YAML.
