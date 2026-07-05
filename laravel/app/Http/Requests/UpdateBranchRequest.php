<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBranchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'address' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:50'],
            'whatsapp_number' => ['nullable', 'string', 'max:50', 'regex:/^\+60/'],
            'image' => ['nullable', 'string', 'max:255'],
            'operating_hours' => ['nullable', 'string', 'max:500'],
            'plato_facility_id' => ['nullable', 'string', 'max:100', 'unique:branches,plato_facility_id,' . $this->branch?->id],
            'is_active' => ['boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'whatsapp_number.regex' => 'WhatsApp number must start with +60 (Malaysia country code).',
        ];
    }
}
