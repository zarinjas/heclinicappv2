#!/usr/bin/env bash
#
# Auto-commit + push semua perubahan (Flutter + Laravel) ke develop.
# GitHub Actions auto-deploy ke hemedicalapps.com bila ada perubahan laravel/**.
#
# Guna macam ni:
#
#   ./deploy.sh "mesej commit awak"
#
set -e

if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh \"commit message\""
    exit 1
fi

# Tunjukkan status perubahan sebelum stage
echo "=== Git status ==="
git status --short

# Kira berapa banyak fail yang berubah
CHANGED=$(git status --porcelain | wc -l | tr -d ' ')

if [ "$CHANGED" -eq 0 ]; then
    echo ""
    echo "Tiada perubahan untuk di-commit."
    exit 0
fi

echo ""
echo "=== Stage semua perubahan ==="
git add -A

echo "=== Commit ==="
git commit -m "$1"

echo "=== Push ke develop (trigger auto-deploy) ==="
git push origin develop

echo ""
echo "Done! Deploy status: https://github.com/zarinjas/heclinicappv2/actions"
