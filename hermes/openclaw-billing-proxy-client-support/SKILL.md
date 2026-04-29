---
name: openclaw-billing-proxy-client-support
description: Extend the openclaw-billing-proxy to support a new client fingerprint (for example Hermes) by adding trigger-string sanitization, tool renames, reverse mappings, docs, and a regression test.
---

# OpenClaw Billing Proxy: Add Support For A New Client

Use this when working in the `openclaw-billing-proxy` repo and you need to make the proxy support another Anthropic-facing client surface beyond OpenClaw itself.

This is the repeatable pattern used to add Hermes support.

## When to use
- A new client sends distinctive persona/config strings that may fingerprint requests
- A new client exposes a stable tool surface (for example `mcp_*`) that should be renamed before forwarding to Anthropic
- You need bidirectional compatibility: sanitized outbound requests, but original names restored in inbound responses

## Core approach
1. Identify the client’s fingerprint surface from real local artifacts
2. Add outbound string replacements in `DEFAULT_REPLACEMENTS`
3. Add inbound reverse mappings in `DEFAULT_REVERSE_MAP`
4. Add tool renames in `DEFAULT_TOOL_RENAMES`
5. Update counts/docs/version metadata
6. Add a regression test that exercises `processBody()` and `reverseMap()`
7. Run syntax + test verification

## Discovery steps
1. Inspect the target client’s real config and/or captured request payloads.
   - For Hermes, useful sources were:
     - `~/.hermes/config.yaml`
     - `~/.hermes/sessions/request_dump_*.json`
2. Extract:
   - branding / persona strings
   - platform adapter names
   - tool names actually sent to Anthropic
3. Do not guess the tool list if you can inspect a real request dump.

## Code changes

### 1) Add string sanitization
Edit `proxy.js`:
- Add client-specific outbound replacements near the top of `DEFAULT_REPLACEMENTS`
- Add exact reverse mappings to `DEFAULT_REVERSE_MAP`

Guidelines:
- Put the most specific phrase first (example: `Hermes Agent Persona` before `Hermes Agent`)
- Keep lowercase/path-sensitive replacements space-free if they could ever appear in file paths
- Preserve bidirectionality: every sanitized term should have an inverse mapping unless intentionally one-way

### 2) Add tool renames
Edit `DEFAULT_TOOL_RENAMES` in `proxy.js`.

Guidelines:
- Rename the exact quoted tool names the client sends
- Use Claude-Code-like names (PascalCase / action-oriented names)
- Keep mappings deterministic and human-readable
- Avoid collisions with Anthropic content block `type` tags or other protocol fields

### 3) Update metadata/docs
Usually update:
- `proxy.js` version constant
- `setup.js` displayed default counts if they are hard-coded there
- `README.md` support/configuration sections
- `CHANGELOG.md`

## Regression test pattern
This repo does not expose `processBody()` / `reverseMap()` as a library API, so the reliable test pattern is:

1. Create a `node:test` file under `tests/`
2. Load `proxy.js` as text
3. Replace the trailing startup lines:
   - `const config = loadConfig();`
   - `startServer(config);`
4. Inject `module.exports = { processBody, reverseMap, DEFAULT_REPLACEMENTS, DEFAULT_REVERSE_MAP, DEFAULT_TOOL_RENAMES, DEFAULT_PROP_RENAMES };`
5. Execute with `vm.runInNewContext(...)`
6. Build a config object directly from the default arrays
7. Assert:
   - client strings are removed from processed output
   - tool names are renamed in processed output
   - file paths survive unchanged
   - `reverseMap()` restores the original names/strings

This lets you test transformation logic without refactoring the production script first.

## Verification commands
Run from repo root:

```bash
node --test tests/<your-test>.test.js
node -c proxy.js
node -c setup.js
node -c troubleshoot.js
```

## Hermes-specific findings worth remembering
- Hermes definitely exposed fingerprintable strings including:
  - `Hermes Agent`
  - `Hermes Agent Persona`
- Do not stop at proxy-side edits if live Hermes requests still fail. First verify whether Hermes is actually reaching the proxy.
- In this case, the first real blocker was Hermes itself: `hermes chat` ignored `providers.anthropic.base_url` in `~/.hermes/config.yaml` because runtime resolution only honored `model.base_url`.
- The Hermes-side fix was in `~/.hermes/hermes-agent/hermes_cli/runtime_provider.py`:
  - `_get_model_config()` must merge provider-specific config from `config["providers"][active_provider]`
  - only fill `base_url` / `api_key` from the provider section when `model.base_url` / `model.api_key` are unset
  - preserve model-level precedence
