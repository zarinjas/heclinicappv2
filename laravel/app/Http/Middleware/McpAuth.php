<?php

namespace App\Http\Middleware;

use App\Models\Setting;
use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Symfony\Component\HttpFoundation\Response;

/**
 * Authenticates MCP (`/api/mcp`) requests with a bearer token generated in the
 * admin panel. The token is stored encrypted in `settings` and can be rotated
 * or disabled at any time.
 */
class McpAuth
{
    public function handle(Request $request, Closure $next): Response
    {
        if (Setting::where('key', 'mcp_enabled')->value('value') !== '1') {
            return $this->error('MCP access is disabled. Enable it from the admin MCP page.', -32000, 503);
        }

        $stored = Setting::where('key', 'mcp_token')->value('value');

        if (! is_string($stored) || $stored === '') {
            return $this->error('No MCP token has been generated yet.', -32001, 401);
        }

        try {
            $expected = Crypt::decryptString($stored);
        } catch (\Throwable) {
            return $this->error('MCP token could not be read. Regenerate it in the admin panel.', -32001, 401);
        }

        $provided = $request->bearerToken() ?: $request->header('X-Mcp-Token');

        if (! is_string($provided) || $provided === '' || ! hash_equals($expected, $provided)) {
            return $this->error('Invalid or missing MCP token.', -32001, 401);
        }

        // Visible on the admin page so the client can confirm Claude connected.
        Setting::updateOrCreate(
            ['key' => 'mcp_last_used_at'],
            ['value' => now()->toDateTimeString(), 'description' => 'Last MCP request received'],
        );

        return $next($request);
    }

    private function error(string $message, int $code, int $status): JsonResponse
    {
        return response()->json([
            'jsonrpc' => '2.0',
            'id' => null,
            'error' => ['code' => $code, 'message' => $message],
        ], $status)->header('WWW-Authenticate', 'Bearer');
    }
}
