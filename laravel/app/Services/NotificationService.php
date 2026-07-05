<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\NotificationLog;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

final class NotificationService
{
    private FirebaseService $firebase;

    public function __construct(FirebaseService $firebase)
    {
        $this->firebase = $firebase;
    }

    public function sendAppointmentConfirmation(Appointment $appointment, ?array $channels = null): void
    {
        $selectedChannels = $channels ?? ['push', 'email', 'in_app'];

        $title = 'Appointment Confirmed';
        $body = sprintf(
            'Your appointment with %s at %s on %s %s is confirmed.',
            $appointment->doctor_name ?: 'our doctor',
            $appointment->branch_name ?: 'our clinic',
            $appointment->appointment_date->format('d M Y'),
            $appointment->appointment_time,
        );

        if (in_array('push', $selectedChannels, true)) {
            $this->sendPush($title, $body, [
                'parameter_data' => json_encode([
                    'appointment_id' => $appointment->id,
                    'plato_appointment_id' => $appointment->plato_appointment_id,
                ]),
                'initial_page_name' => 'Appointments',
                'target_audience' => 'All',
            ]);
        }

        if (in_array('in_app', $selectedChannels, true)) {
            $this->sendInApp($title, $body, $appointment);
        }

        if (in_array('email', $selectedChannels, true)) {
            $this->sendEmail($title, $body, $appointment);
        }

        $appointment->update(['notified_at' => now()]);

        NotificationLog::create([
            'type' => 'appointment_confirmation',
            'title' => $title,
            'body' => $body,
            'target_type' => 'appointment',
            'target_ids' => [(string) $appointment->id],
            'channels' => $selectedChannels,
            'status' => 'sent',
            'sent_at' => now(),
        ]);
    }

    public function sendTargetedPush(string $title, string $body, array $targeting): array
    {
        $pushData = [
            'title' => $title,
            'body' => $body,
            'parameter_data' => $targeting['parameter_data'] ?? '',
            'initial_page_name' => $targeting['initial_page_name'] ?? 'Appointments',
            'target_audience' => $targeting['target_audience'] ?? 'All',
        ];

        if (!empty($targeting['user_refs'])) {
            $pushData['user_refs'] = $targeting['user_refs'];
        }

        if (!empty($targeting['branch_ids'])) {
            $pushData['branch_ids'] = $targeting['branch_ids'];
        }

        if (!empty($targeting['doctor_ids'])) {
            $pushData['doctor_ids'] = $targeting['doctor_ids'];
        }

        if (!empty($targeting['target_date_range'])) {
            $pushData['target_date_range'] = $targeting['target_date_range'];
        }

        return $this->sendPush($title, $body, $pushData);
    }

    private function sendPush(string $title, string $body, array $options): array
    {
        $payload = array_merge([
            'title' => $title,
            'body' => $body,
            'initial_page_name' => 'Appointments',
            'target_audience' => 'All',
        ], $options);

        $result = $this->firebase->writePushNotification($payload);

        if (!($result['success'] ?? false)) {
            Log::channel('plato')->warning('Push notification failed', [
                'error' => $result['error'] ?? 'Unknown',
            ]);
        }

        return $result;
    }

    private function sendInApp(string $title, string $body, Appointment $appointment): void
    {
        $this->firebase->writeInAppNotification([
            'title' => $title,
            'body' => $body,
            'type' => 'appointment_confirmed',
            'deep_link' => 'appointments',
        ]);
    }

    private function sendEmail(string $title, string $body, Appointment $appointment): void
    {
        try {
            Mail::raw($body, function ($message) use ($title) {
                $message->to(config('mail.from.address'))
                    ->subject($title);
            });
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Email notification failed', [
                'appointment_id' => $appointment->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
