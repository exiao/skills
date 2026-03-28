---
name: stock-footage
description: Search and download free stock video footage from Pexels and Pixabay for B-roll and video production. Use when the user mentions "stock footage", "B-roll", "b-roll", "stock video", "find clips", "Pexels", "background footage", "video clips for", "find me a video of", "download stock video", or when a video-production pipeline needs supplementary footage. Also trigger when building TikTok/Reels/YouTube content and the user needs filler or background clips, even if they don't say "stock footage" explicitly.
---

# Stock Footage

Search and download free stock video clips from Pexels (primary) and Pixabay (fallback). All footage is free for commercial use with no watermarks.

## Quick Start

In examples below, `{baseDir}` means the skill directory (e.g. `~/clawd/skills/stock-footage`); replace with that path or run from that directory.

```bash
# Search for clips
{baseDir}/scripts/footage.sh search "stock market trading" --orientation portrait --per-page 5

# Download a specific video by ID
{baseDir}/scripts/footage.sh download 12345 --quality hd --output ~/clawd/assets/broll/

# Search and immediately download the best match
{baseDir}/scripts/footage.sh grab "office meeting" --orientation landscape --output ./broll/

# Show preview URL for a video
{baseDir}/scripts/footage.sh preview 12345

# Search with duration filter (seconds)
{baseDir}/scripts/footage.sh search "nature aerial" --min-duration 5 --max-duration 15

# JSON output for pipeline use
{baseDir}/scripts/footage.sh search "city timelapse" --json
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `PEXELS_API_KEY` | Yes | Free API key from pexels.com/api |
| `PIXABAY_API_KEY` | No | Fallback. Free key from pixabay.com/api/docs |

If `PEXELS_API_KEY` is missing, the script falls back to Pixabay (if `PIXABAY_API_KEY` is set). If neither is set, it errors with signup instructions.

## Commands

### `search <query>` — Find videos

Searches Pexels (or Pixabay fallback) and prints a table of results.

| Flag | Default | Description |
|------|---------|-------------|
| `--orientation` | (any) | `portrait`, `landscape`, or `square` |
| `--per-page` | 5 | Results per page (max 80) |
| `--min-duration` | (none) | Minimum duration in seconds |
| `--max-duration` | (none) | Maximum duration in seconds |
| `--page` | 1 | Page number |
| `--json` | false | Output raw JSON instead of table |

Output table columns: ID, Duration, Resolution (best quality), Preview URL.

### `download <video-id>` — Download a video file

Downloads the video file for a given Pexels video ID.

| Flag | Default | Description |
|------|---------|-------------|
| `--quality` | hd | `hd`, `sd`, or `uhd` (falls back to next best) |
| `--output` | `.` | Directory to save to |

The file is saved with a descriptive name: `pexels-<id>-<quality>.mp4`.

### `grab <query>` — Search + download top result

Combines search and download in one step. Takes all search flags plus `--quality` and `--output`.

### `preview <video-id>` — Show preview info

Prints the video's preview URL, duration, dimensions, and photographer credit. On macOS, opens the preview URL in the default browser.

## Orientation Guide

| Use Case | Orientation |
|----------|-------------|
| TikTok, Instagram Reels, YouTube Shorts | `portrait` |
| YouTube, website background | `landscape` |
| Instagram feed | `square` or `landscape` |

## Tips

- B-roll clips are typically 5-15 seconds. Use `--min-duration 5 --max-duration 15` to filter.
- Pexels has a 200 requests/hour rate limit. The script handles 429 responses with a retry.
- Always credit Pexels/Pixabay when required by their license (Pexels license doesn't require it but appreciates it).
- Use `--json` output to pipe into other tools or scripts.
- The `grab` command is the fastest path: one command to search and download the best match.
