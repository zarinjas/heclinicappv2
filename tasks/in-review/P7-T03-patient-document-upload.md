# Patient Document Upload — PDF to Firebase Storage

## Header

| Field | Value |
|-------|-------|
| Task ID | P7-T03 |
| Slug | patient-document-upload |
| Process | 7 — Admin Panel: Patient and Appointment Management |
| Process Step | Step 3 |
| Type | Laravel |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | NO |
| Depends On | P7-T02 |
| Blocked Reason | N/A |

---

## Description

Add a document upload section to the patient profile page in the Laravel Admin Panel. Admins can upload PDF documents (medical reports, lab results, MCs) which are stored in Firebase Storage under the patient's ID path. The uploaded document is linked to the patient's Plato UID so the mobile app can display it in the Documents tab of the Health section.

Per `docs/v2-decisions.md` Process 7 Step 3.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 7 Step 3 (line 96)
- `docs/v2-ux-spec.md` — Health Tab Documents section (lines 310-330)
- `laravel/app/Services/FirebaseStorageService.php` — existing Firebase Storage list/download logic
- `laravel/app/Http/Controllers/Api/PatientDocumentController.php` — existing API endpoint `GET /api/v2/patients/{id}/documents`
- `laravel/config/firebase.php` — Firebase project config
- `laravel/app/Http/Controllers/Admin/BranchController.php` — reference file upload pattern (store/store method)

---

## Scope

> Exact deliverables for this task.

### In Scope
- Create a `PatientDocumentService` that handles uploading PDFs to Firebase Storage
- Storage path: `patients/{patient_plato_uid}/documents/{filename}.pdf`
- File validation: PDF only, max 10MB
- Add a file upload form section to the patient profile Blade view (`show.blade.php`)
- Upload form: file input (PDF only), optional title/description field, "Upload" button
- After upload: save document metadata to Firestore `patients/{uid}/documents` subcollection (or a local `patient_documents` MySQL table)
- List uploaded documents on the profile page with download link (via Firebase Storage signed URL)
- Add delete button for each document (admin can remove uploaded documents)
- **If Firebase SDK not available** for upload: store files in Laravel's `storage/app/public/patients/{uid}/` and serve via a local proxy route

### Out of Scope
- Mobile app changes (the existing `GetPatientDocumentsCall` already works with Firebase Storage)
- Bulk document upload
- Document preview/thumbnail generation
- Integration with Plato (documents are admin-side only, not synced to Plato)

---

## Technical Spec

> Key implementation details.

### Files to Create or Modify
- `laravel/app/Services/PatientDocumentService.php` — new service for upload/delete/list
- `laravel/app/Http/Controllers/Admin/PatientController.php` — add `uploadDocument()`, `deleteDocument()` methods, and modify `show()` to list documents
- `laravel/resources/views/admin/patients/show.blade.php` — add document upload section and document list
- `laravel/routes/web.php` — add POST/DELETE routes for documents (as nested resource or explicit routes)

### Fallback Strategy (if Firebase upload not available)
If `kreait/laravel-firebase` is not installed and Firebase Admin SDK cannot do direct file uploads:
1. Store files in `storage/app/public/patients/{uid}/` using Laravel's `Storage::disk('public')`
2. Create a route `GET /admin/patients/{id}/documents/{filename}` that serves the file
3. Store document metadata in a new `patient_documents` MySQL table:
   - `id`, `patient_plato_uid`, `filename`, `original_name`, `title`, `mime_type`, `size_bytes`, `uploaded_by` (user_id FK), `created_at`, `updated_at`

### PatientDocumentService Interface
```php
class PatientDocumentService
{
    public function upload(string $patientUid, UploadedFile $file, ?string $title, int $userId): array;
    public function list(string $patientUid): array;
    public function delete(string $patientUid, string $filename): bool;
    public function getUrl(string $patientUid, string $filename): string;
}
```

### API Endpoints
- `GET /api/v2/patients/{id}/documents` — existing (used by mobile app for document listing)
- New web routes (under `auth` + `role` middleware):
  - `POST /admin/patients/{id}/documents` — upload document
  - `DELETE /admin/patients/{id}/documents/{filename}` — delete document

