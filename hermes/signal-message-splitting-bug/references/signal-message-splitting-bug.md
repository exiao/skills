# Signal Message Splitting Bug

## Symptom
Short bot responses on Signal get split into two bubbles (e.g., "hey" + "! 👋 what's up?" instead of one "hey! 👋 what's up?").

## Root Cause
Even with `streaming.enabled: false` in config, a `GatewayStreamConsumer` is still created because `_want_interim_consumer` defaults to True for Signal (run.py ~line 7805-7835):

```python
_want_interim_consumer = _want_interim_messages  # True for Signal
if _want_stream_deltas or _want_interim_consumer:  # Always True!
    _stream_consumer = GatewayStreamConsumer(...)
```

Since Signal doesn't support message editing (`SUPPORTS_MESSAGE_EDITING = False`, returns `message_id=None`), the consumer's first 1s flush sends a partial message, enters `__no_edit__` fallback mode (sentinel `_message_id = "__no_edit__"`), then sends the remainder as a second bubble via `_send_fallback_final()`.

## Key Code Paths
- `GatewayStreamConsumer` in stream_consumer.py: lines 578-584 (fallback mode), 241-242 (fallback final send)
- `run.py` lines 7805-7835: consumer creation
- Default config: `edit_interval=1.0s`, `buffer_threshold=40 chars`, `cursor=" ▉"` (suppressed to "" for Signal)

## Proposed Fix (Two-Part, Mild) — USER APPROVED DIRECTION
1. **Increase `edit_interval` to ~2.0s** for non-editable platforms (in run.py where StreamConsumerConfig is built)
2. **Add `initial_delay: float = 0.0` to `StreamConsumerConfig`**, set to ~2.0s for non-editable platforms
   - Suppresses intermediate flushes until delay has elapsed since first token
   - **Critical:** `got_done` (stream complete) MUST bypass `initial_delay` — send immediately when response is finished, no artificial latency floor
3. **Broader improvement:** Don't create a full GatewayStreamConsumer when streaming is off — use a simpler interim message delivery path

### Fix Logic (stream_consumer.py run() loop):
```python
if got_done:
    # send now, no waiting (final response)
elif first_token_age < initial_delay:
    # skip this flush cycle (still accumulating)
elif elapsed >= edit_interval:
    # flush intermediate update
```

## Session References
- Investigated session: `20260413_194907_1307942a`, group `fZpKW...`
- Response was `"\n\nhey! 👋 what's up?"` — 17 chars, 1 API call, no tool calls, finish_reason=stop
- Single model response split into two Signal messages
