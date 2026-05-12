# Public skills repo hygiene

Use this when cleaning a skills repo that is public or intended to be shared.

## Default stance

Keep the library public and useful by default. Do not move a skill to private/internal just because it mentions a private project, a person's name, or a concrete example. First ask whether sanitizing the private details preserves the reusable workflow.

Move a skill out of the public bundle only when its value is inherently private and sanitization would gut the skill.

## Decision rule

Keep public and sanitize when the skill is mostly reusable:
- API workflows, CLI patterns, external service operations, generic debugging workflows
- Writing/editorial/voice skills where the user intentionally wants personal voice samples public
- Marketing, ASO, paid-ads, analytics, or creative production skills that can use placeholders for account-specific details

Move to ignored internal storage when the skill is mainly a private runbook:
- Private infra topology, deploy pipelines, local proxy routing, cron delivery, or incident runbooks
- Account-specific automations where removing app IDs, account IDs, private paths, or reporting destinations removes most value
- Skills tied to private repo internals, eval harnesses, prompt files, or operational workflows that outsiders cannot use

## Safe move pattern for a public repo

1. Work in a git worktree, not the main checkout.
2. Confirm `.gitignore` excludes `internal/` or the chosen private directory.
3. Move private skills into the ignored internal directory locally so the user keeps the runbooks.
4. Remove the tracked public copies from the PR.
5. Do not document ignored internal paths in public README/INSTALL files. That creates broken links and exposes private operational structure.
6. Update generated docs and install lists so they have no stale references to removed skills.
7. Validate:
   - Search repo docs for old paths and skill names.
   - Parse moved internal `SKILL.md` frontmatter locally.
   - Review the public diff for leaked private paths, account IDs, cron routes, secrets, app IDs, or operational snapshots.

## Naming

If a public skill had a generic name but is actually private-project-specific, rename it in internal storage to say what it really is. Example: `coding/optimize-prompt` became `internal/optimize-bloom-prompt` because it tuned Bloom's `CHAT_AGENT_PROMPT` using Bloom-specific eval runners.

## Redaction

Never preserve credentials, tokens, passwords, connection strings, private account IDs, private domains, app IDs, cron IDs, Render IDs, personal handles, or operational snapshots in public skills. Replace with placeholders or `[REDACTED]`.

## Cleanup patterns from real repo hygiene work

When auditing a public skills repo, classify each questionable skill into one of three outcomes:

| Outcome | Use when | Example pattern |
|---|---|---|
| Sanitize and keep public | The reusable workflow survives after replacing private nouns and IDs with placeholders | Finance research, earnings-card generation, external-service CLI usage, ad creative strategy |
| Move to ignored `internal/` | The skill is a private operational runbook and outsiders cannot use it without private infra/accounts | Private deploy runbooks, Sentry fix automation for one app, cron/reporting/ad-account operations, local runtime/proxy setup |
| Delete from public entirely | The skill creates security, platform-policy, or reputational risk and is not worth preserving as a public artifact | Jailbreak/obfuscation/"godmode" style tools |

Prefer class-level public skills over one-project aliases. If a public skill is useful but carries a private project name in filenames or examples, rename files and examples to generic terms (`click-to-whatsapp.md`, `$APP_NAME`, `$PROJECT_ROOT`, `$AD_ACCOUNT_ID`) rather than moving the whole skill.

For public editorial skills, personal voice samples and the author's name can be intentional fingerprints. Do not over-sanitize them unless the user asks. Remove unrelated private business identifiers, internal campaign names, private customer names, or operational IDs while preserving the voice and examples that make the skill work.

Watch for duplicate skill names after moving local internal copies. If a private/internal runbook collides with a public skill name, rename the internal copy to the actual private class of work, e.g. `assistant-runtime` instead of another `hermes-agent`.