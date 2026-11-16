<?php

namespace App\Jobs;

use App\Console\Commands\ProcessLoyaltyEarnings;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

final class ProcessPlatoLoyaltyEarnings implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 1;

    public function handle(ProcessLoyaltyEarnings $command): void
    {
        $command->handle(app(\App\Services\PlatoProxyService::class), app(\App\Services\LoyaltyService::class));
    }
}
