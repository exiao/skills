---
name: openclaw-docker-debug
description: Debug OpenClaw issues when deployed via Docker Compose. Covers finding containers, reading logs, health checks, config inspection, and diagnosing channel crash loops. Use when OpenClaw is running in Docker and something is wrong (channels down, crashes, auth issues).
---

# OpenClaw Docker Debugging

## Overview

OpenClaw is often deployed via the Hostinger VPS image (ghcr.io/hostinger/hvps-openclaw:latest) which runs the gateway, Redis, monitoring, and a health proxy as Docker containers. When channels crash or disconnect, the debugging approach is different from bare-metal installs.

## Common Symptoms

- Channel repeatedly stopping and restarting (crash loop)
- Health monitor hitting restart limits and skipping recovery
- No error logs visible at first glance
- CLI not available on the host machine

## Step 1: Identify the Deployment

Check if OpenClaw is running in Docker:

```bash
docker ps | grep openclaw
```

Typical containers:
- `bloombot-gateway` — the main OpenClaw gateway
- `bloombot-redis` — Redis for state/cache
- `bloombot-monitor` — Uptime Kuma monitoring
- `bloombot-autoheal` — Docker container autohealer
- `bloombot-healthproxy` — Nginx health proxy

## Step 2: Check Gateway Logs

```bash
# Recent logs with error filtering
docker logs bloombot-gateway --tail 200 2>&1 | grep -iE 'error|fail|whatsapp|signal|telegram|disconnect|crash|auth|qr|scan' | tail -40

# Full recent logs
docker logs bloombot-gateway --tail 500 2>&1
```

Look for:
- `[health-monitor] [channel:instance] health-monitor: restarting (reason: stopped)` — channel crash loop
- `[health-monitor] [...]: hit 3 restarts/hour limit, skipping` — recovery throttled
- `webchat disconnected code=1005` — WebSocket disconnects
- Authentication/connection errors specific to each channel

## Step 3: Health Check via Container

```bash
# Try the gateway's HTTP health endpoint
docker exec bloombot-gateway curl -s http://127.0.0.1:3000/health 2>/dev/null

# Check what ports the gateway is listening on
docker exec bloombot-gateway ss -tlnp 2>/dev/null || netstat -tlnp
```

Note: Port 3000 might serve the dashboard UI, not the health API. The actual CLI health endpoint may not be reachable via HTTP in Docker deployments.

## Step 4: Inspect Config

The config lives at `/data/.openclaw/openclaw.json` inside the gateway container:

```bash
docker exec bloombot-gateway cat /data/.openclaw/openclaw.json
```

Check these key sections:
- `channels.whatsapp` / `channels.telegram` / `channels.signal` — channel configs
- `env` — API keys and secrets (look for `WHATSAPP_SECRET`, `TELEGRAM_BOT_TOKEN`, etc.)
- `plugins.entries` — plugin enable/disable status
- `gateway.channelMaxRestartsPerHour` — restart throttle limit (default: 3)

## Step 5: Diagnose Channel Crash Loops

When a channel keeps stopping with no specific error:

1. **Check if it's an auth/credential issue** — verify secrets in `env` section are still valid
2. **Check for rate limiting** — WhatsApp/Telegram may block connections after too many rapid restarts
3. **Check dependency health** — WhatsApp needs `wacli` binary, Signal needs `signal-cli`
4. **Check network access** — container may not be able to reach channel APIs

### Quick restart commands:

```bash
# Restart just the gateway container
docker restart bloombot-gateway

# Or restart the whole stack
docker compose -f /data/docker-compose.yml down && docker compose -f /data/docker-compose.yml up -d
```

## Step 6: Use OpenClaw Docker CLI

The OpenClaw CLI may be available inside the container:

```bash
docker exec bloombot-gateway openclaw status
docker exec bloombot-gateway openclaw health --json
docker exec bloombot-gateway openclaw doctor
```

If `openclaw` is not on PATH, find it:

```bash
docker exec bloombot-gateway find / -name 'openclaw' -type f 2>/dev/null | head -5
docker exec bloombot-gateway echo $PATH
```

## Pitfalls

- **Port 3000 is the dashboard UI, not the health API** — curling `/health` on port 3000 returns an HTML page (Vite app), not JSON health data
- **Container PATH differences** — the gateway runs as `node` user, not root; PATH may differ from host
- **Config path** — inside the container, config is at `/data/.openclaw/openclaw.json`, not `~/.openclaw/openclaw.json`
- **Restart limits** — `gateway.channelMaxRestartsPerHour` (default 3) prevents rapid restart thundering herds. If a channel keeps crashing, you must fix the root cause OR increase this limit temporarily
- **Autoheal container** — the `autoheal` container may auto-restart unhealthy containers, masking issues
- **Docker volume paths** — the `/data/.openclaw/` directory on the HOST is mounted into the container

## Troubleshooting Matrix

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Channel stops with "stopped" reason, no error | Auth expired, library crash, or upstream disconnect | Verify credentials in `env`, check for WhatsApp/Telegram API changes |
| "hit 3 restarts/hour limit" | Consecutive crashes exceeded throttle | Fix root cause, then `docker restart` the gateway to reset the counter |
| WebSocket disconnect 1005 | Client-side disconnect or server restart | Usually transient, check if gateway restarted |
| `openclaw` command not found in container | CLI not on node process PATH | Find the entrypoint script or install path; use `docker exec` with full path |
| No logs at all | Log driver issue or container just started | Check `docker logs --since 1h`; verify container isn't in restart backoff |
