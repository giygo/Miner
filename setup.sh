#!/bin/bash

echo "🔐 Starting VPS setup..."

# Update & install Docker
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose ufw git nginx certbot python3-certbot-nginx

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Setup UFW firewall
echo "🛡️ Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Clone your GitHub repo
echo "📦 Cloning repo..."
git clone https://github.com/Giygo/miner.git ~/miner
cd ~/miner

# Ask for domain if HTTPS is desired
read -p "Enter domain for HTTPS (or leave blank to skip): " DOMAIN

if [ ! -z "$DOMAIN" ]; then
    echo "🌐 Setting up HTTPS for $DOMAIN..."
    sudo cp dashboard/nginx_template.conf /etc/nginx/sites-available/miner
    sudo sed -i "s/YOUR_DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/miner
    sudo ln -s /etc/nginx/sites-available/miner /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx
    sudo certbot --nginx -d $DOMAIN
fi

# Start miner in regtest mode
echo "🚀 Starting miner stack (regtest)..."
sudo docker-compose up -d

echo "✅ Setup complete. Access dashboard at: http://$DOMAIN or your server IP"