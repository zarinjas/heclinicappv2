<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\PlatoAppointmentReminder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;

/**
 * Sends reminders for upcoming Plato appointments that were NOT booked through
 * the app — e.g. follow-up treatments scheduled by clinic staff directly in
 * Plato. Reminders go out 3 days and 1 day before the appointment.
 *
 * App-booked appointments already get 24h/1h reminders from
 * App\Console\Commands\SendAppointmentReminders, so they are skipped here to
 * avoid duplicate notifications.
 */
class PlatoAppointmentReminderService
{
    /** Days before the appointment at which a reminder is sent. */
    public const OFFSETS = [3, 1];

    private const TIMEZONE = 'Asia/Kuala_Lumpur';

    private const MAX_PAGES = 200;

    public function __construct(
        private readonly PlatoProxyService $plato,
        private readonly NotificationService $notifications,
    ) {}

    /**
     * @return array{patients:int,sent:int,skipped:int,failed:int}
     */
    public function run(?callable $progress = null): array
    {
        $stats = ['patients' => 0, 'sent' => 0, 'skipped' => 0, 'failed' => 0];

        $today = Carbon::now(self::TIMEZONE)->startOfDay();

        // App-booked appointments are already covered by the 24h/1h job.
        $appBookedIds = Appointment::query()
            ->whereNotNull('plato_appointment_id')
            ->pluck('plato_appointment_id')
            ->flip();

        Patient::query()
            ->whereNotNull('idplato')
            ->where('idplato', '!=', '')
            ->select(['id', 'name', 'idplato'])
            ->chunkById(100, function ($patients) use (&$stats, $today, $appBookedIds, $progress): void {
                foreach ($patients as $patient) {
                    $stats['patients']++;

                    foreach ($this->upcomingAppointments($patient->idplato) as $appointment) {
                        $this->handleAppointment($patient, $appointment, $today, $appBookedIds, $stats);
                    }

                    if ($progress !== null) {
                        $progress((string) $patient->idplato);
                    }
                }
            });

        return $stats;
    }

    /**
     * @param  array<string,mixed>  $appointment
     * @param  Collection<string,int>  $appBookedIds
     * @param  array{patients:int,sent:int,skipped:int,failed:int}  $stats
     */
    private function handleAppointment(
        Patient $patient,
        array $appointment,
        Carbon $today,
        $appBookedIds,
        array &$stats,
    ): void {
        $id = (string) ($appointment['appointment_id'] ?? $appointment['id'] ?? '');
        $start = $appointment['starttime'] ?? null;

        if ($id === '' || empty($start)) {
            return;
        }

        if (isset($appBookedIds[$id])) {
            return;
        }

        try {
            $appointmentDate = Carbon::parse((string) $start, self::TIMEZONE)->startOfDay();
        } catch (\Throwable $e) {
            return;
        }

        $daysBefore = (int) $today->diffInDays($appointmentDate, false);

        if (! in_array($daysBefore, self::OFFSETS, true)) {
            return;
        }

        // Claim the reminder slot first so overlapping runs can't double-send.
        $claim = PlatoAppointmentReminder::firstOrCreate(
            [
                'plato_appointment_id' => $id,
                'offset_days' => $daysBefore,
            ],
            [
                'patient_plato_id' => $patient->idplato,
                'sent_at' => now(),
            ],
        );

        if (! $claim->wasRecentlyCreated) {
            $stats['skipped']++;

            return;
        }

        try {
            $this->notify($appointment, $patient, $daysBefore);
            $stats['sent']++;
        } catch (\Throwable $e) {
            // Release the claim so a later run can retry.
            $claim->delete();
            $stats['failed']++;

            Log::channel('plato')->error('Plato appointment reminder failed', [
                'plato_appointment_id' => $id,
                'patient_plato_id' => $patient->idplato,
                'days_before' => $daysBefore,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Dispatch the reminder. Kept as a seam so tests can capture sends without
     * touching FCM/Firebase.
     *
     * @param  array<string,mixed>  $appointment
     */
    protected function notify(array $appointment, Patient $patient, int $daysBefore): void
    {
        $this->notifications->sendPlatoAppointmentReminder(
            patientPlatoId: (string) $patient->idplato,
            platoAppointmentId: (string) ($appointment['appointment_id'] ?? $appointment['id'] ?? ''),
            starttime: (string) ($appointment['starttime'] ?? ''),
            doctor: $appointment['name_Background'] ?? $appointment['doctorname'] ?? null,
            branch: $appointment['name_Top'] ?? $appointment['branch_name'] ?? null,
            daysBefore: $daysBefore,
        );
    }

    /**
     * Fetch a patient's upcoming appointments from Plato (paginated).
     *
     * @return array<int, array<string,mixed>>
     */
    protected function upcomingAppointments(string $patientId): array
    {
        $all = [];
        $seen = [];
        $page = 1;

        while ($page <= self::MAX_PAGES) {
            $result = $this->plato->proxy('GET', 'appointment', [
                'patient_id' => $patientId,
                'start_date' => Carbon::now(self::TIMEZONE)->toDateString(),
                'current_page' => $page,
            ]);

            if (! empty($result['error'])) {
                break;
            }

            $rows = $result['data'] ?? [];
            if (! is_array($rows) || $rows === []) {
                break;
            }

            $new = 0;
            foreach ($rows as $row) {
                if (! is_array($row)) {
                    continue;
                }

                $id = (string) ($row['appointment_id'] ?? $row['id'] ?? '');
                if ($id !== '' && isset($seen[$id])) {
                    continue;
                }
                if ($id !== '') {
                    $seen[$id] = true;
                }

                $all[] = $row;
                $new++;
            }

            if ($new === 0) {
                break;
            }

            $page++;
        }

        return $all;
    }
}
