<?php

namespace Tests\Unit;

use App\Services\PlatoDuplicateService;
use App\Services\PlatoProxyService;
use Tests\TestCase;

class PlatoDuplicateServiceTest extends TestCase
{
    private function service(): PlatoDuplicateService
    {
        return new PlatoDuplicateService(app(PlatoProxyService::class));
    }

    private function patient(string $id, array $overrides = []): array
    {
        return array_merge([
            '_id' => $id,
            'name' => 'Patient '.$id,
            'nric' => null,
            'telephone' => null,
            'email' => null,
            'created_on' => '2025-01-01',
        ], $overrides);
    }

    public function test_same_nric_records_cluster_together(): void
    {
        $clusters = $this->service()->buildClusters([
            $this->patient('a', ['nric' => '900101-14-1234']),
            $this->patient('b', ['nric' => '900101141234']),
            $this->patient('c', ['nric' => '880202025678']),
        ]);

        $this->assertCount(1, $clusters);
        $this->assertContains('same_ic', $clusters[0]['signals']);
        $this->assertSame(['a', 'b'], array_column($clusters[0]['records'], 'plato_id'));
    }

    public function test_same_phone_records_cluster_together(): void
    {
        $clusters = $this->service()->buildClusters([
            $this->patient('a', ['telephone' => '012-345 6789']),
            $this->patient('b', ['telephone' => '+60123456789']),
        ]);

        $this->assertCount(1, $clusters);
        $this->assertContains('same_phone', $clusters[0]['signals']);
    }

    public function test_overlapping_nric_and_phone_groups_collapse_into_one_cluster(): void
    {
        // a & b share an IC; b & c share a phone; all three become one cluster.
        $clusters = $this->service()->buildClusters([
            $this->patient('a', ['nric' => '900101141234', 'telephone' => '60111111111']),
            $this->patient('b', ['nric' => '900101141234', 'telephone' => '60122222222']),
            $this->patient('c', ['nric' => '880202025678', 'telephone' => '60122222222']),
        ]);

        $this->assertCount(1, $clusters);
        $this->assertSame(['same_ic', 'same_phone'], $clusters[0]['signals']);
        $this->assertCount(3, $clusters[0]['records']);
        $this->assertSame('Same IC & phone', $clusters[0]['signal_label']);
    }

    public function test_distinct_records_produce_no_clusters(): void
    {
        $clusters = $this->service()->buildClusters([
            $this->patient('a', ['nric' => '900101141234', 'telephone' => '60111111111']),
            $this->patient('b', ['nric' => '880202025678', 'telephone' => '60122222222']),
        ]);

        $this->assertSame([], $clusters);
    }

    public function test_records_with_missing_identifiers_are_ignored(): void
    {
        $clusters = $this->service()->buildClusters([
            $this->patient('a'),
            $this->patient('b', ['nric' => '']),
            $this->patient('c', ['telephone' => '   ']),
        ]);

        $this->assertSame([], $clusters);
    }

    public function test_normalises_nric_and_phone(): void
    {
        $service = $this->service();

        $this->assertSame('900101141234', $service->normaliseNric('900101-14-1234'));
        $this->assertSame('S1234567A', $service->normaliseNric('s1234567a'));
        $this->assertNull($service->normaliseNric('  '));

        $this->assertSame('60123456789', $service->normalisePhone('012-345 6789'));
        $this->assertSame('60123456789', $service->normalisePhone('+60 12 345 6789'));
        $this->assertNull($service->normalisePhone('   '));
    }

    public function test_fetch_all_patients_retries_on_rate_limit_then_succeeds(): void
    {
        config([
            'plato.duplicate_scan.max_retries' => 5,
            'plato.duplicate_scan.retry_base_ms' => 10,
            'plato.duplicate_scan.throttle_ms' => 5,
        ]);

        $service = $this->fakeScanService([
            ['error' => true, 'code' => 429, 'message' => 'rate limited', 'headers' => []],
            ['data' => [$this->patient('a', ['nric' => '900101141234'])], 'status' => 200],
            ['data' => [], 'status' => 200],
        ]);

        $records = $service->fetchAllPatients();

        $this->assertCount(1, $records);
        $this->assertSame([10, 5], $service->pauses);
    }

    public function test_fetch_all_patients_gives_up_after_max_retries(): void
    {
        config([
            'plato.duplicate_scan.max_retries' => 3,
            'plato.duplicate_scan.retry_base_ms' => 10,
            'plato.duplicate_scan.throttle_ms' => 0,
        ]);

        $service = $this->fakeScanService([
            ['error' => true, 'code' => 429, 'message' => 'rate limited', 'headers' => []],
            ['error' => true, 'code' => 429, 'message' => 'rate limited', 'headers' => []],
            ['error' => true, 'code' => 429, 'message' => 'rate limited', 'headers' => []],
        ]);

        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Plato API error while listing patients: rate limited');

        try {
            $service->fetchAllPatients();
        } finally {
            $this->assertSame([10, 20], $service->pauses);
        }
    }

    public function test_retry_delay_honours_retry_after_header(): void
    {
        $service = $this->fakeScanService([]);

        $this->assertSame(
            2000,
            $service->exposedRetryDelayMs(['headers' => ['retry-after' => '2']], 1000, 0)
        );
        $this->assertSame(
            4000,
            $service->exposedRetryDelayMs(['headers' => []], 1000, 2)
        );
    }

    /**
     * @param  array<int, array<string,mixed>>  $responses
     */
    private function fakeScanService(array $responses): PlatoDuplicateService
    {
        return new class(app(PlatoProxyService::class), $responses) extends PlatoDuplicateService
        {
            /** @var array<int, array<string,mixed>> */
            public array $responses;

            /** @var array<int, int> */
            public array $pauses = [];

            private int $calls = 0;

            public function __construct(PlatoProxyService $proxy, array $responses)
            {
                parent::__construct($proxy);
                $this->responses = $responses;
            }

            protected function requestPatientPage(int $page): array
            {
                return $this->responses[$this->calls++] ?? ['data' => []];
            }

            protected function pause(int $milliseconds): void
            {
                $this->pauses[] = $milliseconds;
            }

            public function exposedRetryDelayMs(array $result, int $baseMs, int $attempt): int
            {
                return $this->retryDelayMs($result, $baseMs, $attempt);
            }
        };
    }
}
