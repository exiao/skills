---
name: porkbun-forwards
description: Use this skill to redirect one domain or subdomain to another URL.
---

# porkbun-forwards

This skill manages URL Forwarding (Redirection). It's great for parking domains or pointing old sites to new ones.

## When to use
- "Redirect my domain to google.com"
- "Forward old-site.com to new-site.com"
- "Make www go to the root domain"

## Instructions

### 1. Check Existing
Endpoint: `POST https://api.porkbun.com/api/json/v3/domain/getUrlForwarding/DOMAIN`
- always check before overwriting.

### 2. Create Forward
Endpoint: `POST https://api.porkbun.com/api/json/v3/domain/addUrlForward/DOMAIN`
Payload:
```json
{
  "subdomain": "", 
  "location": "https://destination.com", 
  "type": "temporary", 
  "includePath": "yes", 
  "wildcard": "yes"
}
```

### Parameters explained to User
- **Location**: Must be a full URL (start with `http://` or `https://`).
- **301 (Permanent)** vs **302 (Temporary)**: 
  - Use **301** if this is a permanent move (better for SEO).
  - Use **302** if it's temporary or you're testing.
- **Path Forwarding**: If someone goes to `old.com/blog/post-1`, "includePath" sends them to `new.com/blog/post-1`. Usually you want this **ON** ("yes").
- **Wildcard**: Matches `*.old.com`. Usually **ON**.

## Examples

**User**: "Redirect `client-site.com` to `https://final-site.com`"
**Claude**:
> "I'll set up a **301 Permanent Redirect**.
> 
> **Source**: `client-site.com` (and all subdomains)
> **Destination**: `https://final-site.com`
> **Preserve Path**: Yes (e.g. `client-site.com/about` -> `final-site.com/about`)
>
> Is that correct?"
