---
name: watchdog-status-cleanup
description: Inspect Hermes/OpenClaw watchdog LaunchAgents on macOS and clean up stale signal-cli send jobs or proxy launcher shells that make status output noisy.
---

# Watchdog Status and Cleanup

Use when the user wants a quick SSH command or local helper to see which Hermes/OpenClaw watchdogs are actually running, or when old one-off `signal-cli send` jobs are piling up.

## What this solves

Two recurring issues came up on this machine:

1. `launchctl list` is the right high-level source for interval LaunchAgents. For `StartInterval` jobs, `PID = -` is normal when idle.
2. `ps aux | grep signal-cli` is noisy because stuck one-off `signal-cli send` processes can linger for hours or days. Those are not the daemon.
3. A manually launched billing proxy can also leave behind a parent shell wrapper plus the real `node proxy.js` child.

## Preferred status helper

Write `~/.hermes/watchdog/status.sh` with a stable, SSH-friendly summary:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "LaunchAgents"
echo -e "PID\tLAST_EXIT\tLABEL"
launchctl list | egrep "hermes|openclaw|watchdog" || true

echo
echo "Live processes"
echo -e "PID\tELAPSED\tNAME"
ps -axo pid=,etime=,command= | awk '
  /hermes gateway/ {print $1 "\t" $2 "\thermes gateway"; next}
  /signal-cli/ {print $1 "\t" $2 "\tsignal-cli"; next}
  /proxy_watchdog\.sh/ {print $1 "\t" $2 "\tproxy_watchdog.sh"; next}
  /billing_proxy_refresh_watchdog\.sh/ {print $1 "\t" $2 "\tbilling_proxy_refresh_watchdog.sh"; next}
  /meta_watchdog\.sh/ {print $1 "\t" $2 "\tmeta_watchdog.sh"; next}
  /wake_check\.sh/ {print $1 "\t" $2 "\twake_check.sh"; next}
  /backup_signal\.sh/ {print $1 "\t" $2 "\tbackup_signal.sh"; next}
  /resource_check\.sh/ {print $1 "\t" $2 "\tresource_check.sh"; next}
  /proxy\.js/ {print $1 "\t" $2 "\tbilling proxy"; next}
' | awk '!seen[$0]++'
```

Then:

```bash
chmod +x ~/.hermes/watchdog/status.sh
~/.hermes/watchdog/status.sh
```

SSH usage:

```bash
ssh HOST '~/.hermes/watchdog/status.sh'
```

## How to read the output

- LaunchAgents:
  - `PID = -` for `ai.openclaw.proxy-watchdog` and `ai.openclaw.billing-proxy-refresh-watchdog` is normal. They are interval jobs, not daemons.
  - long-lived daemons should show a PID, like `com.nousresearch.hermes-gateway` or `ai.openclaw.signal-daemon`.
- Live processes:
  - `hermes gateway` should usually have one long-lived PID.
  - `signal-cli` may include the real daemon plus many stale `send` processes.
  - `billing proxy` may show both the real `node proxy.js` and a parent shell wrapper if it was started manually.

## Cleanup helper

When status output is polluted by stale `signal-cli send` jobs or an old proxy wrapper shell, write `~/.hermes/watchdog/cleanup.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=1
MIN_AGE_SECONDS=$((10 * 60))

while [ $# -gt 0 ]; do
  case "$1" in
    --run) DRY_RUN=0 ;;
    --dry-run) DRY_RUN=1 ;;
    --age-min)
      shift
      MIN_AGE_SECONDS=$((${1:?missing value} * 60))
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ~/.hermes/watchdog/cleanup.sh [--dry-run] [--run] [--age-min N]
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

echo "Mode: $([ "$DRY_RUN" -eq 0 ] && echo run || echo dry-run)"
echo "Min age: $((MIN_AGE_SECONDS / 60)) minutes"
echo
printf "%-8s %-8s %-18s %s\n" "PID" "AGE_S" "TYPE" "COMMAND"

