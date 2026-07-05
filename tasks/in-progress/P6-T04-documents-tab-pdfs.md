# Documents Tab — Admin-Uploaded PDFs

## Header

| Field | Value |
|-------|-------|
| Task ID | P6-T04 |
| Slug | documents-tab-pdfs |
| Process | 6 — Health Tab |
| Process Step | Step 4 |
| Type | Flutter + Laravel |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P6-T03 |
| Blocked Reason | N/A |

---

## Description

Implement the Documents inner tab of the Health Tab scaffold. This tab displays admin-uploaded PDF documents from Firebase Storage fetched via a new Laravel API endpoint `GET /api/v2/patients/{id}/documents`. Each document is shown as a list item with a file icon, document name, upload date, and optional admin note. Tapping a document opens it in a PDF viewer (WebViewX+).

The Laravel backend needs a new API route and controller method to serve patient document metadata from Firebase Storage. The Flutter side consumes this endpoint and renders the document list with V2 design system styling.

Per `docs/v2-decisions.md` Process 6 Step 4 and `docs/v2-ux-spec.md` Documents Tab specification.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 6 Step 4 (line 89), Document Upload & Management section (line 325)
- `docs/v2-ux-spec.md` — Documents Tab section (line 590-595), Design System section (line 9)
- `docs/CODEBASE.md` — Firebase Storage integration
- `laravel/routes/api.php` — existing API route patterns
- `lib/backend/api_requests/api_calls.dart` — existing API call patterns

---

## Scope

> Exact deliverables for this task.

### In Scope
**Laravel:**
- Create a new route: `GET /api/v2/patients/{id}/documents` in `laravel/routes/api.php` (inside auth:sanctum group)
- Create a new controller method in a PatientDocumentsController (or add to PlatoProxyController) that:
  - Accepts patient ID from route
  - Lists documents from Firebase Storage at `patients/{patient_id}/documents/`
  - Returns JSON array with: name, url (signed download URL), uploaded_at, admin_note, size_bytes
  - Uses Firebase Admin SDK (already configured in the Laravel project)

**Flutter:**
- Create `GetPatientDocumentsCall` API call class in `lib/backend/api_requests/api_calls.dart`
- Implement Documents tab body in ReportsWidget
- Each document card: file icon (Icons.picture_as_pdf), document name, upload date formatted, admin note (if present)
- Sorted by upload date, newest first
- Tap to open PDF in WebViewX+ viewer (already used in existing codebase)
- Loading: 4× SkeletonListTile while fetching
- Empty state: `EmptyStateWidget` with icon `Icons.folder_outlined`, title "No documents yet", subtitle "Your health records will appear here"
- Error state: `ErrorStateWidget` with retry callback

### Out of Scope
- Admin Panel document upload UI (Process 7)
- Records tab or Vitals tab content
- Document deletion
- Pagination / modified_since (deferred to P6-T05)

---

## Technical Spec

> Key implementation details.

### Laravel — Files to Create or Modify
- `laravel/routes/api.php` — Add `Route::get('/v2/patients/{id}/documents', [PatientDocumentController::class, 'index'])` inside auth:sanctum group
- `laravel/app/Http/Controllers/Api/PatientDocumentController.php` — New controller with `index($id)` method
- Controller `index()` method logic:
  ```php
  public function index(string $patientId): JsonResponse
  {
      $bucket = app('firebase.storage')->getBucket();
      $prefix = "patients/{$patientId}/documents/";
      $objects = $bucket->objects(['prefix' => $prefix]);

      $documents = [];
      foreach ($objects as $object) {
          if ($object->name() === $prefix) continue; // skip directory marker
          $documents[] = [
              'name' => basename($object->name()),
              'url' => $object->signedUrl(now()->addMinutes(15)),
              'uploaded_at' => $object->info()['timeCreated'] ?? null,
              'size_bytes' => $object->info()['size'] ?? 0,
              'admin_note' => $object->info()['metadata']['admin_note'] ?? null,
          ];
      }

      usort($documents, fn($a, $b) => strtotime($b['uploaded_at'] ?? '') <=> strtotime($a['uploaded_at'] ?? ''));

      return response()->json(['documents' => $documents]);
  }
  ```

