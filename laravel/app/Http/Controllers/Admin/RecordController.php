<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Services\PatientDocumentService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class RecordController extends Controller
{
    public function __construct(private readonly PatientDocumentService $documents) {}

    public function index(Request $request): View
    {
        $query = DB::table('patient_documents')
            ->leftJoin('branches', 'branches.id', '=', 'patient_documents.branch_id')
            ->select('patient_documents.*', 'branches.name as branch_name');

        if ($request->filled('source') && in_array($request->input('source'), ['admin', 'patient'], true)) {
            $query->where('source', $request->input('source'));
        }

        if ($request->filled('search')) {
            $search = $request->string('search')->trim();
            $query->where(function ($q) use ($search) {
                $q->where('patient_name', 'like', "%{$search}%")
                    ->orWhere('patient_nric', 'like', "%{$search}%")
                    ->orWhere('original_name', 'like', "%{$search}%");
            });
        }

        $records = $query
            ->orderBy('created_at', 'desc')
            ->paginate(20)
            ->withQueryString();

        $records->getCollection()->transform(function ($record) {
            $record->url = $this->documents->getUrl($record->patient_plato_uid, $record->filename);
            $record->size_kb = round($record->size_bytes / 1024, 1);

            return $record;
        });

        $defaultEmail = (string) Setting::where('key', 'document_upload_admin_email')->value('value');

        return view('admin.records.index', compact('records', 'defaultEmail'));
    }

    public function destroy(Request $request, int $record): RedirectResponse
    {
        $this->documents->deleteById($record);

        return redirect()
            ->route('admin.records.index')
            ->with('success', 'Record deleted successfully.');
    }

    public function updateDefaultEmail(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'document_upload_admin_email' => ['nullable', 'email', 'max:191'],
        ]);

        Setting::updateOrCreate(
            ['key' => 'document_upload_admin_email'],
            ['value' => $validated['document_upload_admin_email'] ?? '', 'description' => 'Default email that receives patient document upload notifications']
        );

        return redirect()
            ->route('admin.records.index')
            ->with('success', 'Default notification email updated successfully.');
    }
}
