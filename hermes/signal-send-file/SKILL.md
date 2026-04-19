---
name: signal-send-file
description: |
  Send files (images, PNGs, PDFs, videos, documents, anything) as native
  attachments on Signal, Telegram, Discord, Slack, WhatsApp, or any messaging
  gateway. Use whenever a user asks to "send", "share", "attach", "send again",
  or "resend" a file or image, or when your reply needs to include a local file
  as an attachment. Covers both the direct inline-MEDIA approach and the
  send_file tool, and the one rule that makes either approach work.
---

# signal-send-file

The gateway delivers files as native attachments by scanning the **final
assistant text** for `MEDIA:<path>` tags. The regex lives in
`hermes-agent/gateway/platforms/base.py` in `extract_media()` (around line
1286). Every tag it finds is pulled out, stripped from the text, and routed
through the platform's `_send_attachment` / `send_image_file` / `send_voice`
/ `send_document` path depending on extension.

## The one rule

**The `MEDIA:<path>` tag must appear in your final reply text.**

It does not matter where the tag came from. What matters is that the string
lives in the assistant message the gateway sees, not buried in a tool-result
payload the gateway ignores.

## Two valid approaches

### Approach A — inline the tag directly (simplest)

Write the tag as prose in your reply. No tool call needed. Works for any file
that exists on disk.

```
Here are all six graphics.

MEDIA:/tmp/memory-graphics/1-descent.png
MEDIA:/tmp/memory-graphics/2-split.png
MEDIA:/tmp/memory-graphics/3-meta-line.png
```

Use this when you already know the paths and you do not need size/existence
validation.

### Approach B — use the `send_file` tool, then echo its result

The `send_file` tool (custom Hermes patch, see
`~/.hermes/plans/hermes-patches/send-file-attachment.md`) validates the path,
checks file size (100MB limit), and returns a `MEDIA:<path>` string as its
tool result. For the tag to actually reach the gateway, **you must include
that returned string verbatim in your final reply text**.

Correct:

```
[tool call: send_file(file_path="/tmp/report.pdf")]
  → returns "MEDIA:/tmp/report.pdf"

[final reply text:]
Here's the report.

MEDIA:/tmp/report.pdf
```

Incorrect (what I did in the 04:22 session):

```
[tool call: send_file(...)] × 6
  → each returns "MEDIA:/tmp/..."

[final reply text:]
"All six sent again. Let me know if any are still not coming through."
       ↑ tags never echoed into the text → 0 attachments sent
```

Use this approach when you want size/existence validation, or when the file
path is dynamic.

## Which approach to pick

- Sending files you just wrote to `/tmp/`? Inline (Approach A) is simpler.
- Sending user-supplied paths that might not exist? Tool + echo (Approach B)
  catches errors cleanly.
- Sending many files? Inline is less noise than N tool calls.

## Rules for both approaches

- **One tag per line.** Six files = six `MEDIA:` lines.
- **Absolute paths.** No `~`, no globs, no `*`. Expand before writing.
- **Blank line before each tag.** Prevents the tag from being treated as part
  of a paragraph.
- **Path must exist on disk** at the moment the reply is sent. `ls -la` first
  if unsure.
- **No fabricated paths in prose.** Do not write `/tmp/file.png` in a sentence
  if the file is not there — the regex will match, the file lookup will fail,
  and the user gets a silent drop or a warning log.

## Supported extensions

The `extract_media()` regex currently matches:

**Images:** `png`, `jpg`, `jpeg`, `gif`, `webp`
**Video:** `mp4`, `mov`, `avi`, `mkv`, `webm`
**Audio:** `ogg`, `opus`, `mp3`, `wav`, `m4a`
**Docs:** `pdf`, `txt`, `md`, `csv`, `rtf`, `doc`, `docx`, `xls`, `xlsx`, `pptx`
**Config/data:** `json`, `yaml`, `yml`, `toml`, `xml`, `ini`, `cfg`, `conf`
**Code:** `py`, `js`, `ts`, `sh`, `rb`, `go`, `rs`, `java`, `c`, `cpp`, `h`, `hpp`, `sql`, `html`, `css`
**Archives:** `zip`, `tar`, `gz`
**Logs:** `log`

Plus a `|\S+` fallback for any path that looks like a `MEDIA:` tag regardless
of extension.

## Voice messages

For voice-message bubbles on Signal/Telegram, add `[[audio_as_voice]]` on its
own line after the audio `MEDIA:` tag.

## Common failure modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| User sees text but no attachments | Tool called, tag not echoed in reply text | Inline the tag in the final reply |
| "Image file not found: `*.png`" in gateway.log | Paths listed in prose got globbed | Use absolute paths on their own lines, not inside file listings |
| "Image file not found: `<path>`" | Placeholder text from a code block got parsed | Keep example paths inside fenced code blocks |
| Schema shows `properties: {}` for `send_file` tool | Known bug from double-wrapped schema | Use Approach A (inline) or restart gateway; patched in `send-file-schema-unwrap.md` |

## When the user says "send them again"

They mean: write a new reply containing one `MEDIA:` tag per file. Either
approach works. What does not work is writing "here you go" without the tags.
