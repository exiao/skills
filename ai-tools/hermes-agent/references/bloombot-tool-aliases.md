# Bloombot tool aliasing: renaming `skill_view`

Use when a gateway profile such as Bloombot exposes a built-in Hermes tool with an awkward model-facing name and the user asks to rename, alias, hide, or overwrite it.

## Finding

`skill_view` is registered by Hermes core in `tools/skills_tool.py` under the `skills` toolset. Bloombot inherits it through the `hermes-whatsapp` / `hermes-cli` core tool surface, so the live tool list can include:

- `skills_list`
- `skill_view`
- `skill_manage`

A simple config rename is not available. Tool names come from registry entries and schemas, not from `config.yaml` aliases.

## Safe Bloombot-only pattern

Prefer a small profile/plugin alias over editing Hermes core:

1. Add a user/profile plugin, for example `bloombot-tool-aliases`.
2. Import the existing handler/schema from `tools.skills_tool`.
3. Deregister the old tool name from the registry.
4. Register the nicer name, for example `load_skill`, in a plugin toolset.
5. Add the alias tool to the plugin manager's tracked plugin tools so `_get_platform_tools()` discovers and enables its toolset.
6. Restart the Bloombot Hermes gateway so the new tool surface is built.

Prototype shape:

```python
def register(ctx):
    from tools.registry import registry
    from tools.skills_tool import SKILL_VIEW_SCHEMA, _skill_view_with_bump

    registry.deregister("skill_view")

    schema = dict(SKILL_VIEW_SCHEMA)
    schema["name"] = "load_skill"
    schema["description"] = "Load a Hermes skill document or one of its linked files."

    ctx.register_tool(
        name="load_skill",
        toolset="bloom-skills",
        schema=schema,
        handler=_skill_view_with_bump,
        emoji="📚",
    )
```

If using direct `registry.register()` instead of `ctx.register_tool()`, also add the new tool name to the plugin manager's `_plugin_tool_names`, otherwise `_get_platform_tools()` may not include the plugin toolset.

## Verification

Run with the target profile's `HERMES_HOME`:

```bash
HERMES_HOME=/path/to/bloombot/hermes python - <<'PY'
from hermes_cli.config import load_config
from hermes_cli.plugins import discover_plugins
from hermes_cli.tools_config import _get_platform_tools
from model_tools import get_tool_definitions

discover_plugins()
cfg = load_config()
ts = sorted(_get_platform_tools(cfg, "whatsapp"))
tools = [t["function"]["name"] for t in get_tool_definitions(ts, quiet_mode=True)]
print("toolsets:", ts)
print("skills-ish:", [t for t in tools if "skill" in t or t == "load_skill"])
PY
```

Expected after the alias plugin:

- `load_skill` present
- `skill_view` absent
- `skills_list` and `skill_manage` still present unless intentionally hidden

## Pitfalls

- Registering `load_skill` under a new toolset with `registry.register()` alone is insufficient for the gateway tool surface. Plugin discovery depends on plugin-tracked tool names for platform toolset resolution.
- Overwriting a built-in tool by re-registering the same name is rejected by the registry unless you deregister first.
- Update related schema descriptions if needed. `skills_list` may still say "Use skill_view(name)" unless patched or aliased.
- Changes require gateway restart. Tool changes do not reliably affect an already-running conversation because Hermes preserves tool/system prompt caching.
