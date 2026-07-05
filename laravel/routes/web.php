<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\BranchController;
use App\Http\Controllers\Admin\CalendarSetupController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DoctorController;
use App\Http\Controllers\Admin\AdminAppointmentController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\PatientController;
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
        Route::resource('doctors', DoctorController::class);
        Route::resource('patients', PatientController::class)->only(['index', 'show']);
        Route::post('patients/{patient}/documents', [PatientController::class, 'uploadDocument'])
            ->name('patients.documents.upload');
        Route::delete('patients/{patient}/documents/{filename}', [PatientController::class, 'deleteDocument'])
            ->name('patients.documents.delete');
        Route::resource('appointments', AdminAppointmentController::class)->only(['index', 'create', 'store', 'show']);
        Route::post('calendars/sync', [CalendarSetupController::class, 'sync'])->name('calendars.sync');
        Route::resource('calendars', CalendarSetupController::class);

        Route::get('notifications/compose', [NotificationController::class, 'compose'])
            ->name('notifications.compose');
        Route::post('notifications/compose', [NotificationController::class, 'send'])
            ->name('notifications.send');
    });
});
