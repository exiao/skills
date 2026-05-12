---
name: yt-dlp
description: Download audio/video from YouTube and other sites using yt-dlp. Use when the user asks to download music, songs, albums, podcasts, or video from YouTube or similar platforms. Triggers on 'download song', 'get mp3', 'yt-dlp', 'youtube download', 'rip audio'.
---

# yt-dlp — Media Downloads

Download audio/video from YouTube (and 1000+ other sites) via yt-dlp CLI.

## Installation

```bash
pip3 install --break-system-packages yt-dlp
```

Note: On macOS with system Python, `--break-system-packages` is required (PEP 668).

## Common Workflows

### Download as MP3 (best quality)

```bash
yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Documents/%(title)s.%(ext)s" "ytsearch1:ARTIST TITLE"
```

### Download with custom filename

```bash
yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Documents/Artist - Title.%(ext)s" "ytsearch1:Artist Title"
```

### Download from direct URL

```bash
yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Documents/%(title)s.%(ext)s" "https://www.youtube.com/watch?v=XXXX"
```

### Download video (best quality)

```bash
yt-dlp -f "bestvideo+bestaudio" --merge-output-format mp4 -o "$HOME/Documents/%(title)s.%(ext)s" "URL"
```

### Metadata only (no download)

```bash
yt-dlp --dump-json "ytsearch1:query" | jq '{title, duration, url}'
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `-x` | Extract audio only |
| `--audio-format mp3` | Convert to mp3 |
| `--audio-quality 0` | Best quality (VBR ~245kbps) |
| `-o TEMPLATE` | Output filename template |
| `-f 2` | Download format #2 (often 360p mp4) |
| `--cookies-from-browser chrome` | Use browser cookies for age-gated content |
| `ytsearch1:query` | Search YouTube, take first result |
| `ytsearch5:query` | Search YouTube, take first 5 results |

## Output Templates

| Template | Expands to |
|----------|-----------|
| `%(title)s` | Video title |
| `%(uploader)s` | Channel name |
| `%(duration)s` | Duration in seconds |
| `%(ext)s` | File extension |
| `%(playlist_index)s` | Index in playlist |

## Pitfalls

- **JS runtime warning**: "No supported JavaScript runtime" warning appears but downloads still work via Android API fallback. Install `deno` to suppress and get all formats.
- **Google Drive sync**: On this machine, Google Drive mounts at `~/Library/CloudStorage/GoogleDrive-USER_EMAIL/My Drive/`, NOT at `~/Documents/`. If the user wants files on Google Drive, output there.
- **Playlists**: Add `--no-playlist` to avoid downloading entire playlists when given a video URL that's part of one.
- **Rate limiting**: YouTube may throttle. Add `--sleep-interval 3` for batch downloads.
- **Age-gated content**: Use `--cookies-from-browser chrome` or `--cookies cookies.txt`.

## File Delivery

After downloading, send the file back to the user:

```
MEDIA:/absolute/path/to/file.mp3
```
