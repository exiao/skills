# Netlify DNS Blueprint

**Vendor Docs**: [Netlify Custom Domains](https://docs.netlify.com/domains-https/custom-domains/configure-external-dns/)

## Records to Apply

### 1. Root Domain (@)
- **Type**: A
- **Content**: `75.2.60.5`
- **TTL**: 600

### 2. WWW Subdomain
- **Type**: CNAME
- **Host**: `www`
- **Content**: `<site-name>.netlify.app`
- **TTL**: 600

## Instructions for Agent
Ask for the **Netlify site name** (e.g., `my-cool-site` from `my-cool-site.netlify.app`).
