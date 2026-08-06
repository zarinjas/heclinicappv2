<?php
namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Tests\TestCase;
use App\Models\User;
use App\Models\CmsOnboardingSlide;
use Illuminate\Support\Facades\Storage;

class OnboardingVideoTest extends TestCase
{
    use RefreshDatabase;

    private string $fixture;

    protected function setUp(): void
    {
        parent::setUp();
        exec('ffmpeg -version 2>&1', $out, $code);
        if ($code !== 0) {
            $this->markTestSkipped('ffmpeg is required for video optimisation tests.');
        }
        $this->fixture = tempnam(sys_get_temp_dir(), 'slide').'.mov';
        exec(
            'ffmpeg -y -f lavfi -i "testsrc=size=1080x1920:rate=30:duration=2" '
            .'-f lavfi -i "sine=frequency=440:duration=2" '
            .'-c:v libx264 -c:a aac '.escapeshellarg($this->fixture).' 2>&1',
            $_, $code
        );
        if ($code !== 0) {
            $this->markTestSkipped('Could not generate test video fixture.');
        }
    }

    protected function tearDown(): void
    {
        @unlink($this->fixture);
        parent::tearDown();
    }

    private function admin(): User
    {
        return User::create([
            'name' => 'Super Admin',
            'email' => 'admin@heclinic.com',
            'password' => bcrypt('secret'),
            'role' => 'super_admin',
        ]);
    }

    public function test_video_upload_is_optimised_to_faststart_mp4(): void
    {
        Storage::fake('public');

        $video = new UploadedFile($this->fixture, 'background.mov', 'video/quicktime', null, true);

        $this->actingAs($this->admin())
            ->post('/admin/cms/onboarding', [
                'title' => 'Optimised video slide',
                'gradient_start' => '#3B8DFF',
                'gradient_end' => '#27F5A3',
                'video' => $video,
            ])
            ->assertRedirect(route('admin.cms.onboarding.index'));

        $slide = CmsOnboardingSlide::first();
        $this->assertNotNull($slide->video, 'video path should be stored');
        $this->assertStringEndsWith('.mp4', $slide->video, 'output must be an MP4');

        Storage::disk('public')->assertExists($slide->video);
        $this->assertGreaterThan(0, Storage::disk('public')->size($slide->video));

        // Fast-start: moov atom near the beginning.
        $fullPath = Storage::disk('public')->path($slide->video);
        $probe = shell_exec('ffprobe -v trace '.escapeshellarg($fullPath).' 2>&1');
        $pos = PHP_INT_MAX;
        if (preg_match("/type:'moov' parent:'root' sz: \d+ (\d+) /", $probe, $m)) {
            $pos = (int) $m[1];
        }
        $this->assertLessThan(1000, $pos, 'moov atom must be near the start for fast streaming');

        // Audio removed (muted background).
        $info = shell_exec(
            'ffprobe -v error -select_streams a -show_entries stream=codec_name '
            .'-of csv=p=0 '.escapeshellarg($fullPath).' 2>&1'
        );
        $this->assertSame('', trim((string) $info), 'background videos should have no audio track');
    }

    public function test_gif_upload_works(): void
    {
        Storage::fake('public');

        $gif = UploadedFile::fake()->create('anim.gif', 2000, 'image/gif');

        $this->actingAs($this->admin())
            ->post('/admin/cms/onboarding', [
                'title' => 'GIF slide',
                'gradient_start' => '#3B8DFF',
                'gradient_end' => '#27F5A3',
                'image' => $gif,
            ])
            ->assertRedirect(route('admin.cms.onboarding.index'));

        $slide = CmsOnboardingSlide::first();
        $this->assertNotNull($slide->image);
        Storage::disk('public')->assertExists($slide->image);
    }
}
