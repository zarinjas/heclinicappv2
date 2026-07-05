# Upcoming Appointment Section

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P3-T04 |
| Slug | upcoming-appointment-section |
| Process | Epic: UI Migration — Phase 3 |
| Process Step | Step 3.4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | UI-P3-T01 (home screen shell) |
| Blocked Reason | N/A |

---

## Description

Implement the upcoming appointment section on the home screen using the `AppointmentCard` component (Phase 1). Fetch the patient's next upcoming appointment from `GET /appointment` via Laravel proxy. Show a compact `AppointmentCard` with status chip. If no upcoming appointments exist, show `AppEmptyState` with a "Book Now" CTA. Show `AppSkeleton` while loading.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/ui-design-system.md` — §2 (Colors), §10 (AppCard), §11 (AppChip), §15 (Skeleton), §16 (EmptyState)
- `docs/ui-migration-plan.md` — §Phase 3 Home Screen, line 118
- `docs/ui-epic.md` — Compliance Rule
- `docs/design-system-v2.png` — visual target
- `docs/v2-ux-spec.md` — Home screen appointment card
- `docs/CODEBASE.md` — existing appointment fetching code

---

## Scope

### In Scope
- Integrate `AppointmentCard` component into home screen upcoming appointment section
- Fetch upcoming appointments from `GET /appointment` (via Laravel proxy), filter to upcoming only
- Display the next upcoming appointment as a compact card
- Show `AppSkeleton` while loading
- Show `AppEmptyState` with "No upcoming appointments" + "Book Now" button when empty
- "See All" in `SectionHeader` navigates to appointments tab
- Status chip on card (Confirmed, Pending, etc.)

### Out of Scope
- AppointmentCard component itself (Phase 1 — UI-P1-T01)
- Appointments tab full implementation (Phase 5)
- Booking flow (Phase 4)
- Home screen shell (UI-P3-T01)

---

## Technical Spec

### Files to Modify
- `lib/features/home/home_screen.dart` — Add upcoming appointment section slot
- `lib/core/widgets/appointment_card.dart` — Use existing Phase 1 component

### API Endpoints
- `GET /appointment` — fetch patient appointments (via Laravel proxy)

### Data / Schema
- Appointment: `id`, `branch_name`, `doctor_name`, `appointment_date`, `appointment_time`, `status`

### UI Components
- `AppointmentCard` — Phase 1 reusable, compact variant
- `AppSkeleton` — shimmer while loading
- `AppEmptyState` — no appointments state with CTA
- `SectionHeader` — "Upcoming Appointment" + "See All"

### Constraints
- All styling must use design tokens
- Dark mode support
- Preserve existing API call and auth headers

---

## Acceptance Criteria

- [ ] Upcoming appointment card is displayed when the patient has a future appointment
- [ ] Card shows branch name, doctor name, date, time, and status chip
- [ ] `AppSkeleton` shimmer is displayed while appointment data is loading
- [ ] `AppEmptyState` with "Book Now" CTA is shown when no upcoming appointments exist
- [ ] "See All" tap navigates to appointments tab
- [ ] Book Now CTA navigates to booking flow
- [ ] `flutter analyze` passes with zero errors

---

## Implementation Notes

> Filled in by the Developer after implementation.
> Leave blank until implementation is complete.

### What Was Done


### Files Changed


### Decisions Made During Implementation


### Known Limitations


---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

### Result: PASSED / FAILED

### Criteria Results

### Failure Details


---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.

### Decision: APPROVED / REJECTED

### Alignment Check

### Rejection Reason

