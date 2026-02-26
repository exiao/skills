#!/bin/bash
set -euo pipefail

# deploy-bloom: Safe OTA deployment wrapper with QA gates
# Usage: deploy-bloom [--no-bump|--patch|--minor|--major] [--skip-confirm] [--dry-run]

BLOOM_DIR="${BLOOM_DIR:-$HOME/bloom}"
FRONTEND_DIR="$BLOOM_DIR/frontend"
UPDATER_DIR="${BLOOM_UPDATER_PATH:-$HOME/bloom-updater}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BUMP_FLAG="--no-bump"
SKIP_CONFIRM=false
DRY_RUN=false
BACKUP_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-bump) BUMP_FLAG="--no-bump"; shift ;;
        --patch) BUMP_FLAG="--patch"; shift ;;
        --minor) BUMP_FLAG="--minor"; shift ;;
        --major) BUMP_FLAG="--major"; shift ;;
        --skip-confirm) SKIP_CONFIRM=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --help) echo "Usage: deploy-bloom [--no-bump|--patch|--minor|--major] [--skip-confirm] [--dry-run]"; exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

step()    { echo -e "${BLUE}[GATE]${NC} $1"; }
pass()    { echo -e "${GREEN}  ✅ $1${NC}"; }
fail()    { echo -e "${RED}  ❌ $1${NC}"; }
warn()    { echo -e "${YELLOW}  ⚠️  $1${NC}"; }

abort() {
    fail "$1"
    echo -e "${RED}DEPLOY ABORTED${NC}"
    exit 1
}

# ============================================
# PRE-DEPLOY QA GATES
# ============================================

echo ""
echo "🚀 Bloom OTA Deploy — QA Pipeline"
echo "=================================="
echo ""

# Gate 1: Pull latest and check branch
step "Gate 1: Git status"
cd "$BLOOM_DIR"
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != "master" && "$BRANCH" != "main" ]]; then
    warn "On branch '$BRANCH' (not master/main)"
    if [[ "$SKIP_CONFIRM" == "false" ]]; then
        echo "  Deploy from non-main branch? (y/N): "
        read -r REPLY
        [[ ! "$REPLY" =~ ^[Yy]$ ]] && abort "User cancelled — switch to master first"
    fi
fi
git pull origin "$BRANCH" --ff-only 2>/dev/null || warn "Could not fast-forward (may have local commits)"
pass "Branch: $BRANCH"

# Gate 2: Frontend lint
step "Gate 2: Frontend lint"
cd "$FRONTEND_DIR"
if bun run lint 2>&1 | tail -5; then
    pass "Lint passed"
else
    abort "Lint failed — fix errors before deploying"
fi

# Gate 3: Frontend tests
step "Gate 3: Frontend tests"
cd "$FRONTEND_DIR"
if bun run test 2>&1 | tail -10; then
    pass "Tests passed"
else
    abort "Tests failed — fix before deploying"
fi

# Gate 4: Build
step "Gate 4: Frontend build"
cd "$FRONTEND_DIR"
export NODE_OPTIONS="--max-old-space-size=4096"
if bun run build 2>&1 | tail -5; then
    pass "Build succeeded"
else
    abort "Build failed — fix compilation errors"
fi

# Gate 5: Bundle sanity check
step "Gate 5: Bundle sanity check"
cd "$FRONTEND_DIR"
if [[ ! -d "dist" ]]; then
    abort "dist/ directory not found after build"
fi
if [[ ! -f "dist/index.html" ]]; then
    abort "dist/index.html missing — build output is broken"
fi
DIST_SIZE=$(du -sh dist | cut -f1)
FILE_COUNT=$(find dist -type f | wc -l | tr -d ' ')
pass "dist/ contains $FILE_COUNT files ($DIST_SIZE)"

# Gate 6: Check for JS errors in built output
step "Gate 6: Critical file check"
# Verify key JS bundles exist and aren't empty
JS_COUNT=$(find dist/assets -name "*.js" -size +0 2>/dev/null | wc -l | tr -d ' ')
CSS_COUNT=$(find dist/assets -name "*.css" -size +0 2>/dev/null | wc -l | tr -d ' ')
if [[ "$JS_COUNT" -eq 0 ]]; then
    abort "No JS bundles found in dist/assets/"
fi
if [[ "$CSS_COUNT" -eq 0 ]]; then
    warn "No CSS files found in dist/assets/ (might be inlined)"
fi
pass "$JS_COUNT JS bundles, $CSS_COUNT CSS files"

