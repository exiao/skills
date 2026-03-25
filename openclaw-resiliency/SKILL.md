---
name: openclaw-resiliency
description: Set up a gateway watchdog that monitors OpenClaw health and auto-recovers from failures. Covers 3-tier health checks (process, HTTP, channel deep health), exponential backoff, signal-cli special handling, and launchd/systemd integration. Use when someone wants their OpenClaw instance to self-heal and stay online.
---

# OpenClaw Resiliency (Gateway Watchdog)

## Overview

The watchdog is a lightweight shell script that runs every 5 minutes via launchd (macOS) or systemd timer (Linux). It checks gateway health in three tiers of increasing cost, only escalating when cheaper checks pass. It handles the most common failure modes: gateway process crashes, hung HTTP, and channel disconnections (especially signal-cli flakiness).

## Prerequisites

- A running OpenClaw gateway (via daemon or LaunchAgent/systemd)
- `curl`, `python3`, `jq` available on PATH
- The OpenClaw CLI installed (for deep health checks)
- The gateway's HTTP health endpoint accessible at `http://127.0.0.1:<port>/health`

## Architecture: 3-Tier Health Checks

```
Tier 1: Process exists? (pgrep, ~0ms)
  → No process found for N consecutive checks → launchctl kickstart
  → Process found → continue to Tier 2

Tier 2: HTTP /health returns 200? (curl, ~1s)
  → Not responding → SIGUSR1 (graceful restart)
  → Responding → continue to Tier 3

Tier 3: Deep channel health via CLI (openclaw health --json, ~3s)
  → All channels OK → reset all counters, exit healthy
  → Signal down → track streak, only restart after 3+ consecutive failures
  → Other channels down → SIGUSR1 with backoff
  → Parse error / unhealthy → SIGUSR1 with backoff
```

## Key Design Decisions

1. **SIGUSR1 over SIGTERM.** SIGUSR1 triggers a graceful restart that preserves in-flight agent runs. Only escalate to process kill if SIGUSR1 doesn't recover.
2. **Let launchd/systemd handle crashes.** If the process is gone, the watchdog doesn't restart it directly. It waits for the OS service manager (KeepAlive/Restart=always). Only after N consecutive "no process" checks does it force a kickstart.
3. **Signal-cli gets extra patience.** Signal-cli is the most fragile component (30-60s startup, SSE drops). The watchdog tracks signal failures separately and only restarts after 3+ consecutive failures. It kills `signal-cli` specifically before sending SIGUSR1.
4. **Exponential backoff.** After repeated failures, the watchdog backs off to prevent restart storms. After 4 consecutive failures, it enters a 30-minute cooldown.
5. **Warmup grace period.** If the gateway process started less than 90 seconds ago, all checks are skipped. This prevents the watchdog from fighting a gateway that's still booting.
6. **Stale failure reset.** If the last restart attempt was more than 10 minutes ago and the failure count is nonzero, it resets. Old failures shouldn't penalize new checks.

## Step 1: Create the Watchdog Script

Create the watchdog script. Recommended location: `~/.openclaw/scripts/watchdog.sh` (or wherever makes sense on your system).

