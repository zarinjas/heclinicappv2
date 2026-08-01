<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\NotificationLog;
use App\Notifications\AppointmentNotification;
use App\Notifications\GeneralNotification;
use App\Notifications\PatientDocumentUploaded;
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
            $patientId = $this->resolvePatientId($appointment);
            $this->sendPush($title, $body, [
                'parameter_data' => json_encode([
                    'appointment_id' => $appointment->id,
                    'plato_appointment_id' => $appointment->plato_appointment_id,
                    'patient_plato_id' => $patientId,
                ]),
                'initial_page_name' => 'MyBookingPage',
                'target_audience' => 'All',
                'type' => 'appointment_confirmed',
                'patient_ids' => $patientId !== null ? [$patientId] : [],
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
    {        if (empty(trim($recipientEmail))) {
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

    public function sendPatientDocumentUploadedEmail(array $document, string $recipientEmail, string $branchName = ''): bool
    {
        if (empty(trim($recipientEmail))) {
            Log::channel('plato')->warning('Patient document upload email skipped — no recipient email provided', [
                'document_id' => $document['id'] ?? null,
            ]);

            return false;
        }

        try {
            Notification::route('mail', $recipientEmail)
                ->notify(new PatientDocumentUploaded(
                    patientName: (string) ($document['patient_name'] ?? '—'),
                    patientNric: (string) ($document['patient_nric'] ?? '—'),
                    branchName: $branchName !== '' ? $branchName : '—',
                    platoId: (string) ($document['patient_plato_uid'] ?? '—'),
                    fileUrl: (string) ($document['url'] ?? '#'),
                    fileName: (string) ($document['original_name'] ?? '—'),
                    fileTitle: (string) ($document['title'] ?? '—'),
                ));

            Log::channel('plato')->info('Patient document upload email sent', [
                'recipient' => $recipientEmail,
                'document_id' => $document['id'] ?? null,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Patient document upload email failed', [
                'recipient' => $recipientEmail,
                'document_id' => $document['id'] ?? null,
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

    public function sendAppointmentReminder(Appointment $appointment, string $reminderType): void
    {
        $hours = $reminderType === '24h' ? 24 : 1;
        $title = sprintf('Appointment Reminder — %dh', $hours);
        $body = sprintf(
            'Your appointment with %s at %s on %s %s is in %d hours.',
            $appointment->doctor_name ?: 'our doctor',
            $appointment->branch_name ?: 'our clinic',
            $appointment->appointment_date->format('d M Y'),
            $appointment->appointment_time,
            $hours,
        );

        $channels = ['push', 'in_app'];

        if (in_array('push', $channels, true)) {
            $patientId = $this->resolvePatientId($appointment);
            $this->sendPush($title, $body, [
                'parameter_data' => json_encode([
                    'appointment_id' => $appointment->id,
                    'plato_appointment_id' => $appointment->plato_appointment_id,
                    'patient_plato_id' => $patientId,
                ]),
                'initial_page_name' => 'MyBookingPage',
                'target_audience' => 'All',
                'type' => 'appointment_reminder',
                'patient_ids' => $patientId !== null ? [$patientId] : [],
            ]);
        }

        if (in_array('in_app', $channels, true)) {
            $this->writeInAppNotify($title, $body, 'appointments', 'appointment_reminder', $appointment->patient_plato_id ?? null);
        }

        $timestampColumn = $reminderType === '24h' ? 'reminded_24h_at' : 'reminded_1h_at';
        $appointment->update([$timestampColumn => now()]);

        NotificationLog::create([
            'type' => 'appointment_reminder',
            'title' => $title,
            'body' => $body,
            'target_type' => 'appointment',
            'target_ids' => [(string) $appointment->id],
            'channels' => $channels,
            'status' => 'sent',
            'sent_at' => now(),
        ]);
    }

    public function sendDocumentUploadedNotification(string $patientPlatoId, string $filename, ?string $patientName = null): void
    {
        $title = 'New Document Available';
        $body = $patientName
            ? sprintf('A new document "%s" has been uploaded for %s.', $filename, $patientName)
            : sprintf('A new document "%s" has been uploaded to your records.', $filename);

        $channels = ['push', 'in_app'];

        if (in_array('push', $channels, true)) {
            $this->sendPush($title, $body, [
                'parameter_data' => json_encode([
                    'filename' => $filename,
                    'patient_plato_id' => $patientPlatoId,
                ]),
                'initial_page_name' => 'Reports',
                'target_audience' => 'All',
                'type' => 'document_uploaded',
                'patient_ids' => [$patientPlatoId],
            ]);
        }

        if (in_array('in_app', $channels, true)) {
            $this->writeInAppNotify($title, $body, 'health/documents', 'document_uploaded', $patientPlatoId);
        }

        NotificationLog::create([
            'type' => 'document_uploaded',
            'title' => $title,
            'body' => $body,
            'target_type' => 'patient',
            'target_ids' => [$patientPlatoId],
            'channels' => $channels,
            'status' => 'sent',
            'sent_at' => now(),
        ]);
    }

    public function sendManualNotification(NotificationLog $log): void
    {
        $channels = $log->channels ?? [];
        $targetType = $log->target_type;
        $targetIds = $log->target_ids ?? [];

        $patientId = null;
        if ($targetType === 'specific_patient' && ! empty($log->target_ids)) {
            $patientId = $this->resolvePatientIdByTerm((string) $log->target_ids[0]);
        }

        if (in_array('push', $channels, true)) {
            if ($targetType === 'specific_patient' && $patientId === null) {
                Log::channel('plato')->warning('Manual push skipped — could not resolve specific patient', [
                    'notification_log_id' => $log->id,
                    'term' => $log->target_ids[0] ?? null,
                ]);
            } else {
                $pushData = [
                    'parameter_data' => json_encode(['patient_id' => $patientId]),
                    'initial_page_name' => 'notificationPage',
                    'target_audience' => 'All',
                    'type' => 'manual',
                ];

                if ($targetType === 'branch') {
                    $pushData['branch_ids'] = $targetIds;
                } elseif ($targetType === 'doctor') {
                    $pushData['doctor_ids'] = $targetIds;
                } elseif ($targetType === 'appointment_date_range') {
                    $pushData['target_date_range'] = [
                        'from' => $log->target_date_from?->format('Y-m-d'),
                        'to' => $log->target_date_to?->format('Y-m-d'),
                    ];
                } elseif ($patientId !== null) {
                    $pushData['patient_ids'] = [$patientId];
                }

                $this->sendPush($log->title, $log->body, $pushData);
            }
        }

        if (in_array('email', $channels, true)) {
            if ($patientId !== null) {
                $recipientEmail = $this->resolvePatientEmailById($patientId);
                $this->sendManualEmailNotification($log->title, $log->body, $recipientEmail, $log->image_url);
            } else {
                Log::channel('plato')->warning('Manual email notification skipped — target is not a single patient', [
                    'notification_log_id' => $log->id,
                    'target_type' => $targetType,
                ]);
            }
        }

        if (in_array('in_app', $channels, true)) {
            $this->writeInAppNotify($log->title, $log->body, 'profile', 'manual', $patientId);
        }

        $log->update([
            'status' => 'sent',
            'sent_at' => now(),
        ]);
    }

    private function writeInAppNotify(string $title, string $body, string $deepLink, string $type, ?string $idPatient): void
    {
        $this->firebase->writeInAppNotification([
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'deep_link' => $deepLink,
            'id_patient' => $idPatient,
        ]);
    }

    private function sendInApp(string $title, string $body, Appointment $appointment, string $deepLink = 'appointments', string $type = 'appointment_confirmed'): void
    {
        $this->writeInAppNotify($title, $body, $deepLink, $type, $appointment->patient_plato_id ?? null);
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

    private function resolvePatientId(Appointment $appointment): ?string
    {
        if (! empty($appointment->patient_plato_id)) {
            return $appointment->patient_plato_id;
        }

        $platoResponse = $appointment->plato_response ?? [];

        if (! is_array($platoResponse)) {
            return null;
        }

        $patientId = $platoResponse['data']['patient_id'] ?? $platoResponse['patient_id'] ?? null;

        if (is_array($patientId)) {
            $patientId = $patientId['id'] ?? $patientId['_id'] ?? null;
        }

        return $patientId !== null ? (string) $patientId : null;
    }

    private function resolvePatientIdByTerm(string $term): ?string
    {
        $term = trim($term);

        if ($term === '') {
            return null;
        }

        $query = ['current_page' => 1];

        if (preg_match('/^\d{12}$/', $term)) {
            $query['ic'] = $term;
        } else {
            $query['name'] = $term;
        }

        try {
            $result = $this->platoProxy->proxy('GET', 'patient', $query);
            $patients = $this->extractPatients($result);

            foreach ($patients as $patient) {
                if (! empty($patient['_id'])) {
                    return (string) $patient['_id'];
                }
            }
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Failed to resolve patient id from Plato', [
                'term' => $term,
                'error' => $e->getMessage(),
            ]);
        }

        return null;
    }

    private function resolvePatientEmailById(string $patientId): ?string
    {
        try {
            $result = $this->platoProxy->proxy('GET', "patient/{$patientId}");

            $patient = $result['data'] ?? [];

            if (is_array($patient) && ! empty($patient['email']) && filter_var($patient['email'], FILTER_VALIDATE_EMAIL)) {
                return $patient['email'];
            }
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Failed to resolve patient email by id from Plato', [
                'patient_id' => $patientId,
                'error' => $e->getMessage(),
            ]);
        }

        return null;
    }

    private function extractPatients(array $result): array
    {
        if (! empty($result['data']) && is_array($result['data'])) {
            return $result['data'];
        }

        if (! empty($result['patients']) && is_array($result['patients'])) {
            return $result['patients'];
        }

        if (! empty($result[0]) && is_array($result)) {
            return $result;
        }

        return [];
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
            $patients = $this->extractPatients($result);

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
