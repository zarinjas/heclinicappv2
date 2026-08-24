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
            'email' => ['nullable', 'email', 'max:191'],
            'whatsapp_number' => ['nullable', 'string', 'max:50', 'regex:/^\+60/'],
            'image' => ['nullable'],
            'operating_hours' => ['nullable', 'array'],
            'operating_hours.*' => ['nullable', 'string', 'regex:/^([01]\d|2[0-3]):[0-5]\d-([01]\d|2[0-3]):[0-5]\d$/'],
            'google_maps_link' => ['nullable', 'url', 'max:500'],
            'plato_facility_id' => ['nullable', 'string', 'max:100', 'unique:branches,plato_facility_id,'.$this->branch?->id],
            'is_active' => ['boolean'],
            'is_visible_in_app' => ['boolean'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('operating_hours') && is_array($this->input('operating_hours'))) {
            $hours = array_filter($this->input('operating_hours'), fn ($v) => $v !== null && trim((string) $v) !== '');
            $this->merge(['operating_hours' => $hours ?: null]);
        }
    }

    public function messages(): array
    {
        return [
            'whatsapp_number.regex' => 'WhatsApp number must start with +60 (Malaysia country code).',
        ];
    }
}
