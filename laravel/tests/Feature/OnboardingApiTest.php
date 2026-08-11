<?php

namespace Tests\Feature;

use App\Models\CmsOnboardingSlide;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

/**
 * Guards GET /api/v2/cms/onboarding-slides.
 *
 * A slide can hold a DB reference to a media file that no longer exists on
 * disk (an admin upload that was later removed, or wiped by a deploy). Serving
 * that URL made the app wait on a 404 before falling back. The endpoint must
 * return null for missing files so the app goes straight to the image or the
 * gradient.
 */
class OnboardingApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
    }

    private function slide(array $attrs = []): CmsOnboardingSlide
    {
        return CmsOnboardingSlide::create(array_merge([
            'title' => 'Slide',
            'subtitle' => 'Sub',
            'is_active' => true,
        ], $attrs));
    }

    public function test_a_video_whose_file_exists_is_returned(): void
    {
        Storage::disk('public')->put('onboarding/real.mp4', 'data');
        $this->slide(['video' => 'onboarding/real.mp4']);

        $response = $this->getJson('/api/v2/cms/onboarding-slides');

        $response->assertStatus(200);
        $this->assertStringContainsString(
            'onboarding/real.mp4',
            $response->json('0.video')
        );
    }

    public function test_a_video_whose_file_is_missing_is_returned_as_null(): void
    {
        // DB references a file that was never written to disk.
        $this->slide(['video' => 'onboarding/ghost.mp4']);

        $response = $this->getJson('/api/v2/cms/onboarding-slides');

        $response->assertStatus(200);
        $this->assertNull($response->json('0.video'));
    }

    public function test_a_missing_image_is_returned_as_null_but_the_slide_stays(): void
    {
        // Image gone, but the slide should still appear (gradient fallback).
        $this->slide([
            'image' => 'onboarding/gone.jpg',
            'gradient_start' => '#3B8DFF',
            'gradient_end' => '#27F5A3',
        ]);

        $response = $this->getJson('/api/v2/cms/onboarding-slides');

        $response->assertStatus(200);
        $this->assertNull($response->json('0.image'));
        $this->assertSame('#3B8DFF', $response->json('0.gradient_start'));
    }

    public function test_inactive_slides_are_excluded(): void
    {
        $this->slide(['is_active' => false]);

        $this->getJson('/api/v2/cms/onboarding-slides')
            ->assertStatus(200)
            ->assertJsonCount(0);
    }
}
