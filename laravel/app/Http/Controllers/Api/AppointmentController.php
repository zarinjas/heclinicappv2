<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AppointmentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

final class AppointmentController extends Controller
{
    private AppointmentService $service;

    public function __construct(AppointmentService $service)
    {
        $this->service = $service;
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'patient_name' => ['required', 'string', 'max:255'],
            'patient_nric' => ['nullable', 'string', 'max:50'],
            'patient_phone' => ['required', 'string', 'max:30'],
            'branch_id' => ['nullable', 'integer', 'exists:branches,id'],
            'branch_name' => ['nullable', 'string', 'max:255'],
            'doctor_id' => ['nullable', 'integer', 'exists:doctors,id'],
            'doctor_name' => ['nullable', 'string', 'max:255'],
            'appointment_date' => ['required', 'date', 'date_format:Y-m-d'],
            'appointment_time' => ['required', 'string', 'max:10'],
            'calendar_color_id' => ['nullable', 'string', 'max:50'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => true,
                'message' => 'Validation failed.',
                'errors' => $validator->errors()->toArray(),
            ], 422);
        }

        try {
            $result = $this->service->createAppointment($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Appointment created successfully.',
                'plato_appointment_id' => $result['plato_appointment_id'],
                'appointment' => [
                    'id' => $result['appointment']->id,
                    'patient_name' => $result['appointment']->patient_name,
                    'doctor_name' => $result['appointment']->doctor_name,
                    'branch_name' => $result['appointment']->branch_name,
                    'appointment_date' => $result['appointment']->appointment_date->format('Y-m-d'),
                    'appointment_time' => $result['appointment']->appointment_time,
                    'status' => $result['appointment']->status,
                ],
            ], 201);
        } catch (\RuntimeException $e) {
            return response()->json([
                'error' => true,
                'message' => $e->getMessage(),
            ], 502);
        } catch (\Exception $e) {
            return response()->json([
                'error' => true,
                'message' => 'An unexpected error occurred while creating the appointment.',
            ], 500);
        }
    }
}
