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

];
