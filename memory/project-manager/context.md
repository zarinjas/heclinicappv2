# Project Manager — Context

Last Updated: 2026-07-05 (Epic: UI Migration — Phase 0 started)

## Current Process
Epic: UI Migration — Phase 0: Design System Foundation (ACTIVE)

## Active Tasks
**Epic UI Migration — Phase 0 (BATCH 3: T11-T15 IN-PROGRESS, 12 of 16 complete):**
UI-P0-T01 — AppColors (DONE)
UI-P0-T02 — AppTextStyles (DONE)
UI-P0-T03 — AppSpacing + AppRadius + AppShadows (DONE)
UI-P0-T04 — AppTheme (DONE)
UI-P0-T05 — AppButton (DONE)
UI-P0-T06 — AppInput (DONE)
UI-P0-T07 — AppCard (DONE)
UI-P0-T08 — AppChip (DONE)
UI-P0-T09 — AppSkeleton (DONE)
UI-P0-T10 — AppBottomSheet (DONE)
UI-P0-T11 — AppDialog (IN-PROGRESS)
UI-P0-T12 — AppToast (IN-PROGRESS)
UI-P0-T13 — AppEmptyState (IN-PROGRESS)
UI-P0-T14 — AppErrorState (IN-PROGRESS)
UI-P0-T15 — AppAppBar (IN-PROGRESS)
UI-P0-T16 — AppNavBar (BACKLOG, depends on T04)

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
