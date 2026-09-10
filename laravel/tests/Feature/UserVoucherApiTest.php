<?php

namespace Tests\Feature;

use App\Models\CmsPromotion;
use App\Models\Patient;
use App\Models\UserVoucher;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class UserVoucherApiTest extends TestCase
{
    use RefreshDatabase;

    private function makePatient(): Patient
    {
        return Patient::create([
            'name' => 'Voucher Patient',
            'nric' => '900101010001',
            'telephone' => '601111110001',
            'password' => Hash::make('secret123'),
        ]);
    }

    private function makePromotion(array $overrides = []): CmsPromotion
    {
        return CmsPromotion::create(array_merge([
            'title' => 'Basic Health Screening',
            'description' => 'Full screening package.',
            'cta_text' => 'RM 99',
            'promo_code' => 'BASIC99',
            'is_active' => true,
            'valid_from' => now()->subDay()->toDateString(),
            'valid_until' => now()->addDays(30)->toDateString(),
        ], $overrides));
    }

    public function test_index_requires_authentication(): void
    {
        $this->getJson('/api/v2/vouchers')->assertStatus(401);
    }

    public function test_patient_can_claim_a_promotion(): void
    {
        $patient = $this->makePatient();
        $promotion = $this->makePromotion();

        $response = $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id]);

        $response->assertStatus(201)
            ->assertJsonPath('status', true)
            ->assertJsonPath('voucher.status', 'active');

        $code = $response->json('voucher.code');
        $this->assertStringStartsWith('VCH-', $code);
        $this->assertDatabaseHas('user_vouchers', [
            'patient_id' => $patient->id,
            'promotion_id' => $promotion->id,
            'code' => $code,
        ]);
    }

    public function test_patient_cannot_claim_twice(): void
    {
        $patient = $this->makePatient();
        $promotion = $this->makePromotion();

        $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(201);

        $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(422)
            ->assertJsonPath('message', 'You have already claimed this voucher.');

        $this->assertSame(1, UserVoucher::where('promotion_id', $promotion->id)->count());
    }

    public function test_claim_rejects_inactive_promotion(): void
    {
        $patient = $this->makePatient();
        $promotion = $this->makePromotion(['is_active' => false]);

        $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(422);
    }

    public function test_claim_rejects_expired_promotion(): void
    {
        $patient = $this->makePatient();
        $promotion = $this->makePromotion([
            'valid_from' => now()->subDays(10)->toDateString(),
            'valid_until' => now()->subDay()->toDateString(),
        ]);

        $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(422);
    }

    public function test_claim_enforces_usage_limit(): void
    {
        $patientA = $this->makePatient();
        $patientB = Patient::create([
            'name' => 'Second Patient',
            'nric' => '900101010002',
            'telephone' => '601111110002',
            'password' => Hash::make('secret123'),
        ]);
        $promotion = $this->makePromotion(['usage_limit' => 1]);

        $this->actingAs($patientA, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(201);

        $this->actingAs($patientB, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(422)
            ->assertJsonPath('message', 'This promotion has reached its usage limit.');
    }

    public function test_index_returns_only_own_vouchers(): void
    {
        $patient = $this->makePatient();
        $other = Patient::create([
            'name' => 'Other Patient',
            'nric' => '900101010003',
            'telephone' => '601111110003',
            'password' => Hash::make('secret123'),
        ]);
        $promotion = $this->makePromotion();

        $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(201);

        $this->actingAs($other, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->assertStatus(201);

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/vouchers')
            ->assertOk()
            ->assertJsonCount(1)
            ->assertJsonPath('0.promotion.title', 'Basic Health Screening')
            ->assertJsonPath('0.status', 'active');
    }

    public function test_index_reflects_used_status(): void
    {
        $patient = $this->makePatient();
        $promotion = $this->makePromotion();

        $voucher = $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/vouchers/claim', ['promotion_id' => $promotion->id])
            ->json('voucher');

        UserVoucher::find($voucher['id'])->update(['used_at' => now()]);

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/vouchers')
            ->assertOk()
            ->assertJsonPath('0.status', 'used')
            ->assertJsonPath('0.used_at', fn ($value) => $value !== null);
    }
}
