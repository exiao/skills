# Bloom Fastlane Workspace

Last updated: 2026-05-05

## Connected Accounts

| Platform | Username | Connection ID | Notes |
|----------|----------|---------------|-------|
| TikTok | $TIKTOK_BRAND_HANDLE | $TIKTOK_BRAND_CONNECTION_ID | Bloom brand |
| TikTok | $TIKTOK_CREATOR_HANDLE | $TIKTOK_CREATOR_CONNECTION_ID | Personal finance creator |
| Instagram | $IG_BRAND_HANDLE | $IG_BRAND_CONNECTION_ID | Bloom brand |
| Instagram | $IG_CREATOR_HANDLE | $IG_CREATOR_CONNECTION_ID | Personal finance creator |
| YouTube | $YOUTUBE_CHANNEL_NAME | $YOUTUBE_CONNECTION_ID | $YOUTUBE_CHANNEL_ID |

## Active Angles (as of setup)

| Angle | ID | Target Audience |
|-------|----|-----------------|
| Second Opinion Investing | ts702fzxzdkj66b4r69wark6bd864md3 | Active retail investors wanting validation |
| Information Overload Fatigue | ts77qv54k0b2wwxg297qantzn186455y | Self-directed investors struggling with noise |
| Beginner Investing Anxiety | ts7faca7aprwbcptxt8feybtg986517m | First-time investors feeling overwhelmed |

## Preferences (defaults at setup)

All format weights at 25% even split. 50% remix, 50% own media, 50% product mention rate. No gender filter. No angle weights set.

## Cron

- Job: `fastlane-daily` (ID: d21431bbea17)
- Schedule: daily at 10am ET (`0 10 * * *`)
- Script: `~/.hermes/scripts/fastlane-daily.sh`
- Delivers to: signal:Skills Admin
- Behavior: generates 3 pieces via Blitz, polls until rendered, sends preview. Does NOT auto-schedule. The user approves before anything posts.
- Batch size controlled by `FASTLANE_BATCH_SIZE` env var (default 3).

## Open Questions (from setup session)

- Post to all 5 accounts or just Bloom? (awaiting answer)
- 3 pieces/day enough or want more? (awaiting answer)
