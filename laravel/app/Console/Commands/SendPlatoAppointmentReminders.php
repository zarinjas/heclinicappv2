<?php

namespace App\Console\Commands;

use App\Services\PlatoAppointmentReminderService;
use Illuminate\Console\Command;

class SendPlatoAppointmentReminders extends Command
{
    protected $signature = 'plato:send-appointment-reminders';

    protected $description = 'Send 3-day and 1-day reminders for upcoming Plato appointments set by clinic staff';

    public function handle(PlatoAppointmentReminderService $service): int
    {
        $this->info('Checking upcoming Plato appointments for reminders...');

        try {
            $stats = $service->run(function (string $patientId): void {
                $this->line("  Checked patient {$patientId}");
            });
        } catch (\Throwable $e) {
            $this->error($e->getMessage());

            return Command::FAILURE;
        }

        $this->info(sprintf(
            'Done. Patients checked: %d, sent: %d, skipped: %d, failed: %d.',
            $stats['patients'],
            $stats['sent'],
            $stats['skipped'],
            $stats['failed'],
        ));

        return Command::SUCCESS;
    }
}
