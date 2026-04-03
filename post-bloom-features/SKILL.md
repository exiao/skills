---
name: post-bloom-features
description: Use when the cron fires at 1am ET on Tuesday or Thursday — runs preflight to find user-facing PRs, screenshots the feature in iOS simulator, renders a Remotion video, creates an unscheduled Typefully draft, and reports to Signal.
---

# Bloom Feature Threads

Finds a recently shipped user-facing Bloom feature, screenshots it in the iOS simulator, renders a product showcase video via Remotion, and creates a Typefully draft for review. Always draft-only — never auto-publishes.

---

## Tools

| Tool | Purpose |
|------|---------|
| `exec` | Run preflight script, simulator scripts, render script |
| `ios-simulator` skill | Boot simulator, launch Bloom app, navigate, screenshot |
| `typefully` skill | Upload video + create draft (NOT scheduled/published) |
| `message` tool | Report to Signal group |

---

## Workflow

### Step 1 — Preflight (MANDATORY)

```bash
bash ~/clawd/scripts/bloom-feature-preflight.sh
```

This script:
- Inspects recent merged PRs for user-facing changes
- Outputs JSON of qualifying PRs, or **exits with code 1** if none qualify

If the script exits with code 1: **NO_REPLY** (stop completely, send nothing).

From the JSON output, pick the **single most visually interesting PR** — prefer UI changes, new screens, visual improvements over backend/infra changes.

### Step 2 — Boot iOS Simulator

```bash
# Check if a simulator is already booted
xcrun simctl list devices booted

# If none booted:
python ~/clawd/skills/ios-simulator/scripts/simctl_boot.py \
  --name 'iPhone 16 Pro' \
  --wait-ready

# Launch Bloom app
python ~/clawd/skills/ios-simulator/scripts/app_launcher.py \
  --launch com.bloom.invest

# Set clean status bar (no carrier noise, full battery, 9:41)
python ~/clawd/skills/ios-simulator/scripts/status_bar.py \
  --preset clean

sleep 5
```

### Step 3 — Navigate to Feature Screen + Screenshot

```bash
# Get a map of the app's current screen
python ~/clawd/skills/ios-simulator/scripts/screen_mapper.py

# Navigate to the feature screen based on the PR content
# Use navigator.py for screen navigation, gesture.py for taps/swipes
python ~/clawd/skills/ios-simulator/scripts/navigator.py --screen <target_screen>
# OR
python ~/clawd/skills/ios-simulator/scripts/gesture.py --tap <x> <y>

sleep 2

# Take screenshot
xcrun simctl io booted screenshot /tmp/bloom-shot-1.png
```

**Validate the screenshot:**
```bash
wc -c /tmp/bloom-shot-1.png
```
- Must be **>100KB**
- If <100KB: wait 3s and retry once
- If still <100KB: navigate to any real, populated app screen and screenshot that instead
- If still <100KB: set `screenshot_valid=false` (will post text-only)

### Step 4 — Write Post Copy

Read 2-3 recent release notes:
```bash
ls ~/bloom/release-notes/releases/ | sort | tail -5
cat ~/bloom/release-notes/releases/<recent-file>
```

Write the post copy:
- **Max 220 characters**
- User-benefit-first voice — what does this do *for you*, not what the code does
- No dev language (no "PR", "refactor", "API", "backend")
- Name the specific feature (not vague like "improved experience")
- Add App Store link if space allows — use `https://apps.apple.com/app/bloom-investing/id` + the value of `$BLOOM_APP_STORE_ID` env var

Also write a `featureTitle` (3-5 words) for the Remotion video overlay.

### Step 5 — Render Remotion Video (if screenshot valid)

```bash
bash ~/clawd/scripts/bloom-render-feature.sh \
  /tmp/bloom-shot-1.png \
  "<copy_text>" \
  "<feature_title>"
```

This takes 2-4 minutes. Output: `/tmp/bloom-feature-video.mp4`

Wait for the script to complete before proceeding.

### Step 6 — Upload to Typefully + Create Draft

**If video was rendered:**
```bash
# Upload video
node ~/clawd/skills/typefully/scripts/typefully.js media:upload /tmp/bloom-feature-video.mp4
# → returns media_id

node ~/clawd/skills/typefully/scripts/typefully.js drafts:create $TYPEFULLY_BLOOM_SET_ID \
  --platform x \
  --text "<copy_text>" \
  --media <media_id> \
  --tags bloom-features
# → returns draft_id
```

**If screenshot invalid (text-only):**
```bash
node ~/clawd/skills/typefully/scripts/typefully.js drafts:create $TYPEFULLY_BLOOM_SET_ID \
  --platform x \
  --text "<copy_text>" \
  --tags bloom-features
```

⚠️ **DO NOT pass `--schedule`** — this draft is for Eric's review, not auto-publish.

### Step 7 — Report to Signal

Send to `$SIGNAL_MARKETING_GROUP`:

```
🍎 Feature thread ready for review:
Feature: [featureTitle]
PR: [PR title]

Copy: [post copy]

Typefully draft: https://typefully.com/?a=$TYPEFULLY_BLOOM_SET_ID&d=[draft_id]
[video: attached / text-only: no screenshot available]
```

---

## Delivery

- Signal group: `$SIGNAL_MARKETING_GROUP` — cron delivery handles routing, do NOT send via message tool
- Typefully account: `$TYPEFULLY_BLOOM_SET_ID` (Bloom brand account), tag: `bloom-features`
- Draft is **NOT scheduled** — Eric reviews and publishes manually
- Screenshot: `/tmp/bloom-shot-1.png`
- Video: `/tmp/bloom-feature-video.mp4`

---

## Cron Config

- **ID:** `06efe3fb-85f4-4e75-a54b-ad7b704ede53`
- **Schedule:** `0 1 * * 2,4` (1am ET, Tue + Thu)
- **Model:** default (claude-sonnet)
- **Target:** isolated

---

## Common Mistakes

1. **Skipping preflight** — preflight is MANDATORY. Never proceed if it exits code 1.
2. **Auto-publishing** — this draft is always for human review. Never add `--schedule` to the Typefully command.
3. **Small screenshot** — a screenshot under 100KB is blank or a stub. Retry navigation; use a real populated screen as fallback.
4. **Dev language in copy** — "we shipped a refactor" is bad. "Portfolio charts now load instantly" is good.
5. **Wrong Typefully account** — this uses account `$TYPEFULLY_BLOOM_SET_ID` (Bloom brand), NOT `$TYPEFULLY_SOCIAL_SET_ID`.
6. **Render timeout** — the Remotion render can take up to 4 minutes. Don't kill it early.
7. **Simulator not ready** — always use `--wait-ready` when booting; launching too fast crashes the app.

## Constitutional Rules
- NEVER lower the quality bar to find something to post. If nothing meets criteria, report "nothing to post today" and why.
- NEVER post without reading back the full content first.
- Always create as draft first; do not schedule or publish directly.
