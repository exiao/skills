---
name: claude-auth-remote-login
description: Remote Claude Code OAuth login flow when token expires
category: hermes-ops
---

# Claude Auth Remote Login Flow

## Problem
Claude Code OAuth token expires and `claude auth status` falsely reports logged in. `claude -p "ping"` does NOT auto-refresh — returns 401.

## Remote Login Steps
1. SSH into machine
2. Run: `claude auth login --email <your-email>`
3. Copy the printed OAuth URL
4. Open URL in local browser, complete login
5. Browser lands on `platform.claude.com/oauth/code/callback?code=...&state=...`
6. Page shows "Authentication Code" — paste code back into the live SSH claude session
7. Verify: `claude auth status` and `curl http://127.0.0.1:18801/health`

## Key Details
- Keychain item: `Claude Code-credentials` in login.keychain-db
- The code is tied to the specific `state` param — if CLI session dies, code is useless
- Signal mangles URLs with underscores — send URL as .txt file attachment instead
- Proxy on port 18801 translates OAuth token for Anthropic API access

## After Login Succeeds
- Check: `curl http://127.0.0.1:18801/health` — should NOT show token_expired
- Run refresh watchdog: `bash ~/.hermes/watchdog/billing_proxy_refresh_watchdog.sh` — should exit 0

## Status as of 2026-04-15
- Auth login was in progress but not yet completed when session ended
- Branch `fix/proxy-watchdog-stale-pid` has watchdog fixes staged but no PR opened
