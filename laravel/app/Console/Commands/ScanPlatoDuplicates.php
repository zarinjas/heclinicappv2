<?php

namespace App\Console\Commands;

use App\Services\PlatoDuplicateService;
use Illuminate\Console\Command;

class ScanPlatoDuplicates extends Command
{
    protected $signature = 'plato:scan-duplicates';

    protected $description = 'Scan Plato for duplicate patients (same NRIC or phone) and save a read-only report snapshot';

    public function handle(PlatoDuplicateService $duplicates): int
    {
        $this->info('Scanning Plato for duplicate patients...');

        try {
            $snapshot = $duplicates->scan(function (int $page, int $count): void {
                $this->line("  Page {$page} — {$count} patient(s) collected so far");
            });
        } catch (\Throwable $e) {
            $this->error($e->getMessage());

            return Command::FAILURE;
        }

        $this->info(
            "Done. Scanned {$snapshot['total_scanned']} patient(s), found {$snapshot['cluster_count']} duplicate cluster(s)."
        );
        $this->line('Snapshot: '.$duplicates->snapshotPath());

        return Command::SUCCESS;
    }
}
