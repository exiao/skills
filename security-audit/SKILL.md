---
name: security-audit
description: Run a codebase security audit using OWASP Top 10 and STRIDE threat modeling. Use when auditing code for vulnerabilities or preparing for a pentest.
---
# Security Audit

Codebase security audit using OWASP Top 10 and STRIDE threat modeling. Scans application code for vulnerabilities, not infrastructure (see `healthcheck` skill for host hardening).

Use when: auditing a codebase for security issues, reviewing a feature branch before merge, preparing for a pentest, or when something feels off about how auth/data/access is handled.

---

## How It Works

Two passes over the codebase, then a consolidated report. Run dependency checks first (they're fast and definitive), then do the manual code audit.

---

## Step 0: Dependency Scan (Automated)

Run the appropriate package audit tools before any manual review:

```bash
# JavaScript/TypeScript
npm audit --json 2>/dev/null || yarn audit --json 2>/dev/null
npx better-npm-audit audit 2>/dev/null

# Python
pip audit 2>/dev/null || safety check 2>/dev/null
pip list --outdated --format=json 2>/dev/null

# Ruby
bundle audit check --update 2>/dev/null

# Go
govulncheck ./... 2>/dev/null

# General
gh api /repos/{owner}/{repo}/dependabot/alerts --jq '.[].security_advisory.summary' 2>/dev/null
```

Report known CVEs with severity. These are facts, not opinions.

---

## Step 1: OWASP Top 10 Scan

For each category, scan the codebase systematically. Skip categories that don't apply to the stack (e.g., skip XXE for a pure React frontend).

### A01: Broken Access Control
- Are there endpoints missing auth middleware?
- Can users access other users' data by changing IDs? (IDOR)
- Are admin routes properly gated?
- Do API endpoints enforce the same permissions as the UI?
- Check: every route/view that takes a user-scoped ID

### A02: Cryptographic Failures
- Secrets in source code or version control (grep for API keys, tokens, passwords)
- Sensitive data stored unencrypted (PII, financial data, health data)
- Weak hashing (MD5, SHA1 for passwords)
- Missing TLS enforcement
- Check: `.env.example`, config files, database schemas for sensitive fields

### A03: Injection
- SQL injection (raw queries, string concatenation in queries)
- NoSQL injection (unsanitized MongoDB queries)
- Command injection (shell exec with user input)
- Prompt injection (user input passed directly to LLM prompts)
- LDAP, XPath, template injection
- Check: every place user input touches a query, command, or template

### A04: Insecure Design
- Missing rate limiting on auth endpoints
- No account lockout after failed attempts
- Missing CSRF protection on state-changing requests
- Business logic flaws (can users skip payment? access premium features?)
- Check: auth flows, payment flows, onboarding flows

### A05: Security Misconfiguration
- Debug mode enabled in production configs
- Default credentials in config files
- Overly permissive CORS (`Access-Control-Allow-Origin: *`)
- Stack traces exposed in error responses
- Unnecessary features enabled (admin panels, debug endpoints)
- Check: settings files, middleware config, error handlers

### A06: Vulnerable Components
- Handled by Step 0 (dependency scan)
- Additionally: are there vendored/copied libraries that won't get updates?

### A07: Authentication Failures
- Session tokens in URLs
- Tokens stored in localStorage (XSS-accessible)
- Missing token expiration or rotation
- Password reset flows that leak information
- JWT without signature verification, or using `none` algorithm
- Check: auth middleware, session management, token handling

### A08: Data Integrity Failures
- Deserialization of untrusted data (pickle, yaml.load, JSON.parse of user input into executable context)
- Missing integrity checks on updates or deployments
- CI/CD pipeline security (can PRs modify deploy scripts?)
- Check: serialization/deserialization code, update mechanisms

### A09: Logging & Monitoring Failures
- Sensitive data in logs (passwords, tokens, PII)
- Missing audit trail for admin actions
- No alerting on auth failures
- Check: logging config, log statements, monitoring setup

### A10: Server-Side Request Forgery (SSRF)
- User-controlled URLs fetched server-side
- Missing URL validation/allowlisting
- Internal service URLs accessible via user input
- Check: any endpoint that fetches a URL, webhook handlers, image/file importers

---

## Step 2: STRIDE Threat Model

For the application's core flows (auth, data access, payments, admin), evaluate each STRIDE category:

| Threat | Question | What to look for |
|--------|----------|-----------------|
| **Spoofing** | Can someone pretend to be another user? | Weak auth, session fixation, missing MFA on sensitive ops |
| **Tampering** | Can someone modify data they shouldn't? | Missing input validation, unsigned tokens, client-side trust |
| **Repudiation** | Can someone deny performing an action? | Missing audit logs, no transaction records |
| **Information Disclosure** | Can someone access data they shouldn't? | Verbose errors, directory listing, exposed internal APIs, debug endpoints |
| **Denial of Service** | Can someone make the service unavailable? | Missing rate limits, expensive queries without pagination, file upload without size limits |
| **Elevation of Privilege** | Can someone gain higher access? | Role check bypass, parameter pollution, mass assignment |

For each threat found, describe:
1. The specific attack scenario (not generic, reference actual code paths)
2. The affected file and line
3. The severity (Critical / High / Medium / Low)
4. A concrete fix

---

## Confidence & False Positive Filtering

### Confidence Gate
Only report findings with **high confidence** (8/10+). If you're not sure something is a real vulnerability, say so explicitly. "Possible issue, needs manual verification" is better than a false positive.

### Common False Positives to Skip
- `eval()` in build tooling or test fixtures (not user-reachable)
- Hardcoded strings in tests that look like secrets but aren't
- `dangerouslySetInnerHTML` with sanitized or static content
- `innerHTML` in server-rendered templates with escaped output
- Console.log in development-only code paths
- Broad CORS in local dev config (check prod config instead)
- Self-signed certs in dev/test environments
- `subprocess` calls with hardcoded (not user-derived) arguments
- Query construction in ORM methods that parameterize internally
- `nosec` / `noinspection` annotations (acknowledged risks)
- Rate limiting handled by reverse proxy rather than app code
- Cookies without `Secure` flag in localhost-only contexts
- `eval` in Python `ast.literal_eval` (safe)
- Dynamic imports with hardcoded module names
- File reads from config-defined paths (not user input)

### Independent Verification
Before reporting a finding, verify it's actually exploitable:
- Can the vulnerable code path be reached from user input?
- Is there middleware or validation that catches it before it hits the vulnerable code?
- Is the "vulnerability" in dead code or behind a feature flag?

---

## Report Format

```
Security Audit Report
━━━━━━━━━━━━━━━━━━━━

Stack: [detected stack]
Files scanned: [count]
Dependencies: [count checked, count vulnerable]

CRITICAL (fix before deploy)
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[C1] SQL Injection in user search
     File: app/views/search.py:47
     Category: OWASP A03 (Injection)
     Confidence: 9/10
     
     Attack: GET /api/search?q=' OR 1=1--
     The search query is concatenated directly into a raw SQL query
     without parameterization.
     
     Fix: Use Django ORM .filter() or parameterized query.

HIGH
━━━━
[H1] Tokens stored in localStorage
     File: src/auth/session.ts:23
     Category: OWASP A07 (Auth Failures)
     Confidence: 10/10
     
     Attack: Any XSS vulnerability gives full account takeover.
     localStorage is accessible to any JavaScript on the page.
     
     Fix: Move to httpOnly cookies with SameSite=Strict.

MEDIUM
━━━━━━
[M1] Missing rate limiting on /api/login
     File: app/urls.py:12 → app/views/auth.py:8
     Category: OWASP A04 (Insecure Design) / STRIDE DoS
     Confidence: 8/10
     
     Attack: Automated credential stuffing at unlimited rate.
     No rate limiting middleware on auth endpoints.
     
     Fix: Add django-ratelimit or throttle via reverse proxy.

LOW
━━━
[L1] Verbose error messages in production
     ...

PASSED (checked, no issues)
━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CSRF protection: enabled on all state-changing endpoints
✅ Password hashing: bcrypt with cost factor 12
✅ SQL injection: ORM used consistently (except C1 above)
✅ XSS: React auto-escaping, no dangerouslySetInnerHTML
✅ Secrets: no hardcoded credentials in source

Summary: [X] critical, [Y] high, [Z] medium, [W] low
```

---

## Scope Options

The user can scope the audit:

- **Full** (default) — entire codebase, both OWASP and STRIDE
- **Diff only** — only files changed in the current branch (`git diff main`)
- **Auth only** — focus on authentication and authorization code
- **API only** — focus on API endpoints and data handling
- **Frontend only** — XSS, client-side storage, CORS, CSP

---

## After the Audit

1. Report findings in the format above
2. Offer to fix Critical and High issues (with user approval per fix)
3. If run on a branch, suggest adding findings as PR comments
4. Don't auto-fix anything. Present the fix, let the user decide.

## Anti-Patterns

- Don't report low-confidence findings as definitive vulnerabilities
- Don't flag dev-only code as production risks without checking
- Don't recommend security theater (e.g., "add more encryption" without specifying what/where)
- Don't audit infrastructure or hosting (that's the healthcheck skill)
- Don't run penetration tests or exploit code against live systems
- Don't ignore framework-provided protections (ORMs, CSRF middleware, template escaping)
