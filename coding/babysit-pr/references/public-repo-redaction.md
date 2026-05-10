# Public Repo Redaction Pattern

When CI reviewers flag hardcoded values in a public skills repo (domains, emails, account IDs, usernames), follow this workflow:

## 1. Scan for ALL instances

Don't fix one at a time. Grep the full diff for all occurrences:

```bash
grep -rn "HARDCODED_VALUE" --include="*.md" . 2>/dev/null | grep -v node_modules | grep -v ".git/"
```

Common patterns to scan for:
- Product/company domains (`$APP_DOMAIN`, `$API_DOMAIN`)
- Email addresses (`admin@example.com`)
- Account/set IDs (`$TYPEFULLY_SOCIAL_SET_ID`, `$META_AD_ACCOUNT_ID`, `act_XXXXXXXXX`)
- Cron job UUIDs (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` for real scheduled routines)
- Deployment hostnames (`*.up.railway.app`, `*.onrender.com`) and Render service IDs (`srv-...`)
- API URLs (`https://api.example.com/path`)
- Frontmatter fields that leak people (`author: <personal-handle>`, personal names)
- Real social media handles, tweet URLs, quoted personal announcements, and engagement/revenue figures tied to identifiable accounts
- Product-specific search queries or app IDs in examples (`$APP_SEARCH_QUERY`, `$APP_ID`)
- Workspace/org names in SaaS URLs (Linear, Render, Sentry, GitHub orgs) and env var names (`RENDER_API_KEY_<WORKSPACE>`)
- Substack/newsletter URLs

## 2. Replace with env var placeholders

Use consistent naming:
- `$APP_DOMAIN` for the main product domain
- `$API_DOMAIN` for API subdomains
- `$APP_SEARCH_QUERY` for product-specific query examples
- `$APP_ID` / `$PACKAGE_NAME` for app store identifiers
- `$RAILWAY_PUBLIC_DOMAIN` for Railway deployment hostnames
- `$RENDER_SERVICE_ID` for Render service IDs
- `$RENDER_API_KEY_<WORKSPACE>` for workspace-specific Render tokens. In public repos, use generic placeholders like `$RENDER_API_KEY_APP1`, not real workspace names
- `$META_ADS_LOGIN` for ad platform credentials
- `$META_AD_ACCOUNT_ID` for Meta ad account IDs
- `$SUBSTACK_URL` for newsletter URLs
- `$TYPEFULLY_SOCIAL_SET_ID` for Typefully account IDs
- `$TYPEFULLY_USERNAME` for social handles
- `$SENTRY_ORG` / `$SENTRY_PROJECT` for Sentry slugs
- `$LINEAR_WORKSPACE` / placeholder Linear URLs for Linear orgs and document slugs
- `$CRON_JOB_ID` for generic cron/routine IDs in public docs

If multiple real cron IDs are replaced with the generic `$CRON_JOB_ID`, preserve the private mapping in `~/.hermes/.env` with specific aliases (`MARKET_DAILY_BRIEFING_CRON_JOB_ID=...`, `META_ADS_CRON_JOB_ID=...`) so the operational values are not lost.

Use `sed -i ''` for bulk replacement across multiple files:
```bash
sed -i '' 's|hardcoded.domain.com|$APP_DOMAIN|g' file1.md file2.md file3.md
```

## 3. Add actual values to ~/.hermes/.env

After stripping values from the repo, add them to the private env file so skills can still resolve them at runtime:

```bash
cat >> ~/.hermes/.env << 'EOF'
APP_DOMAIN=example.com
BLOOM_API_DOMAIN=api.example.com
EOF
```

## 4. Re-scan after fixing

Always run the grep again after replacing to catch stragglers:
```bash
grep -rn "old_value" --include="*.md" . 2>/dev/null | grep -v node_modules | grep -v ".git/"
```

## 5. Public skills repo checklist

For PRs against the public `exiao/skills` repo, redaction is only half the job. Also verify repository packaging rules before reporting ready:

- Read `CLAUDE.md` first. It requires the root `README.md` directory/skill index to stay current.
- Skill folders should not contain their own `README.md`; put usage details in `SKILL.md` or `references/`.
- Keep standard skill frontmatter portable and non-personal. Avoid personal names, real company/product names, hardcoded domains, and private workspace slugs.
- Delete session-specific snapshots or proprietary business documents from the PR, not just redact them. Examples: analytics JSON snapshots, private onboarding flows, revenue/engagement exports, internal strategy docs.
- If two skills duplicate the same class, keep the broader/canonical location and remove the duplicate to avoid routing collisions.
- Prefer shell-style placeholders in examples (`$APP_NAME`, `$APP_DOMAIN`, `$GSC_SERVICE_ACCOUNT_EMAIL`, `$CLIPIFY_DIR`) so future agents know values must be supplied at runtime.

## 6. Resolve review threads in bulk

After pushing the fix, resolve all related threads in one shell loop. See `delegation-and-git-pitfalls.md` for the batch pattern.
