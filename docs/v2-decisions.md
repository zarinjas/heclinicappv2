# He Clinic V2 — Locked Decisions & Strategy

> **Purpose:** Single source of truth for all V2 decisions. AI should treat this as the primary objective reference.
> **Last Updated:** July 2026
> **Status:** Approved — Active Development Reference
> **UI/UX Spec:** See [docs/v2-ux-spec.md](v2-ux-spec.md)

---

## LOCKED DECISIONS

| # | Topic | Decision | Rationale |
|---|-------|----------|-----------|
| 1 | **Admin Panel UI** | Custom-built — Laravel + Inertia.js + Vue 3 + Tailwind CSS | Full design control, no Filament overhead, matches He Clinic brand |
| 2 | **Booking Flow** | WhatsApp redirect model — intentional business decision | Upsell opportunity, human touch, admin controls Plato data entry |
| 3 | **Notifications** | 3 channels: Push (FCM) + Email + In-App | Broader reach, email for formal confirmation, in-app for history |
| 4 | **Language** | English only (current cycle) | BM/ZH post-V2 if needed |
| 5 | **Payment** | Feature plan only — NOT this cycle | Execute after core features stable |
| 6 | **Primary Focus** | Full UI/UX overhaul + Full Plato API utilization | App underutilizes Plato, current UI is outdated |
| 7 | **WhatsApp Number** | Dynamic — configurable per-branch from Admin Panel | Stored in MySQL, fetched via Laravel API, cached on device |
| 8 | **Plato Calendar Setup** | Admin Panel handles it — sync via GET /systemsetup | Admin maps doctor to Plato calendar color ID in our panel |
| 9 | **Doctor Photos and Bio** | Admin uploads in Admin Panel CMS | Plato /facility only provides name — photo/bio managed by us |
| 10 | **Doctor Visibility** | Admin explicitly selects which doctors appear in app | Plato may have resigned doctors — default OFF, admin enables |
| 11 | **Branch Photos** | Admin uploads in Admin Panel CMS | Branch name/ID from Plato, all media managed by us |
| 12 | **Patient List** | Admin Panel with server-side pagination + search | Plato limit 20/req — paginate via current_page, search by name/NRIC/phone |
| 13 | **Error Handling** | Global interceptor pattern — see Error Handling section | Single consistent pattern across all API calls |
| 14 | **Health Tab Content** | Clinical notes + letters + vitals + admin-uploaded docs | All sourced from Plato; admin can upload external docs per patient |
| 15 | **Doctor No Preference** | Available as option — goes directly to date and time selection | Slots checked against all active doctors in selected branch |

---

## IMPLEMENTATION PROCESS

> Process flows in dependency order. Complete each before starting the next.

### PROCESS 1 — Security and Foundation (Blocking Everything)

1. Move Plato API token out of mobile APK into Laravel .env (server-side proxy)
2. All PlatomeApiGroup calls in Flutter rerouted through Laravel proxy endpoints
3. Fix minSdkVersion 35 to 23 in android/app/build.gradle
4. Fix GetAppointmentDetailsCall — replace hardcoded appointment ID with dynamic parameter
5. Remove test_page/ from production codebase
6. Clean up Copy duplicate pages and copy variants

### PROCESS 2 — Laravel Admin Panel Scaffold

1. Laravel project setup on VPS — auth, roles (Super Admin, Branch Admin, Staff)
2. MySQL schema: branches, doctors, plato_calendars, settings, notifications_log
3. Branch Management module — CRUD + WhatsApp number per branch + Plato facility ID mapping
4. Doctor Management module — CRUD + photo upload + bio + visibility toggle (is_visible_in_app, default OFF) + Plato facility link
5. Plato API proxy layer — all Plato calls route through Laravel with token in .env
6. GET /systemsetup sync — Calendar Setup UI — map doctor to Plato calendar color ID

### PROCESS 3 — Mobile App: Data Layer Refactor

