<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCmsArticleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', Rule::unique('cms_articles')->ignore($this->route('article'))],
            'body' => ['required', 'string'],
            'excerpt' => ['nullable', 'string'],
            'featured_image' => [$this->isMethod('put') ? 'nullable' : 'nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'category' => ['nullable', 'string', 'max:100'],
            'author_name' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', 'in:draft,published'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'published_at' => ['nullable', 'date'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Please enter an article title.',
            'body.required' => 'Please enter article content.',
            'featured_image.image' => 'The file must be an image.',
            'featured_image.max' => 'Image size must not exceed 5MB.',
        ];
    }
}
