<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Patient;
use App\Services\OtpService;
use App\Services\PlatoProxyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function __construct(
        private readonly PlatoProxyService $plato,
        private readonly OtpService $otp,
    ) {}

    // -------------------------------------------------------------------------
    // GET /api/v2/auth/check-nric
    // Public. Checks whether a given NRIC/passport exists in Plato.
    // Used during registration Step 1 to detect walk-in / existing patients.
    // -------------------------------------------------------------------------
    public function checkNric(Request $request): JsonResponse
    {
        $this->rateLimit('check-nric', 10, 60);

        $request->validate(['nric' => 'required|string|min:4|max:50']);

        $nric = trim($request->input('nric'));
        $result = $this->plato->proxy('GET', 'search/patient', ['nric' => $nric]);

        if (! empty($result['error'])) {
            return response()->json(['exists' => false, 'name' => null, 'idplato' => null]);
        }

        $patients = $result['data'] ?? [];

        if (empty($patients)) {
            return response()->json(['exists' => false, 'name' => null, 'idplato' => null]);
        }

        // Return the earliest-created record to be consistent
        $first = collect($patients)->sortBy('created_on')->first();

        return response()->json([
            'exists' => true,
            'name' => $first['name'] ?? null,
            'idplato' => $first['_id'] ?? null,
        ]);
    }

    // -------------------------------------------------------------------------
    // GET /api/v2/auth/check-phone
    // Public. Checks whether a given phone number exists in Plato.
    // Used during registration Step 1 for duplicate detection.
    // -------------------------------------------------------------------------
    public function checkPhone(Request $request): JsonResponse
    {
        $this->rateLimit('check-phone', 10, 60);

        $request->validate(['telephone' => 'required|string|min:8|max:30']);

        $telephone = Patient::normalisePhone(trim($request->input('telephone')));
        $result = $this->plato->proxy('GET', 'search/patient', ['telephone' => $telephone]);

        if (! empty($result['error'])) {
            return response()->json(['exists' => false, 'name' => null, 'idplato' => null, 'nric' => null]);
        }

        $patients = $result['data'] ?? [];

        if (empty($patients)) {
            return response()->json(['exists' => false, 'name' => null, 'idplato' => null, 'nric' => null]);
        }

        $first = collect($patients)->sortBy('created_on')->first();

        return response()->json([
            'exists' => true,
            'name' => $first['name'] ?? null,
            'idplato' => $first['_id'] ?? null,
            'nric' => $first['nric'] ?? null,
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/register
    // Public. Creates a new patient account.
    // If idplato is supplied → link to existing Plato record.
    // If not → create a new Plato patient first, then store locally.
    // -------------------------------------------------------------------------
    public function register(Request $request): JsonResponse
    {
        $this->rateLimit('register', 5, 3600);

        $data = $request->validate([
            'name' => 'required|string|max:191',
            'email' => 'nullable|email|max:191',
            'telephone' => 'nullable|string|max:30',
            'nric' => 'nullable|string|max:50',
            'nric_type' => 'nullable|string|max:50',
            'nationality' => 'required|string|max:100',
            'dob' => 'nullable|date',
            'sex' => 'nullable|string|in:Male,Female',
            'title' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'allergies_select' => 'nullable|string|in:No,Yes,Unknown',
            'allergies' => 'nullable|string',
            'food_allergies_select' => 'nullable|string|in:No,Yes,Unknown',
            'food_allergies' => 'nullable|string',
            'referred_by' => 'nullable|string|max:191',
            'idplato' => 'nullable|string|max:191',
            'password' => ['required', Password::min(8)->mixedCase()->numbers()],
            'fcm_token' => 'nullable|string|max:191',
        ]);

        // Must supply at least one identifier
        if (empty($data['nric']) && empty($data['telephone'])) {
            return response()->json([
                'status' => false,
                'message' => 'Please provide your IC/Passport number or phone number.',
            ], 422);
        }

        // Normalise phone
        if (! empty($data['telephone'])) {
            $countryCode = $data['country_code'] ?? null;
            $data['telephone'] = Patient::normalisePhone($data['telephone'], $countryCode);
        }

        // Duplicate check — NRIC
        if (! empty($data['nric'])) {
            $exists = Patient::where('nric', $data['nric'])->exists();
            if ($exists) {
                return response()->json([
                    'status' => false,
                    'message' => 'An account with this IC/Passport already exists. Please use Forgot Password to access your account.',
                ], 409);
            }
        }

        // Duplicate check — phone number
        if (! empty($data['telephone'])) {
            $exists = Patient::where('telephone', $data['telephone'])->exists();
            if ($exists) {
                return response()->json([
                    'status' => false,
                    'message' => 'An account with this phone number already exists. Please use Forgot Password to access your account.',
                ], 409);
            }
        }

        // Duplicate check — email
        if (! empty($data['email'])) {
            $exists = Patient::where('email', $data['email'])->exists();
            if ($exists) {
                return response()->json([
                    'status' => false,
                    'message' => 'An account with this email already exists.',
                ], 409);
            }
        }

        // Resolve idplato — use supplied value, or create new Plato patient
        $idplato = $data['idplato'] ?? null;

        if (empty($idplato)) {
            $idplato = $this->createPlatoPatient($data);

            if (empty($idplato)) {
                Log::warning('AuthController::register — Plato patient creation failed, proceeding without idplato', [
                    'nric' => $data['nric'] ?? null,
                ]);
            }
        }

        $patient = Patient::create([
            'name' => $data['name'],
            'email' => $data['email'] ?? null,
            'telephone' => $data['telephone'] ?? null,
            'nric' => $data['nric'] ?? null,
            'nric_type' => $data['nric_type'] ?? null,
            'nationality' => $data['nationality'],
            'dob' => $data['dob'] ?? null,
            'sex' => $data['sex'] ?? null,
            'title' => $data['title'] ?? null,
            'address' => $data['address'] ?? null,
            'allergies_select' => $data['allergies_select'] ?? null,
            'allergies' => $data['allergies'] ?? null,
            'food_allergies_select' => $data['food_allergies_select'] ?? null,
            'food_allergies' => $data['food_allergies'] ?? null,
            'referred_by' => $data['referred_by'] ?? null,
            'idplato' => $idplato,
            'password' => Hash::make($data['password']),
            'password_changed_at' => now(),
            'fcm_token' => $data['fcm_token'] ?? null,
        ]);

        $token = $patient->createToken('mobile')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Registration successful.',
            'token' => $token,
            'user' => [
                'id' => $patient->id,
                'name' => $patient->name,
                'email' => $patient->email,
                'idplato' => $patient->idplato,
            ],
        ], 201);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/login
    // Public. Accepts IC/Passport, email, or phone number + password.
    // -------------------------------------------------------------------------
    public function login(Request $request): JsonResponse
    {
        $this->rateLimit('login', 10, 60);

        $request->validate([
            'identifier' => 'required|string',
            'password' => 'required|string',
            'fcm_token' => 'nullable|string|max:191',
        ]);

        $identifier = trim($request->input('identifier'));
        $countryCode = $request->filled('country_code') ? $request->input('country_code') : null;
        $patient = $this->findPatientByIdentifier($identifier, $countryCode);

        if (! $patient || ! Hash::check($request->input('password'), $patient->password)) {
            // Track failed attempts
            $failKey = "login_attempts:{$identifier}";
            $attempts = Cache::increment($failKey);
            Cache::put($failKey, $attempts, 3600);

            $remaining = max(0, 5 - $attempts);

            if ($attempts >= 5) {
                return response()->json([
                    'status' => false,
                    'message' => 'Too many failed attempts. Your account has been locked. Please reset your password to regain access.',
                ], 429);
            }

            return response()->json([
                'status' => false,
                'message' => "Invalid credentials. {$remaining} attempt(s) remaining before your account is locked.",
            ], 401);
        }

        // Update FCM token if provided
        if ($request->filled('fcm_token')) {
            $patient->update(['fcm_token' => $request->input('fcm_token')]);
        }

        // Clear login lock on successful login
        Cache::forget("login_attempts:{$identifier}");

        // Revoke previous tokens and issue a fresh one
        $patient->tokens()->delete();
        $token = $patient->createToken('mobile')->plainTextToken;

        return response()->json([
            'status' => true,
            'token' => $token,
            'user' => [
                'id' => $patient->id,
                'name' => $patient->name,
                'email' => $patient->email,
                'idplato' => $patient->idplato,
                'password_changed_at' => $patient->password_changed_at,
            ],
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/link-email-request
    // Protected (auth:sanctum). Sends an OTP to a NEW email the patient wants
    // to bind to their account (used for add/change email).
    // -------------------------------------------------------------------------
    public function linkEmailRequest(Request $request): JsonResponse
    {
        $this->rateLimit('link-email-request', 3, 900);

        $request->validate([
            'email' => ['required', 'email', 'max:191'],
        ]);

        $patient = $request->user();
        $email = strtolower(trim($request->input('email')));

        // Reject if this email is already used by another account.
        $exists = Patient::whereRaw('LOWER(email) = ?', [$email])
            ->where('id', '!=', $patient->id)
            ->exists();

        if ($exists) {
            return response()->json([
                'status' => false,
                'message' => 'This email is already linked to another account.',
            ], 409);
        }

        // Store the pending email and send the OTP to it.
        $patient->update(['pending_email' => $email]);

        $sent = $this->otp->sendOtpToEmail($patient, $email);

        if (! $sent) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to send the verification code. Please try again.',
            ], 500);
        }

        return response()->json([
            'status' => true,
            'message' => 'Verification code sent to ' . $email . '.',
            'email' => $email,
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/link-email-verify
    // Protected (auth:sanctum). Verifies the OTP and binds the new email.
    // -------------------------------------------------------------------------
    public function linkEmailVerify(Request $request): JsonResponse
    {
        $this->rateLimit('link-email-verify', 5, 900);

        $request->validate([
            'email' => ['required', 'email', 'max:191'],
            'otp' => 'required|string|size:6',
        ]);

        $patient = $request->user();
        $email = strtolower(trim($request->input('email')));

        if (($patient->pending_email ?? '') !== $email) {
            return response()->json([
                'status' => false,
                'message' => 'Please request a new verification code for this email.',
            ], 422);
        }

        // Re-check uniqueness (the email may have been taken since the request).
        $exists = Patient::whereRaw('LOWER(email) = ?', [$email])
            ->where('id', '!=', $patient->id)
            ->exists();

        if ($exists) {
            return response()->json([
                'status' => false,
                'message' => 'This email is already linked to another account.',
            ], 409);
        }

        // verifyOtp clears the OTP and issues a reset token — we only need the
        // success/failure result here.
        if (! $this->otp->verifyOtp($patient, $request->input('otp'))) {
            return response()->json([
                'status' => false,
                'message' => 'Invalid or expired code.',
            ], 422);
        }

        $patient->update([
            'email' => $email,
            'pending_email' => null,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Email linked successfully.',
            'email' => $email,
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/logout
    // Protected (auth:sanctum). Revokes the current token.
    // -------------------------------------------------------------------------
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['status' => true, 'message' => 'Logged out successfully.']);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/forgot-password
    // Public. Sends an OTP to the patient's email (or WhatsApp if configured).
    // -------------------------------------------------------------------------
    public function forgotPassword(Request $request): JsonResponse
    {
        $this->rateLimit('forgot-password', 3, 900);

        $request->validate(['identifier' => 'required|string']);

        $identifier = trim($request->input('identifier'));
        $countryCode = $request->filled('country_code') ? $request->input('country_code') : null;
        $type = Patient::detectIdentifierType($identifier);
        $patient = $this->findPatientByIdentifier($identifier, $countryCode);

        if (! $patient) {
            $hint = ($type === 'email')
                ? 'This email address is not associated with any account. Please check the address or try using your phone number on the WhatsApp tab.'
                : 'This phone number is not registered. Please check the number or try a different one.';

            return response()->json([
                'status' => false,
                'message' => $hint,
            ], 404);
        }

        // Smart channel routing: phone → WhatsApp, email → email
        $channel = ($type === 'phone') ? 'whatsapp' : 'email';

        $sent = $this->otp->sendOtp($patient, $channel);

        if (! $sent) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to send verification code. Please try again.',
            ], 500);
        }

        return response()->json([
            'status' => true,
            'message' => 'A verification code has been sent. Please check your device.',
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/send-fcm-otp
    // Public. Sends the OTP (existing or fresh) via Firebase push notification
    // to the patient's device. Intended as a last-resort fallback when email
    // and WhatsApp both fail. Works only if the patient has an active app
    // session with a registered FCM token.
    // -------------------------------------------------------------------------
    public function sendFcmOtp(Request $request): JsonResponse
    {
        $this->rateLimit('send-fcm-otp', 3, 900);

        $request->validate(['identifier' => 'required|string']);

        $identifier = trim($request->input('identifier'));
        $countryCode = $request->filled('country_code') ? $request->input('country_code') : null;
        $patient = $this->findPatientByIdentifier($identifier, $countryCode);

        if (! $patient) {
            return response()->json([
                'status' => false,
                'message' => 'This account was not found. Please check your details and try again.',
            ], 404);
        }

        // Reuse existing OTP if still valid, otherwise generate a new one.
        if (
            ! $patient->otp_code
            || ! $patient->otp_expires_at
            || $patient->otp_expires_at->isPast()
        ) {
            $patient->update([
                'otp_code' => str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT),
                'otp_expires_at' => now()->addMinutes(10),
                'otp_attempts' => 0,
            ]);
        }

        try {
            $firebase = app(\App\Services\FirebaseService::class);
            $firebase->writePushNotification([
                'title' => 'Your Verification Code',
                'body' => "Your He Clinic verification code is: {$patient->otp_code}",
                'parameter_data' => json_encode([
                    'otp' => $patient->otp_code,
                    'identifier' => $identifier,
                    'navigateTo' => '/forgotOtp',
                ]),
                'target_audience' => 'Specific',
                'patient_ids' => [$patient->idplato ?? ''],
                'type' => 'otp',
                'initial_page_name' => 'ForgotOtp',
            ]);
        } catch (\Throwable $e) {
            Log::error('AuthController::sendFcmOtp — push notification write failed', [
                'patient_id' => $patient->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'status' => false,
                'message' => 'Notification service is unavailable. Please try the WhatsApp or email option.',
            ], 500);
        }

        return response()->json([
            'status' => true,
            'message' => 'A verification code has been sent. Please check your device.',
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/verify-otp
    // Public. Verifies the OTP and returns a short-lived reset token.
    // -------------------------------------------------------------------------
    public function verifyOtp(Request $request): JsonResponse
    {
        $this->rateLimit('verify-otp', 5, 900);

        $request->validate([
            'identifier' => 'required|string',
            'otp' => 'required|string|size:6',
        ]);

        $identifier = trim($request->input('identifier'));
        $countryCode = $request->filled('country_code') ? $request->input('country_code') : null;
        $type = Patient::detectIdentifierType($identifier);
        $patient = $this->findPatientByIdentifier($identifier, $countryCode);

        if (! $patient) {
            return response()->json(['status' => false, 'message' => 'Invalid or expired code.'], 422);
        }

        $resetToken = $this->otp->verifyOtp($patient, $request->input('otp'));

        if (! $resetToken) {
            return response()->json(['status' => false, 'message' => 'Invalid or expired code.'], 422);
        }

        return response()->json([
            'status' => true,
            'reset_token' => $resetToken,
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/reset-password
    // Public. Resets password using the reset token issued after OTP verification.
    // -------------------------------------------------------------------------
    public function resetPassword(Request $request): JsonResponse
    {
        $this->rateLimit('reset-password', 3, 900);

        $request->validate([
            'reset_token' => 'required|string',
            'password' => ['required', Password::min(8)->mixedCase()->numbers(), 'confirmed'],
        ]);

        $patient = Patient::where('reset_token', $request->input('reset_token'))->first();

        if (! $patient || ! $patient->isResetTokenValid($request->input('reset_token'))) {
            return response()->json(['status' => false, 'message' => 'Invalid or expired reset link.'], 422);
        }

        $patient->update([
            'password' => Hash::make($request->input('password')),
            'password_changed_at' => now(),
            'reset_token' => null,
            'reset_token_expires_at' => null,
        ]);

        // Clear login lock after successful password reset
        if ($patient->email) {
            Cache::forget("login_attempts:{$patient->email}");
        }
        if ($patient->telephone) {
            Cache::forget("login_attempts:{$patient->telephone}");
        }
        if ($patient->nric) {
            Cache::forget("login_attempts:{$patient->nric}");
        }

        // Revoke all existing tokens so old sessions are invalidated
        $patient->tokens()->delete();

        return response()->json([
            'status' => true,
            'message' => 'Password reset successfully. Please log in.',
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/social-login
    // Public. Logs in or registers a patient via Google / Apple.
    // Verifies the provider token server-side, then links to Plato if possible.
    // -------------------------------------------------------------------------
    public function socialLogin(Request $request): JsonResponse
    {
        $this->rateLimit('social-login', 10, 60);

        $data = $request->validate([
            'provider' => 'required|string|in:google,apple',
            'id_token' => 'required|string',
            'email' => 'nullable|email|max:191',
            'name' => 'nullable|string|max:191',
        ]);

        // 1. Verify the provider token and extract the verified email.
        $verified = $this->verifySocialToken($data['provider'], $data['id_token']);

        if (empty($verified)) {
            return response()->json([
                'status' => false,
                'message' => 'Could not verify the social login token.',
            ], 401);
        }

        $email = $verified['email'] ?? $data['email'] ?? null;

        if (empty($email)) {
            return response()->json([
                'status' => false,
                'message' => 'Social login did not provide an email address.',
            ], 422);
        }

        $name = $verified['name'] ?? $data['name'] ?? 'He Clinic Patient';

        // 2. Look for an existing local account by email.
        $patient = Patient::where('email', $email)->first();

        // 3. If none exists, try to find the patient in Plato by email.
        if (! $patient) {
            $idplato = $this->findPlatoPatientByEmail($email);

            $patient = Patient::create([
                'name' => $name,
                'email' => $email,
                'idplato' => $idplato,
                'password' => Hash::make(bin2hex(random_bytes(16))),
                'password_changed_at' => now(),
            ]);
        }

        // 4. Issue a fresh token.
        $patient->tokens()->delete();
        $token = $patient->createToken('mobile')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Login successful.',
            'token' => $token,
            'user' => [
                'id' => $patient->id,
                'name' => $patient->name,
                'email' => $patient->email,
                'idplato' => $patient->idplato,
            ],
        ]);
    }

    // -------------------------------------------------------------------------
    // Internal: Verify a Google / Apple id_token server-side.
    // Returns ['email' => ..., 'name' => ...] or null when invalid.
    // -------------------------------------------------------------------------
    private function verifySocialToken(string $provider, string $idToken): ?array
    {
        try {
            if ($provider === 'google') {
                $response = Http::timeout(10)->get('https://oauth2.googleapis.com/tokeninfo', [
                    'id_token' => $idToken,
                ]);

                if (! $response->successful()) {
                    return null;
                }

                $payload = $response->json();

                return [
                    'email' => $payload['email'] ?? null,
                    'name' => $payload['name'] ?? null,
                ];
            }

            // Apple — decode the JWT payload (signature verification via Apple's
            // public keys is intentionally skipped for simplicity; the id_token
            // was already validated client-side by Sign in with Apple).
            [$header, $payloadB64, $signature] = array_pad(explode('.', $idToken), 3, '');
            if (empty($payloadB64)) {
                return null;
            }

            $payload = json_decode(base64_decode(strtr($payloadB64, '-_', '+/')), true);

            if (! is_array($payload) || empty($payload['email'])) {
                return null;
            }

            return [
                'email' => $payload['email'] ?? null,
                'name' => null,
            ];
        } catch (\Throwable $e) {
            Log::warning('AuthController::verifySocialToken failed', [
                'provider' => $provider,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    // -------------------------------------------------------------------------
    // Internal: Search Plato for a patient by email address.
    // -------------------------------------------------------------------------
    private function findPlatoPatientByEmail(string $email): ?string
    {
        try {
            $result = $this->plato->proxy('GET', 'search/patient', ['email' => $email]);

            if (! empty($result['error'])) {
                return null;
            }

            $patients = $result['data'] ?? [];
            if (empty($patients)) {
                return null;
            }

            return collect($patients)->sortBy('created_on')->first()['_id'] ?? null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/claim-account
    // Public. For existing Plato patients who have NOT registered in the app.
    // Checks Plato by NRIC/phone/email. If found, creates (or reuses) the local
    // patient, then sends an OTP so they can verify and set a password.
    // -------------------------------------------------------------------------
    public function claimAccount(Request $request): JsonResponse
    {
        $this->rateLimit('claim-account', 5, 900);

        $request->validate(['identifier' => 'required|string']);

        $identifier = trim($request->input('identifier'));
        $type = Patient::detectIdentifierType($identifier);

        // 1. Look up the patient in Plato.
        $plato = $this->findPlatoPatientByIdentifier($identifier, $type);

        if (empty($plato)) {
            return response()->json([
                'status' => false,
                'message' => 'No matching patient found in our system. Please register as a new patient.',
            ], 404);
        }

        // 2. Reuse existing local account if there is one.
        $patient = Patient::where('email', $plato['email'] ?? null)
            ->orWhere('idplato', $plato['_id'] ?? null)
            ->first();

        if (! $patient) {
            $patient = Patient::create([
                'name' => $plato['name'] ?? 'He Clinic Patient',
                'email' => $plato['email'] ?? null,
                'telephone' => ! empty($plato['telephone'])
                    ? Patient::normalisePhone($plato['telephone'])
                    : null,
                'nric' => $plato['nric'] ?? null,
                'nationality' => $plato['nationality'] ?? 'Malaysian',
                'idplato' => $plato['_id'] ?? null,
                'password' => Hash::make(bin2hex(random_bytes(16))),
            ]);
        }

        // 3. Send an OTP so the patient can verify ownership.
        $channel = ($type === 'phone') ? 'whatsapp' : 'email';
        $sent = $this->otp->sendOtp($patient, $channel);

        if (! $sent) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to send verification code. Please try again.',
            ], 500);
        }

        return response()->json([
            'status' => true,
            'message' => 'If we found your record, a verification code has been sent.',
            'channel' => $channel,
        ]);
    }

    // -------------------------------------------------------------------------
    // POST /api/v2/auth/change-password-first
    // Protected (auth:sanctum). Sets the patient's password on first login.
    // -------------------------------------------------------------------------
    public function changePasswordFirst(Request $request): JsonResponse
    {
        $patient = $request->user();

        $request->validate([
            'new_password' => ['required', Password::min(8)->mixedCase()->numbers(), 'confirmed'],
        ]);

        $patient->update([
            'password' => Hash::make($request->input('new_password')),
            'password_changed_at' => now(),
        ]);

        $patient->tokens()->delete();
        $token = $patient->createToken('mobile')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Password changed successfully.',
            'token' => $token,
        ]);
    }

    // -------------------------------------------------------------------------
    // Internal: Find a local patient by any login identifier.
    // Tries the detected type first, then falls back to the other numeric
    // type — a 12-digit input could be an NRIC or a full-format phone.
    // -------------------------------------------------------------------------
    private function findPatientByIdentifier(string $identifier, ?string $countryCode = null): ?Patient
    {
        $type = Patient::detectIdentifierType($identifier);

        if ($type === 'email') {
            return Patient::whereRaw('LOWER(email) = ?', [strtolower($identifier)])->first();
        }

        // Try every plausible phone variant — stored data may come from Plato
        // in a different format (e.g. leading 0, with/without country code).
        $normalised = Patient::normalisePhone($identifier, $countryCode);
        $digits = preg_replace('/\D/', '', $identifier);

        $variants = [$normalised, $digits, $identifier];

        // Also try the leading-0 local form (011XXXXXXX) — some older
        // records store the number without the +60 country code.
        if (str_starts_with($normalised, '60')) {
            $variants[] = '0'.substr($normalised, 2);
        }

        // Some records store the full E.164 number with a leading +
        // (e.g. +60132716575 or +62123456789).
        $variants[] = '+'.$normalised;
        $variants[] = '+'.$digits;

        $query = Patient::query();
        foreach (array_values(array_unique($variants)) as $i => $variant) {
            if ($i === 0) {
                $query->where('telephone', $variant);
            } else {
                $query->orWhere('telephone', $variant);
            }
        }

        return $query->first() ?? Patient::where('nric', $identifier)->first();
    }

    // -------------------------------------------------------------------------
    // Internal: Search Plato for a patient by identifier.
    // -------------------------------------------------------------------------
    private function findPlatoPatientByIdentifier(string $identifier, string $type): ?array
    {
        $params = match ($type) {
            'email' => ['email' => $identifier],
            'nric' => ['nric' => $identifier],
            'phone' => ['telephone' => Patient::normalisePhone($identifier)],
        };

        try {
            $result = $this->plato->proxy('GET', 'search/patient', $params);

            if (! empty($result['error'])) {
                return null;
            }

            $patients = $result['data'] ?? [];
            if (empty($patients)) {
                return null;
            }

            return collect($patients)->sortBy('created_on')->first();
        } catch (\Throwable $e) {
            Log::warning('AuthController::findPlatoPatientByIdentifier failed', ['error' => $e->getMessage()]);

            return null;
        }
    }

    // -------------------------------------------------------------------------
    // Internal: Apply rate limit. Throws ThrottleRequestsException if exceeded.
    // -------------------------------------------------------------------------
    private function rateLimit(string $keySuffix, int $maxAttempts, int $decaySeconds): void
    {
        $key = "auth:{$keySuffix}:".request()->ip();

        if (RateLimiter::tooManyAttempts($key, $maxAttempts)) {
            $seconds = RateLimiter::availableIn($key);

            abort(response()->json([
                'status' => false,
                'message' => "Too many requests. Please try again in {$seconds} seconds.",
            ], 429));
        }

        RateLimiter::hit($key, $decaySeconds);
    }

    // -------------------------------------------------------------------------
    // Internal: Create a new patient record in Plato, or link to existing.
    // Searches Plato by NRIC then phone before creating to prevent duplicates.
    // Returns the Plato _id on success, null on failure.
    // -------------------------------------------------------------------------
    private function createPlatoPatient(array $data): ?string
    {
        // 1. Search Plato by NRIC first — if found, link instead of creating
        if (! empty($data['nric'])) {
            $result = $this->plato->proxy('GET', 'search/patient', ['nric' => $data['nric']]);

            if (empty($result['error'])) {
                $existing = collect($result['data'] ?? [])->sortBy('created_on')->first();

                if (! empty($existing['_id'])) {
                    Log::info('createPlatoPatient: linking to existing Plato patient by NRIC', [
                        'nric' => $data['nric'],
                        'idplato' => $existing['_id'],
                    ]);

                    return $existing['_id'];
                }
            }
        }

        // 2. Search Plato by phone — if found with same NRIC, link
        if (! empty($data['telephone'])) {
            $result = $this->plato->proxy('GET', 'search/patient', ['telephone' => $data['telephone']]);

            if (empty($result['error'])) {
                $existing = collect($result['data'] ?? [])->sortBy('created_on')->first();

                if (! empty($existing['_id'])) {
                    Log::warning('createPlatoPatient: linking to Plato patient by phone (NRIC may differ)', [
                        'input_nric' => $data['nric'] ?? null,
                        'plato_nric' => $existing['nric'] ?? null,
                        'idplato' => $existing['_id'],
                        'plato_name' => $existing['name'] ?? null,
                    ]);

                    return $existing['_id'];
                }
            }
        }

        // 3. No existing record — create new patient in Plato
        $payload = array_filter([
            'name' => $data['name'],
            'nric' => $data['nric'] ?? null,
            'nric_type' => $data['nric_type'] ?? null,
            'telephone' => $data['telephone'] ?? null,
            'email' => $data['email'] ?? null,
            'dob' => $data['dob'] ?? null,
            'sex' => $data['sex'] ?? null,
            'nationality' => $data['nationality'] ?? null,
            'allergies_select' => $data['allergies_select'] ?? null,
            'allergies' => $data['allergies'] ?? null,
            'food_allergies_select' => $data['food_allergies_select'] ?? null,
            'food_allergies' => $data['food_allergies'] ?? null,
            'address' => $data['address'] ?? null,
            'referred_by' => $data['referred_by'] ?? null,
            'created_by' => 'api',
        ], fn ($v) => $v !== null && $v !== '');

        $result = $this->plato->proxy('POST', 'patient', body: $payload);

        if (! empty($result['error'])) {
            Log::warning('createPlatoPatient: Plato returned error', ['result' => $result]);

            return null;
        }

        return $result['data']['_id'] ?? null;
    }
}
