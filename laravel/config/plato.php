<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Plato API Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration for the Plato API proxy layer. The token must NEVER be
    | exposed to the mobile app — it stays in .env on the server side.
    |
    */

    'base_url' => env('PLATO_BASE_URL', 'https://clinic.platomedical.com/api/hemedclinic'),

    'api_token' => env('PLATO_API_TOKEN'),

    'timeout' => env('PLATO_TIMEOUT', 30),

    'cache' => [
        'enabled' => env('PLATO_CACHE_ENABLED', true),
        'ttl_facility' => env('PLATO_CACHE_TTL_FACILITY', 300),
        'ttl_doctor' => env('PLATO_CACHE_TTL_DOCTOR', 300),
        'ttl_slots' => env('PLATO_CACHE_TTL_SLOTS', 60),
        'ttl_default' => env('PLATO_CACHE_TTL_DEFAULT', 120),
    ],

    'log_requests' => env('PLATO_LOG_REQUESTS', true),

    'proxy_rate_limit' => env('PLATO_PROXY_RATE_LIMIT', 60),

    /*
    |--------------------------------------------------------------------------
    | Voucher / Redemption
    |--------------------------------------------------------------------------
    |
    | Path within the Plato API used to validate/redeem a voucher code.
    | Leave null if Plato does not provide a voucher endpoint — the CMS
    | voucher is then display-only. Configure when Plato supports it.
    |
    */

    'voucher_path' => env('PLATO_VOUCHER_PATH'),

    /*
    |--------------------------------------------------------------------------
    | Duplicate report snapshot
    |--------------------------------------------------------------------------
    |
    | Where the read-only duplicate-patient scan (plato:scan-duplicates) writes
    | its JSON snapshot. Defaults to storage/app/private/plato-duplicates.json.
    |
    */

    'duplicate_snapshot_path' => env('PLATO_DUPLICATE_SNAPSHOT_PATH'),

    /*
    |--------------------------------------------------------------------------
    | Duplicate scan pacing
    |--------------------------------------------------------------------------
    |
    | The duplicate scan pages through the entire Plato patient list, which is
    | the most rate-limit-prone operation in the app. throttle_ms inserts a
    | pause between pages; when Plato still answers 429 we retry with
    | exponential backoff up to max_retries times, honouring any retry-after
    | header Plato sends. Delays are in milliseconds.
    |
    */

    'duplicate_scan' => [
        'throttle_ms' => env('PLATO_DUPLICATE_THROTTLE_MS', 250),
        'max_retries' => env('PLATO_DUPLICATE_MAX_RETRIES', 5),
        'retry_base_ms' => env('PLATO_DUPLICATE_RETRY_BASE_MS', 1000),
    ],

    /*
    |--------------------------------------------------------------------------
    | Plato patient merge
    |--------------------------------------------------------------------------
    |
    | Merges two Plato patient records into one. Plato requires the exact
    | acknowledgement string and the action CANNOT be undone, so this is
    | disabled by default. Confirm the request/response field names with Plato
    | before enabling; they are configurable so the contract can be corrected
    | without a code change.
    |
    */

    'merge' => [
        'enabled' => env('PLATO_MERGE_ENABLED', false),
        'path' => env('PLATO_MERGE_PATH', 'patient/merge'),
        'acknowledge' => env('PLATO_MERGE_ACKNOWLEDGE', 'I understand that this action cannot be undone'),
        'primary_field' => env('PLATO_MERGE_PRIMARY_FIELD', 'primary_id'),
        'secondary_field' => env('PLATO_MERGE_SECONDARY_FIELD', 'secondary_id'),
    ],

];
