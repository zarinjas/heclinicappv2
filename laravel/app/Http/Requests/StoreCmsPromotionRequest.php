<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCmsPromotionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'cta_text' => ['nullable', 'string', 'max:100'],
            'cta_link' => ['nullable', 'url', 'max:500'],
            'promo_code' => ['nullable', 'string', 'max:50'],
            'is_active' => ['boolean'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'The promotion title is required.',
            'description.required' => 'The promotion description is required.',
            'image.image' => 'The file must be an image.',
            'image.max' => 'Image size must not exceed 5MB.',
        ];
    }
}