### Flutter — Files to Modify
- `lib/backend/api_requests/api_calls.dart` — Add `GetPatientDocumentsCall` class calling `GET ${EnvConfig.medicalAppsBaseUrl}/v2/patients/{id}/documents`
- `lib/front_page/reports/reports_widget.dart` — Implement Documents tab body
- `lib/front_page/reports/reports_model.dart` — Add model fields: documentsList, isLoadingDocuments, documentsError

### New Flutter API Call Class
```dart
class GetPatientDocumentsCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetPatientDocuments',
      apiUrl: '${EnvConfig.medicalAppsBaseUrl}/v2/patients/${patientId}/documents',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}
```

### UI Components
- Document card: `Card` with V2 styling, leading: 40px red-tinted circle with `Icons.picture_as_pdf` in white, title: document name (GoogleFonts.plusJakartaSans 14px weight 600), subtitle: "Uploaded {date}" and admin note if present (12px, AppColors.textSecondary)
- Tapping card: navigate to PDF viewer. Use existing `WebViewX+` approach from existing ReportsWidget or open via `url_launcher`
- Sort: newest first (sorted by backend in Laravel)

### UI States
- Loading: 4× `SkeletonListTile`
- Empty: `EmptyStateWidget(icon: Icons.folder_outlined, title: 'No documents yet', subtitle: 'Your health records will appear here')`
- Error: `ErrorStateWidget` with retry

### Constraints
- Documents endpoint must be behind auth:sanctum middleware in Laravel
- PDF URLs should be signed (temporary) for security
- Use `EnvConfig.medicalAppsBaseUrl` for the Laravel Medical Apps API (not the Plato proxy)
- All text uses GoogleFonts.plusJakartaSans

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] Laravel `GET /api/v2/patients/{id}/documents` route returns JSON array of patient documents from Firebase Storage
- [ ] Documents tab fetches and displays document list with file icon, name, date, and admin note
- [ ] Documents are sorted newest first
- [ ] Skeleton loaders display while fetching (4 items)
- [ ] Empty state displays when no documents exist
- [ ] Error state displays with retry button on fetch failure
- [ ] Tapping a document opens the PDF in a viewer (WebViewX+ or url_launcher)
- [ ] Laravel PHP syntax check passes: `php -l app/Http/Controllers/Api/PatientDocumentController.php`
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled by Developer after implementation.

### What Was Done
{to be filled}

### Files Changed
{to be filled}

### Decisions Made During Implementation
{to be filled}

### Known Limitations
{to be filled}

---

## QA Notes

> Filled by QA after verification.

### Result: {PASSED / FAILED}

### Criteria Results
- [ ] Laravel endpoint returns documents JSON — {PASS / FAIL} — {note}
- [ ] Documents tab displays list with correct fields — {PASS / FAIL} — {note}
- [ ] Documents sorted newest first — {PASS / FAIL} — {note}
- [ ] Skeleton loaders appear while loading — {PASS / FAIL} — {note}
- [ ] Empty state when no documents — {PASS / FAIL} — {note}
- [ ] Error state with retry works — {PASS / FAIL} — {note}
- [ ] PDF viewer opens on tap — {PASS / FAIL} — {note}
- [ ] Laravel syntax check passes — {PASS / FAIL} — {note}
- [ ] flutter analyze zero errors — {PASS / FAIL} — {note}

### Failure Details
{to be filled if failed}

---

## Reviewer Notes

> Filled by Reviewer after QA passes.

### Decision: {APPROVED / REJECTED}

### Alignment Check
- v2-decisions.md alignment: {YES / NO} — {note}
- v2-ux-spec.md alignment: {YES / NO} — {note}

### Rejection Reason
{to be filled if rejected}
