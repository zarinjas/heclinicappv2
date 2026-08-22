<?php

use App\Http\Controllers\AccountDeletionController;
use App\Http\Controllers\Admin\AdminAppointmentController;
use App\Http\Controllers\Admin\AppAccountController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\BranchController;
use App\Http\Controllers\Admin\BrandingController;
use App\Http\Controllers\Admin\CalendarSetupController;
use App\Http\Controllers\Admin\CmsArticleCategoryController;
use App\Http\Controllers\Admin\CmsArticleController;
use App\Http\Controllers\Admin\CmsClinicInfoController;
use App\Http\Controllers\Admin\CmsLegalPageController;
use App\Http\Controllers\Admin\CmsOnboardingSlideController;
use App\Http\Controllers\Admin\CmsPromotionController;
use App\Http\Controllers\Admin\CmsServicePackageController;
use App\Http\Controllers\Admin\CmsSliderController;
use App\Http\Controllers\Admin\CmsVideoController;
use App\Http\Controllers\Admin\ContactInfoController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DoctorController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\PatientController;
use App\Http\Controllers\Admin\PlatoSettingsController;
use App\Http\Controllers\Admin\RecordController;
use App\Http\Controllers\Admin\SystemSettingsController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\UserVoucherController;
use App\Http\Controllers\Admin\WhatsAppController;
use App\Http\Controllers\LegalPageController;
use App\Http\Controllers\PatientDocumentFileController;
use App\Http\Controllers\PublicInfoController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

// Public, admin-editable legal pages. Content is managed in the admin panel
// under CMS → Legal Pages and stored in the `cms_legal_pages` table.
Route::get('/privacy-policy', [LegalPageController::class, 'show'])
    ->defaults('slug', 'privacy')
    ->name('legal.privacy');
Route::get('/terms-of-service', [LegalPageController::class, 'show'])
    ->defaults('slug', 'terms')
    ->name('legal.terms');

// Public, admin-editable contact & about pages. Values are managed in the
// admin panel under Settings → Contact & About and stored in `settings`.
Route::get('/contact', [PublicInfoController::class, 'contact'])->name('contact');
Route::get('/about', [PublicInfoController::class, 'about'])->name('about');

// Public account-deletion request page. Google Play requires a web URL where
// users can request deletion of their account in addition to the in-app flow.
// The POST route is rate-limited to slow down password guessing.
Route::get('/account-deletion', [AccountDeletionController::class, 'index'])
    ->name('account-deletion');
Route::post('/account-deletion', [AccountDeletionController::class, 'destroy'])
    ->middleware('throttle:10,1')
    ->name('account-deletion.submit');

// Signed, expiring download link for patient documents. Replaces the previous
// permanent public storage URLs, which exposed medical files to anyone holding
// the link. The signature is validated by the `signed` middleware.
Route::get('/documents/{document}', PatientDocumentFileController::class)
    ->whereNumber('document')
    ->middleware('signed')
    ->name('documents.show');

