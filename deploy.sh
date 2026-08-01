#!/usr/bin/env bash
#
# Auto-commit + push ke develop, lepas tu GitHub Actions auto-deploy
# ke hemedicalapps.com (VPS). Guna macam ni:
#
#   ./deploy.sh "mesej commit awak"
#
set -e

if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh \"commit message\""
    exit 1
fi

git add -A
git commit -m "$1"
git push origin develop
