<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCmsClinicInfoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'image' => [$this->isMethod('put') ? 'nullable' : 'required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'is_active' => ['boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'image.required' => 'Please upload a clinic info image.',
            'image.image' => 'The file must be an image.',
            'image.max' => 'Image size must not exceed 5MB.',
        ];
    }
}
