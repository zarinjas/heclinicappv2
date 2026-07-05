<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreAppointmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'patient_name' => ['required', 'string', 'max:255'],
            'patient_nric' => ['required', 'string', 'max:20'],
            'patient_phone' => ['required', 'string', 'max:20'],
            'branch_id' => ['required', 'exists:branches,id'],
            'branch_name' => ['required', 'string'],
            'doctor_id' => ['required', 'exists:doctors,id'],
            'doctor_name' => ['required', 'string'],
            'appointment_date' => ['required', 'date', 'after:today'],
            'appointment_time' => ['required', 'date_format:H:i'],
            'calendar_color_id' => ['nullable', 'string'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function messages(): array
    {
        return [
            'appointment_date.after' => 'The appointment date must be a future date.',
        ];
    }
}
