#!/bin/bash
set -e

echo "Updating and installing nginx, certbot, geoip2, and dependencies..."
apt update && apt upgrade -y
apt install -y nginx certbot python3-certbot-nginx wget unzip ufw libnginx-mod-http-geoip2

echo "Please enter your proxy server domain (e.g. proxy.example.com):"
read PROXY_DOMAIN

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

# Download GeoLite2-Country.mmdb if not exists
GEOIP_PATH="/usr/share/GeoIP/GeoLite2-Country.mmdb"
mkdir -p /usr/share/GeoIP/
if [ ! -f "$GEOIP_PATH" ]; then
    echo "Downloading GeoLite2-Country.mmdb ..."
    wget -q https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz -O /tmp/GeoLite2-Country.mmdb.gz
    gunzip -f /tmp/GeoLite2-Country.mmdb.gz -c > $GEOIP_PATH
fi

echo "Setting up nginx config for proxy..."

cat > /etc/nginx/sites-available/$PROXY_DOMAIN << EOF
load_module modules/ngx_http_geoip2_module.so;

server {
    listen 80;
    server_name $PROXY_DOMAIN;

    geoip2 /usr/share/GeoIP/GeoLite2-Country.mmdb {
        auto_reload 60m;
        \$geoip2_data_country_code country iso_code;
    }

    location / {
        if (\$geoip2_data_country_code = "IR") {
            proxy_pass https://REPLACE_WITH_MAIN_SERVER_IP_OR_DOMAIN;
            proxy_set_header Host REPLACE_WITH_MAIN_SERVER_DOMAIN;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_ssl_verify off;
            break;
        }
        return 403;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$PROXY_DOMAIN /etc/nginx/sites-enabled/

nginx -t && systemctl restart nginx

echo "Obtaining SSL certificate for $PROXY_DOMAIN..."
certbot --nginx -d $PROXY_DOMAIN --non-interactive --agree-tos -m admin@$PROXY_DOMAIN

echo "Setup complete for proxy server."

echo "IMPORTANT: Please edit /etc/nginx/sites-available/$PROXY_DOMAIN and replace:"
echo "  REPLACE_WITH_MAIN_SERVER_IP_OR_DOMAIN"
echo "  REPLACE_WITH_MAIN_SERVER_DOMAIN"
echo "with your main server's IP/domain and domain name."
echo "Then reload nginx with: sudo nginx -s reload"
