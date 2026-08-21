<?php

namespace Tests\Feature;

use App\Models\Patient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

/**
 * Covers the public web account-deletion page at /account-deletion, which is
 * what gets submitted to Google Play as the account-deletion URL.
 */
class AccountDeletionWebTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // The web routes are CSRF-protected; feature tests do not carry a
        // session token, so disable just that middleware for this test.
        $this->withoutMiddleware(\Illuminate\Foundation\Http\Middleware\VerifyCsrfToken::class);
    }

    private function patient(): Patient
    {
        return Patient::create([
            'name' => 'Web Deletion',
            'email' => 'web-delete@example.com',
            'telephone' => '60123456789',
            'nric' => '900101011234',
            'password' => Hash::make('Secret123'),
            'password_changed_at' => now(),
        ]);
    }

    public function test_the_deletion_page_is_publicly_accessible(): void
    {
        $this->get('/account-deletion')
            ->assertOk()
            ->assertSee('Delete your account');
    }

    public function test_submitting_correct_credentials_soft_deletes_the_account(): void
    {
        $patient = $this->patient();
        $token = $patient->createToken('mobile')->plainTextToken;

        $this->post('/account-deletion', [
            'identifier' => 'web-delete@example.com',
            'password' => 'Secret123',
        ])->assertRedirect('/account-deletion')
            ->assertSessionHas('success');

        $this->assertSoftDeleted('patients', ['id' => $patient->id]);
        $this->assertDatabaseMissing('personal_access_tokens', ['tokenable_id' => $patient->id]);
    }

    public function test_submitting_a_wrong_password_does_not_delete_the_account(): void
    {
        $patient = $this->patient();

        $this->post('/account-deletion', [
            'identifier' => 'web-delete@example.com',
            'password' => 'wrong',
        ])->assertSessionHasErrors('identifier');

        $this->assertDatabaseHas('patients', ['id' => $patient->id, 'deleted_at' => null]);
    }

    public function test_an_already_deleted_account_cannot_be_deleted_again(): void
    {
        $patient = $this->patient();
        $patient->delete();

        $this->post('/account-deletion', [
            'identifier' => 'web-delete@example.com',
            'password' => 'Secret123',
        ])->assertSessionHasErrors('identifier');
    }
}
