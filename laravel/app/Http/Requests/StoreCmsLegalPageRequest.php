<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCmsLegalPageRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'slug'           => ['required', 'string', 'max:50', 'unique:cms_legal_pages,slug,' . ($this->page?->id ?? 'NULL')],
            'title'          => ['required', 'string', 'max:255'],
            'last_updated'   => ['nullable', 'date'],
            'sections_json'  => ['nullable', 'string'],
            'is_active'      => ['boolean'],
        ];
    }
}
