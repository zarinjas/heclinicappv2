<?php

namespace App\Services;

use App\Models\Appointment;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

final class AppointmentService
{
    private PlatoProxyService $plato;
    private NotificationService $notifications;

    public function __construct(PlatoProxyService $plato, NotificationService $notifications)
    {
        $this->plato = $plato;
        $this->notifications = $notifications;
    }

    public function createAppointment(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $appointment = Appointment::create([
                'patient_name' => $data['patient_name'],
                'patient_nric' => $data['patient_nric'] ?? null,
                'patient_phone' => $data['patient_phone'],
                'branch_id' => $data['branch_id'] ?? null,
                'branch_name' => $data['branch_name'] ?? null,
                'doctor_id' => $data['doctor_id'] ?? null,
                'doctor_name' => $data['doctor_name'] ?? null,
                'appointment_date' => $data['appointment_date'],
                'appointment_time' => $data['appointment_time'],
                'calendar_color_id' => $data['calendar_color_id'] ?? null,
                'notes' => $data['notes'] ?? null,
                'status' => 'pending',
            ]);

            $platoPayload = $this->buildPlatoPayload($appointment);

            $result = $this->plato->proxy('POST', 'appointment', [], $platoPayload);

            if (! empty($result['error'])) {
                $errorMessage = $result['message'] ?? 'Plato API returned an error';
                $appointment->update([
                    'status' => 'failed',
                    'plato_response' => $result,
                ]);

                Log::channel('plato')->error('Plato appointment creation failed', [
                    'appointment_id' => $appointment->id,
                    'error' => $errorMessage,
                    'response' => $result,
                ]);

                throw new \RuntimeException($errorMessage);
            }

            $platoAppointmentId = $result['data']['id'] ?? $result['data']['_id'] ?? null;

            $appointment->update([
                'plato_appointment_id' => $platoAppointmentId,
                'status' => 'confirmed',
                'plato_response' => $result,
            ]);

            try {
                $this->notifications->sendAppointmentConfirmation($appointment);
            } catch (\Exception $e) {
                Log::channel('plato')->warning('Notification dispatch failed', [
                    'appointment_id' => $appointment->id,
                    'error' => $e->getMessage(),
                ]);
            }

            return [
                'success' => true,
                'appointment' => $appointment->fresh(),
                'plato_appointment_id' => $platoAppointmentId,
            ];
        });
    }

    private function buildPlatoPayload(Appointment $appointment): array
    {
        $payload = [
            'name' => $appointment->patient_name,
            'phone' => $appointment->patient_phone,
            'date' => $appointment->appointment_date->format('Y-m-d'),
            'time' => $appointment->appointment_time,
        ];

        if ($appointment->calendar_color_id) {
            $payload['color'] = $appointment->calendar_color_id;
        }

        if ($appointment->patient_nric) {
            $payload['ic'] = $appointment->patient_nric;
        }

        if ($appointment->notes) {
            $payload['notes'] = $appointment->notes;
        }

        return $payload;
    }
}
