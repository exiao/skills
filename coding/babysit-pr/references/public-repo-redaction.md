# Public Repo Redaction Pattern

When CI reviewers flag hardcoded values in a public skills repo (domains, emails, account IDs, usernames), follow this workflow:

## 1. Scan for ALL instances

Don't fix one at a time. Grep the full diff for all occurrences:

```bash
grep -rn "HARDCODED_VALUE" --include="*.md" . 2>/dev/null | grep -v node_modules | grep -v ".git/"
```

Common patterns to scan for:
- Domain names (example.com, api.example.com)
- Email addresses (admin@domain.com, socials@domain.com)
- Account/set IDs (`ACCOUNT_ID`, `act_<META_AD_ACCOUNT_ID>`)
- Phone numbers (`+1XXXXXXXXXX`)
- Cron job UUIDs (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` for real scheduled routines)
- Deployment hostnames (`*.up.railway.app`, `*.onrender.com`) and Render service IDs (`srv-...`), env group IDs (`evg-...`), and workspace-specific API key names (`$RENDER_API_KEY_<WORKSPACE>`)
- API URLs (https://api.domain.com/path/)
- Social media handles (@username)
- Substack/newsletter URLs and private publication subdomains
- RevenueCat project, product, entitlement, and offering IDs (`proj...`, `prod...`, `ofrng...`) plus live subscription prices
- Live App Store ASO metadata: title, subtitle, keyword field, competitor-sensitive copy
- Private chat/group codes from messaging platforms
- Private key filenames (`PRIVATE_KEY_FILENAME.p8`)
- Connection IDs from third-party services (long alphanumeric strings like `CONNECTION_ID_PLACEHOLDER`)
- Personal names in bylines, ownership examples, or action instructions (prefer "the account owner")
- Password location hints ("password in path/to/file")

## 2. Replace with env var placeholders

Use consistent naming:
- `$APP_DOMAIN` for the main product domain
- `$BLOOM_API_DOMAIN` for API subdomain
- `$BLOOM_MCP_URL` for full MCP endpoint URL
- `$RAILWAY_PUBLIC_DOMAIN` for Railway deployment hostnames
- `$RENDER_SERVICE_ID` for Render service IDs
- `$META_ADS_LOGIN` for ad platform credentials
- `$SUBSTACK_URL` for newsletter URLs
- `$REVENUECAT_PROJECT_ID`, `$REVENUECAT_PRODUCT_ID`, `$REVENUECAT_OFFERING_ID`, `$REVENUECAT_ENTITLEMENT_ID` for RevenueCat identifiers
- `$SUBSCRIPTION_YEARLY_PRICE`, `$SUBSCRIPTION_WEEKLY_PRICE` for live pricing examples that should not be public
- `$APP_STORE_TITLE`, `$APP_STORE_SUBTITLE`, `$APP_STORE_KEYWORDS` for live ASO metadata
- `$TYPEFULLY_SOCIAL_SET_ID` for Typefully account IDs
- `$TYPEFULLY_USERNAME` for social handles
- `$YUANBAO_GROUP_CODE` or `$CHAT_GROUP_CODE` for private group/chat IDs
- `$SENTRY_ORG` for Sentry org slugs
- `$CRON_JOB_ID` for generic cron/routine IDs in public docs
- `$RENDER_ENV_GROUP_ID` for Render env group IDs
- `$ASC_PRIVATE_KEY_PATH` for App Store Connect private key file paths
- `$SIGNAL_PHONE` for Signal notification numbers
- `$TIKTOK_BRAND_HANDLE`, `$IG_BRAND_HANDLE`, etc. for social platform handles
- `$TIKTOK_BRAND_CONNECTION_ID`, `$IG_BRAND_CONNECTION_ID`, etc. for third-party service connection IDs

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

## 5. Check AGENTS.md compliance rules beyond secrets

Public skills repos often have structural rules that reviewers flag:
- **No README.md inside skill directories** — use TESTING.md, WORKFLOWS.md, etc. instead
- **SKILL.md must stay under 500 lines** — if content was inlined from a reference file, revert it and keep the reference
- **No personal data** — includes names in bylines, blog URLs with real names, personal handles in examples

## 6. Resolve review threads in bulk

After pushing the fix, resolve all related threads in one shell loop. See `delegation-and-git-pitfalls.md` for the batch pattern.

## 7. Handling claude-review 401 failures

The `claude-code-action` GitHub Action uses `CLAUDE_CODE_OAUTH_TOKEN` which expires periodically. When CI shows:
```
App token exchange failed: 401 Unauthorized - GitHub App authentication failed.
```

This is an infra issue, not a code issue. Options:
- **Quick**: Run `claude setup-token` locally, then `gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo <repo>`
- **Permanent**: Switch workflow to `anthropic_api_key` (uses API billing instead of Pro/Max subscription, doesn't expire)

Per AGENTS.md: "CI failures from bad credentials (401) are infra issues. Retry the run." Don't waste cycles trying to fix code when the auth is the problem.
