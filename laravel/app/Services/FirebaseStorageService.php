<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

final class FirebaseStorageService
{
    private string $bucket;
    private string $webApiKey;

    public function __construct()
    {
        $projectId = config('firebase.project_id', 'heclinicapps-8be27');
        $this->bucket = sprintf('%s.appspot.com', $projectId);
        $this->webApiKey = config('firebase.web_api_key', '');
    }

    public function listDocuments(string $patientId): array
    {
        $prefix = sprintf('patients/%s/documents/', $patientId);
        $url = sprintf(
            'https://firebasestorage.googleapis.com/v0/b/%s/o',
            $this->bucket
        );

        try {
            $response = Http::timeout(10)
                ->acceptJson()
                ->get($url, [
                    'prefix' => $prefix,
                    'key' => $this->webApiKey,
                ]);

            if (! $response->successful()) {
                Log::channel('plato')->warning('Firebase Storage list failed', [
                    'prefix' => $prefix,
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                return [];
            }

            $data = $response->json();
            $items = $data['items'] ?? [];
            $documents = [];

            foreach ($items as $item) {
                $name = $item['name'];
                if ($name === $prefix) {
                    continue;
                }

                $documents[] = [
                    'name' => basename($name),
                    'url' => $this->getDownloadUrl($name),
                    'uploaded_at' => $item['timeCreated'] ?? null,
                    'size_bytes' => (int) ($item['size'] ?? 0),
                    'admin_note' => $item['metadata']['admin_note'] ?? null,
                ];
            }

            usort($documents, fn ($a, $b) => strtotime($b['uploaded_at'] ?? '') <=> strtotime($a['uploaded_at'] ?? ''));

            return $documents;
        } catch (\Exception $e) {
            Log::channel('plato')->error('Firebase Storage list exception', [
                'prefix' => $prefix,
                'error' => $e->getMessage(),
            ]);

            return [];
        }
    }

    public function getDownloadUrl(string $objectPath): string
    {
        return sprintf(
            'https://firebasestorage.googleapis.com/v0/b/%s/o/%s?alt=media&token=%s',
            $this->bucket,
            urlencode($objectPath),
            $this->webApiKey,
        );
    }
}
