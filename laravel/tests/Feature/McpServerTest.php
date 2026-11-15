<?php

namespace Tests\Feature;

use App\Models\Patient;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Crypt;
use Tests\TestCase;

class McpServerTest extends TestCase
{
    use RefreshDatabase;

    private function enableMcp(): string
    {
        $token = 'hecl_'.str_repeat('a', 48);

        Setting::create(['key' => 'mcp_enabled', 'value' => '1']);
        Setting::create(['key' => 'mcp_token', 'value' => Crypt::encryptString($token)]);

        return $token;
    }

    private function rpc(string $token, array $payload)
    {
        return $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/mcp', $payload);
    }

    public function test_endpoint_requires_a_token(): void
    {
        Setting::create(['key' => 'mcp_enabled', 'value' => '1']);

        $this->postJson('/api/mcp', ['jsonrpc' => '2.0', 'id' => 1, 'method' => 'tools/list'])
            ->assertStatus(401);
    }

    public function test_endpoint_is_unavailable_when_disabled(): void
    {
        Setting::create(['key' => 'mcp_enabled', 'value' => '0']);
        Setting::create(['key' => 'mcp_token', 'value' => Crypt::encryptString('hecl_test')]);

        $this->withHeader('Authorization', 'Bearer hecl_test')
            ->postJson('/api/mcp', ['jsonrpc' => '2.0', 'id' => 1, 'method' => 'tools/list'])
            ->assertStatus(503);
    }

    public function test_initialize_returns_server_info(): void
    {
        $token = $this->enableMcp();

        $this->rpc($token, [
            'jsonrpc' => '2.0',
            'id' => 1,
            'method' => 'initialize',
            'params' => ['protocolVersion' => '2025-06-18'],
        ])
            ->assertOk()
            ->assertJsonPath('result.serverInfo.name', 'he-clinic-admin')
            ->assertJsonPath('result.protocolVersion', '2025-06-18');
    }

    public function test_tools_list_returns_tools(): void
    {
        $token = $this->enableMcp();

        $response = $this->rpc($token, ['jsonrpc' => '2.0', 'id' => 2, 'method' => 'tools/list']);

        $response->assertOk();
        $names = array_column($response->json('result.tools'), 'name');
        $this->assertContains('send_campaign_notification', $names);
        $this->assertContains('list_registrations', $names);
    }

    public function test_initialized_notification_returns_202(): void
    {
        $token = $this->enableMcp();

        $this->rpc($token, ['jsonrpc' => '2.0', 'method' => 'notifications/initialized'])
            ->assertStatus(202);
    }

    public function test_get_dashboard_stats_tool_runs(): void
    {
        $token = $this->enableMcp();
        Patient::create(['name' => 'Ali', 'telephone' => '60123456789', 'password' => bcrypt('secret123')]);

        $response = $this->rpc($token, [
            'jsonrpc' => '2.0',
            'id' => 3,
            'method' => 'tools/call',
            'params' => ['name' => 'get_dashboard_stats', 'arguments' => new \stdClass],
        ]);

        $response->assertOk()->assertJsonPath('result.isError', false);
        $this->assertStringContainsString('patients', $response->json('result.content.0.text'));
    }

    public function test_create_promotion_tool_creates_row_and_audit_log(): void
    {
        $token = $this->enableMcp();

        $response = $this->rpc($token, [
            'jsonrpc' => '2.0',
            'id' => 4,
            'method' => 'tools/call',
            'params' => [
                'name' => 'create_promotion',
                'arguments' => ['title' => 'Diskaun 20%', 'description' => 'Promo test'],
            ],
        ]);

        $response->assertOk()->assertJsonPath('result.isError', false);
        $this->assertDatabaseHas('cms_promotions', ['title' => 'Diskaun 20%']);
        $this->assertDatabaseHas('mcp_audit_logs', ['tool' => 'create_promotion', 'status' => 'success']);
    }

    public function test_list_registrations_filters_by_campaign(): void
    {
        $token = $this->enableMcp();

        Patient::create(['name' => 'Siti', 'telephone' => '60111111111', 'password' => bcrypt('secret123'), 'referred_by' => 'instagram_july']);
        Patient::create(['name' => 'Ahmad', 'telephone' => '60122222222', 'password' => bcrypt('secret123'), 'referred_by' => 'tiktok_raya']);

        $response = $this->rpc($token, [
            'jsonrpc' => '2.0',
            'id' => 5,
            'method' => 'tools/call',
            'params' => ['name' => 'list_registrations', 'arguments' => ['campaign' => 'instagram_july']],
        ]);

        $response->assertOk();
        $text = $response->json('result.content.0.text');
        $this->assertStringContainsString('Siti', $text);
        $this->assertStringNotContainsString('Ahmad', $text);
    }

    public function test_admin_mcp_page_renders_for_super_admin(): void
    {
        $this->enableMcp();

        $admin = new User([
            'name' => 'Admin',
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
            'role' => User::ROLE_SUPER_ADMIN,
        ]);
        $admin->save();

        $this->actingAs($admin)
            ->get('/admin/mcp')
            ->assertOk()
            ->assertSee('Claude / MCP')
            ->assertSee('/api/mcp');
    }

    public function test_admin_mcp_page_forbidden_for_staff(): void
    {
        $staff = new User([
            'name' => 'Staff',
            'email' => 'staff@example.com',
            'password' => bcrypt('password'),
            'role' => User::ROLE_STAFF,
        ]);
        $staff->save();

        $this->actingAs($staff)
            ->get('/admin/mcp')
            ->assertForbidden();
    }

    public function test_unknown_tool_returns_tool_error(): void
    {
        $token = $this->enableMcp();

        $this->rpc($token, [
            'jsonrpc' => '2.0',
            'id' => 6,
            'method' => 'tools/call',
            'params' => ['name' => 'does_not_exist', 'arguments' => new \stdClass],
        ])
            ->assertOk()
            ->assertJsonPath('result.isError', true);
    }
}
