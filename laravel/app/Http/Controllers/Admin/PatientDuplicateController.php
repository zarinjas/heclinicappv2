<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\PlatoDuplicateService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Read-only review of duplicate Plato patients (same NRIC or phone).
 *
 * The clinic reviews this report and merges records manually inside Plato.
 * Nothing here writes back to Plato.
 */
class PatientDuplicateController extends Controller
{
    public function __construct(private readonly PlatoDuplicateService $duplicates) {}

    public function index(Request $request): View
    {
        $snapshot = $this->duplicates->readSnapshot();
        $clusters = $this->filterClusters($snapshot['clusters'] ?? [], $request);

        return view('admin.patient-duplicates.index', [
            'snapshot' => $snapshot,
            'clusters' => $clusters,
            'signal' => $request->input('signal'),
            'app' => $request->input('app'),
            'search' => trim((string) $request->input('search')),
        ]);
    }

    public function scan(): RedirectResponse
    {
        // A full scan can take a while on large datasets. The artisan command
        // is preferred for scheduled/CLI runs; this keeps the button usable.
        @set_time_limit(0);

        try {
            $snapshot = $this->duplicates->scan();
        } catch (\Throwable $e) {
            return redirect()
                ->route('admin.patient-duplicates.index')
                ->with('error', 'Scan failed: '.$e->getMessage());
        }

        return redirect()
            ->route('admin.patient-duplicates.index')
            ->with(
                'success',
                "Scan complete. Scanned {$snapshot['total_scanned']} patient(s), found {$snapshot['cluster_count']} duplicate cluster(s)."
            );
    }

    public function export(Request $request): StreamedResponse
    {
        $snapshot = $this->duplicates->readSnapshot();
        $clusters = $this->filterClusters($snapshot['clusters'] ?? [], $request);

        $filename = 'plato-duplicate-patients-'.now()->format('Ymd-His').'.csv';

        return response()->streamDownload(function () use ($clusters): void {
            $out = fopen('php://output', 'w');

            fputcsv($out, [
                'cluster', 'signals', 'plato_id', 'name', 'nric',
                'phone', 'email', 'created_on', 'has_app_account', 'app_account_name',
            ]);

            foreach ($clusters as $cluster) {
                foreach ($cluster['records'] as $record) {
                    fputcsv($out, [
                        $cluster['id'],
                        implode('+', $cluster['signals']),
                        $record['plato_id'],
                        $record['name'],
                        $record['nric'],
                        $record['phone'],
                        $record['email'],
                        $record['created_on'],
                        $record['app_account_id'] ? 'yes' : 'no',
                        $record['app_account_name'],
                    ]);
                }

                // Blank row between clusters for readability in a spreadsheet.
                fputcsv($out, []);
            }

            fclose($out);
        }, $filename, ['Content-Type' => 'text/csv']);
    }

    /**
     * Apply signal / app-link / free-text filters to a set of clusters.
     *
     * @param  array<int, array<string,mixed>>  $clusters
     * @return array<int, array<string,mixed>>
     */
    private function filterClusters(array $clusters, Request $request): array
    {
        $signal = $request->input('signal');
        $app = $request->input('app');
        $search = strtolower(trim((string) $request->input('search')));

        if (! in_array($signal, ['same_ic', 'same_phone'], true)) {
            $signal = null;
        }
        if (! in_array($app, ['linked', 'not_linked'], true)) {
            $app = null;
        }

        return array_values(array_filter($clusters, function (array $cluster) use ($signal, $app, $search): bool {
            if ($signal !== null && ! in_array($signal, $cluster['signals'], true)) {
                return false;
            }

            $hasApp = false;
            foreach ($cluster['records'] as $record) {
                if (! empty($record['app_account_id'])) {
                    $hasApp = true;
                    break;
                }
            }

            if ($app === 'linked' && ! $hasApp) {
                return false;
            }
            if ($app === 'not_linked' && $hasApp) {
                return false;
            }

            if ($search !== '') {
                $haystack = '';
                foreach ($cluster['records'] as $record) {
                    $haystack .= ' '.strtolower(implode(' ', [
                        (string) $record['name'],
                        (string) $record['nric'],
                        (string) $record['phone'],
                        (string) $record['email'],
                        (string) $record['plato_id'],
                    ]));
                }

                if (! str_contains($haystack, $search)) {
                    return false;
                }
            }

            return true;
        }));
    }
}