```bash
#!/bin/bash
# OpenClaw Gateway Watchdog v5
# Monitors gateway health with graceful restarts and backoff.
# Falls back to launchctl kickstart if launchd KeepAlive fails.
#
# Designed to run every 5 minutes via launchd (macOS) or systemd timer (Linux).
# Checks health in 3 tiers: process → HTTP → channel deep health.

# --- Configuration (override with env vars) ---
CLI="${OPENCLAW_CLI:-openclaw}"
GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
GATEWAY_LAUNCHD_LABEL="${OPENCLAW_LAUNCHD_LABEL:-com.openclaw.gateway}"
GATEWAY_SYSTEMD_UNIT="${OPENCLAW_SYSTEMD_UNIT:-openclaw-gateway.service}"
LOG_FILE="${OPENCLAW_WATCHDOG_LOG:-/tmp/openclaw/watchdog.log}"
LOCK_FILE="/tmp/openclaw-watchdog.lock"
STATE_FILE="/tmp/openclaw/watchdog-state.json"

# Warmup: skip checks if gateway booted < this many seconds ago
WARMUP_SECONDS=90
# Signal gets extra patience: only restart after this many consecutive failures
SIGNAL_DOWN_THRESHOLD=3
# Max signal restart attempts before it feeds into global failure count
SIGNAL_MAX_RESTARTS=6
# Max consecutive restart failures before long cooldown
MAX_FAILURES=4
# Cooldown after max failures (30 min)
COOLDOWN_SECONDS=1800
# If last restart was more than this long ago, reset failure counter (stale)
STALE_SECONDS=600
# After this many consecutive "no process" checks, force a kickstart
NO_PROCESS_KICKSTART_THRESHOLD=3

mkdir -p /tmp/openclaw

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Rotate log if > 1MB
if [ -f "$LOG_FILE" ] && [ "$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)" -gt 1048576 ]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
fi

# --- Lock (prevent concurrent runs) ---
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local old_pid
        old_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            exit 0
        fi
    fi
    echo $$ > "$LOCK_FILE"
}
release_lock() { rm -f "$LOCK_FILE"; }
trap release_lock EXIT
acquire_lock

# --- State management (uses python3 for JSON) ---
DEFAULT_STATE='{"consecutiveFailures":0,"lastRestartAt":0,"signalDownStreak":0,"backoffUntil":0,"noProcessStreak":0}'

read_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "$DEFAULT_STATE"
    fi
}

write_state() {
    echo "$1" > "$STATE_FILE"
}

get_field() {
    echo "$1" | python3 -c "import sys,json; print(json.load(sys.stdin).get('$2', $3))" 2>/dev/null
}

set_field() {
    echo "$1" | python3 -c "
import sys,json
d=json.load(sys.stdin)
d['$2']=$3
print(json.dumps(d))
" 2>/dev/null
}

now_epoch() {
    date +%s
}

# --- Restart helpers (cross-platform) ---
detect_platform() {
    if [ "$(uname)" = "Darwin" ]; then
        echo "macos"
    else
        echo "linux"
    fi
}

kickstart_gateway() {
    local platform
    platform=$(detect_platform)
    if [ "$platform" = "macos" ]; then
        launchctl kickstart "gui/$(id -u)/${GATEWAY_LAUNCHD_LABEL}" 2>/dev/null
    else
        systemctl --user start "$GATEWAY_SYSTEMD_UNIT" 2>/dev/null || \
        sudo systemctl start "$GATEWAY_SYSTEMD_UNIT" 2>/dev/null
    fi
}

find_gateway_pid() {
    # Try matching the openclaw gateway process
    local pid
    pid=$(pgrep -f "openclaw.*gateway" 2>/dev/null | head -1)
    if [ -z "$pid" ]; then
        # Also try matching the node entry.js gateway pattern from service plists
        pid=$(pgrep -f "node.*entry.js.*gateway" 2>/dev/null | head -1)
    fi
    if [ -z "$pid" ]; then
        # Try clawdbot (older installations)
        pid=$(pgrep -f "clawdbot.*gateway" 2>/dev/null | head -1)
    fi
    echo "$pid"
}

state=$(read_state)
now=$(now_epoch)

# --- Reset stale failure counter ---
last_restart=$(get_field "$state" "lastRestartAt" "0")
if [ "$last_restart" -gt 0 ] && [ $((now - last_restart)) -gt "$STALE_SECONDS" ]; then
    old_failures=$(get_field "$state" "consecutiveFailures" "0")
    if [ "$old_failures" -gt 0 ]; then
        state=$(set_field "$state" "consecutiveFailures" "0")
        state=$(set_field "$state" "backoffUntil" "0")
        write_state "$state"
    fi
fi

# --- Check backoff ---
backoff_until=$(get_field "$state" "backoffUntil" "0")
if [ "$now" -lt "$backoff_until" ]; then
    exit 0
fi

# --- Tier 1: Process check ---
gateway_pid=$(find_gateway_pid)

if [ -z "$gateway_pid" ]; then
    no_proc_streak=$(get_field "$state" "noProcessStreak" "0")
    no_proc_streak=$((no_proc_streak + 1))
    state=$(set_field "$state" "noProcessStreak" "$no_proc_streak")
    write_state "$state"

    if [ "$no_proc_streak" -ge "$NO_PROCESS_KICKSTART_THRESHOLD" ]; then
        log "WARN: No gateway process for $no_proc_streak consecutive checks. Forcing kickstart."
        kickstart_gateway
        state=$(set_field "$state" "lastRestartAt" "$now")
        state=$(set_field "$state" "noProcessStreak" "0")
        write_state "$state"
    else
        log "OK: No gateway process (streak $no_proc_streak/$NO_PROCESS_KICKSTART_THRESHOLD). Waiting for service manager."
    fi
    exit 0
fi

# Process exists: reset no-process streak
no_proc_streak=$(get_field "$state" "noProcessStreak" "0")
if [ "$no_proc_streak" -gt 0 ]; then
    state=$(set_field "$state" "noProcessStreak" "0")
    write_state "$state"
fi

# --- Warmup grace period (based on process start time) ---
if [ "$(detect_platform)" = "macos" ]; then
    proc_start=$(ps -o lstart= -p "$gateway_pid" 2>/dev/null)
    if [ -n "$proc_start" ]; then
        start_epoch=$(date -j -f "%a %b %d %T %Y" "$proc_start" +%s 2>/dev/null || echo 0)
        uptime=$((now - start_epoch))
        if [ "$uptime" -lt "$WARMUP_SECONDS" ]; then
            log "OK: Warming up (uptime ${uptime}s < ${WARMUP_SECONDS}s). Skipping."
            exit 0
        fi
    fi
else
    # Linux: read process start time from /proc
    if [ -d "/proc/$gateway_pid" ]; then
        start_epoch=$(stat -c %Y "/proc/$gateway_pid" 2>/dev/null || echo 0)
        uptime=$((now - start_epoch))
        if [ "$uptime" -lt "$WARMUP_SECONDS" ]; then
            log "OK: Warming up (uptime ${uptime}s < ${WARMUP_SECONDS}s). Skipping."
            exit 0
        fi
    fi
fi

# --- Tier 2: Is the port responding? (cheap HTTP check) ---
http_code=$(curl -sf -o /dev/null -w "%{http_code}" "http://127.0.0.1:${GATEWAY_PORT}/health" --max-time 8 2>/dev/null)
if [ "$http_code" != "200" ]; then
    log "WARN: Gateway process $gateway_pid exists but HTTP not responding (code: $http_code)."
    failures=$(get_field "$state" "consecutiveFailures" "0")
    failures=$((failures + 1))
    state=$(set_field "$state" "consecutiveFailures" "$failures")

    if [ "$failures" -ge "$MAX_FAILURES" ]; then
        state=$(set_field "$state" "backoffUntil" "$((now + COOLDOWN_SECONDS))")
        write_state "$state"
        log "ERROR: Max failures ($MAX_FAILURES). Cooldown ${COOLDOWN_SECONDS}s."
        exit 1
    fi

    log "Sending SIGUSR1 to PID $gateway_pid (attempt $failures/$MAX_FAILURES)..."
    kill -USR1 "$gateway_pid" 2>/dev/null
    state=$(set_field "$state" "lastRestartAt" "$now")
    write_state "$state"
    exit 0
fi

# --- Tier 3: Deep health via CLI (channels, uptime) ---
health_output=$($CLI health --json --timeout 12000 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$health_output" ]; then
    log "WARN: $CLI health --json failed or empty."
    failures=$(get_field "$state" "consecutiveFailures" "0")
    failures=$((failures + 1))
    state=$(set_field "$state" "consecutiveFailures" "$failures")

    if [ "$failures" -ge "$MAX_FAILURES" ]; then
        state=$(set_field "$state" "backoffUntil" "$((now + COOLDOWN_SECONDS))")
        write_state "$state"
        log "ERROR: Max failures ($MAX_FAILURES). Cooldown ${COOLDOWN_SECONDS}s."
        exit 1
    fi

    log "Sending SIGUSR1 to PID $gateway_pid (attempt $failures/$MAX_FAILURES)..."
    kill -USR1 "$gateway_pid" 2>/dev/null
    state=$(set_field "$state" "lastRestartAt" "$now")
    write_state "$state"
    exit 0
fi

# --- Parse health response ---
eval_result=$(echo "$health_output" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)

    if not d.get('ok', False):
        print('unhealthy')
        sys.exit(0)

    channels = d.get('channels', {})
    down = []
    for name, ch in channels.items():
        if not ch.get('configured', False):
            continue
        probe = ch.get('probe', {})
        if not probe.get('ok', False):
            down.append(name)

    if down:
        print('channels_down ' + ' '.join(sorted(down)))
    else:
        print('ok')
except Exception as e:
    print('parse_error ' + str(e)[:80])
" 2>/dev/null)

status=$(echo "$eval_result" | awk '{print $1}')
details=$(echo "$eval_result" | awk '{$1="";print}' | xargs)

if [ -z "$status" ]; then
    status="parse_error"
    details="empty eval result"
fi

# --- Evaluate ---
case "$status" in
    ok)
        if [ "$(get_field "$state" "consecutiveFailures" "0")" -gt 0 ] || \
           [ "$(get_field "$state" "signalDownStreak" "0")" -gt 0 ]; then
            log "OK: Gateway recovered. Resetting counters."
        fi
        write_state "$DEFAULT_STATE"
        exit 0
        ;;

    channels_down)
        if [ "$details" = "signal" ]; then
            streak=$(get_field "$state" "signalDownStreak" "0")
            streak=$((streak + 1))
            state=$(set_field "$state" "signalDownStreak" "$streak")

            if [ "$streak" -lt "$SIGNAL_DOWN_THRESHOLD" ]; then
                write_state "$state"
                log "WARN: Signal down (streak $streak/$SIGNAL_DOWN_THRESHOLD). Waiting."
                exit 0
            fi

            if [ "$streak" -ge "$SIGNAL_MAX_RESTARTS" ]; then
                failures=$(get_field "$state" "consecutiveFailures" "0")
                failures=$((failures + 1))
                state=$(set_field "$state" "consecutiveFailures" "$failures")

                if [ "$failures" -ge "$MAX_FAILURES" ]; then
                    state=$(set_field "$state" "backoffUntil" "$((now + COOLDOWN_SECONDS))")
                    write_state "$state"
                    log "ERROR: Signal down $streak checks + max global failures ($MAX_FAILURES). Cooldown ${COOLDOWN_SECONDS}s."
                    exit 1
                fi
            fi

            log "WARN: Signal down $streak checks. Killing signal-cli + SIGUSR1."
            pkill -f signal-cli 2>/dev/null
            sleep 2
            kill -USR1 "$gateway_pid" 2>/dev/null
            state=$(set_field "$state" "lastRestartAt" "$now")
            write_state "$state"
            exit 0
        fi

        log "WARN: Channels down: $details"
        failures=$(get_field "$state" "consecutiveFailures" "0")
        failures=$((failures + 1))
        state=$(set_field "$state" "consecutiveFailures" "$failures")

        if [ "$failures" -ge "$MAX_FAILURES" ]; then
            state=$(set_field "$state" "backoffUntil" "$((now + COOLDOWN_SECONDS))")
            write_state "$state"
            log "ERROR: Max failures ($MAX_FAILURES). Cooldown ${COOLDOWN_SECONDS}s."
            exit 1
        fi

        log "Sending SIGUSR1 to PID $gateway_pid (attempt $failures/$MAX_FAILURES)..."
        kill -USR1 "$gateway_pid" 2>/dev/null
        state=$(set_field "$state" "lastRestartAt" "$now")
        write_state "$state"
        exit 0
        ;;

    unhealthy|parse_error|*)
        log "WARN: $status (details: $details)"
        failures=$(get_field "$state" "consecutiveFailures" "0")
        failures=$((failures + 1))
        state=$(set_field "$state" "consecutiveFailures" "$failures")

        if [ "$failures" -ge "$MAX_FAILURES" ]; then
            state=$(set_field "$state" "backoffUntil" "$((now + COOLDOWN_SECONDS))")
            write_state "$state"
            log "ERROR: Max failures ($MAX_FAILURES). Cooldown ${COOLDOWN_SECONDS}s."
            exit 1
        fi

        log "Sending SIGUSR1 to PID $gateway_pid (attempt $failures/$MAX_FAILURES)..."
        kill -USR1 "$gateway_pid" 2>/dev/null
        state=$(set_field "$state" "lastRestartAt" "$now")
        write_state "$state"
        exit 0
        ;;
esac
```

