<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\NotificationLog;
use App\Models\Patient;
use App\Models\PatientNotification;
use App\Jobs\SendPushNotification;
use App\Notifications\AppointmentNotification;
use App\Notifications\GeneralNotification;
use App\Notifications\PatientDocumentUploaded;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Notification;

final class NotificationService
{
    private FirebaseService $firebase;
    private PlatoProxyService $platoProxy;
    private FcmService $fcm;

    public function __construct(FirebaseService $firebase, PlatoProxyService $platoProxy, FcmService $fcm)
    {
        $this->firebase = $firebase;
        $this->platoProxy = $platoProxy;
        $this->fcm = $fcm;
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

        $delivered = [];

        if (in_array('push', $selectedChannels, true)) {
            $patientId = $this->resolvePatientId($appointment);
            $result = $this->sendPush($title, $body, [
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
            $delivered['push'] = (bool) ($result['success'] ?? false);
        }

        if (in_array('in_app', $selectedChannels, true)) {
            $delivered['in_app'] = $this->sendInApp($title, $body, $appointment);
        }

        if (in_array('email', $selectedChannels, true)) {
            $recipientEmail = $this->resolvePatientEmailForAppointment($appointment);
            $delivered['email'] = $this->sendEmail($title, $body, $recipientEmail, $appointment);
        }

        $appointment->update(['notified_at' => now()]);

        NotificationLog::create([
            'type' => 'appointment_confirmation',
            'title' => $title,
            'body' => $body,
            'target_type' => 'appointment',
            'target_ids' => [(string) $appointment->id],
            'channels' => $selectedChannels,
            'status' => $this->resolveLogStatus($delivered),
            'sent_at' => now(),
        ]);
    }

    /**
     * Reduce per-channel delivery outcomes to a single log status so the admin
     * UI stops reporting "sent" for notifications that never went out.
     *
     * @param  array<string, bool>  $delivered
     */
    private function resolveLogStatus(array $delivered): string
    {
        if ($delivered === []) {
            return 'failed';
        }

        if (in_array(true, $delivered, true)) {
            return in_array(false, $delivered, true) ? 'partial' : 'sent';
        }

        return 'failed';
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

    public function sendManualEmailNotification(string $title, string $body, ?string $recipientEmail, ?string $imageUrl = null): bool
    {
        if (empty(trim((string) $recipientEmail))) {
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
                    // Emailed links need a longer life than in-app ones, since
                    // staff may not open the message immediately.
                    fileUrl: isset($document['id'])
                        ? app(PatientDocumentService::class)->signedUrl(
                            (int) $document['id'],
                            (int) config('documents.email_link_ttl_minutes', 10080),
                        )
                        : (string) ($document['url'] ?? '#'),
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

    private function sendPush(string $title, string $body, array $options, ?int $logId = null): array
    {
        $payload = array_merge([
            'title' => $title,
            'body' => $body,
            'initial_page_name' => 'Appointments',
            'target_audience' => 'All',
        ], $options);

        // Preferred path: send straight from Laravel via FCM HTTP v1 using the
        // device tokens we already store on the patients table at login.
        if ($this->fcm->isConfigured()) {
            $tokens = $this->resolveDeviceTokens($payload);

            if ($tokens === []) {
                Log::channel('plato')->warning('Push notification skipped — no registered device tokens', [
                    'title' => $title,
                    'patient_ids' => $payload['patient_ids'] ?? [],
                ]);

                return ['success' => false, 'error' => 'No registered device tokens for the target audience.'];
            }

            $data = [
                'initialPageName' => $payload['initial_page_name'] ?? '',
                'parameterData' => $payload['parameter_data'] ?? '',
                'type' => $payload['type'] ?? 'manual',
            ];
            $imageUrl = $payload['image_url'] ?? null;

            // FCM v1 sends one HTTP request per device, so anything larger than
            // a single chunk goes to the queue to keep the request fast.
            if (count($tokens) > SendPushNotification::CHUNK_SIZE) {
                foreach (array_chunk($tokens, SendPushNotification::CHUNK_SIZE) as $chunk) {
                    SendPushNotification::dispatch($chunk, $title, $body, $data, $imageUrl, $logId);
                }

                Log::channel('plato')->info('Push notification queued', [
                    'title' => $title,
                    'devices' => count($tokens),
                ]);

                return ['success' => true, 'queued' => true, 'devices' => count($tokens)];
            }

            $result = $this->fcm->sendToTokens($tokens, $title, $body, $data, $imageUrl);

            // Drop tokens FCM told us are permanently dead so we stop retrying them.
            if (! empty($result['invalid_tokens'])) {
                Patient::whereIn('fcm_token', $result['invalid_tokens'])->update(['fcm_token' => null]);
            }

            if (($result['success'] ?? 0) < 1) {
                Log::channel('plato')->warning('Push notification failed', [
                    'error' => $result['error'] ?? 'All sends failed',
                    'failure' => $result['failure'] ?? 0,
                ]);

                return ['success' => false, 'error' => $result['error'] ?? 'All sends failed'] + $result;
            }

            return ['success' => true] + $result;
        }

        // Fallback: the legacy Firestore queue consumed by the Cloud Function.
        $result = $this->firebase->writePushNotification($payload);

        if (!($result['success'] ?? false)) {
            Log::channel('plato')->warning('Push notification failed', [
                'error' => $result['error'] ?? 'Unknown',
            ]);
        }

        return $result;
    }

    /**
     * Resolve device tokens for a push payload.
     *
     * @param  array<string, mixed>  $payload
     * @return array<int, string>
     */
    private function resolveDeviceTokens(array $payload): array
    {
        $query = Patient::query()->whereNotNull('fcm_token')->where('fcm_token', '!=', '');

        $patientIds = array_filter((array) ($payload['patient_ids'] ?? []));

        if ($patientIds !== []) {
            return $query->whereIn('idplato', $patientIds)->pluck('fcm_token')->all();
        }

        $branchIds = array_filter((array) ($payload['branch_ids'] ?? []));
        $doctorIds = array_filter((array) ($payload['doctor_ids'] ?? []));
        $dateRange = $payload['target_date_range'] ?? null;

        // Branch, doctor and date-range targeting all resolve through appointments.
        if ($branchIds !== [] || $doctorIds !== [] || is_array($dateRange)) {
            $appointments = Appointment::query()
                ->whereNotNull('patient_plato_id')
                ->when($branchIds !== [], fn ($q) => $q->whereIn('branch_id', $branchIds))
                ->when($doctorIds !== [], fn ($q) => $q->whereIn('doctor_id', $doctorIds))
                ->when(
                    is_array($dateRange) && ! empty($dateRange['from']) && ! empty($dateRange['to']),
                    fn ($q) => $q->whereBetween('appointment_date', [$dateRange['from'], $dateRange['to']]),
                )
                ->pluck('patient_plato_id')
                ->unique()
                ->all();

            if ($appointments === []) {
                return [];
            }

            return $query->whereIn('idplato', $appointments)->pluck('fcm_token')->all();
        }

        // No targeting supplied — broadcast to every registered device.
        return $query->pluck('fcm_token')->all();
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
        $delivered = [];

        if (in_array('push', $channels, true)) {
            $patientId = $this->resolvePatientId($appointment);
            $result = $this->sendPush($title, $body, [
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
            $delivered['push'] = (bool) ($result['success'] ?? false);
        }

        if (in_array('in_app', $channels, true)) {
            $delivered['in_app'] = $this->writeInAppNotify($title, $body, 'appointments', 'appointment_reminder', $appointment->patient_plato_id ?? null);
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
            'status' => $this->resolveLogStatus($delivered),
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
        $delivered = [];

        if (in_array('push', $channels, true)) {
            $result = $this->sendPush($title, $body, [
                'parameter_data' => json_encode([
                    'filename' => $filename,
                    'patient_plato_id' => $patientPlatoId,
                ]),
                'initial_page_name' => 'Reports',
                'target_audience' => 'All',
                'type' => 'document_uploaded',
                'patient_ids' => [$patientPlatoId],
            ]);
            $delivered['push'] = (bool) ($result['success'] ?? false);
        }

        if (in_array('in_app', $channels, true)) {
            $delivered['in_app'] = $this->writeInAppNotify($title, $body, 'health/documents', 'document_uploaded', $patientPlatoId);
        }

        NotificationLog::create([
            'type' => 'document_uploaded',
            'title' => $title,
            'body' => $body,
            'target_type' => 'patient',
            'target_ids' => [$patientPlatoId],
            'channels' => $channels,
            'status' => $this->resolveLogStatus($delivered),
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

        $delivered = [];
        $queued = false;

        if (in_array('push', $channels, true)) {
            if ($targetType === 'specific_patient' && $patientId === null) {
                Log::channel('plato')->warning('Manual push skipped — could not resolve specific patient', [
                    'notification_log_id' => $log->id,
                    'term' => $log->target_ids[0] ?? null,
                ]);
                $delivered['push'] = false;
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

                $result = $this->sendPush($log->title, $log->body, $pushData, $log->id);
                $delivered['push'] = (bool) ($result['success'] ?? false);
                $queued = $queued || (bool) ($result['queued'] ?? false);
            }
        }

        if (in_array('email', $channels, true)) {
            if ($patientId !== null) {
                $recipientEmail = $this->resolvePatientEmailById($patientId);
                $delivered['email'] = $this->sendManualEmailNotification($log->title, $log->body, $recipientEmail, $log->image_url);
            } else {
                Log::channel('plato')->warning('Manual email notification skipped — target is not a single patient', [
                    'notification_log_id' => $log->id,
                    'target_type' => $targetType,
                ]);
                $delivered['email'] = false;
            }
        }

        if (in_array('in_app', $channels, true)) {
            $delivered['in_app'] = $this->writeInAppNotify($log->title, $log->body, 'profile', 'manual', $patientId, $log->image_url);
        }

        $log->update([
            // Queued sends report their own outcome as each batch completes, so
            // don't overwrite that with a provisional status here.
            'status' => $queued ? 'sending' : $this->resolveLogStatus($delivered),
            'sent_at' => now(),
        ]);
    }

    private function writeInAppNotify(string $title, string $body, string $deepLink, string $type, ?string $idPatient, ?string $imageUrl = null): bool
    {
        // Primary store: our own DB, read by the app over the authenticated API.
        $stored = false;

        if ($idPatient !== null && $idPatient !== '') {
            try {
                PatientNotification::create([
                    'patient_plato_id' => $idPatient,
                    'type' => $type,
                    'title' => $title,
                    'body' => $body,
                    'deep_link' => $deepLink,
                    'image_url' => $imageUrl,
                ]);
                $stored = true;
            } catch (\Exception $e) {
                Log::channel('plato')->warning('In-app notification store failed', [
                    'patient_plato_id' => $idPatient,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        // Legacy mirror to Firestore, kept so older app builds still see the
        // inbox. Its outcome does not affect the reported delivery status.
        $this->firebase->writeInAppNotification([
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'deep_link' => $deepLink,
            'id_patient' => $idPatient,
        ]);

        return $stored;
    }

    private function sendInApp(string $title, string $body, Appointment $appointment, string $deepLink = 'appointments', string $type = 'appointment_confirmed'): bool
    {
        return $this->writeInAppNotify($title, $body, $deepLink, $type, $appointment->patient_plato_id ?? null);
    }

    private function sendEmail(string $title, string $body, ?string $recipientEmail, ?Appointment $appointment = null): bool
    {
        if ($recipientEmail === null || trim($recipientEmail) === '') {
            Log::channel('plato')->warning('Email notification skipped — no recipient email available', [
                'appointment_id' => $appointment?->id,
                'title' => $title,
            ]);

            return false;
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

            return true;
        } catch (\Exception $e) {
            Log::channel('plato')->warning('Email notification failed', [
                'appointment_id' => $appointment?->id,
                'recipient' => $recipientEmail,
                'error' => $e->getMessage(),
            ]);

            return false;
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

        // Preferred path: the local patients table already stores idplato +
        // fcm_token, so a match there is exact and needs no Plato round-trip.
        $local = Patient::query()
            ->when(preg_match('/^\d{12}$/', $term), fn ($q) => $q->where('nric', $term))
            ->when(
                ! preg_match('/^\d{12}$/', $term) && ! str_contains($term, '@'),
                fn ($q) => $q->where('name', 'like', "%{$term}%"),
            )
            ->whereNotNull('idplato')
            ->first();

        if ($local !== null) {
            return (string) $local->idplato;
        }

        // Fall back to Plato search. The `patient` endpoint ignores nric/name
        // filters and just returns the paged list, so lookups must go through
        // `search/patient` instead.
        $query = ['current_page' => 1];

        if (preg_match('/^\d{12}$/', $term)) {
            $query['nric'] = $term;
        } else {
            $query['name'] = $term;
        }

        try {
            $result = $this->platoProxy->proxy('GET', 'search/patient', $query);
            $patients = $this->extractPatients($result);

            // Plato can hold several records for one NRIC. Prefer the record
            // already linked to a local app account (patients.idplato), since
            // that account is the one that registered a device token. Fall back
            // to the earliest-created record, mirroring the check-nric flow.
            $linked = Patient::whereIn(
                'idplato',
                array_values(array_filter(array_column($patients, '_id'))),
            )->pluck('idplato')->first();

            if ($linked !== null) {
                return (string) $linked;
            }

            $first = collect($patients)->sortBy('created_on')->first();

            if (! empty($first['_id'])) {
                return (string) $first['_id'];
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
            $patients = $this->extractPatients($result);

            foreach ($patients as $patient) {
                if (! empty($patient['email']) && filter_var($patient['email'], FILTER_VALIDATE_EMAIL)) {
                    return $patient['email'];
                }
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
                $query['nric'] = $appointment->patient_nric;
            } elseif (!empty($appointment->patient_name)) {
                $query['name'] = $appointment->patient_name;
            }

            $result = $this->platoProxy->proxy('GET', 'search/patient', $query);
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
