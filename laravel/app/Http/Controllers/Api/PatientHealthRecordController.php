<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PlatoHealthRecordService;
use App\Services\PlatoProxyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response as SymfonyResponse;

final class PatientHealthRecordController extends Controller
{
    public function __construct(
        private readonly PlatoHealthRecordService $records,
        private readonly PlatoProxyService $plato,
    ) {}

    public function index(Request $request, string $id): JsonResponse
    {
        $patient = $request->user();

        if ($patient === null || (string) $patient->idplato !== $id) {
            return response()->json([
                'error' => true,
                'message' => 'You are not authorized to view these records.',
            ], 403);
        }

        $records = $this->records->recordsForPatient($id);
        foreach ($records as &$record) {
            $detail = $record['detail_data'] ?? null;
            if (($record['is_file'] ?? false) && is_string($detail) && $detail !== '') {
                $record['detail_data'] = route('patients.health-record-file', [
                    'id' => $id,
                    'source' => rtrim(strtr(base64_encode($detail), '+/', '-_'), '='),
                ]);
            }
            unset($record['is_file']);
        }
        unset($record);

        return response()->json(['records' => $records]);
    }

    public function file(Request $request, string $id): SymfonyResponse
    {
        $patient = $request->user();
        if ($patient === null || (string) $patient->idplato !== $id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $encoded = (string) $request->query('source', '');
        $encoded .= str_repeat('=', (4 - strlen($encoded) % 4) % 4);
        $source = base64_decode(strtr($encoded, '-_', '+/'), true);
        if (! is_string($source) || $source === '') {
            return response()->json(['message' => 'Invalid file source.'], 400);
        }

        try {
            $response = $this->plato->download($source);
        } catch (\InvalidArgumentException) {
            return response()->json(['message' => 'Invalid file source.'], 400);
        }
        if (! $response->successful()) {
            return response()->json([
                'message' => 'This health record file is unavailable.',
            ], $response->status() >= 400 ? $response->status() : 502);
        }

        $contentType = $response->header('Content-Type') ?: 'application/octet-stream';
        $name = basename((string) parse_url($source, PHP_URL_PATH));
        $name = $name !== '' ? preg_replace('/[^A-Za-z0-9._-]/', '_', $name) : 'health-record';

        return response($response->body(), 200, [
            'Content-Type' => $contentType,
            'Content-Disposition' => 'inline; filename="'.$name.'"',
            'Cache-Control' => 'private, max-age=0, no-store',
        ]);
    }
}
