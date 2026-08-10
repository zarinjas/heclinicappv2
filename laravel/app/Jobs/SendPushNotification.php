<?php

namespace App\Jobs;

use App\Models\NotificationLog;
use App\Models\Patient;
use App\Services\FcmService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * Delivers one batch of push notifications in the background.
 *
 * FCM HTTP v1 has no true multicast endpoint, so a broadcast to N devices is N
 * HTTP requests. Doing that inline would hold an admin request open for minutes
 * on a large audience, so sends are chunked into jobs instead.
 */
class SendPushNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /** Devices handled per job. Keeps any single job well under the timeout. */
    public const CHUNK_SIZE = 100;

    public int $tries = 3;

    public int $timeout = 120;

    /**
     * @param  array<int, string>  $tokens
     * @param  array<string, string>  $data
     */
    public function __construct(
        private readonly array $tokens,
        private readonly string $title,
        private readonly string $body,
        private readonly array $data = [],
        private readonly ?string $imageUrl = null,
        private readonly ?int $notificationLogId = null,
    ) {}

    /** Exponential-ish backoff between retries. */
    public function backoff(): array
    {
        return [10, 30, 60];
    }

    public function handle(FcmService $fcm): void
    {
        $result = $fcm->sendToTokens($this->tokens, $this->title, $this->body, $this->data, $this->imageUrl);

        // Clear tokens FCM reported as permanently dead.
        if (! empty($result['invalid_tokens'])) {
            Patient::whereIn('fcm_token', $result['invalid_tokens'])->update(['fcm_token' => null]);
        }

        $this->recordOutcome(
            (int) ($result['success'] ?? 0),
            (int) ($result['failure'] ?? 0),
        );
    }

    public function failed(\Throwable $e): void
    {
        Log::channel('plato')->error('Push notification job failed', [
            'notification_log_id' => $this->notificationLogId,
            'devices' => count($this->tokens),
            'error' => $e->getMessage(),
        ]);

        $this->recordOutcome(0, count($this->tokens));
    }

    /**
     * Fold this batch's outcome into the notification log so the admin UI
     * reflects real delivery rather than a blanket "sent".
     */
    private function recordOutcome(int $success, int $failure): void
    {
        if ($this->notificationLogId === null) {
            return;
        }

        $log = NotificationLog::find($this->notificationLogId);

        if ($log === null) {
            return;
        }

        $delivered = (int) ($log->delivered_count ?? 0) + $success;
        $failed = (int) ($log->failed_count ?? 0) + $failure;

        $log->update([
            'delivered_count' => $delivered,
            'failed_count' => $failed,
            'status' => $delivered > 0 ? ($failed > 0 ? 'partial' : 'sent') : 'failed',
            'sent_at' => $log->sent_at ?? now(),
        ]);
    }
}
