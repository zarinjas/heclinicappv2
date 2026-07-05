<?php

use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\CmsArticleController as ApiCmsArticleController;
use App\Http\Controllers\Api\CmsSliderController as ApiCmsSliderController;
use App\Http\Controllers\Api\CmsServicePackageController as ApiCmsServicePackageController;
use App\Http\Controllers\Api\CmsVideoController as ApiCmsVideoController;
use App\Http\Controllers\Api\DoctorConfigController;
use App\Http\Controllers\Api\PatientDocumentController;
use App\Http\Controllers\Api\PlatoProxyController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/v2/plato/health', [PlatoProxyController::class, 'health'])
    ->name('plato.health');

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
