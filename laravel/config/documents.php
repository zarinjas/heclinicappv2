<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Document Link Lifetime
    |--------------------------------------------------------------------------
    |
    | How long a signed patient-document URL stays valid, in minutes. Applies
    | to links returned by the mobile API and shown in the admin panel, where
    | the link is used immediately.
    |
    */

    'link_ttl_minutes' => (int) env('DOCUMENT_LINK_TTL_MINUTES', 60),

    /*
    |--------------------------------------------------------------------------
    | Emailed Document Link Lifetime
    |--------------------------------------------------------------------------
    |
    | Links sent by email need to survive longer, since staff may not open the
    | message straight away. Defaults to 7 days.
    |
    */

    'email_link_ttl_minutes' => (int) env('DOCUMENT_EMAIL_LINK_TTL_MINUTES', 10080),

];
