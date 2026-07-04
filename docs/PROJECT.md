# He Clinic Mobile App

> FlutterFlow-generated Flutter project — Healthcare/Clinic booking app.

---

## Tech Stack

| Layer | Stack |
|-------|-------|
| **Framework** | Flutter 3.29.3 (Dart 3.7.2) |
| **State Management** | Provider (`ChangeNotifier`) |
| **Routing** | GoRouter 12.1.3 |
| **Backend** | Firebase + REST API |
| **Cloud Functions** | Firebase Functions (Node 20) |
| **Auth** | Firebase Auth (Email, Google, Apple, Anonymous, JWT, Phone, GitHub) |
| **Database** | Cloud Firestore |
| **Push Notifications** | Firebase Cloud Messaging + Local Notifications |

---

## Firebase Project

- **Project ID:** `heclinicapps-8be27`
- **Android Package:** `com.hemedgroup.heclinicapps`
- **iOS Bundle ID:** `com.hemedgroup.heclinicapps`

### Firestore Collections

| Collection | Purpose |
|------------|---------|
| `users` | Firebase auth users |
| `patients` | Patient records (mirror from Platom) |
| `articles` | Static articles |
| `videos` | Video content |
| `branch` | Branch locations |
| `otps` | OTP verification codes |
| `fcm` / `fcm_tokens` | FCM push tokens |
| `historynotif` | Notification history |
| `biometric` | Biometric settings |
| `info` | General info content |
| `ff_push_notifications` | Push notification queue (Firestore-triggered) |

### Cloud Functions (Firebase)

| Function | Trigger | Description |
|----------|---------|-------------|
| `addFcmToken` | HTTPS Callable | Register device FCM token per user |
| `sendPushNotificationsTrigger` | Firestore `.onCreate` on `ff_push_notifications` | Send push notifications to target users |
| `onUserDeleted` | Auth `onDelete` | Cleanup on user deletion |

---

## API Endpoints

### 1. Medical Apps API (`https://hemedicalapps.com/api`)

Main backend for auth & clinic operations.

| Method | Endpoint | Call Class | Description |
|--------|----------|------------|-------------|
| POST | `/register` | `RegisterCall` | Register new patient (multipart: email, tel, name, nric, dob, allergies, doctor list, etc) |
| POST | `/login` | `LoginCall` | Email + password login |
| GET | `/profile` | `ProfileCall` | Get user profile (Bearer token) |
| GET | `/logout` | `LogoutCall` | Logout user |
| POST | `/forgot-password` | `RequestForgotPasswordCall` | Request reset code |
| POST | `/verify-reset-code` | `VerifyResetCodeCall` | Verify OTP/reset code |
| POST | `/change-password` | `ChangepasswordCall` | Change password |
| POST | `/change-password-first` | `FirsttimechangepasswordCall` | First-time password change |
| POST | `/changePasswordforgot` | `ForgotchangeCall` | Forgot password flow |
| GET | `/sliders` | `SlidersCall` | Homepage slider images |
| GET | `/servicepackages` | `ServicesPackagesCall` | Service packages list |
| POST | `/appointments` | `CreateAppointmentCall` | Create appointment |
| POST | `/update` | `UpdateProfilCall` | Update user profile (multipart) |
| GET | `/pdfs` | `GetMedicalCertificateCall` | List medical certificates |

### 2. Plato API (`{db}/` — Platomedical Clinic Backend)

> **Rujukan rasmi:** [`docs/api-guidelines.md`](api-guidelines.md) — Dokumentasi Platform Pembangun Plato.
>
> URL pattern rasmi: `/{db}/...` (contoh: `/hemedclinic/patient`). App sekarang guna `https://clinic.platomedical.com/api/hemedclinic/...`.
>
> **Auth:** Semua endpoint guna Bearer token (hardcoded sementara: `1463d1150e7b199effa2793c2d809034`).

