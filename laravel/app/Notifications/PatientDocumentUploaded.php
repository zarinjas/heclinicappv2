<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PatientDocumentUploaded extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $patientName,
        private readonly string $patientNric,
        private readonly string $branchName,
        private readonly string $platoId,
        private readonly string $fileUrl,
        private readonly string $fileName,
        private readonly string $fileTitle,
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('New Document Uploaded by Patient')
            ->greeting('Hello,')
            ->line('A patient has uploaded a new document to their records.')
            ->line('**Patient Name:** '.$this->patientName)
            ->line('**NRIC:** '.$this->patientNric)
            ->line('**Branch:** '.$this->branchName)
            ->line('**Plato ID:** '.$this->platoId)
            ->line('**File:** '.$this->fileName)
            ->line('**Title:** '.$this->fileTitle)
            ->action('View File', $this->fileUrl)
            ->line('Open the link above to view the file — no login required.')
            ->salutation('Regards, He Clinic');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'patient_name' => $this->patientName,
            'patient_nric' => $this->patientNric,
            'branch_name' => $this->branchName,
            'plato_id' => $this->platoId,
            'file_url' => $this->fileUrl,
            'file_name' => $this->fileName,
            'file_title' => $this->fileTitle,
        ];
    }
}
