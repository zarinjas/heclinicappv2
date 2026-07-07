<?php

use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CmsArticleController as ApiCmsArticleController;
use App\Http\Controllers\Api\CmsSliderController as ApiCmsSliderController;
use App\Http\Controllers\Api\CmsServicePackageController as ApiCmsServicePackageController;
use App\Http\Controllers\Api\CmsVideoController as ApiCmsVideoController;
use App\Http\Controllers\Api\BranchConfigController;
use App\Http\Controllers\Api\DoctorConfigController;
use App\Http\Controllers\Api\PatientDocumentController;
use App\Http\Controllers\Api\PlatoProxyController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// ─── Mobile Patient Auth (public) ────────────────────────────────────────────
Route::prefix('v2/auth')->name('auth.')->group(function () {
    Route::get('/check-nric',       [AuthController::class, 'checkNric'])->name('check-nric');
    Route::post('/register',        [AuthController::class, 'register'])->name('register');
    Route::post('/login',           [AuthController::class, 'login'])->name('login');
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('forgot-password');
    Route::post('/verify-otp',      [AuthController::class, 'verifyOtp'])->name('verify-otp');
    Route::post('/reset-password',  [AuthController::class, 'resetPassword'])->name('reset-password');
});

// ─── Mobile Patient Auth (protected) ─────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/v2/auth/logout', [AuthController::class, 'logout'])->name('auth.logout');
});

Route::get('/v2/plato/health', [PlatoProxyController::class, 'health'])
    ->name('plato.health');

// ─── Public branding config (no auth required) ─────────────────────────────────
Route::get('/v2/config/branding', function () {
    $settings = \App\Models\Setting::whereIn('key', [
        'branding_app_name',
        'branding_app_short_name',
        'branding_tagline',
        'branding_primary_color',
        'branding_logo_url',
        'branding_splash_logo_url',
        'branding_login_logo_url',
        'branding_appbar_logo_url',
        'branding_favicon_url',
    ])->pluck('value', 'key');

    return response()->json([
        'app_name' => $settings['branding_app_name'] ?? 'He Medical Clinic',
        'app_short_name' => $settings['branding_app_short_name'] ?? 'HE',
        'tagline' => $settings['branding_tagline'] ?? 'Your Health, Simplified',
        'primary_color' => $settings['branding_primary_color'] ?? '#131C3C',
        'logo_url' => $settings['branding_logo_url'] ?? null,
        'splash_logo_url' => $settings['branding_splash_logo_url'] ?? null,
        'login_logo_url' => $settings['branding_login_logo_url'] ?? null,
        'appbar_logo_url' => $settings['branding_appbar_logo_url'] ?? null,
        'favicon_url' => $settings['branding_favicon_url'] ?? null,
    ]);
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::any('/v2/plato/{path}', [PlatoProxyController::class, 'proxy'])
        ->where('path', '.*')
        ->name('plato.proxy');

    Route::get('/v2/config/doctors', [DoctorConfigController::class, 'index'])
        ->name('config.doctors');

    Route::post('/v2/admin/appointments', [AppointmentController::class, 'store'])
        ->name('admin.appointments.store');

    Route::get('/v2/patients/{id}/documents', [PatientDocumentController::class, 'index'])
        ->name('patients.documents');
});

Route::get('/v2/cms/articles', [ApiCmsArticleController::class, 'index'])
    ->name('cms.articles');
Route::get('/v2/cms/articles/{slug}', [ApiCmsArticleController::class, 'show'])
    ->name('cms.articles.show');

Route::get('/v2/cms/sliders', [ApiCmsSliderController::class, 'index'])
    ->name('cms.sliders');

Route::get('/v2/cms/service-packages', [ApiCmsServicePackageController::class, 'index'])
    ->name('cms.service-packages');

Route::get('/v2/cms/videos', [ApiCmsVideoController::class, 'index'])
    ->name('cms.videos');

Route::get('/v2/config/branches', [BranchConfigController::class, 'index'])
    ->name('config.branches');
