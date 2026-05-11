# Fastlane Cron Automation Pitfalls

Session source: 2026-05-09 Bloom `fastlane-daily` cron failure.

## macOS bash 3.2 compatibility

Hermes cron may execute shell wrappers with `/bin/bash` on macOS. That is Bash 3.2 and does **not** support associative arrays.

Failure signature:

```text
declare: -A: invalid option
declare: usage: declare [-afFirtx] [-p] [name[=value] ...]
```

Fix options:

- Prefer portable shell data structures in cron scripts: parallel arrays, temp TSV/JSON files, or `jq` lookups.
- If Bash 4+ is truly required, install and call it explicitly from the Python wrapper. Do not assume `/usr/bin/env bash` finds Homebrew bash in cron.
- Verify with `bash -n path/to/script.sh` before rerunning.

Portable replacement pattern for `content_id -> suggestion`:

```bash
suggestion_ids=()
suggestion_values=()

get_suggestion() {
  local lookup="$1"
  local idx
  for idx in "${!suggestion_ids[@]}"; do
    if [ "${suggestion_ids[$idx]}" = "$lookup" ]; then
      printf '%s' "${suggestion_values[$idx]}"
      return 0
    fi
  done
  return 1
}

suggestion_ids+=("$content_id")
suggestion_values+=("$suggestion")
caption="$(get_suggestion "$cid" || true)"
```

## Blitz suggestion extraction

`POST /blitz` can return `data.suggestion` as a structured object. Scheduling that object directly produces ugly captions containing JSON metadata.

Use this extraction shape:

```bash
suggestion=$(echo "$response" | jq -r '
  (.data.suggestion.generatedText // .data.hook.generatedText // .data.title // .data.suggestion // .data.hook // "")
  | if type == "object" then (.generatedText // "") else . end
' 2>/dev/null)
```

Then validate captions before scheduling:

- If the caption begins with `{` or contains keys like `aiExplanation`, stop and extract `generatedText`.
- For YouTube, use a short title in `caption` and put longer text in `description`.

## Failure recovery workflow

When the script fails before any `POST /blitz`, it is safe to fix and rerun. When it fails after generation or scheduling, first inspect output/logs and Fastlane posts to avoid duplicate scheduled posts.

Report structure for cron failures:

1. Root cause and whether the script was patched.
2. Generated count, failed count, still-building count.
3. Content IDs grouped by type.
4. Scheduled posts by platform/time/post ID.
5. Skips that are expected, e.g. YouTube slideshow incompatibility.
6. Remaining cleanup, especially caption edits if bad data was already scheduled.
