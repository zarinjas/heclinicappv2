<?php

namespace App\Console\Commands;

use App\Models\Appointment;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class SendAppointmentReminders extends Command
{
    protected $signature = 'app:send-appointment-reminders';
    protected $description = 'Send appointment reminders for 24h-before and 1h-before upcoming appointments';

    public function handle(NotificationService $notificationService): int
    {
        $twentyFourHourAppointments = Appointment::whereDate('appointment_date', now()->addDay()->toDateString())
            ->whereNull('reminded_24h_at')
            ->get();

        foreach ($twentyFourHourAppointments as $appointment) {
            try {
                $notificationService->sendAppointmentReminder($appointment, '24h');
                $this->info("24h reminder sent for appointment {$appointment->id}");
            } catch (\Exception $e) {
                Log::channel('plato')->error('Failed to send 24h reminder', [
                    'appointment_id' => $appointment->id,
                    'error' => $e->getMessage(),
                ]);
                $this->error("Failed 24h reminder for appointment {$appointment->id}: {$e->getMessage()}");
            }
        }

        $oneHourAppointments = Appointment::whereDate('appointment_date', now()->toDateString())
            ->whereTime('appointment_time', '>=', now()->format('H:i'))
            ->whereTime('appointment_time', '<=', now()->addHour()->format('H:i'))
            ->whereNull('reminded_1h_at')
            ->get();

        foreach ($oneHourAppointments as $appointment) {
            try {
                $notificationService->sendAppointmentReminder($appointment, '1h');
                $this->info("1h reminder sent for appointment {$appointment->id}");
            } catch (\Exception $e) {
                Log::channel('plato')->error('Failed to send 1h reminder', [
                    'appointment_id' => $appointment->id,
                    'error' => $e->getMessage(),
                ]);
                $this->error("Failed 1h reminder for appointment {$appointment->id}: {$e->getMessage()}");
            }
        }

        $count = $twentyFourHourAppointments->count() + $oneHourAppointments->count();

        if ($count === 0) {
            $this->info('No appointment reminders due at this time.');
        }

        return Command::SUCCESS;
    }
}
