# GitHub Pages DNS Blueprint

**Vendor Docs**: [GitHub Pages Custom Domains](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)

## Records to Apply

### 1. Root Domain (@)
GitHub requires **4 A Records** for redundancy.
- **Type**: A
- **Content**: `185.199.108.153`
- **Content**: `185.199.109.153`
- **Content**: `185.199.110.153`
- **Content**: `185.199.111.153`

### 2. WWW Subdomain
- **Type**: CNAME
- **Host**: `www`
- **Content**: `<username>.github.io`
- **TTL**: 600

## Instructions for Agent
Ask user for their **GitHub username** or organization name to complete the CNAME record.
