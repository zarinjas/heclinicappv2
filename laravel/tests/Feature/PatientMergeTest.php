<?php

namespace Tests\Feature;

use App\Models\CmsPromotion;
use App\Models\Patient;
use App\Models\User;
use App\Models\UserVoucher;
use App\Services\PatientMergeService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PatientMergeTest extends TestCase
{
    use RefreshDatabase;

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

    private function makePromotion(): CmsPromotion
    {
        return CmsPromotion::create([
            'title' => 'Basic Health Screening',
            'description' => 'Full screening package.',
            'cta_text' => 'RM 99',
            'promo_code' => 'BASIC99',
            'is_active' => true,
            'valid_from' => now()->subDay()->toDateString(),
            'valid_until' => now()->addDays(30)->toDateString(),
        ]);
    }

    private function claim(Patient $patient, CmsPromotion $promotion): UserVoucher
    {
        return UserVoucher::create([
            'patient_id' => $patient->id,
            'promotion_id' => $promotion->id,
            'code' => 'HEC-'.strtoupper(substr(md5((string) mt_rand()), 0, 4)).'-'.now()->year,
        ]);
    }

    public function test_merge_reassigns_vouchers_and_soft_deletes_duplicate(): void
    {
        $primary = $this->makePatient(['idplato' => 'PLATO-A']);
        $duplicate = $this->makePatient(['nric' => '900101010001', 'idplato' => null]);
        $promotion = $this->makePromotion();
        $voucher = $this->claim($duplicate, $promotion);

        $this->assertSame($voucher->fresh()->patient_id, $duplicate->id);

        app(PatientMergeService::class)->merge($primary, $duplicate);

        $this->assertNotNull($duplicate->fresh()->deleted_at, 'Duplicate should be soft-deleted.');
        $this->assertSame($voucher->fresh()->patient_id, $primary->id, 'Voucher should be reassigned to the primary account.');
        $this->assertDatabaseMissing('user_vouchers', ['id' => $voucher->id, 'patient_id' => $duplicate->id]);
    }

    public function test_merge_fills_identity_gaps_on_primary(): void
    {
        $primary = $this->makePatient(['apple_sub' => null, 'idplato' => null, 'email' => null]);
        $duplicate = $this->makePatient([
            'nric' => $primary->nric,
            'apple_sub' => 'apple-123',
            'idplato' => 'PLATO-B',
            'email' => 'shared@example.com',
        ]);

        app(PatientMergeService::class)->merge($primary, $duplicate);

        $primary->refresh();
        $this->assertSame('apple-123', $primary->apple_sub);
        $this->assertSame('PLATO-B', $primary->idplato);
        $this->assertSame('shared@example.com', $primary->email);
    }

    public function test_merge_drops_voucher_when_primary_already_claimed_same_promotion(): void
    {
        $primary = $this->makePatient();
        $duplicate = $this->makePatient(['nric' => $primary->nric]);
        $promotion = $this->makePromotion();

        $primaryVoucher = $this->claim($primary, $promotion);
        $duplicateVoucher = $this->claim($duplicate, $promotion);

        app(PatientMergeService::class)->merge($primary, $duplicate);

        $this->assertDatabaseHas('user_vouchers', ['id' => $primaryVoucher->id, 'patient_id' => $primary->id]);
        $this->assertDatabaseMissing('user_vouchers', ['id' => $duplicateVoucher->id]);
    }

    public function test_merge_revokes_duplicate_sessions(): void
    {
        $primary = $this->makePatient();
        $duplicate = $this->makePatient(['nric' => $primary->nric]);
        $duplicate->createToken('device');

        $this->assertSame(1, DB::table('personal_access_tokens')->where('tokenable_id', $duplicate->id)->count());

        app(PatientMergeService::class)->merge($primary, $duplicate);

        $this->assertSame(0, DB::table('personal_access_tokens')->where('tokenable_id', $duplicate->id)->count());
    }

    public function test_merge_rejects_accounts_linked_to_different_plato_records(): void
    {
        $primary = $this->makePatient(['idplato' => 'PLATO-A']);
        $duplicate = $this->makePatient(['nric' => $primary->nric, 'idplato' => 'PLATO-B']);

        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('two different Plato records');

        app(PatientMergeService::class)->merge($primary, $duplicate);
    }

    public function test_merge_rejects_merging_into_itself(): void
    {
        $patient = $this->makePatient();

        $this->expectException(\InvalidArgumentException::class);

        app(PatientMergeService::class)->merge($patient, $patient);
    }

    public function test_admin_can_merge_two_duplicate_accounts_via_http(): void
    {
        $admin = User::create([
            'name' => 'Admin',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
        ]);

        $primary = $this->makePatient(['idplato' => 'PLATO-A']);
        $duplicate = $this->makePatient(['nric' => $primary->nric, 'idplato' => null]);

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge'), [
                'primary_id' => $primary->id,
                'duplicate_id' => $duplicate->id,
            ])
            ->assertRedirect(route('admin.app-accounts.show', $primary));

        $this->assertNotNull($duplicate->fresh()->deleted_at);
    }

    public function test_admin_cannot_merge_non_matching_accounts(): void
    {
        $admin = User::create([
            'name' => 'Admin',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
        ]);

        $primary = $this->makePatient(['idplato' => 'PLATO-A']);
        $duplicate = $this->makePatient(['idplato' => 'PLATO-B']);

        $this->actingAs($admin)
            ->post(route('admin.app-accounts.merge'), [
                'primary_id' => $primary->id,
                'duplicate_id' => $duplicate->id,
            ])
            ->assertSessionHasErrors('duplicate_id');

        $this->assertNull($duplicate->fresh()->deleted_at, 'No merge should happen when Plato records differ.');
    }

    public function test_index_lists_newest_signup_first(): void
    {
        $admin = $this->makeAdmin();

        $older = $this->makePatient(['name' => 'Older Signup', 'nric' => '900101010001']);
        $older->update(['created_at' => now()->subDays(10)]);

        $newer = $this->makePatient(['name' => 'Newer Signup', 'nric' => '900101010099']);
        $newer->update(['created_at' => now()->subDay()]);

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.index'))
            ->assertOk()
            ->assertSeeInOrder(['Newer Signup', 'Older Signup']);
    }

    public function test_index_detects_duplicate_nric_accounts(): void
    {
        $admin = $this->makeAdmin();

        $this->makePatient(['nric' => '900101010001']);
        $this->makePatient(['nric' => '900101010001']);

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.index'))
            ->assertOk()
            ->assertSee('Possible duplicate accounts')
            ->assertSee('900101010001');
    }

    public function test_show_page_lists_merge_candidates(): void
    {
        $admin = $this->makeAdmin();

        $account = $this->makePatient(['nric' => '900101010001', 'name' => 'Primary User']);
        $other = $this->makePatient(['nric' => '900101010001', 'name' => 'Duplicate User']);

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.show', $account))
            ->assertOk()
            ->assertSee('Merge account')
            ->assertSee($other->name);
    }

    public function test_index_filters_by_linked_status(): void
    {
        $admin = $this->makeAdmin();

        $linked = $this->makePatient(['idplato' => 'PLATO-A', 'name' => 'Linked User', 'nric' => '900101010001', 'telephone' => '601111110001']);
        $this->makePatient(['idplato' => null, 'name' => 'Anonymous User', 'nric' => '900101010002', 'telephone' => '601111110002']);

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.index', ['view' => 'linked']))
            ->assertOk()
            ->assertSee('Linked User');

        $this->actingAs($admin)
            ->get(route('admin.app-accounts.index', ['view' => 'not_linked']))
            ->assertOk()
            ->assertDontSee('Linked User');
    }

    private function makeAdmin(): User
    {
        return User::create([
            'name' => 'Admin',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
        ]);
    }
}
