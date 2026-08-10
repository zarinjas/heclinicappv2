<?php

namespace Tests\Feature;

use App\Models\Patient;
use Firebase\JWT\JWT;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

/**
 * Guards POST /api/v2/auth/social-login.
 *
 * The Apple branch previously base64-decoded the id_token payload without
 * verifying its signature, so anyone could forge a token carrying an arbitrary
 * email and receive a valid session for that account. These tests pin the
 * signature, issuer, audience and nonce checks that close that hole.
 */
class SocialLoginSecurityTest extends TestCase
{
    use RefreshDatabase;

    private const AUD = 'com.hemedgroup.heclinicapps';

    private string $privateKey;

    private array $jwks;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('services.apple.client_ids', [self::AUD]);

        // Generate a throwaway RSA keypair and publish it as a JWKS so the
        // controller can verify tokens we sign, without touching the network.
        $resource = openssl_pkey_new([
            'private_key_bits' => 2048,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ]);

        $exported = '';
        openssl_pkey_export($resource, $exported);
        $this->privateKey = $exported;
        $details = openssl_pkey_get_details($resource);

        $this->jwks = [
            'keys' => [[
                'kty' => 'RSA',
                'kid' => 'testkey',
                'use' => 'sig',
                'alg' => 'RS256',
                'n' => rtrim(strtr(base64_encode($details['rsa']['n']), '+/', '-_'), '='),
                'e' => rtrim(strtr(base64_encode($details['rsa']['e']), '+/', '-_'), '='),
            ]],
        ];

        Cache::flush();
        Http::fake([
            'appleid.apple.com/auth/keys' => Http::response($this->jwks, 200),
        ]);
    }

    private function appleToken(array $overrides = [], ?string $signingKey = null): string
    {
        $claims = array_merge([
            'iss' => 'https://appleid.apple.com',
            'aud' => self::AUD,
            'sub' => '001234.abcdef',
            'email' => 'patient@example.com',
            'email_verified' => 'true',
            'iat' => time(),
            'exp' => time() + 3600,
        ], $overrides);

        // A null override means "Apple omitted this claim entirely", which is
        // what happens to `email` on every sign-in after the first.
        $claims = array_filter($claims, static fn ($v) => $v !== null);

        return JWT::encode($claims, $signingKey ?? $this->privateKey, 'RS256', 'testkey');
    }

    private function socialLogin(array $payload)
    {
        return $this->postJson('/api/v2/auth/social-login', array_merge([
            'provider' => 'apple',
        ], $payload));
    }

    public function test_a_properly_signed_apple_token_logs_the_user_in(): void
    {
        $response = $this->socialLogin(['id_token' => $this->appleToken()]);

        $response->assertStatus(200);
        $response->assertJson(['status' => true]);
        $this->assertNotEmpty($response->json('token'));
        $this->assertDatabaseHas('patients', ['email' => 'patient@example.com']);
    }

    public function test_an_unsigned_forged_token_is_rejected(): void
    {
        // This is exactly the old attack: a token with alg=none and any email.
        $header = rtrim(strtr(base64_encode(json_encode([
            'alg' => 'none', 'typ' => 'JWT',
        ])), '+/', '-_'), '=');

        $payload = rtrim(strtr(base64_encode(json_encode([
            'iss' => 'https://appleid.apple.com',
            'aud' => self::AUD,
            'email' => 'victim@example.com',
            'exp' => time() + 3600,
        ])), '+/', '-_'), '=');

        $response = $this->socialLogin(['id_token' => "$header.$payload."]);

        $response->assertStatus(401);
        $this->assertDatabaseMissing('patients', ['email' => 'victim@example.com']);
    }

    public function test_a_token_signed_by_the_wrong_key_is_rejected(): void
    {
        $attackerKey = '';
        openssl_pkey_export(openssl_pkey_new([
            'private_key_bits' => 2048,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ]), $attackerKey);

        $token = $this->appleToken(['email' => 'victim@example.com'], $attackerKey);

        $this->socialLogin(['id_token' => $token])->assertStatus(401);
        $this->assertDatabaseMissing('patients', ['email' => 'victim@example.com']);
    }

    public function test_a_token_for_another_app_is_rejected(): void
    {
        $token = $this->appleToken(['aud' => 'com.someone.else']);

        $this->socialLogin(['id_token' => $token])->assertStatus(401);
    }

    public function test_a_token_from_the_wrong_issuer_is_rejected(): void
    {
        $token = $this->appleToken(['iss' => 'https://evil.example.com']);

        $this->socialLogin(['id_token' => $token])->assertStatus(401);
    }

    public function test_an_expired_token_is_rejected(): void
    {
        $token = $this->appleToken([
            'iat' => time() - 7200,
            'exp' => time() - 3600,
        ]);

        $this->socialLogin(['id_token' => $token])->assertStatus(401);
    }

    public function test_a_mismatched_nonce_is_rejected(): void
    {
        $token = $this->appleToken(['nonce' => hash('sha256', 'the-real-nonce')]);

        $this->socialLogin([
            'id_token' => $token,
            'raw_nonce' => 'a-different-nonce',
        ])->assertStatus(401);
    }

    public function test_a_matching_nonce_is_accepted(): void
    {
        $raw = 'the-real-nonce';
        $token = $this->appleToken(['nonce' => hash('sha256', $raw)]);

        $this->socialLogin([
            'id_token' => $token,
            'raw_nonce' => $raw,
        ])->assertStatus(200);
    }

    public function test_client_supplied_email_cannot_override_the_verified_one(): void
    {
        $victim = Patient::create([
            'name' => 'Victim',
            'email' => 'victim@example.com',
            'password' => Hash::make('secret123'),
            'password_changed_at' => now(),
        ]);

        // Valid token for the attacker, but claiming the victim's email.
        $token = $this->appleToken(['email' => 'attacker@example.com']);

        $response = $this->socialLogin([
            'id_token' => $token,
            'email' => 'victim@example.com',
        ]);

        $response->assertStatus(200);

        // The session must belong to the attacker, never the victim.
        $this->assertSame('attacker@example.com', $response->json('user.email'));
        $this->assertNotSame($victim->id, $response->json('user.id'));
    }

    public function test_a_returning_apple_user_without_email_is_recognised(): void
    {
        // First sign-in: Apple includes the email and creates the account.
        $first = $this->socialLogin(['id_token' => $this->appleToken()]);
        $first->assertStatus(200);
        $userId = $first->json('user.id');

        // Every later sign-in carries only `sub` — no email. This is the exact
        // case that produced "Login failed" for real users.
        $second = $this->socialLogin([
            'id_token' => $this->appleToken(['email' => null]),
        ]);

        $second->assertStatus(200);
        $second->assertJson(['status' => true]);
        $this->assertSame($userId, $second->json('user.id'));
        $this->assertNotEmpty($second->json('token'));
    }

    public function test_a_different_apple_user_gets_a_separate_account(): void
    {
        $this->socialLogin(['id_token' => $this->appleToken()])->assertStatus(200);

        $other = $this->socialLogin([
            'id_token' => $this->appleToken([
                'sub' => '009999.differentuser',
                'email' => 'someone.else@example.com',
            ]),
        ]);

        $other->assertStatus(200);
        $this->assertSame('someone.else@example.com', $other->json('user.email'));
    }
}
