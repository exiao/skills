# Vercel DNS Blueprint

**Vendor Docs**: [Vercel Custom Domains](https://vercel.com/docs/concepts/projects/domains/add-a-domain)

## Records to Apply

### 1. Root Domain (@)
- **Type**: A
- **Content**: `76.76.21.21`
- **TTL**: 600

### 2. WWW Subdomain
- **Type**: CNAME
- **Host**: `www`
- **Content**: `cname.vercel-dns.com`
- **TTL**: 600

## Notes
- Vercel automatically handles SSL.
- Ensure the domain is added to your Vercel project settings dashboard.
