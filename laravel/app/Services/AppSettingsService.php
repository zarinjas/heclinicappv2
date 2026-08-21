<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

final class AppSettingsService
{
    private ?array $cache = null;

    public function all(): array
    {
        if ($this->cache !== null) {
            return $this->cache;
        }

        $this->cache = DB::table('settings')->pluck('value', 'key')->toArray();

        return $this->cache;
    }

    public function get(string $key, mixed $default = null): mixed
    {
        $all = $this->all();

        if (! array_key_exists($key, $all)) {
            return $default;
        }

        $value = $all[$key];

        return ($value === null || $value === '') ? $default : $value;
    }

    public function has(string $key): bool
    {
        $all = $this->all();

        return array_key_exists($key, $all) && $all[$key] !== null && $all[$key] !== '';
    }

    public function appUrl(): string
    {
        return rtrim((string) $this->get('app_url', config('app.url')), '/');
    }

    public function firebaseProjectId(): string
    {
        return (string) $this->get('firebase_project_id', config('firebase.project_id'));
    }

    public function firebaseWebApiKey(): string
    {
        return $this->decrypt($this->get('firebase_web_api_key'));
    }

    public function firebaseWebApiKeyConfigured(): bool
    {
        return $this->has('firebase_web_api_key');
    }

    public function firebaseServiceAccount(): string
    {
        return $this->decrypt($this->get('firebase_service_account'));
    }

    public function firebaseServiceAccountConfigured(): bool
    {
        return $this->has('firebase_service_account');
    }

    public function mailMailer(): string
    {
        return (string) $this->get('mail_mailer', config('mail.default'));
    }

    public function mailHost(): string
    {
        return (string) $this->get('mail_host', config('mail.mailers.smtp.host'));
    }

    public function mailPort(): int
    {
        return (int) $this->get('mail_port', config('mail.mailers.smtp.port'));
    }

    public function mailUsername(): string
    {
        return (string) $this->get('mail_username', config('mail.mailers.smtp.username'));
    }

    public function mailPassword(): string
    {
        return $this->decrypt($this->get('mail_password'));
    }

    public function mailPasswordConfigured(): bool
    {
        return $this->has('mail_password');
    }

    public function mailEncryption(): string
    {
        $value = (string) $this->get('mail_encryption', '');

        return $value === 'none' ? '' : $value;
    }

    public function mailFromAddress(): string
    {
        return (string) $this->get('mail_from_address', config('mail.from.address'));
    }

    public function mailFromName(): string
    {
        return (string) $this->get('mail_from_name', config('mail.from.name'));
    }

    /**
     * Override the in-memory config with database-backed settings so the whole
     * app (Firebase services, Mail system, storage URLs) uses the admin-configured
     * values without needing to edit .env.
     */
    public function applyToConfig(): void
    {
        try {
            if (! Schema::hasTable('settings')) {
                return;
            }

            $appUrl = $this->appUrl();
            if ($appUrl !== '') {
                config(['app.url' => $appUrl]);
                config(['filesystems.disks.public.url' => $appUrl.'/storage']);
            }

            $projectId = $this->firebaseProjectId();
            if ($projectId !== '') {
                config(['firebase.project_id' => $projectId]);
            }

            $webApiKey = $this->firebaseWebApiKey();
            if ($webApiKey !== '') {
                config(['firebase.web_api_key' => $webApiKey]);
            }

            $serviceAccount = $this->firebaseServiceAccount();
            if ($serviceAccount !== '') {
                config(['firebase.service_account' => $serviceAccount]);
            }

            config(['mail.default' => $this->mailMailer()]);
            config(['mail.mailers.smtp.host' => $this->mailHost()]);
            config(['mail.mailers.smtp.port' => $this->mailPort()]);
            config(['mail.mailers.smtp.username' => $this->mailUsername()]);
            config(['mail.mailers.smtp.password' => $this->mailPassword()]);

            $encryption = $this->mailEncryption();
            config(['mail.mailers.smtp.encryption' => $encryption === '' ? null : $encryption]);

            $fromAddress = $this->mailFromAddress();
            if ($fromAddress !== '') {
                config(['mail.from.address' => $fromAddress]);
            }
            config(['mail.from.name' => $this->mailFromName()]);
        } catch (\Throwable $e) {
            Log::channel('plato')->warning('AppSettingsService::applyToConfig failed', [
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Persist system settings to the database. Secret fields are encrypted and
     * left blank keeps the existing stored value.
     */
    public function save(array $values): void
    {
        $nonSecret = [
            'app_url', 'firebase_project_id', 'mail_mailer', 'mail_host',
            'mail_port', 'mail_username', 'mail_encryption',
            'mail_from_address', 'mail_from_name',
        ];

        foreach ($nonSecret as $key) {
            if (! array_key_exists($key, $values)) {
                continue;
            }

            $value = $values[$key];

            if ($key === 'mail_encryption' && $value === 'none') {
                $value = '';
            }

            Setting::updateOrCreate(
                ['key' => $key],
                ['value' => $value === null ? '' : (string) $value, 'description' => 'System setting: '.$key]
            );
        }

        foreach (['firebase_web_api_key', 'firebase_service_account', 'mail_password'] as $secretKey) {
            if (empty($values[$secretKey] ?? '')) {
                continue;
            }

            Setting::updateOrCreate(
                ['key' => $secretKey],
                ['value' => Crypt::encryptString($values[$secretKey]), 'description' => 'System setting (encrypted): '.$secretKey]
            );
        }

        $this->cache = null;
    }

    private function decrypt(?string $value): string
    {
        if ($value === null || $value === '') {
            return '';
        }

        try {
            return Crypt::decryptString($value);
        } catch (\Throwable $e) {
            return $value;
        }
    }
}
