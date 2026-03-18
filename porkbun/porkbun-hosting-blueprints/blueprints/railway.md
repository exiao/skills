# Railway DNS Blueprint

**Vendor Docs**: [Railway Custom Domains](https://docs.railway.app/guides/public-networking#custom-domains)

## Records to Apply

### 1. Root or Subdomain
- **Type**: CNAME
- **Content**: `<domain>.up.railway.app`
- **TTL**: 600

## Instructions for Agent
Ask the user for the **Railway-provided domain** (usually looks like `project-production.up.railway.app` or similar).
- Unlike Vercel, Railway generally uses CNAMEs (or ALIAS/CNAME Flattening) for everything.
