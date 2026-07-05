<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\FirebaseStorageService;
use Illuminate\Http\JsonResponse;

final class PatientDocumentController extends Controller
{
    private FirebaseStorageService $storageService;

    public function __construct(FirebaseStorageService $storageService)
    {
        $this->storageService = $storageService;
    }

    public function index(string $patientId): JsonResponse
    {
        $documents = $this->storageService->listDocuments($patientId);

        return response()->json(['documents' => $documents]);
    }
}
