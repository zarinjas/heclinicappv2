<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AppSettingsService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class SystemSettingsController extends Controller
{
    public function __construct(private readonly AppSettingsService $settings) {}

    public function index(): View
    {
        return view('admin.settings.system', [
            'settings' => [
                'app_url' => $this->settings->appUrl(),
                'firebase_project_id' => $this->settings->firebaseProjectId(),
                'firebase_web_api_key_configured' => $this->settings->firebaseWebApiKeyConfigured(),
                'mail_mailer' => $this->settings->mailMailer(),
                'mail_host' => $this->settings->mailHost(),
                'mail_port' => $this->settings->mailPort(),
                'mail_username' => $this->settings->mailUsername(),
                'mail_password_configured' => $this->settings->mailPasswordConfigured(),
                'mail_encryption' => $this->settings->mailEncryption(),
                'mail_from_address' => $this->settings->mailFromAddress(),
                'mail_from_name' => $this->settings->mailFromName(),
            ],
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'app_url' => ['nullable', 'url', 'max:255'],
            'firebase_project_id' => ['nullable', 'string', 'max:191'],
            'firebase_web_api_key' => ['nullable', 'string', 'max:500'],
            'mail_mailer' => ['required', 'in:smtp,log'],
            'mail_host' => ['nullable', 'string', 'max:255'],
            'mail_port' => ['nullable', 'integer', 'min:1', 'max:65535'],
            'mail_username' => ['nullable', 'string', 'max:255'],
            'mail_password' => ['nullable', 'string', 'max:500'],
            'mail_encryption' => ['nullable', 'in:tls,ssl,none'],
            'mail_from_address' => ['nullable', 'email', 'max:191'],
            'mail_from_name' => ['nullable', 'string', 'max:191'],
        ]);

        $this->settings->save($validated);

        $this->settings->applyToConfig();

        return redirect()
            ->route('admin.settings.system')
            ->with('success', 'System settings saved successfully.');
    }
}
