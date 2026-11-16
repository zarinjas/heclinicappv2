<?php

namespace App\Services;

use App\Models\Patient;
use App\Models\PlatoHealthRecordEvent;
use App\Models\Setting;
use Illuminate\Support\Facades\Log;

final class PlatoHealthRecordNotificationService
{
    public function __construct(
        private readonly PlatoHealthRecordService $records,
        private readonly NotificationService $notifications,
    ) {}

    /**
     * @return array{patients:int, discovered:int, sent:int, failed:int}
     */
    public function run(?callable $progress = null): array
    {
        $stats = ['patients' => 0, 'discovered' => 0, 'sent' => 0, 'failed' => 0];
        $bootstrapKey = 'plato_health_record_notifications_bootstrapped';
        $bootstrap = ! Setting::query()->where('key', $bootstrapKey)->exists();

        Patient::query()
            ->whereNotNull('idplato')
            ->where('idplato', '!=', '')
            ->select(['id', 'idplato'])
            ->chunkById(100, function ($patients) use (&$stats, $bootstrap, $progress): void {
                foreach ($patients as $patient) {
                    $stats['patients']++;

                    try {
                        foreach ($this->records->recordsForPatient((string) $patient->idplato) as $record) {
                            $recordId = (string) ($record['id'] ?? '');
                            if ($recordId === '') {
                                continue;
                            }
                            $legacyKey = (string) $patient->idplato.':'.$recordId;
                            $sourceKey = (string) $patient->idplato.':'
                                .$this->logicalRecordKey($record);

                            // Existing deployments used the Plato row id as the
                            // key. Recognise it too, otherwise a key migration
                            // would notify all historical records again.
                            $event = PlatoHealthRecordEvent::query()
                                ->whereIn('source_key', [$legacyKey, $sourceKey])
                                ->first();

                            if ($event === null) {
                                $event = PlatoHealthRecordEvent::firstOrCreate(
                                    ['source_key' => $sourceKey],
                                    [
                                        'patient_plato_id' => (string) $patient->idplato,
                                        'record_type' => (string) ($record['type'] ?? 'record'),
                                        'title' => (string) ($record['title'] ?? 'Health record'),
                                        'notified_at' => $bootstrap ? now() : null,
                                    ],
                                );
                            }

                            if ($event->wasRecentlyCreated) {
                                $stats['discovered']++;
                            }

                            if ($bootstrap || $event->notified_at !== null) {
                                continue;
                            }

                            try {
                                $this->notifications->sendHealthRecordAvailableNotification(
                                    (string) $patient->idplato,
                                    (string) ($record['title'] ?? 'Health record'),
                                );
                                $event->update(['notified_at' => now()]);
                                $stats['sent']++;
                            } catch (\Throwable $e) {
                                $stats['failed']++;
                                Log::channel('plato')->error('Health record notification failed', [
                                    'patient_ref' => hash('sha256', (string) $patient->idplato),
                                    'error' => $e->getMessage(),
                                ]);
                            }
                        }
                    } catch (\Throwable $e) {
                        $stats['failed']++;
                        Log::channel('plato')->warning('Health record sync failed', [
                            'patient_ref' => hash('sha256', (string) $patient->idplato),
                            'error' => $e->getMessage(),
                        ]);
                    }

                    if ($progress !== null) {
                        $progress((string) $patient->idplato);
                    }
                }
            });

        if ($bootstrap) {
            Setting::updateOrCreate(
                ['key' => $bootstrapKey],
                [
                    'value' => now()->toIso8601String(),
                    'description' => 'Health record notification sync initialized',
                ],
            );
        }

        return $stats;
    }

    /**
     * Collapse duplicate Plato rows representing the same logical file.
     */
    private function logicalRecordKey(array $record): string
    {
        $type = (string) ($record['type'] ?? 'record');
        $detail = (string) ($record['detail_data'] ?? '');

        if (($record['is_file'] ?? false) && $detail !== '') {
            $uri = parse_url($detail);
            $stable = is_array($uri)
                ? strtolower((string) ($uri['host'] ?? '').(string) ($uri['path'] ?? ''))
                : strtolower($detail);

            return 'file:'.sha1($stable);
        }

        return 'text:'.sha1(implode('|', [
            $type,
            (string) ($record['title'] ?? ''),
            (string) ($record['date'] ?? ''),
            strip_tags($detail),
        ]));
    }
}
