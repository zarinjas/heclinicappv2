# QA — Context

Last Updated: 2026-07-05

## Last Verified Task
P8-T05 — Email Provider Configuration (PASSED — 7/7 criteria)

## Verification History
- P8-T05 (2026-07-05): PASSED — 7/7 criteria. .env.example has all 8 MAIL_* vars with SMTP defaults. AppointmentNotification + GeneralNotification classes with toMail()+toArray(). NotificationService::sendEmail() uses Notification::route() with recipientEmail param. resolvePatientEmailForAppointment() queries Plato GET /patient by NRIC/name. Graceful null-email handling with warning log. sendAppointmentConfirmation() creates NotificationLog record. MAIL_MAILER=log configured via config/mail.php log transport. All PHP files syntax-checked: zero errors.

## Verification History
- P8-T04 (2026-07-05): PASSED — 7/7 criteria. FirebaseService::writePushNotification() accepts user_refs (array+string compat), branch_ids, doctor_ids, target_date_range. NotificationService::sendPush() refactored to generic options array; sendTargetedPush() added. Cloud Function upgraded with 3 resolvers (resolveUserRefsByBranchIds, resolveUserRefsByDoctorIds, resolveUserRefsByDateRange). Targeting priority: branch > doctor > date_range > user_refs > broadcast-all. Batching preserved for >500 tokens. Backward compatible broadcast fallback. Status update to "succeeded"/"failed". Graceful error handling with try/catch. PHP syntax check: 37 files, zero errors.
- P8-T03 (2026-07-05): PASSED — 6/6 criteria. Compose form has 3 channel checkboxes (Push/Email/In-App) all checked by default. Controller validates channels as required array with min:1, custom message "Please select at least one delivery channel." Controller stores validated channels array into NotificationLog. NotificationService.sendAppointmentConfirmation() accepts optional $channels parameter defaulting to all 3 for backward compat; gates sendPush/sendEmail/sendInApp with in_array() checks. php -l passes all 4 PHP files.
- P8-T01 (2026-07-05): PASSED — 8/8 criteria.
- P7-T06 (2026-07-05): PASSED — 9/9 criteria. AdminAppointmentController@show($id) finds appointment by primary key, then by plato_appointment_id, then falls back to Plato proxy; abort(404) if not found. show.blade.php follows branches/show.blade.php pattern with grouped sections: Patient Info (Name, NRIC, Phone, Profile link), Appointment Details (Date, Time, Status badge, monospace Plato ID), Assignment (Doctor, Branch, Calendar Color ID), Notes (or "No notes" placeholder), Local Record timestamps (Created/Updated/Notification Sent). Index view replaced disabled button with active link to show route. Routes updated to include 'show'. php -l passes all 4 modified files.

