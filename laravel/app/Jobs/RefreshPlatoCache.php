<?php

namespace App\Jobs;

use App\Services\PlatoProxyService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

final class RefreshPlatoCache implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 1;

    public function __construct(
        private readonly string $method,
        private readonly string $path,
        private readonly array $query = [],
        private readonly array $body = [],
    ) {}

    public function handle(PlatoProxyService $plato): void
    {
        $plato->proxy($this->method, $this->path, $this->query, $this->body, true);
    }
}
