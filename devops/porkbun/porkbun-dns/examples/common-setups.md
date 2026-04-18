# Common DNS Scenarios

## 1. Hosting a Website
To point your domain to a web host, you usually need:
- **Root Domain** (`example.com`): An **A Record** pointing to the server's IP address.
- **WWW Subdomain** (`www.example.com`): A **CNAME Record** pointing to `example.com` (or sometimes the host's domain).

## 2. Verifying Domain Ownership
Services like Google, Facebook, or newsletter tools often ask you to add a **TXT Record**.
- **Host**: Usually `@` (root) or a specific code provided by the service.
- **Content**: A long string like `google-site-verification=...`.
- **Note**: You can have multiple TXT records on the same root domain.

## 3. Email Setup (MX Records)
**MX (Mail Exchange)** records tell the world which server handles email for your domain.
- **Priority**: A number (0, 10, 20) that sets the order of servers to try. Lower = higher priority.
- **Host**: Always `@` for your main email address (you@example.com).

## 4. Subdomains for Apps
If you have an app at `app.example.com`:
- **Separate Server**: Use an **A Record** for `app` pointing to the new IP.
- **Hosted Platform**: Use a **CNAME Record** for `app` pointing to the provider (e.g., `cname.vercel-dns.com`).