| Method | Endpoint (Rasmi) | Call Class | Status |
|--------|------------------|------------|--------|
| GET | `/{db}/patient` | `GetPatientCall` | ✅ |
| GET | `/{db}/patient/{id}` | `GetPatientbyidCall` / `GetPatientbyidCopyCall` | ✅ (duplicate) |
| POST | `/{db}/patient` | — | ❌ |
| PUT | `/{db}/patient/{id}` | `EditPatiendCall` | ✅ |
| DELETE | `/{db}/patient/{id}` | `DeletePatientForAdminOnlyCall` | ❌ (no UI) |
| GET | `/{db}/search/patient` | `CeknumberphoneCall` | ✅ |
| POST | `/{db}/patient/merge` | — | ❌ |
| GET | `/{db}/patient/{id}/graphing` | — | ❌ |
| GET | `/{db}/patient/{id}/updatelink` | — | ❌ |
| GET | `/{db}/patient/{id}/note` | `GetReportCall` | ✅ |
| GET | `/{db}/facility` | `GetproviderCall` | ✅ |
| POST | `/{db}/facility` | — | ❌ |
| GET | `/{db}/appointment` | `GetAppointmentCall` / `GetAppointmentUpcomingCall` | ✅ |
| GET | `/{db}/appointment/{id}` | `GetAppointmentDetailsCall` (hardcoded ID) | ⚠️ broken |
| POST | `/{db}/appointment` | — | ❌ |
| POST | `/{db}/appointment/slots` | — | ❌ |
| GET | `/{db}/appointment/calendars` | `GetAppointmentCopyCall` | ✅ |
| GET | `/{db}/appointment/codes` | `GetAppointmentCodeCall` | ✅ |
| GET | `/{db}/letter` | `LetterCall` | ✅ |
| GET | `/{db}/letter/count` | — | ❌ |
| GET | `/{db}/invoice` | `LetterCopyCall` (misnamed) | ✅ |
| POST | `/{db}/invoice` | — | ❌ |
| PUT | `/{db}/invoice/{id}` | — | ❌ |
| POST | `/{db}/invoice/items` | — | ❌ |
| POST | `/{db}/invoice/finalize` | — | ❌ |
| POST | `/{db}/invoice/payment` | — | ❌ |
| GET | `/{db}/queue/status` | — | ❌ |
| POST | `/{db}/queue/status` | — | ❌ |
| GET | `/{db}/payment` | — | ❌ |

### 3. WordPress API (Articles)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `https://hemedicalclinic.com/wp-json/wp/v2/posts?per_page=10` | Fetch latest articles (title, excerpt, content, featured image) |

---

## Plato API Gap Analysis

> Berdasarkan [`docs/api-guidelines.md`](api-guidelines.md) — Dokumentasi Platform Pembangun Plato rasmi.
> ✅ = Dah guna | ❌ = Tak guna / belum implement | ⚠️ = Rosak / incomplete

### Invoice / Queue (Biggest Gap)

Plato kata **invoice = queue**. Setiap kali masuk giliran, invois auto-tercipta. App sekarang **baca je invoice**, tak boleh create/finalize/pay.

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/invoice` | GET | ✅ | Guna `LetterCopyCall` (misnamed) |
| `/{db}/invoice` | POST | ❌ | Cipta draf invois & giliran |
| `/{db}/invoice/{id}` | PUT | ❌ | Update invois |
| `/{db}/invoice/items` | POST | ❌ | Tambah item bil (ubat/prosedur) dari inventory |
| `/{db}/invoice/finalize` | POST | ❌ | Muktamadkan invois |
| `/{db}/invoice/payment` | POST | ❌ | Rekod bayaran — lepas ni invois dikunci |
| `/{db}/queue/status` | GET | ❌ | Status giliran semasa |
| `/{db}/queue/status` | POST | ❌ | Update status (Selesai/Dalam Rawatan) |
| `/{db}/payment` | GET | ❌ | Senarai transaksi pembayaran |

### Appointment

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/appointment` | GET | ✅ | List appointment by patient |
| `/{db}/appointment` | POST | ❌ | Cipta temujanji direct ke Plato (skrg guna Medical Apps API) |
| `/{db}/appointment/{id}` | GET | ⚠️ | Hardcoded ID `a052e78b...` |
| `/{db}/appointment/slots` | POST | ❌ | Cari slot masa kosong (mandatory: month, color[], simultaneous, interval, start/endtime) |
| `/{db}/appointment/calendars` | GET | ✅ | Senarai semua kalendar |
| `/{db}/appointment/codes` | GET | ✅ | Code mappings |

