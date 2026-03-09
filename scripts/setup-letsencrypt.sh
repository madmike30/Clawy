#!/bin/bash
set -e

DOMAIN="clawy.duckdns.org"

echo "=== Setting up Let's Encrypt SSL for $DOMAIN ==="

# Install certbot
echo "1. Installing certbot..."
sudo apt-get update -qq
sudo apt-get install -y -qq certbot python3-certbot-nginx

# Open port 443 and 80 (needed for cert validation)
echo "2. Opening firewall ports..."
sudo ufw allow 80/tcp comment 'HTTP (certbot)' >/dev/null
sudo ufw allow 443/tcp comment 'HTTPS' >/dev/null

# Write nginx config with domain
echo "3. Writing nginx config for $DOMAIN..."
sudo tee /etc/nginx/sites-available/openclaw-ssl > /dev/null << NGINX
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/nginx/ssl/openclaw.crt;
    ssl_certificate_key /etc/nginx/ssl/openclaw.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    auth_basic "OpenClaw";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://127.0.0.1:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/openclaw-ssl /etc/nginx/sites-enabled/openclaw
sudo nginx -t && sudo systemctl restart nginx
echo "   nginx restarted with domain config"

# Get Let's Encrypt cert
echo "4. Obtaining Let's Encrypt certificate..."
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email madmike30@users.noreply.github.com --redirect
echo "   SSL certificate obtained!"

# Verify auto-renewal
echo "5. Testing cert auto-renewal..."
sudo certbot renew --dry-run
echo "   Auto-renewal working"

echo ""
echo "=== SSL setup complete ==="
echo "Access: https://$DOMAIN/#token=<your-token>"