1. Implement global API error interceptor in api_manager.dart
2. Implement pagination helper — current_page loop for all Plato list endpoints
3. Implement modified_since strategy for incremental data fetching
4. Implement HTTP 429 exponential backoff (1s, 2s, 4s, 8s — then fail gracefully and notify user)
5. Monitor x-ratelimit-remaining header — pause calls when near limit
6. Replace hardcoded PlatomeApiGroup base URL with Laravel proxy URL from EnvConfig

### PROCESS 4 — Mobile App: UI/UX Overhaul

1. Apply new design system — colors, typography, spacing (see v2-ux-spec.md)
2. Replace bottom navigation: 4 tabs to 5 tabs (Home, Appointments, Health, Notifications, Profile)
3. Replace 17 hardcoded doctor modals with single dynamic doctor list from GET /facility + admin CMS data
4. Home screen — new layout with dynamic sliders, quick actions, upcoming appointment, doctor list, articles
5. Profile screen — consolidated (remove ProfileCopy duplicate)
6. Apply global loading states (skeleton), empty states, error states consistently

### PROCESS 5 — Booking Flow

1. Prerequisite: Process 2 step 6 complete (Calendar Setup in Admin Panel)
2. Mobile: Branch selection screen — data from GET /api/v2/config/branches
3. Mobile: Doctor selection screen — active doctors (is_visible_in_app = true) for selected branch, No Preference option always shown at top
4. Mobile: Date and Time screen — POST /appointment/slots via Laravel proxy, validate future month, show slots as time chips, skeleton while loading
5. Mobile: Confirmation screen — summary of Branch, Doctor, Date, Time + slot disclaimer banner
6. Mobile: WhatsApp redirect — https://wa.me/{branch_wa_number}?text={prefilled_message}
7. Admin: Receives WA message, creates appointment in Plato, sends confirmation notification
8. Mobile: Patient receives Push + Email + In-App notification Appointment Confirmed
9. Mobile: Appointment appears in Appointments tab via GET /appointment

### PROCESS 6 — Health Tab

1. Mobile: Health tab scaffold — 3 inner tabs: Records, Vitals, Documents
2. Records tab: clinical notes from GET /patient/{id}/note, MC + letters from GET /letter, filter chips by type
3. Vitals tab: health trends graph from GET /patient/{id}/graphing, render dynamically based on response
4. Documents tab: admin-uploaded PDFs from Firebase Storage via GET /api/v2/patients/{id}/documents
5. All lists paginated, modified_since used for incremental refresh

### PROCESS 7 — Admin Panel: Patient and Appointment Management

1. Patient list — server-side pagination (20/page), search by name / NRIC / phone
2. Patient profile view — data from Plato, admin can trigger manual re-sync
3. Patient document upload — PDF to Firebase Storage, linked to patient UID
4. Appointment calendar view — all appointments from GET /appointment
5. Create appointment for walk-ins — POST /appointment via Plato proxy
6. Appointment detail view

### PROCESS 8 — Notifications Module

1. Admin Panel: Notification composer — title, body, image, target segment
2. Targeting: All / By branch / By doctor / By appointment date range / Specific patient
3. Channel selection: Push + Email + In-App (can select all or specific)
4. Push: Firebase Cloud Functions — upgrade existing sendPushNotificationsTrigger
5. Email: Laravel Mail — resolve email provider (Mailgun / SES / SMTP) before this step
6. In-App: Write to Firestore historynotif with deep link support
7. Automated triggers: appointment confirmed (Push+Email+In-App, immediate), appointment reminder (Push+In-App, 24h and 1h before), new document uploaded (Push+In-App, immediate)
8. Notification history log in Admin Panel with delivery status

### PROCESS 9 — CMS Module

1. Sliders — upload image, set order, active/inactive toggle
2. Service Packages — upload image, name, description (replaces 4 static images in app)
3. Articles — TipTap rich text editor, featured image, category, publish/draft status, sort order
4. Videos — paste TikTok URL, auto-fetch thumbnail + title via TikTok oEmbed API, publish/draft status, sort order
5. Doctor profiles — photo upload, bio, specialty, branch assignment, visibility toggle
6. Branch profiles — photo, address, operating hours, WA number, Google Maps link

