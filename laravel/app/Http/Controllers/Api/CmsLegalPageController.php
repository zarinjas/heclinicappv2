<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsLegalPage;

class CmsLegalPageController extends Controller
{
    public function show($slug)
    {
        $page = CmsLegalPage::where('slug', $slug)->where('is_active', true)->first();

        if (! $page) {
            return response()->json(['error' => true, 'message' => 'Not found'], 404);
        }

        return response()->json([
            'title'        => $page->title,
            'last_updated' => $page->last_updated?->format('F Y'),
            'sections'     => $page->sections,
        ]);
    }
}
