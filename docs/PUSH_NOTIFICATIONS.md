# Push Notifications — Setup & Troubleshooting

## How it works now

```
Admin action (appointment / document / manual send)
  └─> NotificationService
        ├─ push   ─> FcmService ──> FCM HTTP v1 ──> device
        │            (>100 devices: queued via SendPushNotification job)
        ├─ in_app ─> patient_notifications table ──> GET /api/v2/notifications
        └─ email  ─> Resend
```

Device tokens are stored in `patients.fcm_token`. The app registers the token
via `POST /api/v2/auth/device-token` at login, at startup, and whenever FCM
rotates it.

> **Note on the old pipeline.** Push previously went Laravel → Firestore
> `ff_push_notifications` → Cloud Function → FCM. That chain was broken in
> several places at once (unauthenticated Firestore write, no matching security
> rule, and tokens read from `fcm/{patientId}` which nothing wrote to any more).
> Laravel now talks to FCM directly. The Firestore path remains only as a
> fallback when no service account is configured, and the Cloud Function is no
> longer required.

## Required setup

### 1. Create a service account key

1. Firebase Console → Project Settings → **Service accounts**
2. **Generate new private key** → downloads a JSON file
3. Upload it to the server **outside the app folder** and outside the web root.
   Do NOT put it inside `storage/app/` — the deploy workflow rsyncs with
   `--delete` from git, so any file not tracked in git gets wiped on deploy.

   On the production server (`hemedicalapps.com` / `72.62.251.208`) we use:
   `/home/hemedicalapps.com/.secrets/firebase-service-account.json`
4. Lock it down — it grants full send rights:
   ```bash
   chown hemed2668:hemed2668 firebase-service-account.json
   chmod 600 firebase-service-account.json
   ```
   Make sure it is **not** committed to git.

### 2. Point the app at it

In `.env`:

```env
FIREBASE_PROJECT_ID=heclinicapps-8be27
FIREBASE_SERVICE_ACCOUNT_PATH=/home/hemedicalapps.com/.secrets/firebase-service-account.json
```

A path without a leading `/` is resolved relative to the Laravel root.

Then:

```bash
php artisan config:clear
```

### 3. Run migrations

```bash
php artisan migrate
```

Adds `patient_notifications` (the in-app inbox) and delivery counters on
`notifications_log`. The deploy workflow runs this automatically.

### 4. Make sure the queue runs

Large sends are dispatched to the queue (`QUEUE_CONNECTION=database` by
default). Without a worker they will sit unprocessed:

```bash
php artisan queue:work --tries=3
```

On the production server this runs as a systemd service (`heclinic-queue`) as
user `hemed2668`, with auto-restart. The Laravel scheduler (appointment
reminders) runs via a per-minute cron for `hemed2668`.

### 5. iOS only — production APNs

`ios/Runner/Runner.entitlements` currently has:

```xml
<key>aps-environment</key>
<string>development</string>
```

This **must** be `production` for TestFlight and App Store builds, otherwise
notifications silently fail to deliver on release builds.

## Verify

```bash
php artisan push:diagnose
```

Checks the service account, confirms Google issues an access token, and reports
how many patients have a registered device token.

Send a real notification to one patient:

```bash
php artisan push:diagnose --patient=<idplato>
```

Expected output when healthy:

```
  [ OK ] Service account file found: /var/www/.../firebase-service-account.json
  [ OK ] Service account JSON is valid (client_email + private_key present)
  [ OK ] Google returned an OAuth access token — FCM is reachable
  [ OK ] Firebase project id: heclinicapps-8be27
  [ OK ] 42 of 130 patients have a device token registered
```

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `FIREBASE_SERVICE_ACCOUNT_PATH is not set` | Step 2 skipped | Set it, then `php artisan config:clear` |
| `Could not obtain an OAuth access token` | Key revoked, or server clock skewed | Regenerate the key; check `timedatectl` — JWT auth fails if the clock drifts |
| `0 of N patients have a device token` | No one has logged in on a build that includes `DeviceTokenService` | Log in on the new build, then re-run |
| Patient has no token | Never logged in since the update, or denied notification permission | Ask them to reopen the app and allow notifications |
| Push works on Android, not iOS release | `aps-environment` is `development` | Set it to `production` and rebuild |
| Admin shows "Sending" and it never changes | Queue worker not running | Start `php artisan queue:work` |
| Status shows `partial` | Some devices had stale tokens | Normal. Dead tokens are cleared automatically |

Detailed errors are logged to `storage/logs/plato-proxy.log`.

## Notification status values

| Status | Meaning |
|---|---|
| `sent` | Every targeted device accepted it |
| `partial` | Some succeeded, some failed |
| `sending` | Queued; jobs still processing |
| `failed` | Nothing was delivered |

Previously status was always written as `'sent'`, which hid the fact that
nothing was being delivered.