# Gate 7: Create zip bundle
step "Gate 7: Create bundle zip"
cd "$FRONTEND_DIR"
bunx @capgo/cli bundle zip --path dist 2>&1 | tail -3
ZIP_FILE=$(find . -maxdepth 1 -name "*.zip" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
if [[ -z "$ZIP_FILE" ]]; then
    abort "Bundle zip not created"
fi
ZIP_SIZE=$(du -sh "$ZIP_FILE" | cut -f1)
pass "Bundle: $(basename "$ZIP_FILE") ($ZIP_SIZE)"

# Gate 8: Version check
step "Gate 8: Version check"
DEPLOY_VERSION=$(grep -o "version: '[0-9]*\.[0-9]*\.[0-9]*'" "$FRONTEND_DIR/capacitor.config.ts" | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
CURRENT_LIVE=$(grep 'BLOOM_CURRENT_VERSION_BUILD' "$UPDATER_DIR/backend.py" | grep -o '"[0-9]*\.[0-9]*\.[0-9]*"' | tr -d '"' || echo "unknown")
pass "Deploying: v$DEPLOY_VERSION (currently live: v$CURRENT_LIVE)"

# Gate 9: Diff summary
step "Gate 9: Change summary since last deploy"
cd "$BLOOM_DIR"
COMMIT_COUNT=$(git log --oneline "origin/$BRANCH"..HEAD 2>/dev/null | wc -l | tr -d ' ')
if [[ "$COMMIT_COUNT" -gt 0 ]]; then
    warn "$COMMIT_COUNT unpushed commits"
    git log --oneline "origin/$BRANCH"..HEAD 2>/dev/null | head -10
fi
# Show recent commits touching frontend
RECENT=$(git log --oneline -10 -- frontend/ 2>/dev/null)
echo "  Recent frontend changes:"
echo "$RECENT" | sed 's/^/    /'
pass "Diff reviewed"

echo ""
echo "=================================="
echo -e "${GREEN}All QA gates passed!${NC}"
echo "=================================="
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}DRY RUN — would deploy v$DEPLOY_VERSION now${NC}"
    # Cleanup zip
    rm -f "$FRONTEND_DIR/$ZIP_FILE"
    exit 0
fi

# ============================================
# DEPLOY
# ============================================

# Backup current bundle
step "Backing up current bundle"
if [[ -f "$UPDATER_DIR/static/bloom.zip" ]]; then
    BACKUP_FILE="$UPDATER_DIR/static/bloom.zip.bak"
    cp "$UPDATER_DIR/static/bloom.zip" "$BACKUP_FILE"
    pass "Backed up to bloom.zip.bak"
else
    warn "No existing bundle to back up"
fi

# Copy new bundle
step "Copying bundle to bloom-updater"
cd "$UPDATER_DIR"
git pull origin main 2>/dev/null || true
cp "$FRONTEND_DIR/$ZIP_FILE" "$UPDATER_DIR/static/bloom.zip"
pass "Bundle copied"

# Update version
step "Updating version in backend.py"
python3 "$FRONTEND_DIR/scripts/sync-version.py" "$DEPLOY_VERSION"
pass "Version updated to $DEPLOY_VERSION"

# Run setup if exists
if [[ -f "$UPDATER_DIR/setup.sh" ]]; then
    step "Running setup.sh"
    chmod +x "$UPDATER_DIR/setup.sh"
    ./setup.sh 2>&1 | tail -3
    pass "Setup complete"
fi

# Commit and push
step "Committing and pushing bloom-updater"
cd "$UPDATER_DIR"
git add static/bloom.zip backend.py
git commit -m "Deploy Bloom app version $DEPLOY_VERSION

🚀 Automated deployment via Kit
QA gates: lint ✅ tests ✅ build ✅ bundle ✅" || warn "Nothing to commit"
git push origin main
pass "Pushed to GitHub"

# Deploy to Modal
step "Deploying to Modal"
cd "$UPDATER_DIR"
make deploy 2>&1 | tail -10
pass "Deployed to Modal"

# ============================================
# POST-DEPLOY HEALTH CHECK
# ============================================

step "Post-deploy health check"
sleep 3  # Give Modal a moment

# Check if the endpoint responds
HEALTH_URL="https://prompt-pm--bloom-updater.modal.run"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" --max-time 10 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "301" || "$HTTP_CODE" == "302" ]]; then
    pass "Endpoint responding (HTTP $HTTP_CODE)"
else
    fail "Endpoint returned HTTP $HTTP_CODE"
    if [[ -n "$BACKUP_FILE" && -f "$BACKUP_FILE" ]]; then
        warn "Rolling back to previous bundle..."
        cp "$BACKUP_FILE" "$UPDATER_DIR/static/bloom.zip"
        cd "$UPDATER_DIR"
        git add static/bloom.zip
        git commit -m "Rollback: revert to previous bundle (health check failed)" || true
        git push origin main || true
        make deploy 2>&1 | tail -5
        fail "ROLLED BACK — previous version restored"
    fi
    exit 1
fi

# Cleanup
rm -f "$FRONTEND_DIR/$ZIP_FILE"
rm -f "$BACKUP_FILE"

echo ""
echo "=================================="
echo -e "${GREEN}🎉 Deploy complete! v$DEPLOY_VERSION is live${NC}"
echo "=================================="
