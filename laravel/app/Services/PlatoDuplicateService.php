<?php

namespace App\Services;

use App\Models\Patient;
use Illuminate\Support\Arr;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\File;

/**
 * Read-only duplicate detection across Plato patient records.
 *
 * Scans Plato's paginated patient list and groups records that share a
 * normalised NRIC ("same_ic", a strong signal) or a normalised phone number
 * ("same_phone", a weaker signal — families often share a number). Results are
 * written to a JSON snapshot so the admin page can render and export them
 * without re-hitting Plato on every request.
 *
 * This service NEVER writes to Plato. Merging duplicate records remains a
 * manual, human-reviewed task performed by clinic staff inside Plato.
 */
class PlatoDuplicateService
{
    /** Snapshot file, relative to storage/app/private. */
    public const SNAPSHOT_FILE = 'plato-duplicates.json';

    /** Safety cap so a misbehaving pagination loop can't run forever. */
    private const MAX_PAGES = 1000;

    public function __construct(private readonly PlatoProxyService $plato) {}

    // ---------------------------------------------------------------------
    // Public API
    // ---------------------------------------------------------------------

    /**
     * Full scan: fetch every Plato patient, build clusters, annotate which
     * records are linked to a local app account, and persist the snapshot.
     *
     * @param  callable(int $page, int $count)|null  $progress
     * @return array{scanned_at:string,total_scanned:int,cluster_count:int,clusters:array<int,array<string,mixed>>}
     */
    public function scan(?callable $progress = null): array
    {
        $records = $this->fetchAllPatients($progress);
        $clusters = $this->annotateWithAppAccounts($this->buildClusters($records));

        $snapshot = [
            'scanned_at' => Carbon::now()->toIso8601String(),
            'total_scanned' => count($records),
            'cluster_count' => count($clusters),
            'clusters' => $clusters,
        ];

        $this->writeSnapshot($snapshot);

        return $snapshot;
    }

    /**
     * Read the last snapshot, or null when a scan has never been run.
     */
    public function readSnapshot(): ?array
    {
        $path = $this->snapshotPath();

        if (! File::isFile($path)) {
            return null;
        }

        $decoded = json_decode((string) File::get($path), true);

        return is_array($decoded) ? $decoded : null;
    }