### Patient

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/patient` | GET | ✅ | List semua patient |
| `/{db}/patient` | POST | ❌ | Daftar patient baru terus ke Plato |
| `/{db}/patient/{id}` | GET | ✅ | Profile by ID |
| `/{db}/patient/{id}` | PUT | ✅ | Update name, dob, address |
| `/{db}/patient/{id}` | DELETE | ❌ | Tak guna di mana-mana UI |
| `/{db}/search/patient` | GET | ✅ | By telephone |
| `/{db}/patient/merge` | POST | ❌ | Gabung dua rekod (perlu hantar "I understand that this action cannot be undone") |
| `/{db}/patient/{id}/graphing` | GET | ❌ | Data graf/vitals pesakit |
| `/{db}/patient/{id}/updatelink` | GET | ❌ | Generate pautan update kendiri |

### Clinical Notes

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/patient/{id}/note` | GET | ✅ | Klinikal notes/reports |
| `/{db}/letter` | GET | ✅ | Surat rujukan/klinikal |
| `/{db}/letter/count` | GET | ❌ | Jumlah surat |

### Facility

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/facility` | GET | ✅ | List facilities/providers |
| `/{db}/facility` | POST | ❌ | Tambah facility baru |

### Webhook (Real-time)

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/webhook` | GET/POST | ❌ | Daftar & senarai webhook |
| `/{db}/webhook/activate` | POST | ❌ | Aktifkan guna JWT token |

> Webhook boleh gantikan **polling** — Plato akan hantar event masa-nyata bila ada perubahan data (appointment baru, patient update, lab result). Kalau gagal 5x dalam 24 jam, Plato akan padamkan webhook auto.

### WhatsApp Communication

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/whatsapp/send` | POST | ❌ | Hantar mesej via Twilio template |
| `/{db}/whatsapp/list` | GET | ❌ | Sejarah mesej |

### Inventory / Stock

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/inventory` | GET/POST | ❌ | Item stok & harga |
| `/{db}/search/inventory` | GET | ❌ | Cari item by given_id/name |
| `/{db}/adjustment` | GET/POST | ❌ | Pelarasan stok |
| `/{db}/deliveryorder` | GET/POST | ❌ | Penerimaan stok dari pembekal |
| `/{db}/transfer` | GET/POST | ❌ | Pemindahan stok antara cawangan |
| `/{db}/supplier` | GET/POST | ❌ | Pangkalan data pembekal |
| `/{db}/purchaseorder` | GET/POST | ❌ | Pesanan pembelian |
| `/{db}/purchaserequisition` | GET/POST | ❌ | Permintaan pembelian dalaman |

### Lain-lain

| Endpoint | Method | Dalam App? | Notes |
|----------|--------|-----------|-------|
| `/{db}/contact` | GET/POST | ❌ | Kenalan luaran (dokor luar/pembekal) |
| `/{db}/corporate` | GET/POST | ❌ | Syarikat panel/korporat |
| `/{db}/search/corporate` | GET | ❌ | Cari corporate by name/given_id |
| `/{db}/expense` | GET/POST | ❌ | Perbelanjaan operasi |
| `/{db}/task` | GET/POST | ❌ | Tugasan klinikal/pentadbiran |
| `/{db}/systemsetup` | GET | ❌ | Setup sistem (guna utk cari calendar ID warna) |

### Rate Limiting & Pagination (Dari Docs Plato)

