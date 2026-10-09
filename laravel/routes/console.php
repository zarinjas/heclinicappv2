<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::command('app:send-appointment-reminders')->everyMinute();

// Reminders for Plato-set follow-up/treatment appointments, 3 and 1 days out.
// Runs at 09:00 Malaysia time (the server itself runs on UTC).
Schedule::command('plato:send-appointment-reminders')
    ->dailyAt('09:00')
    ->timezone('Asia/Kuala_Lumpur');

Schedule::command('app:process-loyalty-earnings')->everyFiveMinutes();
