# Sentry REST Endpoints (used by sentry.sh)

All paths relative to `https://sentry.io/api/0`. Auth: `Authorization: Bearer $SENTRY_AUTH_TOKEN`.

## Discovery

| Method | Path | Used by |
|--------|------|---------|
| GET | `/organizations/` | `orgs list` |
| GET | `/` | `whoami` — returns user + token scopes |
| GET | `/organizations/{org}/projects/` | `projects list` |
| GET | `/organizations/{org}/releases/?project={numeric_id}&per_page=N` | `releases list` — script resolves `--project <slug>` to numeric ID |

## Issues

| Method | Path | Used by |
|--------|------|---------|
| GET | `/organizations/{org}/issues/?query=Q&limit=N&sort=S` | `issues list` |
| GET | `/organizations/{org}/issues/{id}/` | `issues get` |
| PUT | `/organizations/{org}/issues/{id}/` body `{status, assignedTo}` | `issues resolve/unresolve/ignore/assign` |
| GET | `/organizations/{org}/issues/{id}/events/` | `issues events` |
| GET | `/organizations/{org}/issues/{id}/events/latest/` | `issues events --latest` |
| GET | `/organizations/{org}/issues/{id}/tags/{key}/values/` | `issues tags` |
| GET | `/organizations/{org}/shortids/{shortId}/` | shortId → numeric id resolution |

Tag keys commonly useful: `release`, `environment`, `os`, `browser`, `device`, `url`, `user.email`.

## Events & traces

| Method | Path | Used by |
|--------|------|---------|
| GET | `/organizations/{org}/events/?field=...&query=Q&statsPeriod=P` | `events list` (Discover) |
| GET | `/organizations/{org}/trace/{trace_id}/` | `trace` |
| GET | `/organizations/{org}/profiling/profiles/{id}/` | (not yet wrapped — call directly if needed) |

## Seer (AI root-cause)

| Method | Path | Notes |
|--------|------|-------|
| POST | `/organizations/{org}/issues/{id}/autofix/` body `{}` | Kicks off a Seer run. Returns run ID. |
| GET | `/organizations/{org}/issues/{id}/autofix/` | Polls latest run state. |

## Gotchas

- **shortId vs numeric ID.** Most endpoints need the numeric `id` (e.g. `7311602652`). `sentry.sh` auto-resolves shortIds via the dedicated `/organizations/{org}/shortids/{shortId}/` endpoint. Costs one extra call per command when you use a shortId.
- **URL encoding.** The `query` param contains `:` and spaces — the script uses `curl --data-urlencode` which handles this. If you hit the API directly, encode it yourself.
- **Event shape varies.** Exception events have `.entries[].data.values[].stacktrace.frames`; message events just have `.message` + breadcrumbs. The `issues events --latest` jq handles both.
- **Stacktrace frame keys are camelCase.** `lineNo`, `colNo`, `inApp` — not `line_no`/`col_no`. The script normalizes to `lineno`/`colno` in output.
- **jq empty-stream trap.** `a // b` where `b` is an empty generator produces an empty stream and kills the enclosing object. Always collect tag lookups into an array first: `([gen] | first // null)`.
- **Releases endpoint wants numeric project ID**, not slug. The script resolves `--project <slug>` via a projects lookup first.
- **Autofix returns immediately.** POST starts the run, GET polls. Seer analysis typically takes 30s–3min. If your org lacks Seer budget, the response is `"No budget for Seer Autofix."`
- **Discover events endpoint** (`/events/`) requires `field=` params — the response shape is `{data: [...], meta: {...}}` not a flat array.
- **Tag values endpoint** returns counts scoped to one issue, not global.

## If `sentry.sh` is missing something

Drop to raw curl:
```bash
curl -sS -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/{id}/stats/" | jq .
```
Other useful endpoints not currently wrapped:
- `/issues/{id}/hashes/` — fingerprint hashes
- `/issues/{id}/stats/` — time-series event counts
- `/organizations/{org}/stats_v2/` — org-level event throughput
- `/organizations/{org}/eventsv2/` — older Discover
- `/projects/{org}/{project}/events/{event_id}/` — single event by ID
