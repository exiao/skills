# Sentry Query Syntax

Full reference: https://docs.sentry.io/concepts/search/searchable-properties/

## Structure

`key:value key:value ...` — space-separated terms are AND.
Quote values with spaces: `message:"worker timeout"`.
Negate with `!`: `!environment:dev`.
Ranges: `count:>100`, `times_seen:>=50`.

## Status & assignment

| Query | Meaning |
|-------|---------|
| `is:unresolved` | Open |
| `is:resolved` | Closed |
| `is:ignored` | Archived |
| `is:assigned` / `is:unassigned` | Assignment state |
| `assigned:me` | Mine |
| `assigned:username` | Someone specific |
| `assigned_or_suggested:me` | Mine or routed to me |

## Scope

| Query | Meaning |
|-------|---------|
| `project:<slug>` | Single project (slug) |
| `project:[a,b,c]` | Multiple projects |
| `environment:production` | Env filter |
| `release:1.0.0` | Specific release |
| `release:latest` | Current release |

## Time

| Query | Meaning |
|-------|---------|
| `firstSeen:-24h` | First occurred in last 24h |
| `lastSeen:-1h` | Last occurred in last hour |
| `age:-7d` | Issue age less than 7 days |
| `timesSeen:>100` | Seen more than 100 times |

Units: `m`, `h`, `d`, `w`. Absolute dates also work: `firstSeen:>=2026-04-01`.

## Error content

| Query | Meaning |
|-------|---------|
| `error.type:TypeError` | By exception class |
| `error.value:"*undefined*"` | Exception message (wildcards with `*`) |
| `error.handled:false` | Unhandled only |
| `has:stack` | Has a stacktrace |
| `message:"fetch failed"` | Substring match on event message |
| `culprit:"app/checkout"` | Culprit (function/location) match |

## User impact

| Query | Meaning |
|-------|---------|
| `user.email:user@example.com` | Specific user hit |
| `user.id:12345` | By user id |
| `users_affected:>100` | Impact threshold |

## Device / browser / OS

| Query | Meaning |
|-------|---------|
| `os.name:iOS` | Platform |
| `browser.name:Chrome` | Browser |
| `device.family:iPhone` | Device |

## Transactions / performance

| Query | Meaning |
|-------|---------|
| `transaction:/api/checkout` | Transaction name |
| `transaction.duration:>1000` | Slow transactions (ms) |
| `transaction.op:http.server` | By span op |

## Sort options (`--sort`)

| Value | Meaning |
|-------|---------|
| `date` | Last seen (default) |
| `new` | First seen (newest) |
| `freq` | Event count |
| `user` | Users affected |
| `priority` | Sentry's priority score |

## Good starter queries

- **"What broke today?"** → `is:unresolved firstSeen:-24h`
- **"New crashes on current release?"** → `is:unresolved release:latest firstSeen:-24h`
- **"Loud but handled?"** → `error.handled:true timesSeen:>1000`
- **"Regressions?"** → `is:regressed` (issues that reopened)
