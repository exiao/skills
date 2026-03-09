---
name: demo-pr-feature
description: Capture a demo screenshot or video of a Bloom PR's feature, deploy to Surge.sh, and post the URL as a GitHub PR comment. Use after pushing a fix to a frontend PR.
---

# Demo PR Feature

After pushing a fix to a frontend Bloom PR, capture a screenshot of the feature in the iOS simulator (or web browser as fallback), generate a demo page, and post it to the PR.

## Usage

Called with a PR number. Can be run standalone or as a post-fix step in fix-bloom-prs.

## Step 1 — Check if PR is UI-facing

```bash
gh pr diff <PR_NUMBER> --repo Bloom-Invest/bloom --name-only | grep -E 'frontend/src/(components|screens|views|styles|locales)/'
```

If no matches → skip (backend-only PR). Exit silently.

## Step 2 — Map files to screen

Read `~/clawd/skills/demo-pr-feature/screen-map.json`. Check the PR's changed component paths against the routing table. Use the first match. If no match → use `home` screen.

## Step 3 — Capture

### Primary: iOS Simulator

```bash
# Check if simulator is booted
xcrun simctl list devices booted 2>/dev/null | grep -q Booted

# If not booted:
python ~/clawd/skills/ios-simulator/scripts/simctl_boot.py --name 'iPhone 16 Pro' --wait-ready

# Launch Bloom
python ~/clawd/skills/ios-simulator/scripts/app_launcher.py --launch com.bloom.invest
sleep 5

# Navigate to screen (use navigator.py)
python ~/clawd/skills/ios-simulator/scripts/navigator.py --screen <SCREEN_NAME>
sleep 3

# Screenshot
xcrun simctl io booted screenshot /tmp/pr-demo-<PR>.png

# Validate (must be >100KB)
SIZE=$(wc -c < /tmp/pr-demo-<PR>.png)
if [ "$SIZE" -lt 102400 ]; then
  echo "Screenshot too small, retrying..."
  sleep 3
  xcrun simctl io booted screenshot /tmp/pr-demo-<PR>.png
fi
```

### Fallback: Clawdbot Browser (spin up local dev server)

If simulator unavailable or screenshot <100KB after retry:

**1. Create a worktree for the PR branch:**
```bash
BRANCH=$(gh pr view <PR_NUMBER> --repo Bloom-Invest/bloom --json headRefName -q .headRefName)
git -C ~/bloom worktree add /tmp/bloom-worktrees/demo-<PR_NUMBER> $BRANCH
```

**2. Install deps and start the dev server, capturing the port:**
```bash
cd /tmp/bloom-worktrees/demo-<PR_NUMBER>/frontend
bun install --frozen-lockfile 2>/dev/null || bun install
bun start > /tmp/vite-dev-<PR_NUMBER>.log 2>&1 &
DEV_PID=$!
```

**3. Wait for it to be ready and detect the actual port:**
```bash
# Wait up to 60s for vite to print its Local URL
DEV_PORT=5173
for i in $(seq 1 30); do
  sleep 2
  PORT=$(grep -oE 'Local:.*http://localhost:([0-9]+)' /tmp/vite-dev-<PR_NUMBER>.log | grep -oE '[0-9]+$' | tail -1)
  if [ -n "$PORT" ]; then
    DEV_PORT=$PORT
    break
  fi
done
echo "Dev server on port $DEV_PORT"
```

**4. Open browser and navigate to the mapped screen:**
Use `browser action=open profile=clawd url=http://localhost:$DEV_PORT<path>` where `<path>` is the path portion from screen-map.json `webFallbackUrls`.
Navigate to the feature if needed using `browser action=act`.
Wait 3s for the page to settle.

**5. Take screenshot:**
Use `browser action=screenshot profile=clawd` — save the returned image to `/tmp/pr-demo-<PR>.png`.
Browser screenshots don't need the 100KB check — skip it.

**6. Kill dev server and clean up worktree:**
```bash
kill $DEV_PID 2>/dev/null
cd ~/bloom
git worktree remove /tmp/bloom-worktrees/demo-<PR_NUMBER> --force
git branch -D $BRANCH 2>/dev/null; true
```

## Step 4 — Optional: Short video for animation PRs

Check if PR title or changed files mention animation keywords: `Animation`, `animate`, `motion`, `canvas`.

