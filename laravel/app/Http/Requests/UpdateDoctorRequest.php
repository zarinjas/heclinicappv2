<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateDoctorRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'specialty' => ['nullable', 'string', 'max:255'],
            'bio' => ['nullable', 'string', 'max:500'],
            'photo' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
            'branch_id' => ['required', 'exists:branches,id'],
            'plato_facility_id' => ['nullable', 'string', 'max:100', 'unique:doctors,plato_facility_id,' . $this->doctor?->id],
            'is_visible_in_app' => ['boolean'],
            'is_active' => ['boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'photo.max' => 'Photo must not exceed 2MB.',
            'photo.mimes' => 'Photo must be a JPG, JPEG, PNG, or WebP image.',
            'branch_id.required' => 'Please select a branch.',
        ];
    }
}
