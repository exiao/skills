---
name: hermes-model-alias-config
description: Configure custom model aliases in Hermes to bypass buggy catalog resolution
category: hermes
tags: [hermes, config, models]
---

# Hermes Model Alias Configuration

## Problem
`resolve_alias()` in `hermes_cli/model_switch.py` picks the FIRST matching model in catalog order, not the latest. Aliases like "sonnet" can resolve to ancient models.

## Solution
Add direct aliases in `~/.hermes/config.yaml` under `model_aliases:` — these bypass catalog resolution entirely.

## User's Current Config
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

## Cache Stats Visibility
- CLI: auto-shown via 💾 Cache line
- Signal/Gateway: suppressed (quiet_mode=True) — check Anthropic dashboard or OpenRouter activity log
- TODO: patch to add logging.debug() for cache stats in gateway mode