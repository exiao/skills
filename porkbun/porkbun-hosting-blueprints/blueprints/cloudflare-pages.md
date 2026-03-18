# Cloudflare Pages DNS Blueprint

**Vendor Docs**: [Cloudflare Pages Custom Domains](https://developers.cloudflare.com/pages/configuration/custom-domains/)

## Records to Apply

### 1. Root Domain (@) or Subdomain
- **Type**: CNAME
- **Content**: `<project-name>.pages.dev`
- **TTL**: 600

## Instructions for Agent
Ask the user for their **project name** (the `<project-name>.pages.dev` part).
- If setup is for root (`example.com`), use CNAME (or ALIAS if CNAME on root is blocked, but Porkbun usually allows CNAME flattening/ALIAS behavior).
- **Porkbun specific**: Use **CNAME** for root; Porkbun automatically flattens it (internally treats as ALIAS).

## Notes
- You must add the custom domain in the Cloudflare Pages dashboard.
