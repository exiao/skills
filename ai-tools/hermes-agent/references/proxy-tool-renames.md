# Proxy tool renames

Use this when a user asks to rename, alias, overwrite, or make a Hermes tool name nicer and the request may involve the Claude/Anthropic billing proxy rather than Hermes core.

## Key lesson

Hermes-side tool aliases and proxy-side tool renames are different layers.

Do not jump to plugins or `tools.registry` changes when the user's wording is "overwrite tool name" and there is already a proxy config for it. First inspect the proxy config.

## Files

- Proxy config: `~/.hermes/proxy/config.json`
- Proxy implementation: `~/.hermes/proxy/proxy.js`
- Relevant config key: `toolRenames`
- Defaults in proxy.js: `DEFAULT_TOOL_RENAMES`

`config.toolRenames` is merged over `DEFAULT_TOOL_RENAMES` unless `mergeDefaults` is explicitly false. Because merge uses the original tool name as the key, adding the same original name overwrites the default destination.

## Example: rename skill_view to a nicer proxy name

Default mappings currently include:

```json
["skill_view", "SkillView"]
["mcp_skill_view", "SkillView"]
```

To override the display name sent through the proxy:

```json
{
  "port": 18801,
  "credentialsPath": "/path/to/credentials.json",
  "toolRenames": [
    ["skill_view", "LoadSkill"],
    ["mcp_skill_view", "LoadSkill"]
  ]
}
```

Then restart the proxy process so config reloads.

## Verification

1. Inspect effective config behavior in `proxy.js`: `loadConfig()` should merge `DEFAULT_TOOL_RENAMES` with `config.toolRenames`.
2. Search a request dump or run the proxy troubleshooting script:

```bash
cd ~/.hermes/proxy
node troubleshoot.js
```

3. Confirm outgoing tool schemas use the new proxy-facing name and responses are reverse-mapped back to the original Hermes name.

## Pitfalls

- This only affects traffic routed through the proxy. It does not change the native Hermes tool surface for OpenAI Codex, Gemini, or OpenRouter unless those providers use an equivalent proxy layer.
- Do not create a Hermes plugin just to rename a proxy-facing tool. That changes the real tool registry and can affect non-proxy providers.
- If working on a remote bot like Bloombot, verify whether its live provider/base URL actually routes through the proxy before promising the rename works in production.
- Avoid putting VPS passwords or secrets into shell commands. Use SSH keys, an interactive approved session, or ask for proper access.
