---
name: deploy-bloom
description: Use when deploying Bloom OTA updates via the bloom-updater pipeline.
---

# Deploy Bloom OTA Update

## Quick Reference

```bash
# Dry run (QA gates only, no deploy)
BLOOM_UPDATER_PATH=~/bloom-updater ~/clawd/bin/deploy-bloom --no-bump --dry-run

# Deploy without version bump
BLOOM_UPDATER_PATH=~/bloom-updater ~/clawd/bin/deploy-bloom --no-bump

# Deploy with patch/minor/major bump
BLOOM_UPDATER_PATH=~/bloom-updater ~/clawd/bin/deploy-bloom --patch
BLOOM_UPDATER_PATH=~/bloom-updater ~/clawd/bin/deploy-bloom --minor
BLOOM_UPDATER_PATH=~/bloom-updater ~/clawd/bin/deploy-bloom --major
```

## Prerequisites

- `bun` — frontend build tool (brew install oven-sh/bun/bun)
- `modal` — deployment CLI (uv tool install modal), profile `prompt-pm`
- `node_modules` — `cd ~/bloom/frontend && bun install`
- `~/bloom-updater` — bloom-updater repo cloned

## QA Pipeline (9 gates, all must pass)

1. **Git status** — verify branch, pull latest
2. **Lint** — `bun run lint` (0 errors allowed, warnings ok)
3. **Tests** — `bun run test` (all must pass)
4. **Build** — `bun run build` with `NODE_OPTIONS=--max-old-space-size=4096`
5. **Bundle sanity** — dist/ has index.html, reasonable file count
6. **Critical files** — JS bundles exist and aren't empty
7. **Bundle zip** — Capgo CLI creates zip
8. **Version check** — compare local vs live version
9. **Diff summary** — show recent frontend changes

## Deploy Flow

1. Back up current `bloom.zip` → `bloom.zip.bak`
2. Copy new bundle to `~/bloom-updater/static/bloom.zip`
3. Update version in `backend.py`
4. Run `setup.sh` (checksum generation)
5. Commit + push bloom-updater to GitHub
6. `modal deploy` to push to production
7. Health check the live endpoint
8. Auto-rollback if health check fails

## Safety Notes

- **Always confirm with user before deploying** if version gap is large or changes touch critical paths (auth, payments, update mechanism)
- OTA updates only touch the web bundle — can't break native code or backend
- **But** a broken UI may prevent the app from fetching the next update — QA must be thorough
- The script backs up and auto-rolls back on health check failure
- Default to `--no-bump` unless user specifies otherwise

## Rollback

If something goes wrong after deploy:
```bash
cd ~/bloom-updater
cp static/bloom.zip.bak static/bloom.zip
git add static/bloom.zip && git commit -m "Rollback" && git push origin main
make deploy
```

## Troubleshooting

- **Build SIGABRT**: Set `NODE_OPTIONS=--max-old-space-size=4096` (already in script)
- **Modal auth expired**: `modal token set --token-id <id> --token-secret <secret> --profile=prompt-pm`
- **Capgo CLI missing**: `cd ~/bloom/frontend && bun add -d @capgo/cli`
