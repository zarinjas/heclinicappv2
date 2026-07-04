#!/bin/bash
# He Clinic VPS Setup Script
# Run this ONCE on the VPS to install all dependencies and configure services.

set -e

echo "=== He Clinic VPS Setup ==="
echo ""

# --- System Update ---
echo "[1/8] Updating system packages..."
apt-get update && apt-get upgrade -y

# --- Install Core Dependencies ---
echo "[2/8] Installing core dependencies..."
apt-get install -y \
    nginx \
    certbot python3-certbot-nginx \
    php8.3 php8.3-fpm php8.3-cli \
    php8.3-mysql php8.3-mbstring php8.3-xml php8.3-curl php8.3-zip \
    php8.3-bcmath php8.3-gd \
    composer \
    nodejs npm \
    mysql-server

# --- Install PM2 for bot process management ---
echo "[3/8] Installing PM2..."
npm install -g pm2

# --- Create Directories ---
echo "[4/8] Creating directories..."
mkdir -p /var/www/heclinic
mkdir -p /var/www/heclinic-laravel
mkdir -p /var/www/heclinic-bot
mkdir -p /var/log

# --- Nginx Config ---
echo "[5/8] Configuring nginx..."
cp /var/www/heclinic-laravel/../nginx/heclinic.conf /etc/nginx/sites-available/heclinic 2>/dev/null || true
ln -sf /etc/nginx/sites-available/heclinic /etc/nginx/sites-enabled/

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# --- SSL (Let's Encrypt) ---
echo "[6/8] Setting up SSL..."
certbot --nginx -d heclinic.cyberoket.cloud --non-interactive --agree-tos --email admin@cyberoket.cloud || true

# --- MySQL Setup ---
echo "[7/8] Setting up MySQL..."
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS heclinic CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'heclinic'@'localhost' IDENTIFIED BY 'CHANGE_ME_DB_PASSWORD';
GRANT ALL PRIVILEGES ON heclinic.* TO 'heclinic'@'localhost';
FLUSH PRIVILEGES;
EOF

# --- Laravel .env ---
echo "[8/8] Creating Laravel .env..."
if [ ! -f /var/www/heclinic-laravel/.env ]; then
    cp /var/www/heclinic-laravel/.env.example /var/www/heclinic-laravel/.env
    php /var/www/heclinic-laravel/artisan key:generate
    echo "⚠️  Edit /var/www/heclinic-laravel/.env and set:"
    echo "    DB_PASSWORD=CHANGE_ME_DB_PASSWORD"
    echo "    PLATO_API_TOKEN=your_plato_token"
fi

# --- Bot .env ---
echo ""
echo "Creating bot env file..."
cat > /var/www/heclinic-bot/.env <<BOTEOF
TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN
GH_PAT=YOUR_GITHUB_PAT
GH_OWNER=YOUR_GITHUB_USERNAME
GH_REPO=heclinic_mobile-main
GH_WORKFLOW_ID=agent-director.yml
TELEGRAM_CHAT_ID=YOUR_TELEGRAM_CHAT_ID
PORT=3000
BOTEOF

# --- Restart Services ---
echo ""
echo "Restarting services..."
systemctl restart nginx
systemctl restart php8.3-fpm
systemctl enable nginx php8.3-fpm mysql

# --- Setup PM2 ---
cd /var/www/heclinic-bot
npm install
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup systemd -u root --hp /root || true

# --- Register Telegram Webhook ---
echo ""
echo "========================================="
echo "SETUP COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Edit /var/www/heclinic-laravel/.env → set DB_PASSWORD and PLATO_API_TOKEN"
echo "2. Edit /var/www/heclinic-bot/.env → set TELEGRAM_BOT_TOKEN, GH_PAT, GH_OWNER, TELEGRAM_CHAT_ID"
echo "3. Register Telegram webhook:"
echo "   curl -X POST https://api.telegram.org/bot<TOKEN>/setWebhook \\"
echo "     -d 'url=https://heclinic.cyberoket.cloud/bot/webhook'"
echo "4. Run PHP migrations:"
echo "   cd /var/www/heclinic-laravel && php artisan migrate"
echo "5. Trigger first workflow_dispatch from GitHub Actions UI"
echo ""
echo "⚠️  IMPORTANT: Change DB_PASSWORD 'CHANGE_ME_DB_PASSWORD' above!"
