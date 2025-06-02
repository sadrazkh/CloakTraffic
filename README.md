# CloakTraffic - Proxy Setup Script for Regional IP Masking

This script is designed to prepare a Linux server (Debian/Ubuntu) with NGINX, automatic SSL, and basic HTML content to act as a proxy or frontend server. It supports use cases like routing Iranian traffic through a German proxy to bypass IP-based geo-detection (e.g., for Google Analytics).

## 🔧 Features
- Automatic NGINX + Let's Encrypt SSL setup
- Domain prompt on install
- Minimal HTML index page for testing
- UFW firewall auto-config
- English-only clean output

## 📦 Usage
Clone the repo and run the setup script on both your proxy (Germany) and main (Canada) servers:

```bash
git clone https://github.com/yourusername/geo-shield.git
cd geo-shield
chmod +x install.sh
sudo ./install.sh
```

You'll be asked to enter the domain name for this server during setup (e.g., `proxy.yoursite.com` or `main.yoursite.com`).

---

## ☁️ Cloudflare Configuration (Optional but Recommended)

### ✅ Enable Cloudflare Proxy
1. Make sure both your domains (`proxy.yoursite.com`, `main.yoursite.com`) are added to your Cloudflare account.
2. Set DNS records for both domains to point to their respective IPs (Germany and Canada).
3. Enable the orange cloud icon to activate Cloudflare Proxy for both.

### ⚙️ Recommended Settings
- **SSL/TLS**: Set to **Full**
- **Caching**: Set to **Standard** (optional)
- **Bot Fight Mode**: Optional (can block internal curl requests)
- **Page Rules (optional)**:
    - Cache everything if you want to improve performance
    - Disable security for `.well-known/acme-challenge` if Let's Encrypt fails

---

## 📡 Advanced: Proxying Iranian Traffic via Cloudflare Workers (Upcoming)
You can deploy a Cloudflare Worker to forward traffic based on IP geolocation (Iran) through your German proxy. This will hide the user's original IP from analytics tools.

Coming soon in the next version of this repo.

---

## 📁 File Structure
```
.
├── install.sh          # Main setup script for server configuration
├── README.md           # This file
```

---

## ✍️ Author
**Your Name** — [@yourhandle](https://github.com/yourhandle)

---

## 📄 License
MIT License
