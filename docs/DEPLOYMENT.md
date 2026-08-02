# Deployment — hemedicalapps.com (Laravel)

Dokumen ini "mengunci" proses deploy supaya tak berlaku masalah di kemudian hari.
Deploy guna **self-hosted GitHub runner** yang dipasang pada server sendiri —
tidak perlu SSH dari GitHub langsung.

## 1. Server

| Item | Nilai |
|---|---|
| IP | `72.62.251.208` |
| Hostname | `mail.cyberocket.my` |
| Panel | CyberPanel (LiteSpeed), OS AlmaLinux 9, HostGator Cloud |
| Path app Laravel | `/home/hemedicalapps.com/heclinic-laravel` |
| User pemilik domain | `hemed2668` (uid 5010) |
| Runner user | `github-runner` (uid 5021) |
| Runner dir | `/opt/actions-runner` (bukan `/home` — `/home` tak boleh list) |
| Runner nama | `heclinic-deploy-runner` |

> ⚠️ **Cloudflare:** domain `hemedicalapps.com` berada di belakang Cloudflare
> (resolve ke `104.21.x`/`172.67.x`). Ia hanya untuk web (80/443), **bukan SSH**.
> Punca asal "Connection timed out" sebelum ni: `HOST` secret guna domain
> Cloudflare. **Kini tidak lagi berkaitan** — deploy tak guna SSH.

## 2. Kenapa Self-Hosted Runner

Hosting provider (HostGator) **block IP GitHub Actions (Azure) pada SSH secara
intermitten** — sesetengah runner boleh connect, yang lain timeout. Ini tak
boleh diperbaiki dari workflow atau server (fail2ban, ufw, iptables semua bersih).

Penyelesaian: **runner berjalan dalam server sendiri** (`heclinic-deploy-runner`).
GitHub hantar job ke runner melalui sambungan **keluar** (server → github.com,
yang memang berfungsi). Deploy dibuat dengan rsync tempatan + artisan — tak ada
SSH dari Azure langsung, jadi imun terhadap block IP.

## 3. Setup Runner (rujukan — sudah siap)

```bash
# sekali sahaja di server (root)
useradd -m -s /bin/bash github-runner
mkdir -p /opt/actions-runner
curl -fsSL -o /opt/actions-runner/actions-runner-linux-x64-2.336.0.tar.gz \
  https://github.com/actions/runner/releases/download/v2.336.0/actions-runner-linux-x64-2.336.0.tar.gz
cd /opt/actions-runner && tar xzf actions-runner-linux-x64-2.336.0.tar.gz
chown -R github-runner:github-runner /opt/actions-runner
./bin/installdependencies.sh          # dnf install pakej keperluan
# daftar (token dari: gh api repos/<owner>/<repo>/actions/runners/registration-token -X POST)
sudo -u github-runner ./config.sh --url https://github.com/zarinjas/heclinicappv2 \
  --token <TOKEN> --name heclinic-deploy-runner --labels self-hosted --work _work --unattended
# sudoers
echo 'github-runner ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/github-runner
chmod 440 /etc/sudoers.d/github-runner
# service
./svc.sh install github-runner && ./svc.sh start
```

Semak status:
```bash
systemctl status actions.runner.zarinjas-heclinicappv2.heclinic-deploy-runner.service
# online?:
gh api repos/zarinjas/heclinicappv2/actions/runners --jq '.runners[]|{name,status}'
```

## 4. GitHub Actions Secrets

Workflow sekarang **tidak lagi guna** `HOST`, `PORT`, `USERNAME`, `SSH_KEY`.
Boleh dibiarkan atau dipadam (`gh secret delete <NAME> --repo zarinjas/heclinicappv2`).
Yang masih dipakai oleh workflow lain: `GH_PAT`, `TELEGRAM_BOT_TOKEN`, `OPENAI_API_KEY`.

## 5. Bila Deploy Berlaku

Workflow `deploy-hemedicalapps.yml` trigger bila:

1. **Manual** — `workflow_dispatch` (butang "Run workflow").
2. **Push ke `develop`** menyentuh:
   - `laravel/**`
   - `.github/workflows/deploy-hemedicalapps.yml`

```bash
./deploy.sh "mesej commit awak"          # commit + push semua (trigger auto-deploy)
gh workflow run deploy-hemedicalapps.yml --repo zarinjas/heclinicappv2 --ref develop   # deploy manual
```

## 6. Aliran Deploy (semua dalam server)

1. `actions/checkout@v5` — checkout `develop` ke `/opt/actions-runner/_work/...`
2. **Deploy Laravel (local)**:
   - `sudo rsync -a --delete $GITHUB_WORKSPACE/laravel/ → /home/hemedicalapps.com/heclinic-laravel/`
     (exclude `.env`, `vendor`, `node_modules`, cache, `public/build`)
   - `sudo chown -R hemed2668:hemed2668` app dir
   - `sudo -u hemed2668 composer install --no-dev --optimize-autoloader`
   - `sudo -u hemed2668 php artisan migrate --force` (`|| true` — tak menyekat deploy)
   - `sudo -u hemed2668 php artisan storage:link`
   - `sudo -u hemed2668 php artisan optimize:clear`
   - chown semula `storage bootstrap/cache public/storage`

## 7. Troubleshooting

**Runner tak online**
```bash
systemctl status actions.runner.zarinjas-heclinicappv2.heclinic-deploy-runner.service
journalctl -u actions.runner.zarinjas-heclinicappv2.heclinic-deploy-runner.service -n 50
```
Server mesti boleh keluar ke `github.com` (runner long-poll). Semak: `curl -sI https://github.com`.

**Deploy gagal pada rsync / permission**
- Pastikan `/home` tak menyekat: runner guna `/opt/actions-runner` (bukan `/home`).
- Pastikan `github-runner` ada NOPASSWD sudo (`/etc/sudoers.d/github-runner`).
- Semak pengguna PHP site ialah `hemed2668`: `ps aux | grep lsphp`.

**Deploy tak trigger**
- Push mesti sentuh `laravel/**` ATAU fail workflow.
- Check di GitHub → Actions → Deploy Laravel to hemedicalapps.com.

**Migration tak jalan**
- `php artisan migrate --force` sengaja `|| true`. Jika tertinggal, run manual:
  ```bash
  ssh root@72.62.251.208 "cd /home/hemedicalapps.com/heclinic-laravel && php artisan migrate --force"
  ```

## 8. Verifikasi Selepas Deploy

```bash
curl -s https://hemedicalapps.com/api/v2/cms/service-packages   # patut return JSON
ssh root@72.62.251.208 "cd /home/hemedicalapps.com/heclinic-laravel && php artisan migrate:status"
```

## 9. Nota Teknikal

- **`runs-on: self-hosted`** — job dihantar ke runner dalam server; label `self-hosted`
  diberi automatik semasa config.
- **Heredoc/`&&` tidak lagi relevan** — tiada SSH. Setiap command dalam satu step `run`.
- **`actions/checkout@v5`** — guna Node 24, tiada warning deprecation.
- **`concurrency` group** — deploy tak bertindih.
- Semua secret SSH lama boleh dipadam; tiada kesan pada deploy.
