# Deployment — hemedicalapps.com (Laravel)

Dokumen ini "mengunci" proses deploy supaya tak berlaku masalah di kemudian hari.
Ikut setting yang dinyatakan di bawah secara tepat — beberapa isu sebelum ni berpunca
dari nilai secret yang tak konsisten dengan server sebenar.

## 1. Server

| Item | Nilai |
|---|---|
| IP / SSH host | `72.62.251.208` |
| Hostname | `mail.cyberocket.my` |
| Panel | CyberPanel (LiteSpeed), OS AlmaLinux 9 |
| Path app Laravel | `/home/hemedicalapps.com/heclinic-laravel` |
| User pemilik domain | `hemed2668` (uid 5010) |
| SSH user deploy | `root` |
| SSH port | `22` sahaja |
| Deploy key (public) | `github-actions-deploy` di dalam `/root/.ssh/authorized_keys` |

> ⚠️ **PENTING — Cloudflare:** domain `hemedicalapps.com` berada di belakang
> Cloudflare (resolve ke `104.21.x` / `172.67.x`). Cloudflare **tidak forward SSH**.
> SSH **mesti** guna origin IP (`72.62.251.208`), bukan nama domain.
> Ini punca utama masaalah "Connection timed out" sebelum ni.

## 2. GitHub Actions Secrets

Set dalam **repo → Settings → Secrets and variables → Actions**:

| Secret | Nilai | Nota |
|---|---|---|
| `HOST` | `72.62.251.208` | Origin IP. **JANGAN** guna `hemedicalapps.com` (Cloudflare). |
| `PORT` | `22` | Port sshd server. |
| `USERNAME` | `root` | Mesti padan dengan authorized_keys tempat deploy key diletak. |
| `SSH_KEY` | (private key) | Public key kena ada dalam `/root/.ssh/authorized_keys` untuk user di atas. |
| `GH_PAT` | (Personal Access Token) | Digunakan oleh workflow lain / bot. |

Cara update:
```bash
gh secret set HOST     --repo zarinjas/heclinicappv2 --body "72.62.251.208"
gh secret set PORT     --repo zarinjas/heclinicappv2 --body "22"
gh secret set USERNAME --repo zarinjas/heclinicappv2 --body "root"
```

## 3. Bila Deploy Berlaku

Workflow `deploy-hemedicalapps.yml` (`.github/workflows/`) trigger bila:

1. **Manual** — `workflow_dispatch` (butang "Run workflow" di GitHub Actions).
2. **Push ke `develop`** yang menyentuh:
   - `laravel/**`
   - `.github/workflows/deploy-hemedicalapps.yml`

Script tempatan untuk commit + push semua perubahan (termasuk trigger auto-deploy):
```bash
./deploy.sh "mesej commit awak"
```

Deploy manual tanpa commit baru:
```bash
gh workflow run deploy-hemedicalapps.yml --repo zarinjas/heclinicappv2 --ref develop
```

## 4. Aliran Deploy

1. `actions/checkout@v5` — checkout repo
2. Install `rsync`
3. Setup SSH (tulis `SSH_KEY` ke `~/.ssh/deploy_key`)
4. **Check SSH reachability** — fail-fast jika host/port tak boleh dicapai dari runner
5. `rsync -avz --delete` — sync `laravel/` ke server (exclude `.env`, `vendor`, cache)
6. Post-deploy (via ssh + heredoc):
   - `composer install --no-dev`
   - `php artisan migrate --force` (kegagalan tak menggagalkan deploy)
   - `php artisan storage:link`
   - `php artisan optimize:clear`
   - chown semula ke `hemed2668:hemed2668`

## 5. Troubleshooting

**"ssh: connect to host ... port ...: Connection timed out"**
- Step "Check SSH reachability" akan tunjuk `UNREACHABLE`. Sebab biasa:
  - `HOST` secret guna domain Cloudflare → mesti tukar ke `72.62.251.208`.
  - Server down / firewall block. Test dari laptop:
    ```bash
    nc -zv 72.62.251.208 22
    ssh -i ~/.ssh/<key> root@72.62.251.208 "echo OK"
    ```

**"Permission denied (publickey)"**
- Public key bagi `SSH_KEY` tak ada dalam `authorized_keys` user yang betul.
- Semak di server:
  ```bash
  grep -c "github-actions-deploy" /root/.ssh/authorized_keys
  ```

**"No such file or directory" semasa post-deploy**
- Pastikan `APP_DIR=/home/hemedicalapps.com/heclinic-laravel` betul dan wujud.
- Deploy key mesti ada akses untuk tulis ke path tersebut.

**Migration tak jalan**
- `php artisan migrate --force` sengaja `|| true` supaya deploy tak tersekat.
- Jika ada migration baharu yang tertinggal, run manual:
  ```bash
  ssh root@72.62.251.208 "cd /home/hemedicalapps.com/heclinic-laravel && php artisan migrate --force"
  ```

## 6. Verifikasi Selepas Deploy

```bash
# API service packages (patut return JSON, bukan error)
curl -s https://hemedicalapps.com/api/v2/cms/service-packages

# Migration status di server
ssh root@72.62.251.208 "cd /home/hemedicalapps.com/heclinic-laravel && php artisan migrate:status"
```

## 7. Nota Teknikal (kenapa struktur macam ni)

- **Heredoc + `bash -s`** untuk post-deploy (bukan satu baris dengan `&&`):
  baris `&&` panjang dulu pernah ter-mangle oleh runner (exit 127).
  Sekarang setiap command atas baris sendiri, lebih robust.
- **`ssh-keyscan ... || true`** + **`StrictHostKeyChecking=accept-new`**:
  tak perlu keyscan betul-betul berjaya untuk deploy jalan.
- **`actions/checkout@v5`**: guna Node 24, elak warning deprecation Node 20.
- **`concurrency` group**: deploy tak bertindih antara satu sama lain.
