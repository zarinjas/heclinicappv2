<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\CmsPromotion;
use App\Models\McpAuditLog;
use App\Models\NotificationLog;
use App\Models\Patient;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Implements the tools exposed to Claude (and any other MCP client) through
 * the JSON-RPC endpoint at POST /api/mcp.
 *
 * Every tool reuses the existing admin services/models instead of duplicating
 * business logic, so behaviour stays consistent with the admin panel.
 */
final class McpService
{
    public function __construct(private readonly NotificationService $notifications) {}

    /**
     * Tool catalogue returned by `tools/list`.
     *
     * @return array<int, array<string, mixed>>
     */
    public function tools(): array
    {
        return [
            [
                'name' => 'get_dashboard_stats',
                'description' => 'Get a snapshot of the clinic: total patients, new registrations in the last 30 days, how many patients can receive push, appointments this month, notification totals, and the top registration campaigns. Use for "how are we doing" / summary questions.',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => new \stdClass,
                    'additionalProperties' => false,
                ],
            ],
            [
                'name' => 'list_registrations',
                'description' => 'List patients who registered in an optional date range, optionally filtered by marketing campaign (matches the referral/campaign field or a patient tag). Returns names with masked contact details. Use to answer "who registered from campaign X this month".',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => [
                        'campaign' => ['type' => 'string', 'description' => 'Campaign or referral name/code (e.g. "instagram_july"). Matches patients.referred_by or a patient tag/note.'],
                        'from' => ['type' => 'string', 'description' => 'Start date (YYYY-MM-DD). Defaults to 30 days ago.'],
                        'to' => ['type' => 'string', 'description' => 'End date (YYYY-MM-DD). Defaults to today.'],
                        'limit' => ['type' => 'integer', 'description' => 'Max rows to return (1-100). Default 25.'],
                    ],
                    'additionalProperties' => false,
                ],
            ],
            [
                'name' => 'campaign_report',
                'description' => 'Report registrations by marketing campaign. With a campaign name, returns that campaign\'s totals and sample registrants; without one, returns a leaderboard of all campaigns in the date range. Use for marketing performance questions.',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => [
                        'campaign' => ['type' => 'string', 'description' => 'Optional campaign/referral name to report on.'],
                        'from' => ['type' => 'string', 'description' => 'Start date (YYYY-MM-DD). Defaults to 30 days ago.'],
                        'to' => ['type' => 'string', 'description' => 'End date (YYYY-MM-DD). Defaults to today.'],
                        'limit' => ['type' => 'integer', 'description' => 'Max sample rows (1-100). Default 20.'],
                    ],
                    'additionalProperties' => false,
                ],
            ],
            [
                'name' => 'list_promotions',
                'description' => 'List promotions in the CMS, newest first. Use to check what promos currently exist before creating a new one.',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => [
                        'active_only' => ['type' => 'boolean', 'description' => 'Only return active promotions. Default true.'],
                        'limit' => ['type' => 'integer', 'description' => 'Max rows (1-100). Default 20.'],
                    ],
                    'additionalProperties' => false,
                ],
            ],
            [
                'name' => 'create_promotion',
                'description' => 'Create a promotion in the CMS. WRITE ACTION: only call after the user has explicitly confirmed the details. title and description are required.',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => [
                        'title' => ['type' => 'string', 'description' => 'Max 255 chars.'],
                        'description' => ['type' => 'string'],
                        'promo_code' => ['type' => 'string', 'description' => 'Optional promo code, max 50 chars.'],
                        'cta_text' => ['type' => 'string', 'description' => 'Optional button text, max 100 chars.'],
                        'cta_link' => ['type' => 'string', 'description' => 'Optional valid URL.'],
                        'valid_from' => ['type' => 'string', 'description' => 'Optional start date (YYYY-MM-DD).'],
                        'valid_until' => ['type' => 'string', 'description' => 'Optional end date (YYYY-MM-DD).'],
                        'usage_limit' => ['type' => 'integer', 'description' => 'Optional maximum redemptions.'],
                        'is_active' => ['type' => 'boolean', 'description' => 'Whether the promo is live. Default true.'],
                        'code_unique' => ['type' => 'boolean', 'description' => 'Whether each user gets a unique code. Default false.'],
                    ],
                    'required' => ['title', 'description'],
                    'additionalProperties' => false,
                ],
            ],
            [
                'name' => 'send_push_notification',
                'description' => 'Send a push / in-app / email notification. WRITE ACTION: only call after the user has explicitly confirmed the exact title, body and audience. audience="all" broadcasts to every registered device; audience="specific_patient" requires patient_identifier.',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => [
                        'title' => ['type' => 'string', 'description' => 'Max 255 chars.'],
                        'body' => ['type' => 'string', 'description' => 'Max 2000 chars.'],
                        'audience' => ['type' => 'string', 'enum' => ['all', 'specific_patient'], 'description' => 'Default "all".'],
                        'patient_identifier' => ['type' => 'string', 'description' => 'Required when audience=specific_patient. NRIC, phone, email or idplato.'],
                        'channels' => [
                            'type' => 'array',
                            'items' => ['type' => 'string', 'enum' => ['push', 'in_app', 'email']],
                            'description' => 'Default ["push","in_app"].',
                        ],
                        'image_url' => ['type' => 'string', 'description' => 'Optional HTTPS image URL.'],
                    ],
                    'required' => ['title', 'body'],
                    'additionalProperties' => false,
                ],
            ],
            [
                'name' => 'send_campaign_notification',
                'description' => 'Send a push + in-app notification to every patient registered through a marketing campaign. WRITE ACTION: only call after the user has explicitly confirmed the campaign, title and body.',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => [
                        'campaign' => ['type' => 'string', 'description' => 'Campaign/referral name being targeted.'],
                        'title' => ['type' => 'string', 'description' => 'Max 255 chars.'],
                        'body' => ['type' => 'string', 'description' => 'Max 2000 chars.'],
                        'channels' => [
                            'type' => 'array',
                            'items' => ['type' => 'string', 'enum' => ['push', 'in_app']],
                            'description' => 'Default ["push","in_app"].',
                        ],
                        'image_url' => ['type' => 'string', 'description' => 'Optional HTTPS image URL.'],
                    ],
                    'required' => ['campaign', 'title', 'body'],
                    'additionalProperties' => false,
                ],
            ],
            [
                'name' => 'recent_activity',
                'description' => 'List the most recent actions performed through this MCP connection (audit trail).',
                'inputSchema' => [
                    'type' => 'object',
                    'properties' => [
                        'limit' => ['type' => 'integer', 'description' => 'Max rows (1-50). Default 10.'],
                    ],
                    'additionalProperties' => false,
                ],
            ],
        ];
    }

    /**
     * Execute a tool and return an MCP `tools/call` result.
     *
     * @param  array<string, mixed>  $arguments
     * @return array<string, mixed>
     */
    public function call(string $name, array $arguments): array
    {
        $data = match ($name) {
            'get_dashboard_stats' => $this->getDashboardStats(),
            'list_registrations' => $this->listRegistrations($arguments),
            'campaign_report' => $this->campaignReport($arguments),
            'list_promotions' => $this->listPromotions($arguments),
            'create_promotion' => $this->createPromotion($arguments),
            'send_push_notification' => $this->sendPushNotification($arguments),
            'send_campaign_notification' => $this->sendCampaignNotification($arguments),
            'recent_activity' => $this->recentActivity($arguments),
            default => throw new \InvalidArgumentException("Unknown tool: {$name}"),
        };

        return $this->textResult($data);
    }

    // -------------------------------------------------------------------------
    // Tools
    // -------------------------------------------------------------------------

    private function getDashboardStats(): array
    {
        $since = now()->subDays(30);

        $campaigns = Patient::query()
            ->whereNotNull('referred_by')
            ->where('referred_by', '!=', '')
            ->select('referred_by', DB::raw('count(*) as total'))
            ->groupBy('referred_by')
            ->orderByDesc('total')
            ->limit(8)
            ->get()
            ->map(fn ($row) => ['campaign' => $row->referred_by, 'registrations' => (int) $row->total])
            ->all();

        return [
            'patients' => [
                'total' => Patient::count(),
                'new_last_30_days' => Patient::where('created_at', '>=', $since)->count(),
                'push_reachable' => Patient::whereNotNull('fcm_token')->where('fcm_token', '!=', '')->count(),
            ],
            'appointments' => [
                'this_month' => Appointment::whereMonth('appointment_date', now()->month)
                    ->whereYear('appointment_date', now()->year)
                    ->count(),
            ],
            'notifications' => [
                'total' => NotificationLog::count(),
                'delivered' => NotificationLog::whereIn('status', ['sent', 'partial', 'delivered'])->count(),
            ],
            'top_campaigns' => $campaigns,
        ];
    }

    private function listRegistrations(array $args): array
    {
        [$from, $to] = $this->dateRange($args, 30);
        $limit = $this->limit($args, 25, 100);
        $campaign = trim((string) ($args['campaign'] ?? ''));

        $query = Patient::query()->whereBetween('created_at', [$from, $to]);

        if ($campaign !== '') {
            $this->applyCampaignScope($query, $campaign);
        }

        $total = (clone $query)->count();

        $rows = $query->orderByDesc('created_at')
            ->limit($limit)
            ->get(['name', 'telephone', 'email', 'referred_by', 'idplato', 'fcm_token', 'created_at'])
            ->map(fn (Patient $patient) => [
                'name' => $patient->name,
                'phone' => $this->maskPhone($patient->telephone),
                'email' => $this->maskEmail($patient->email),
                'campaign' => $patient->referred_by,
                'linked_app_account' => $patient->idplato !== null,
                'push_reachable' => ! empty($patient->fcm_token),
                'registered_at' => optional($patient->created_at)->toDateTimeString(),
            ])
            ->all();

        return [
            'campaign' => $campaign !== '' ? $campaign : null,
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'total_registrations' => $total,
            'returned' => count($rows),
            'registrations' => $rows,
        ];
    }

    private function campaignReport(array $args): array
    {
        [$from, $to] = $this->dateRange($args, 30);
        $limit = $this->limit($args, 20, 100);
        $campaign = trim((string) ($args['campaign'] ?? ''));

        if ($campaign !== '') {
            $query = Patient::query()->whereBetween('created_at', [$from, $to]);
            $this->applyCampaignScope($query, $campaign);

            $samples = (clone $query)->orderByDesc('created_at')
                ->limit($limit)
                ->get(['name', 'referred_by', 'idplato', 'fcm_token', 'created_at'])
                ->map(fn (Patient $patient) => [
                    'name' => $patient->name,
                    'campaign' => $patient->referred_by,
                    'linked_app_account' => $patient->idplato !== null,
                    'push_reachable' => ! empty($patient->fcm_token),
                    'registered_at' => optional($patient->created_at)->toDateTimeString(),
                ])
                ->all();

            return [
                'campaign' => $campaign,
                'from' => $from->toDateString(),
                'to' => $to->toDateString(),
                'total_registrations' => (clone $query)->count(),
                'linked_app_accounts' => (clone $query)->whereNotNull('idplato')->count(),
                'push_reachable' => (clone $query)->whereNotNull('fcm_token')->where('fcm_token', '!=', '')->count(),
                'samples' => $samples,
            ];
        }

        $rows = Patient::query()
            ->whereBetween('created_at', [$from, $to])
            ->select('referred_by', DB::raw('count(*) as total'))
            ->groupBy('referred_by')
            ->orderByDesc('total')
            ->limit(50)
            ->get()
            ->map(fn ($row) => [
                'campaign' => $row->referred_by ?: '(Direct / no campaign)',
                'registrations' => (int) $row->total,
            ])
            ->all();

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'campaigns' => $rows,
        ];
    }

    private function listPromotions(array $args): array
    {
        $activeOnly = array_key_exists('active_only', $args) ? (bool) $args['active_only'] : true;
        $limit = $this->limit($args, 20, 100);

        $query = CmsPromotion::query()->orderByDesc('created_at');

        if ($activeOnly) {
            $query->where('is_active', true);
        }

        $rows = $query->limit($limit)
            ->get(['id', 'title', 'description', 'promo_code', 'valid_from', 'valid_until', 'usage_limit', 'is_active', 'created_at'])
            ->map(fn (CmsPromotion $promo) => [
                'id' => $promo->id,
                'title' => $promo->title,
                'description' => $promo->description,
                'promo_code' => $promo->promo_code,
                'valid_from' => optional($promo->valid_from)->toDateString(),
                'valid_until' => optional($promo->valid_until)->toDateString(),
                'usage_limit' => $promo->usage_limit,
                'is_active' => (bool) $promo->is_active,
                'created_at' => optional($promo->created_at)->toDateTimeString(),
            ])
            ->all();

        return ['active_only' => $activeOnly, 'promotions' => $rows];
    }

    private function createPromotion(array $args): array
    {
        $title = trim((string) ($args['title'] ?? ''));
        $description = trim((string) ($args['description'] ?? ''));

        if ($title === '' || $description === '') {
            throw new \InvalidArgumentException('Both "title" and "description" are required.');
        }

        if (mb_strlen($title) > 255) {
            throw new \InvalidArgumentException('Title must be 255 characters or fewer.');
        }

        $ctaLink = trim((string) ($args['cta_link'] ?? ''));

        if ($ctaLink !== '' && ! filter_var($ctaLink, FILTER_VALIDATE_URL)) {
            throw new \InvalidArgumentException('"cta_link" must be a valid URL.');
        }

        $validFrom = $this->nullableDate($args['valid_from'] ?? null);
        $validUntil = $this->nullableDate($args['valid_until'] ?? null);

        if ($validFrom !== null && $validUntil !== null && Carbon::parse($validUntil)->lt(Carbon::parse($validFrom))) {
            throw new \InvalidArgumentException('"valid_until" must be on or after "valid_from".');
        }

        $promotion = CmsPromotion::create([
            'title' => $title,
            'description' => $description,
            'promo_code' => $this->nullableString($args['promo_code'] ?? null),
            'cta_text' => $this->nullableString($args['cta_text'] ?? null),
            'cta_link' => $ctaLink !== '' ? $ctaLink : null,
            'valid_from' => $validFrom,
            'valid_until' => $validUntil,
            'usage_limit' => isset($args['usage_limit']) && $args['usage_limit'] !== '' ? (int) $args['usage_limit'] : null,
            'is_active' => array_key_exists('is_active', $args) ? (bool) $args['is_active'] : true,
            'code_unique' => (bool) ($args['code_unique'] ?? false),
        ]);

        return [
            'created' => true,
            'id' => $promotion->id,
            'title' => $promotion->title,
            'promo_code' => $promotion->promo_code,
            'is_active' => (bool) $promotion->is_active,
            'message' => 'Promotion created. It is now available in CMS → Promotions.',
        ];
    }

    private function sendPushNotification(array $args): array
    {
        $title = trim((string) ($args['title'] ?? ''));
        $body = trim((string) ($args['body'] ?? ''));

        if ($title === '' || $body === '') {
            throw new \InvalidArgumentException('Both "title" and "body" are required.');
        }

        if (mb_strlen($title) > 255) {
            throw new \InvalidArgumentException('Title must be 255 characters or fewer.');
        }

        if (mb_strlen($body) > 2000) {
            throw new \InvalidArgumentException('Body must be 2000 characters or fewer.');
        }

        $imageUrl = $this->validatedImageUrl($args['image_url'] ?? null);
        $audience = (string) ($args['audience'] ?? 'all');
        $channels = $this->channels($args['channels'] ?? null, ['push', 'in_app', 'email']);

        $targetType = 'all';
        $targetIds = null;

        if ($audience === 'specific_patient') {
            $term = trim((string) ($args['patient_identifier'] ?? ''));

            if ($term === '') {
                throw new \InvalidArgumentException('"patient_identifier" is required when audience is "specific_patient".');
            }

            $targetType = 'specific_patient';
            $targetIds = [$term];
        } elseif ($audience !== 'all') {
            throw new \InvalidArgumentException('"audience" must be "all" or "specific_patient".');
        }

        $log = NotificationLog::create([
            'type' => 'manual',
            'title' => $title,
            'body' => $body,
            'image_url' => $imageUrl,
            'target_type' => $targetType,
            'target_ids' => $targetIds,
            'channels' => $channels,
            'status' => 'pending',
        ]);

        $this->notifications->sendManualNotification($log);
        $log->refresh();

        return [
            'notification_log_id' => $log->id,
            'audience' => $audience,
            'channels' => $channels,
            'status' => $log->status,
            'delivered_count' => (int) ($log->delivered_count ?? 0),
            'failed_count' => (int) ($log->failed_count ?? 0),
            'message' => $log->status === 'sending'
                ? 'Notification queued — the queue worker will finish delivery shortly.'
                : 'Notification processed. Check status for delivery details.',
        ];
    }

    private function sendCampaignNotification(array $args): array
    {
        $campaign = trim((string) ($args['campaign'] ?? ''));
        $title = trim((string) ($args['title'] ?? ''));
        $body = trim((string) ($args['body'] ?? ''));

        if ($campaign === '' || $title === '' || $body === '') {
            throw new \InvalidArgumentException('"campaign", "title" and "body" are required.');
        }

        if (mb_strlen($title) > 255 || mb_strlen($body) > 2000) {
            throw new \InvalidArgumentException('Title must be <= 255 and body <= 2000 characters.');
        }

        $imageUrl = $this->validatedImageUrl($args['image_url'] ?? null);
        $channels = $this->channels($args['channels'] ?? null, ['push', 'in_app']);

        $query = Patient::query()->whereNotNull('idplato');
        $this->applyCampaignScope($query, $campaign);

        $patientIds = $query->pluck('idplato')->filter()->unique()->values()->all();

        if ($patientIds === []) {
            throw new \InvalidArgumentException("No patients with an app account were found for campaign \"{$campaign}\".");
        }

        $result = $this->notifications->sendToPatients($patientIds, $title, $body, $channels, $imageUrl);

        return $result + ['campaign' => $campaign];
    }

    private function recentActivity(array $args): array
    {
        $limit = $this->limit($args, 10, 50);

        $rows = McpAuditLog::query()
            ->latest()
            ->limit($limit)
            ->get()
            ->map(fn (McpAuditLog $log) => [
                'tool' => $log->tool,
                'status' => $log->status,
                'summary' => $log->summary,
                'at' => optional($log->created_at)->toDateTimeString(),
            ])
            ->all();

        return ['activity' => $rows];
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private function textResult(array $data): array
    {
        return [
            'content' => [[
                'type' => 'text',
                'text' => json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE),
            ]],
            'isError' => false,
        ];
    }

    /**
     * Match patients by campaign: the referral/campaign field at registration
     * OR a tag/note set on the patient in the admin panel.
     */
    private function applyCampaignScope($query, string $campaign): void
    {
        $like = '%'.$campaign.'%';

        $query->where(function ($q) use ($like): void {
            $q->where('referred_by', 'like', $like)
                ->orWhereIn('idplato', function ($sub) use ($like): void {
                    $sub->select('patient_plato_uid')
                        ->from('patient_metadata')
                        ->where(function ($m) use ($like): void {
                            $m->where('tags', 'like', $like)
                                ->orWhere('notes', 'like', $like);
                        });
                });
        });
    }

    /**
     * @return array{0: Carbon, 1: Carbon}
     */
    private function dateRange(array $args, int $defaultDays): array
    {
        $to = $this->parseDate($args['to'] ?? null) ?? now();
        $from = $this->parseDate($args['from'] ?? null) ?? $to->copy()->subDays($defaultDays);

        if ($from->greaterThan($to)) {
            throw new \InvalidArgumentException('"from" must be on or before "to".');
        }

        return [$from->copy()->startOfDay(), $to->copy()->endOfDay()];
    }

    private function parseDate(mixed $value): ?Carbon
    {
        if (! is_string($value) || trim($value) === '') {
            return null;
        }

        try {
            return Carbon::parse($value);
        } catch (\Throwable) {
            throw new \InvalidArgumentException("Invalid date \"{$value}\". Use YYYY-MM-DD.");
        }
    }

    private function nullableDate(mixed $value): ?string
    {
        $date = $this->parseDate($value);

        return $date?->toDateString();
    }

    private function nullableString(mixed $value): ?string
    {
        if (! is_string($value)) {
            return null;
        }

        $value = trim($value);

        return $value === '' ? null : $value;
    }

    private function limit(array $args, int $default, int $max): int
    {
        $limit = isset($args['limit']) ? (int) $args['limit'] : $default;

        return max(1, min($limit, $max));
    }

    /**
     * @param  array<int, string>  $allowed
     * @return array<int, string>
     */
    private function channels(mixed $value, array $allowed): array
    {
        $requested = is_array($value) ? $value : [];
        $channels = array_values(array_intersect($allowed, array_map('strval', $requested)));

        if ($channels === []) {
            $channels = array_values(array_intersect($allowed, ['push', 'in_app']));
        }

        return $channels;
    }

    private function validatedImageUrl(mixed $value): ?string
    {
        $url = $this->nullableString($value);

        if ($url === null) {
            return null;
        }

        if (! filter_var($url, FILTER_VALIDATE_URL)) {
            throw new \InvalidArgumentException('"image_url" must be a valid URL.');
        }

        return $url;
    }

    private function maskPhone(?string $phone): ?string
    {
        if ($phone === null || $phone === '') {
            return null;
        }

        $digits = preg_replace('/\D/', '', $phone) ?? '';

        if (strlen($digits) <= 4) {
            return str_repeat('*', strlen($digits));
        }

        return substr($digits, 0, max(0, strlen($digits) - 4)).'****';
    }

    private function maskEmail(?string $email): ?string
    {
        if ($email === null || $email === '' || ! str_contains($email, '@')) {
            return $email;
        }

        [$local, $domain] = explode('@', $email, 2);
        $visible = substr($local, 0, 2);

        return $visible.str_repeat('*', max(2, strlen($local) - 2)).'@'.$domain;
    }
}
