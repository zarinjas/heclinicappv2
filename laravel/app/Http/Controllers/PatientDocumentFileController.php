<?php

namespace App\Http\Controllers;

use App\Services\PatientDocumentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Serves patient documents behind a signed, expiring URL.
 *
 * Files previously used raw `Storage::url()` links on the public disk: valid
 * forever and readable by anyone who obtained the URL, with no authentication.
 * For medical records that is unacceptable, so downloads now go through a
 * signed route that Laravel validates before streaming the file.
 */
final class PatientDocumentFileController extends Controller
{
    public function __construct(private readonly PatientDocumentService $documents) {}

    public function __invoke(Request $request, int $document): StreamedResponse
    {
        // `signed` middleware already rejected tampered or expired links.
        $doc = $this->documents->findById($document);

        abort_if($doc === null, 404, 'Document not found.');

        $path = $this->documents->getFilePath($doc->patient_plato_uid, $doc->filename);
        $disk = Storage::disk('public');

        abort_unless($disk->exists($path), 404, 'File is no longer available.');

        // Inline so PDFs and images preview in-app instead of forcing a download.
        return $disk->response($path, $doc->original_name, [
            'Content-Type' => $doc->mime_type,
            'Content-Disposition' => 'inline; filename="'.addslashes($doc->original_name).'"',
            // Private: the URL is per-recipient and time-limited.
            'Cache-Control' => 'private, max-age=0, no-store',
        ]);
    }
}
