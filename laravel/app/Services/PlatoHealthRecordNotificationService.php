<?php

namespace App\Services;

use App\Models\Patient;
use App\Models\PlatoHealthRecordEvent;
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
        $bootstrap = ! PlatoHealthRecordEvent::query()->exists();

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
                            $sourceKey = (string) $patient->idplato.':'.$recordId;

                            $event = PlatoHealthRecordEvent::firstOrCreate(
                                ['source_key' => $sourceKey],
                                [
                                    'patient_plato_id' => (string) $patient->idplato,
                                    'record_type' => (string) ($record['type'] ?? 'record'),
                                    'title' => (string) ($record['title'] ?? 'Health record'),
                                    'notified_at' => $bootstrap ? now() : null,
                                ],
                            );

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

        return $stats;
    }
}