| Parameter | Detail |
|-----------|--------|
| Max records/req | **20** — setiap request hanya boleh ambil 20 rekod |
| Pagination | Guna `current_page` parameter — loop sampai response kosong |
| `modified_since` | Format UNIX timestamp — amalan terbaik untuk ambil data incremental je |
| Rate limit headers | `x-ratelimit-limit` (jumlah had), `x-ratelimit-remaining` (baki) |
| HTTP 429 | Too Many Requests — kena implement **exponential backoff** |
| Caching | Docs recommend centralized caching kalau ada multiple modules guna data sama |

> **Status app sekarang:** Langsung tak implement pagination atau rate limit handling.

---

## Architecture

### App State (`FFAppState`)

Singleton `ChangeNotifier` storing:
- Auth data: `userEmail`, `tokenauth`, `isLoggedIn` (persisted), `fcmtoken`
- Patient data: `idplato`, `givenid`, `name`, `phonefield`, `nationalman`
- Booking data: `timepick`, `Upcoming`, `Listcode`, `ListDoctorName`, `notifappointment`
- Biometric: `fingerprint`, `faceid`
- Misc: `coutnnotif`, `registerEmail`, `password`, `defaultprovider`

### Routing (GoRouter)

27 routes defined in `lib/flutter_flow/nav/nav.dart`:
- `'/` — Splash or NavBar (conditional on auth)
- Bottom Navigation: HomepageNew, BranchLocationNewCopy, BookingPage, ProfileCopy
- All other routes pushed on top of the nav stack

### Auth Flow

1. App starts → `initFirebase()` → `loadLoginData()` (custom action) → check `isLoggedIn` in SharedPreferences
2. `heClinicFirebaseUserStream()` listens to Firebase auth state
3. On login: `MedicalAppsApiGroup.loginCall()` → stores token in `FFAppState.tokenauth`
4. On register: `RegisterCall` (multipart) → auto-login
5. Biometric (fingerprint/faceid) supported via `local_auth` package

### Custom Code (16 actions)

`lib/custom_code/actions/`:
- `load_login_data.dart` — loads persisted login state from SharedPreferences
- `save_login_custom.dart` — saves credentials locally
- `logout.dart` — clears session
- `request_notification_permissions_user.dart` — FCM permissions
- `setup_f_c_m_foreground_handler.dart` — foreground push handler
- `load_biometric_status.dart` / `save_biometric_status.dart` — biometric toggle
- `show_local_notification.dart` — local notification display
- `date_to_unix_timestamp_seconds.dart`, `generate_password.dart`, etc.

---

## Project Structure

```
lib/
  main.dart                      # Entry point, MyApp, NavBarPage (4 tabs)
  index.dart                     # Export all 27 page widgets
  app_state.dart                 # FFAppState (global state singleton)

  auth/                          # Firebase Auth layer
    firebase_auth/
      auth_util.dart             # Auth stream, current user helpers
      firebase_user_provider.dart
      email_auth.dart
      google_auth.dart
      apple_auth.dart
      jwt_token_auth.dart
      github_auth.dart
      anonymous_auth.dart

  backend/                       # Data layer
    api_requests/
      api_manager.dart           # HTTP client (GET/POST/PUT/DELETE/MULTIPART)
      api_calls.dart             # All API endpoint definitions (1682 lines)
    firebase/
      firebase_config.dart       # Firebase init + web options
    cloud_functions/
      cloud_functions.dart
    push_notifications/
      push_notifications_util.dart
      push_notifications_handler.dart
      serialization_util.dart
    schema/                      # Firestore record models
      users_record.dart
      articles_record.dart
      patients_record.dart
      branch_record.dart
      biometric_record.dart
      fcm_record.dart
      historynotif_record.dart
      info_record.dart
      otps_record.dart
      videos_record.dart

  custom_code/
    actions/                     # 16 custom action files
    widgets/                     # 3 custom widgets (dropdownsearch, nationality, phonefield)

  flutter_flow/                  # FlutterFlow-generated framework
    flutter_flow_theme.dart      # Theme system (colors, typography)
    flutter_flow_util.dart       # Utility functions
    flutter_flow_widgets.dart    # FFButtonWidget etc.
    nav/nav.dart                 # GoRouter routes + AppStateNotifier
    flutter_flow_model.dart      # Base model class
    custom_functions.dart        # Custom Dart functions
    ...                          # (animations, calendar, dropdown, etc.)

  # --- Page Modules ---
  auth_page/                     # Login, Register, Onboarding
  booking_page/                  # Booking, My Booking, Select Date, Visits
  front_page/                    # Homepage, Profile, Reports, Biometric, Splash, etc.
  article_page/                  # Article listing + detail
  content_media/                 # Content/media page
  info_page/                     # Hemed Info pages
  service_package/               # Service packages
  telehealth/                    # All Doctors list
  on_boarding_new/               # Onboarding screen

  component/                     # 24 reusable modal dialogs (named per dev: Arif, Avenesh, etc.)
  components/                    # 3 shared widgets (confirm dialog, reference modal, tags)

firebase/
  firebase.json
  firestore.rules
  firestore.indexes.json
  storage.rules
  functions/
    index.js                     # Cloud Functions (3 functions)
    api_manager.js               # Private API proxy (currently empty callMap)
    package.json                 # Includes: axios, braintree, stripe, langchain deps

assets/
  images/                        # 60 images (app icons, IG posts, doctor images, onboarding, etc.)
  fonts/                         # Poppins-Regular.ttf
  videos/                        # (empty placeholders)
  audios/                        # (empty placeholders)
  pdfs/                          # (empty placeholders)
  rive_animations/               # (empty placeholders)
  jsons/                         # (empty placeholders)

web/
  index.html                     # PWA-enabled
  manifest.json                  # PWA manifest
  flutter_bootstrap.js
  favicon.png
  icons/                         # App icons for PWA
```