    /**
     * Persist a snapshot to disk. Public so it can be seeded in tests.
     */
    public function writeSnapshot(array $snapshot): void
    {
        $path = $this->snapshotPath();
        File::ensureDirectoryExists(dirname($path));
        File::put($path, json_encode($snapshot, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
    }

    public function snapshotPath(): string
    {
        $configured = config('plato.duplicate_snapshot_path');

        return is_string($configured) && $configured !== ''
            ? $configured
            : storage_path('app/private/'.self::SNAPSHOT_FILE);
    }

    // ---------------------------------------------------------------------
    // Plato fetch
    // ---------------------------------------------------------------------

    /**
     * Page through Plato's patient list until a page yields no new records.
     *
     * Plato's list endpoint does not return a total and its page size is not
     * guaranteed, so we iterate until a page contributes nothing new (empty
     * page, or a repeated page) rather than trusting a fixed page size.
     *
     * @param  callable(int, int)|null  $progress
     * @return array<int, array<string,mixed>>
     */
    public function fetchAllPatients(?callable $progress = null): array
    {
        $all = [];
        $seen = [];
        $page = 1;

        while ($page <= self::MAX_PAGES) {
            $result = $this->fetchPatientPage($page);

            if (! empty($result['error'])) {
                throw new \RuntimeException(
                    'Plato API error while listing patients: '.($result['message'] ?? 'unknown error')
                );
            }

            $rows = $result['data'] ?? [];
            if (! is_array($rows) || $rows === []) {
                break;
            }

            $new = 0;
            foreach ($rows as $row) {
                if (! is_array($row)) {
                    continue;
                }

                $id = (string) ($row['_id'] ?? '');
                if ($id !== '' && isset($seen[$id])) {
                    continue;
                }
                if ($id !== '') {
                    $seen[$id] = true;
                }

                $all[] = $row;
                $new++;
            }

            if ($progress !== null) {
                $progress($page, count($all));
            }

            if ($new === 0) {
                break;
            }

            $page++;
            $this->throttlePages();
        }

        return $all;
    }

    /**
     * Fetch one patient page, retrying with exponential backoff when Plato
     * answers HTTP 429 (rate limited). Honours Plato's retry-after header when
     * present. Gives up after the configured number of attempts so the caller
     * can surface a clear error instead of hammering the API.
     *
     * @return array<string,mixed>
     */
    protected function fetchPatientPage(int $page): array
    {
        $attempts = max(1, (int) config('plato.duplicate_scan.max_retries', 5));
        $baseMs = max(0, (int) config('plato.duplicate_scan.retry_base_ms', 1000));
        $result = [];

        for ($attempt = 0; $attempt < $attempts; $attempt++) {
            $result = $this->requestPatientPage($page);

            if (($result['code'] ?? null) !== 429) {
                return $result;
            }

            if ($attempt < $attempts - 1) {
                $this->pause($this->retryDelayMs($result, $baseMs, $attempt));
            }
        }

        return $result;
    }

    /**
     * @return array<string,mixed>
     */
    protected function requestPatientPage(int $page): array
    {
        return $this->plato->proxy('GET', 'patient', ['current_page' => $page]);
    }

    /**
     * Pause briefly between pages so a full scan stays under Plato's rate limit.
     */
    protected function throttlePages(): void
    {
        $this->pause(max(0, (int) config('plato.duplicate_scan.throttle_ms', 250)));
    }

    /**
     * @param  array<string,mixed>  $result
     */
    protected function retryDelayMs(array $result, int $baseMs, int $attempt): int
    {
        $retryAfter = $result['headers']['retry-after'] ?? null;

        if (is_numeric($retryAfter)) {
            return (int) $retryAfter * 1000;
        }

        return $baseMs * (2 ** $attempt);
    }

    protected function pause(int $milliseconds): void
    {
        if ($milliseconds > 0) {
            usleep($milliseconds * 1000);
        }
    }

    // ---------------------------------------------------------------------
    // Clustering
    // ---------------------------------------------------------------------

    /**
     * Build duplicate clusters from raw Plato records using union-find so that
     * overlapping NRIC and phone groups collapse into one cluster.
     *
     * @param  array<int, array<string,mixed>>  $records
     * @return array<int, array<string,mixed>>
     */
    public function buildClusters(array $records): array
    {
        $byId = [];
        foreach ($records as $record) {
            $id = (string) ($record['_id'] ?? '');
            if ($id === '') {
                continue;
            }
            $byId[$id] = $record;
        }

        if (count($byId) < 2) {
            return [];
        }

        $parent = [];
        foreach (array_keys($byId) as $id) {
            $parent[$id] = $id;
        }

        $nricGroups = $this->groupByField(
            $byId,
            fn (array $r): ?string => $this->normaliseNric($r['nric'] ?? null)
        );
        $phoneGroups = $this->groupByField(
            $byId,
            fn (array $r): ?string => $this->normalisePhone($r['telephone'] ?? $r['phone'] ?? null)
        );

        foreach ($nricGroups as $ids) {
            $this->unionAll($parent, $ids);
        }
        foreach ($phoneGroups as $ids) {
            $this->unionAll($parent, $ids);
        }

        // Attribute each signal to the component root it belongs to.
        $signals = [];
        foreach ($nricGroups as $ids) {
            $signals[$this->root($parent, $ids[0])]['same_ic'] = true;
        }
        foreach ($phoneGroups as $ids) {
            $signals[$this->root($parent, $ids[0])]['same_phone'] = true;
        }

        $components = [];
        foreach (array_keys($byId) as $id) {
            $components[$this->root($parent, $id)][] = $id;
        }

        $clusters = [];
        foreach ($components as $root => $ids) {
            if (count($ids) < 2) {
                continue;
            }

            sort($ids);
            $signalsForCluster = array_keys($signals[$root] ?? []);

            $clusters[] = [
                'id' => 'dup-'.substr(md5(implode('|', $ids)), 0, 10),
                'signals' => $signalsForCluster,
                'signal_label' => $this->signalLabel($signalsForCluster),
                'records' => array_map(
                    fn (string $id): array => $this->snapshotRecord($byId[$id]),
                    $ids
                ),
            ];
        }

        // Same-IC clusters first (strongest), then larger clusters, then name.
        usort($clusters, function (array $a, array $b): int {
            $aStrong = in_array('same_ic', $a['signals'], true) ? 0 : 1;
            $bStrong = in_array('same_ic', $b['signals'], true) ? 0 : 1;
            if ($aStrong !== $bStrong) {
                return $aStrong <=> $bStrong;
            }

            $count = count($b['records']) <=> count($a['records']);
            if ($count !== 0) {
                return $count;
            }

            return strcasecmp(
                (string) ($a['records'][0]['name'] ?? ''),
                (string) ($b['records'][0]['name'] ?? '')
            );
        });

        return $clusters;
    }

    /**
     * Enrich each record with its local app account (if any), so admin staff
     * know which records are safe to merge and which are linked to the app.
     *
     * @param  array<int, array<string,mixed>>  $clusters
     * @return array<int, array<string,mixed>>
     */
    public function annotateWithAppAccounts(array $clusters): array
    {
        $ids = [];
        foreach ($clusters as $cluster) {
            foreach ($cluster['records'] as $record) {
                if (($record['plato_id'] ?? '') !== '') {
                    $ids[] = $record['plato_id'];
                }
            }
        }

        $accounts = $ids === []
            ? collect()
            : Patient::query()
                ->whereIn('idplato', array_values(array_unique($ids)))
                ->get(['id', 'idplato', 'name'])
                ->keyBy('idplato');

        foreach ($clusters as &$cluster) {
            foreach ($cluster['records'] as &$record) {
                $account = $accounts->get($record['plato_id']);
                $record['app_account_id'] = $account?->id;
                $record['app_account_name'] = $account?->name;
            }
            unset($record);
        }
        unset($cluster);

        return $clusters;
    }

    // ---------------------------------------------------------------------
    // Normalisation
    // ---------------------------------------------------------------------

    public function normaliseNric(?string $nric): ?string
    {
        if ($nric === null) {
            return null;
        }

        $cleaned = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', $nric) ?? '');

        return $cleaned === '' ? null : $cleaned;
    }

    public function normalisePhone(?string $phone): ?string
    {
        if ($phone === null || trim($phone) === '') {
            return null;
        }

        $normalised = Patient::normalisePhone(trim($phone));

        return $normalised === '' ? null : $normalised;
    }

    // ---------------------------------------------------------------------
    // Internals
    // ---------------------------------------------------------------------

    /**
     * @param  array<string, array<string,mixed>>  $byId
     * @param  callable(array<string,mixed>): ?string  $resolver
     * @return array<string, array<int, string>> only values with 2+ records
     */
    private function groupByField(array $byId, callable $resolver): array
    {
        $groups = [];

        foreach ($byId as $id => $record) {
            $value = $resolver($record);
            if ($value === null) {
                continue;
            }
            $groups[$value][] = $id;
        }

        return array_filter($groups, fn (array $ids): bool => count($ids) > 1);
    }

    /**
     * @param  array<string,mixed>  $record
     * @return array<string,mixed>
     */
    private function snapshotRecord(array $record): array
    {
        return [
            'plato_id' => (string) ($record['_id'] ?? ''),
            'name' => Arr::get($record, 'name'),
            'nric' => Arr::get($record, 'nric'),
            'phone' => Arr::get($record, 'telephone') ?? Arr::get($record, 'phone'),
            'email' => Arr::get($record, 'email'),
            'created_on' => Arr::get($record, 'created_on'),
            'app_account_id' => null,
            'app_account_name' => null,
        ];
    }

    /**
     * @param  array<int, string>  $signals
     */
    private function signalLabel(array $signals): string
    {
        if (in_array('same_ic', $signals, true) && in_array('same_phone', $signals, true)) {
            return 'Same IC & phone';
        }

        return in_array('same_ic', $signals, true) ? 'Same IC' : 'Same phone';
    }

    /**
     * @param  array<string,string>  $parent
     */
    private function root(array &$parent, string $key): string
    {
        while (($parent[$key] ?? $key) !== $key) {
            $parent[$key] = $parent[$parent[$key]] ?? $key;
            $key = $parent[$key];
        }

        return $key;
    }

    /**
     * @param  array<string,string>  $parent
     * @param  array<int, string>  $ids
     */
    private function unionAll(array &$parent, array $ids): void
    {
        $first = $ids[0];
        foreach (array_slice($ids, 1) as $id) {
            $rootFirst = $this->root($parent, $first);
            $rootOther = $this->root($parent, $id);
            if ($rootFirst !== $rootOther) {
                $parent[$rootOther] = $rootFirst;
            }
        }
    }
}
