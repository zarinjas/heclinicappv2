<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\McpAuditLog;
use App\Services\McpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;

/**
 * Minimal Model Context Protocol server using the Streamable HTTP transport.
 *
 * Clients (Claude Desktop via `mcp-remote`, Claude Code, etc.) POST JSON-RPC
 * 2.0 messages to /api/mcp and receive JSON responses. Server-initiated
 * streams (GET/SSE) are intentionally not offered, which the spec permits.
 */
class McpServerController extends Controller
{
    private const PROTOCOL_VERSIONS = ['2024-11-05', '2025-03-26', '2025-06-18'];

    private const LATEST_PROTOCOL = '2025-06-18';

    public function handle(Request $request, McpService $service): Response|JsonResponse
    {
        if (! $request->isMethod('post')) {
            return response()->json([
                'jsonrpc' => '2.0',
                'id' => null,
                'error' => ['code' => -32600, 'message' => 'Use POST for MCP requests. GET/SSE is not supported.'],
            ], 405)->header('Allow', 'POST');
        }

        $decoded = json_decode($request->getContent(), true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return $this->error(null, -32700, 'Parse error: body is not valid JSON.');
        }

        // JSON-RPC batch support (defensive — some clients still send arrays).
        if (is_array($decoded) && array_is_list($decoded)) {
            $responses = [];

            foreach ($decoded as $message) {
                if (! is_array($message)) {
                    $responses[] = $this->error(null, -32600, 'Invalid request.');

                    continue;
                }

                $response = $this->handleMessage($message, $service, $request);

                if ($response !== null) {
                    $responses[] = $response;
                }
            }

            return response()->json($responses);
        }

        if (! is_array($decoded)) {
            return $this->error(null, -32600, 'Invalid request.');
        }

        $response = $this->handleMessage($decoded, $service, $request);

        return $response ?? response('', 202);
    }

    /**
     * @param  array<string, mixed>  $message
     */
    private function handleMessage(array $message, McpService $service, Request $request): Response|JsonResponse|null
    {
        $id = $message['id'] ?? null;
        $method = $message['method'] ?? null;
        $params = is_array($message['params'] ?? null) ? $message['params'] : [];
        $isNotification = ! array_key_exists('id', $message);

        if (! is_string($method) || $method === '') {
            return $this->error($id, -32600, 'Invalid request: missing method.');
        }

        try {
            switch ($method) {
                case 'initialize':
                    $result = [
                        'protocolVersion' => $this->negotiateVersion($params['protocolVersion'] ?? null),
                        'capabilities' => ['tools' => ['listChanged' => false]],
                        'serverInfo' => [
                            'name' => 'he-clinic-admin',
                            'version' => '1.0.0',
                        ],
                        'instructions' => $this->instructions(),
                    ];
                    break;

                case 'notifications/initialized':
                case 'notifications/cancelled':
                    return null;

                case 'ping':
                case 'logging/setLevel':
                    $result = new \stdClass;
                    break;

                case 'tools/list':
                    $result = ['tools' => $service->tools()];
                    break;

                case 'tools/call':
                    $result = $this->callTool($service, $request, $params);
                    break;

                case 'resources/list':
                    $result = ['resources' => []];
                    break;

                case 'resources/templates/list':
                    $result = ['resourceTemplates' => []];
                    break;

                case 'prompts/list':
                    $result = ['prompts' => []];
                    break;

                default:
                    if ($isNotification) {
                        return null;
                    }

                    return $this->error($id, -32601, "Method not found: {$method}");
            }
        } catch (\Throwable $e) {
            Log::channel('plato')->error('MCP request failed', [
                'method' => $method,
                'error' => $e->getMessage(),
            ]);

            if ($isNotification) {
                return null;
            }

            return $this->error($id, -32603, 'Internal error: '.$e->getMessage());
        }

        if ($isNotification) {
            return null;
        }

        return response()->json([
            'jsonrpc' => '2.0',
            'id' => $id,
            'result' => $result,
        ]);
    }

    /**
     * @param  array<string, mixed>  $params
     * @return array<string, mixed>
     */
    private function callTool(McpService $service, Request $request, array $params): array
    {
        $name = (string) ($params['name'] ?? '');
        $arguments = is_array($params['arguments'] ?? null) ? $params['arguments'] : [];

        if ($name === '') {
            throw new \InvalidArgumentException('Missing tool name.');
        }

        try {
            $result = $service->call($name, $arguments);

            $this->audit($request, $name, $arguments, 'success', $this->summarize($result));

            return $result;
        } catch (\Throwable $e) {
            $this->audit($request, $name, $arguments, 'error', $e->getMessage());

            // Report tool failures to the model instead of breaking the session.
            return [
                'content' => [[
                    'type' => 'text',
                    'text' => 'Error: '.$e->getMessage(),
                ]],
                'isError' => true,
            ];
        }
    }

    private function negotiateVersion(mixed $requested): string
    {
        if (is_string($requested) && in_array($requested, self::PROTOCOL_VERSIONS, true)) {
            return $requested;
        }

        return self::LATEST_PROTOCOL;
    }

    private function instructions(): string
    {
        return implode(' ', [
            'You are connected to the He Clinic admin panel.',
            'Use these tools to answer admin questions about patients, registrations, campaigns, promotions and notifications.',
            'Contact details are masked; do not attempt to bypass that.',
            'WRITE tools (create_promotion, send_push_notification, send_campaign_notification) change real data or message real patients.',
            'Before calling any write tool you MUST show the user exactly what will happen (title, body, audience/campaign) and wait for explicit confirmation.',
        ]);
    }

    /**
     * @param  array<string, mixed>  $arguments
     */
    private function audit(Request $request, string $tool, array $arguments, string $status, string $summary): void
    {
        try {
            McpAuditLog::create([
                'tool' => $tool,
                'arguments' => $this->sanitizeArguments($arguments),
                'status' => $status,
                'summary' => mb_strimwidth($summary, 0, 1000, '…'),
                'ip' => $request->ip(),
            ]);
        } catch (\Throwable $e) {
            Log::channel('plato')->warning('Failed to write MCP audit log', ['error' => $e->getMessage()]);
        }
    }

    /**
     * @param  array<string, mixed>  $arguments
     * @return array<string, mixed>
     */
    private function sanitizeArguments(array $arguments): array
    {
        array_walk_recursive($arguments, function (&$value): void {
            if (is_string($value) && mb_strlen($value) > 500) {
                $value = mb_strimwidth($value, 0, 500, '…');
            }
        });

        return $arguments;
    }

    /**
     * @param  array<string, mixed>  $result
     */
    private function summarize(array $result): string
    {
        return (string) ($result['content'][0]['text'] ?? '');
    }

    private function error(mixed $id, int $code, string $message): JsonResponse
    {
        return response()->json([
            'jsonrpc' => '2.0',
            'id' => $id,
            'error' => ['code' => $code, 'message' => $message],
        ]);
    }
}
