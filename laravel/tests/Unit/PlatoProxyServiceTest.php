<?php

namespace Tests\Unit;

use App\Jobs\RefreshPlatoCache;
use App\Services\PlatoProxyService;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Queue;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PlatoProxyServiceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'plato.base_url' => 'https://plato.test/api/db',
            'plato.api_token' => 'test-token',
            'plato.cache.enabled' => true,
            'plato.cache.store' => 'array',
            'plato.cache.stale_while_revalidate' => 900,
            'plato.retry.max_attempts' => 1,
        ]);
        Cache::flush();
    }

    public function test_successful_get_is_cached_and_reused(): void
    {
        Http::fake(['https://plato.test/api/db/facility*' => Http::response(['rows' => [1]], 200)]);
        $service = app(PlatoProxyService::class);

        $first = $service->proxy('GET', 'facility', ['current_page' => 1]);
        $this->assertNotNull(Cache::store('array')->get($this->cacheKey('facility', ['current_page' => 1])));
        $second = $service->proxy('GET', 'facility', ['current_page' => 1]);

        $this->assertSame($first, $second);
        Http::assertSentCount(1);
    }

    public function test_stale_cache_is_returned_and_refresh_is_queued_on_rate_limit(): void
    {
        Queue::fake();
        Http::fake(['https://plato.test/api/db/appointment*' => Http::response(['rows' => [1]], 200)]);
        $service = app(PlatoProxyService::class);
        $service->proxy('GET', 'appointment', ['patient_id' => 'PATIENT-A']);

        config(['plato.cache.store' => 'array']);
        Http::fake(['https://plato.test/api/db/appointment*' => Http::response([], 429)]);
        $key = $this->cacheKey('appointment', ['patient_id' => 'PATIENT-A']);
        $entry = Cache::get($key);
        Cache::put($key, array_merge($entry, [
            'fresh_until' => now()->subSecond()->timestamp,
            'stale_until' => now()->addMinute()->timestamp,
        ]), 900);

        $result = $service->proxy('GET', 'appointment', ['patient_id' => 'PATIENT-A']);

        $this->assertSame(['rows' => [1]], $result['data']);
        $this->assertSame('true', $result['headers']['x-plato-data-stale']);
        Queue::assertPushed(RefreshPlatoCache::class);
    }

    public function test_patient_cache_entries_are_isolated(): void
    {
        Http::fake(['https://plato.test/api/db/invoice*' => Http::sequence()
            ->push(['patient' => 'A'], 200)
            ->push(['patient' => 'B'], 200)]);
        $service = app(PlatoProxyService::class);

        $a = $service->proxy('GET', 'invoice', ['patient_id' => 'PATIENT-A']);
        $b = $service->proxy('GET', 'invoice', ['patient_id' => 'PATIENT-B']);

        $this->assertSame('A', $a['data']['patient']);
        $this->assertSame('B', $b['data']['patient']);
        Http::assertSentCount(2);
    }

    public function test_forced_refresh_falls_back_to_cached_data_on_rate_limit(): void
    {
        Http::fake(['https://plato.test/api/db/invoice*' => Http::sequence()
            ->push(['total' => 10], 200)
            ->push([], 429)]);
        $service = app(PlatoProxyService::class);
        $service->proxy('GET', 'invoice', ['patient_id' => 'PATIENT-A']);

        $result = $service->proxy('GET', 'invoice', ['patient_id' => 'PATIENT-A'], [], true);

        $this->assertSame(['total' => 10], $result['data']);
        $this->assertSame('true', $result['headers']['x-plato-data-stale']);
    }

    public function test_successful_mutation_invalidates_all_patient_cache_variants(): void
    {
        Http::fake(['https://plato.test/api/db/invoice*' => Http::response(['value' => 1], 200)]);
        $service = app(PlatoProxyService::class);
        $service->proxy('GET', 'invoice', ['patient_id' => 'PATIENT-A', 'current_page' => 1]);
        $service->invalidatePatient('PATIENT-A', ['invoice']);
        $service->proxy('GET', 'invoice', ['patient_id' => 'PATIENT-A', 'current_page' => 1]);

        Http::assertSentCount(2);
    }

    private function cacheKey(string $path, array $query): string
    {
        $service = app(PlatoProxyService::class);
        $reflection = new \ReflectionClass($service);
        $method = $reflection->getMethod('buildCacheKey');
        $method->setAccessible(true);

        return $method->invoke($service, 'GET', 'https://plato.test/api/db/'.$path, $query, []);
    }
}
