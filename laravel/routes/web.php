<?php

use App\Http\Controllers\Admin\AdminAppointmentController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\BranchController;
use App\Http\Controllers\Admin\BrandingController;
use App\Http\Controllers\Admin\CalendarSetupController;
use App\Http\Controllers\Admin\CmsArticleController;
use App\Http\Controllers\Admin\CmsArticleCategoryController;
use App\Http\Controllers\Admin\CmsLegalPageController;
use App\Http\Controllers\Admin\CmsOnboardingSlideController;
use App\Http\Controllers\Admin\CmsPromotionController;
use App\Http\Controllers\Admin\CmsServicePackageController;
use App\Http\Controllers\Admin\CmsSliderController;
use App\Http\Controllers\Admin\CmsVideoController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DoctorController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\PatientController;
use App\Http\Controllers\Admin\PlatoSettingsController;
use App\Http\Controllers\Admin\RecordController;
use App\Http\Controllers\Admin\SystemSettingsController;
use App\Http\Controllers\Admin\WhatsAppController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

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
        Route::resource('patients', PatientController::class)->only(['index', 'show']);
        Route::post('patients/{patient}/metadata', [PatientController::class, 'updateMetadata'])
            ->name('patients.metadata');
        Route::post('patients/{patient}/documents', [PatientController::class, 'uploadDocument'])
            ->name('patients.documents.upload');
        Route::delete('patients/{patient}/documents/{filename}', [PatientController::class, 'deleteDocument'])
            ->name('patients.documents.delete');
        Route::get('records', [RecordController::class, 'index'])->name('records.index');
        Route::post('records/email', [RecordController::class, 'updateDefaultEmail'])->name('records.email.update');
        Route::delete('records/{record}', [RecordController::class, 'destroy'])->name('records.destroy');
        Route::resource('appointments', AdminAppointmentController::class)->only(['index', 'create', 'store', 'show']);
        Route::post('calendars/sync', [CalendarSetupController::class, 'sync'])->name('calendars.sync');
        Route::resource('calendars', CalendarSetupController::class);

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
            Route::resource('service-packages', CmsServicePackageController::class);
            Route::resource('articles', CmsArticleController::class);
            Route::resource('article-categories', CmsArticleCategoryController::class);
            Route::get('videos/bulk', [CmsVideoController::class, 'bulk'])->name('videos.bulk');
            Route::post('videos/bulk-store', [CmsVideoController::class, 'bulkStore'])->name('videos.bulk-store');
            Route::resource('videos', CmsVideoController::class);
            Route::post('videos/fetch-info', [CmsVideoController::class, 'fetchInfo'])->name('videos.fetch-info');
            Route::resource('promotions', CmsPromotionController::class);
            Route::resource('onboarding', CmsOnboardingSlideController::class);
            Route::resource('legal', CmsLegalPageController::class);
        });

        Route::get('branding', [BrandingController::class, 'index'])->name('branding');
        Route::post('branding', [BrandingController::class, 'update'])->name('branding.update');
    });

    Route::middleware(['auth', 'role:super_admin'])->group(function (): void {
        Route::get('settings/plato', [PlatoSettingsController::class, 'index'])->name('settings.plato');
        Route::post('settings/plato', [PlatoSettingsController::class, 'update'])->name('settings.plato.update');
        Route::post('settings/plato/test', [PlatoSettingsController::class, 'testConnection'])->name('settings.plato.test');
        Route::get('settings/system', [SystemSettingsController::class, 'index'])->name('settings.system');
        Route::post('settings/system', [SystemSettingsController::class, 'update'])->name('settings.system.update');
    });
});
