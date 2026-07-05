<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

final class FirebaseService
{
    private string $projectId;
    private string $firestoreBaseUrl;
    private string $webApiKey;

    public function __construct()
    {
        $this->projectId = config('firebase.project_id');
        $this->firestoreBaseUrl = rtrim(config('firebase.firestore_base_url'), '/');
        $this->webApiKey = config('firebase.web_api_key', '');
    }

    public function writeToFirestore(string $collection, array $data, ?string $documentId = null): array
    {
        $url = sprintf(
            '%s/projects/%s/databases/(default)/documents/%s',
            $this->firestoreBaseUrl,
            $this->projectId,
            $collection,
        );

        if ($documentId !== null) {
            $url .= '?documentId=' . $documentId;
        }

        if ($this->webApiKey !== '' && $this->webApiKey !== '0') {
            $url .= (str_contains($url, '?') ? '&' : '?') . 'key=' . $this->webApiKey;
        }

        $firestorePayload = $this->toFirestoreDocument($data);

        try {
            $response = Http::timeout(10)
                ->acceptJson()
                ->asJson()
                ->post($url, $firestorePayload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            Log::channel('plato')->warning('Firestore write failed', [
                'collection' => $collection,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'success' => false,
                'error' => $response->json('error.message') ?? 'Firestore write failed',
                'status' => $response->status(),
            ];
        } catch (\Exception $e) {
            Log::channel('plato')->error('Firestore write exception', [
                'collection' => $collection,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    public function writePushNotification(array $notificationData): array
    {
        $userRefs = $notificationData['user_refs'] ?? [];
        if (is_string($userRefs) && $userRefs !== '') {
            $userRefs = array_map('trim', explode(',', $userRefs));
        } elseif (!is_array($userRefs)) {
            $userRefs = [];
        }

        $branchIds = $notificationData['branch_ids'] ?? [];
        if (!is_array($branchIds)) {
            $branchIds = [];
        }

        $doctorIds = $notificationData['doctor_ids'] ?? [];
        if (!is_array($doctorIds)) {
            $doctorIds = [];
        }

        $targetDateRange = $notificationData['target_date_range'] ?? null;
        if ($targetDateRange !== null && !is_array($targetDateRange)) {
            $targetDateRange = null;
        }

        $payload = [
            'notification_title' => $notificationData['title'] ?? '',
            'notification_text' => $notificationData['body'] ?? '',
            'notification_image_url' => $notificationData['image_url'] ?? '',
            'notification_sound' => $notificationData['sound'] ?? 'default',
            'parameter_data' => $notificationData['parameter_data'] ?? '',
            'target_audience' => $notificationData['target_audience'] ?? 'All',
            'initial_page_name' => $notificationData['initial_page_name'] ?? 'Appointments',
            'user_refs' => $userRefs,
            'branch_ids' => $branchIds,
            'doctor_ids' => $doctorIds,
            'target_date_range' => $targetDateRange,
            'batch_index' => 0,
            'num_batches' => 0,
            'status' => '',
        ];

        return $this->writeToFirestore('ff_push_notifications', $payload);
    }

    public function writeInAppNotification(array $data): array
    {
        $payload = [
            'title' => $data['title'] ?? '',
            'body' => $data['body'] ?? '',
            'timestamp' => now()->timestamp,
            'read' => false,
            'deep_link' => $data['deep_link'] ?? 'appointments',
            'type' => $data['type'] ?? 'appointment',
            'id_patient' => $data['id_patient'] ?? null,
        ];

        return $this->writeToFirestore('historynotif', $payload);
    }

    private function toFirestoreDocument(array $data): array
    {
        $fields = [];

        foreach ($data as $key => $value) {
            $fields[$key] = $this->toFirestoreValue($value);
        }

        return ['fields' => $fields];
    }

    private function toFirestoreValue(mixed $value): array
    {
        if (is_string($value)) {
            return ['stringValue' => $value];
        }

        if (is_int($value)) {
            return ['integerValue' => (string) $value];
        }

        if (is_float($value)) {
            return ['doubleValue' => $value];
        }

        if (is_bool($value)) {
            return ['booleanValue' => $value];
        }

        if ($value === null) {
            return ['nullValue' => null];
        }

        if (is_array($value) && array_is_list($value)) {
            return [
                'arrayValue' => [
                    'values' => array_map(fn ($v) => $this->toFirestoreValue($v), $value),
                ],
            ];
        }

        if (is_array($value)) {
            $mapFields = [];
            foreach ($value as $k => $v) {
                $mapFields[$k] = $this->toFirestoreValue($v);
            }

            return ['mapValue' => ['fields' => $mapFields]];
        }

        return ['stringValue' => (string) $value];
    }
}
