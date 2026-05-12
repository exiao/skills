# Google Gemini CLI / Code Assist provider triage

Use when `google-gemini-cli` appears broken in Hermes, falls back despite `/gquota` showing quota, or returns empty assistant responses.

## Core distinction

Do not treat `/gquota` as proof that inference is available. Code Assist can report daily quota remaining while the generation endpoint returns short-window 429 capacity throttles:

```text
HTTP 429 RESOURCE_EXHAUSTED
reason: RATE_LIMIT_EXCEEDED
domain: cloudcode-pa.googleapis.com
message: You have exhausted your capacity on this model. Your quota will reset after Ns.
```

That is Google-side capacity/throttle state, not necessarily a Hermes routing bug. Still verify Hermes is not dropping valid streamed output before blaming quota.

## Fast reproduction path

1. Verify live code and provider resolution:
```bash
cd ~/.hermes/hermes-agent
git log --oneline -5
python - <<'PY'
from hermes_cli.runtime_provider import resolve_runtime_provider
print(resolve_runtime_provider(requested='google-gemini-cli', target_model='gemini-3.1-pro-preview'))
PY
```

2. Run with fallback disabled so failures are not masked. Prefer the bundled script to avoid retyping and to redact token-looking strings:
```bash
python ~/.hermes/skills/ai-tools/hermes-agent/scripts/gemini_cli_no_fallback_probe.py
```

Equivalent inline repro:
```bash
python - <<'PY'
from run_agent import AIAgent
agent = AIAgent(
    provider='google-gemini-cli',
    model='gemini-3.1-pro-preview',
    quiet_mode=False,
    enabled_toolsets=[],
)
agent._fallback_chain = []
res = agent.run_conversation('Use no tools. Reply exactly: GEMINI_DIRECT_OK')
print('RESULT', repr(res.get('final_response')), 'error', res.get('error'))
PY
```

3. If it says empty response, inspect the session JSON and actual model used. A `hermes chat` smoke test can silently succeed via fallback. Check `~/.hermes/sessions/session_<id>.json` for `model`, provider metadata, and fallback events before declaring Gemini healthy.

## Known Code Assist pitfalls

### 1. Retry-after is in the error text
Code Assist often exposes reset windows only in the exception/body text, not standard `Retry-After` headers. Retry parsing needs to handle:
- exception attr `retry_after`
- `retry-after` / `Retry-After` headers
- text like `quota will reset after 18s`

For short Google waits, Hermes should wait instead of immediately falling back. Add a small cushion because Google can return `reset after 0s` while still settling.

### 2. Stream chunks must mimic OpenAI chunk shape
Hermes' stream accumulator accesses `delta.content` and `delta.tool_calls` directly. Gemini Code Assist stream chunks must always expose both attributes, using `None` when absent. Final chunks that only carry `finishReason` must not omit `content` or `tool_calls`, or Hermes can raise internally, lose the valid streamed text, treat the response as empty, retry, and fall back.

Regression shape:
```python
terminal_delta.content is None
terminal_delta.tool_calls is None
```

### 3. `thinking_config` is not safe for `google-gemini-cli` by default
Code Assist already spends hidden thinking tokens, even without `thinkingConfig`. Sending Hermes' shared Gemini `thinking_config` to `google-gemini-cli` can make tiny prompts burn budget, return empty text, or worsen throttling. Omit `thinking_config` for `google-gemini-cli`; keep API-key Gemini behavior unchanged.

## Useful tests

```bash
python -m pytest \
  tests/agent/test_gemini_cloudcode.py::TestTranslateStreamEvent \
  tests/run_agent/test_provider_parity.py::TestBuildApiKwargsOpenRouter::test_google_gemini_cli_omits_thinking_config \
  tests/test_gemini_cli_retry_after.py \
  -q -o 'addopts='
```

## Live verification after merge

After the PR merges into the live branch:
```bash
cd ~/.hermes/hermes-agent
git pull --ff-only origin live-config
hermes gateway restart
```
Then run a no-fallback `AIAgent` test, not only `hermes chat`, because chat may fall back and print the expected string from another provider.

Expected healthy behavior, even under capacity throttle:
- initial 429 reset window is honored
- after wait, streamed chunk contains the requested text
- terminal chunk has `finish_reason=stop` and no AttributeError
- final response is non-empty without fallback