---

## Admin Panel (Laravel)

> **Location:** Separately hosted on VPS (not in this repo)
> **Stack:** Laravel + MySQL
> **Current Features:** Patient management, slider images, push notifications

### V1 vs V2

| Feature | V1 (Current) | V2 (Planned) |
|---------|-------------|--------------|
| Patient Management | ⚠️ Basic | ✅ Full CRM with Plato sync |
| Slider Images | ✅ | ✅ CMS: articles, videos, banners |
| Push Notification | ✅ Basic (all users) | ✅ Rich + targeted + scheduled |
| Appointment Management | ❌ | ✅ Calendar view, CRUD, slot mgmt |
| Invoice / Billing | ❌ | ✅ Create, items, finalize, payment |
| Queue Management | ❌ | ✅ Real-time queue board |
| Loyalty Points | ❌ | ✅ Points panel, campaigns, reports |
| WhatsApp Integration | ❌ | ✅ Send single/bulk via Twilio |
| Role-Based Access | ❌ | ✅ Super Admin, Branch Admin, Staff |
| Dashboard Analytics | ❌ | ✅ Revenue, appointments, trends |
| Reports & Export | ❌ | ✅ CSV/PDF reports |
| Plato API Proxy | ❌ | ✅ Token server-side, all calls proxied |

### Architecture

```
Mobile App (Flutter)
       │
       ▼ HTTPS (Bearer token per user)
Laravel Admin Panel (VPS)  ──►  Plato API (server-side token)
       │                              │
       ▼                              ▼
    MySQL (local)                Firebase (Firestore/FCM)
```

Rujuk `docs/v2-pitch-deck.md` untuk proposal lengkap upgrade admin panel.

---

## Mock API Server (Local Development)

Mock server untuk develop tanpa internet / depend pada production API. Letak dekat `mock_server/`.

### Setup

```bash
cd mock_server
npm install
npm start
# Server jalan di http://localhost:4000
```

### Credentials Mock

| Field | Value |
|-------|-------|
| Phone | `0123456789` |
| Password | `test123` (or anything) |

### Run Flutter App with Mock Server

```bash
# Mock mode (API panggil localhost:4000)
flutter run --dart-define=MEDICAL_APPS_URL=http://localhost:4000/api \
           --dart-define=PLATOM_URL=http://localhost:4000/platom \
           --dart-define=WORDPRESS_URL=http://localhost:4000/wp-json/wp/v2

# Production mode (default — real servers)
flutter run
```

