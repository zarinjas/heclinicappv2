# Laravel Developer — Context

Last Updated: 2026-07-05 (P8-T07 implemented)

## Active Task
P8-T07 — Automated Notification Triggers (IN-REVIEW)

## Implementation Summary — P8-T07
- `laravel/database/migrations/2026_07_05_000014_add_reminder_tracking_to_appointments.php`: adds `reminded_24h_at` and `reminded_1h_at` nullable timestamps to appointments table
- `laravel/app/Models/Appointment.php`: added `reminded_24h_at`, `reminded_1h_at` to fillable and casts (datetime)
- `laravel/app/Services/NotificationService.php`: added `sendAppointmentReminder()` (Push+In-App reminder, updates timestamp, logs to notifications_log), `sendDocumentUploadedNotification()` (Push+In-App for document uploads, deep link `health/documents`), private `writeInAppNotify()` helper refactored from `sendInApp()` to avoid code duplication
- `laravel/app/Console/Commands/SendAppointmentReminders.php`: new Artisan command queries appointments for 24h reminders (tomorrow's date, null reminded_24h_at) and 1h reminders (today's date, time within next 60min, null reminded_1h_at), calls sendAppointmentReminder for each, idempotent via nullable timestamp guards
- `laravel/routes/console.php`: schedules `app:send-appointment-reminders` everyMinute()
- `laravel/app/Http/Controllers/Admin/PatientController.php`: `uploadDocument()` triggers `sendDocumentUploadedNotification()` with patient Plato ID and original filename after successful upload
- Trigger 1 (appointment confirmed) already fully implemented by prior P8-T04/P8-T05/P8-T06 work — no new code needed
- PHP syntax: all 7 files pass lint

## Implementation Summary — P8-T06
- `laravel/app/Services/FirebaseService.php`: added `id_patient` field to `writeInAppNotification()` payload, sourced from `$data` array. All other fields (`title`, `body`, `read: false` (boolean), `deep_link`, `type`) were already present.
- `laravel/app/Services/NotificationService.php`: `sendInApp()` signature updated to accept `$deepLink` and `$type` parameters with defaults. Now passes `$appointment->patient_plato_id` as `id_patient` to FirebaseService.
- `laravel/app/Models/Appointment.php`: added `patient_plato_id` to `$fillable` so it can be stored when known.
- `lib/backend/schema/historynotif_record.dart`: added `title`, `body`, `deep_link`, `type` fields. `read` field refactored from `String?` to `dynamic` with `readBool` getter (handles both bool and String "yes"/"no" for backward compat). Updated `createHistorynotifRecordData` to accept `bool? readBool`.
- `lib/front_page/notification_page/notification_page_widget.dart`: tap handler now writes `readBool: true` (boolean). Added deep link routing: `appointments` → MyBookingPage, `health/*` → Reports, `profile` → HomepageNew. Fallback to old message/tittle logic when `deepLink` is empty.
- PHP syntax: all 3 files pass lint. Flutter analyze: zero errors.

## Implementation Summary — P8-T05
- `laravel/.env.example`: added MAIL_MAILER, MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD, MAIL_ENCRYPTION, MAIL_FROM_ADDRESS, MAIL_FROM_NAME variables with SMTP defaults
- `laravel/app/Notifications/AppointmentNotification.php`: NEW — Laravel Notification class with toMail() (subject, greeting, appointment detail lines, salutation) and toArray()
- `laravel/app/Notifications/GeneralNotification.php`: NEW — Laravel Notification class for manual compose notifications with toMail() (subject, greeting, body, optional inline image) and toArray()
- `laravel/app/Services/NotificationService.php`: MAJOR REFACTOR — injected PlatoProxyService for email resolution; sendEmail() now accepts $recipientEmail (nullable) and uses Laravel Notification::route() instead of Mail::raw(); added sendManualEmailNotification() for Admin Panel compose flow; added resolvePatientEmailForAppointment() that queries Plato GET /patient by NRIC/name; graceful skip when no email found (warning logged, no crash); comprehensive try/catch with plato channel logging for all email paths