Make it executable:

```bash
chmod +x ~/.openclaw/scripts/watchdog.sh
```

## Step 2: Configure the Watchdog (Environment Variables)

The script is configured via environment variables with sensible defaults. Override any of these:

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENCLAW_CLI` | `openclaw` | Path to the OpenClaw CLI binary |
| `OPENCLAW_GATEWAY_PORT` | `18789` | Gateway HTTP port |
| `OPENCLAW_LAUNCHD_LABEL` | `com.openclaw.gateway` | macOS LaunchAgent label |
| `OPENCLAW_SYSTEMD_UNIT` | `openclaw-gateway.service` | Linux systemd unit name |
| `OPENCLAW_WATCHDOG_LOG` | `/tmp/openclaw/watchdog.log` | Log file location |

## Step 3: Install as a Scheduled Job

### macOS (LaunchAgent)

Create `~/Library/LaunchAgents/com.openclaw.watchdog.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.watchdog</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>WATCHDOG_PATH_PLACEHOLDER</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>StandardOutPath</key>
    <string>/tmp/openclaw/watchdog-launchd.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/openclaw/watchdog-launchd.err</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>HOME_PLACEHOLDER</string>
    </dict>
</dict>
</plist>
```

Replace `WATCHDOG_PATH_PLACEHOLDER` with the actual path to `watchdog.sh` and `HOME_PLACEHOLDER` with your home directory.

Load it:

```bash
launchctl load ~/Library/LaunchAgents/com.openclaw.watchdog.plist
```

### Linux (systemd timer)

Create `~/.config/systemd/user/openclaw-watchdog.service`:

```ini
[Unit]
Description=OpenClaw Gateway Watchdog

