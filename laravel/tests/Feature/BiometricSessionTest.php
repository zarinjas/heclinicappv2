<?php

namespace Tests\Feature;

use App\Models\Patient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

/**
 * Guards GET /api/v2/auth/me, the probe biometric quick-login uses to decide
 * whether a stored session token is still usable.
 *
 * The app previously probed /profile, which does not exist on this API. Every
 * biometric unlock therefore looked like a rejected token and forced the user
 * to sign in with a password again.
 */
class BiometricSessionTest extends TestCase
{
    use RefreshDatabase;

    private function patient(): Patient
    {
        return Patient::create([
            'name' => 'Biometric User',
            'email' => 'bio@example.com',
            'idplato' => 'PL-001',
            'password' => Hash::make('secret123'),
            'password_changed_at' => now(),
        ]);
    }

    public function test_a_valid_token_is_accepted(): void
    {
        $patient = $this->patient();
        $token = $patient->createToken('mobile', ['*'], now()->addDays(30))
            ->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/v2/auth/me');

        $response->assertStatus(200);
        $response->assertJson([
            'status' => true,
            'user' => [
                'name' => 'Biometric User',
                'email' => 'bio@example.com',
                'idplato' => 'PL-001',
            ],
        ]);
    }

    public function test_a_missing_token_is_rejected_with_401(): void
    {
        // 401 is the specific status the app treats as "enrolment is dead".
        $this->getJson('/api/v2/auth/me')->assertStatus(401);
    }

    public function test_a_garbage_token_is_rejected_with_401(): void
    {
        $this->withHeader('Authorization', 'Bearer not-a-real-token')
            ->getJson('/api/v2/auth/me')
            ->assertStatus(401);
    }

    public function test_a_revoked_token_is_rejected_with_401(): void
    {
        $patient = $this->patient();
        $token = $patient->createToken('mobile', ['*'])->plainTextToken;

        // Logging out elsewhere revokes it.
        $patient->tokens()->delete();

        $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/v2/auth/me')
            ->assertStatus(401);
    }

    public function test_an_expired_token_is_rejected_with_401(): void
    {
        $patient = $this->patient();
        $token = $patient->createToken('mobile', ['*'], now()->subMinute())
            ->plainTextToken;

        $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/v2/auth/me')
            ->assertStatus(401);
    }

    public function test_the_token_survives_a_login_so_biometrics_persist(): void
    {
        // The token issued at login is what gets stored in the keystore. It
        // must still authenticate afterwards, otherwise biometric unlock would
        // fail on the very next app launch.
        $this->patient();

        $login = $this->postJson('/api/v2/auth/login', [
            'identifier' => 'bio@example.com',
            'password' => 'secret123',
        ]);

        $login->assertStatus(200);
        $token = $login->json('token');
        $this->assertNotEmpty($token);

        $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/v2/auth/me')
            ->assertStatus(200);
    }
}
