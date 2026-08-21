<?php

namespace Tests\Feature;

use App\Models\Patient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AccountDeletionTest extends TestCase
{
    use RefreshDatabase;

    private function patient(): Patient
    {
        return Patient::create([
            'name' => 'Delete Me',
            'email' => 'delete@example.com',
            'telephone' => '60123456789',
            'nric' => '900101011234',
            'password' => Hash::make('Secret123'),
            'password_changed_at' => now(),
        ]);
    }

    public function test_account_deletion_soft_deletes_and_revokes_all_tokens(): void
    {
        $patient = $this->patient();
        $token = $patient->createToken('mobile')->plainTextToken;
        $patient->createToken('other-device');

        $this->withHeader('Authorization', "Bearer {$token}")
            ->deleteJson('/api/v2/auth/account', ['password' => 'Secret123'])
            ->assertOk()
            ->assertJson(['status' => true]);

        $this->assertSoftDeleted('patients', ['id' => $patient->id]);
        $this->assertDatabaseMissing('personal_access_tokens', ['tokenable_id' => $patient->id]);
        $this->assertDatabaseHas('patients', ['id' => $patient->id, 'fcm_token' => null]);
    }

    public function test_account_deletion_requires_the_current_password(): void
    {
        $patient = $this->patient();
        $token = $patient->createToken('mobile')->plainTextToken;

        $this->withHeader('Authorization', "Bearer {$token}")
            ->deleteJson('/api/v2/auth/account', ['password' => 'wrong'])
            ->assertStatus(422)
            ->assertJson(['status' => false]);

        $this->assertDatabaseHas('patients', ['id' => $patient->id, 'deleted_at' => null]);
    }

    public function test_deleted_accounts_cannot_log_in_again(): void
    {
        $patient = $this->patient();
        $patient->delete();

        $this->postJson('/api/v2/auth/login', [
            'identifier' => 'delete@example.com',
            'password' => 'Secret123',
        ])->assertStatus(401)->assertJson(['status' => false]);
    }
}
