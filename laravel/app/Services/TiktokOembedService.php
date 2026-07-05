<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

final class TiktokOembedService
{
    private const OEMBED_URL = 'https://www.tiktok.com/oembed';

    public function fetch(string $tiktokUrl): ?array
    {
        $response = Http::timeout(10)
            ->get(self::OEMBED_URL, [
                'url' => $tiktokUrl,
            ]);

        if (! $response->successful()) {
            return null;
        }

        $data = $response->json();

        return [
            'title' => $data['title'] ?? null,
            'thumbnail_url' => $data['thumbnail_url'] ?? null,
            'author_name' => $data['author_name'] ?? null,
        ];
    }
}
