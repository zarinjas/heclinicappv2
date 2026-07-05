# Laravel Developer — Context

Last Updated: 2026-07-05

## Active Task
P5-T07 — Admin Appointment Creation and Confirmation (IN-REVIEW)

## Implementation Summary — P5-T07
- `database/migrations/2026_07_05_000010_create_appointments_table.php`: appointments table with plato_appointment_id, patient_name/NRIC/phone, branch/doctor reference and name denormalization, appointment_date/time, calendar_color_id, notes, status (pending/confirmed/failed), plato_response JSON, notified_at
- `app/Models/Appointment.php`: Eloquent model with branch/doctor BelongsTo, date/datetime/array casting
- `config/firebase.php`: FIREBASE_PROJECT_ID, FIREBASE_WEB_API_KEY, Firestore/FCM endpoint URLs, service account path
- `app/Services/FirebaseService.php`: Firestore REST API client — `writeToFirestore()` with typed document serialization (stringValue, integerValue, booleanValue, arrayValue, mapValue), `writePushNotification()` to `ff_push_notifications` collection (triggers existing Cloud Function sendPushNotificationsTrigger), `writeInAppNotification()` to `historynotif` collection with deep_link support
- `app/Services/NotificationService.php`: 3-channel dispatch — push via FirebaseService.writePushNotification, email via Mail::raw(), in-app via FirebaseService.writeInAppNotification. Logs to notifications_log table. Graceful failure (errors logged but don't fail the transaction)
- `app/Services/AppointmentService.php`: transactional appointment creation — creates MySQL record, forwards to Plato via PlatoProxyService::proxy('POST', 'appointment'), updates with plato_appointment_id on success, triggers NotificationService, rolls back on Plato failure
- `app/Http/Controllers/Api/AppointmentController.php`: POST /api/v2/admin/appointments with Validator-based input validation, 422/502/500 error handling, 201 on success with appointment details
- `routes/api.php`: added POST /api/v2/admin/appointments behind auth:sanctum middleware
- `.env.example`: added FIREBASE_PROJECT_ID, FIREBASE_WEB_API_KEY, FIREBASE_SERVICE_ACCOUNT_PATH, FIREBASE_FIRESTORE_URL

## Last Completed Task
P2-T06 — Calendar Setup UI (DONE)

## Implementation Summary — P2-T06
- `app/Services/PlatoSystemSetupService.php`: fetches `GET /systemsetup` from Plato via `PlatoProxyService`, recursively parses response for calendar entries (looking for `calendar`, `calendars`, or nested arrays), extracts `color` (as `plato_calendar_color_id`) and `name` fields
- `app/Http/Controllers/Admin/CalendarSetupController.php`: full CRUD resource controller + `sync()` action. Index with search (by name/color ID/doctor), doctor filter, active status filter, sort, pagination. Unmapped doctor warning. Sync upserts calendars with `doctor_id = null`, deactivates stale entries. Last sync timestamp via `Setting` model
- `app/Http/Requests/StorePlatoCalendarRequest.php`: validates doctor_id (exists), plato_calendar_color_id (required, max 50), name (nullable), is_active (boolean)
- `app/Http/Requests/UpdatePlatoCalendarRequest.php`: same rules with `sometimes`
- `database/migrations/2026_07_05_000007_make_doctor_id_nullable_on_plato_calendars.php`: makes `doctor_id` nullable on `plato_calendars` table — required for unlinked synced calendar entries
- Blade views: index (sync card with last timestamp, Available Plato Calendars panel from session, search/filter/sort table, unmapped doctor amber warning, empty state with sync CTA), create (doctor dropdown, color ID input, name input, active toggle), edit (doctor dropdown with "Unmapped" option, color ID, name, active toggle), show (detail with doctor name, branch, visibility, timestamps)
- Updated `routes/web.php`: added `CalendarSetupController` import, `POST calendars/sync` route (before resource to avoid route conflict), `Route::resource('calendars')`
- Updated `layouts/admin.blade.php`: replaced disabled "Calendar Setup (Soon)" span with active route link using `routeIs('admin.calendars.*')` pattern

## Implementation Summary — P2-T05
- `config/plato.php`: centralized Plato proxy config (base_url, api_token, timeout, cache TTLs, log_requests, proxy_rate_limit)
- `app/Services/PlatoProxyService.php`: service class with proxy() supporting all HTTP methods (GET/POST/PUT/PATCH/DELETE), healthCheck() to verify Plato connectivity, response caching for GET endpoints with configurable TTL per endpoint type (facility/doctor=300s, slots=60s, default=120s), error normalization to `{ error, code, message }` format, rate-limit header extraction (x-ratelimit-limit, x-ratelimit-remaining), request/error logging to dedicated plato log channel
- `app/Http/Controllers/Api/PlatoProxyController.php`: rewritten to inject PlatoProxyService via DI, added IP-based rate limiting using Laravel's RateLimiter facade (configurable via PLATO_PROXY_RATE_LIMIT), forwards rate-limit headers from Plato response to Flutter client, added health() action
- `routes/api.php`: added `GET /api/v2/plato/health` (public, outside auth middleware) returning `{ status, plato_connected, token_configured, base_url }`
- `config/logging.php`: added `plato` log channel — daily rotation to `storage/logs/plato-proxy.log`, 30 days retention
- `.env.example`: added PLATO_TIMEOUT, PLATO_CACHE_*, PLATO_LOG_REQUESTS, PLATO_PROXY_RATE_LIMIT env vars

## Last Completed Task
P2-T03 — Branch Management CRUD (DONE)

## Implementation Summary — P2-T04
- DoctorController: full CRUD resource controller (index with search/branch/visibility filters, create, store with photo upload to storage/app/public/doctors/, show, edit, update with photo replacement, destroy with photo cleanup)
- StoreDoctorRequest: validation (name required, branch_id required, photo max 2MB image, bio max 500 chars, plato_facility_id unique, is_visible_in_app/is_active boolean)
- UpdateDoctorRequest: same rules with current doctor ignore on unique plato_facility_id
- Blade views: index (table with avatar, name, specialty, branch, visibility eye/eye-off badge, active/inactive badge, pagination, branch filter, visibility filter, text search), create/edit forms (photo file input with preview, branch dropdown, bio textarea with char counter, is_visible_in_app toggle default OFF, is_active toggle), show detail (photo, badges, timestamps, calendar count)
- Updated admin.blade.php: Doctors sidebar "Soon" placeholder replaced with active route link
- Routes: Route::resource('doctors', DoctorController::class) under auth+role middleware
- DoctorSeeder: 3 sample doctors (Ahmad, Siti at Shah Alam visible; Rajesh at Bangi hidden)
- DatabaseSeeder: added DoctorSeeder call
- Flash success/error messages via session on all CRUD operations
- Delete confirmation via JS confirm() dialog with cascade warning
- Photo upload: stored in storage/app/public/doctors/, deleted on doctor removal, replaced on update

## Implementation Summary — P2-T03
- BranchController: full CRUD resource controller (index, create, store, show, edit, update, destroy)
- StoreBranchRequest: validation (name required, WhatsApp +60 prefix, Plato facility ID unique)
- UpdateBranchRequest: same rules with ignore current branch on unique check
- Blade views: index (searchable table, sortable name, active/inactive badges, pagination), create/edit forms, show detail
- Updated admin.blade.php: Branches sidebar placeholder replaced with active route link
- Routes: Route::resource('branches', BranchController::class) under auth+role middleware
- BranchSeeder: 3 sample Malaysian branches (Shah Alam, Bangi active; Putrajaya inactive)
- DatabaseSeeder: added BranchSeeder call
- Flash success messages via session on create/update/delete
- Delete confirmation via JS confirm() dialog

## Implementation Summary — P2-T02
- migrations: branches, doctors, plato_calendars, settings, notifications_log tables created
- Added foreign key on users.branch_id → branches.id (nullOnDelete)
- Models: Branch, Doctor, PlatoCalendar, Setting, NotificationLog with fillable, casts, relationships
- User model: added branch() BelongsTo relationship
- FK cascades: doctors.branch_id → cascadeOnDelete, plato_calendars.doctor_id → cascadeOnDelete
- Nullable FKs use nullOnDelete: doctors.user_id, users.branch_id

## Implementation Summary — P2-T01
- Migration: added `role` (enum: super_admin, branch_admin, staff) and `branch_id` to users table
- RoleMiddleware: checks user role(s), registered as `role` alias in bootstrap/app.php
- Admin AuthController: session-based login/logout with Blade views
- Admin DashboardController: dashboard view with stats cards and welcome message
- Blade views: admin.auth.login, layouts.admin (dark sidebar with placeholder nav), admin.dashboard
- UserSeeder: creates Super Admin from .env ADMIN_EMAIL/ADMIN_PASSWORD, sample Staff user
- User model: role constants (ROLE_SUPER_ADMIN, ROLE_BRANCH_ADMIN, ROLE_STAFF), helper methods, branch relationship
- Routes: /admin/login, /admin/dashboard (protected by auth + role middleware)
- Manual Blade auth (no Breeze/Jetstream) for minimal dependencies

## Known Constraints
- Plato API token lives in .env only — never exposed in any API response, log, or mobile code
- All Plato list endpoints must implement pagination: current_page loop until empty response
- HTTP 429 handling: exponential backoff 1s → 2s → 4s → 8s, then fail gracefully with clear message
- Monitor x-ratelimit-remaining header — pause calls when near limit
- MySQL schemas in v2-decisions.md are authoritative — do not alter column names
- Admin Panel timeout: 10s per Plato request, retry once, then fail with message

## Pending Items
- Calendar Setup sidebar link is placeholder — implemented in P2-T06
- Admin password reset flow not implemented (out of scope)