## Verification History
- P7-T05 (2026-07-05): PASSED — 10/10 criteria. StoreAppointmentRequest FormRequest with validation (required fields, after:today for date, max lengths). AdminAppointmentController@create passes branches + doctors to view. @store calls AppointmentService::createAppointment() with validated data, handles Runtime/Exception with flash error. create.blade.php form with 3 sections (Patient Info, Appointment Details, Notes), branch/doctor dropdowns with JS client-side filtering (data-branch attributes), date input with min=tomorrow, hidden branch_name/doctor_name/calendar_color_id auto-populated via JS. Appointment index page "New Walk-In Appointment" button now links to create route. Admin layout updated with @stack('scripts') for page-level JS. Resource route expanded to ['index', 'create', 'store']. php -l passes on all modified PHP files.
- P7-T04 (2026-07-05): PASSED — 10/10 criteria. AdminAppointmentController@index fetches appointments from Plato via proxy, supports filters (date_from, date_to, doctor_id, facility_id, status), uses LengthAwarePaginator with 20/page. Blade view renders data table with 7 columns (Date, Time, Patient Name, NRIC, Doctor, Branch, Status chip). Colored status chips (green/amber/red/blue) with dot indicators. Filter row with date inputs, doctor/branch dropdowns, status dropdown. Empty state with calendar SVG. Pagination links. Sidebar Appointments link between Patients and Calendar Setup. "New Walk-In Appointment" shown as disabled placeholder. View action shown as disabled placeholder. php -l passes syntax check on all 4 files.
- P7-T03 (2026-07-05): PASSED — 9/9 criteria. Upload form in documents section of patient show page. mimetypes:application/pdf validation rejects non-PDF. max:10240 validation rejects >10MB. PatientDocumentService stores to public disk at patients/{uid}/documents/{uuid}.pdf and inserts DB record. show() lists documents via PatientDocumentService@list(). Delete route removes file + DB record with confirm() dialog. Download link serves via Storage::disk('public')->url(). php -l passed on all 5 new/modified files. Storage path includes patient Plato UID.
- P7-T02 (2026-07-05): PASSED — 8/8 criteria. PatientController@show enhanced with Request parameter for ?sync=1 cache-busting, vitals count from /patient/{id}/graphing, passes $vitalsCount to view. show.blade.php full rewrite with grouped sections (Personal Info: NRIC/DOB/Gender/Nationality, Contact: Phone/Address, Medical: Allergies/Notes with None fallback, Vitals: count badge or Unavailable). "Re-sync from Plato" button with teal bg-[#00C9A7] styling. Back link to admin.patients.index. Footer with Patient ID. php -l syntax check passed on PatientController.php.
- P7-T01 (2026-07-05): PASSED — 8/8 criteria. PatientController@index queries Plato /patient via PlatoProxyService with search params (name, NRIC, phone) and current_page pagination. LengthAwarePaginator wraps response for Blade pagination links. index.blade.php renders data table with 5 columns (Name, NRIC, Given ID, Phone, View action). Empty state rendered when no patients. Sidebar Patients link between Doctors and Calendar Setup. All 32 PHP files in laravel/app/ pass php -l syntax check with zero errors.
- P6-T05 (2026-07-05): PASSED — 8/8 criteria.
- P6-T04 (2026-07-05): PASSED — 9/9 criteria.
- P6-T03 (2026-07-05): PASSED — 8/8 criteria.
- P6-T02 (2026-07-05): PASSED — 8/8 criteria.
- P6-T01 (2026-07-05): PASSED — 7/7 criteria.
- P5-T09 (2026-07-05): PASSED — 10/10 criteria.
- P5-T08 (2026-07-05): PASSED — 7/7 criteria.
- P5-T07 (2026-07-05): PASSED — 8/8 criteria.
- P5-T06 (2026-07-05): PASSED — 8/8 criteria.
- P5-T05 (2026-07-05): PASSED — 7/7 criteria.
- P5-T04 (2026-07-05): PASSED — 12/12 criteria.
- P5-T03 (2026-07-05): PASSED — 10/10 criteria (re-verified).
- P2-T06 (2026-07-05): PASSED — 9/9 criteria.
- P2-T05 (2026-07-05): PASSED — 10/10 criteria.
- P2-T04 (2026-07-05): PASSED — 10/10 criteria.
- P2-T03 (2026-07-05): PASSED — 9/9 criteria.
- P2-T02 (2026-07-05): PASSED — 8/8 criteria.
- P5-T02 (2026-07-05): PASSED — 9/9 criteria.
- P5-T01 (2026-07-05): PASSED — 6/6 criteria.
- P4-T06 through P4-T01: All PASSED.
- P3-T06 through P3-T01: All PASSED.

## Key Files to Monitor
- `laravel/app/Http/Controllers/Admin/AdminAppointmentController.php` — NEW: Appointment index with filters and pagination
- `laravel/resources/views/admin/appointments/index.blade.php` — NEW: Appointment list view
- `laravel/app/Http/Controllers/Admin/PatientController.php` — PatientController with index(), show(), uploadDocument(), deleteDocument()
- `laravel/app/Services/PatientDocumentService.php` — document upload/delete/list/serve service
- `laravel/resources/views/admin/patients/show.blade.php` — patient detail with documents section
- `laravel/resources/views/admin/patients/index.blade.php` — patient list view
- `laravel/routes/web.php` — patients/appointments resource routes
- `laravel/resources/views/layouts/admin.blade.php` — sidebar with Patients, Appointments links
