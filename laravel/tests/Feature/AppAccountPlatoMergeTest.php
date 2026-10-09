<?php

namespace Tests\Feature;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class AppAccountPlatoMergeTest extends TestCase
{
    use RefreshDatabase;

    private const PHRASE = 'I understand that this action cannot be undone';

    private const SEARCH_ROWS = [
        ['_id' => 'PLATO-A', 'name' => 'A', 'nric' => '900101010001', 'created_on' => '2024-01-01'],
        ['_id' => 'PLATO-B', 'name' => 'B', 'nric' => '900101010001', 'created_on' => '2025-01-01'],
    ];

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'plato.base_url' => 'https://plato.test/api/db',
            'plato.merge.enabled' => true,
        ]);
        Cache::flush();
    }

    private function makeAdmin(): User
    {
        return User::create([
            'name' => 'Admin',
            'email' => 'admin-'.uniqid().'@example.com',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
        ]);
    }

    private function makeAccount(string $idplato = 'PLATO-A'): Patient
    {
        return Patient::create([
            'name' => 'Hafiz',
            'nric' => '900101010001',
            'telephone' => '601111110001',
            'email' => 'p'.mt_rand().'@example.com',
            'idplato' => $idplato,
            'password' => Hash::make('secret123'),
        ]);
    }

    private function fakePlato(array $mergeResponse = ['status' => true]): void
    {
        Http::fake([
            'https://plato.test/api/db/search/patient*' => Http::response(self::SEARCH_ROWS, 200),
            'https://plato.test/api/db/patient/merge*' => Http::response($mergeResponse, 200),
        ]);
    }

    public function test_show_renders_merge_panel_with_two_records(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makeAccount('PLATO-A');
        $this->fakePlato();

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]))
            ->assertOk()
            ->assertSee('Merge Plato records')
            ->assertSee('Merge in (record to remove)');
    }

    public function test_merge_calls_plato_and_relinks_to_survivor(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makeAccount('PLATO-A');
        $this->fakePlato();

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge-plato', $account), [
                'survivor_id' => 'PLATO-B',
                'merged_id' => 'PLATO-A',
                'acknowledge' => self::PHRASE,
            ])
            ->assertRedirect(route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]))
            ->assertSessionHas('success');

        Http::assertSent(function ($request) {
            return str_contains($request->url(), '/patient/merge')
                && $request['primary_id'] === 'PLATO-B'
                && $request['secondary_id'] === 'PLATO-A'
                && $request['acknowledge'] === self::PHRASE;
        });

        $this->assertSame('PLATO-B', $account->fresh()->idplato);
    }

    public function test_merge_is_blocked_when_disabled(): void
    {
        config(['plato.merge.enabled' => false]);

        $admin = $this->makeAdmin();
        $account = $this->makeAccount('PLATO-A');

        Http::fake();

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge-plato', $account), [
                'survivor_id' => 'PLATO-B',
                'merged_id' => 'PLATO-A',
                'acknowledge' => self::PHRASE,
            ])
            ->assertSessionHas('error');

        Http::assertNothingSent();
        $this->assertSame('PLATO-A', $account->fresh()->idplato);
    }

    public function test_merge_requires_exact_acknowledgement_phrase(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makeAccount('PLATO-A');

        Http::fake();

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge-plato', $account), [
                'survivor_id' => 'PLATO-B',
                'merged_id' => 'PLATO-A',
                'acknowledge' => 'yes please',
            ])
            ->assertSessionHas('error');

        Http::assertNothingSent();
        $this->assertSame('PLATO-A', $account->fresh()->idplato);
    }

    public function test_merge_rejects_record_not_belonging_to_account(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makeAccount('PLATO-A');
        $this->fakePlato();

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge-plato', $account), [
                'survivor_id' => 'PLATO-A',
                'merged_id' => 'PLATO-OTHER',
                'acknowledge' => self::PHRASE,
            ])
            ->assertSessionHas('error');

        Http::assertNotSent(fn ($request) => str_contains($request->url(), '/patient/merge'));
        $this->assertSame('PLATO-A', $account->fresh()->idplato);
    }

    public function test_merge_reports_plato_error(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makeAccount('PLATO-A');

        Http::fake([
            'https://plato.test/api/db/search/patient*' => Http::response(self::SEARCH_ROWS, 200),
            'https://plato.test/api/db/patient/merge*' => Http::response(['message' => 'Nope'], 422),
        ]);

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge-plato', $account), [
                'survivor_id' => 'PLATO-B',
                'merged_id' => 'PLATO-A',
                'acknowledge' => self::PHRASE,
            ])
            ->assertSessionHas('error');

        $this->assertSame('PLATO-A', $account->fresh()->idplato);
    }

    public function test_merge_requires_distinct_records(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makeAccount('PLATO-A');

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge-plato', $account), [
                'survivor_id' => 'PLATO-A',
                'merged_id' => 'PLATO-A',
                'acknowledge' => self::PHRASE,
            ])
            ->assertSessionHasErrors('merged_id');
    }
}
