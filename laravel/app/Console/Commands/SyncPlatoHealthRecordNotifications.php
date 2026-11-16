<?php

namespace App\Console\Commands;

use App\Services\PlatoHealthRecordNotificationService;
use Illuminate\Console\Command;

class SyncPlatoHealthRecordNotifications extends Command
{
    protected $signature = 'plato:sync-health-record-notifications';

    protected $description = 'Discover new Plato Labs, Radiology and MC records and notify patients';

    public function handle(PlatoHealthRecordNotificationService $service): int
    {
        $stats = $service->run();

        $this->info(sprintf(
            'Patients: %d, discovered: %d, sent: %d, failed: %d.',
            $stats['patients'],
            $stats['discovered'],
            $stats['sent'],
            $stats['failed'],
        ));

        return Command::SUCCESS;
    }
}
