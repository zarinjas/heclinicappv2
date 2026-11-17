<?php

namespace App\Services;

use Illuminate\Support\Str;
use Illuminate\Support\Facades\Cache;

/**
 * Reads patient-facing records from Plato without exposing private notes.
 */
final class PlatoHealthRecordService
{
    private const MAX_PAGES = 200;

    public function __construct(private readonly PlatoProxyService $plato) {}

    /**
     * @return array<int, array<string, mixed>>
     */
    public function recordsForPatient(string $patientId): array
    {
        $cacheKey = 'plato:health-records:'.$patientId;
        // Records must remain available if the optional cache backend is down.
        // A cache outage should never turn this patient endpoint into a 500.
        try {
            $cached = Cache::get($cacheKey);
        } catch (\Throwable) {
            $cached = null;
        }
        if (is_array($cached) && isset($cached['records'], $cached['fetched_at'])) {
            try {
                $age = now()->diffInSeconds($cached['fetched_at']);
                if ($age < 600) {
                    return is_array($cached['records']) ? $cached['records'] : [];
                }
            } catch (\Throwable) {
                // Ignore malformed/stale cache entries and fetch fresh data.
            }
        }

        $upstreamFailed = false;
        try {
            $records = $this->fetchRecords($patientId, $upstreamFailed);
        } catch (\Throwable) {
            return is_array($cached['records'] ?? null) ? $cached['records'] : [];
        }

        // Do not overwrite a good cache with an empty/partial response when
        // Plato rate-limits one of the paginated requests.
        if ($upstreamFailed) {
            return is_array($cached['records'] ?? null) ? $cached['records'] : $records;
        }

        // A transient Plato failure can look like an empty page. Keep the
        // last known records instead of making the patient app appear empty.
        if ($records === [] && is_array($cached['records'] ?? null) && $cached['records'] !== []) {
            return $cached['records'];
        }

        try {
            Cache::put($cacheKey, [
                'records' => $records,
                'fetched_at' => now(),
            ], now()->addHours(2));
        } catch (\Throwable) {
            // Cache is an optimisation only; do not fail the API response.
        }

        return $records;
    }

    /** @return array<int, array<string, mixed>> */
    private function fetchRecords(string $patientId, bool &$upstreamFailed = false): array
    {
        $records = [];

        foreach ($this->fetchAll('letter', ['patient_id' => $patientId], $upstreamFailed) as $row) {
            if (! is_array($row) || ! $this->isMedicalCertificate($row)) {
                continue;
            }

            $records[] = $this->record(
                source: 'letter:'.($row['_id'] ?? $row['id'] ?? sha1(json_encode($row))),
                type: 'mc',
                title: $row['subject'] ?? 'Medical Certificate',
                date: $row['created_on'] ?? $row['created_at'] ?? '',
                author: $row['created_by'] ?? $row['author'] ?? '',
                detailData: $this->stringValue($row['html'] ?? null),
            );
        }

        foreach ($this->fetchAll('patient/'.rawurlencode($patientId).'/note', [], $upstreamFailed) as $row) {
            if (! is_array($row) || ! $this->isAllowedClinicalFile($row)) {
                continue;
            }

            $type = $this->recordType($row);
            $baseId = (string) ($row['_id'] ?? $row['id'] ?? sha1(json_encode($row)));
            $files = $this->attachments(
                $row['attachments']
                    ?? $row['file']
                    ?? $row['file_url']
                    ?? $row['fileUrl']
                    ?? $row['pdf']
                    ?? null,
            );

            foreach ($files as $index => $file) {
                $records[] = $this->record(
                    source: "note:{$baseId}:{$index}",
                    type: $type,
                    title: $file['name'] ?: $this->title($row, $type),
                    date: $this->date($row),
                    author: $this->stringValue($row['author'] ?? $row['doctor'] ?? ''),
                    detailData: $file['url'],
                    isFile: true,
                );
            }

            // Some lab integrations send an HTML report instead of a file.
            if ($files === []) {
                $report = $this->stringValue(
                    $row['report'] ?? $row['html'] ?? $row['note'] ?? null,
                );
                if ($report !== '') {
                    $records[] = $this->record(
                        source: "note:{$baseId}:report",
                        type: $type,
                        title: $this->title($row, $type),
                        date: $this->date($row),
                        author: $this->stringValue($row['author'] ?? $row['doctor'] ?? ''),
                        detailData: $report,
                    );
                }
            }
        }

        usort($records, static fn (array $a, array $b): int =>
            strcmp((string) ($b['date'] ?? ''), (string) ($a['date'] ?? ''))
        );

        return $records;
    }

    /**
     * @return array<int, mixed>
     */
    private function fetchAll(string $path, array $query, bool &$upstreamFailed = false): array
    {
        $all = [];

        for ($page = 1; $page <= self::MAX_PAGES; $page++) {
            $result = $this->plato->proxy('GET', $path, $query + ['current_page' => $page]);
            if (! empty($result['error'])) {
                $upstreamFailed = true;
                break;
            }

            $rows = $result['data'] ?? [];
            if (! is_array($rows) || $rows === []) {
                break;
            }

            $count = 0;
            foreach ($rows as $row) {
                if (is_array($row)) {
                    $all[] = $row;
                    $count++;
                }
            }

            if ($count === 0 || $count < 20) {
                break;
            }
        }

        return $all;
    }

