# Phase 5: DNS Cutover

Switching DNS is the moment users start hitting the new provider. Do this only after Phase 4 (parity verification) passes.

---

## TTL Strategy

**Lower TTL 24 hours before cutover.** This is the most important DNS tip.

DNS records have a TTL (time-to-live) — how long resolvers cache the old value. If your TTL is 3600 (1 hour), it takes up to 1 hour for all users to see the new IP after you change it.

```
Day before migration:
  - Change TTL from 3600 → 60 (on all records you'll be updating)
  - Wait for old TTL to expire (up to 3600s)
  - Now: TTL is effectively 60s everywhere

Day of cutover:
  - Update record → propagates in ~60 seconds
  - If anything goes wrong → revert in ~60 seconds
```

After migration is stable (48h), raise TTL back to 300 or 3600.

---

## Provider-Specific DNS Records

### Railway

Railway gives you a CNAME target for custom domains:

```bash
# Register the custom domain
railway domain api.myapp.com
# Output: "Set CNAME api.myapp.com → abc123.up.railway.app"

# Railway also provides the CNAME target:
# Format: <hash>.up.railway.app
# Example: tmnv267w.up.railway.app  (from the Bloom migration)
```

DNS record to set:
```
Type:  CNAME
Name:  api         (for api.myapp.com)
Value: <hash>.up.railway.app
TTL:   60 (during cutover), 300 (after)
```

**Cloudflare note:** Use "DNS only" (grey cloud) for Railway custom domains — do NOT proxy through Cloudflare orange cloud unless Railway supports it. Railway handles its own SSL. If you proxy through CF, Railway's SSL won't provision correctly.

### Fly.io

```bash
flyctl certs create api.myapp.com -a $APP
# Output: CNAME target → <app>.fly.dev or A record
```

Fly.io supports both CNAME and A records.

### Heroku

```bash
heroku domains:add api.myapp.com -a $APP
heroku domains -a $APP
# Shows: DNS Target = myapp.prod-us-east-1.elb.amazonaws.com
```

Use CNAME pointing to the DNS target shown.

### Vercel (frontend)

```bash
vercel domains add api.myapp.com
# Follow prompts for DNS verification
```

---

## Cutover Procedure

### Step 1: Verify target is healthy

Before touching DNS, confirm:
```bash
# Health check on the Railway/Fly domain (not custom domain yet)
curl -I https://myapp-production.up.railway.app/health/
# Expect: HTTP/2 200

# API endpoint check
curl https://myapp-production.up.railway.app/api/v1/status/
```

### Step 2: Lower TTL (if not done 24h ago)

If you didn't lower TTL in advance:
- Lower it now to 60
- Wait for the old TTL duration before proceeding (e.g., wait 1 hour if TTL was 3600)
- This is the "wrong" way but sometimes unavoidable

### Step 3: Update DNS record

In your DNS provider (Cloudflare, Route53, Namecheap, etc.):

**CNAME record:**
```
Before: api.myapp.com → old-provider.example.com
After:  api.myapp.com → newhash.up.railway.app
```

**A record (if not using CNAME):**
```
Before: api.myapp.com → 1.2.3.4
After:  api.myapp.com → new IP from provider
```

### Step 4: Verify propagation

```bash
# Check what resolvers see
dig api.myapp.com CNAME
dig api.myapp.com A

# Use a public DNS checker
# https://dnschecker.org/ — shows resolution from ~30 locations

# Hit the endpoint through custom domain
curl -I https://api.myapp.com/health/
```

### Step 5: Monitor both environments

For 15-30 minutes after cutover, watch logs on both old and new:

```bash
# New (Railway):
mcporter call railway.get-logs workspacePath="$(pwd)" logType="deploy"

# Old (Render/Heroku - if still accessible):
heroku logs --tail -a myapp  # Heroku
# Render: watch for any requests still hitting old
```

### Step 6: SSL verification

New provider SSL should provision within 5-15 minutes:

```bash
# Check SSL cert
curl -vI https://api.myapp.com/health/ 2>&1 | grep -E "subject|issuer|expire"
# Look for: subject: CN=api.myapp.com
# Issuer should be Let's Encrypt or provider CA
```

If SSL doesn't provision: check that DNS is pointing to the new provider (not proxied through Cloudflare incorrectly).

---

## Rollback Plan

Because you lowered the TTL, rollback is fast:

```bash
# If new provider is broken:
# 1. Update DNS back to old CNAME/A record
# 2. Wait 60-120 seconds for propagation
# 3. Old provider is live again

# Test rollback worked:
curl -I https://api.myapp.com/health/
```

Keep the old provider running for 48 hours specifically to enable this rollback.

---

## Cloudflare-Specific Notes

Cloudflare is a common DNS provider. Key settings:

```
Proxy status:
- Orange cloud (proxied): Traffic goes through Cloudflare CDN
  → SSL is Cloudflare's. Provider doesn't see real client IPs.
  → Use for: static sites, Vercel, anything behind CF
  
- Grey cloud (DNS only): Cloudflare just resolves, traffic goes direct
  → SSL is provider's (Let's Encrypt, etc.)
  → Use for: Railway, Fly.io, Heroku (they handle SSL themselves)
  → Required for Railway custom domain SSL to provision
```

For the Bloom migration (Render → Railway):
- `api.getbloom.app` → CNAME `tmnv267w.up.railway.app`
- **DNS only (grey cloud)** — not proxied
- Railway provisioned SSL automatically within ~10 minutes

---

## DNS Cutover Checklist

- [ ] TTL lowered to 60 (ideally 24h before)
- [ ] Target environment passing all health/parity checks
- [ ] Custom domain registered on target provider (`railway domain`, `flyctl certs`, etc.)
- [ ] DNS record updated in registrar/Cloudflare
- [ ] Propagation verified via `dig` and dnschecker.org
- [ ] SSL certificate provisioned on new domain
- [ ] Health endpoint returning 200 via custom domain
- [ ] Both old and new logs monitored for 15-30 min
- [ ] Old environment kept alive for 48h confidence window
