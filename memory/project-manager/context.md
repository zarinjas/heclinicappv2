# Project Manager — Context

Last Updated: 2026-07-05

## Current Process
Process 4 — Mobile App: UI/UX Overhaul (Flutter)

## Active Tasks
P4-T01 — Apply V2 Design System (BACKLOG)
P4-T02 — Replace Bottom Navigation: 4 Tabs to 5 Tabs (DONE)
P4-T03 — Replace 17 Hardcoded Doctor Modals with Dynamic Doctor List (DONE)
P4-T04 — Home Screen Redesign (IN-REVIEW)
P4-T05 — Consolidate Profile Screen (BACKLOG)
P4-T06 — Apply Global Loading, Empty, and Error States (BACKLOG)

## Blocked Tasks
None currently.

## Open Decisions (from v2-decisions.md — Still Pending)
- Design mockup approval from client pending — blocks Process 4 UI Overhaul
- Flutter version upgrade timing undecided — blocks Process 4 UI Overhaul
- Email provider not resolved (Mailgun / SES / SMTP / SendGrid) — blocks Process 8 Notifications
- GET /systemsetup access for He Clinic Plato account unconfirmed — blocks Process 2 Step 6

## Completed Processes
- Process 1 — Security and Foundation: ALL DONE (P1-T01 through P1-T10)
- Process 3 — Mobile App: Data Layer Refactor: ALL DONE (P3-T01 through P3-T06)

## Next Task to Create
After all Process 4 tasks are DONE, create Process 5 tasks (Booking Flow).

## Agentic AI Setup
- AI Director workflow: `.github/workflows/agent-director.yml`
- Approval via Telegram: https://t.me/CyberocketBot
- Laravel proxy controller: `laravel/app/Http/Controllers/Api/PlatoProxyController.php`
- VPS bot server: `/var/www/heclinic-bot/` (PM2)

## Notes
Process 4 tasks have a dependency chain: P4-T01 (design foundation) → P4-T02 (nav), P4-T03 (doctors) → P4-T04 (home) ← P4-T05 (profile) → P4-T06 (global states applied everywhere).
P4-T01 is the critical foundation for all subsequent UI work.
