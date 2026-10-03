<?php

namespace Tests\Feature;

use App\Models\Patient;
use App\Models\User;
use App\Services\PlatoDuplicateService;
use App\Services\PlatoProxyService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PatientDuplicateReportTest extends TestCase
{
    use RefreshDatabase;

    private string $snapshotPath;

    protected function setUp(): void
    {
        parent::setUp();

        $this->snapshotPath = sys_get_temp_dir().'/plato-dup-test-'.uniqid().'.json';
        config(['plato.duplicate_snapshot_path' => $this->snapshotPath]);
    }

    protected function tearDown(): void
    {
        if (is_file($this->snapshotPath)) {
            unlink($this->snapshotPath);
        }

        parent::tearDown();
    }

    private function makeAdmin(string $role = 'super_admin'): User
    {
        return User::create([
            'name' => 'Admin',
            'email' => $role.'-'.uniqid().'@example.com',
            'password' => Hash::make('password'),
            'role' => $role,
        ]);
    }

    private function seedSnapshot(array $clusters, int $total = 0): void
    {
        app(PlatoDuplicateService::class)->writeSnapshot([
            'scanned_at' => now()->toIso8601String(),
            'total_scanned' => $total,
            'cluster_count' => count($clusters),
            'clusters' => $clusters,
        ]);
    }

    private function record(string $id, string $name, string $nric = '900101141234'): array
    {
        return [
            'plato_id' => $id,
            'name' => $name,
            'nric' => $nric,
            'phone' => null,
            'email' => null,
            'created_on' => '2025-01-01',
            'app_account_id' => null,
            'app_account_name' => null,
        ];
    }

    public function test_index_requires_super_admin(): void
    {
        $staff = $this->makeAdmin('staff');

        $this->actingAs($staff)
            ->get(route('admin.patient-duplicates.index'))
            ->assertForbidden();
    }

    public function test_index_renders_snapshot_clusters(): void
    {
        $this->seedSnapshot([
            [
                'id' => 'dup-abc',
                'signals' => ['same_ic'],
                'signal_label' => 'Same IC',
                'records' => [
                    $this->record('p1', 'Ahmad Bin Ali'),
                    $this->record('p2', 'Ahmad Ali'),
                ],
            ],
        ], total: 120);

        $this->actingAs($this->makeAdmin())
            ->get(route('admin.patient-duplicates.index'))
            ->assertOk()
            ->assertSee('Same IC')
            ->assertSee('Ahmad Bin Ali')
            ->assertSee('Ahmad Ali')
            ->assertSee('p1');
    }

    public function test_index_filters_by_signal(): void
    {
        $this->seedSnapshot([
            [
                'id' => 'dup-ic',
                'signals' => ['same_ic'],
                'signal_label' => 'Same IC',
                'records' => [$this->record('p1', 'Same Ic Person')],
            ],
            [
                'id' => 'dup-phone',
                'signals' => ['same_phone'],
                'signal_label' => 'Same phone',
                'records' => [$this->record('p2', 'Same Phone Person', '888888888888')],
            ],
        ]);

        $this->actingAs($this->makeAdmin())
            ->get(route('admin.patient-duplicates.index', ['signal' => 'same_ic']))
            ->assertOk()
            ->assertSee('Same Ic Person')
            ->assertDontSee('Same Phone Person');
    }

    public function test_export_streams_csv(): void
    {
        $this->seedSnapshot([
            [
                'id' => 'dup-abc',
                'signals' => ['same_ic'],
                'signal_label' => 'Same IC',
                'records' => [
                    $this->record('p1', 'Ahmad Bin Ali'),
                    $this->record('p2', 'Ahmad Ali'),
                ],
            ],
        ]);

        $response = $this->actingAs($this->makeAdmin())
            ->get(route('admin.patient-duplicates.export'));

        $response->assertOk();
        $this->assertStringContainsString('text/csv', (string) $response->headers->get('content-type'));

        $csv = $response->streamedContent();
        $this->assertStringContainsString('cluster,signals,plato_id', $csv);
        $this->assertStringContainsString('Ahmad Bin Ali', $csv);
        $this->assertStringContainsString('dup-abc', $csv);
    }

    public function test_scan_via_http_builds_and_stores_snapshot(): void
    {
        $linked = Patient::create([
            'name' => 'Ahmad Bin Ali',
            'nric' => '900101141234',
            'telephone' => '60111111111',
            'idplato' => 'p1',
            'password' => Hash::make('secret123'),
        ]);

        $fake = new class(app(PlatoProxyService::class)) extends PlatoDuplicateService
        {
            /** @var array<int, array<string,mixed>> */
            public array $records = [];

            public function fetchAllPatients(?callable $progress = null): array
            {
                return $this->records;
            }
        };

        $fake->records = [
            ['_id' => 'p1', 'name' => 'Ahmad Bin Ali', 'nric' => '900101-14-1234', 'telephone' => '60111111111', 'created_on' => '2025-01-01'],
            ['_id' => 'p2', 'name' => 'Ahmad Ali', 'nric' => '900101141234', 'telephone' => '60122222222', 'created_on' => '2025-02-01'],
        ];

        $this->app->instance(PlatoDuplicateService::class, $fake);

        $this->actingAs($this->makeAdmin())
            ->post(route('admin.patient-duplicates.scan'))
            ->assertRedirect(route('admin.patient-duplicates.index'));

        $this->assertFileExists($this->snapshotPath);

        $snapshot = app(PlatoDuplicateService::class)->readSnapshot();
        $this->assertSame(2, $snapshot['total_scanned']);
        $this->assertSame(1, $snapshot['cluster_count']);
        $this->assertNotNull($snapshot['clusters'][0]['records'][0]['app_account_id'] ?? null);

        // The linked local account should surface on the report.
        $this->actingAs($this->makeAdmin())
            ->get(route('admin.patient-duplicates.index'))
            ->assertOk()
            ->assertSee('Linked #'.$linked->id);
    }
}
