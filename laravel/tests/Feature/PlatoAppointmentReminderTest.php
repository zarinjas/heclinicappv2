<?php

namespace Tests\Feature;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\PlatoAppointmentReminder;
use App\Services\NotificationService;
use App\Services\PlatoAppointmentReminderService;
use App\Services\PlatoProxyService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PlatoAppointmentReminderTest extends TestCase
{
    use RefreshDatabase;

    private function makePatient(string $platoId): Patient
    {
        return Patient::create([
            'name' => 'Patient '.$platoId,
            'nric' => '9001011400'.random_int(10, 99),
            'telephone' => '6011111'.random_int(1000, 9999),
            'idplato' => $platoId,
            'password' => Hash::make('secret123'),
        ]);
    }

    private function appointment(string $id, int $daysFromNow): array
    {
        return [
            'appointment_id' => $id,
            'starttime' => Carbon::now('Asia/Kuala_Lumpur')
                ->addDays($daysFromNow)
                ->setTime(10, 0)
                ->toDateTimeString(),
            'name_Background' => 'Dr. Ahmad',
            'name_Top' => 'He Clinic Shah Alam',
        ];
    }

    private function fakeService(array $fixtures): PlatoAppointmentReminderService
    {
        $fake = new class(app(PlatoProxyService::class), app(NotificationService::class)) extends PlatoAppointmentReminderService
        {
            /** @var array<int, array<string,mixed>> */
            public array $fixtures = [];

            /** @var array<int, array{id:string,days:int}> */
            public array $sent = [];

            public function upcomingAppointments(string $patientId): array
            {
                return $this->fixtures;
            }

            protected function notify(array $appointment, Patient $patient, int $daysBefore): void
            {
                $this->sent[] = [
                    'id' => (string) ($appointment['appointment_id'] ?? $appointment['id'] ?? ''),
                    'days' => $daysBefore,
                ];
            }
        };

        $fake->fixtures = $fixtures;

        return $fake;
    }

    public function test_sends_reminders_only_at_three_and_one_days(): void
    {
        $patient = $this->makePatient('PLATO-1');

        $fake = $this->fakeService([
            $this->appointment('APT-3D', 3),
            $this->appointment('APT-1D', 1),
            $this->appointment('APT-5D', 5),
        ]);

        $this->app->instance(PlatoAppointmentReminderService::class, $fake);

        $this->artisan('plato:send-appointment-reminders')->assertSuccessful();

        $this->assertEqualsCanonicalizing([
            ['id' => 'APT-3D', 'days' => 3],
            ['id' => 'APT-1D', 'days' => 1],
        ], $fake->sent);

        $this->assertDatabaseHas('plato_appointment_reminders', [
            'plato_appointment_id' => 'APT-3D',
            'offset_days' => 3,
            'patient_plato_id' => $patient->idplato,
        ]);
        $this->assertDatabaseHas('plato_appointment_reminders', [
            'plato_appointment_id' => 'APT-1D',
            'offset_days' => 1,
        ]);
        $this->assertDatabaseMissing('plato_appointment_reminders', [
            'plato_appointment_id' => 'APT-5D',
        ]);
    }

    public function test_does_not_send_the_same_reminder_twice(): void
    {
        $this->makePatient('PLATO-1');

        $fixtures = [$this->appointment('APT-3D', 3)];

        $first = $this->fakeService($fixtures);
        $this->app->instance(PlatoAppointmentReminderService::class, $first);
        $this->artisan('plato:send-appointment-reminders')->assertSuccessful();
        $this->assertCount(1, $first->sent);

        $second = $this->fakeService($fixtures);
        $this->app->instance(PlatoAppointmentReminderService::class, $second);
        $this->artisan('plato:send-appointment-reminders')->assertSuccessful();

        $this->assertCount(0, $second->sent, 'A reminder already sent must not be sent again.');
        $this->assertSame(1, PlatoAppointmentReminder::count());
    }

    public function test_skips_app_booked_appointments(): void
    {
        $this->makePatient('PLATO-1');

        Appointment::create([
            'plato_appointment_id' => 'APT-LOCAL',
            'patient_plato_id' => 'PLATO-1',
            'patient_name' => 'Patient',
            'patient_phone' => '60111111111',
            'appointment_date' => Carbon::now('Asia/Kuala_Lumpur')->addDays(3)->toDateString(),
            'appointment_time' => '10:00',
            'status' => 'confirmed',
        ]);

        $fake = $this->fakeService([
            $this->appointment('APT-LOCAL', 3),
            $this->appointment('APT-PLATO', 3),
        ]);

        $this->app->instance(PlatoAppointmentReminderService::class, $fake);

        $this->artisan('plato:send-appointment-reminders')->assertSuccessful();

        $this->assertSame(
            [['id' => 'APT-PLATO', 'days' => 3]],
            $fake->sent,
            'App-booked appointments are already covered by the 24h/1h job.',
        );
    }
}
