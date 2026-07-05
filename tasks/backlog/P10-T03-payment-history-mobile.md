# Payment History — Mobile App

## Header

| Field | Value |
|-------|-------|
| Task ID | T03 |
| Slug | payment-history-mobile |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 3 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | P1-T02 (Laravel proxy routes exist), P4-T02 (bottom nav exists) |
| Blocked Reason | N/A |

---

## Description

Build a Payment History screen in the Flutter mobile app that displays a patient's past payment transactions. Fetches data from Plato via `GET /payment` through the Laravel proxy. Shows transaction date, amount, payment method, invoice number, and status. Supports pagination and pull-to-refresh. Accessible from the Appointments tab or Profile section.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 3
- `docs/v2-ux-spec.md` — List screen patterns (use existing Appointments tab as reference)
- `docs/CODEBASE.md` — FFAppState, pagination helper from Process 3
- `docs/api-guidelines.md` — GET /payment endpoint

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- New Flutter screen `lib/pages/payment/payment_history_screen.dart`
- Payment data model `lib/pages/payment/payment_model.dart`
- API call method in `PlatomeApiGroup` for `GET /payment` with pagination
- List view with payment rows: date, amount (RM), payment method, invoice number, status badge
- Pagination via `current_page` parameter (reuse `pagination_helper.dart` from P3-T02)
- Loading state with skeleton list
- Empty state when no payment history
- Error state with retry
- GoRouter route `/payment-history`
- Entry point from Profile section or Appointments tab

### Out of Scope
- Payment creation or invoices — Plato handles this
- Payment receipt download or sharing
- Payment method management
- Refund view

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `lib/pages/payment/payment_history_screen.dart` — NEW: payment list screen
- `lib/pages/payment/payment_model.dart` — NEW: Payment model with `fromJson()`
- `lib/backend/api/platome_api_group.dart` — MODIFY: add `getPaymentHistory()` with pagination
- `lib/main.dart` — MODIFY: add GoRouter route `/payment-history`
- `lib/pages/profile/` or `lib/pages/appointments/appointments_screen.dart` — MODIFY: add entry link

### API Endpoints
- `GET /api/proxy/payment` — Laravel proxy → Plato `GET /payment` (params: `current_page`, `limit`)

### Data / Schema
Plato `/payment` response (paginated):
```json
{
  "data": [
    {
      "id": 123,
      "invoice_number": "INV-2026-0001",
      "amount": "150.00",
      "payment_method": "credit_card",
      "status": "completed",
      "created_at": "2026-07-05 10:30:00"
    }
  ],
  "current_page": 1,
  "last_page": 5
}
```

### UI Components
- `AppCard` for each payment row
- Status badge (colored chip: green for completed, orange for pending, red for failed)
- `AppTextStyles.body` for amount/date
- Skeleton loader (use existing `skeleton_loaders.dart`)
- Empty state widget (use existing `empty_state_widget.dart`)
- Error state widget (use existing `error_state_widget.dart`)
- `ListView.builder` with scroll-to-load-more for pagination
- `RefreshIndicator` for pull-to-refresh

### Constraints
- All Plato calls MUST route through Laravel proxy
- Must use `modified_since` strategy for freshness (P3-T03)
- Pagination max 20 per page (api-guidelines.md limit)
- Must support both light and dark mode
- Use `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius` tokens only

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Payment history screen loads at `/payment-history` with skeleton list
- [ ] If payment history exists, displays list with date, amount (RM), method, invoice, status badge
- [ ] Scroll-to-bottom loads next page of payments (pagination)
- [ ] Pull-to-refresh reloads from page 1
- [ ] Empty state displays when no payment history exists
- [ ] Error state with retry button on API failure
- [ ] Status badges are color-coded (completed=green, pending=orange, failed=red)
- [ ] Screen supports both light and dark mode
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
{To be filled}

### Files Changed
{To be filled}

### Decisions Made During Implementation
{To be filled}

### Known Limitations
{To be filled}

---

## QA Notes

> Filled in by QA after verification.

### Result: PENDING

### Criteria Results
- [ ] Loads with skeleton — PENDING
- [ ] Payment list with fields — PENDING
- [ ] Scroll-to-bottom pagination — PENDING
- [ ] Pull-to-refresh — PENDING
- [ ] Empty state — PENDING
- [ ] Error state with retry — PENDING
- [ ] Colored status badges — PENDING
- [ ] Light + dark mode — PENDING
- [ ] flutter analyze — PENDING

### Failure Details
{N/A}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: PENDING

### Alignment Check
- v2-decisions.md alignment: PENDING
- v2-ux-spec.md alignment: PENDING

### Rejection Reason
{N/A}
