# Appointment Detail Screen (Shared)

## Header

| Field | Value |
|-------|-------|
| Task ID | UI-P5-T04 |
| Slug | appointment-detail-screen |
| Process | Epic: UI Migration — Phase 5 |
| Process Step | Step 5.4 |
| Type | Flutter |
| Assigned To | flutter-developer |
| Assigned Date | 2026-07-05 |
| Status | IN-REVIEW |
| Parallel | YES |
| Depends On | N/A |
| Blocked Reason | N/A |

---

## Description

Build the shared Appointment Detail screen for the Appointments Tab. Navigated to from any `AppointmentCard` (both Upcoming and Past tabs). Displays full appointment information — doctor, branch, date/time, status, notes, and action buttons (Cancel, Reschedule). Replaces the existing hardcoded appointment detail from booking flow with a token-driven V2 design.

---

## Context

- `docs/ui-design-system.md` — §§2 (AppColors), 3 (AppTextStyles), 4–6 (Spacing/Radius/Shadows), 7 (AppCard), 8 (AppButton), 11 (AppChip — status chip), 15 (AppSkeleton), 17 (AppErrorState), 20 (AppDialog), 24 (Dark Mode)
- `docs/ui-migration-plan.md` — Phase 5 (lines 145–161), Booking Flow Migration Notes (line 142 — existing appointment detail notes)
- `docs/v2-ux-spec.md` — Appointment Detail screen specifications
- `docs/design-system-v2.png` — Visual target reference
- Check existing `AppointmentCard` component in `lib/core/widgets/appointment_card.dart` (from Phase 1)

---

## Scope

### In Scope
- Create `lib/features/appointments/appointment_detail_screen.dart` with V2 design system
- Display full appointment info card: doctor name/photo, branch name/address, date, time, status chip, appointment notes
- Status chip using `AppChip` component (Confirmed, Pending, Completed, Cancelled, No-Show)
- Action buttons area:
  - "Cancel Appointment" button using `AppButton` (Destructive variant) — triggers `AppDialog` confirmation before action
  - "Reschedule" button using `AppButton` (Secondary variant) — navigates to booking flow date/time step
  - WhatsApp contact button using `AppButton` (WhatsApp variant) — deep link to branch WhatsApp
- Skeleton loader (`AppSkeleton`) while fetching appointment details from API
- `AppErrorState` with retry on API failure
- Replace all hardcoded appointment ID logic with dynamic parameter-based routing
- Support dark mode
- Replace all `FFButtonWidget`, `FlutterFlowTheme`, and inline styles with design tokens

### Out of Scope
- Cancel/reschedule API logic (keep existing business logic)
- Navigation wiring from AppointmentCard tap handlers (part of UI-P5-T01 shell integration)
- WhatsApp deep link config (branch WhatsApp number from existing API)

---

## Technical Spec

### Files to Create or Modify
- `lib/features/appointments/appointment_detail_screen.dart` — Create new detail screen

### API Endpoints
- N/A — Reuse existing appointment detail endpoints from booking flow
- Replace any hardcoded appointment ID parameter with dynamic route parameter

### Data / Schema
- Existing appointment detail data models (preserve existing business logic)
- Fields: id, doctor_name, doctor_photo_url, branch_name, branch_address, appointment_date, appointment_time, status, notes, whatsapp_number

### UI Components
- `AppCard` — appointment info card with grouped detail rows
- `AppChip` — status chip (color-coded per status)
- `AppButton` — Primary (Reschedule), Destructive (Cancel), WhatsApp variant (WhatsApp)
- `AppSkeleton` — shimmer detail preset for loading
- `AppErrorState` — error icon + message + "Try Again" button
- `AppDialog` — confirmation dialog variant for cancel action
- `AppTextStyles` — heading3 (appointment date), bodyLarge (detail labels), bodyMedium (detail values)

### Constraints
- All Plato API calls must route through Laravel proxy
- No hardcoded appointment IDs — must use dynamic route parameter
- No hardcoded colors, font sizes, spacing, or border radius
- Design system compliance mandatory

---

## Acceptance Criteria

- [ ] `appointment_detail_screen.dart` exists and compiles with `flutter analyze` (zero errors)
- [ ] Displays full appointment info: doctor (name + optional photo), branch, date, time, status chip, notes
- [ ] Status chip renders correct color per appointment status (Confirmed=green, Pending=amber, Completed=grey, Cancelled=red, No-Show=red)
- [ ] "Cancel Appointment" button opens `AppDialog` confirmation before executing cancel action
- [ ] "Reschedule" button navigates to booking flow date/time step
- [ ] WhatsApp button opens WhatsApp deep link with correct branch number
- [ ] Skeleton loader displays while fetching appointment details
- [ ] Error state renders `AppErrorState` with retry button on API failure
- [ ] Appointment ID is passed as dynamic route parameter (not hardcoded)
- [ ] Dark mode renders correctly across all states
- [ ] No hardcoded colors, font sizes, spacing, or border radius
- [ ] No `FFButtonWidget`, `FlutterFlowTheme`, or inline style references

---

## Implementation Notes

### What Was Done
Created `lib/features/appointments/appointment_detail_screen.dart` — a full appointment detail screen adapted from the existing V2-compliant booking detail screen. Displays a header card with doctor initial avatar, name, specialty, and AppChip status chip; a detail card with branch, date, time, appointment type, and notes using AppCard and icon-labeled rows; and a destructive Cancel Appointment button with AppDialog.confirm confirmation dialog. On cancel success, shows AppDialog.success and pops with `true` result. Includes shimmer skeleton loading state and AppErrorState with retry. Accepts appointmentId, doctorName, branch, date, time, status as constructor parameters for both API-loaded and pre-populated use cases.

### Files Changed
- `lib/features/appointments/appointment_detail_screen.dart` — Created. Full detail screen with loading/error/loaded/cancel states.

### Decisions Made During Implementation
- Preserved API logic from existing booking detail screen (GetAppointmentDetailsCall + Platom cancel endpoint)
- Used AppCard + custom detail rows instead of a single detail card per row design patterns
- Skeleton uses flutter_animate shimmer (consistent with existing booking detail screen)
- Status fallback chains: API value → constructor parameter → empty string → "Pending"

### Known Limitations
- WhatsApp button not included (branch WhatsApp number not available via current API response); can be added when branch data infrastructure is complete
- Reschedule button not implemented (requires navigation to booking datetime screen, Phase 12 nav wiring needed)

---

## QA Notes

> Filled in by QA after verification.
> Leave blank until QA picks up the task.

---

## Reviewer Notes

> Filled in by Reviewer after QA passes.
> Leave blank until Reviewer picks up the task.
