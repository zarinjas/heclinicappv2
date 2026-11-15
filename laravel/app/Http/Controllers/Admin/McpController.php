<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\McpAuditLog;
use App\Models\Setting;
use App\Services\McpService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Str;
use Illuminate\View\View;

/**
 * Admin page that turns the MCP integration on/off, shows the bearer token and
 * walks a non-technical admin through connecting Claude Desktop / Claude Code.
 */
class McpController extends Controller
{
    public function __construct(private readonly McpService $service) {}

    public function index(): View
    {
        $settings = Setting::pluck('value', 'key');

        $token = $this->decryptToken($settings['mcp_token'] ?? null);
        $appUrl = rtrim((string) ($settings['app_url'] ?? config('app.url')), '/');

        return view('admin.mcp.index', [
            'enabled' => ($settings['mcp_enabled'] ?? '0') === '1',
            'token' => $token,
            'endpoint' => $appUrl.'/api/mcp',
            'generatedAt' => $settings['mcp_token_generated_at'] ?? null,
            'lastUsedAt' => $settings['mcp_last_used_at'] ?? null,
            'tools' => $this->service->tools(),
            'logs' => McpAuditLog::query()->latest()->limit(20)->get(),
            'writeTools' => ['create_promotion', 'send_push_notification', 'send_campaign_notification'],
        ]);
    }

    public function toggle(Request $request): RedirectResponse
    {
        $enable = $request->boolean('enable');

        if ($enable && Setting::where('key', 'mcp_token')->doesntExist()) {
            $this->generateToken();
        }

        Setting::updateOrCreate(
            ['key' => 'mcp_enabled'],
            ['value' => $enable ? '1' : '0', 'description' => 'MCP access enabled'],
        );

        return back()->with('success', $enable
            ? 'MCP access enabled. Claude can now connect using the URL and token below.'
            : 'MCP access disabled. Claude can no longer connect.');
    }

    public function regenerate(): RedirectResponse
    {
        $this->generateToken();

        Setting::updateOrCreate(
            ['key' => 'mcp_enabled'],
            ['value' => '1', 'description' => 'MCP access enabled'],
        );

        return back()->with('success', 'New MCP token generated. Copy the new token into your Claude config — the old one no longer works.');
    }

    private function generateToken(): void
    {
        $token = 'hecl_'.Str::random(48);

        Setting::updateOrCreate(
            ['key' => 'mcp_token'],
            ['value' => Crypt::encryptString($token), 'description' => 'MCP bearer token (encrypted)'],
        );

        Setting::updateOrCreate(
            ['key' => 'mcp_token_generated_at'],
            ['value' => now()->toDateTimeString(), 'description' => 'MCP token generated at'],
        );
    }

    private function decryptToken(?string $encrypted): string
    {
        if (! is_string($encrypted) || $encrypted === '') {
            return '';
        }

        try {
            return Crypt::decryptString($encrypted);
        } catch (\Throwable) {
            return '';
        }
    }
}