> **Note:** Articles and Videos replace all hardcoded content in the mobile app. No static article or video data should remain in the Flutter codebase after Process 9 is complete.

### PROCESS 10 — Polish and Remaining Features

1. WhatsApp Center in Admin Panel — send single/bulk via POST /whatsapp/send
2. Queue tracker in mobile app — GET /queue/status
3. Payment history in mobile app — GET /payment
4. Analytics dashboard in Admin Panel — appointment trends, patient count, notification stats
5. Role and permission audit — Branch Admin restricted to own branch data only
6. Firestore security rules review and tighten
7. Remove unused Firebase Functions dependencies (braintree, stripe, razorpay, langchain)
8. Flutter version upgrade assessment

---

## BOOKING FLOW — DETAILED

### The Full Flow

Patient (Mobile App):
  Home -> Book Appointment -> Select Branch -> Select Doctor (or No Preference)
  -> Select Date and Time (real slots from POST /appointment/slots)
  -> Confirm Details (summary + disclaimer)
  -> Open WhatsApp (pre-filled message to branch WA number)

Staff (WhatsApp + Plato + Admin Panel):
  Receives WA message -> upsells if applicable
  -> Creates appointment in Plato (POST /appointment)
  -> Sends Appointment Confirmed notification via Admin Panel

Patient (after confirmation):
  Receives Push + Email + In-App notification
  Appointments tab shows new appointment (from GET /appointment)

### Slot Disclaimer (Mandatory UI Element)

Slots shown are NOT reserved until admin confirms via Plato.
Confirmation screen must display:
  Your preferred slot is not confirmed until our team responds via WhatsApp.

### WhatsApp Pre-filled Message Format

  Hi He Clinic [Branch Name]!

  I would like to book an appointment:
  - Name: [Patient Name]
  - NRIC: [Patient NRIC]
  - Branch: [Branch Name]
  - Doctor: [Doctor Name / No Preference]
  - Date: [Selected Date]
  - Time: [Selected Time]

  Please confirm my appointment. Thank you!

### WhatsApp Deep Link

  https://wa.me/{branch_whatsapp_number}?text={url_encoded_message}

Number fetched from GET /api/v2/config/branches — cached locally, refreshed on app open.

---

## ERROR HANDLING PATTERN

### Mobile App — Global Interceptor (api_manager.dart)

  200-299  -> Success -> return data
  401      -> Token expired -> clear session -> redirect to Login
               Toast: Session expired. Please log in again.
  429      -> Rate limited -> exponential backoff (1s, 2s, 4s, 8s)
               After 4 retries: toast Too many requests, please try again shortly.
  500-599  -> Server error -> show error state + Try Again button
  No network -> Banner: No internet connection — showing last synced data
                Write operations blocked with inline message

### UI Error States (Apply to Every Screen)

| State | UI Behaviour |
|-------|-------------|
| Loading | Skeleton loader matching content shape — never a full-screen spinner |
| Empty | Illustration + message + optional CTA button |
| Error | Error icon + message + Try Again button — never a blank screen |
| Offline | Top banner: You are offline — showing last synced data |

### Admin Panel — Laravel (Plato API Calls)

  429 -> Exponential backoff, log to admin notification center
  401 -> Alert Super Admin: Plato API token expired — update in Settings
  500 -> Log error + show: Plato is unreachable, try again later
  Timeout -> 10s timeout, retry once, then fail with clear message

---

## DOCTOR AND BRANCH MANAGEMENT

### Doctor Data Sources

| Field | Source |
|-------|--------|
| Name | Plato GET /facility |
| Plato Facility ID | Plato GET /facility |
| Photo | Admin uploads in Admin Panel |
| Bio / Specialty | Admin enters in Admin Panel |
| Branch assignment | Admin sets in Admin Panel |
| Visible in app | Admin toggle — default: OFF |

