#!/usr/bin/env bash
# sentry.sh — thin curl wrapper over the Sentry REST API.
# Covers the debug loop: list/search issues, inspect events, check release
# distribution, resolve/assign, and run Seer root-cause analysis.
#
# Auth: reads SENTRY_AUTH_TOKEN from env.
# Org:  reads SENTRY_ORG from env (required for any /organizations/ call).
# Output: pretty-printed JSON via jq by default. Use --json for raw.

set -euo pipefail

: "${SENTRY_AUTH_TOKEN:?SENTRY_AUTH_TOKEN not set — export a Sentry auth token (https://sentry.io/settings/account/api/auth-tokens/)}"
: "${SENTRY_ORG:?SENTRY_ORG not set — export your Sentry org slug}"

API="https://sentry.io/api/0"
AUTH=(-H "Authorization: Bearer $SENTRY_AUTH_TOKEN")

# ── helpers ────────────────────────────────────────────────────────────
RAW_JSON=0
for arg in "$@"; do
    [[ "$arg" == "--json" ]] && RAW_JSON=1
done

_emit() {
    # Read stdin, emit raw JSON if --json, otherwise pretty via jq.
    if [[ $RAW_JSON -eq 1 ]] || ! command -v jq >/dev/null 2>&1; then
        cat
    else
        jq "${1:-.}"
    fi
}

_call() {
    # _call METHOD PATH [curl-args...]
    local method="$1" path="$2"; shift 2
    curl -sS -X "$method" "${AUTH[@]}" "$@" "$API$path"
}

# Resolve shortId (e.g. MY-PROJECT-42) → numeric ID. Numeric passes through.
_resolve_issue_id() {
    local ref="$1"
    if [[ "$ref" =~ ^[0-9]+$ ]]; then
        echo "$ref"; return
    fi
    # Dedicated shortids endpoint — single hop, unambiguous.
    local id
    id=$(_call GET "/organizations/$SENTRY_ORG/shortids/$ref/" \
            | jq -r '.group.id // empty')
    if [[ -z "$id" ]]; then
        echo "issue not found: $ref" >&2; exit 1
    fi
    echo "$id"
}

_flag_val() {
    # _flag_val --limit "$@"  → echoes value or empty
    local want="$1"; shift
    local prev=""
    for a in "$@"; do
        [[ "$prev" == "$want" ]] && { echo "$a"; return; }
        prev="$a"
    done
}

# ── subcommands ────────────────────────────────────────────────────────
cmd_issues_list() {
    local query="${1:-is:unresolved}"
    local limit; limit="$(_flag_val --limit "$@")"; limit="${limit:-25}"
    local sort; sort="$(_flag_val --sort "$@")"; sort="${sort:-date}"
    _call GET "/organizations/$SENTRY_ORG/issues/" \
        --get \
        --data-urlencode "query=$query" \
        --data-urlencode "limit=$limit" \
        --data-urlencode "sort=$sort" \
        | _emit '[.[] | {shortId, title, count, userCount, project: .project.slug, lastSeen, status}]'
}

cmd_issues_get() {
    local ref="${1:?usage: issues get <shortId|id>}"
    local id; id="$(_resolve_issue_id "$ref")"
    _call GET "/organizations/$SENTRY_ORG/issues/$id/" \
        | _emit '{shortId, title, culprit, count, userCount, firstSeen, lastSeen, status, assignedTo: (.assignedTo.email // .assignedTo // null), project: .project.slug, permalink, metadata}'
}

