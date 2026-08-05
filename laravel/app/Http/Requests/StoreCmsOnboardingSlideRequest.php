<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCmsOnboardingSlideRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'title'          => ['required', 'string', 'max:255'],
            'subtitle'       => ['nullable', 'string', 'max:500'],
            'image'          => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'video'          => ['nullable', 'file', 'mimes:mp4,mov,m4v,webm', 'max:51200'],
            'gradient_start' => ['nullable', 'string', 'max:9'],
            'gradient_end'   => ['nullable', 'string', 'max:9'],
            'is_active'      => ['boolean'],
        ];
    }
}
