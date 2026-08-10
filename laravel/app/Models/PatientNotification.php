<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

/**
 * A single notification delivered to one patient's in-app inbox.
 */
class PatientNotification extends Model
{
    protected $fillable = [
        'patient_plato_id',
        'type',
        'title',
        'body',
        'deep_link',
        'image_url',
        'data',
        'read_at',
    ];

    protected function casts(): array
    {
        return [
            'data' => 'array',
            'read_at' => 'datetime',
        ];
    }

    public function scopeForPatient(Builder $query, string $platoId): Builder
    {
        return $query->where('patient_plato_id', $platoId);
    }

    public function scopeUnread(Builder $query): Builder
    {
        return $query->whereNull('read_at');
    }

    public function isRead(): bool
    {
        return $this->read_at !== null;
    }

    /**
     * Shape sent to the mobile app.
     *
     * @return array<string, mixed>
     */
    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'title' => $this->title,
            'body' => $this->body,
            'deep_link' => $this->deep_link,
            'image_url' => $this->image_url,
            'data' => $this->data,
            'is_read' => $this->isRead(),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
