#!/bin/bash

# Exit on any error
set -e

# Update and install Nginx and OpenSSL
sudo apt update
sudo apt install -y nginx openssl

# Create a directory for SSL certificates
sudo mkdir -p /etc/nginx/ssl

# Generate a self-signed SSL certificate (adjust the domain for production)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=US/ST=State/L=City/O=Company/CN=${DOMAIN_NAME}"

# Create Nginx configuration file
cat <<EOF | sudo tee /etc/nginx/sites-available/default > /dev/null
server {
    listen 80;
    server_name ${DOMAIN_NAME};

    # Redirect HTTP to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Test Nginx configuration
sudo nginx -t

# Restart Nginx to apply the changes
sudo systemctl restart nginx

# Allow Nginx traffic through the firewall (if applicable)
sudo ufw allow 'Nginx Full'

# Check Nginx status
sudo systemctl status nginx
