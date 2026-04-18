---
name: hermes-signal-reply-fix
description: Fix for Signal reply context not being passed into Hermes gateway
version: 1
tags: [hermes, signal, gateway, bugfix]
---

# Hermes Signal Reply Context Fix

## Problem
Signal replies don't carry quoted-message context into Hermes. The gateway supports reply context (gateway/run.py prepends `[Replying to: "..."]`), but Signal's adapter doesn't extract it.

## Root Cause
In `~/.hermes/hermes-agent/gateway/platforms/signal.py`, inbound message handling builds a MessageEvent but never reads `dataMessage.quote`.

## Fix (APPLIED)
In `gateway/platforms/signal.py`, after extracting `data_message`:
```python
quote = data_message.get("quote", {}) or {}
reply_to_message_id = str(quote["id"]) if "id" in quote else None
reply_to_text = quote.get("text")
```
Then pass both into the MessageEvent constructor:
```python
reply_to_message_id=reply_to_message_id,
reply_to_text=reply_to_text,
```

## Key Details
- `gateway/run.py` already has reply-context injection (~line 3051) — no changes needed there
- Signal envelope uses `sourceNumber`/`sourceUuid` as scalars (NOT nested `source` dict)
- `MessageEvent` in `gateway/platforms/base.py` already has `reply_to_message_id` and `reply_to_text` fields

## Tests
3 adapter-level tests added to `tests/gateway/test_signal.py`:
1. Quote present → reply fields populated
2. No quote → reply fields stay None
3. Quote without text → id set, text None

All 65 Signal tests pass.

## Patch Plan
Full plan at: `~/hermes-patches/signal-reply-patch.md`
