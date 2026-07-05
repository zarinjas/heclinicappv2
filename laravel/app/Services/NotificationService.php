<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\NotificationLog;
use App\Notifications\AppointmentNotification;
use App\Notifications\GeneralNotification;
use Illuminate\Notifications\AnonymousNotifiable;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Notification;

final class NotificationService
{
    private FirebaseService $firebase;
    private PlatoProxyService $platoProxy;

    public function __construct(FirebaseService $firebase, PlatoProxyService $platoProxy)
    {
        $this->firebase = $firebase;
        $this->platoProxy = $platoProxy;
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
            $recipientEmail = $this->resolvePatientEmailForAppointment($appointment);
            $this->sendEmail($title, $body, $recipientEmail, $appointment);
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

    public function sendManualEmailNotification(string $title, string $body, string $recipientEmail, ?string $imageUrl = null): bool
    {
        if (empty(trim($recipientEmail))) {
            Log::channel('plato')->warning('Manual email notification skipped — no recipient email provided', [
                'title' => $title,
            ]);

            return false;
        }

        try {
            Notification::route('mail', $recipientEmail)
                ->notify(new GeneralNotification($title, $body, $imageUrl));

            Log::channel('plato')->info('Manual email notification sent', [
                'recipient' => $recipientEmail,
                'title' => $title,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Manual email notification failed', [
                'recipient' => $recipientEmail,
                'title' => $title,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
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

    private function sendInApp(string $title, string $body, Appointment $appointment, string $deepLink = 'appointments', string $type = 'appointment_confirmed'): void
    {
        $this->firebase->writeInAppNotification([
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'deep_link' => $deepLink,
            'id_patient' => $appointment->patient_plato_id ?? null,
        ]);
    }

    private function sendEmail(string $title, string $body, ?string $recipientEmail, ?Appointment $appointment = null): void
    {
        if ($recipientEmail === null || trim($recipientEmail) === '') {
            Log::channel('plato')->warning('Email notification skipped — no recipient email available', [
                'appointment_id' => $appointment?->id,
                'title' => $title,
            ]);

            return;
        }

        try {
            $appointmentData = [];
            if ($appointment !== null) {
                $appointmentData = [
                    'doctor_name' => $appointment->doctor_name,
                    'branch_name' => $appointment->branch_name,
                    'appointment_date' => $appointment->appointment_date?->format('d M Y'),
                    'appointment_time' => $appointment->appointment_time,
                ];
            }

            Notification::route('mail', $recipientEmail)
                ->notify(new AppointmentNotification($title, $body, $appointmentData));

            Log::channel('plato')->info('Email notification sent', [
                'recipient' => $recipientEmail,
                'appointment_id' => $appointment?->id,
                'title' => $title,
            ]);
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Email notification failed', [
                'appointment_id' => $appointment?->id,
                'recipient' => $recipientEmail,
                'error' => $e->getMessage(),
            ]);
        }
    }

    private function resolvePatientEmailForAppointment(Appointment $appointment): ?string
    {
        if (empty($appointment->patient_nric) && empty($appointment->patient_name)) {
            Log::channel('plato')->warning('Cannot resolve patient email — no NRIC or name on appointment', [
                'appointment_id' => $appointment->id,
            ]);

            return null;
        }

        try {
            $query = ['current_page' => 1];
            if (!empty($appointment->patient_nric)) {
                $query['ic'] = $appointment->patient_nric;
            }
            if (!empty($appointment->patient_name)) {
                $query['name'] = $appointment->patient_name;
            }

            $result = $this->platoProxy->proxy('GET', 'patient', $query);

            if (!empty($result['data']) && is_array($result['data'])) {
                $patients = $result['data'];
            } elseif (!empty($result['patients']) && is_array($result['patients'])) {
                $patients = $result['patients'];
            } elseif (is_array($result) && !empty($result[0])) {
                $patients = $result;
            } else {
                $patients = [];
            }

            foreach ($patients as $patient) {
                if (!empty($patient['email']) && filter_var($patient['email'], FILTER_VALIDATE_EMAIL)) {
                    return $patient['email'];
                }
            }

            Log::channel('plato')->warning('No email found for patient in Plato', [
                'appointment_id' => $appointment->id,
                'patient_nric' => $appointment->patient_nric,
            ]);

            return null;
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Failed to resolve patient email from Plato', [
                'appointment_id' => $appointment->id,
                'patient_nric' => $appointment->patient_nric,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }
}
