<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\Branch;
use App\Models\Setting;
use App\Services\NotificationService;
use App\Services\PatientDocumentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class PatientDocumentController extends Controller
{
    public function __construct(
        private readonly PatientDocumentService $documents,
        private readonly NotificationService $notifications,
    ) {}

    public function index(Request $request, string $patientId): JsonResponse
    {
        $modifiedSince = $request->filled('modified_since')
            ? (int) $request->input('modified_since')
            : null;

        $documents = $this->documents->list($patientId, $modifiedSince);

        return response()->json(['documents' => $documents]);
    }

    public function store(Request $request, string $patientId): JsonResponse
    {
        $patient = $request->user();

        if ($patient === null || (string) $patient->idplato !== $patientId) {
            return response()->json([
                'error' => true,
                'message' => 'You are not authorized to upload documents for this patient.',
            ], 403);
        }

        $request->validate([
            'document' => [
                'required',
                'file',
                'mimetypes:application/pdf,image/jpeg,image/png,image/gif,image/webp',
                'max:10240',
            ],
            'title' => ['nullable', 'string', 'max:255'],
        ], [
            'document.mimetypes' => 'Only PDF or image files are allowed.',
            'document.max' => 'The document must not be larger than 10MB.',
        ]);

        $branchId = $this->resolveBranchId($patientId, $patient);
        $branch = $branchId !== null ? Branch::find($branchId) : null;
        $defaultEmail = (string) Setting::where('key', 'document_upload_admin_email')->value('value');
        $recipient = $branch?->email ?: $defaultEmail;
        $title = $request->filled('title') ? $request->input('title') : null;

        $document = $this->documents->upload(
            $patientId,
            $request->file('document'),
            $title,
            null,
            [
                'name' => $patient->name,
                'nric' => $patient->nric,
                'phone' => $patient->telephone,
            ],
            $branchId,
            'patient',
            $recipient,
        );

        if ($recipient !== '') {
            $this->notifications->sendPatientDocumentUploadedEmail(
                $document,
                $recipient,
                $branch?->name ?? '',
            );
        }

        return response()->json([
            'message' => 'Document uploaded successfully.',
            'document' => $document,
        ], 201);
    }

    public function destroy(Request $request, string $patientId, int $document): JsonResponse
    {
        $patient = $request->user();
        $doc = $this->documents->findById($document);

        if ($doc === null || (string) $doc->patient_plato_uid !== $patientId) {
            return response()->json([
                'error' => true,
                'message' => 'Document not found.',
            ], 404);
        }

        if ($patient === null || (string) $patient->idplato !== $patientId) {
            return response()->json([
                'error' => true,
                'message' => 'You are not authorized to delete this document.',
            ], 403);
        }

        if ($doc->source !== 'patient') {
            return response()->json([
                'error' => true,
                'message' => 'You can only delete documents you uploaded yourself.',
            ], 403);
        }

        $this->documents->deleteById($document);

        return response()->json([
            'message' => 'Document deleted successfully.',
        ]);
    }

    private function resolveBranchId(string $patientId, object $patient): ?int
    {
        $appointment = Appointment::query()
            ->where(function ($q) use ($patientId, $patient) {
                $q->where('patient_plato_id', $patientId);

                if (! empty($patient->nric)) {
                    $q->orWhere('patient_nric', $patient->nric);
                }

                if (! empty($patient->telephone)) {
                    $q->orWhere('patient_phone', $patient->telephone);
                }
            })
            ->orderBy('appointment_date', 'desc')
            ->orderBy('id', 'desc')
            ->first();

        return $appointment?->branch_id;
    }
}
