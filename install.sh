#!/bin/bash

set -e

# Colors for output
green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

# Prompt for domain
read -p "Enter the domain to configure on this server (e.g., proxy.example.com): " DOMAIN

# Update & install dependencies
echo -e "${green}Installing NGINX and Certbot...${reset}"
apt update && apt install -y nginx certbot python3-certbot-nginx ufw

# Setup basic firewall
ufw allow 'Nginx Full'
ufw --force enable

# Create web root and test page
echo -e "${green}Creating test site content...${reset}"
mkdir -p /var/www/$DOMAIN/html
echo "<h1>✅ $DOMAIN is successfully installed on $(hostname)</h1>" > /var/www/$DOMAIN/html/index.html

# Set permissions
chown -R www-data:www-data /var/www/$DOMAIN/html
chmod -R 755 /var/www/$DOMAIN

# Create NGINX config
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
echo -e "${green}Creating NGINX config...${reset}"
cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/$DOMAIN/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable site & reload nginx
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Issue SSL certificate
echo -e "${green}Issuing SSL certificate with Let's Encrypt...${reset}"
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN || true

# Reload NGINX
systemctl reload nginx

# Done
echo -e "${green}Setup complete. Visit: https://$DOMAIN${reset}"
echo -e "This server is: $(hostname)"
