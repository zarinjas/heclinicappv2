<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

final class PatientDocumentService
{
    public const ALLOWED_MIMES = [
        'application/pdf',
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
    ];

    public function upload(string $patientUid, UploadedFile $file, ?string $title, ?int $userId, array $patientInfo = [], ?int $branchId = null, string $source = 'admin', ?string $emailSentTo = null): array
    {
        $mimeType = $this->normalizeMime($file);
        $extension = $this->extensionFor($mimeType, $file->getClientOriginalExtension());
        $storedName = Str::uuid().'.'.$extension;
        $sizeBytes = $file->getSize();
        $originalName = $file->getClientOriginalName();

        $disk = Storage::disk('public');
        $path = sprintf('patients/%s/documents', $patientUid);
        $disk->putFileAs($path, $file, $storedName);

        $id = DB::table('patient_documents')->insertGetId([
            'patient_plato_uid' => $patientUid,
            'filename' => $storedName,
            'original_name' => $originalName,
            'title' => $title,
            'mime_type' => $mimeType,
            'size_bytes' => $sizeBytes,
            'uploaded_by' => $userId,
            'branch_id' => $branchId,
            'patient_name' => $patientInfo['name'] ?? null,
            'patient_nric' => $patientInfo['nric'] ?? null,
            'patient_phone' => $patientInfo['phone'] ?? null,
            'email_sent_to' => $emailSentTo,
            'source' => $source,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return [
            'id' => $id,
            'patient_plato_uid' => $patientUid,
            'filename' => $storedName,
            'original_name' => $originalName,
            'title' => $title,
            'mime_type' => $mimeType,
            'size_bytes' => $sizeBytes,
            'patient_name' => $patientInfo['name'] ?? null,
            'patient_nric' => $patientInfo['nric'] ?? null,
            'patient_phone' => $patientInfo['phone'] ?? null,
            'branch_id' => $branchId,
            'url' => $this->getUrl($patientUid, $storedName),
            'source' => $source,
            'created_at' => now()->toISOString(),
        ];
    }

    public function list(string $patientUid, ?int $modifiedSince = null): array
    {
        $query = DB::table('patient_documents')
            ->where('patient_plato_uid', $patientUid);

        if ($modifiedSince !== null) {
            $query->where('created_at', '>', Carbon::createFromTimestamp($modifiedSince));
        }

        return $query
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn ($doc) => $this->format($doc))
            ->values()
            ->toArray();
    }

    public function listForAdmin(string $patientUid): array
    {
        return DB::table('patient_documents')
            ->where('patient_plato_uid', $patientUid)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($doc) {
                $doc->url = $this->getUrl($doc->patient_plato_uid, $doc->filename);
                $doc->size_kb = round($doc->size_bytes / 1024, 1);

                return $doc;
            })
            ->toArray();
    }

    public function delete(string $patientUid, string $filename): bool
    {        $disk = Storage::disk('public');
        $path = sprintf('patients/%s/documents/%s', $patientUid, $filename);

        if ($disk->exists($path)) {
            $disk->delete($path);
        }

        return DB::table('patient_documents')
            ->where('patient_plato_uid', $patientUid)
            ->where('filename', $filename)
            ->delete() > 0;
    }

    public function deleteById(int $id): bool
    {
        $doc = DB::table('patient_documents')->where('id', $id)->first();

        if ($doc === null) {
            return false;
        }

        $disk = Storage::disk('public');
        $path = sprintf('patients/%s/documents/%s', $doc->patient_plato_uid, $doc->filename);

        if ($disk->exists($path)) {
            $disk->delete($path);
        }

        return DB::table('patient_documents')->where('id', $id)->delete() > 0;
    }

    public function findById(int $id): ?object
    {
        return DB::table('patient_documents')->where('id', $id)->first();
    }

    public function getUrl(string $patientUid, string $filename): string
    {
        $path = sprintf('patients/%s/documents/%s', $patientUid, $filename);

        return Storage::disk('public')->url($path);
    }

    public function getFilePath(string $patientUid, string $filename): string
    {
        return sprintf('patients/%s/documents/%s', $patientUid, $filename);
    }

    private function format(object $doc): array
    {
        return [
            'id' => $doc->id,
            'name' => $doc->original_name,
            'url' => $this->getUrl($doc->patient_plato_uid, $doc->filename),
            'uploaded_at' => Carbon::parse($doc->created_at)->toISOString(),
            'admin_note' => $doc->title,
            'size_bytes' => (int) $doc->size_bytes,
            'mime_type' => $doc->mime_type,
            'source' => $doc->source,
        ];
    }

    private function normalizeMime(UploadedFile $file): string
    {
        $sniffed = $file->getMimeType();
        $client = $file->getClientMimeType();

        $mime = in_array($sniffed, self::ALLOWED_MIMES, true)
            ? $sniffed
            : $client;

        if (! in_array($mime, self::ALLOWED_MIMES, true)) {
            $mime = 'application/octet-stream';
        }

        return $mime;
    }

    private function extensionFor(string $mimeType, string $fallback): string
    {
        return match ($mimeType) {
            'application/pdf' => 'pdf',
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/gif' => 'gif',
            'image/webp' => 'webp',
            default => strtolower($fallback) !== '' ? strtolower($fallback) : 'bin',
        };
    }
}
