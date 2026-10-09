<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;

/**
 * Merges two Plato patient records into a single record.
 *
 * This is the ONE place the app writes a destructive change to Plato. The
 * action cannot be undone, so the service is inert unless explicitly enabled
 * via config and every call is logged.
 *
 * The exact request field names are not published in Plato's API docs (only
 * the mandatory `acknowledge` string is). They are therefore configurable so
 * the real contract can be confirmed with Plato without a code change.
 */
final class PlatoPatientMergeService
{
    public function __construct(private readonly PlatoProxyService $plato) {}

    public function enabled(): bool
    {
        return (bool) config('plato.merge.enabled', false);
    }

    public function path(): string
    {
        return (string) config('plato.merge.path', 'patient/merge');
    }

    public function acknowledgePhrase(): string
    {
        return (string) config(
            'plato.merge.acknowledge',
            'I understand that this action cannot be undone',
        );
    }

    /**
     * Build the body sent to Plato.
     *
     * @return array<string,string>
     */
    public function payload(string $survivorId, string $mergedId): array
    {
        $primaryField = (string) config('plato.merge.primary_field', 'primary_id');
        $secondaryField = (string) config('plato.merge.secondary_field', 'secondary_id');

        return [
            $primaryField => $survivorId,
            $secondaryField => $mergedId,
            'acknowledge' => $this->acknowledgePhrase(),
        ];
    }

    /**
     * Merge $mergedId into $survivorId at Plato.
     *
     * @return array<string,mixed> Standard proxy result (data + status, or error).
     */
    public function merge(string $survivorId, string $mergedId): array
    {
        Log::channel('plato')->info('Plato patient merge request', [
            'path' => $this->path(),
            'survivor_id' => $survivorId,
            'merged_id' => $mergedId,
        ]);

        $result = $this->plato->proxy('POST', $this->path(), [], $this->payload($survivorId, $mergedId));

        Log::channel('plato')->info('Plato patient merge response', [
            'survivor_id' => $survivorId,
            'merged_id' => $mergedId,
            'error' => $result['error'] ?? false,
            'code' => $result['code'] ?? 200,
            'message' => $result['message'] ?? null,
        ]);

        return $result;
    }
}
