---
name: recall
description: |
  Retrieve memory from past sessions. Use whenever the user asks about past
  conversations, prior decisions, "what did we do about X", "when did we
  last...", "do you remember...", or anything where the answer might live
  outside the current session's context. Uses progressive disclosure across
  six tiers (hot memory → dated episodes → raw sessions) with an uncertainty
  gate — stops expanding context when confidence plateaus.
---

# recall

Three storage tiers, searched cheapest first. Stop at the tier that answers
the question confidently. Do not expand further if more context is not
helping — that is the uncertainty gate.

## Storage tiers

| Tier      | Source                              | Cost                  |
|-----------|-------------------------------------|-----------------------|
| Hot       | `MEMORY.md`, `USER.md`              | ~0 (already in prompt) |
| Episodes  | `~/.hermes/episodes/*.md`           | grep, small files     |
| Sessions  | `~/.hermes/sessions/*.jsonl`        | grep, large files     |

Episodes answer "did this happen, and when". Raw sessions answer "what was
the exact error we hit" — the detail the summary dropped.

## Disclosure levels

Run these in order. Stop as soon as you can answer confidently (see
"Uncertainty gate" below).

### L0 — hot memory
Check `MEMORY.md` and `USER.md` (already in your system prompt). If the
answer is there, you are done.

### L1 — list episode dates
```bash
ls ~/.hermes/episodes/ | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | sort
```
Useful when the user gives a rough date ("last Tuesday", "a couple weeks
ago") — pick the right file and skip to L3.

### L2 — theme match on tag line (canonical themes)
The `[meta] Episode tags (canonical)` entry in MEMORY.md lists searchable
themes. If the user's query maps to one of those themes, grep only the
`tags:` line of each episode file — precise, no false positives from
passing mentions:
```bash
grep -l "^tags:.*\b<theme>\b" ~/.hermes/episodes/*.md
```

### L2.5 — content match across episode files
If L2 misses (query not in canonical themes) or returns nothing, grep
anywhere in episode files:
```bash
grep -il "<query>" ~/.hermes/episodes/*.md
```

### L3 — cat one episode file
Once you have candidate date(s), read the full day's summaries:
```bash
cat ~/.hermes/episodes/<YYYY-MM-DD>.md
```
Each session block has `summary:` and `tags:`. This is usually enough.

### L4 — grep raw session transcripts
When an episode summary dropped the detail you need (exact error string,
code snippet, command used), grep the raw sessions:
```bash
grep -l "<query>" ~/.hermes/sessions/*.jsonl
```
Expensive — only do this if episodes are too coarse.

### L5 — read one raw session
```bash
jq -r '.messages[] | select(.role=="user" or .role=="assistant") | "\(.role): \(.content)"' \
  ~/.hermes/sessions/<session>.jsonl | less
```
Or a simple `cat` if the jsonl is small. Stop here; do not keep searching.

## Uncertainty gate

After each tier, self-rate your confidence in the current answer on a
0–1 scale:

1. Start at L0. If confidence ≥ 0.7, answer.
2. Else expand one tier. Re-answer. Re-score.
3. If confidence gained from this tier is < 0.1 (context did not help),
   **stop** — more context is noise. Tell the user what you found and
   what's still uncertain.
4. Hard cap at L5. If still low confidence there, say you don't know.
   Do not fabricate.

Skipping tiers is fine when the query shape makes the lower tier irrelevant
(e.g. date-shaped query → straight to L3; exact-error query → straight
to L4).

## Output shape

- If a single clear answer emerged, state it with the episode date as
  evidence: *"On 2026-04-15 we fixed the Anthropic proxy routing — the
  `_get_model_config()` merge patch."*
- If multiple episodes matched, list them briefly with dates and let the
  user pick.
- If nothing matched, say so — do not invent.

## Safety rails

- Never expose content from `~/.hermes/.env`, `auth.json`, `state.db`, or
  anything in `~/.ssh/` / `~/.aws/`. `recall` reads only `episodes/` and
  `sessions/`.
- Never share raw transcript content from group-chat sessions without
  summarizing first. Signal UUIDs, phone numbers, and third-party PII
  must not appear in your answer even if they appear in the transcript.
