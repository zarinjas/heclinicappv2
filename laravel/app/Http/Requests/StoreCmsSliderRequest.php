<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCmsSliderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'image' => [$this->isMethod('put') ? 'nullable' : 'required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'title' => ['nullable', 'string', 'max:255'],
            'link_url' => ['nullable', 'url', 'max:500'],
            'is_active' => ['boolean'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ];
    }

    public function messages(): array
    {
        return [
            'image.required' => 'Please upload a slider image.',
            'image.image' => 'The file must be an image.',
            'image.max' => 'Image size must not exceed 5MB.',
        ];
    }
}
