#!/bin/bash
set -e

echo "=== Setting up nginx HTTPS reverse proxy ==="

# Generate self-signed SSL cert (valid 1 year)
echo "1. Generating self-signed SSL certificate..."
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/openclaw.key \
    -out /etc/nginx/ssl/openclaw.crt \
    -subj "/CN=147.224.144.47/O=Clawy/C=IL" 2>/dev/null
echo "   Certificate created"

# Ensure htpasswd exists
echo "2. Checking HTTP basic auth..."
if [ ! -f /etc/nginx/.htpasswd ]; then
    echo -n "Enter password for user 'dor': "
    read -s PASS
    echo
    echo "$PASS" | sudo htpasswd -ci /etc/nginx/.htpasswd dor
else
    echo "   htpasswd already exists"
fi

# Write nginx config
echo "3. Writing nginx config..."
sudo tee /etc/nginx/sites-available/openclaw-ssl > /dev/null << 'NGINX'
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

# Redirect HTTP to HTTPS
server {
    listen 18790;
    return 301 https://$host:18443$request_uri;
}

# HTTPS server
server {
    listen 18443 ssl;

    ssl_certificate /etc/nginx/ssl/openclaw.crt;
    ssl_certificate_key /etc/nginx/ssl/openclaw.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    auth_basic "OpenClaw";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://127.0.0.1:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Origin https://$host:$server_port;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
}
NGINX

# Enable the new config, remove old
sudo ln -sf /etc/nginx/sites-available/openclaw-ssl /etc/nginx/sites-enabled/openclaw
sudo nginx -t && sudo systemctl restart nginx && sudo systemctl enable nginx
echo "   nginx configured and running"

# Open port 18443 in UFW
echo "4. Opening firewall port 18443..."
sudo ufw allow 18443/tcp comment 'OpenClaw HTTPS' >/dev/null
echo "   Port 18443 open"

echo ""
echo "=== HTTPS proxy ready ==="
echo "Access: https://147.224.144.47:18443/#token=<your-token>"
echo "Note: Browser will warn about self-signed cert - accept it."
echo "For a proper cert, add a domain and use Let's Encrypt."
