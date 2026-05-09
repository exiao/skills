# Bloom Fastlane Workspace

Last updated: 2026-05-07

## Connected Accounts

| Platform | Username | Connection ID | Notes |
|----------|----------|---------------|-------|
| TikTok | @invest.with.bloom | mn74v7k5gb02xyvqfxek42myb5865sjq | Bloom brand |
| TikTok | @madsmoneyflow | mn72myer8k22j72shnhw68eqt1864g8h | Personal finance creator |
| Instagram | invest.with.bloom | mn77hpwzse9p2jpb46zw6eqaq9865v01 | Bloom brand |
| Instagram | madsmakesmoney_ | mn7f6kw7fzset52f0t1a6bp8w9864cp2 | Personal finance creator |
| YouTube | Eric Invests | mn7ctv270k7pz53zyzcaacftk9865cz5 | UCiouo56rRnfAQlJNnKImYBg |

## Active Angles (as of setup)

| Angle | ID | Target Audience |
|-------|----|--------------------|
| Second Opinion Investing | ts702fzxzdkj66b4r69wark6bd864md3 | Active retail investors wanting validation |
| Information Overload Fatigue | ts77qv54k0b2wwxg297qantzn186455y | Self-directed investors struggling with noise |
| Beginner Investing Anxiety | ts7faca7aprwbcptxt8feybtg986517m | First-time investors feeling overwhelmed |

## Preferences (defaults at setup)

All format weights at 25% even split. 50% remix, 50% own media, 50% product mention rate. No gender filter. No angle weights set.

## Cron

- Job: `fastlane-daily` (ID: d21431bbea17)
- Schedule: daily at 10am ET (`0 10 * * *`)
- Script: `~/.hermes/scripts/fastlane-daily.sh` (wrapper: `fastlane-daily.py`)
- Delivers to: signal:Skills Admin
- Behavior: generates 3 pieces via Blitz, polls until rendered, **auto-schedules to Bloom brand accounts** (TikTok, Instagram, YouTube). No approval needed.
- Schedule stagger: posts at 2pm, 5pm, 8pm ET the next day.
- YouTube: skips slideshows (not supported), truncates titles to <100 chars.
- Batch size controlled by `FASTLANE_BATCH_SIZE` env var (default 3).
- Creator accounts (madsmoneyflow, madsmakesmoney_) are ON HOLD.
- Operational pitfall: the shell script runs under macOS `/bin/bash` 3.2, so avoid Bash 4 features like `declare -A`. See `references/cron-automation-pitfalls.md`.
- Caption pitfall: Blitz suggestions may be JSON objects. Extract `suggestion.generatedText` before scheduling; do not pass raw suggestion JSON as the caption.

## Resolved Questions

- Post to all 5 accounts or just Bloom? **Bloom brand only** (3 accounts: TikTok, Instagram, YouTube). Creator accounts on hold.
- Auto-schedule or require approval? **Auto-schedule.** Eric confirmed 2026-05-07.
