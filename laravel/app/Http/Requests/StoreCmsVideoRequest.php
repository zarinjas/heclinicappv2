<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCmsVideoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'tiktok_url' => ['required', 'url', 'max:500'],
            'thumbnail_url' => ['required', 'string', 'max:500'],
            'tiktok_author' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', 'in:draft,published'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'published_at' => ['nullable', 'date'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Please enter a video title.',
            'tiktok_url.required' => 'Please enter a TikTok URL.',
            'tiktok_url.url' => 'Please enter a valid URL.',
            'thumbnail_url.required' => 'Thumbnail URL is required.',
        ];
    }
}
