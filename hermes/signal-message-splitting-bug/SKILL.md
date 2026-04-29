---
name: signal-message-splitting-bug
version: 1
category: hermes-patches
description: Investigation and fix plan for Signal splitting short bot responses into multiple bubbles
---

# Signal Message Splitting Bug

## Symptom
Short bot responses (e.g. "hey! 👋 what's up?") split into two Signal bubbles ("hey" + "! 👋 what's up?").

## Root Cause
Even with `streaming.enabled: false`, a `GatewayStreamConsumer` is always created for Signal because `interim_assistant_messages` defaults to True (`_want_interim_consumer` is True). The consumer's flush logic sends partial content before the response completes. Since Signal can't edit messages (`SUPPORTS_MESSAGE_EDITING = False`, `message_id=None`), the first flush becomes a permanent separate bubble, and the remainder gets sent as a second message via `_send_fallback_final()`.

## Key Code Paths
- `run.py` ~line 7805-7835: stream consumer created when `_want_stream_deltas or _want_interim_consumer` (always true for Signal)
- `stream_consumer.py` lines 578-584: fallback mode when `message_id=None` (non-editable platform)
- Default `edit_interval=1.0s`, `buffer_threshold=40 chars`

## Proposed Fix (agreed with user)
1. Bump `edit_interval` to ~2.0s for non-editable platforms (in run.py config)
2. Add `initial_delay: float = 0.0` to `StreamConsumerConfig` — set to ~2.0s for non-editable platforms. Suppress intermediate flushes until initial_delay elapsed.
3. **Critical:** Bypass delay when `got_done=True` so fast responses send immediately (no artificial response time floor)
4. Consider: don't create full GatewayStreamConsumer when streaming is off — use simpler interim delivery path

## Implementation Plan
- `StreamConsumerConfig`: add `initial_delay: float = 0.0`
- `GatewayStreamConsumer.__init__`: store `self._first_send_time = None`
- `run()` loop ~line 166: if `_first_send_time is None`, set on first token; suppress `should_edit` until `elapsed >= initial_delay`
- `run.py` ~line 7823: when `not _adapter_supports_edit`, set `edit_interval=2.0, initial_delay=2.0`

## Status
NOT YET IMPLEMENTED - investigation complete, fix plan agreed upon.