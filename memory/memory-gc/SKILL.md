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

## Tool availability

The `memory` tool (MemoryStore) may not be available in all environments (e.g.,
cron jobs). If it returns "Memory is not available", fall back to direct file
editing via `FilePatch` on `~/.hermes/memories/MEMORY.md`. When using FilePatch:
- Remove entries by replacing the entry text AND its trailing `§` separator
  line together in one replacement (match `<entry text>\n§` → empty string).
  This avoids orphaned separators.
- If the entry is the LAST in the file (no trailing `§`), remove just the entry
  text and the preceding `\n§\n` from the entry above it.
- Clean up resulting blank lines with `sed -i '' '/^$/d'` afterward.
- The same safety rails apply: never touch `[rule]` or `[meta]` entries
  (except the step-8 protected-floor guard, which may losslessly *shorten* them,
  never remove).

**Pitfall — multibyte characters:** MEMORY.md may contain unicode (arrows,
special chars in old entries). Use Python for age computation rather than
awk, which chokes on multibyte sequences in some locales.

**Pitfall — FilePatch `§` uniqueness:** The `§` separator appears on every
entry boundary. `old_string` containing just `<text>\n§` will often match
multiple locations. Always include enough surrounding context (adjacent
entry text on both sides) to make the match unique. Alternatively, batch
multiple adjacent removals into a single FilePatch that replaces the whole
multi-entry block at once — this is more reliable than individual removals.

**Pitfall — pending drain in cron:** The `memory` tool (MemoryStore) is
typically unavailable in cron. Pending entries accumulate across cron GC
runs. Do NOT clear `.pending.md` unless entries were actually drained
successfully. They will drain during the next interactive session.

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

Once ALL entries are processed successfully, clear the file:

```bash
: > ~/.hermes/episodes/.pending.md
```

**If `memory` tool is unavailable (cron), skip this step entirely.** Do not
clear the file. Pending entries will accumulate and drain during the next
interactive session where the memory tool works.

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

**Optimization:** If the tag output is large and the canonical list hasn't
changed recently, scan only the top ~30 tags for missing canonicals. Don't
waste tokens on the long tail.

### 7. Prune old files

```bash
find ~/.hermes/episodes -name "*.md" -mtime +90 -delete
find ~/.hermes/sessions -name "*.jsonl" -mtime +180 -delete
```

### 8. Enforce capacity target

After all removals and drains, check the current size of MEMORY.md and read the
configured limit from config (do NOT hardcode it — it has changed over time,
e.g. 6000 → 8000):

```bash
wc -c ~/.hermes/memories/MEMORY.md
LIMIT=$(grep -E '^\s*memory_char_limit:' ~/.hermes/config.yaml 2>/dev/null | grep -oE '[0-9]+' | head -1)
LIMIT=${LIMIT:-8000}
echo "limit=$LIMIT target(70%)=$((LIMIT*70/100))"
```

The target is **70% of the configured limit** (limit 8000 → target 5600).
Compute it from `$LIMIT`, never from a memorized number. GC must always leave
the file below 100% of the limit — parking at 99% is the exact failure mode
this step exists to prevent.

If the file exceeds the target, evict entries.
Eviction priority (evict from top priority first):
1. `[env]` entries older than 21 days (even if still accurate; they can be re-added if needed)
2. `[proj:*]` entries older than 14 days
3. `[fact]` entries older than 45 days
4. Longest entries first (within the same priority tier)

**When no entries meet age thresholds but file is over target:** Fall back to
evicting the longest `[env]` entries first, then longest `[proj:*]` entries,
regardless of age. Prefer entries whose content is also captured in a dedicated
memory file (e.g., `~/.hermes/memories/cpe-research.md`) or in a skill, since
those can be re-derived.

**`[pref]` relocation (the file-stays-at-98% failure mode).** A hot-memory file
dominated by `[rule]` + `[meta]` + long project `[pref]` entries cannot be
brought to target by the env/proj/fact ladder above — those are a small slice
of the bytes. When the file is still over target after that ladder, treat long
**project-scoped** `[pref]` entries as relocation candidates (NOT eviction —
prefs encode user-approved decisions, so move them, don't drop them): append the
content as a dated bullet to the project's dedicated memory file (e.g. Bloom
prefs → `bloom-architecture.md`) **via the `memory` tool** (`target` = the
filename, like Step 4 — never a raw shell append, which would trip the
filesystem-scope safety rail), archive the original to
`~/.hermes/episodes/.gc.log`, then remove it from MEMORY.md. Generic
cross-project prefs stay hot but get a lossless shortening pass. Never relocate a
`[rule]` — rules are behavioral constraints that must stay in the system prompt
every session.

**Protected-floor guard (never silently park at 98%).** Compute the byte total
of `[rule]` + `[meta]` entries alone. If that floor already exceeds the 70%
target, the target is unreachable without shortening protected entries:
1. Losslessly shorten the longest `[rule]`/`[meta]` entries (preserve dates,
   categories, force, and behavioral meaning) until the file is under 100% of
   the limit.
2. Relocate every project-scoped `[pref]` per the rule above.
3. If still over the 70% target, do not loop forever — stop at the lowest
   achievable byte count and **flag it in the final report** ("protected floor
   N chars exceeds 70% target M; durable rule set has outgrown hot memory,
   consider raising memory_char_limit"). Parking just-under-limit with a flag is
   correct here; parking at 98% with no flag is the bug this guard prevents.

Before removing, archive evicted entries to `~/.hermes/episodes/.gc.log`. Do NOT
copy evicted entries back to `.pending.md` — that creates a feedback loop where
entries bounce between MEMORY.md and pending indefinitely.

Keep evicting/relocating until the file is at or below the 70% target, or only
`[rule]` and `[meta]` entries remain.

### 9. Log and report

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

- Never `remove` a `[rule]` or `[meta]` entry. They may be **losslessly
  shortened** (preserving date, category, and behavioral meaning) only under the
  protected-floor guard in step 8 — shortened, never removed.
- Never `remove` something whose content you do not understand. Keep it.
- If MEMORY.md / USER.md is malformed (no entries parse), stop immediately
  and report. Do not attempt repair.
- All filesystem commands target only `~/.hermes/episodes` and
  `~/.hermes/sessions`. Never touch `hermes-agent`, `skills`, `plans`,
  `config.yaml`, `.env`, or anything outside those two directories.