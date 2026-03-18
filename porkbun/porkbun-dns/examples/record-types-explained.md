# DNS Record Types Explained

| Type | Name | What it does (Plain English) |
|:---:|:---:|---|
| **A** | Address | **Points a name to an IPv4 address** (e.g., `1.2.3.4`). The most common record. Used to "connect" your domain to a server. |
| **AAAA** | IPv6 Address | **Points a name to an IPv6 address**. Same as A, but for the newer, longer IP format. |
| **CNAME** | Canonical Name | **Points a name to another name**. Like a "See Also" or alias. E.g., point `www` to `example.com`. **RESTRICTION**: Cannot be used on the root domain (`example.com`). |
| **ALIAS** | Alias (Porkbun) | **A "smart" CNAME for the root domain**. Allows you to point your root `example.com` to another domain (like `gcp.app.net`) which standard DNS forbids. Porkbun handles the magic behind the scenes. |
| **MX** | Mail Exchange | **Controls where email goes**. Points to a mail server. Includes a "Priority" number—lower numbers are tried first. |
| **TXT** | Text | **Stores text info**. Used for verifying you own a domain (Google, etc.) or for email security (SPF, DKIM). Does *not* affect where the website goes. |
| **NS** | Nameserver | **Delegates authority**. Tells the world "Go ask *this* server about my domain". Changing these moves your DNS management away from Porkbun. |
