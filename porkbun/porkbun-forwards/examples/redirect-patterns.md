# Common Redirect Patterns

## 1. The Domain Move (SEO Safe)
Moving from `old-brand.com` to `new-brand.com`.
- **Type**: 301 Permanent
- **Include Path**: Yes
- **Wildcard**: Yes
- **Why**: This tells Google to transfer all "link juice" to the new domain.

## 2. The "Naked" Domain Fix
Ensuring `www.example.com` redirects to `example.com` (or vice versa).
- **Subdomain**: `www` (pointing to root) OR root (pointing to `www`)
- **Type**: 301 Permanent
- **Include Path**: Yes
- **Note**: Many modern hosts (Vercel, Netlify) handle this automatically, but doing it at the registrar level is a fail-safe.

## 3. Social Media Shortlink
Redirecting a short domain like `my.co` to your LinkedIn profile.
- **Location**: `https://linkedin.com/in/username`
- **Type**: 302 Temporary (allows you to change it later without caching issues)
- **include Path**: No (usually)
