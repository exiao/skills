---
name: hermes-model-aliases
description: Fix broken Hermes model switching shortcuts with custom aliases in config.yaml
tags: [hermes, config, models]
---

# Hermes Custom Model Aliases

## Problem
`resolve_alias()` in `hermes_cli/model_switch.py` (lines 321-332) picks the **first match** in catalog order, not the latest model. Built-in shortcuts like "opus", "sonnet", "gpt" resolve to old/wrong models.

## Solution
Add `model_aliases:` to `~/.hermes/config.yaml`. These are "Direct Aliases" checked BEFORE the buggy catalog lookup (loaded by `_load_direct_aliases()` lines 153-186).

## Format
```yaml
model_aliases:
  shortcut_name:
    model: "exact-model-id"
    provider: provider_name     # optional
    base_url: "url"             # optional
```

## Example
```yaml
model_aliases:
  opus:
    model: "claude-opus-4-6"
    provider: anthropic
  sonnet:
    model: "claude-sonnet-4-6"
    provider: anthropic
  haiku:
    model: "claude-haiku-4-5"
    provider: anthropic
  gpt:
    model: "gpt-5.3-codex"
    provider: openai-codex
```

## Caching Notes
- Prompt caching is automatic and not configurable
- Cache stats only visible in CLI (gateway/Signal runs quiet_mode=True)
- To verify caching on Signal: check Anthropic dashboard or OpenRouter activity log