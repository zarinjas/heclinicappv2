<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

final class PatientDocumentService
{
    public function upload(string $patientUid, UploadedFile $file, ?string $title, int $userId): array
    {
        $originalName = $file->getClientOriginalName();
        $storedName = Str::uuid().'.pdf';
        $sizeBytes = $file->getSize();

        $disk = Storage::disk('public');
        $path = sprintf('patients/%s/documents', $patientUid);
        $disk->putFileAs($path, $file, $storedName);

        $id = DB::table('patient_documents')->insertGetId([
            'patient_plato_uid' => $patientUid,
            'filename' => $storedName,
            'original_name' => $originalName,
            'title' => $title,
            'mime_type' => 'application/pdf',
            'size_bytes' => $sizeBytes,
            'uploaded_by' => $userId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return [
            'id' => $id,
            'patient_plato_uid' => $patientUid,
            'filename' => $storedName,
            'original_name' => $originalName,
            'title' => $title,
            'mime_type' => 'application/pdf',
            'size_bytes' => $sizeBytes,
            'url' => $this->getUrl($patientUid, $storedName),
            'created_at' => now()->toISOString(),
        ];
    }

    public function list(string $patientUid): array
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
    {
        $disk = Storage::disk('public');
        $path = sprintf('patients/%s/documents/%s', $patientUid, $filename);

        if ($disk->exists($path)) {
            $disk->delete($path);
        }

        return DB::table('patient_documents')
            ->where('patient_plato_uid', $patientUid)
            ->where('filename', $filename)
            ->delete() > 0;
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
}