## Implementation Summary — P8-T04
- `laravel/app/Services/FirebaseService.php`: `writePushNotification()` updated to accept `user_refs` as array (with string backward compat), `branch_ids` array, `doctor_ids` array, `target_date_range` map. Normalizes all inputs before write.
- `laravel/app/Services/NotificationService.php`: `sendPush()` refactored to accept generic `$options` array; added public `sendTargetedPush()` for composer integration; `sendAppointmentConfirmation()` updated to new signature.
- `firebase/functions/index.js`: `sendPushNotifications()` upgraded with 3 targeting resolvers (`resolveUserRefsByBranchIds`, `resolveUserRefsByDoctorIds`, `resolveUserRefsByDateRange`); `user_refs` supports both array and legacy string formats; graceful fallback when Firestore collections are missing; backward compatible broadcast-all path preserved.
- Zero PHP syntax errors confirmed across all Laravel files.
- Targeting resolution priority: branch_ids > doctor_ids > target_date_range > user_refs > broadcast-all.
- Batching for >500 tokens preserved for all paths.

## Implementation Summary — P8-T03
- `laravel/app/Http/Controllers/Admin/NotificationController.php`: added channels validation (required array, min:1, in:push/email/in_app), custom error message "Please select at least one delivery channel.", stores validated channels array instead of hardcoded all-3
- `laravel/app/Services/NotificationService.php`: added optional `$channels` parameter (defaults to all 3 for backward compat), gates `sendPush`/`sendEmail`/`sendInApp` with `in_array()` checks, logs selected channels into NotificationLog
- `laravel/resources/views/admin/notifications/compose.blade.php`: added "Delivery Channels" section with 3 checkboxes (Push/Email/In-App), all checked by default via `old('channels', ['push', 'email', 'in_app'])`, validation error display

## Last Completed Task
P8-T02 — Targeting System — Notifications (DONE)

## Implementation Summary — P8-T02
- `database/migrations/2026_07_05_000013_add_targeting_fields_to_notifications_log.php`: adds `target_date_from` and `target_date_to` columns to `notifications_log` table
- `app/Models/NotificationLog.php`: added `target_date_from`, `target_date_to` to `$fillable` and `$casts` (date)
- `app/Http/Controllers/Admin/NotificationController.php`: `compose()` passes active branches and doctors (filtered by branch_id for branch admins) to view; `send()` validates `target_type` (in:all,branch,doctor,appointment_date_range,specific_patient), `target_ids[]` array, `target_date_from/to` dates, `target_patient` text. For specific_patient, text stored in target_ids JSON. For all, target_ids=null.
- `resources/views/admin/notifications/compose.blade.php`: added "Target Audience" section with dropdown selector (5 options) + 4 conditional panels (branch checkboxes, doctor checkboxes, date range inputs, patient text input) toggled via JavaScript. Uses existing Tailwind form patterns.

## Last Completed Task
P8-T01 — Notification Composer — Admin Panel (DONE)

## Implementation Summary — P8-T01
- `database/migrations/2026_07_05_000012_add_image_to_notifications_log.php`: adds `image_url` column to `notifications_log` table
- `app/Models/NotificationLog.php`: added `image_url` to `$fillable`
- `app/Http/Controllers/Admin/NotificationController.php`: `compose()` shows Blade form, `send()` validates (title max 255, body max 2000, image_url optional valid URL) and saves draft to `notifications_log` with type=`manual`, target=`all`, channels=`['push', 'email', 'in_app']`, status=`draft`
- `routes/web.php`: GET/POST `/admin/notifications/compose` and `/admin/notifications/send` inside auth+role middleware
- `resources/views/admin/notifications/compose.blade.php`: Blade form with title (char counter), body textarea (char counter), image_url (optional), success flash
- `resources/views/layouts/admin.blade.php`: added Notifications sidebar nav link with bell icon

## Last Completed Task
P7-T06 — Appointment Detail View — Admin Panel (DONE)

## Previous Implementation Summary — P7-T06
- `app/Http/Controllers/Admin/AdminAppointmentController.php`: added `show($id)` method — tries local DB by primary key, then by `plato_appointment_id`, then falls back to Plato proxy; casts Plato data to object with `from_plato` flag
- `resources/views/admin/appointments/show.blade.php`: new detail view following branches/show pattern — grouped sections (Patient Info, Appointment Details, Assignment, Notes, Local Record), colored status badge, monospace Plato ID, patient profile link, back navigation
- `routes/web.php`: added `'show'` to `Route::resource('appointments')->only([...])`
- `resources/views/admin/appointments/index.blade.php`: replaced disabled "coming soon" button with working `route('admin.appointments.show')` link