If yes, record a short 3-5s screencast instead:
```bash
bash ~/clawd/scripts/bloom-render-feature.sh /tmp/pr-demo-<PR>.png "<PR_TITLE>" "<FEATURE_TITLE>"
# Output: /tmp/bloom-feature-video.mp4
```

## Step 5 — Generate HTML page

Create `/tmp/bloom-pr-<PR>-demo/index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PR #<PR> Demo — <PR_TITLE></title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #0a0a0a; color: #fff; font-family: -apple-system, sans-serif; display: flex; flex-direction: column; align-items: center; min-height: 100vh; padding: 24px 16px; }
    h1 { font-size: 18px; font-weight: 600; margin-bottom: 4px; text-align: center; }
    .pr { font-size: 13px; color: #888; margin-bottom: 24px; }
    .media { max-width: 390px; width: 100%; border-radius: 20px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.5); }
    img, video { width: 100%; display: block; }
  </style>
</head>
<body>
  <h1><PR_TITLE></h1>
  <div class="pr">PR #<PR> · Bloom</div>
  <div class="media">
    <!-- screenshot: <img src="data:<BASE64>"> -->
    <!-- or video: <video autoplay muted loop playsinline src="data:<BASE64>"></video> -->
  </div>
</body>
</html>
```

Embed screenshot as base64 inline data URI. Keep it self-contained — no external assets.

```bash
B64=$(base64 < /tmp/pr-demo-<PR>.png)
# Inject into HTML template
```

## Step 6 — Deploy to Surge

```bash
surge /tmp/bloom-pr-<PR>-demo bloom-pr-<PR>-demo.surge.sh
```

Surge token is in `~/.netrc` for `your-email@example.com`.

## Step 7 — Post PR comment

```bash
gh pr comment <PR> --repo Bloom-Invest/bloom \
  --body "📱 **Demo:** https://bloom-pr-<PR>-demo.surge.sh"
```

---

## screen-map.json format

```json
{
  "patterns": [
    { "match": ["PaymentModal", "SubscriptionCard", "OnboardingTrial", "AnnualPricingCard", "OneTimeOffer", "TrialHero"], "screen": "paywall" },
    { "match": ["OnboardingView", "OnboardingAI", "OnboardingTop", "OnboardingNotif"], "screen": "onboarding" },
    { "match": ["ChatPage", "AIChatAnimation"], "screen": "chat" },
    { "match": ["DailyPicks", "AIArena", "FeatureShowcase"], "screen": "ai-arena" },
    { "match": ["MorePage", "SubscriptionCard"], "screen": "more" },
    { "match": ["Portfolio", "PerformanceCard", "PerformanceChart"], "screen": "portfolio" }
  ],
  "fallback": "home",
  "webFallbackUrls": {
    "paywall": "http://localhost:5173/?demo=paywall",
    "onboarding": "http://localhost:5173/?demo=onboarding",
    "chat": "http://localhost:5173/chat",
    "ai-arena": "http://localhost:5173/?demo=ai-arena",
    "more": "http://localhost:5173/more",
    "portfolio": "http://localhost:5173/portfolio",
    "home": "http://localhost:5173"
  }
}
```

## Common mistakes

- **base64 encoding**: Use `base64` CLI; on macOS it's `base64 -i file` or `base64 < file`. Avoid newlines with `-w 0` on Linux.
- **Surge deploy**: Make sure `index.html` is in the folder being deployed, not a parent.
- **Simulator not booted**: Always check before trying to screenshot — don't assume it's running.
- **Large base64**: iPhone screenshots are ~2-4MB → ~3-5MB base64. This is fine for a self-contained HTML page.
- **Dev server port conflict**: If port 5173 is already in use, vite picks a different port — check stdout for "Local: http://localhost:XXXX" and use that port.
- **bun install slowness**: First install in a fresh worktree can take 30-60s. `--frozen-lockfile` is faster if bun.lock is committed.
- **Browser screenshot format**: `browser action=screenshot` returns a PNG attachment path — copy the file to `/tmp/pr-demo-<PR>.png`.

---

## Integration with fix-bloom-prs

To enable: after fix-bloom-prs pushes a fix, add this line to the cron payload:
"After pushing any code fix to a frontend PR, run the demo-pr-feature skill with that PR number."

The skill is designed to be called inline — no sub-agent needed. Takes ~60-120s for simulator capture.
