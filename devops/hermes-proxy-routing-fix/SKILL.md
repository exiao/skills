---
name: hermes-proxy-routing-fix
category: devops
description: Fix for Hermes not routing Anthropic requests through local billing proxy
---

# Hermes Proxy Routing Fix

## Problem
Hermes `hermes chat` was not sending Anthropic requests through the local billing proxy at http://127.0.0.1:18801, even though `providers.anthropic.base_url` was set in config.yaml.

## Root Causes
1. **Hermes runtime_provider.py** only checked `model.*` fields, so `providers.anthropic.base_url` in config.yaml was ignored during live runtime resolution. Fix: patch `_get_model_config()` in `~/.hermes/hermes-agent/hermes_cli/runtime_provider.py` to inherit missing endpoint/auth fields from `providers.<configured_provider>`.
2. **Proxy missing tool renames**: `mcp_send_message` and `mcp_mixture_of_agents` were not being sanitized. Fix: add renames and reverse mappings in proxy.js.
3. **System block leaking**: Large "# Claude Code Persona" system text from Hermes was being forwarded. Fix: strip it in proxy.js before forwarding.

## Verification
```bash
# Proxy-side tests
node --test tests/hermes-support.test.js

# Hermes-side targeted tests for the Anthropic routing path
pytest tests/hermes_cli/test_runtime_provider_resolution.py -q -k 'get_model_config_merges_provider_specific_anthropic_base_url or anthropic_pool_respects_config_base_url or anthropic_explicit_override_skips_pool'

# Inspect actual runtime resolution with the live config
python - <<'PY'
from hermes_cli.runtime_provider import resolve_runtime_provider
print(resolve_runtime_provider(requested='anthropic'))
PY
# Expect base_url=http://127.0.0.1:18801

# Live end-to-end test
hermes chat -q "Reply with exactly: HERMES_PROXY_OK" --provider anthropic -Q -v
# Verify the log shows POST http://127.0.0.1:18801/v1/messages and a 200 OK.
```

## Expected validated outcome
- `resolve_runtime_provider(requested='anthropic')` returns `base_url=http://127.0.0.1:18801`
- verbose `hermes chat` logs show `POST http://127.0.0.1:18801/v1/messages`
- final assistant response is `HERMES_PROXY_OK`

## Files
- Hermes: ~/.hermes/hermes-agent/hermes_cli/runtime_provider.py
- Hermes test: ~/.hermes/hermes-agent/tests/hermes_cli/test_runtime_provider_resolution.py
- Proxy: /Users/testuser/openclaw-billing-proxy/proxy.js
- Proxy test: /Users/testuser/openclaw-billing-proxy/tests/hermes-support.test.js