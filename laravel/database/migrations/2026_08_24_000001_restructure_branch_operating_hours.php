<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    private const DAY_KEYS = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
    ];

    public function up(): void
    {
        // operating_hours is already a JSON column; we only need to migrate the
        // existing free-text values (e.g. "Mon-Fri: 8:00 AM - 5:00 PM") into a
        // structured per-day map: {"monday": "08:00-17:00", ...}. Closed days
        // are omitted.
        $branches = DB::table('branches')->whereNotNull('operating_hours')->get();

        foreach ($branches as $branch) {
            $value = $branch->operating_hours;

            // Already structured JSON object? Leave it alone.
            if (is_string($value)) {
                $decoded = json_decode($value, true);
                if (is_array($decoded) && ! empty($decoded)) {
                    continue;
                }
            } elseif (is_array($value)) {
                continue;
            }

            $structured = $this->parseLegacy($value);
            DB::table('branches')
                ->where('id', $branch->id)
                ->update(['operating_hours' => $structured ? json_encode($structured) : null]);
        }
    }

    public function down(): void
    {
        // No-op: reverting structured hours back to free text is not lossless.
    }

    /**
     * Best-effort parse of the old free-text format such as
     * "Mon-Fri: 8:00 AM - 5:00 PM, Sat: 8:00 AM - 1:00 PM".
     */
    private function parseLegacy(mixed $value): array
    {
        $text = is_string($value) ? $value : '';
        if ($text === '') {
            return [];
        }

        $result = [];
        $segments = preg_split('/[,;\n]+/', $text) ?: [];

        foreach ($segments as $segment) {
            $segment = trim($segment);
            if ($segment === '') {
                continue;
            }

            // Split day part and time part on the first colon.
            $colon = strpos($segment, ':');
            if ($colon === false) {
                continue;
            }

            $dayPart = strtolower(trim(substr($segment, 0, $colon)));
            $timePart = trim(substr($segment, $colon + 1));

            $times = $this->parseTimeRange($timePart);
            if ($times === null) {
                continue;
            }

            [$open, $close] = $times;

            foreach ($this->daysFromRange($dayPart) as $day) {
                $result[$day] = $open.'-'.$close;
            }
        }

        return $result;
    }

    private function daysFromRange(string $dayPart): array
    {
        $dayPart = str_replace(['mon-fri', 'monday-friday'], 'mon,fri', $dayPart);
        $dayPart = str_replace(['mon-thu', 'monday-thursday'], 'mon,thu', $dayPart);
        $dayPart = str_replace(['mon-sat', 'monday-saturday'], 'mon,sat', $dayPart);
        $dayPart = str_replace(['mon-sun', 'monday-sunday'], 'mon,sun', $dayPart);

        $abbr = [
            'mon' => 'monday', 'tue' => 'tuesday', 'tues' => 'tuesday',
            'wed' => 'wednesday', 'thu' => 'thursday', 'thur' => 'thursday',
            'thurs' => 'thursday', 'fri' => 'friday', 'sat' => 'saturday',
            'sun' => 'sunday',
        ];

        if (str_contains($dayPart, ',')) {
            $parts = array_map('trim', explode(',', $dayPart));
            $start = $abbr[$parts[0]] ?? $parts[0];
            $end = $abbr[$parts[1]] ?? $parts[1];
            return $this->expandRange($start, $end);
        }

        $single = $abbr[$dayPart] ?? $dayPart;
        if (in_array($single, self::DAY_KEYS, true)) {
            return [$single];
        }

        return [];
    }

    private function expandRange(string $start, string $end): array
    {
        $startIdx = array_search($start, self::DAY_KEYS, true);
        $endIdx = array_search($end, self::DAY_KEYS, true);

        if ($startIdx === false || $endIdx === false) {
            return [];
        }

        $days = [];
        $i = $startIdx;
        while (true) {
            $days[] = self::DAY_KEYS[$i % 7];
            if ($i % 7 === $endIdx) {
                break;
            }
            $i++;
        }

        return $days;
    }

    private function parseTimeRange(string $timePart): ?array
    {
        $parts = preg_split('/\s+-\s+|–|—/', $timePart) ?: [];
        if (count($parts) < 2) {
            return null;
        }

        $open = $this->to24h(trim($parts[0]));
        $close = $this->to24h(trim($parts[1]));

        if ($open === null || $close === null) {
            return null;
        }

        return [$open, $close];
    }

    private function to24h(?string $time): ?string
    {
        if (! $time) {
            return null;
        }

        $matches = [];
        if (! preg_match('/(\d{1,2})(?::(\d{2}))?\s*(am|pm)/i', $time, $matches)) {
            return null;
        }

        $hour = (int) $matches[1];
        $minute = isset($matches[2]) && $matches[2] !== '' ? (int) $matches[2] : 0;
        $ampm = strtolower($matches[3]);

        if ($ampm === 'pm' && $hour !== 12) {
            $hour += 12;
        } elseif ($ampm === 'am' && $hour === 12) {
            $hour = 0;
        }

        return sprintf('%02d:%02d', $hour, $minute);
    }
};