- Add a regression test on the Hermes side proving `resolve_runtime_provider(requested="anthropic")` returns `providers.anthropic.base_url` when `model.provider == "anthropic"` and `model.base_url` is unset.
- After the Hermes-side fix, verify with a real runtime check before touching proxy logic again:
  - `resolve_runtime_provider(requested='anthropic')`
  - confirm it returns `http://127.0.0.1:18801`
- Once Hermes truly hits the proxy, inspect the processed outbound body, not just the raw request dump.
- Do not assume the raw JSON is minified. Hermes requests sent through the Python Anthropic SDK include spaces like `"text": "..."`, so proxy markers that rely on exact substrings like `"text":"# ...` can silently fail. When stripping system blocks, search for the human marker text first, then walk backward to the enclosing `"text"` field.
- In this case the processed Hermes payload still leaked two unsanitized tool names:
  - `mcp_mixture_of_agents`
  - `mcp_send_message`
- Those two were enough to keep triggering proxy-side detection even though the larger Hermes `mcp_*` rename set had already been added in the past.
- Minimal proxy fix:
  - add `mcp_mixture_of_agents -> MixtureOfAgents` to `DEFAULT_TOOL_RENAMES`
  - add `mcp_send_message -> SendMessageTool` to `DEFAULT_TOOL_RENAMES`
  - add the matching reverse mappings in `DEFAULT_REVERSE_MAP`
- Update the proxy regression test to assert those defaults exist and that both names are removed from processed output and restored by `reverseMap()`.
- Verification pattern that worked:
  1. Hermes regression test passes
  2. `resolve_runtime_provider(requested='anthropic')` shows the proxy URL
  3. inspect the processed proxy body locally to confirm no leaked `mcp_*` names remain
  4. run `node --test tests/hermes-support.test.js`
  5. rerun the live `hermes chat -q ...` request and inspect proxy logs
### Debugging Hermes-shaped payloads

Three durable lessons from live debugging of the Hermes client:

1. **Failures compound — isolate each stage.** A single symptom (400 extra-usage) can come from multiple bugs stacked: client not reaching proxy, proxy not renaming tool names, proxy not stripping the client's system prompt. Fix one at a time; re-verify after each.

2. **Replay method.** Capture the fully assembled client request (e.g. from `~/.hermes/sessions/request_dump_*.json`), replay it directly through `http://127.0.0.1:18801/v1/messages`, then swap one major block at a time (system prompt, tool list, tool schemas) to identify which block flips the response from 200 → 400. Full-prompt replay beats file-by-file guessing because individual files pass in isolation.

3. **Tool-count billing-shape trigger.** Max-subscription endpoints appear to accept payloads up to ~130 tools; at ~131 the request flips to extra-usage even when tool schemas are minified. Tool count itself is a likely trigger, not just total bytes. When `troubleshoot.js` shows a passing minimal payload plus a failing high-tool-count replay, cap forwarded tool count to ~120-130 before expanding fingerprint-stripping.

Implementation hint: put pure helpers (`buildMinimalToolSubset`, `buildHermesDiagnosticCases`, `summarizeHermesDiagnostics`) in a `troubleshoot-helpers.js` module with node tests; keep `troubleshoot.js` focused on wiring them into live proxy requests and printing operator guidance.

## Pitfalls
- This repo may already have a dirty worktree; check `git status` before editing and mention it to the user
- Do not rely on broad filesystem scans if the user is actively messaging; open the exact repo path directly
- If the test still shows unsanitized names, first verify your test actually loaded the modified defaults (add sanity asserts on `DEFAULT_REPLACEMENTS` / `DEFAULT_TOOL_RENAMES`)
- Keep path protection in mind: tests should include a real path string to ensure replacements do not corrupt it
- Do not assume every observed tool name should be renamed. First try the minimal change set, then verify with `troubleshoot.js` and, if possible, a real client request through the proxy.
- Prefer evidence from real request dumps over config files when deciding whether a client-specific replacement or rename is justified.

## Done criteria
- New client strings sanitized outbound
- Reverse mappings restore original strings inbound
- Tool renames cover the real transmitted tool surface
- README mentions how to route the client through the proxy
- Regression test passes
- `node -c` passes for all modified JS files