[Service]
Type=oneshot
ExecStart=/bin/bash %h/.openclaw/scripts/watchdog.sh
Environment=PATH=/usr/local/bin:/usr/bin:/bin
```

Create `~/.config/systemd/user/openclaw-watchdog.timer`:

```ini
[Unit]
Description=Run OpenClaw watchdog every 5 minutes

[Timer]
OnBootSec=120
OnUnitActiveSec=300

[Install]
WantedBy=timers.target
```

Enable:

```bash
systemctl --user daemon-reload
systemctl --user enable --now openclaw-watchdog.timer
```

## Step 4: Verify It Works

### Manual test

```bash
# Run the watchdog manually
bash ~/.openclaw/scripts/watchdog.sh

# Check the log
cat /tmp/openclaw/watchdog.log

# Check the state
cat /tmp/openclaw/watchdog-state.json
```

### Simulate a failure

```bash
# Temporarily block the health endpoint (watchdog will detect and SIGUSR1)
# Or just read the log after 15-20 minutes to see it checking in
tail -f /tmp/openclaw/watchdog.log
```

Expected log output when healthy:

```
[2026-03-25 16:00:00] OK: Gateway recovered. Resetting counters.
```

Expected when signal drops temporarily:

```
[2026-03-25 16:00:00] WARN: Signal down (streak 1/3). Waiting.
[2026-03-25 16:05:00] WARN: Signal down (streak 2/3). Waiting.
[2026-03-25 16:10:00] WARN: Signal down 3 checks. Killing signal-cli + SIGUSR1.
```

## Tuning Guide

| Scenario | What to change |
|----------|---------------|
| Gateway boots slowly (VPS, low RAM) | Increase `WARMUP_SECONDS` to 120-180 |
| Signal-cli is very flaky | Increase `SIGNAL_DOWN_THRESHOLD` to 5 |
| Want faster recovery | Decrease `StartInterval` to 120 (2 min) |
| Running on low-power device | Increase `StartInterval` to 600 (10 min) |
| No signal-cli (Telegram/WhatsApp only) | Signal handling is automatic; it only triggers for signal channel |
| Multiple channels are flaky | Lower `MAX_FAILURES` to 3, or increase `COOLDOWN_SECONDS` |

## How the Backoff State Machine Works

```
State: consecutiveFailures=0, backoffUntil=0
  → Failure detected
  → consecutiveFailures=1, SIGUSR1 sent
  → Next check (5 min): still failing
  → consecutiveFailures=2, SIGUSR1 sent
  → ... continues ...
  → consecutiveFailures=4 (MAX_FAILURES)
  → backoffUntil = now + 1800 (30 min cooldown)
  → All checks skip until cooldown expires
  → After cooldown: checks resume, failures reset if stale

Recovery at any point:
  → Healthy check detected
  → All counters reset to 0
```

## Uninstall

### macOS

```bash
launchctl bootout gui/$(id -u)/com.openclaw.watchdog
rm ~/Library/LaunchAgents/com.openclaw.watchdog.plist
rm ~/.openclaw/scripts/watchdog.sh
```

### Linux

```bash
systemctl --user disable --now openclaw-watchdog.timer
rm ~/.config/systemd/user/openclaw-watchdog.{service,timer}
systemctl --user daemon-reload
rm ~/.openclaw/scripts/watchdog.sh
```
