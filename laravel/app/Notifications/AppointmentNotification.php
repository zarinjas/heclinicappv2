<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AppointmentNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $title,
        private readonly string $body,
        private readonly array $appointmentData = [],
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

        if (!empty($this->appointmentData)) {
            $message->line('---');
            if (!empty($this->appointmentData['doctor_name'])) {
                $message->line('Doctor: ' . $this->appointmentData['doctor_name']);
            }
            if (!empty($this->appointmentData['branch_name'])) {
                $message->line('Clinic: ' . $this->appointmentData['branch_name']);
            }
            if (!empty($this->appointmentData['appointment_date'])) {
                $message->line('Date: ' . $this->appointmentData['appointment_date']);
            }
            if (!empty($this->appointmentData['appointment_time'])) {
                $message->line('Time: ' . $this->appointmentData['appointment_time']);
            }
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
            'appointment_data' => $this->appointmentData,
        ];
    }
}