### Mock Data Disediakan

| Data | Detail |
|------|--------|
| Patient Profile | Nama "Test User", NRIC "000101-01-0001" |
| Doctors | 3 doctors (Ahmad, Sarah, Lim) |
| Appointments | 3 mock appointments Jul 2025 |
| Articles | 3 health articles |
| Sliders | 3 slider images (placeholder) |
| Reports | 2 mock clinical notes |
| Letters | 1 medical certificate |
| Invoices | 2 invoices with items |
| Appointment Codes | 4 doctor codes + 3 location codes |

### Architecture

```
Flutter App → EnvConfig (lib/env_config.dart)
                   ↓
            dart-define vars
              ├─ production → real API servers
              └─ mock       → http://localhost:4000
                                ↓
                         mock_server/index.js
                           (Express server)
```

---

## Run Locally

### Prerequisites

```bash
# Already installed:
flutter --version   # Flutter 3.29.3 (Dart 3.7.2)
```

### Setup

```bash
# 1. Install Dart dependencies
flutter pub get

# 2. Choose mode:

# Production (real API servers)
flutter run

# Mock server (local)
# First, start mock server in another terminal:
cd mock_server && npm install && npm start
# Then run app with mock URLs:
flutter run --dart-define=MEDICAL_APPS_URL=http://localhost:4000/api \
           --dart-define=PLATOM_URL=http://localhost:4000/platom \
           --dart-define=WORDPRESS_URL=http://localhost:4000/wp-json/wp/v2

# 3. Run on specific platform
flutter run                    # auto-detect device
flutter run -d chrome          # web
flutter run -d ios             # iOS (requires Xcode)
flutter run -d android         # Android (requires emulator/device)
```

### For iOS

```bash
cd ios
pod install --repo-update     # install CocoaPods
cd ..
flutter run -d ios
```

### For Android

Open `android/` in Android Studio or just run:
```bash
flutter run -d android
```

### Web

```bash
flutter run -d chrome
```

---

## Known Issues & Notes for Upgrade

### 🔴 Critical