Doctors are hidden by default when synced from Plato. Admin must explicitly enable each doctor. This prevents resigned or inactive doctors from appearing in the app.

### Branch Data Sources

| Field | Source |
|-------|--------|
| Name | Admin enters in Admin Panel |
| Plato Facility ID | Admin maps manually |
| Photo | Admin uploads |
| Address / Hours | Admin enters |
| WhatsApp Number | Admin enters (per-branch) |
| Google Maps Link | Admin enters, or auto-generated from lat/lng |

---

## PLATO CALENDAR — SETUP APPROACH

Each calendar in Plato is identified by a color hex value. Every appointment must specify which calendar it belongs to.

Example mapping:
  Calendar A = color #FF0000 = Dr. Ahmad
  Calendar B = color #00FF00 = Dr. Sarah
  Calendar C = color #0000FF = Aesthetic room

Slot check for specific doctor:
  POST /appointment/slots with check_for_conflicts: [#FF0000]

Slot check for No Preference (all active doctors in branch):
  POST /appointment/slots with check_for_conflicts: [#FF0000, #00FF00, #0000FF]

### Setup Steps (Admin Panel -> Settings -> Calendar Setup)

1. Click Sync from Plato -> GET /systemsetup -> saves all color IDs to MySQL plato_calendars
2. Admin maps each color ID to Doctor (or marks as shared room)
3. Mobile booking uses these mappings when calling POST /appointment/slots
4. Re-sync only needed when He Clinic adds or removes doctors/rooms in Plato

### MySQL Schema

  CREATE TABLE plato_calendars (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    plato_color   VARCHAR(20) NOT NULL,
    name          VARCHAR(100) NOT NULL,
    branch_id     INT REFERENCES branches(id),
    doctor_id     INT REFERENCES doctors(id) NULL,
    is_active     BOOLEAN DEFAULT true,
    synced_at     TIMESTAMP,
    created_at    TIMESTAMP,
    updated_at    TIMESTAMP
  );

  CREATE TABLE doctors (
    id                  INT PRIMARY KEY AUTO_INCREMENT,
    name                VARCHAR(100) NOT NULL,
    specialty           VARCHAR(100),
    photo_url           VARCHAR(255),
    bio                 TEXT,
    plato_facility_id   VARCHAR(100),
    branch_id           INT REFERENCES branches(id),
    is_visible_in_app   BOOLEAN DEFAULT false,
    is_active           BOOLEAN DEFAULT true,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP
  );

  CREATE TABLE branches (
    id                  INT PRIMARY KEY AUTO_INCREMENT,
    name                VARCHAR(100) NOT NULL,
    address             TEXT,
    phone               VARCHAR(20),
    whatsapp_number     VARCHAR(20),
    operating_hours     VARCHAR(255),
    photo_url           VARCHAR(255),
    google_maps_url     VARCHAR(255),
    latitude            DECIMAL(10,7),
    longitude           DECIMAL(10,7),
    plato_facility_id   VARCHAR(100),
    is_active           BOOLEAN DEFAULT true,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP
  );

---

## HEALTH TAB — CONTENT SPEC

### Data Sources (All via Plato API through Laravel Proxy)

| Content | Plato Endpoint | Notes |
|---------|---------------|-------|
| Clinical notes / Doctor notes | GET /patient/{id}/note | Paginated, modified_since supported |
| Medical certificates | GET /letter | Filter by letter type |
| Referral letters | GET /letter | Filter by letter type |
| Lab and radiology results | GET /letter or GET /patient/{id}/note | Depends on lab Plato integration |
| Vitals / health trends | GET /patient/{id}/graphing | Render dynamically based on response shape |
| Visit / invoice history | GET /invoice | Past visits + billing summary |

### Admin-Uploaded Documents

  - Admin Panel: Patient Profile -> Documents -> Upload PDF
  - Stored: Firebase Storage at patients/{patient_id}/documents/{filename}
  - Fetched: GET /api/v2/patients/{id}/documents via Laravel
  - Displayed: Patient Health tab -> Documents section

### Health Tab Inner Tabs

| Tab | Content |
|-----|---------|
| Records | Clinical notes, MC, referral letters — filter chips by type |
| Vitals | Line graphs per vital type from /graphing — render dynamically |
| Documents | Admin-uploaded PDFs + lab results — PDF viewer on tap |

---

## NOTIFICATION STRATEGY

### 3 Channels

| Channel | Tool | Use Case |
|---------|------|----------|
| Push | Firebase Cloud Messaging | Real-time alerts, appointment reminders |
| Email | Laravel Mail (provider TBD) | Appointment confirmation, formal documents |
| In-App | Firestore historynotif | Notification center, history, deep links |

### Automated Triggers

| Trigger | Channels | Timing |
|---------|---------|--------|
| Appointment confirmed by admin | Push + Email + In-App | Immediately |
| Appointment reminder | Push + In-App | 24h before + 1h before |
| New document uploaded | Push + In-App | Immediately on upload |

### Targeting Options

  - All patients (broadcast)
  - By branch
  - By doctor
  - By appointment date range
  - Specific patient (by name / NRIC)

---

## ADMIN PANEL — TECH STACK

  Laravel        — Backend, routing, Plato API proxy, scheduling, mail
  Inertia.js     — SPA bridge (no separate frontend API layer needed)
  Vue 3          — Reactive frontend components
  Tailwind CSS   — Design system
  Alpine.js      — Lightweight JS for simple interactions
  Chart.js       — Analytics charts
  TipTap         — Rich text editor for CMS articles

### Modules

| Module | Priority |
|--------|----------|
| Auth + Role Management | Critical |
| Branch Management | Critical |
| Doctor Management (visibility toggle) | Critical |
| Plato API Proxy + Calendar Setup | Critical |
| Patient List + Search + Pagination | High |
| Appointment Calendar + Create for Walk-ins | High |
| Notifications (3-channel composer + automated triggers) | High |
| CMS (Sliders, Packages, Articles, Videos, Doctor Profiles) | High |
| Health Documents (upload per patient) | High |
| Queue Management | High |
| Invoice and Billing Viewer | High |
| WhatsApp Center | Medium |
| Loyalty Points Panel | Medium |
| Analytics Dashboard | Medium |

### Not Executing This Cycle

  - Online Payment Gateway (FPX / Stripe)
  - Telehealth / Video Call
  - Lab/Radiology direct Plato integration
  - Native in-app TikTok video playback — redirect to TikTok app or browser instead

---

## SECURITY — MANDATORY FIRST

| Fix | Priority | Blocks |
|-----|----------|--------|
| Plato token to Laravel .env (server-side proxy) | CRITICAL | All Plato features |
| minSdkVersion 35 to 23 | CRITICAL | Android device testing |
| Fix hardcoded appointment ID in GetAppointmentDetailsCall | HIGH | Appointment detail screen |
| Pagination on all Plato list calls | HIGH | Data completeness |
| HTTP 429 + exponential backoff | HIGH | API stability |
| Firestore security rules audit | HIGH | Data security |
| Remove test_page/, clean Copy pages | MEDIUM | Code quality |
| Remove unused Firebase Functions deps | MEDIUM | Attack surface reduction |

---

## OPEN QUESTIONS

### Resolved

| # | Question | Answer |
|---|----------|--------|
| 1 | Admin Panel stack? | Laravel + Inertia.js + Vue 3 + Tailwind CSS |
| 2 | WhatsApp number dynamic? | Yes — per-branch, managed in Admin Panel |
| 3 | Who sets up Plato calendar? | We do — via GET /systemsetup sync + Calendar Setup UI |
| 4 | Doctor photos source? | Admin uploads — Plato only provides name |
| 5 | Doctor visibility control? | Admin toggles per-doctor — default OFF |
| 6 | Branch photos source? | Admin uploads |
| 7 | Booking flow model? | WhatsApp redirect — slots shown but not held |
| 8 | Health tab content? | Clinical notes + letters + vitals + admin-uploaded docs |
| 9 | Patient No Preference option? | Yes — checks all active doctor slots in selected branch |
| 10 | Get Directions? | Google Maps URL deep link (maps.google.com/?q=lat,lng) |

### Still Pending

| # | Question | Blocks |
|---|----------|--------|
| 1 | Email provider? (Mailgun / SES / SMTP / SendGrid) | Process 8 — Notifications |
| 2 | Does He Clinic Plato account have GET /systemsetup access? | Process 2 step 6 |
| 3 | Design mockup approval from client? | Process 4 — UI overhaul |
| 4 | Flutter version upgrade — during V2 or after? | Process 4 — UI overhaul |

---

## RELATED DOCUMENTS

| Document | Purpose |
|----------|---------|
| docs/v2-ux-spec.md | Full UI/UX specification — screens, components, states |
| docs/CODEBASE.md | Full technical audit — existing code, known issues |
| docs/api-guidelines.md | Official Plato API reference |
| docs/v2-pitch-deck.md | Client proposal |

---


## CMS MODULE — ARTICLES AND VIDEOS

### Articles

#### Data Flow

  Admin Panel: Create/edit article -> TipTap editor -> publish
           |
           v
  Laravel: stores in MySQL cms_articles table
           |
           v
  Mobile: GET /api/v2/cms/articles -> renders article list + detail

#### MySQL Schema

  CREATE TABLE cms_articles (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    title           VARCHAR(255) NOT NULL,
    slug            VARCHAR(255) NOT NULL UNIQUE,
    body            LONGTEXT NOT NULL,          -- TipTap HTML output
    excerpt         TEXT NULL,                  -- auto-generated or manually entered
    featured_image  VARCHAR(255) NULL,          -- Firebase Storage URL
    category        VARCHAR(100) NULL,
    author_name     VARCHAR(100) NULL,
    status          ENUM('draft','published') DEFAULT 'draft',
    sort_order      INT DEFAULT 0,
    published_at    TIMESTAMP NULL,
    created_by      INT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_published_at (published_at)
  );

#### Laravel API Endpoints

  GET  /api/v2/cms/articles              -- list published articles, paginated (10/page)
  GET  /api/v2/cms/articles/{slug}       -- single article detail

  Admin (authenticated):
  GET    /api/v2/admin/cms/articles          -- all articles including drafts
  POST   /api/v2/admin/cms/articles          -- create article
  PUT    /api/v2/admin/cms/articles/{id}     -- update article
  DELETE /api/v2/admin/cms/articles/{id}     -- delete article

#### Mobile Integration

  Home screen -> Health Tips section:     GET /api/v2/cms/articles?limit=3
  Articles list screen (See All):         GET /api/v2/cms/articles (paginated)
  Article Detail screen:                  GET /api/v2/cms/articles/{slug}

---

### Videos

#### Approach

Admin pastes TikTok URL -> Laravel calls TikTok oEmbed API to fetch thumbnail + title automatically.
Mobile displays thumbnail grid. Tap opens TikTok app (if installed) or browser -- no in-app playback.

TikTok oEmbed endpoint (public, no auth required):
  GET https://www.tiktok.com/oembed?url={tiktok_url}
  Returns: title, thumbnail_url, author_name

#### Data Flow

  Admin Panel: paste TikTok URL -> click Fetch Info
           |
           v
  Laravel: GET https://www.tiktok.com/oembed?url={url} -> returns thumbnail_url + title
           |
           v
  Laravel: download thumbnail -> upload to Firebase Storage (cache)
           |
           v
  Admin confirms -> saved to cms_videos
           |
           v
  Mobile: GET /api/v2/cms/videos -> show thumbnail cards
           |
           v
  Patient taps -> url_launcher opens TikTok URL (TikTok app or browser)

#### Why Cache Thumbnail to Firebase Storage

TikTok oEmbed thumbnail URLs can expire or change. Caching on save ensures thumbnails
always load in the app regardless of TikTok CDN availability.

#### MySQL Schema

  CREATE TABLE cms_videos (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    title           VARCHAR(255) NOT NULL,      -- from oEmbed or manually overridden by admin
    tiktok_url      VARCHAR(500) NOT NULL,
    thumbnail_url   VARCHAR(500) NOT NULL,      -- cached to Firebase Storage on save
    tiktok_author   VARCHAR(100) NULL,          -- from oEmbed author_name
    status          ENUM('draft','published') DEFAULT 'draft',
    sort_order      INT DEFAULT 0,
    published_at    TIMESTAMP NULL,
    created_by      INT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status)
  );

#### Laravel API Endpoints

  GET  /api/v2/cms/videos              -- list published videos, paginated (10/page)

  Admin (authenticated):
  GET    /api/v2/admin/cms/videos              -- all videos including drafts
  POST   /api/v2/admin/cms/videos/fetch-info   -- fetch oEmbed preview before save
  POST   /api/v2/admin/cms/videos              -- create video entry
  PUT    /api/v2/admin/cms/videos/{id}         -- update video entry
  DELETE /api/v2/admin/cms/videos/{id}         -- delete video entry

#### Mobile Integration

  Home screen -> Videos section:     GET /api/v2/cms/videos?limit=6
  Videos list screen (See All):      GET /api/v2/cms/videos (paginated)
  Tap thumbnail:                     url_launcher -> TikTok app or browser

---

## LOYALTY POINTS SYSTEM

### Konsep

  Patient Appreciation Program — bukan "Loyalty/Rewards" untuk elak isu MMC.
  Setiap RM1 yang dibelanjakan = 1 Point. Points boleh ditebus untuk diskaun bil akan datang.

### Mekanisma

| Item | Detail |
|------|--------|
| Earn Rate | RM1 = 1 point (flat rate) |
| Redemption Rate | 100 points = RM5 discount |
| Min Redemption | 100 points |
| Max Per Transaction | 1,000 points max guna sekali bayar |
| Expiry | 12 bulan dari tarikh earn (FIFO — points lama guna dulu) |
| Auto-Earn | Bila staff finalize invoice di Admin Panel → points auto-credit |
| Tiers | Standard (0pt), Silver (5,000pt) → 2x earn rate, Gold (20,000pt) → 3x earn rate |

### Data Source — Plato API

Plato tidak ada dedicated loyalty API. Points dikira dari invoice data:

  GET /{db}/invoice            — ambil invoice_total dan patient_id untuk history
  POST /{db}/invoice/finalize  — trigger point untuk credit points
  invoice_id                   — unique key untuk duplicate/fraud check

Semua loyalty data disimpan dalam MySQL kerana keperluan atomic transactions untuk
financial accuracy. Firestore digunakan hanya untuk real-time balance display di mobile.

### Technical Flow — Earn

  Admin Panel: Staff finalize invoice (POST /{db}/invoice/finalize via Laravel proxy)
           │
           ▼
  Laravel: LoyaltyService::earnFromInvoice($invoice_id, $invoice_total, $patient_id)
           │
           ├── Check duplicate: invoice_id already in loyalty_transactions? → skip
           ├── Fetch patient tier from loyalty_accounts → apply multiplier
           ├── Kira: points = floor(invoice_total) × earn_rate × tier_multiplier
           ├── INSERT loyalty_transactions { invoice_id, patient_id, points, type: "earn", expires_at: +12mo }
           └── UPDATE loyalty_accounts SET balance += points, lifetime_earned += points
                │
                ▼
           FCM Push: "You earned X points!"
           Firestore mirror: update loyalty_accounts/{patient_id}.balance

### Technical Flow — Redeem

  Patient taps Redeem in app → selects amount (min 100pt, max 1000pt)
           │
           ▼
  Laravel: LoyaltyService::redeemPoints($patient_id, $points_requested)
           │
           ├── Check balance >= requested
           ├── FIFO: consume oldest non-expired transactions first
           ├── INSERT loyalty_transactions { type: "redeem", points: -X }
           ├── UPDATE loyalty_accounts SET balance -= X
           └── Return redemption_code to mobile app
                │
                ▼
  Staff enters redemption_code at billing → discount applied

### MySQL Schema

  CREATE TABLE loyalty_accounts (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    patient_id      VARCHAR(100) NOT NULL UNIQUE,
    patient_nric    VARCHAR(20) NOT NULL,
    balance         INT DEFAULT 0,
    lifetime_earned INT DEFAULT 0,
    tier            ENUM('standard','silver','gold') DEFAULT 'standard',
    tier_updated_at TIMESTAMP NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  );

  CREATE TABLE loyalty_transactions (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    patient_id      VARCHAR(100) NOT NULL,
    invoice_id      VARCHAR(100) NULL,
    type            ENUM('earn','redeem','expire','adjust') NOT NULL,
    points          INT NOT NULL,
    balance_after   INT NOT NULL,
    staff_id        INT NULL,
    reason          TEXT NULL,
    expires_at      TIMESTAMP NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_patient (patient_id),
    INDEX idx_invoice (invoice_id),
    UNIQUE KEY uq_invoice_earn (invoice_id, type)
  );

  CREATE TABLE loyalty_config (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    key_name        VARCHAR(50) NOT NULL UNIQUE,
    value           VARCHAR(100) NOT NULL,
    updated_by      INT NULL,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -- Keys: earn_rate, redemption_rate, min_redemption, max_per_txn, expiry_months
  );

### Tier Auto-Update

  After every earn transaction, Laravel checks lifetime_earned:
    >= 20,000 → gold (3x earn multiplier)
    >= 5,000  → silver (2x earn multiplier)
    default   → standard (1x)

  If tier upgraded → FCM Push: "Congratulations! You've reached Silver tier!"

### Fraud Prevention

| Measure | Implementation |
|---------|---------------|
| Duplicate earn | UNIQUE KEY (invoice_id, type) — satu invoice tak boleh earn dua kali |
| Audit trail | Setiap transaction ada staff_id, timestamp, reason |
| Non-transferable | Points tied to patient_id (Plato) + NRIC |
| Manual adjust gated | Hanya Super Admin / Supervisor boleh manual adjust |
| FIFO expiry | Points lama expire dulu — no cherry-picking |

### MMC Regulatory Note

  1. Nama: "Patient Appreciation Program" — bukan "Loyalty Rewards"
  2. Promosi dalam app sahaja — bukan billboard atau social media ads
  3. Tiada referral bonus — points dari spend sendiri sahaja
  4. Dapatkan written guidance dari KKM/MMC sebelum launch
  5. T&C clear: points bukan cash value, clinic berhak ubah terma

---

## PROCESS 11 — Loyalty Points System

> Execute after Process 7 (Patient and Appointment Management) is stable.

1. MySQL: create loyalty_accounts, loyalty_transactions, loyalty_config tables
2. Seed loyalty_config defaults: earn_rate=1, redemption_rate=0.05, min_redemption=100, max_per_txn=1000, expiry_months=12
3. LoyaltyService class: earnFromInvoice(), redeemPoints(), expirePoints(), adjustPoints()
4. Hook LoyaltyService::earnFromInvoice() into invoice finalize action in Admin Panel
5. Tier auto-update logic after every earn transaction
6. Laravel scheduled job: daily expiry check — expire points past 12 months, warn 30 days before
7. Firestore mirror: sync balance to loyalty_accounts/{patient_id} for real-time display
8. Mobile: Loyalty section on Home screen — points balance widget + tier badge (see v2-ux-spec.md)
9. Mobile: Profile → My Points — full transaction history, redeem button, tier progress bar
10. Admin Panel: Loyalty Points Panel — dashboard, patient lookup, manual adjust, config
11. FCM triggers: points earned, tier upgrade, expiry warning (30 days before)
