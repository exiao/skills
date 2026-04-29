---
name: hermes-signal-italic-fix
description: Fix false-positive italics in Signal adapter caused by snake_case underscores. Use when Signal messages show random italics around snake_case identifiers like `config_file` or `OPENAI_API_KEY`. Trigger phrases include "signal italics", "snake_case italic", "Signal formatting bug", "underscore italic".
---

# Signal Italic False-Positive Fix

## Problem
Random italics appear in Signal responses when LLM output contains snake_case identifiers (e.g., `config_file`, `OPENAI_API_KEY`). The underscore-italic regex in `_markdown_to_signal()` is too permissive and matches underscores inside words.

## Root Cause
The regex `(?<!_)_(?!_)(.+?)(?<!_)_(?!_)` only checks that the character before/after the underscore isn't another underscore. It doesn't enforce word-boundary semantics, so `config_file and error_code` gets the middle part italicized.

## Fix
In the Signal adapter's `_markdown_to_signal()` function (~line 673), change the italic regex from:
```
(?<!_)_(?!_)(.+?)(?<!_)_(?!_)
```
To:
```
(?<!\w)_(?!_)(.+?)(?<!_)_(?!\w)
```

The `\w` (word character) lookarounds enforce CommonMark-style word boundary semantics — underscores inside words like `snake_case` are left alone, while standalone `_italic text_` at word boundaries still works.

## Test
All 65 Signal adapter tests pass after the change.
