<?php

use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CmsArticleController as ApiCmsArticleController;
use App\Http\Controllers\Api\CmsSliderController as ApiCmsSliderController;
use App\Http\Controllers\Api\CmsServicePackageController as ApiCmsServicePackageController;
use App\Http\Controllers\Api\CmsVideoController as ApiCmsVideoController;
use App\Http\Controllers\Api\CmsPromotionController as ApiCmsPromotionController;
use App\Http\Controllers\Api\CmsOnboardingSlideController as ApiCmsOnboardingSlideController;
use App\Http\Controllers\Api\CmsLegalPageController as ApiCmsLegalPageController;
use App\Http\Controllers\Api\BranchConfigController;
use App\Http\Controllers\Api\DoctorConfigController;
use App\Http\Controllers\Api\LoyaltyController;
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
    Route::get('/check-phone',     [AuthController::class, 'checkPhone'])->name('check-phone');
    Route::post('/register',        [AuthController::class, 'register'])->name('register');
    Route::post('/login',           [AuthController::class, 'login'])->name('login');
    Route::post('/social-login',    [AuthController::class, 'socialLogin'])->name('social-login');
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('forgot-password');
    Route::post('/claim-account',    [AuthController::class, 'claimAccount'])->name('claim-account');
    Route::post('/verify-otp',      [AuthController::class, 'verifyOtp'])->name('verify-otp');
    Route::post('/reset-password',  [AuthController::class, 'resetPassword'])->name('reset-password');
});

// ─── Mobile Patient Auth (protected) ─────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/v2/auth/logout', [AuthController::class, 'logout'])->name('auth.logout');
    Route::post('/v2/auth/change-password-first', [AuthController::class, 'changePasswordFirst'])
        ->name('auth.change-password-first');
});

// ─── Mobile Loyalty Points (protected) ──────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/v2/loyalty/balance', [LoyaltyController::class, 'balance'])
        ->name('loyalty.balance');
    Route::get('/v2/loyalty/transactions', [LoyaltyController::class, 'transactions'])
        ->name('loyalty.transactions');
    Route::post('/v2/loyalty/redeem', [LoyaltyController::class, 'redeem'])
        ->name('loyalty.redeem');
});

// ─── Loyalty webhook (public, secret-gated via header) ──────────────────────
Route::post('/v2/loyalty/webhook', [LoyaltyController::class, 'webhook'])
    ->name('loyalty.webhook');

Route::get('/v2/plato/health', [PlatoProxyController::class, 'health'])
    ->name('plato.health');

// ─── Public branding config (no auth required) ─────────────────────────────────
Route::get('/v2/config/branding', function () {
    $settings = \App\Models\Setting::whereIn('key', [
        'branding_app_name',
        'branding_app_short_name',
        'branding_tagline',
        'branding_primary_color',
        'branding_accent_color',
        'branding_splash_bg_color',
        'branding_logo_url',
        'branding_splash_logo_url',
        'branding_login_logo_url',
        'branding_appbar_logo_url',
        'branding_loading_gif_url',
        'branding_favicon_url',
    ])->pluck('value', 'key');

    return response()->json([
        'app_name' => $settings['branding_app_name'] ?? 'He Medical Clinic',
        'app_short_name' => $settings['branding_app_short_name'] ?? 'HE',
        'tagline' => $settings['branding_tagline'] ?? 'Your Health, Simplified',
        'primary_color' => $settings['branding_primary_color'] ?? '#131C3C',
        'accent_color' => $settings['branding_accent_color'] ?? '#3B8DFF',
        'splash_bg_color' => $settings['branding_splash_bg_color'] ?? '#131C3C',
        'logo_url' => $settings['branding_logo_url'] ?? null,
        'splash_logo_url' => $settings['branding_splash_logo_url'] ?? null,
        'login_logo_url' => $settings['branding_login_logo_url'] ?? null,
        'appbar_logo_url' => $settings['branding_appbar_logo_url'] ?? null,
        'loading_gif_url' => $settings['branding_loading_gif_url'] ?? null,
        'favicon_url' => $settings['branding_favicon_url'] ?? null,
    ]);
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('/v2/plato/voucher/redeem', [PlatoProxyController::class, 'voucherRedeem'])
        ->name('plato.voucher.redeem');

    Route::any('/v2/plato/{path}', [PlatoProxyController::class, 'proxy'])
        ->where('path', '.*')
        ->name('plato.proxy');

    Route::post('/v2/admin/appointments', [AppointmentController::class, 'store'])
        ->name('admin.appointments.store');

    Route::get('/v2/patients/{id}/documents', [PatientDocumentController::class, 'index'])
        ->name('patients.documents');
    Route::post('/v2/patients/{id}/documents', [PatientDocumentController::class, 'store'])
        ->name('patients.documents.store');
    Route::delete('/v2/patients/{id}/documents/{document}', [PatientDocumentController::class, 'destroy'])
        ->whereNumber('document')
        ->name('patients.documents.destroy');
});

