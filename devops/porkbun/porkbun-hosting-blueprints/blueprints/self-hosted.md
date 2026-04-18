# Self-Hosted / VPS Blueprint

Use this for DigitalOcean, Linode, AWS EC2, or a home server.

## Records to Apply

### 1. IPv4 Address (Required)
Ask user for their **Server IPv4 Address**.
- **Type**: A
- **Host**: `@` (Root)
- **Content**: `<IPv4>`

### 2. IPv6 Address (Optional)
Ask user for their **Server IPv6 Address**.
- **Type**: AAAA
- **Host**: `@`
- **Content**: `<IPv6>`

### 3. Subdomains
- **Type**: CNAME
- **Host**: `www`
- **Content**: `@` (Points to root)

### 4. Basic Email Security (Optional but Recommended)
Prevents spoofing if they aren't using email yet.
- **Type**: TXT
- **Host**: `@`
- **Content**: `v=spf1 -all` (Strictly no email sent from here)
