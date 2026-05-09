# Cron safety notes for fix-sentry-issues

Session learning from 2026-05-08: the `fix-sentry-issues` cron failed before execution because the cron injection scanner flagged a loaded skill's documentation, not the task prompt.

## Symptom

Cron run is blocked with a threat-pattern finding such as `exfil_curl` before the Sentry workflow starts.

## Root cause

A loaded supporting skill included example commands like `curl` with `Authorization` headers. The scanner inspects loaded skill context, so harmless docs can poison the cron run.

## Fix

Keep the cron's attached skills narrow:
- include `fix-sentry-issues`
- include `sentry-debug`
- avoid broad GitHub workflow skills if they document raw `curl` commands with auth headers

Keep toolsets minimal for this cron: `terminal,file,web,skills`.

## Verification

After editing the cron config, run or dry-run the cron and confirm it reaches the first Sentry issue fetch rather than stopping during prompt/security validation.