Route::get('/v2/config/doctors', [DoctorConfigController::class, 'index'])
    ->name('config.doctors');

Route::get('/v2/cms/articles', [ApiCmsArticleController::class, 'index'])
    ->name('cms.articles');
Route::get('/v2/cms/article-categories', [ApiCmsArticleController::class, 'categories'])
    ->name('cms.articles.categories');
Route::get('/v2/cms/articles/{slug}', [ApiCmsArticleController::class, 'show'])
    ->name('cms.articles.show');
Route::get('/v2/cms/sliders', [ApiCmsSliderController::class, 'index'])
    ->name('cms.sliders');

Route::get('/v2/cms/service-packages', [ApiCmsServicePackageController::class, 'index'])
    ->name('cms.service-packages');

Route::get('/v2/cms/videos', [ApiCmsVideoController::class, 'index'])
    ->name('cms.videos');

Route::get('/v2/cms/promotions', [ApiCmsPromotionController::class, 'index'])
    ->name('cms.promotions');

Route::get('/v2/cms/onboarding-slides', [ApiCmsOnboardingSlideController::class, 'index'])
    ->name('cms.onboarding');

Route::get('/v2/cms/legal/{slug}', [ApiCmsLegalPageController::class, 'show'])
    ->name('cms.legal.show');

Route::get('/v2/config/telehealth', function () {
    $settings = \App\Models\Setting::whereIn('key', [
        'telehealth_title',
        'telehealth_description',
        'telehealth_features',
        'telehealth_whatsapp',
        'telehealth_price',
        'telehealth_hours',
        'telehealth_button_label',
    ])->pluck('value', 'key');

    return response()->json([
        'title'            => $settings['telehealth_title'] ?? 'Telehealth Consultation',
        'description'      => $settings['telehealth_description'] ?? 'Speak with a doctor from the comfort of your home.',
        'features'         => json_decode($settings['telehealth_features'] ?? '[]', true),
        'whatsapp_number'  => $settings['telehealth_whatsapp'] ?? '60136254528',
        'price'            => $settings['telehealth_price'] ?? 'RM 30 per 15-minute consultation',
        'hours_text'       => $settings['telehealth_hours'] ?? 'Available Monday - Friday, 8am - 8pm',
        'button_label'     => $settings['telehealth_button_label'] ?? 'Start WhatsApp Consultation',
    ]);
})->name('config.telehealth');

Route::get('/v2/config/clinic-info', function () {
    $settings = \App\Models\Setting::whereIn('key', [
        'clinic_about_text',
        'clinic_operating_hours',
        'clinic_contact_email',
    ])->pluck('value', 'key');

    return response()->json([
        'about_text'       => $settings['clinic_about_text'] ?? '',
        'operating_hours'  => json_decode($settings['clinic_operating_hours'] ?? '[]', true),
        'contact_email'    => $settings['clinic_contact_email'] ?? 'info@heclinic.com',
    ]);
})->name('config.clinic-info');

Route::get('/v2/config/branches', [BranchConfigController::class, 'index'])
    ->name('config.branches');
