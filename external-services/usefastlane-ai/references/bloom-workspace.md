# Bloom Fastlane Workspace

Last updated: 2026-05-07

## Connected Accounts

| Platform | Username | Connection ID | Notes |
|----------|----------|---------------|-------|
| TikTok | $TIKTOK_BRAND_HANDLE | $TIKTOK_BRAND_CONNECTION_ID | Bloom brand |
| TikTok | $TIKTOK_CREATOR_HANDLE | $TIKTOK_CREATOR_CONNECTION_ID | Personal finance creator |
| Instagram | $IG_BRAND_HANDLE | $IG_BRAND_CONNECTION_ID | Bloom brand |
| Instagram | $IG_CREATOR_HANDLE | $IG_CREATOR_CONNECTION_ID | Personal finance creator |
| YouTube | $YT_CHANNEL_NAME | $YT_CONNECTION_ID | $YT_CHANNEL_ID |

## Active Angles (as of setup)

| Angle | ID | Target Audience |
|-------|----|----------------|
| Second Opinion Investing | $ANGLE_ID_1 | Active retail investors wanting validation |
| Information Overload Fatigue | $ANGLE_ID_2 | Self-directed investors struggling with noise |
| Beginner Investing Anxiety | $ANGLE_ID_3 | First-time investors feeling overwhelmed |

## Preferences (defaults at setup)

All format weights at 25% even split. 50% remix, 50% own media, 50% product mention rate. No gender filter. No angle weights set.

## Cron

- Job: `fastlane-daily` (ID: $FASTLANE_CRON_ID)
- Schedule: daily at 10am ET (`0 10 * * *`)
- Script: `~/.hermes/scripts/fastlane-daily.sh` (wrapper: `fastlane-daily.py`)
- Delivers to: signal:Skills Admin
- Behavior: generates 3 pieces via Blitz, polls until rendered, **auto-schedules to Bloom brand accounts** (TikTok, Instagram, YouTube). No approval needed.
- Schedule stagger: posts at 2pm, 5pm, 8pm ET the next day.
- YouTube: skips slideshows (not supported), truncates titles to <100 chars.
- Batch size controlled by `FASTLANE_BATCH_SIZE` env var (default 3).
- Creator accounts are ON HOLD.
- Operational pitfall: the shell script runs under macOS `/bin/bash` 3.2, so avoid Bash 4 features like `declare -A`. See `references/cron-automation-pitfalls.md`.
- Caption pitfall: Blitz suggestions may be JSON objects. Extract `suggestion.generatedText` before scheduling; do not pass raw suggestion JSON as the caption.

## Resolved Questions

- Post to all 5 accounts or just Bloom? **Bloom brand only** (3 accounts: TikTok, Instagram, YouTube). Creator accounts on hold.
- Auto-schedule or require approval? **Auto-schedule.**