export MIN_AGE_SECONDS
TARGETS=$(ps -axo pid=,etime=,command= | python3 -c $'import json, os, sys

def etime_to_seconds(value: str) -> int:
    value = value.strip()
    days = 0
    if "-" in value:
        day_part, value = value.split("-", 1)
        days = int(day_part)
    parts = [int(x) for x in value.split(":")]
    if len(parts) == 2:
        hours = 0
        minutes, seconds = parts
    elif len(parts) == 3:
        hours, minutes, seconds = parts
    else:
        raise ValueError(f"unsupported etime format: {value!r}")
    return days * 86400 + hours * 3600 + minutes * 60 + seconds

min_age = int(os.environ["MIN_AGE_SECONDS"])
rows = []
for raw in sys.stdin:
    line = raw.rstrip("\\n")
    if not line.strip():
        continue
    parts = line.strip().split(None, 2)
    if len(parts) < 3:
        continue
    pid_s, etime_s, cmd = parts
    pid = int(pid_s)
    age = etime_to_seconds(etime_s)
    target_type = None

    if "org.asamk.signal.Main" in cmd and " daemon " not in cmd and " send " in cmd and age >= min_age:
        target_type = "signal-send"
    elif "bash -c" in cmd and "node proxy.js" in cmd and age >= min_age:
        target_type = "proxy-wrapper"

    if target_type:
        rows.append({"pid": pid, "age": age, "type": target_type, "cmd": cmd})

print(json.dumps(rows))' )

COUNT=$(TARGETS_JSON="$TARGETS" python3 - <<'PY'
import json, os
print(len(json.loads(os.environ['TARGETS_JSON'])))
PY
)

if [ "$COUNT" -eq 0 ]; then
  echo "No matching stale processes found."
  exit 0
fi

TARGETS_JSON="$TARGETS" python3 - <<'PY'
import json, os
for row in json.loads(os.environ['TARGETS_JSON']):
    cmd = row['cmd']
    if len(cmd) > 90:
        cmd = cmd[:87] + '...'
    print(f"{row['pid']:<8} {row['age']:<8} {row['type']:<18} {cmd}")
PY

echo
if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run only. Re-run with --run to terminate these processes."
  exit 0
fi

TARGETS_JSON="$TARGETS" python3 - <<'PY' | while IFS=$'\t' read -r pid target_type; do
import json, os
for row in json.loads(os.environ['TARGETS_JSON']):
    print(f"{row['pid']}\t{row['type']}")
PY
  [ -n "$pid" ] || continue
  echo "Stopping $target_type pid=$pid"
  kill "$pid" 2>/dev/null || true
  sleep 1
  if kill -0 "$pid" 2>/dev/null; then
    echo "Force killing $target_type pid=$pid"
    kill -9 "$pid" 2>/dev/null || true
  fi
done

echo
echo "Cleanup complete."
```

Then:

```bash
chmod +x ~/.hermes/watchdog/cleanup.sh
~/.hermes/watchdog/cleanup.sh --dry-run
~/.hermes/watchdog/cleanup.sh --run
```

## Practical interpretation

If you see:
- one `hermes gateway` PID
- one long-lived `signal-cli` daemon PID
- `proxy-watchdog` and `billing-proxy-refresh-watchdog` loaded with `PID = -`

that is fine.

If you see dozens of `signal-cli` rows with one-off send commands, run the cleanup helper in dry-run first.

## Pitfalls

- Do not treat `PID = -` in `launchctl list` as broken for interval LaunchAgents.
- Do not kill the long-lived `signal-cli daemon --http 127.0.0.1:8080` process unless you mean to restart Signal.
- The billing proxy can appear twice when manually started: parent shell plus `node proxy.js` child.
- `ps aux` is too noisy for this task. Prefer `ps -axo pid=,etime=,command=` and summarize it.
