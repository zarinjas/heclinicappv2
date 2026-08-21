<?php

use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\AppInfoController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CmsArticleController as ApiCmsArticleController;
use App\Http\Controllers\Api\CmsSliderController as ApiCmsSliderController;
use App\Http\Controllers\Api\CmsClinicInfoController as ApiCmsClinicInfoController;
use App\Http\Controllers\Api\CmsServicePackageController as ApiCmsServicePackageController;
use App\Http\Controllers\Api\CmsVideoController as ApiCmsVideoController;
use App\Http\Controllers\Api\CmsPromotionController as ApiCmsPromotionController;
use App\Http\Controllers\Api\CmsOnboardingSlideController as ApiCmsOnboardingSlideController;
use App\Http\Controllers\Api\CmsLegalPageController as ApiCmsLegalPageController;
use App\Http\Controllers\Api\BranchConfigController;
use App\Http\Controllers\Api\DoctorConfigController;
use App\Http\Controllers\Api\LoyaltyController;
use App\Http\Controllers\Api\NotificationInboxController;
use App\Http\Controllers\Api\PatientDocumentController;
use App\Http\Controllers\Api\PlatoProxyController;
use App\Http\Controllers\Api\UserVoucherController;
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
    Route::post('/send-fcm-otp',    [AuthController::class, 'sendFcmOtp'])->name('send-fcm-otp');
    Route::post('/claim-account',    [AuthController::class, 'claimAccount'])->name('claim-account');
    Route::post('/verify-otp',      [AuthController::class, 'verifyOtp'])->name('verify-otp');
    Route::post('/reset-password',  [AuthController::class, 'resetPassword'])->name('reset-password');
});

// ─── Mobile Patient Auth (protected) ─────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    // Cheap "is this token still good?" probe used by biometric quick-login.
    Route::get('/v2/auth/me', [AuthController::class, 'me'])->name('auth.me');
    Route::match(['put', 'patch'], '/v2/auth/me', [AuthController::class, 'updateMe'])
        ->name('auth.me.update');
    Route::post('/v2/auth/logout', [AuthController::class, 'logout'])->name('auth.logout');
    Route::delete('/v2/auth/account', [AuthController::class, 'deleteAccount'])
        ->name('auth.account.delete');
    Route::post('/v2/auth/change-password-first', [AuthController::class, 'changePasswordFirst'])
        ->name('auth.change-password-first');
    Route::post('/v2/auth/device-token', [AuthController::class, 'registerDeviceToken'])
        ->name('auth.device-token');
    Route::post('/v2/auth/link-email-request', [AuthController::class, 'linkEmailRequest'])
        ->name('auth.link-email-request');
    Route::post('/v2/auth/link-email-verify', [AuthController::class, 'linkEmailVerify'])
        ->name('auth.link-email-verify');
});

// ─── Mobile Notification Inbox (protected) ──────────────────────────────────
// Replaces the app's direct Firestore reads of `historynotif`, which the
// security rules deny because the app authenticates with Sanctum, not Firebase.
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/v2/notifications', [NotificationInboxController::class, 'index'])
        ->name('notifications.index');
    Route::get('/v2/notifications/unread-count', [NotificationInboxController::class, 'unreadCount'])
        ->name('notifications.unread-count');
    Route::post('/v2/notifications/read-all', [NotificationInboxController::class, 'markAllRead'])
        ->name('notifications.read-all');
    Route::post('/v2/notifications/{id}/read', [NotificationInboxController::class, 'markRead'])
        ->whereNumber('id')
        ->name('notifications.read');
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

// ─── Mobile Vouchers (protected) ────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/v2/vouchers', [UserVoucherController::class, 'index'])
        ->name('vouchers.index');
    Route::post('/v2/vouchers/claim', [UserVoucherController::class, 'claim'])
        ->name('vouchers.claim');
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
        'branding_accent_color',
        'branding_splash_bg_color',
        'branding_logo_url',
        'branding_splash_logo_url',
        'branding_login_logo_url',
        'branding_appbar_logo_url',
        'branding_loading_gif_url',
        'branding_favicon_url',
        'welcome_bg_color',
        'welcome_bg_gradient_color',
        'welcome_button_color',
        'welcome_logo_size',
        'welcome_logo_url',
        'welcome_bg_image_url',
        'welcome_overlay_type',
        'welcome_overlay_color',
        'welcome_linear_start_color',
        'welcome_linear_end_color',
        'welcome_radial_center_color',
        'welcome_radial_edge_color',
        'welcome_overlay_opacity',
        'clinic_whatsapp',
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
        'welcome_bg_color' => $settings['welcome_bg_color'] ?? '#131C3C',
        'welcome_bg_gradient_color' => $settings['welcome_bg_gradient_color'] ?? '#1D2B5F',
        'welcome_button_color' => $settings['welcome_button_color'] ?? '#3B8DFF',
        'welcome_logo_size' => $settings['welcome_logo_size'] ?? '120',
        'welcome_logo_url' => $settings['welcome_logo_url'] ?? null,
        'welcome_bg_image_url' => $settings['welcome_bg_image_url'] ?? null,
        'welcome_overlay_type' => $settings['welcome_overlay_type'] ?? 'linear',
        'welcome_overlay_color' => $settings['welcome_overlay_color'] ?? '#131C3C',
        'welcome_linear_start_color' => $settings['welcome_linear_start_color'] ?? ($settings['welcome_bg_color'] ?? '#131C3C'),
        'welcome_linear_end_color' => $settings['welcome_linear_end_color'] ?? ($settings['welcome_bg_gradient_color'] ?? '#1D2B5F'),
        'welcome_radial_center_color' => $settings['welcome_radial_center_color'] ?? '#3B8DFF',
        'welcome_radial_edge_color' => $settings['welcome_radial_edge_color'] ?? '#131C3C',
        'welcome_overlay_opacity' => $settings['welcome_overlay_opacity'] ?? '100',
        'clinic_whatsapp' => $settings['clinic_whatsapp'] ?? '601167208860',
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
Route::get('/v2/cms/clinic-info', [ApiCmsClinicInfoController::class, 'index'])
    ->name('cms.clinic-info');

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

// Public contact & about info for the app's About screen. Values are managed
// from Admin → Settings → Contact & About.
Route::get('/v2/config/app-info', [AppInfoController::class, 'index'])
    ->name('config.app-info');

Route::get('/v2/config/branches', [BranchConfigController::class, 'index'])
    ->name('config.branches');
