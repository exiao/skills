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
| Second Opinion Investing | $ANGLE_ID_1 | Active retail investors wanting validation |
| Information Overload Fatigue | $ANGLE_ID_2 | Self-directed investors struggling with noise |
| Beginner Investing Anxiety | $ANGLE_ID_3 | First-time investors feeling overwhelmed |

## Preferences (defaults at setup)

All format weights at 25% even split. 50% remix, 50% own media, 50% product mention rate. No gender filter. No angle weights set.

## Cron

- Job: `fastlane-daily` (ID: `d21431bbea17` in this workspace)
- Schedule: daily at 10am ET (`0 10 * * *`)
- Script wrapper: `~/.hermes/scripts/fastlane-daily.py`
- Bash implementation: `~/.hermes/scripts/fastlane-daily.sh`
- Delivers to: signal:Skills Admin
- Behavior: generates 3 pieces via Blitz, polls until rendered, and auto-schedules to Bloom brand accounts. No approval needed for this cron.
- Target accounts: TikTok `@invest.with.bloom`, Instagram `invest.with.bloom`, YouTube `invest with bloom` / `Eric Invests` where supported.
- YouTube is skipped for `slideshow` content because Fastlane only accepts single-video content for YouTube.
- Batch size controlled by `FASTLANE_BATCH_SIZE` env var (default 3).
- Scheduler timeout should be long enough for generation polling. `cron.script_timeout_seconds: 900` in `~/.hermes/config.yaml` is a known-good value for this job.

## Recovery Pattern: Timed Out Daily Run

If the job reports `Script timed out after 120s`, do not assume no content was generated. The script may have started Blitz items and died before scheduling.

1. List recent content: `GET /content?limit=10`.
2. Identify the newest 3 items around the failed run time with `status: CREATED`.
3. List recent posts: `GET /posts?limit=30`.
4. For each new content ID, verify it is not already scheduled before posting, otherwise duplicates are easy.
5. Schedule videos to TikTok, Instagram, and YouTube; schedule slideshows to TikTok and Instagram only.
6. Verify scheduled records by filtering `/posts` for the recovered `content_id`s and checking `status: SCHEDULED`.
7. Report generated IDs, content types, scheduled post IDs, platforms, and times.
