<?php

namespace Tests\Feature;

use App\Models\Patient;
use App\Models\PatientNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class NotificationInboxTest extends TestCase
{
    use RefreshDatabase;

    private function makePatient(string $idplato, string $nric): Patient
    {
        return Patient::create([
            'name' => 'Patient '.$idplato,
            'nric' => $nric,
            'telephone' => '60111111'.substr($nric, -4),
            'idplato' => $idplato,
            'password' => Hash::make('secret123'),
        ]);
    }

    private function makeNotification(string $platoId, ?string $readAt = null): PatientNotification
    {
        return PatientNotification::create([
            'patient_plato_id' => $platoId,
            'type' => 'manual',
            'title' => 'Hello',
            'body' => 'A message for '.$platoId,
            'deep_link' => 'profile',
            'read_at' => $readAt,
        ]);
    }

    public function test_patient_only_sees_their_own_notifications(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');
        $this->makePatient('PLATO-B', '900101010002');

        $this->makeNotification('PLATO-A');
        $this->makeNotification('PLATO-B');
        $this->makeNotification('PLATO-B');

        $response = $this->actingAs($patient, 'sanctum')->getJson('/api/v2/notifications');

        $response->assertOk();
        $response->assertJsonCount(1, 'notifications');
        $this->assertSame('A message for PLATO-A', $response->json('notifications.0.body'));
    }

    public function test_unread_count_reflects_only_own_unread(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');

        $this->makeNotification('PLATO-A');
        $this->makeNotification('PLATO-A');
        $this->makeNotification('PLATO-A', now()->toDateTimeString());
        $this->makeNotification('PLATO-B');

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/notifications/unread-count')
            ->assertOk()
            ->assertJsonPath('unread_count', 2);
    }

    public function test_marking_read_updates_count(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');
        $notification = $this->makeNotification('PLATO-A');

        $this->actingAs($patient, 'sanctum')
            ->postJson("/api/v2/notifications/{$notification->id}/read")
            ->assertOk()
            ->assertJsonPath('unread_count', 0);

        $this->assertNotNull($notification->fresh()->read_at);
    }

    public function test_cannot_mark_another_patients_notification_as_read(): void
    {
        $attacker = $this->makePatient('PLATO-A', '900101010001');
        $this->makePatient('PLATO-B', '900101010002');
        $victimNotification = $this->makeNotification('PLATO-B');

        $this->actingAs($attacker, 'sanctum')
            ->postJson("/api/v2/notifications/{$victimNotification->id}/read")
            ->assertStatus(404);

        $this->assertNull($victimNotification->fresh()->read_at);
    }

    public function test_mark_all_read_only_affects_own_notifications(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');
        $this->makeNotification('PLATO-A');
        $this->makeNotification('PLATO-A');
        $other = $this->makeNotification('PLATO-B');

        $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/notifications/read-all')
            ->assertOk()
            ->assertJsonPath('unread_count', 0);

        $this->assertSame(0, PatientNotification::where('patient_plato_id', 'PLATO-A')->whereNull('read_at')->count());
        $this->assertNull($other->fresh()->read_at, 'Other patients must be untouched.');
    }

    public function test_inbox_requires_authentication(): void
    {
        $this->getJson('/api/v2/notifications')->assertStatus(401);
    }
}
