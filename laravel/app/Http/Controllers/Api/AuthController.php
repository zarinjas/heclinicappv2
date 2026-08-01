<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Patient;
use App\Services\OtpService;
use App\Services\PlatoProxyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
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
            $data['telephone'] = Patient::normalisePhone($data['telephone']);
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
        $type = Patient::detectIdentifierType($identifier);

        $patient = match ($type) {
            'email' => Patient::where('email', $identifier)->first(),
            'nric' => Patient::where('nric', $identifier)->first(),
            'phone' => Patient::where('telephone', Patient::normalisePhone($identifier))->first(),
        };

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
        $type = Patient::detectIdentifierType($identifier);

        $patient = match ($type) {
            'email' => Patient::where('email', $identifier)->first(),
            'nric' => Patient::where('nric', $identifier)->first(),
            'phone' => Patient::where('telephone', Patient::normalisePhone($identifier))->first(),
        };

        // Always return success to prevent user enumeration
        if (! $patient) {
            return response()->json([
                'status' => true,
                'message' => 'If an account exists, a verification code has been sent.',
            ]);
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
            'message' => 'If an account exists, a verification code has been sent.',
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
        $type = Patient::detectIdentifierType($identifier);

        $patient = match ($type) {
            'email' => Patient::where('email', $identifier)->first(),
            'nric' => Patient::where('nric', $identifier)->first(),
            'phone' => Patient::where('telephone', Patient::normalisePhone($identifier))->first(),
        };

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