    private function isMedicalCertificate(array $row): bool
    {
        $subject = Str::lower($this->stringValue($row['subject'] ?? ''));

        return Str::contains($subject, ['medical certificate', 'medical leave'])
            || preg_match('/\bmc\b/i', $subject) === 1;
    }

    private function isAllowedClinicalFile(array $row): bool
    {
        $haystack = Str::lower(implode(' ', array_filter([
            $row['folder_name'] ?? null,
            $row['category'] ?? null,
            $row['type'] ?? null,
            $row['subject'] ?? null,
            $row['title'] ?? null,
            $row['testname'] ?? null,
            $row['test_name'] ?? null,
            $row['report_type'] ?? null,
            $row['lab'] ?? null,
            $row['radiology'] ?? null,
            $row['modality'] ?? null,
        ], static fn ($value): bool => is_scalar($value))));

        if ($haystack === '' || Str::contains($haystack, ['casenote', 'case note', 'admin'])) {
            return false;
        }

        return Str::contains($haystack, [
            'lab',
            'radiology',
            'radiograph',
            'x-ray',
            'xray',
            'scan',
            'medical certificate',
            'medical leave',
        ]);
    }

    private function recordType(array $row): string
    {
        $haystack = Str::lower(implode(' ', array_filter([
            $row['folder_name'] ?? null,
            $row['category'] ?? null,
            $row['type'] ?? null,
            $row['subject'] ?? null,
            $row['title'] ?? null,
            $row['testname'] ?? null,
            $row['test_name'] ?? null,
            $row['lab'] ?? null,
            $row['radiology'] ?? null,
            $row['modality'] ?? null,
        ], static fn ($value): bool => is_scalar($value))));

        if (Str::contains($haystack, ['radiology', 'radiograph', 'x-ray', 'xray', 'scan'])) {
            return 'radiology';
        }
        if (Str::contains($haystack, ['medical certificate', 'medical leave'])
            || preg_match('/\bmc\b/i', $haystack) === 1) {
            return 'mc';
        }

        return 'lab';
    }

    /**
     * @return array<int, array{name:string,url:string}>
     */
    private function attachments(mixed $value): array
    {
        if ($value === null || $value === '') {
            return [];
        }

        $items = is_array($value) && array_is_list($value) ? $value : [$value];
        $files = [];

        foreach ($items as $item) {
            $url = '';
            $name = '';

            if (is_string($item)) {
                $url = trim($item);
            } elseif (is_array($item)) {
                foreach (['url', 'path', 'file', 'file_url', 'fileUrl', 'download_url', 'downloadUrl', 'uri'] as $key) {
                    if (is_string($item[$key] ?? null) && trim($item[$key]) !== '') {
                        $url = trim($item[$key]);
                        break;
                    }
                }
                foreach (['name', 'filename', 'file_name', 'original_name', 'originalName'] as $key) {
                    if (is_string($item[$key] ?? null) && trim($item[$key]) !== '') {
                        $name = trim($item[$key]);
                        break;
                    }
                }
            }

            if ($url === '') {
                continue;
            }

            $name = $name !== '' ? $name : basename((string) parse_url($url, PHP_URL_PATH));
            $files[] = ['name' => $name !== '' ? $name : 'Health record', 'url' => $url];
        }

        return $files;
    }

    private function title(array $row, string $type): string
    {
        foreach (['subject', 'title', 'testname', 'name', 'folder_name'] as $key) {
            $value = $this->stringValue($row[$key] ?? null);
            if ($value !== '') {
                return $value;
            }
        }

        $note = trim(preg_replace('/\s+/', ' ', strip_tags(
            $this->stringValue($row['note'] ?? ''),
        )) ?? '');
        if ($note !== '') {
            return Str::limit($note, 100);
        }

        return match ($type) {
            'radiology' => 'Radiology record',
            'mc' => 'Medical Certificate',
            default => 'Laboratory record',
        };
    }

    private function date(array $row): string
    {
        foreach (['timestamp', 'created_on', 'created_at', 'date', 'uploaded_at'] as $key) {
            $value = $this->stringValue($row[$key] ?? null);
            if ($value !== '') {
                return $value;
            }
        }

        return '';
    }

    private function stringValue(mixed $value): string
    {
        return is_scalar($value) ? trim((string) $value) : '';
    }

    /** @return array<string, mixed> */
    private function record(
        string $source,
        string $type,
        string $title,
        string $date,
        string $author,
        ?string $detailData,
        bool $isFile = false,
    ): array {
        return [
            'id' => $source,
            'type' => $type,
            'title' => strip_tags($title) ?: 'Health record',
            'date' => $date,
            'author' => strip_tags($author),
            'detail_data' => $detailData,
            'is_file' => $isFile,
        ];
    }
}
