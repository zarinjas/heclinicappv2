<?php

namespace Tests\Feature;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class AppAccountRelinkTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config(['plato.base_url' => 'https://plato.test/api/db']);
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

    private function makePatient(array $overrides = []): Patient
    {
        return Patient::create(array_merge([
            'name' => 'Patient '.substr(md5((string) mt_rand()), 0, 6),
            'nric' => '900101010001',
            'telephone' => '601111110001',
            'email' => 'patient'.mt_rand().'@example.com',
            'password' => Hash::make('secret123'),
        ], $overrides));
    }

    /**
     * @param  array<int, array<string,mixed>>  $searchRows
     * @param  array<int, array<string,mixed>>  $letters
     */
    private function fakePlato(array $searchRows, array $letters = []): void
    {
        Http::fake([
            'https://plato.test/api/db/search/patient*' => Http::response($searchRows, 200),
            'https://plato.test/api/db/letter*' => Http::response($letters, 200),
        ]);
    }

    public function test_show_lists_plato_records_when_lookup_requested(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['nric' => '900101010001', 'idplato' => 'PLATO-A']);

        $this->fakePlato([
            ['_id' => 'PLATO-A', 'name' => 'Old Record', 'nric' => '900101010001', 'created_on' => '2024-01-01'],
            ['_id' => 'PLATO-B', 'name' => 'New Record', 'nric' => '900101010001', 'created_on' => '2025-01-01'],
        ], [['subject' => 'Referral']]);

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]))
            ->assertOk()
            ->assertSee('PLATO-B')
            ->assertSee('New Record')
            ->assertSee('Use this record');
    }

    public function test_show_does_not_hit_plato_without_lookup(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['idplato' => 'PLATO-A']);

        Http::fake();

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.show', $account))
            ->assertOk()
            ->assertSee('Find Plato records');

        Http::assertNothingSent();
    }

    public function test_lookup_merges_nric_and_phone_matches_with_letter_preview(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['nric' => '900101010001', 'telephone' => '601111110001', 'idplato' => 'PLATO-A']);

        Http::fake(function ($request) {
            $url = $request->url();

            if (str_contains($url, 'search/patient')) {
                return str_contains($url, 'nric=')
                    ? Http::response([['_id' => 'PLATO-A', 'name' => 'A', 'nric' => '900101010001', 'created_on' => '2024-01-01']], 200)
                    : Http::response([['_id' => 'PLATO-B', 'name' => 'B', 'nric' => '900101010002', 'created_on' => '2025-01-01']], 200);
            }

            if (str_contains($url, 'letter')) {
                return str_contains($url, 'PLATO-B')
                    ? Http::response([['subject' => 'Referral to Cardiology', 'created_on' => '2025-06-01']], 200)
                    : Http::response([], 200);
            }

            return Http::response([], 200);
        });

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]))
            ->assertOk()
            ->assertSee('PLATO-A')
            ->assertSee('PLATO-B')
            ->assertSee('Referral to Cardiology');
    }

    public function test_lookup_warns_when_linked_record_no_longer_exists(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['nric' => '900101010001', 'idplato' => 'PLATO-GONE']);

        $this->fakePlato([
            ['_id' => 'PLATO-A', 'name' => 'A', 'nric' => '900101010001', 'created_on' => '2024-01-01'],
            ['_id' => 'PLATO-B', 'name' => 'B', 'nric' => '900101010001', 'created_on' => '2025-01-01'],
        ]);

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]))
            ->assertOk()
            ->assertSee('currently points to is missing from Plato')
            ->assertSee('PLATO-GONE');
    }

    public function test_relink_updates_idplato_to_selected_record(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['nric' => '900101010001', 'idplato' => 'PLATO-A']);

        $this->fakePlato([
            ['_id' => 'PLATO-A', 'name' => 'A', 'nric' => '900101010001', 'created_on' => '2024-01-01'],
            ['_id' => 'PLATO-B', 'name' => 'B', 'nric' => '900101010001', 'created_on' => '2025-01-01'],
        ]);

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.relink', $account), ['plato_id' => 'PLATO-B'])
            ->assertRedirect(route('admin.app-accounts.show', ['account' => $account, 'lookup' => 1]))
            ->assertSessionHas('success');

        $this->assertSame('PLATO-B', $account->fresh()->idplato);
    }

    public function test_relink_rejects_record_not_returned_by_plato(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['nric' => '900101010001', 'idplato' => 'PLATO-A']);

        $this->fakePlato([
            ['_id' => 'PLATO-A', 'name' => 'A', 'nric' => '900101010001'],
        ]);

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.relink', $account), ['plato_id' => 'PLATO-OTHER'])
            ->assertSessionHas('error');

        $this->assertSame('PLATO-A', $account->fresh()->idplato);
    }

    public function test_relink_rejects_record_already_linked_to_another_account(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['nric' => '900101010001', 'idplato' => 'PLATO-A']);
        $this->makePatient(['nric' => '900101010001', 'idplato' => 'PLATO-B']);

        $this->fakePlato([
            ['_id' => 'PLATO-A', 'name' => 'A', 'nric' => '900101010001'],
            ['_id' => 'PLATO-B', 'name' => 'B', 'nric' => '900101010001'],
        ]);

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.relink', $account), ['plato_id' => 'PLATO-B'])
            ->assertSessionHas('error');

        $this->assertSame('PLATO-A', $account->fresh()->idplato);
    }

    public function test_relink_requires_plato_id(): void
    {
        $admin = $this->makeAdmin();
        $account = $this->makePatient(['idplato' => 'PLATO-A']);

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.relink', $account), [])
            ->assertSessionHasErrors('plato_id');
    }
}
