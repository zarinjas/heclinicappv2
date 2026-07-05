# Project Manager — Context

Last Updated: 2026-07-05 (UI Epic Phase 1 tasks created — 18 BACKLOG tasks)

## Current Process
Epic: UI Migration — Phase 1: Feature Components (18 tasks in BACKLOG)

## Active Tasks
**Epic UI Migration — Phase 1 (0 of 18 complete):**
UI-P1-T01 — AppointmentCard (BACKLOG)
UI-P1-T02 — DoctorCard (BACKLOG)
UI-P1-T03 — ArticleCard (BACKLOG)
UI-P1-T04 — VideoCard (BACKLOG)
UI-P1-T05 — LoyaltyCard (BACKLOG)
UI-P1-T06 — HealthRecordCard (BACKLOG)
UI-P1-T07 — HeroSlider (BACKLOG)
UI-P1-T08 — QuickActionGrid (BACKLOG)
UI-P1-T09 — StepIndicator (BACKLOG)
UI-P1-T10 — OtpInputRow (BACKLOG)
UI-P1-T11 — SectionHeader (BACKLOG)
UI-P1-T12 — NotificationItem (BACKLOG)
UI-P1-T13 — TransactionItem (BACKLOG)
UI-P1-T14 — BranchCard (BACKLOG)
UI-P1-T15 — TimeSlotChip (BACKLOG)
UI-P1-T16 — VitalsChart (BACKLOG)
UI-P1-T17 — DocumentItem (BACKLOG)
UI-P1-T18 — OfflineBanner (BACKLOG)

## Phase 1 Notes
- All 18 tasks are parallel (no dependencies between them) once Phase 0 is complete
- All tasks are Flutter type, assigned to flutter-developer
- Each task references: docs/ui-design-system.md, docs/ui-migration-plan.md, docs/design-system-v2.png
- Phase 1 must complete before Phases 2-10 screen migrations begin

## Phase 0 Dependency Order:
T01 → T02 → T03 → T04 → T05-T16 (parallel once T04 done)

**Process 8 — Notifications Module (completed):**
P8-T01 through P8-T08 — ALL DONE

**Process 6 — Health Tab (completed):**
P6-T01 through P6-T05 — ALL DONE

**Process 5 — Booking Flow (completed):**
P5-T01 through P5-T09 — ALL DONE

## Blocked Tasks
(None)

## Open Decisions (from v2-decisions.md — Still Pending)
- Design mockup approval from client pending — blocks Process 4 UI Overhaul
- Flutter version upgrade timing undecided — blocks Process 4 UI Overhaul
- Email provider not resolved (Mailgun / SES / SMTP / SendGrid) — blocks Process 8 Notifications
- GET /systemsetup access for He Clinic Plato account unconfirmed — blocks Process 2 Step 6

## Completed Processes
- Process 1 — Security and Foundation: ALL DONE (P1-T01 through P1-T10)
- Process 2 — Laravel Admin Panel Scaffold: ALL DONE (P2-T01 through P2-T06)
- Process 3 — Mobile App: Data Layer Refactor: ALL DONE (P3-T01 through P3-T06)
- Process 4 — Mobile App: UI/UX Overhaul: ALL DONE (P4-T01 through P4-T06)
- Process 5 — Booking Flow: ALL DONE (P5-T01 through P5-T09)
- Process 6 — Health Tab: ALL DONE (P6-T01 through P6-T05)
- Process 7 — Admin Panel: Patient and Appointment Mgmt: ALL DONE (P7-T01 through P7-T06)

- Process 8 — Notifications Module: ALL DONE (P8-T01 through P8-T08)

## Next Task to Create
After all Process 9 tasks are DONE, create Process 10 tasks (Polish and Remaining Features).

## Agentic AI Setup
- AI Director workflow: `.github/workflows/agent-director.yml`
- Approval via Telegram: https://t.me/CyberocketBot
- Laravel proxy controller: `laravel/app/Http/Controllers/Api/PlatoProxyController.php`
- VPS bot server: `/var/www/heclinic-bot/` (PM2)

## Notes
Process 6 tasks have a linear dependency chain:
P6-T01 (scaffold) → P6-T02 (records) → P6-T03 (vitals) → P6-T04 (documents) → P6-T05 (pagination).

All Health tab data is sourced from Plato via the Laravel proxy. The existing ReportsWidget at `lib/front_page/reports/reports_widget.dart` is the target for all P6 changes. The Health tab is already registered at nav index 2 in `lib/main.dart:231` with `'health': ReportsWidget(id: null)`.
