# Context compression triage

Use this when Hermes shows a warning like `📦 Preflight compression: ~180,197 tokens >= 163,200 threshold` but the session only shrinks a little.

## Key model

The preflight number is full request size, not the amount the compressor can remove.

It includes:
- system prompt, SOUL, memory, project context, loaded skills
- tool schemas
- protected head messages
- protected recent tail
- current user message
- compressible middle transcript

Only the old middle transcript can be summarized away. Tool schemas, system prompt, the current user turn, protected head, and protected tail remain.

## Why savings can be tiny

With config like:

```yaml
compression:
  threshold: 0.6
  target_ratio: 0.2
  protect_last_n: 20
```

A 272k context gives a 163.2k threshold. `target_ratio: 0.2` makes the tail budget about 32.6k tokens, before also accounting for the fixed `protect_last_n` behavior and boundary alignment around tool call/result groups. If the request is dominated by tools, system prompt, and recent protected tail, compression may have only a small middle window to remove, even when total request tokens are above threshold.

## Diagnosis commands

Search logs around the event:

```bash
grep -E "Preflight compression|context compression done|Compressed:|Summarizing turns|Context compressor initialized" \
  ~/.hermes/logs/gateway.log ~/.hermes/logs/agent.log 2>/dev/null | tail -80
```

Check config:

```bash
grep -nE "compression:|threshold:|target_ratio:|protect_last_n" ~/.hermes/config.yaml
```

Relevant code paths:
- `run_agent.py`: preflight uses `estimate_request_tokens_rough(..., tools=self.tools or None)`, so schemas count.
- `agent/context_compressor.py`: `_find_tail_cut_by_tokens()` protects recent tail by `tail_token_budget = threshold_tokens * summary_target_ratio`; `compress()` then summarizes only `messages[compress_start:compress_end]`.

## Response guidance

Explain plainly: compression is not broken merely because savings are small. The UX is misleading because it reports total request size, while the compressor can only remove one slice.

Offer fixes in this order:
1. Start a new session if the user just needs to continue quickly.
2. Reduce enabled toolsets for that platform/session, because schemas can dominate the request.
3. Lower `protect_last_n` or `target_ratio` if preserving less recent context is acceptable.
4. Consider a code fix: if compression savings are below the threshold delta, warn `context mostly uncompressible: protected tail/tools/system dominate` instead of repeated preflight compression.