cmd_issues_events() {
    local ref="${1:?usage: issues events <shortId|id> [--latest] [--limit N]}"
    local id; id="$(_resolve_issue_id "$ref")"
    local latest=0; for a in "$@"; do [[ "$a" == "--latest" ]] && latest=1; done
    if [[ $latest -eq 1 ]]; then
        # /issues/{id}/events/latest/ returns one event with full stacktrace.
        # Event shape varies: exception-type has .entries[].data.values[].stacktrace,
        # message-type just has a message + breadcrumbs. Handle both.
        # jq gotcha: `a // b` where b is an empty generator produces an empty stream,
        # which kills the whole object construction. Always reduce tag lookups to an
        # array first: `([gen] | first // null)`.
        _call GET "/organizations/$SENTRY_ORG/issues/$id/events/latest/" \
            | _emit '{
                eventID,
                dateCreated,
                message,
                culprit,
                type: ."event.type",
                release: (.release.version // ([.tags[]? | select(.key=="release") | .value] | first) // null),
                environment: ([.tags[]? | select(.key=="environment") | .value] | first // null),
                tags: [.tags[]? | select(.key as $k | ["release","environment","os","os.name","browser","browser.name","device","device.family","url","user","transaction","server_name"] | index($k)) | {key, value}],
                exception: [.entries[]? | select(.type=="exception") | .data.values[]? | {type, value, module, frames: [.stacktrace.frames[]? | {function, filename, lineno: .lineNo, colno: .colNo, inApp}]}],
                breadcrumbs: [.entries[]? | select(.type=="breadcrumbs") | .data.values[-5:][]? | {timestamp, category, message, level}]
            }'
    else
        local limit; limit="$(_flag_val --limit "$@")"; limit="${limit:-5}"
        _call GET "/organizations/$SENTRY_ORG/issues/$id/events/?limit=$limit" \
            | _emit '[.[] | {eventID, dateCreated, message, tags: [.tags[]? | select(.key=="release" or .key=="environment") | {key, value}]}]'
    fi
}

cmd_issues_tags() {
    local ref="${1:?usage: issues tags <shortId|id> <key>}"
    local key="${2:?missing tag key (e.g. release, environment, os)}"
    local id; id="$(_resolve_issue_id "$ref")"
    _call GET "/organizations/$SENTRY_ORG/issues/$id/tags/$key/values/" \
        | _emit '[.[] | {value, count, lastSeen, firstSeen}]'
}

cmd_issues_resolve() {
    local ref="${1:?usage: issues resolve <shortId|id>}"
    local id; id="$(_resolve_issue_id "$ref")"
    _call PUT "/organizations/$SENTRY_ORG/issues/$id/" \
        -H "Content-Type: application/json" \
        -d '{"status":"resolved"}' \
        | _emit '{shortId, status, statusDetails}'
}

cmd_issues_unresolve() {
    local ref="${1:?usage: issues unresolve <shortId|id>}"
    local id; id="$(_resolve_issue_id "$ref")"
    _call PUT "/organizations/$SENTRY_ORG/issues/$id/" \
        -H "Content-Type: application/json" \
        -d '{"status":"unresolved"}' \
        | _emit '{shortId, status}'
}

cmd_issues_ignore() {
    local ref="${1:?usage: issues ignore <shortId|id>}"
    local id; id="$(_resolve_issue_id "$ref")"
    _call PUT "/organizations/$SENTRY_ORG/issues/$id/" \
        -H "Content-Type: application/json" \
        -d '{"status":"ignored"}' \
        | _emit '{shortId, status}'
}

cmd_issues_assign() {
    local ref="${1:?usage: issues assign <shortId|id> <username-or-email>}"
    local who="${2:?missing assignee}"
    local id; id="$(_resolve_issue_id "$ref")"
    _call PUT "/organizations/$SENTRY_ORG/issues/$id/" \
        -H "Content-Type: application/json" \
        -d "{\"assignedTo\":\"$who\"}" \
        | _emit '{shortId, status, assignedTo: (.assignedTo.email // .assignedTo)}'
}

cmd_projects_list() {
    _call GET "/organizations/$SENTRY_ORG/projects/" \
        | _emit '[.[] | {slug, platform, teams: [.teams[].slug], firstEvent, dateCreated}]'
}

cmd_releases_list() {
    local project_slug; project_slug="$(_flag_val --project "$@")"
    local limit; limit="$(_flag_val --limit "$@")"; limit="${limit:-10}"
    local path="/organizations/$SENTRY_ORG/releases/?per_page=$limit"
    if [[ -n "$project_slug" ]]; then
        # Sentry's releases endpoint requires numeric project ID, not slug.
        local pid
        pid=$(_call GET "/organizations/$SENTRY_ORG/projects/" \
                | jq -r --arg slug "$project_slug" '.[] | select(.slug==$slug) | .id')
        if [[ -z "$pid" ]]; then
            echo "project not found: $project_slug" >&2; exit 1
        fi
        path+="&project=$pid"
    fi
    _call GET "$path" \
        | _emit '[.[] | {version, dateCreated, newGroups, projects: [.projects[].slug]}]'
}

cmd_events_list() {
    # Discover-style query across events
    local query; query="$(_flag_val --query "$@")"; query="${query:-}"
    local stats; stats="$(_flag_val --stats-period "$@")"; stats="${stats:-24h}"
    local limit; limit="$(_flag_val --limit "$@")"; limit="${limit:-25}"
    _call GET "/organizations/$SENTRY_ORG/events/" \
        --get \
        --data-urlencode "field=title" \
        --data-urlencode "field=project" \
        --data-urlencode "field=timestamp" \
        --data-urlencode "field=id" \
        --data-urlencode "query=$query" \
        --data-urlencode "statsPeriod=$stats" \
        --data-urlencode "per_page=$limit" \
        | _emit '.data'
}

cmd_trace() {
    local trace_id="${1:?usage: trace <trace_id>}"
    _call GET "/organizations/$SENTRY_ORG/trace/$trace_id/" | _emit '.'
}

cmd_autofix() {
    local ref="${1:?usage: autofix <shortId|id> [--status]}"
    local id; id="$(_resolve_issue_id "$ref")"
    local status=0; for a in "$@"; do [[ "$a" == "--status" ]] && status=1; done
    if [[ $status -eq 1 ]]; then
        _call GET "/organizations/$SENTRY_ORG/issues/$id/autofix/" | _emit '.'
    else
        _call POST "/organizations/$SENTRY_ORG/issues/$id/autofix/" \
            -H "Content-Type: application/json" -d '{}' \
            | _emit '.'
    fi
}

cmd_orgs_list() {
    _call GET "/organizations/" | _emit '[.[] | {slug, name, dateCreated}]'
}

cmd_whoami() {
    _call GET "/" | _emit "{user: .user.email, scopes: .auth.scopes, org_default: \"$SENTRY_ORG\"}"
}

usage() {
    cat <<'USAGE'
sentry.sh — Sentry REST API wrapper

Issues:
  issues list [QUERY] [--limit N] [--sort date|freq|new|user] [--json]
  issues get <shortId|id> [--json]
  issues events <shortId|id> [--latest] [--limit N] [--json]
  issues tags <shortId|id> <tag-key>    # e.g. release, environment, os
  issues resolve <shortId|id>
  issues unresolve <shortId|id>
  issues ignore <shortId|id>
  issues assign <shortId|id> <username-or-email>

Discovery:
  events list [--query Q] [--stats-period 24h] [--limit N]
  trace <trace_id>

Admin:
  projects list
  releases list [--project SLUG] [--limit N]
  orgs list
  whoami

Seer (AI root-cause):
  autofix <shortId|id>            # kick off analysis
  autofix <shortId|id> --status   # poll latest run

Env:
  SENTRY_AUTH_TOKEN  (required)
  SENTRY_ORG         (required — your org slug)

Add --json to any command for raw output.
USAGE
}

# ── dispatch ───────────────────────────────────────────────────────────
case "${1:-}" in
    issues)
        shift
        sub="${1:-}"; shift || true
        case "$sub" in
            list) cmd_issues_list "$@" ;;
            get) cmd_issues_get "$@" ;;
            events) cmd_issues_events "$@" ;;
            tags) cmd_issues_tags "$@" ;;
            resolve) cmd_issues_resolve "$@" ;;
            unresolve) cmd_issues_unresolve "$@" ;;
            ignore) cmd_issues_ignore "$@" ;;
            assign) cmd_issues_assign "$@" ;;
            *) echo "unknown: issues $sub" >&2; usage; exit 1 ;;
        esac
        ;;
    events)
        shift
        case "${1:-}" in
            list) shift; cmd_events_list "$@" ;;
            *) echo "unknown: events ${1:-}" >&2; usage; exit 1 ;;
        esac
        ;;
    projects)
        shift
        case "${1:-}" in
            list) cmd_projects_list ;;
            *) echo "unknown: projects ${1:-}" >&2; usage; exit 1 ;;
        esac
        ;;
    releases)
        shift
        case "${1:-}" in
            list) shift; cmd_releases_list "$@" ;;
            *) echo "unknown: releases ${1:-}" >&2; usage; exit 1 ;;
        esac
        ;;
    orgs)
        shift
        case "${1:-}" in
            list) cmd_orgs_list ;;
            *) echo "unknown: orgs ${1:-}" >&2; usage; exit 1 ;;
        esac
        ;;
    trace) shift; cmd_trace "$@" ;;
    autofix) shift; cmd_autofix "$@" ;;
    whoami) cmd_whoami ;;
    -h|--help|help|"") usage ;;
    *) echo "unknown command: $1" >&2; usage; exit 1 ;;
esac
