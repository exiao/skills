---
name: memory-gc
description: |
  Daily memory garbage collection for MEMORY.md / USER.md. Apply decay rules,
  drain .pending.md, consolidate near-duplicates, maintain canonical theme tags,
  prune old episode and session files. Invoke when asked to "run memory GC",
  "clean up memory", "apply memory decay", or from the scheduled cron job.
---

# memory-gc

Daily garbage collection pass for the Hermes memory system. Read this whole
skill before taking any action. Execute steps in order. Use the `memory` tool
for MEMORY.md / USER.md mutations; use the terminal for filesystem pruning.

## Inputs you already have

- `MEMORY.md` and `USER.md` are already in your system prompt (the snapshot
  shown at the top of this session). Read them there. Each entry looks like:
  ```
  [YYYY-MM-DD][cat] content
  ```

## Decay rules (from the `[meta] Memory format` entry)

| cat                    | action                                              |
|------------------------|-----------------------------------------------------|
| `fact`, `pref`         | review at 60d: still true? keep or `remove`         |
| `env`                  | review at 30d: still accurate? keep or `remove`     |
| `proj:<path>`          | review at 21d; `remove` if path no longer exists    |
| `rel:<name>`           | review at 90d; `remove` if name unmentioned lately  |
| `task`                 | review at 14d; `remove` if completed or abandoned   |
| `tmp`                  | hard `remove` at 7d — no review                     |
| `rule`, `meta`         | never decay                                         |

"Review" = a judgment call by you. Err on the side of keeping. When removing,
log the removal in the final report.

## Procedure

### 1. Compute ages

For each entry in MEMORY.md and USER.md, parse the leading `[YYYY-MM-DD]`
and compute the age in days relative to today. Skip any entry without a
parseable date — report it as unparseable.

### 2. Apply hard drops (no review, no judgment)

- `[tmp]` entries older than 7 days → `memory` tool, `action: remove`, `old_text` = shortest unique substring.
- `[proj:<path>]` entries where the path does not exist on disk → remove.

### 3. Apply review rules

For each entry past its review threshold (from the table above):
- If it's still plausibly accurate / still used → keep.
- If it is obviously stale (refers to resolved tmp state, abandoned project,
  superseded decision) → remove.

Do not remove anything you are not confident is stale. "Unsure" = keep.

### 4. Drain `.pending.md`

```bash
test -s ~/.hermes/episodes/.pending.md && cat ~/.hermes/episodes/.pending.md
```

Each non-empty line is `TARGET\tLINE`. For each line:
- Try to add via `memory` tool (`target` = first field, `content` = second field).
- If it still fails for capacity, either (a) consolidate with an existing
  similar entry via `replace`, or (b) skip and report.

Once processed, clear the file:

```bash
: > ~/.hermes/episodes/.pending.md
```

### 5. Consolidate near-duplicates

Scan MEMORY.md and USER.md for entries that say essentially the same thing
(different dates or phrasing). Merge into one entry using
`memory` tool `action: replace`. Keep the earliest creation date.

### 6. Maintain canonical themes

Collect every tag used in episode files:

```bash
grep -h "^tags:" ~/.hermes/episodes/*.md 2>/dev/null \
  | sed 's/^tags:[[:space:]]*//' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | sort | uniq -c | sort -rn
```

Read the current canonical list from MEMORY.md (the
`[meta] Episode tags (canonical)` entry).

- Any tag used in **≥3** episodes but missing from the canonical list →
  `memory replace` to add it to the `[meta]` entry.
- Near-duplicate tags in use (`debug`/`debugging`, `cron`/`crons`,
  `skill`/`skills`) → pick one canonical spelling. Note the merge in
  your final report (episode-file rewrite is future work, not this pass).

Keep the `[meta] Episode tags` line under ~250 characters. If it starts to
bust, drop themes that have not been used in the last 30 days.

### 7. Prune old files

```bash
find ~/.hermes/episodes -name "*.md" -mtime +90 -delete
find ~/.hermes/sessions -name "*.jsonl" -mtime +180 -delete
```

### 8. Log and report

Append a one-line summary to `~/.hermes/episodes/.gc.log`:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) memory-gc removed=N drained=N consolidated=N themes_added=N files_pruned=N" \
  >> ~/.hermes/episodes/.gc.log
```

Your final response:
- One short paragraph summarizing what changed.
- Only mention anomalies (parse failures, unexpected state, consolidations
  you are unsure about). If everything was routine, say "routine pass, N
  entries removed, M drained, K pruned" and stop.

## Safety rails

- Never `remove` a `[rule]` or `[meta]` entry.
- Never `remove` something whose content you do not understand. Keep it.
- If MEMORY.md / USER.md is malformed (no entries parse), stop immediately
  and report. Do not attempt repair.
- All filesystem commands target only `~/.hermes/episodes` and
  `~/.hermes/sessions`. Never touch `hermes-agent`, `skills`, `plans`,
  `config.yaml`, `.env`, or anything outside those two directories.