## Implementation Summary — P7-T04
- `app/Http/Controllers/Admin/AdminAppointmentController.php`: new controller with index() fetching appointments from Plato via proxy (`GET /appointment`), supports filters (date_from, date_to, doctor_id, facility_id, status), uses LengthAwarePaginator with 20/page
- `resources/views/admin/appointments/index.blade.php`: Blade view with filter row (date range, doctor/branch dropdowns, status), data table (Date, Time, Patient Name, NRIC, Doctor, Branch, Status chip), colored status chips (green/amber/red/blue), empty state, pagination
- `routes/web.php`: added AdminAppointmentController import and Route::resource('appointments')->only(['index']) under auth+role middleware
- `resources/views/layouts/admin.blade.php`: added Appointments sidebar nav link with calendar SVG icon between Patients and Calendar Setup
- `database/migrations/2026_07_05_000011_create_patient_documents_table.php`: patient_documents table with patient_plato_uid, filename, original_name, title, mime_type, size_bytes, uploaded_by FK, unique on (patient_plato_uid, filename)
- `app/Services/PatientDocumentService.php`: upload/delete/list/serve for patient PDFs using Laravel Storage public disk at `patients/{uid}/documents/{uuid}.pdf`
- `app/Http/Controllers/Admin/PatientController.php`: added uploadDocument() (validates PDF only, max 10MB), deleteDocument(), show() now passes $documents
- `resources/views/admin/patients/show.blade.php`: Documents section with upload form, document list table (title/filename/size/date, download/delete actions), empty state
- `routes/web.php`: POST /admin/patients/{patient}/documents and DELETE /admin/patients/{patient}/documents/{filename}
- Fallback to local storage because kreait/laravel-firebase not installed

## Last Completed Task
P7-T02 — Patient Profile View — Plato Data with Manual Re-Sync (DONE)

## Implementation Summary — P7-T02
- `app/Http/Controllers/Admin/PatientController.php`: enhanced `show()` method — added `Request` parameter for `?sync=1` support (cache-busting via `_nocache` query param), vitals count from `/patient/{id}/graphing` endpoint, passes `$vitalsCount` to view
- `resources/views/admin/patients/show.blade.php`: full rewrite with grouped sections (Personal Info, Contact, Medical, Vitals), "Re-sync from Plato" button, vitals count badge with green dot, None/Unavailable placeholders, footer with Patient ID

## Implementation Summary — P7-T01
- `app/Http/Controllers/Admin/PatientController.php`: new controller with index() querying Plato /patient endpoint via PlatoProxyService with search params (name, NRIC, phone) and current_page pagination. Uses LengthAwarePaginator for Blade pagination links. Includes show() for patient detail view.
- `resources/views/admin/patients/index.blade.php`: Blade view with search form (3 text inputs), data table (Name, NRIC, Given ID, Phone, View action), empty state, pagination links.
- `routes/web.php`: added PatientController import and Route::resource('patients')->only(['index', 'show']) under auth+role middleware.
- `resources/views/layouts/admin.blade.php`: added Patients sidebar nav link with people SVG icon between Doctors and Calendar Setup.

## Implementation Summary — P5-T07
- `database/migrations/2026_07_05_000010_create_appointments_table.php`: appointments table
- `app/Models/Appointment.php`: Eloquent model with branch/doctor BelongsTo
- `config/firebase.php`: Firebase project config
- `app/Services/FirebaseService.php`: Firestore REST API client
- `app/Services/NotificationService.php`: 3-channel dispatch (push/email/in-app)
- `app/Services/AppointmentService.php`: transactional appointment creation with Plato proxy
- `app/Http/Controllers/Api/AppointmentController.php`: POST /api/v2/admin/appointments

## Known Constraints
- Plato API token lives in .env only — never exposed
- All Plato list endpoints must implement pagination: current_page loop until empty
- HTTP 429 handling: exponential backoff 1s → 2s → 4s → 8s
- Monitor x-ratelimit-remaining header
- MySQL schemas in v2-decisions.md are authoritative
- Admin Panel timeout: 10s per Plato request
