---
name: hermes-signal-streaming-cursor-fix
description: Diagnose and fix black-square / cursor artifacts in Hermes Signal conversations caused by edit-based streaming assumptions on non-editable platforms.
---

# Hermes Signal Streaming Cursor Fix

Use this when Signal users report black squares, tofu glyphs, or visible cursor blocks appearing in the message thread during in-progress Hermes replies.

## Symptom

Examples:
- trailing `■`
- trailing black square / tofu box
- visible cursor-like block at the end of partial messages in Signal/iPhone

This is usually not a rendering-only issue. In Hermes, it can be caused by the streaming cursor being sent as visible text and never being edited away.

## Root Cause Pattern

Check these files first:
- `gateway/stream_consumer.py`
- `gateway/run.py`
- `gateway/platforms/signal.py`
- `gateway/platforms/base.py`

The failure mode is:
1. `StreamConsumerConfig.cursor` appends a visible cursor (commonly `" ▉"`) to partial streamed text.
2. The platform is treated as if message editing is supported.
3. The adapter returns a truthy `message_id` from `send()`.
4. The adapter does **not** actually implement `edit_message()`.
5. Cleanup edits fail, leaving the cursor visible in the chat thread.
6. Signal/iPhone may render `▉` as a black square / tofu glyph.

## Exact Checks

### 1) Confirm the cursor exists
Search for:
- `cursor: str =`
- `display_text += self.cfg.cursor`

Expected locations:
- `gateway/stream_consumer.py`

### 2) Confirm platform capability detection
Search for:
- `SUPPORTS_MESSAGE_EDITING`
- `StreamConsumerConfig(`
- platform-specific cursor suppression logic

Expected location:
- `gateway/run.py`

### 3) Confirm Signal really lacks editing
Read:
- `gateway/platforms/signal.py`
- `gateway/platforms/base.py`

If Signal does not override `edit_message()`, it is non-editable even if other logic behaves as though it were editable.

### 4) Inspect `send()` return value
If Signal `send()` returns a pseudo message id (for example, from an RPC timestamp), the stream consumer may incorrectly enter the edit path.

## Minimal Fix

Prefer the narrowest evidence-based fix:

### A. Explicitly mark Signal as non-editable
In `gateway/platforms/signal.py` add:

```python
SUPPORTS_MESSAGE_EDITING = False
```

### B. Do not return a pseudo editable message_id from Signal `send()`
Keep any internal timestamp tracking needed for echo filtering, but return:

```python
SendResult(success=True, message_id=None)
```

This prevents the stream consumer from pretending a future edit can remove a visible cursor.

## Recommended Test Coverage

Update/add tests in:
- `tests/gateway/test_signal.py`
- `tests/gateway/test_stream_consumer.py`

Add assertions for:
1. `SignalAdapter.SUPPORTS_MESSAGE_EDITING is False`
2. `SignalAdapter.send()` returns `message_id is None` even if the RPC includes a timestamp
3. Non-edit streaming with `cursor=""` does not send a visible cursor glyph in the first message

## Verification Command

If the repo has a virtualenv:

```bash
source venv/bin/activate && pytest tests/gateway/test_signal.py tests/gateway/test_stream_consumer.py -q
```

## Notes / Pitfalls

- Do not assume a truthy `message_id` means the platform supports editing.
- A timestamp-based pseudo id is especially dangerous here because it masks the real capability mismatch.
- Suppressing the cursor for non-edit platforms is safer than trying to clean it up later.
- This fix is intentionally narrow: it solves the black-square artifact without requiring broader redesign of Signal progress delivery.
