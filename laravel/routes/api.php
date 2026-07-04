<?php

use App\Http\Controllers\Api\PlatoProxyController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::middleware('auth:sanctum')->group(function (): void {
    Route::any('/v2/plato/{path}', [PlatoProxyController::class, 'proxy'])
        ->where('path', '.*')
        ->name('plato.proxy');
});
