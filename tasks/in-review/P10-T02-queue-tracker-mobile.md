# Queue Tracker — Mobile App

## Header

| Field | Value |
|-------|-------|
| Task ID | T02 |
| Slug | queue-tracker-mobile |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 2 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-PROGRESS |
| Parallel | YES |
| Depends On | P1-T02 (Laravel proxy routes exist), P5-T09 (Appointments tab exists) |
| Blocked Reason | N/A |

---

## Description

Build a Queue Tracker screen in the Flutter mobile app that allows patients to view their current queue status. Fetches live queue data from Plato via `GET /queue/status` through the Laravel proxy. Displays queue position, estimated wait time, and current serving number. Accessible from the Appointments tab and as a standalone full-screen view.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 2
- `docs/v2-ux-spec.md` — Queue Tracker screen (if specified) or Health Tab patterns for data-driven screens
- `docs/CODEBASE.md` — FFAppState provider, GoRouter routes
- `docs/api-guidelines.md` — POST /invoice → queue flow, GET /queue/status

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- New Flutter screen `lib/pages/queue/queue_tracker_screen.dart`
- Queue data model `lib/pages/queue/queue_model.dart`
- API call method in `PlatomeApiGroup` or a new proxy service class for `GET /queue/status`
- Display: queue number, estimated wait time, current serving number, patient name
- Loading state with skeleton loader
- Empty state when no active queue
- Error state with retry option
- GoRouter route registration at `/queue`
- Entry point from Appointments tab (button or card linking to queue tracker)
- Pull-to-refresh for real-time updates

### Out of Scope
- Push notification for queue status changes — uses existing Notification system
- Admin-side queue management — Plato handles this
- Queue check-in or registration — Plato handles this
- Real-time WebSocket updates — polling via pull-to-refresh only

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `lib/pages/queue/queue_tracker_screen.dart` — NEW: main queue tracker screen
- `lib/pages/queue/queue_model.dart` — NEW: QueueStatus model with `fromJson()`
- `lib/backend/api/platome_api_group.dart` — MODIFY: add `getQueueStatus()` method
- `lib/main.dart` — MODIFY: add GoRouter route `/queue`
- `lib/pages/appointments/appointments_screen.dart` — MODIFY: add "Queue Tracker" entry card

### API Endpoints
- `GET /api/proxy/queue/status` — Laravel proxy → Plato `GET /queue/status`

### Data / Schema
Plato `/queue/status` response (from api-guidelines.md):
```json
{
  "queue_number": "A001",
  "patient_name": "John Doe",
  "status": "waiting",
  "estimated_wait": "15 min",
  "current_serving": "A001"
}
```

### UI Components
- `AppCard` with queue info
- `AppButton` for "Back to Appointments" navigation
- Skeleton loader (use existing `skeleton_loaders.dart`)
- Empty state widget (use existing `empty_state_widget.dart`)
- Error state widget (use existing `error_state_widget.dart`)
- Pull-to-refresh (`RefreshIndicator`)

### Constraints
- All Plato calls MUST route through Laravel proxy (`PlatomeApiGroup` → `EnvConfig` proxy URL)
- Must support both light and dark mode (`AppColors` tokens only)
- Must use `AppTextStyles`, `AppSpacing`, `AppRadius` constants
- Queue data is per-patient; proxy identifies patient via auth session

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] Queue tracker screen loads at route `/queue` with skeleton loader while fetching
- [ ] If patient has an active queue, displays queue number, estimated wait, current serving
- [ ] If patient has no active queue, displays empty state with message
- [ ] Pull-to-refresh updates queue data from the proxy
- [ ] Error state shows retry button that re-calls the API
- [ ] Appointments tab includes a visible entry point (button or card) to the queue tracker
- [ ] Screen supports both light and dark mode
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.

### What Was Done
Created Queue Tracker screen in Flutter. New screen displays queue number (hero card with gradient), estimated wait time, current serving number, and status. Includes skeleton loader, empty state (no active queue), error state with retry, and pull-to-refresh. Entry point added to Appointments screen app bar as an icon button. API call uses `GET /queue/status` via Laravel proxy (Plato).

### Files Changed
- `lib/backend/api_requests/api_calls.dart` — ADDED: `GetQueueStatusCall` class with call() and response field extractors
- `lib/pages/queue/queue_tracker_screen.dart` — NEW: full screen with skeleton/empty/error/data states
- `lib/pages/appointments/appointments_screen.dart` — MODIFIED: added Queue Tracker icon button in app bar actions
- `lib/index.dart` — MODIFIED: added QueueTrackerScreenWidget export
- `lib/flutter_flow/nav/nav.dart` — MODIFIED: added FFRoute for `/queue-tracker`

### Decisions Made During Implementation
- Queue hero card uses gradient: accent when currently serving, primary when waiting
- Entry point is an icon button in Appointments screen app bar (minimal disruption to existing UI)
- API call uses `EnvConfig.platomBaseUrl` which routes through Laravel proxy
- Pull-to-refresh uses standard `RefreshIndicator` with `AlwaysScrollableScrollPhysics`

### Known Limitations
- No real-time updates — polling via pull-to-refresh only
- No push notification for queue status changes
- Queue check-in/registration is handled by Plato, not this screen

---

## QA Notes

> Filled in by QA after verification.

### Result: PENDING

### Criteria Results
- [ ] Queue tracker loads with skeleton — PENDING
- [ ] Active queue displays info — PENDING
- [ ] No queue shows empty state — PENDING
- [ ] Pull-to-refresh works — PENDING
- [ ] Error state with retry — PENDING
- [ ] Entry point in Appointments tab — PENDING
- [ ] Light + dark mode — PENDING
- [ ] flutter analyze passes — PENDING

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
