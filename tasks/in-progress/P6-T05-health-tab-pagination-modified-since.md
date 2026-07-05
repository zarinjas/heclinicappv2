# Pagination and Modified Since for Health Tab

## Header

| Field | Value |
|-------|-------|
| Task ID | P6-T05 |
| Slug | health-tab-pagination-modified-since |
| Process | 6 — Health Tab |
| Process Step | Step 5 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | NO |
| Depends On | P6-T04 |
| Blocked Reason | N/A |

---

## Description

Apply the existing pagination and modified_since strategies to all data-fetching operations in the Health Tab. The `PaginationHelper` (created in P3-T02) and `ModifiedSinceHelper` (created in P3-T03) already exist in the codebase and are actively used by `LetterCall` and `GetInvoiceCall`. This task upgrades `GetReportCall` and the new `GetVitalsGraphingCall` and `GetPatientDocumentsCall` to use the same paginated + incremental refresh pattern, then adds pull-to-refresh support across all three Health tab sub-tabs.

Per `docs/v2-decisions.md` Process 6 Step 5.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 6 Step 5 (line 90), Process 3 Step 2-4 (lines 57-60 for pagination/backoff/modified_since)
- `docs/CODEBASE.md` — Section 3: backend/api_requests/
- `lib/backend/api_requests/api_calls.dart` — LetterCall (line 1202) as reference implementation of PaginationHelper + ModifiedSinceHelper
- `lib/backend/api_requests/pagination_helper.dart` — existing pagination pattern
- `lib/backend/api_requests/modified_since_helper.dart` — existing modified_since pattern

---

## Scope

> Exact deliverables for this task.

### In Scope
- Upgrade `GetReportCall.call()` to use `PaginationHelper.fetchAllPages()` with `current_page` parameter and `ModifiedSinceHelper` for incremental fetch
- Upgrade the new `GetVitalsGraphingCall` to support `modified_since` parameter (Plato /graphing supports timestamp filtering)
- Upgrade `GetPatientDocumentsCall` to support pagination (if Laravel endpoint returns paginated results)
- Add `RefreshIndicator` (pull-to-refresh) to all three Health tab sub-tab list views
- Pull-to-refresh calls `forceRefresh: true` on the API calls (bypasses modified_since cache)
- Store last fetch timestamps per endpoint: `getReport`, `getVitals`, `getDocuments`
- Ensure stale data is still shown while new data loads (optimistic UI pattern) — skeleton loader during initial load only, not during refresh

### Out of Scope
- Modifying the Records, Vitals, or Documents tab content rendering
- Modifying the Health tab scaffold
- Adding pull-to-refresh outside the Health tab
- Changing PaginationHelper or ModifiedSinceHelper core logic

---

## Technical Spec

> Key implementation details.

### Files to Modify
- `lib/backend/api_requests/api_calls.dart` — Upgrade GetReportCall, add GetVitalsGraphingCall modified_since, upgrade GetPatientDocumentsCall
- `lib/front_page/reports/reports_widget.dart` — Wrap each tab list view in RefreshIndicator
- `lib/front_page/reports/reports_model.dart` — Add refresh state fields if needed

### Reference Implementation (from LetterCall)
```dart
static Future<ApiCallResponse> call({
  String? patientId = '',
  bool forceRefresh = false,
}) async {
  final int? modifiedSince = forceRefresh
      ? null
      : await ModifiedSinceHelper.getLastFetchTimestamp('letter');

  final response = await PaginationHelper.fetchAllPages((currentPage) {
    final params = <String, String>{
      'patient_id': patientId ?? '',
      'current_page': currentPage.toString(),
    };
    if (modifiedSince != null) {
      params['modified_since'] = modifiedSince.toString();
    }
    return ApiManager.instance.makeApiCall(/* ... */);
  });

  if (response.succeeded) {
    await ModifiedSinceHelper.setLastFetchTimestamp(
      'letter',
      ModifiedSinceHelper.now(),
    );
  }

  return response;
}
```

### GetReportCall Upgrade
- Change signature to accept `bool forceRefresh = false`
- Add pagination loop with `current_page` parameter
- Add `modified_since` parameter when `forceRefresh` is false
- Update last fetch timestamp on success
- Existing `note()`, `time()`, `kategori()`, `author()` field extractors must still work with paginated responses

### GetVitalsGraphingCall Upgrade
- Add `bool forceRefresh = false` parameter and `modified_since` support
- The /graphing endpoint returns a single response (not paginated typically), but should still pass modified_since for efficiency

### GetPatientDocumentsCall Upgrade
- Add `bool forceRefresh = false` and support pagination via Laravel (standard Laravel paginate with `?page=` param)
- Store modified_since timestamps per document endpoint

### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await reloadData(forceRefresh: true);
    setState(() {});
  },
  color: AppColors.accent,
  backgroundColor: AppColors.primary,
  child: ListView.builder(/* ... */),
)
```

### UI States
- Initial load: skeleton loaders (unchanged from P6-T02/P6-T03/P6-T04)
- Pull-to-refresh: RefreshIndicator spinner in accent color
- Stale-while-revalidate: show existing data while re-fetching in background (no skeleton on refresh)

### Constraints
- ModifiedSinceHelper keys: `'patient_note'`, `'vitals_graphing'`, `'patient_documents'`
- Do not break existing field extractors on GetReportCall
- Pull-to-refresh must not re-trigger skeleton loading on existing data

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria.

- [ ] `GetReportCall` uses PaginationHelper.fetchAllPages() with current_page loop
- [ ] `GetReportCall` passes modified_since parameter when not force-refreshing
- [ ] `GetVitalsGraphingCall` passes modified_since parameter when not force-refreshing
- [ ] Pull-to-refresh works on Records tab and re-fetches data with forceRefresh=true
- [ ] Pull-to-refresh works on Vitals tab
- [ ] Pull-to-refresh works on Documents tab
- [ ] Skeleton loaders only appear during initial fetch, not during pull-to-refresh
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
- [ ] GetReportCall pagination working — {PASS / FAIL} — {note}
- [ ] GetReportCall modified_since working — {PASS / FAIL} — {note}
- [ ] GetVitalsGraphingCall modified_since working — {PASS / FAIL} — {note}
- [ ] Pull-to-refresh on Records tab — {PASS / FAIL} — {note}
- [ ] Pull-to-refresh on Vitals tab — {PASS / FAIL} — {note}
- [ ] Pull-to-refresh on Documents tab — {PASS / FAIL} — {note}
- [ ] No skeleton on refresh — {PASS / FAIL} — {note}
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
