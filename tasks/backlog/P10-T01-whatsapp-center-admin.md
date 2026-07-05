# WhatsApp Center — Admin Panel

## Header

| Field | Value |
|-------|-------|
| Task ID | T01 |
| Slug | whatsapp-center-admin |
| Process | 10 — Polish and Remaining Features |
| Process Step | Step 1 |
| Type | Both |
| Assigned To | laravel-developer |
| Assigned Date | 2026-07-05 |
| Status | BACKLOG |
| Parallel | YES |
| Depends On | P2-T03 (Branch CRUD — needs branch WhatsApp numbers) |
| Blocked Reason | N/A |

---

## Description

Build a WhatsApp Center in the Admin Panel that allows Super Admin / Staff to send single or bulk WhatsApp messages to patients. Messages are composed from a template with branch-specific WhatsApp numbers and pre-filled text. Uses the existing Branch `whatsapp_number` field and the Plato `POST /whatsapp/send` endpoint via the Laravel proxy. This replaces manual WhatsApp copy-paste workflows with a centralized compose-and-send UI.

---

## Context

> Documents and sections the developer must read before starting.

- `docs/v2-decisions.md` — Process 10, Step 1
- `docs/v2-ux-spec.md` — Admin Panel forms and table patterns
- `docs/CODEBASE.md` — Branch WhatsApp number in Branch model
- `docs/api-guidelines.md` — POST /whatsapp/send

---

## Scope

> Exact deliverables for this task. Be specific. Vague scope causes re-work.

### In Scope
- New Admin controller `WhatsAppController` with `index()`, `send()` actions
- Blade view `admin/whatsapp/index.blade.php` — compose message form (single or bulk)
- Blade view `admin/whatsapp/send.blade.php` — send confirmation / result page
- Form: recipient selection (all patients, by branch, specific patient by name/search), message template editor, preview
- Laravel proxy call to Plato `POST /whatsapp/send` with branch WhatsApp number, recipient phone, message body
- Bulk sending: iterate patients in filtered list, call Plato API per recipient
- Route registration in `routes/web.php` under `auth` + `role` middleware group
- Sidebar nav link in `resources/views/layouts/admin.blade.php`
- Success/error toast feedback for sent messages

### Out of Scope
- WhatsApp message history/log — this is already covered by the existing `NotificationLog` system
- WhatsApp Business API integration — using Plato proxy only
- Media/image attachment in WhatsApp messages
- Scheduled/delayed sending

---

## Technical Spec

> Key implementation details. Reference exact file paths, class names, endpoints, and schema fields from the project docs.

### Files to Create or Modify
- `laravel/app/Http/Controllers/Admin/WhatsAppController.php` — NEW controller
- `laravel/resources/views/admin/whatsapp/index.blade.php` — NEW compose view
- `laravel/resources/views/admin/whatsapp/send.blade.php` — NEW result view
- `laravel/routes/web.php` — add WhatsApp routes (line ~20, inside auth+role group)
- `laravel/resources/views/layouts/admin.blade.php` — add WhatsApp Center nav link

### API Endpoints
- `POST /api/proxy/whatsapp/send` — Laravel proxy → Plato `POST /whatsapp/send` (via `PlatoProxyService`)
- `GET /api/proxy/patient` — list patients by branch (for recipient selection dropdown)

### Data / Schema
- `branches` table: `whatsapp_number` (already exists)
- `patients` table (in Plato, via proxy): patient name, phone, branch
- Plato `/whatsapp/send` payload: `{ phone: string, message: string }`

### UI Components
- Admin Panel form patterns (consistent with existing CMS forms: `Article`, `ServicePackage`, `Slider`)
- Message textarea with character count
- Recipient dropdown (branch-filtered patient list)
- Bulk checkbox "Send to all patients in branch"
- Action bar with "Send" button + loading state
- Toast notification for send result

### Constraints
- All Plato calls MUST route through Laravel proxy (`PlatoProxyService`)
- Branch WhatsApp number must be in `+60` Malaysian format (existing validation in `StoreBranchRequest`)
- Recipient phone must be from Plato patient data, not free-text

---

## Acceptance Criteria

> Testable, binary (PASS/FAIL) criteria. QA verifies exactly these.

- [ ] WhatsApp Center nav link appears in Admin Panel sidebar, navigates to compose page
- [ ] Compose form loads: branch selector, patient selector (single or bulk), message textarea
- [ ] Selecting a branch filters the patient dropdown to patients in that branch
- [ ] "Send to all patients in selected branch" checkbox enables bulk mode
- [ ] Sending a single message calls Plato proxy, returns success/error toast
- [ ] Sending bulk messages calls Plato proxy per patient, shows progress summary
- [ ] Access is gated behind `auth` + `role:super_admin,staff` middleware (NOT branch_admin)

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
- [ ] WhatsApp Center nav link — PENDING
- [ ] Compose form loads — PENDING
- [ ] Branch filters patient dropdown — PENDING
- [ ] Send all checkbox enables bulk — PENDING
- [ ] Single send calls Plato proxy — PENDING
- [ ] Bulk send shows summary — PENDING
- [ ] Auth middleware gate — PENDING

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
