<?php

namespace Tests\Feature;

use App\Models\Patient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

/**
 * Guards the patient-scoping rules on the endpoints that expose medical data.
 *
 * Both of these were previously unscoped: any authenticated patient could read
 * another patient's documents and clinical notes by changing the id in the URL.
 */
class PatientDataScopingTest extends TestCase
{
    use RefreshDatabase;

    private function makePatient(string $idplato, string $nric): Patient
    {
        return Patient::create([
            'name' => 'Patient '.$idplato,
            'nric' => $nric,
            'telephone' => '6011'.substr($idplato.'00000000', 0, 8),
            'idplato' => $idplato,
            'password' => Hash::make('secret123'),
        ]);
    }

    private function makeDocument(string $platoUid): int
    {
        return DB::table('patient_documents')->insertGetId([
            'patient_plato_uid' => $platoUid,
            'filename' => 'file-'.$platoUid.'.pdf',
            'original_name' => 'result.pdf',
            'title' => 'Blood test',
            'mime_type' => 'application/pdf',
            'size_bytes' => 1024,
            'source' => 'admin',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function test_patient_can_list_their_own_documents(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');
        $this->makeDocument('PLATO-A');

        $response = $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/patients/PLATO-A/documents');

        $response->assertOk();
        $this->assertCount(1, $response->json('documents'));
    }

    public function test_patient_cannot_list_another_patients_documents(): void
    {
        $attacker = $this->makePatient('PLATO-A', '900101010001');
        $this->makePatient('PLATO-B', '900101010002');
        $this->makeDocument('PLATO-B');

        $this->actingAs($attacker, 'sanctum')
            ->getJson('/api/v2/patients/PLATO-B/documents')
            ->assertStatus(403);
    }

    public function test_patient_cannot_upload_documents_for_another_patient(): void
    {
        $attacker = $this->makePatient('PLATO-A', '900101010001');
        $this->makePatient('PLATO-B', '900101010002');

        $this->actingAs($attacker, 'sanctum')
            ->postJson('/api/v2/patients/PLATO-B/documents')
            ->assertStatus(403);
    }

    public function test_proxy_rejects_another_patients_path(): void
    {
        $attacker = $this->makePatient('PLATO-A', '900101010001');

        $this->actingAs($attacker, 'sanctum')
            ->getJson('/api/v2/plato/patient/PLATO-B/note')
            ->assertStatus(403);
    }

    public function test_proxy_blocks_clinical_notes_even_for_the_owner(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/plato/patient/PLATO-A/note')
            ->assertStatus(403);
    }

    public function test_proxy_blocks_clinical_note_detail_even_for_the_owner(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/plato/patient/PLATO-A/note/12345')
            ->assertStatus(403);
    }

    public function test_proxy_blocks_casenote_and_admin_note_even_for_the_owner(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');

        foreach (['casenote', 'casenotes', 'adminnote', 'adminnotes', 'admin'] as $path) {
            $this->actingAs($patient, 'sanctum')
                ->getJson("/api/v2/plato/patient/PLATO-A/{$path}")
                ->assertStatus(403);
        }
    }

    public function test_proxy_rejects_another_patients_query_parameter(): void
    {
        $attacker = $this->makePatient('PLATO-A', '900101010001');

        $this->actingAs($attacker, 'sanctum')
            ->getJson('/api/v2/plato/letter?patient_id=PLATO-B')
            ->assertStatus(403);
    }

    public function test_proxy_requires_patient_scope_for_patient_data_lists(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');

        // Without a patient_id these endpoints would return every patient's
        // records because the proxy uses the privileged server token.
        foreach (['letter', 'invoice', 'payment', 'appointment'] as $path) {
            $this->actingAs($patient, 'sanctum')
                ->getJson("/api/v2/plato/{$path}")
                ->assertStatus(403);
        }
    }

    public function test_proxy_allows_scoped_letter_request(): void
    {
        config(['plato.base_url' => 'https://plato.test/api/db']);
        Cache::flush();
        Http::fake(['*' => Http::response([], 200)]);

        $patient = $this->makePatient('PLATO-A', '900101010001');

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/plato/letter?patient_id=PLATO-A')
            ->assertOk();
    }

    public function test_proxy_does_not_require_scope_for_slots(): void
    {
        config(['plato.base_url' => 'https://plato.test/api/db']);
        Cache::flush();
        Http::fake(['*' => Http::response([], 200)]);

        $patient = $this->makePatient('PLATO-A', '900101010001');

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/plato/appointment/slots')
            ->assertOk();
    }

    public function test_proxy_strips_clinical_note_fields_from_patient_record(): void
    {
        config(['plato.base_url' => 'https://plato.test/api/db']);
        Cache::flush();
        Http::fake([
            'https://plato.test/api/db/patient/*' => Http::response([[
                '_id' => 'PLATO-A',
                'name' => 'Test User',
                'nric' => '900101010001',
                'casenote' => 'secret clinical note',
                'admin_note' => 'secret admin note',
                'notes' => 'more secrets',
            ]], 200),
        ]);

        $patient = $this->makePatient('PLATO-A', '900101010001');

        $response = $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/plato/patient/PLATO-A')
            ->assertOk();

        $this->assertSame('Test User', $response->json('0.name'));
        $this->assertArrayNotHasKey('casenote', $response->json('0'));
        $this->assertArrayNotHasKey('admin_note', $response->json('0'));
        $this->assertArrayNotHasKey('notes', $response->json('0'));
    }

    public function test_document_urls_are_signed_and_not_raw_storage_links(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');
        $this->makeDocument('PLATO-A');

        $url = $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/patients/PLATO-A/documents')
            ->json('documents.0.url');

        $this->assertStringContainsString('/documents/', $url);
        $this->assertStringContainsString('signature=', $url, 'Document links must be signed.');
        $this->assertStringNotContainsString('/storage/', $url, 'Must not expose the raw public storage path.');
    }

    public function test_unsigned_document_link_is_rejected(): void
    {
        $id = $this->makeDocument('PLATO-A');

        $this->get("/documents/{$id}")->assertStatus(403);
    }

    public function test_tampered_document_signature_is_rejected(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');
        $id = $this->makeDocument('PLATO-A');

        $url = $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/patients/PLATO-A/documents')
            ->json('documents.0.url');

        $this->get($url.'tampered')->assertStatus(403);
    }

    public function test_device_token_registration_stores_token_and_detaches_previous_owner(): void
    {
        $previousOwner = $this->makePatient('PLATO-A', '900101010001');
        $previousOwner->update(['fcm_token' => 'shared-device-token']);

        $newOwner = $this->makePatient('PLATO-B', '900101010002');

        $this->actingAs($newOwner, 'sanctum')
            ->postJson('/api/v2/auth/device-token', ['fcm_token' => 'shared-device-token'])
            ->assertOk();

        $this->assertSame('shared-device-token', $newOwner->fresh()->fcm_token);
        $this->assertNull($previousOwner->fresh()->fcm_token, 'Old account should no longer receive this device\'s pushes.');
    }

    public function test_logout_clears_the_device_token(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');
        $patient->update(['fcm_token' => 'device-token']);

        $this->actingAs($patient, 'sanctum')
            ->postJson('/api/v2/auth/logout')
            ->assertOk();

        $this->assertNull($patient->fresh()->fcm_token);
    }

    public function test_health_records_expose_only_allowed_plato_files(): void
    {
        config(['plato.base_url' => 'https://plato.test/api/db']);
        Cache::flush();
        Http::fake([
            'https://plato.test/api/db/letter*' => Http::response([
                ['subject' => 'Medical Certificate', 'html' => '<p>MC</p>', 'created_on' => '2026-11-16'],
                ['subject' => 'Referral Letter', 'html' => '<p>private</p>', 'created_on' => '2026-11-16'],
            ], 200),
            'https://plato.test/api/db/patient/PLATO-A/note*' => Http::response([
                [
                    'folder_name' => 'Labs',
                    'timestamp' => '2026-11-16',
                    'attachments' => ['/files/lab.pdf'],
                    'note' => 'not returned',
                ],
                [
                    'folder_name' => 'Radiology',
                    'timestamp' => '2026-11-15',
                    'attachments' => [['path' => '/files/xray.pdf', 'name' => 'X-ray.pdf']],
                ],
                [
                    'folder_name' => 'Casenotes',
                    'timestamp' => '2026-11-14',
                    'attachments' => ['/files/private.pdf'],
                    'note' => 'private',
                ],
                [
                    'folder_name' => 'Admin',
                    'timestamp' => '2026-11-13',
                    'attachments' => ['/files/admin.pdf'],
                ],
            ], 200),
        ]);

        $patient = $this->makePatient('PLATO-A', '900101010001');

        $response = $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/patients/PLATO-A/health-records')
            ->assertOk();

        $records = $response->json('records');
        $this->assertCount(3, $records);
        $this->assertSame(['mc', 'lab', 'radiology'], array_column($records, 'type'));
        $this->assertStringContainsString('/health-record-file', $records[1]['detail_data']);
        $this->assertStringNotContainsString('private', json_encode($records));
        $this->assertStringNotContainsString('admin.pdf', json_encode($records));
    }

    public function test_health_records_are_scoped_to_the_logged_in_patient(): void
    {
        $patient = $this->makePatient('PLATO-A', '900101010001');

        $this->actingAs($patient, 'sanctum')
            ->getJson('/api/v2/patients/PLATO-B/health-records')
            ->assertStatus(403);
    }
}
