# Structured Edit Operations

The skill optimizer uses typed edit operations instead of freeform text changes. This prevents the LLM from rewriting sections it shouldn't touch and gives full observability into what was applied.

Inspired by SkillOpt's `optimizer/skill.py` (Microsoft Research, arxiv:2605.23904).

---

## edit operations

Four operations, matching SkillOpt's edit types:

### append

Add content at the end of the skill document. If `<!-- SLOW_UPDATE_START -->` markers exist, insert before them (the protected section stays at the bottom).

```json
{"op": "append", "content": "## New Section\n\nContent to add at the end."}
```

No `target` field needed.

### insert_after

Add content after a specific heading or text in the skill.

```json
{"op": "insert_after", "target": "## Anti-patterns", "content": "\n- NEVER use numbered lists in diagrams"}
```

The `target` must be an exact substring match. If the target is not found, falls back to `append` behavior (insert before SLOW_UPDATE markers or at the end). Logged as `applied_insert_after_fallback_append`.

### replace

Find exact target text and replace it with new content.

```json
{"op": "replace", "target": "Use pastel, soft colors", "content": "Use these exact colors: #A8D8EA, #AA96DA, #FCBAD3, #FFFFD2, #B5EAD7"}
```

Both `target` and `content` are required. If the target is not found in the skill, the edit is skipped (logged as `skipped_not_found`). Only the first occurrence is replaced.

### delete

Remove exact target text from the skill.

```json
{"op": "delete", "target": "- Always use Comic Sans for labels"}
```

Only `target` is needed. If the target is not found, the edit is skipped.

---

## protected regions

The slow update process writes guidance between markers:

```
<!-- SLOW_UPDATE_START -->
When generating complex diagrams with many nodes, increase spacing
to prevent label overlap.
<!-- SLOW_UPDATE_END -->
```

**Protection rules:**
- Before applying any `insert_after`, `replace`, or `delete` op, check if the `target` text falls within the SLOW_UPDATE markers.
- If it does, skip the edit and log it as `skipped_protected`.
- `append` operations automatically insert before the SLOW_UPDATE markers (not after them).
- Only the slow update process (step 6i) can modify content between these markers.
- Step-level edits that attempt to insert SLOW_UPDATE markers themselves should have those markers stripped from the edit content to prevent duplication.

---

## request format

The optimizer model should produce edits in this JSON structure:

```json
{
  "reasoning": "why these edits address the highest-impact failure pattern",
  "failure_summary": [
    {"pattern": "numbered steps in diagrams", "count": 3, "description": "3/5 failures included step numbers"}
  ],
  "edits": [
    {"op": "append", "content": "## Anti-patterns\n\nNEVER include step numbers."},
    {"op": "replace", "target": "Use soft colors", "content": "Use these colors: #A8D8EA, #AA96DA"}
  ]
}
```

The `failure_summary` is optional but encouraged for logging. The `edits` array is required.

---

## apply report format

After applying edits, generate a report for each one:

```json
[
  {
    "index": 1,
    "op": "append",
    "target_preview": "",
    "content_preview": "## Anti-patterns\nNEVER include step nu...",
    "status": "applied"
  },
  {
    "index": 2,
    "op": "replace",
    "target_preview": "Use soft colors",
    "content_preview": "Use these colors: #A8D8EA, #AA96DA",
    "status": "applied"
  }
]
```

**Status values:**
- `applied` -- edit was applied successfully
- `applied_append_before_slow_update` -- append inserted before SLOW_UPDATE markers
- `applied_insert_after` -- insert_after found target, content added after it
- `applied_insert_after_fallback_append` -- insert_after target not found, fell back to append
- `skipped_protected` -- target is inside the SLOW_UPDATE protected region
- `skipped_not_found` -- target text not found in the skill (for replace/delete)
- `skipped_missing_target` -- replace or delete op missing required target field
- `error` -- unexpected failure during application

The apply report is logged in the experiment record and displayed in the changelog.

---

## fallback behavior

If the optimizer model produces freeform text instead of structured JSON (no `edits` array found):

1. Treat the entire response as a single `append` operation.
2. Log the fallback in the apply report with status `fallback_freeform_to_append`.
3. Proceed with the normal validation gate.

This ensures the optimization loop never stalls on a malformed response. The freeform content still goes through the protected-region check (append inserts before SLOW_UPDATE markers).

---

## tips for the optimizer model

When proposing edits:

- Prefer `replace` over `delete` + `append` when modifying existing content. Fewer ops = fewer chances for target-not-found failures.
- Use exact text for `target` fields. Copy-paste from the skill, don't paraphrase.
- Keep edit content focused. One edit should address one thing. If you need to change three separate paragraphs, that's three edits.
- Don't propose edits that target the SLOW_UPDATE section. They'll be automatically skipped.
- When adding new content, `insert_after` with a heading target is more precise than `append` (which just adds to the end).
