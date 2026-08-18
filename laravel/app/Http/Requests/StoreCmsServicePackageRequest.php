<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCmsServicePackageRequest extends FormRequest
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
            'items' => ['nullable', 'string'],
            'image' => [$this->isMethod('put') ? 'nullable' : 'required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'gallery' => ['nullable', 'array', 'max:12'],
            'gallery.*' => ['image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'whatsapp_number' => ['nullable', 'string', 'max:20'],
            'keep_gallery' => ['nullable', 'array'],
            'is_active' => ['boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Please enter a package name.',
            'image.required' => 'Please upload a package image.',
            'image.image' => 'The file must be an image.',
            'image.max' => 'Image size must not exceed 5MB.',
            'gallery.max' => 'You can upload up to 12 gallery images.',
            'gallery.*.image' => 'Each gallery file must be an image.',
            'gallery.*.max' => 'Each gallery image must not exceed 5MB.',
        ];
    }
}
