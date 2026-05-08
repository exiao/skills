# Public Repo Redaction Pattern

When CI reviewers flag hardcoded values in a public skills repo (domains, emails, account IDs, usernames), follow this workflow:

## 1. Scan for ALL instances

Don't fix one at a time. Grep the full diff for all occurrences:

```bash
grep -rn "HARDCODED_VALUE" --include="*.md" . 2>/dev/null | grep -v node_modules | grep -v ".git/"
```

Common patterns to scan for:
- Domain names (example.com, api.example.com)
- Email addresses (admin@domain.com)
- Account/set IDs (286685, act_725955967809454)
- Cron job UUIDs (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` for real scheduled routines)
- Deployment hostnames (`*.up.railway.app`, `*.onrender.com`) and Render service IDs (`srv-...`)
- API URLs (https://api.domain.com/path/)
- Social media handles (@username)
- Substack/newsletter URLs

## 2. Replace with env var placeholders

Use consistent naming:
- `$APP_DOMAIN` for the main product domain
- `$BLOOM_API_DOMAIN` for API subdomain
- `$BLOOM_MCP_URL` for full MCP endpoint URL
- `$RAILWAY_PUBLIC_DOMAIN` for Railway deployment hostnames
- `$RENDER_SERVICE_ID` for Render service IDs
- `$META_ADS_LOGIN` for ad platform credentials
- `$SUBSTACK_URL` for newsletter URLs
- `$TYPEFULLY_SOCIAL_SET_ID` for Typefully account IDs
- `$TYPEFULLY_USERNAME` for social handles
- `$SENTRY_ORG` for Sentry org slugs
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

## 5. Resolve review threads in bulk

After pushing the fix, resolve all related threads in one shell loop. See `delegation-and-git-pitfalls.md` for the batch pattern.