# Project Manager — Context

Last Updated: 2026-07-05

## Current Process
Process 2 — Laravel Admin Panel Scaffold (started to unblock P5-T03)

## Active Tasks
**Process 2 — Laravel Admin Panel Scaffold:**
P2-T01 — Laravel Project Setup with Auth and Roles (DONE)
P2-T02 — MySQL Schema (DONE)
P2-T03 — Branch Management CRUD (DONE)
P2-T04 — Doctor Management CRUD (DONE)
P2-T05 — Plato API Proxy Layer (IN-REVIEW)
P2-T06 — Calendar Setup UI (BACKLOG)

**Process 5 — Booking Flow (paused, blocked by Process 2):**
P5-T03 — Doctor Selection Screen (BLOCKED — requires Process 2: Laravel Admin Panel Scaffold)
P5-T04 — Date and Time Slot Selection (BACKLOG)
P5-T05 — Booking Confirmation Screen (BACKLOG)
P5-T06 — WhatsApp Redirect After Booking (BACKLOG)
P5-T07 — Admin Appointment Creation and Confirmation (BACKLOG)
P5-T08 — Appointment Confirmation Notification (BACKLOG)
P5-T09 — Appointments Tab Display (BACKLOG)

## Blocked Tasks
P5-T03 — Doctor Selection Screen: Branch filtering and is_visible_in_app filtering require Process 2 (Laravel Admin Panel Scaffold) with MySQL doctors table and branch-doctor mapping.

## Open Decisions (from v2-decisions.md — Still Pending)
- Design mockup approval from client pending — blocks Process 4 UI Overhaul
- Flutter version upgrade timing undecided — blocks Process 4 UI Overhaul
- Email provider not resolved (Mailgun / SES / SMTP / SendGrid) — blocks Process 8 Notifications
- GET /systemsetup access for He Clinic Plato account unconfirmed — blocks Process 2 Step 6

## Completed Processes
- Process 1 — Security and Foundation: ALL DONE (P1-T01 through P1-T10)
- Process 3 — Mobile App: Data Layer Refactor: ALL DONE (P3-T01 through P3-T06)
- Process 4 — Mobile App: UI/UX Overhaul: ALL DONE (P4-T01 through P4-T06)

## Next Task to Create
After all Process 5 tasks are DONE, create Process 6 tasks (Health Tab).

## Agentic AI Setup
- AI Director workflow: `.github/workflows/agent-director.yml`
- Approval via Telegram: https://t.me/CyberocketBot
- Laravel proxy controller: `laravel/app/Http/Controllers/Api/PlatoProxyController.php`
- VPS bot server: `/var/www/heclinic-bot/` (PM2)

## Notes
Process 5 tasks have a linear dependency chain:
P5-T01 (verify prerequisites) → P5-T02 (branch) → P5-T03 (doctor) → P5-T04 (date/time) → P5-T05 (confirmation) → P5-T06 (WhatsApp) → P5-T07 (admin appointment) → P5-T08 (notifications) → P5-T09 (appointments tab).
P5-T01 verifies the Laravel proxy is ready for POST /appointment/slots calls.
P5-T07 and P5-T08 require the Admin Panel Laravel setup to be functional.
