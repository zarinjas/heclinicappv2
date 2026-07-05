<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class GeneralNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $title,
        private readonly string $body,
        private readonly ?string $imageUrl = null,
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $message = (new MailMessage)
            ->subject($this->title)
            ->greeting('Hello!')
            ->line($this->body);

        if ($this->imageUrl !== null && $this->imageUrl !== '' && $this->imageUrl !== '0') {
            $message->line('![Image](' . $this->imageUrl . ')');
        }

        return $message
            ->line('Thank you for choosing He Clinic.')
            ->salutation('Regards, He Clinic');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'title' => $this->title,
            'body' => $this->body,
            'image_url' => $this->imageUrl,
        ];
    }
}
