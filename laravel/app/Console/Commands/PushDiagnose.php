<?php

namespace App\Console\Commands;

use App\Models\Patient;
use App\Services\FcmService;
use Illuminate\Console\Command;

/**
 * Verifies every link in the push notification chain and, optionally, sends a
 * real test push. Run this after configuring the Firebase service account:
 *
 *   php artisan push:diagnose
 *   php artisan push:diagnose --patient=<idplato>
 */
class PushDiagnose extends Command
{
    protected $signature = 'push:diagnose
                            {--patient= : Plato patient id to send a real test push to}
                            {--title=Test Notification : Title for the test push}
                            {--body=If you can read this, push notifications are working. : Body for the test push}';

    protected $description = 'Check the push notification setup and optionally send a test push.';

    public function handle(FcmService $fcm): int
    {
        $this->info('Push notification diagnostics');
        $this->newLine();

        $ok = true;

        // 1. Service account -------------------------------------------------
        $path = (string) config('firebase.service_account_path');
        $stored = (string) config('firebase.service_account', '');

        if ($stored === '' && $path === '') {
            $this->line('  [FAIL] No Firebase service account configured.');
            $this->line('         Paste the service account JSON in Admin → System Settings → Firebase,');
            $this->line('         or set FIREBASE_SERVICE_ACCOUNT_PATH in .env (file must survive deploys).');
            $ok = false;
        } elseif ($stored !== '') {
            try {
                $decoded = json_decode($stored, true, 512, JSON_THROW_ON_ERROR);
                if (is_array($decoded) && ! empty($decoded['client_email']) && ! empty($decoded['private_key'])) {
                    $this->line('  [ OK ] Service account JSON from admin settings is valid');
                } else {
                    $this->line('  [FAIL] Service account JSON in admin settings is missing client_email or private_key.');
                    $ok = false;
                }
            } catch (\JsonException $e) {
                $this->line('  [FAIL] Service account JSON in admin settings is not valid JSON.');
                $ok = false;
            }
        } else {
            $resolved = str_starts_with($path, '/') ? $path : base_path($path);

            if (! is_readable($resolved)) {
                $this->line("  [FAIL] Service account file not readable: {$resolved}");
                $ok = false;
            } else {
                $this->line("  [ OK ] Service account file found: {$resolved}");
            }
        }

        // 2. Credential parses and can mint an access token -------------------
        if ($fcm->isConfigured()) {
            $this->line('  [ OK ] Service account JSON is valid (client_email + private_key present)');

            if ($fcm->verifyCredentials()) {
                $this->line('  [ OK ] Google returned an OAuth access token — FCM is reachable');
            } else {
                $this->line('  [FAIL] Could not obtain an OAuth access token from Google.');
                $this->line('         Check the key is not revoked and the server clock is correct.');
                $this->line('         See storage/logs/plato-proxy.log for the exact error.');
                $ok = false;
            }
        } else {
            $this->line('  [FAIL] Service account is not usable — see above.');
            $ok = false;
        }

        // 3. Project id ------------------------------------------------------
        $projectId = (string) config('firebase.project_id');
        $this->line($projectId !== ''
            ? "  [ OK ] Firebase project id: {$projectId}"
            : '  [FAIL] FIREBASE_PROJECT_ID is not set');

        // 4. Registered devices ----------------------------------------------
        $withToken = Patient::whereNotNull('fcm_token')->where('fcm_token', '!=', '')->count();
        $total = Patient::count();

        if ($withToken === 0) {
            $this->line("  [WARN] 0 of {$total} patients have a device token registered.");
            $this->line('         Tokens are stored when the app calls POST /v2/auth/device-token.');
            $this->line('         Log in on a device running the latest build, then re-run this.');
        } else {
            $this->line("  [ OK ] {$withToken} of {$total} patients have a device token registered");
        }

        $this->newLine();

        // 5. Optional real send ----------------------------------------------
        $patientId = $this->option('patient');

        if ($patientId === null) {
            $this->line('Tip: send a real test push with --patient=<idplato>');

            return $ok ? self::SUCCESS : self::FAILURE;
        }

        $patient = Patient::where('idplato', $patientId)->first();

        if ($patient === null) {
            $this->error("No patient found with idplato = {$patientId}");

            return self::FAILURE;
        }

        if (empty($patient->fcm_token)) {
            $this->error("Patient {$patientId} ({$patient->name}) has no device token registered.");
            $this->line('The patient must log in on the app at least once on the latest build.');

            return self::FAILURE;
        }

        $this->info("Sending test push to {$patient->name} ({$patientId})...");

        $result = $fcm->sendToTokens(
            [$patient->fcm_token],
            (string) $this->option('title'),
            (string) $this->option('body'),
            ['initialPageName' => 'notificationPage', 'type' => 'manual', 'parameterData' => ''],
        );

        if (($result['success'] ?? 0) > 0) {
            $this->info('Sent. The device should show the notification within a few seconds.');

            return self::SUCCESS;
        }

        $this->error('Send failed: '.($result['error'] ?? 'unknown error'));

        if (! empty($result['invalid_tokens'])) {
            $this->line('The stored token was rejected as invalid and has been cleared.');
            $this->line('Ask the patient to reopen the app to register a fresh token.');
            Patient::whereIn('fcm_token', $result['invalid_tokens'])->update(['fcm_token' => null]);
        }

        $this->line('See storage/logs/plato-proxy.log for details.');

        return self::FAILURE;
    }
}
