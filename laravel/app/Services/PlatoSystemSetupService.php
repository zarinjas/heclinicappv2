<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;

final class PlatoSystemSetupService
{
    private PlatoProxyService $proxy;

    public function __construct(PlatoProxyService $proxy)
    {
        $this->proxy = $proxy;
    }

    public function syncCalendars(): array
    {
        $result = $this->proxy->proxy('GET', '/systemsetup');

        if (!empty($result['error'])) {
            Log::channel('plato')->error('Calendar sync failed: Plato API error', [
                'code' => $result['code'] ?? 'unknown',
                'message' => $result['message'] ?? 'Unknown error',
            ]);

            return [
                'success' => false,
                'message' => 'Failed to fetch calendar data from Plato: ' . ($result['message'] ?? 'Unknown error'),
                'calendars' => [],
            ];
        }

        $data = $result['data'] ?? [];

        $calendars = $this->extractCalendars($data);

        if (empty($calendars)) {
            return [
                'success' => true,
                'message' => 'No calendar entries found in Plato system setup response.',
                'calendars' => [],
            ];
        }

        return [
            'success' => true,
            'message' => count($calendars) . ' calendar' . (count($calendars) !== 1 ? 's' : '') . ' fetched from Plato.',
            'calendars' => $calendars,
        ];
    }

    private function extractCalendars(array $data): array
    {
        $calendars = [];

        if (isset($data['calendar']) && is_array($data['calendar'])) {
            return $this->parseCalendarEntries($data['calendar']);
        }

        if (isset($data['calendars']) && is_array($data['calendars'])) {
            return $this->parseCalendarEntries($data['calendars']);
        }

        foreach ($data as $value) {
            if (is_array($value)) {
                $nested = $this->extractCalendars($value);
                if (!empty($nested)) {
                    return $nested;
                }
            }
        }

        return $calendars;
    }

    private function parseCalendarEntries(array $entries): array
    {
        $calendars = [];

        foreach ($entries as $entry) {
            if (!is_array($entry)) {
                continue;
            }

            $color = $entry['color'] ?? $entry['color_id'] ?? $entry['calendar_id'] ?? null;

            if ($color === null) {
                continue;
            }

            $calendars[] = [
                'plato_calendar_color_id' => (string) $color,
                'name' => $entry['name'] ?? $entry['calendar_name'] ?? $entry['title'] ?? 'Calendar ' . $color,
            ];
        }

        return $calendars;
    }
}
