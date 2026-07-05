<?php

return [

    'project_id' => env('FIREBASE_PROJECT_ID', 'heclinicapps-8be27'),

    'web_api_key' => env('FIREBASE_WEB_API_KEY'),

    'firestore_base_url' => env('FIREBASE_FIRESTORE_URL', 'https://firestore.googleapis.com/v1'),

    'fcm_endpoint' => env('FIREBASE_FCM_URL', 'https://fcm.googleapis.com/v1'),

    'service_account_path' => env('FIREBASE_SERVICE_ACCOUNT_PATH'),

];