1. **Hardcoded API Token** — `api_calls.dart:586` uses a hardcoded Bearer token `1463d1150e7b199effa2793c2d809034` for all Platom endpoints. This is a **security risk** and should be moved to server-side or at minimum to environment variables.
2. **Firebase API Key exposed** — `firebase_config.dart:8` has the web API key in plaintext. This is normal for Firebase (it's meant to be public), but ensure proper Firestore security rules are enforced.
3. **minSdkVersion 35** (`android/app/build.gradle`) — Very high; most Android devices run lower. Consider lowering to 23-26 for wider device support.
4. **Hardcoded appointment ID** — `GetAppointmentDetailsCall` has a hardcoded appointment ID `a052e78b3a5547bba54ddbbc83619e93` in the URL.
5. **Flutter/Dart version mismatch** — Project requires Dart >=3.9.0 (`google_fonts`, `cross_file`), tapi Flutter 3.29.3 guna Dart 3.7.2. Sementara downgrade dah buat (`google_fonts: 6.2.1`, `cross_file: ^0.3.4`). Untuk长期, upgrade Flutter ke stable terbaru.

### ⚠️ Medium

5. **Multiple duplicate API classes** — `GetPatientbyidCall` and `GetPatientbyidCopyCall` are identical duplicates. Consider deduplication.
6. **Unused Firebase Functions deps** — `firebase/functions/package.json` includes `braintree`, `stripe`, `razorpay`, `@langchain/*`, `@onesignal` — likely unused. Can clean up.
7. **No error handling for API calls** — Many API calls lack proper try-catch or loading states in the UI.
8. **FlutterFlow `nav.dart` routing** — The `FFRoute` system wraps GoRouter with FlutterFlow-specific logic. For upgrades, consider migrating to standard GoRouter.
9. **`api_manager.js`** — The Firebase private API proxy has an empty `callMap`, making it non-functional. It's a dead code path.

### 🟢 Low

10. **FlutterFlow dependencies** — `dropdown_button2` and `webviewx_plus` are from FlutterFlow's GitHub forks. If upgrading to newer Flutter, may need to replace with community-maintained packages.
11. **Provider state management** — Current app uses Provider (simple `ChangeNotifier`). For scaling, consider Riverpod or Bloc.
12. **No tests** — Only 1 skeleton test file. Need proper unit/widget/integration tests.
13. **Multiple "Copy" pages** — Pages like `RegisterPageCopy`, `ProfileCopy`, `HemedInfoCopy`, `SelectDatecase`, etc. suggest duplicated variants. Audit and consolidate.

### 🔐 Security

- Firestore rules need review (only `firestore.rules` and `storage.rules` exist — ensure they're not wide-open)
- All Platom API calls use a **single static token** — any upgrade should implement per-user authentication with Platom

### 📋 New Findings (Plato API Docs Audit)

14. **URL pattern mismatch** — App guna `https://clinic.platomedical.com/api/hemedclinic/...` tapi docs rasmi guna `/{db}/...`. Verify endpoint mana yg aktif.
15. **No pagination** — Plato limit 20 records/req, kena guna `current_page`. App tak implement langsung — data besar akan silent fail.
16. **No `modified_since` usage** — Available untuk patient, note, letter endpoints tapi app tak guna. Boleh optimize data fetching.
17. **No rate limit handling** — App tak monitor `x-ratelimit` headers atau handle HTTP 429.
18. **Webhook opportunity** — Plato support webhook untuk real-time updates. Boleh gantikan polling.
19. **POST endpoints untapped** — Invoice create/finalize/pay, appointment create/slots, patient create, WhatsApp send — semua available tapi tak guna.

---

## Plato API Integration Details

> **Rujukan rasmi:** [`docs/api-guidelines.md`](api-guidelines.md) — Dokumentasi Platform Pembangun Plato.
> **Base URL (rasmi):** `/{db}/` (contoh: `/hemedclinic/patient`)
> **Base URL (app sekarang):** `https://clinic.platomedical.com/api/hemedclinic/...`

### Auth Flow

| Kaedah | Documentation | App Sekarang |
|--------|--------------|--------------|
| API Key | `Authorization: Bearer <API_KEY>` — generate kat System Setup > General Settings > API | Hardcoded token `1463d1150e7b199effa2793c2d809034` |
| Apps on Plato | Guna App ID + App Secret dalam manifest | Tak guna |

### Integration Flow

1. User register/login through **Medical Apps API** (`hemedicalapps.com/api`) → gets Plato patient ID (`idplato`)
2. Patient CRUD through **Plato API**:
   - Read: profile, notes, letters, invoices, appointments
   - Write: update profile (name, dob, address) via `PUT /{db}/patient/{id}`
3. Appointments fetched from Plato; creation goes through **Medical Apps API** (not direct to Plato)
4. Facility/doctor listing from `GET /{db}/facility`

### Recommended Enhancements (Ikut Docs)

| Priority | Feature | Plato Endpoint | Benefit |
|----------|---------|---------------|---------|
| 🔴 High | Slot availability check | `POST /{db}/appointment/slots` | User nampak slot kosong sebelum booking |
| 🔴 High | Fix appointment detail | `GET /{db}/appointment/{id}` | Gantikan hardcoded ID |
| 🟠 Medium | Create appointment direct | `POST /{db}/appointment` | Bypass Medical Apps API untuk booking |
| 🟠 Medium | Invoice workflow | `POST /{db}/invoice` → `/items` → `/finalize` → `/payment` | Queue management & payment dalam app |
| 🟠 Medium | WhatsApp notifications | `POST /{db}/whatsapp/send` | Appointment reminders |
| 🟢 Low | Webhook integration | `POST /{db}/webhook` | Real-time updates (ganti polling) |
| 🟢 Low | Patient vitals graph | `GET /{db}/patient/{id}/graphing` | Papar trend kesihatan |
| 🟢 Low | Self-update link | `GET /{db}/patient/{id}/updatelink` | Patient update sendiri
