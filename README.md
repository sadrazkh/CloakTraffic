# CloakTraffic

## Overview

**CloakTraffic** is a dual-server proxy system that routes visitors from Iranian IP addresses through a proxy server located in Germany before reaching your main server in Canada.  
This setup hides the Iranian origin IPs from Google Analytics, making the traffic appear as if it originates from Germany.

---

## Prerequisites

- Two VPS servers:
  - **Main Server (Canada)** – hosts your website
  - **Proxy Server (Germany)** – proxies Iranian visitors
- Domains for each server (e.g., `example.com` for Main Server, `proxy.example.com` for Proxy Server)
- Cloudflare account for DNS and CDN management

---

## Installation

### Step 1: Install on Main Server (Canada)

Run this command on your main server:

```bash
bash <(curl -s https://raw.githubusercontent.com/sadrazkh/CloakTraffic/main/install-main.sh)
```

You will be asked to enter your main domain name (e.g., `example.com`).

This script installs and configures:

- NGINX with SSL (Let's Encrypt)
- Basic firewall rules
- Site setup

---

### Step 2: Install on Proxy Server (Germany)

Run this command on your proxy server:

```bash
bash <(curl -s https://raw.githubusercontent.com/sadrazkh/CloakTraffic/main/install-proxy.sh)
```

You will be asked to enter your proxy domain name (e.g., `proxy.example.com`).

This script installs and configures:

- NGINX with SSL (Let's Encrypt)
- GeoIP2 for IP-based country detection
- Firewall rules
- Proxy configuration to forward Iranian IP traffic to the main server

---

## DNS Configuration (Cloudflare)

1. In Cloudflare DNS settings:
   - Point your main domain (e.g., `example.com`) A record to the **Proxy Server's IP (Germany)**.
   - Point your proxy domain (e.g., `proxy.example.com`) A record to the **Proxy Server's IP** as well.
2. Make sure the **Proxy status (orange cloud)** is enabled for both DNS records.
3. This way, all traffic (including Iranian visitors) goes to the proxy server first.

---

## How It Works

- Visitors from all countries access your main domain.
- Iranian visitors are detected by the proxy server using GeoIP2 and their requests are proxied to the main server.
- Non-Iranian visitors can be served directly or also routed through the proxy depending on your config.
- Google Analytics sees the proxy server’s IP (Germany) for Iranian users, hiding their real Iranian IPs.

---

## Testing

- Use VPN or proxy services to simulate access from Iran and other countries.
- Check your Google Analytics to confirm Iranian visits show German IPs.
- Use online IP checker tools from the proxy server to verify IP forwarding.

---

## Quick Commands Summary

| Server       | Command                                                                 |
|--------------|-------------------------------------------------------------------------|
| Main Server  | `bash <(curl -s https://raw.githubusercontent.com/sadrazkh/CloakTraffic/main/install-main.sh)` |
| Proxy Server | `bash <(curl -s https://raw.githubusercontent.com/sadrazkh/CloakTraffic/main/install-proxy.sh)` |

---

## Support & Contributions

Feel free to open issues or contribute to this repository.

---

Thank you for using **CloakTraffic**!
