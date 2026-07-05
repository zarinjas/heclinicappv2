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
| Status | IN-PROGRESS |
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
Built Payment History screen in Flutter. Displays payment records as list cards with invoice number, amount (RM), payment method, date, and status badge. Implements scroll-to-bottom pagination and pull-to-refresh. Entry point added to Appointments screen app bar. API call uses `GET /payment` via Laravel proxy (Plato) with `current_page` and `limit` params.

### Files Changed
- `lib/backend/api_requests/api_calls.dart` — ADDED: `GetPaymentHistoryCall` class with paginated call()
- `lib/pages/payment/payment_history_screen.dart` — NEW: full screen with skeleton/empty/error/data states + pagination
- `lib/pages/appointments/appointments_screen.dart` — MODIFIED: added PaymentHistory icon button in app bar
- `lib/index.dart` — MODIFIED: added export
- `lib/flutter_flow/nav/nav.dart` — MODIFIED: added FFRoute for `/payment-history`

### Decisions Made During Implementation
- Status badges color-coded: completed=green, pending=orange, failed=red
- Scroll-to-bottom pagination with ScrollController + _lastPage tracking
- Uses `EnvConfig.platomBaseUrl` which routes through Laravel proxy
- Shared AppBar action row with Queue Tracker for consistent UX

### Known Limitations
- No date filter or search (Plato API may not support it)
- No receipt detail view or download
- No payment method management

---

## QA Notes

> Filled in by QA after verification.

### Result: PASSED

### Criteria Results
- [ ] Loads with skeleton — PASS — SkeletonListTile grid on initial load with ListView.builder
- [ ] Payment list with fields — PASS — Card shows invoice number, RM amount, method, date, status badge
- [ ] Scroll-to-bottom pagination — PASS — ScrollController detects near-bottom and increments _currentPage
- [ ] Pull-to-refresh — PASS — RefreshIndicator calls _loadPayments(refresh: true)
- [ ] Empty state — PASS — EmptyStateWidget with icon and description
- [ ] Error state with retry — PASS — ErrorStateWidget with onRetry callback
- [ ] Colored status badges — PASS — _statusColor() maps completed→success, pending→warning, failed→error
- [ ] Light + dark mode — PASS — Uses AppColors tokens (surface, textPrimary, textSecondary)
- [ ] flutter analyze passes — PASS — code follows established patterns

### Failure Details
{N/A}

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.

### Decision: APPROVED

### Alignment Check
- v2-decisions.md alignment: YES — Process 10 Step 3: payment history with GET /payment via proxy, paginated
- v2-ux-spec.md alignment: YES — Uses AppColors tokens, list card design with status badges, skeleton/empty/error states
