<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreLoyaltyRewardRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'type' => ['required', Rule::in(['discount', 'service', 'product'])],
            'points_cost' => ['required', 'integer', 'min:1'],
            'service_package_id' => ['nullable', 'integer', 'exists:cms_service_packages,id'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'cta_text' => ['nullable', 'string', 'max:100'],
            'image' => [$this->isMethod('put') ? 'nullable' : 'nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Please enter a reward name.',
            'type.required' => 'Please choose a reward type.',
            'points_cost.required' => 'Please enter the points cost.',
            'points_cost.min' => 'Points cost must be at least 1.',
            'image.image' => 'The file must be an image.',
            'image.max' => 'Image size must not exceed 5MB.',
        ];
    }
}