### Blade View Section (within `show.blade.php`)
- "Documents" card section below patient details
- Upload form: file input with `accept=".pdf"`, title text input, submit button
- Document list table: title, filename, uploaded date, file size, actions (Download, Delete)
- Empty state: "No documents uploaded yet"
- Delete confirmation: JavaScript `confirm()` dialog

### Constraints
- PDF files only (validate MIME type: `application/pdf`)
- Max file size: 10MB
- Patient UID is the patient's `id` from Plato (UUID)
- All admin routes protected by `auth` + `role` middleware

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Document upload form appears on the patient profile page
- [ ] Uploading a PDF file works and stores the document
- [ ] The document appears in the document list on the profile page after upload
- [ ] Non-PDF files are rejected with a validation error message
- [ ] Files over 10MB are rejected with a validation error message
- [ ] Delete button removes the document and it disappears from the list
- [ ] Download link on each document works and serves the file
- [ ] `php -l` passes syntax check on all new/modified PHP files
- [ ] Storage path includes the patient's Plato UID (e.g., `patients/{uuid}/documents/`)

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done
- Created `database/migrations/2026_07_05_000011_create_patient_documents_table.php` — MySQL table for document metadata (`patient_plato_uid`, `filename`, `original_name`, `title`, `mime_type`, `size_bytes`, `uploaded_by` FK, timestamps; unique index on `patient_plato_uid` + `filename`)
- Created `app/Services/PatientDocumentService.php` — handles upload/delete/list/serve using Laravel Storage (public disk) and DB facade. Files stored at `patients/{uid}/documents/{uuid}.pdf`
- Modified `app/Http/Controllers/Admin/PatientController.php` — added `uploadDocument()` (validates PDF only, max 10MB, optional title), `deleteDocument()` (removes file + DB record), updated `show()` to pass `$documents` list to view
- Modified `resources/views/admin/patients/show.blade.php` — added Documents section below patient info card: upload form (file input accept=.pdf, title input, Upload button), document list table (title, filename, size in KB, upload date, Download/Delete actions), empty state, delete confirmation via `confirm()`
- Modified `routes/web.php` — added `POST /admin/patients/{patient}/documents` and `DELETE /admin/patients/{patient}/documents/{filename}` under auth+role middleware
- Used fallback strategy (local storage) because `kreait/laravel-firebase` is not installed

### Files Changed
- `database/migrations/2026_07_05_000011_create_patient_documents_table.php` (new)
- `app/Services/PatientDocumentService.php` (new)
- `app/Http/Controllers/Admin/PatientController.php` (modified)
- `resources/views/admin/patients/show.blade.php` (modified)
- `routes/web.php` (modified)

### Decisions Made During Implementation
- Used Laravel Storage public disk (local) instead of Firebase Storage because kreait/laravel-firebase SDK is not available in composer.json
- Uploaded PDFs renamed to UUID for uniqueness and security
- Used DB facade directly in service for simplicity (no Eloquent model needed for this scope)
- Document route naming convention: `admin.patients.documents.upload` and `admin.patients.documents.delete`

### Known Limitations
- Storage symlink (`php artisan storage:link`) must be created for download links to work
- No Firebase Storage integration (fallback only) — mobile app's existing `GetPatientDocumentsCall` fetches from Firebase Storage, so admin-uploaded documents won't appear in mobile app until Firebase upload is implemented
- Migration needs to be run (`php artisan migrate`) to create the `patient_documents` table


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results
- [ ] {Criterion 1} — PASS / FAIL — {note if fail}
- [ ] {Criterion 2} — PASS / FAIL — {note if fail}
- [ ] {Criterion 3} — PASS / FAIL — {note if fail}
- [ ] {Criterion 4} — PASS / FAIL — {note if fail}
- [ ] {Criterion 5} — PASS / FAIL — {note if fail}
- [ ] {Criterion 6} — PASS / FAIL — {note if fail}
- [ ] {Criterion 7} — PASS / FAIL — {note if fail}
- [ ] {Criterion 8} — PASS / FAIL — {note if fail}
- [ ] {Criterion 9} — PASS / FAIL — {note if fail}

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check
- v2-decisions.md alignment: YES / NO — {note if deviation found}
- v2-ux-spec.md alignment: YES / NO — {note if deviation found}

### Rejection Reason
N/A
