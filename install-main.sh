#!/bin/bash
set -e

echo "Updating and installing nginx, certbot..."
apt update && apt upgrade -y
apt install -y nginx certbot python3-certbot-nginx ufw

echo "Please enter your main server domain (e.g. example.com):"
read MAIN_DOMAIN

echo "Configuring firewall..."
ufw allow 'Nginx Full'
echo "Configuring basic firewall rules..."

ufw allow 22
ufw allow 80
ufw allow 443

read -p "Do you want to open any additional ports? (comma-separated, or leave blank): " extra_ports
if [ ! -z "$extra_ports" ]; then
  IFS=',' read -ra PORTS <<< "$extra_ports"
  for port in "${PORTS[@]}"; do
    ufw allow "$port"
  done
fi

ufw enable
ufw --force enable

echo "Setting up nginx for main domain..."

cat > /etc/nginx/sites-available/$MAIN_DOMAIN << EOF
server {
    listen 80;
    server_name $MAIN_DOMAIN www.$MAIN_DOMAIN;

    location / {
        root /var/www/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$MAIN_DOMAIN /etc/nginx/sites-enabled/

echo "<h1>Welcome to Main Server: $MAIN_DOMAIN</h1>" > /var/www/html/index.html

nginx -t && systemctl restart nginx

echo "Obtaining SSL certificate for $MAIN_DOMAIN..."
certbot --nginx -d $MAIN_DOMAIN -d www.$MAIN_DOMAIN --non-interactive --agree-tos -m admin@$MAIN_DOMAIN

echo "Setup complete for main server."