Route::prefix('admin')->name('admin.')->group(function (): void {
    Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AuthController::class, 'login'])->name('login.submit');
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

    Route::middleware(['auth', 'role:super_admin,branch_admin,staff'])->group(function (): void {
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

        Route::resource('branches', BranchController::class);
        Route::post('branches/sync', [BranchController::class, 'syncFromPlato'])->name('branches.sync');
        Route::resource('doctors', DoctorController::class);
        Route::post('doctors/sync', [DoctorController::class, 'syncFromPlato'])->name('doctors.sync');
        Route::get('patients/search', [PatientController::class, 'search'])
            ->name('patients.search');
        Route::resource('patients', PatientController::class)->only(['index', 'show']);
        Route::post('patients/{patient}/metadata', [PatientController::class, 'updateMetadata'])
            ->name('patients.metadata');
        Route::post('patients/{patient}/documents', [PatientController::class, 'uploadDocument'])
            ->name('patients.documents.upload');
        Route::delete('patients/{patient}/documents/{filename}', [PatientController::class, 'deleteDocument'])
            ->name('patients.documents.delete');
        Route::post('patients/{patient}/reset-password', [PatientController::class, 'resetPassword'])
            ->name('patients.reset-password');
        Route::get('app-accounts', [AppAccountController::class, 'index'])->name('app-accounts.index');
        Route::get('app-accounts/{account}', [AppAccountController::class, 'show'])->name('app-accounts.show');
        Route::post('app-accounts/merge', [AppAccountController::class, 'merge'])->name('app-accounts.merge');
        Route::get('records', [RecordController::class, 'index'])->name('records.index');
        Route::post('records/email', [RecordController::class, 'updateDefaultEmail'])->name('records.email.update');
        Route::delete('records/{record}', [RecordController::class, 'destroy'])->name('records.destroy');
        Route::resource('appointments', AdminAppointmentController::class)->only(['index', 'create', 'store', 'show']);
        Route::post('calendars/sync', [CalendarSetupController::class, 'sync'])->name('calendars.sync');
        Route::resource('calendars', CalendarSetupController::class);

        Route::get('voucher-claims', [UserVoucherController::class, 'index'])
            ->name('voucher-claims.index');
        Route::post('voucher-claims/{voucher}/used', [UserVoucherController::class, 'markUsed'])
            ->name('voucher-claims.used');

        Route::get('notifications/compose', [NotificationController::class, 'compose'])
            ->name('notifications.compose');
        Route::post('notifications/compose', [NotificationController::class, 'send'])
            ->name('notifications.send');
        Route::get('notifications', [NotificationController::class, 'index'])
            ->name('notifications.index');
        Route::get('notifications/{notification}', [NotificationController::class, 'show'])
            ->name('notifications.show');

        Route::get('whatsapp', [WhatsAppController::class, 'index'])->name('whatsapp.index');
        Route::post('whatsapp/send', [WhatsAppController::class, 'send'])->name('whatsapp.send');
        Route::post('whatsapp/fetch-patients', [WhatsAppController::class, 'fetchPatients'])->name('whatsapp.fetch-patients');

        Route::prefix('cms')->name('cms.')->group(function (): void {
            Route::resource('sliders', CmsSliderController::class);
            Route::resource('clinic-info', CmsClinicInfoController::class);
            Route::resource('service-packages', CmsServicePackageController::class);
            Route::resource('articles', CmsArticleController::class);
            Route::resource('article-categories', CmsArticleCategoryController::class);
            Route::get('videos/bulk', [CmsVideoController::class, 'bulk'])->name('videos.bulk');
            Route::post('videos/bulk-store', [CmsVideoController::class, 'bulkStore'])->name('videos.bulk-store');
            Route::resource('videos', CmsVideoController::class);
            Route::post('videos/fetch-info', [CmsVideoController::class, 'fetchInfo'])->name('videos.fetch-info');
            Route::resource('promotions', CmsPromotionController::class);
            Route::resource('onboarding', CmsOnboardingSlideController::class);
            Route::post('onboarding/{onboarding}/remove-media', [CmsOnboardingSlideController::class, 'removeMedia'])
                ->name('onboarding.remove-media');
            Route::resource('legal', CmsLegalPageController::class);
        });

        Route::get('branding', [BrandingController::class, 'index'])->name('branding');
        Route::post('branding', [BrandingController::class, 'update'])->name('branding.update');

        Route::get('settings/contact-info', [ContactInfoController::class, 'index'])
            ->name('settings.contact-info');
        Route::post('settings/contact-info', [ContactInfoController::class, 'update'])
            ->name('settings.contact-info.update');
    });

    Route::middleware(['auth', 'role:super_admin'])->group(function (): void {
        Route::get('settings/plato', [PlatoSettingsController::class, 'index'])->name('settings.plato');
        Route::post('settings/plato', [PlatoSettingsController::class, 'update'])->name('settings.plato.update');
        Route::post('settings/plato/test', [PlatoSettingsController::class, 'testConnection'])->name('settings.plato.test');
        Route::get('settings/system', [SystemSettingsController::class, 'index'])->name('settings.system');
        Route::post('settings/system', [SystemSettingsController::class, 'update'])->name('settings.system.update');
        Route::post('settings/system/test-whatsapp', [SystemSettingsController::class, 'testWhatsapp'])->name('settings.system.test-whatsapp');
        Route::resource('users', UserController::class);
    });
});
