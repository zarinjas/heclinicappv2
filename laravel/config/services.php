<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'plato' => [
        'token' => env('PLATO_API_TOKEN'),
        'base_url' => env('PLATO_BASE_URL', 'https://clinic.platomedical.com/api/hemedclinic'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Social Sign-In
    |--------------------------------------------------------------------------
    |
    | Expected `aud` values for provider identity tokens. A token whose
    | audience is not in this list was minted for a different app and MUST be
    | rejected, otherwise anyone with any Google/Apple token could sign in.
    |
    | APPLE_CLIENT_IDS: the iOS bundle identifier (and the Services ID if a web
    | flow is ever added), comma-separated.
    | GOOGLE_CLIENT_IDS: the OAuth client IDs for each platform, comma-separated.
    |
    */

    'apple' => [
        'client_ids' => array_values(array_filter(array_map(
            'trim',
            explode(',', (string) env('APPLE_CLIENT_IDS', 'com.hemedgroup.heclinicapps'))
        ))),
    ],

    'google' => [
        'client_ids' => array_values(array_filter(array_map(
            'trim',
            explode(',', (string) env('GOOGLE_CLIENT_IDS', ''))
        ))),
    ],

    // OTP delivery channel: 'email' (Resend) | 'whatsapp' (OneSender)
    'otp' => [
        'channel' => env('OTP_CHANNEL', 'email'),
    ],

    'onesender' => [
        'url' => env('ONESENDER_URL'),
        'key' => env('ONESENDER_KEY'),
        'clinic_whatsapp' => env('ONESENDER_CLINIC_WHATSAPP', '601167208860'),
    ],

];
