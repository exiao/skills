---
name: porkbun-hosting-blueprints
description: Use this skill to apply complete, vendor-recommended DNS configurations for popular hosting platforms (Vercel, Netlify, GitHub Pages, etc.) in one go.
---

# porkbun-hosting-blueprints

This skill provides "one-click" configurations for common hosting providers. Instead of manually looking up A records and CNAMEs, the user just says "Setup Vercel" and this skill applies the standard pattern.

## When to use
- "I want to host this on Vercel"
- "Setup DNS for GitHub Pages"
- "Connect my domain to Cloudflare Pages"

## Instructions

### 1. Identify the Platform
Match the user's request to one of the blueprints in the `blueprints/` directory:
- **Vercel** (`vercel.md`)
- **Cloudflare Pages** (`cloudflare-pages.md`)
- **GitHub Pages** (`github-pages.md`)
- **Netlify** (`netlify.md`)
- **Railway** (`railway.md`)
- **Self-Hosted / VPS** (`self-hosted.md`)

### 2. Read the Blueprint
Load the file from `blueprints/` to get the specific records required.

### 3. Execution Protocol (Safety First)
1. **Explain the Plan**: "To set up Vercel, I need to add an A record pointing to 76.76.21.21 and a CNAME for www."
2. **Check for Conflicts**: Use `porkbun-dns` logic. If there are existing A/CNAME records on the root/www, warn the user they will be replaced.
3. **Execute**: Create the records.
4. **Verify**: Brief output confirming what was done.

## Examples

**User**: "Connect `my-site.com` to Vercel"
**Claude**:
> "I can help with that. The **Vercel Blueprint** requires:
> 1. **Root (@)**: A Record -> `76.76.21.21`
> 2. **WWW**: CNAME -> `cname.vercel-dns.com`
>
> [!WARNING]
> This will replace your existing A record pointing to `1.2.3.4`.
>
> Shall I proceed?"
