# CODEBASE.md — He Clinic Mobile App

> **Tujuan dokumen ini:** Rujukan lengkap untuk AI (LLM/Coding Assistant) memahami keseluruhan codebase project ini.
> **Last Updated:** July 2026
> **Sumber audit:** `lib/`, `firebase/`, `mock_server/`, `pubspec.yaml`, `docs/api-guidelines.md`, `docs/v2-pitch-deck.md`

---

## 1. OVERVIEW PROJECT

### Ringkasan
He Clinic Mobile App adalah aplikasi Flutter untuk klinik swasta **He Clinic** (HeMed Group). App ini membolehkan patient untuk login, lihat profil, buat temujanji, baca laporan perubatan, dan terima push notifications. App dibina menggunakan **FlutterFlow** (code-generated) dan kemudiannya diedit secara manual.

### Identiti Projek

| Field | Value |
|-------|-------|
| **Nama Package** | `he_clinic` |
| **App Version** | `0.3.7+37` |
| **Flutter Version** | `3.29.3` |
| **Dart SDK** | `>=3.0.0 <4.0.0` |
| **Android Package** | `com.hemedgroup.heclinicapps` |
| **iOS Bundle ID** | `com.hemedgroup.heclinicapps` |
| **Firebase Project** | `heclinicapps-8be27` |
| **Asal Kod** | FlutterFlow-generated + manual edits |

---

## 2. TECH STACK

| Layer | Teknologi | Versi |
|-------|-----------|-------|
| **Framework** | Flutter | 3.29.3 |
| **Language** | Dart | >=3.0.0 |
| **State Management** | Provider (`ChangeNotifier`) | 6.1.5 |
| **Routing** | GoRouter | 12.1.3 |
| **Auth** | Firebase Auth (Email, Google, Apple, Anonymous, JWT, Phone, GitHub) | 5.6.0 |
| **Database (Cloud)** | Cloud Firestore | 5.6.9 |
| **Push Notifications** | Firebase Cloud Messaging | 15.2.7 |
| **Cloud Functions** | Firebase Functions (Node 20) | — |
| **Local Storage** | SharedPreferences + sqflite | 2.5.3 |
| **Biometric** | local_auth | 2.3.0 |
| **HTTP Client** | http | 1.4.0 |
| **Animations** | flutter_animate | 4.5.0 |
| **Image Cache** | cached_network_image | 3.4.1 |
| **Calendar UI** | table_calendar | 3.2.0 |
| **PDF/Web** | webview_flutter | 4.13.0 |

---

## 3. STRUKTUR DIREKTORI

```
heclinic_mobile-main/
├── lib/                          # Dart source code utama
│   ├── main.dart                 # Entry point — MyApp, NavBarPage (4 tabs)
│   ├── index.dart                # Export semua 27 page widgets
│   ├── app_state.dart            # FFAppState — global state singleton
│   ├── env_config.dart           # URL configuration via dart-define
│   │
│   ├── auth/                     # Firebase Auth layer
│   │   └── firebase_auth/
│   │       ├── auth_util.dart    # Auth stream, currentUser helpers
│   │       ├── firebase_user_provider.dart
│   │       ├── email_auth.dart
│   │       ├── google_auth.dart
│   │       ├── apple_auth.dart
│   │       ├── jwt_token_auth.dart
│   │       ├── github_auth.dart
│   │       └── anonymous_auth.dart
│   │
│   ├── backend/                  # Data layer
│   │   ├── backend.dart          # Export semua backend modules
│   │   ├── api_requests/
│   │   │   ├── api_manager.dart  # HTTP client (GET/POST/PUT/DELETE/MULTIPART)
│   │   │   └── api_calls.dart    # Semua API endpoint definitions (~1682 lines)
│   │   ├── firebase/
│   │   │   └── firebase_config.dart
│   │   ├── cloud_functions/
│   │   │   └── cloud_functions.dart
│   │   ├── push_notifications/
│   │   │   ├── push_notifications_util.dart
│   │   │   ├── push_notifications_handler.dart
│   │   │   └── serialization_util.dart
│   │   └── schema/               # Firestore record models (Dart classes)
│   │       ├── users_record.dart
│   │       ├── articles_record.dart
│   │       ├── patients_record.dart
│   │       ├── branch_record.dart
│   │       ├── biometric_record.dart
│   │       ├── fcm_record.dart
│   │       ├── historynotif_record.dart
│   │       ├── info_record.dart
│   │       ├── otps_record.dart
│   │       └── videos_record.dart
│   │
│   ├── custom_code/
│   │   ├── actions/              # 15 custom Dart action files
│   │   └── widgets/              # 3 custom widget files
│   │
│   ├── flutter_flow/             # FlutterFlow-generated framework utilities
│   │   ├── flutter_flow_theme.dart     # Theme: warna, typography
│   │   ├── flutter_flow_util.dart      # Helper functions
│   │   ├── flutter_flow_widgets.dart   # FFButtonWidget etc.
│   │   ├── nav/nav.dart                # GoRouter routes + AppStateNotifier
│   │   ├── flutter_flow_model.dart     # Base model class untuk semua pages
│   │   └── custom_functions.dart       # Custom Dart utility functions
│   │
│   ├── auth_page/               # Halaman auth
│   │   ├── login_page/
│   │   ├── register_page/
│   │   ├── register_page_copy/  # ISSUE: Duplikasi
│   │   └── on_boarding/
│   │
│   ├── booking_page/            # Halaman booking
│   │   ├── booking_page/
│   │   ├── booking_pagecasse/   # ISSUE: Duplikasi variant
│   │   ├── my_booking_page/
│   │   ├── select_date/
│   │   ├── select_date_reshecedule/  # ISSUE: Typo "reshecedule"
│   │   ├── select_datecase/     # ISSUE: Duplikasi variant
│   │   └── visits/
│   │
│   ├── front_page/              # Halaman utama
│   │   ├── homepage_new/
│   │   ├── profile/
│   │   ├── profile_copy/        # ISSUE: Duplikasi
│   │   ├── profile_edit_page/
│   │   ├── reports/
│   │   ├── splash_screen/
│   │   ├── biometric_setup_page/
│   │   ├── branch_location_new_copy/
│   │   ├── change_password/
│   │   ├── forgot_password/
│   │   ├── notification_page/
│   │   └── test_page/           # ISSUE: Test page dalam production code
│   │
│   ├── article_page/            # Artikel dari WordPress API
│   ├── content_media/           # Media content page
│   ├── info_page/               # Info/about klinik
│   ├── service_package/         # Service packages (gambar statik)
│   ├── telehealth/              # Senarai doktor (17 modal hardcoded)
│   ├── on_boarding_new/         # Onboarding screens baru
│   │
│   ├── component/               # 24 modal dialog components
│   │   ├── alert_report/
│   │   ├── branch_component/
│   │   ├── doctor_component/
│   │   ├── hemed_loader/
│   │   ├── material_card1/
│   │   ├── modal_arif/          # ISSUE: Satu modal per doktor — extreme duplication
│   │   ├── modal_avenesh/
│   │   ├── modal_chong/
│   │   ├── modal_danial/
│   │   ├── modal_doctor/
│   │   ├── modal_farhan/
│   │   ├── modal_fauzi/
│   │   ├── modal_gavin/
│   │   ├── modal_haekal/
│   │   ├── modal_haziq/
│   │   ├── modal_khairul/
│   │   ├── modal_liew/
│   │   ├── modal_lim/
│   │   ├── modal_syakeer/
│   │   ├── modal_tong/
│   │   ├── modal_victor/
│   │   ├── modal_wong/
│   │   ├── notification_dropdown/
│   │   └── notification_setting/
│   │
│   └── components/              # 3 shared generic widgets
│
├── firebase/
│   ├── firebase.json
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   ├── storage.rules
│   └── functions/
│       ├── index.js             # Cloud Functions (3 functions)
│       ├── api_manager.js       # Private API proxy — KOSONG (dead code)
│       └── package.json         # Deps: axios, braintree, stripe, langchain (kebanyakan unused)
│
├── mock_server/
│   ├── index.js                 # Express mock server (port 4000)
│   └── package.json
│
├── assets/
│   ├── images/                  # ~60 images (app icons, doctors, onboarding, IG posts)
│   ├── fonts/                   # Poppins-Regular.ttf
│   ├── videos/                  # (kosong)
│   ├── audios/                  # (kosong)
│   ├── pdfs/                    # (kosong)
│   ├── rive_animations/         # (kosong)
│   └── jsons/                   # (kosong)
│
├── docs/
│   ├── CODEBASE.md              # Dokumen ini — audit lengkap
│   ├── PROJECT.md               # Technical audit dokumen asal
│   ├── api-guidelines.md        # Plato API official documentation (BM)
│   └── v2-pitch-deck.md         # Proposal upgrade V2
│
└── pubspec.yaml
```

---

## 4. GLOBAL APP STATE (`FFAppState`)

**File:** `lib/app_state.dart`
**Pattern:** Singleton `ChangeNotifier` (Provider pattern)

```dart
// Cara akses state dalam widget:
context.read<FFAppState>().tokenauth

// Cara update state:
FFAppState().update(() {
  FFAppState().tokenauth = 'new_token';
});
```

### State Variables

| Variable | Type | Persisted? | Keterangan |
|----------|------|-----------|------------|
| `userEmail` | String | No | Email user semasa login |
| `isLoggedIn` | bool | **Yes** (SharedPrefs key: `ff_isLoggedIn`) | Status login |
| `registerEmail` | String | No | Email semasa proses register |
| `username` | String | No | Nama user |
| `password` | String | No | Password disimpan in-memory sementara |
| `tokenauth` | String | No | Bearer token dari Medical Apps API |
| `fcmtoken` | String | No | Firebase Cloud Messaging device token |
| `timepick` | String | No | Masa yang dipilih untuk booking |
| `Upcoming` | String | No | Upcoming appointment data string |
| `notifappointment` | bool | No | Toggle notifikasi appointment |
| `idplato` | String | No | Patient ID dalam sistem Plato |
| `givenid` | String | No | Patient "given ID" dari Plato |
| `name` | String | No | Nama penuh patient |
| `phonefield` | String | No | Nombor telefon patient |
| `nationalman` | String | No | Nationaliti/IC patient |
| `coutnnotif` | String | No | Bilangan notifikasi belum baca (typo: "coutn") |
| `Listcode` | List\<String\> | No | Senarai appointment color codes |
| `ListDoctorName` | List\<String\> | No | Senarai nama doktor |
| `fingerprint` | bool | No | Biometric fingerprint enabled |
| `faceid` | bool | No | Biometric face ID enabled |
| `passwordChanged` | bool | No | Flag perubahan password |
| `defaultprovider` | List\<String\> | No | Default provider/facility IDs |

> **Nota untuk AI:** `isLoggedIn` satu-satunya state yang persisted. Semua state lain hilang bila app restart — data perlu diload semula dari API atau SharedPreferences melalui custom actions.

---

## 5. ENVIRONMENT CONFIGURATION

**File:** `lib/env_config.dart`

```dart
class EnvConfig {
  // Medical Apps API URL
  static const String medicalAppsBaseUrl = String.fromEnvironment(
    'MEDICAL_APPS_URL',
    defaultValue: 'https://hemedicalapps.com/api',
  );

  // Plato Medical Clinic API URL
  static const String platomBaseUrl = String.fromEnvironment(
    'PLATOM_URL',
    defaultValue: 'https://clinic.platomedical.com/api/hemedclinic',
  );

  // WordPress Blog API URL
  static const String wordpressBaseUrl = String.fromEnvironment(
    'WORDPRESS_URL',
    defaultValue: 'https://hemedicalclinic.com/wp-json/wp/v2',
  );

  // True jika running dalam mock mode
  static bool get isMock =>
      medicalAppsBaseUrl.contains('localhost') ||
      medicalAppsBaseUrl.contains('127.0.0.1');
}
```

### Run Commands

```bash
# Production (guna URL sebenar)
flutter run

# Mock mode (guna local mock server — port 4000)
flutter run --dart-define=MEDICAL_APPS_URL=http://localhost:4000/api \
            --dart-define=PLATOM_URL=http://localhost:4000/platom \
            --dart-define=WORDPRESS_URL=http://localhost:4000/wp-json/wp/v2
```

---

## 6. ROUTING (GoRouter)

**File:** `lib/flutter_flow/nav/nav.dart`
Total: 27 routes. Navigation menggunakan `GoRouter` dibungkus dengan FlutterFlow's `FFRoute` wrapper.

### Bottom Navigation (4 Tabs)

| Tab Index | Page | Route Path |
|-----------|------|------------|
| 0 | HomepageNew | `/` atau `/homepageNew` |
| 1 | BranchLocationNewCopy | `/branchLocationNewCopy` |
| 2 | BookingPage | `/bookingPage` |
| 3 | ProfileCopy | `/profileCopy` |

### Auth Routes

| Route | Page | Syarat |
|-------|------|--------|
| `/` | SplashScreen atau NavBarPage | Redirect ikut `isLoggedIn` |
| `/loginPage` | LoginPage | Public |
| `/registerPage` | RegisterPage | Public |
| `/onBoarding` | OnBoarding | Public |

### Feature Routes (Protected)

| Route | Page | Description |
|-------|------|-------------|
| `/profile` | Profile | Profil penuh |
| `/profileEditPage` | ProfileEditPage | Edit profil |
| `/reports` | Reports | Laporan perubatan (3 tabs) |
| `/myBookingPage` | MyBookingPage | Senarai temujanji |
| `/selectDate` | SelectDate | Pilih tarikh booking |
| `/visits` | Visits | Sejarah lawatan |
| `/notificationPage` | NotificationPage | Senarai notifikasi |
| `/articlePage` | ArticlePage | Artikel kesihatan |
| `/servicePackage` | ServicePackage | Package perkhidmatan |
| `/hemedInfo` | HemedInfo | Info klinik |
| `/biometricSetupPage` | BiometricSetupPage | Setup biometrik |
| `/changePassword` | ChangePassword | Tukar kata laluan |
| `/forgotPassword` | ForgotPassword | Lupa kata laluan |

---

## 7. AUTH FLOW (Lengkap)

### Flow Diagram

```
App Start
    |
    v
initFirebase() --> loadLoginData() [custom action]
                        |
                        v
                  SharedPreferences
                  isLoggedIn == true?
                        |
              Yes ------+------ No
              |                  |
              v                  v
         NavBarPage         SplashScreen
         (HomepageNew)      --> LoginPage

Selepas Login:
    |
    v
LoginCall(email, password) --> Medical Apps API POST /login
    |
    v
Response: { token, idplato, givenid, ... }
    |
    v
FFAppState().tokenauth = token
FFAppState().idplato = idplato
saveLoginCustom() [custom action --> SharedPreferences]
    |
    v
Navigate to HomepageNew
```

### Auth Methods

| Method | Status | Package |
|--------|--------|---------|
| Email + Password | Primary | `firebase_auth` |
| Google Sign-In | Available | `google_sign_in` |
| Apple Sign-In | Available | `sign_in_with_apple` |
| Anonymous | Available | `firebase_auth` |
| JWT Token | Available | Custom |
| Phone (OTP) | Available | `firebase_auth` |
| GitHub | Available | `firebase_auth` |

### Biometric Auth

```
Selepas login biasa:
1. User toggle fingerprint/faceid dalam BiometricSetupPage
2. saveBiometricStatus() simpan ke Firestore collection "biometric"
3. Pada login seterusnya:
   loadBiometricStatus() --> check fingerprint/faceid
   local_auth.authenticate() --> verifikasi biometrik
   Jika berjaya --> skip password entry
```

---

## 8. FIREBASE SETUP

### Project Details

| Field | Value |
|-------|-------|
| **Project ID** | `heclinicapps-8be27` |
| **Android Package** | `com.hemedgroup.heclinicapps` |
| **iOS Bundle ID** | `com.hemedgroup.heclinicapps` |
| **Web API Key** | Ada dalam `firebase_config.dart` (public, selamat untuk Firebase) |

### Firestore Collections

| Collection | Purpose | Key Fields |
|------------|---------|------------|
| `users` | Firebase Auth users | uid, email, displayName |
| `patients` | Patient records (mirror dari Plato) | idplato, givenid, name, phone |
| `articles` | Static article content | title, content, imageUrl |
| `videos` | Video content | title, videoUrl |
| `branch` | Cawangan klinik | name, address, hours, location |
| `otps` | OTP codes untuk verify | code, expiry, phone |
| `fcm_tokens` | FCM tokens (subcollection dalam users) | fcm_token, device_type |
| `historynotif` | Notification history per user | title, body, timestamp |
| `biometric` | Biometric settings | fingerprint, faceid, uid |
| `info` | Info klinik umum | — |
| `ff_push_notifications` | Push notification queue (trigger Cloud Function) | title, body, user_refs, target_audience |

### Cloud Functions

**File:** `firebase/functions/index.js`
**Runtime:** Node.js 20

#### `addFcmToken` — HTTPS Callable
```
Tujuan: Daftar FCM token device untuk user
Input:  { userDocPath: string, fcmToken: string, deviceType: string }
Logic:
  1. Validate auth (reject unauthenticated)
  2. Validate args tidak kosong
  3. Pastikan auth.uid === userDocPath.split("/")[1]
  4. Check duplicate token merentas semua users
  5. Simpan token ke users/{uid}/fcm_tokens/{auto-id}
Output: String status message
```

#### `sendPushNotificationsTrigger` — Firestore Trigger
```
Trigger: ff_push_notifications/{id} onCreate
Config:  Memory 2GB, Timeout 540s

Logic:
  1. Skip jika ada scheduled_time (bukan immediate)
  2. Baca: title, body, image, targetAudience, userRefs
  3. Kumpul FCM tokens:
     - Jika userRefs ada: ambil tokens dari users tertentu sahaja
     - Jika tiada: ambil semua tokens (boleh batch untuk banyak user)
  4. Batch tokens kepada 500 setiap request
  5. sendEachForMulticast() hantar ke FCM
  6. Update document: status = "succeeded" | "failed"
```

#### `onUserDeleted` — Auth Trigger (INCOMPLETE)
```
Trigger: Firebase Auth user.onDelete
Status:  INCOMPLETE — hanya define userRef, tiada cleanup code
Perlu:   Delete user Firestore documents, FCM tokens, dll.
```

---

## 9. API ARCHITECTURE — OVERVIEW

```
Flutter App
     |
     +--[1]--> Medical Apps API  (hemedicalapps.com/api)
     |          Auth: Bearer token (per-user, dari login)
     |
     +--[2]--> Plato API         (clinic.platomedical.com/api/hemedclinic)
     |          Auth: Hardcoded token — SECURITY RISK
     |
     +--[3]--> WordPress API     (hemedicalclinic.com/wp-json/wp/v2)
                Auth: Tiada (public read)
```

**HTTP Client file:** `lib/backend/api_requests/api_manager.dart`
- Support: GET, POST, PUT, DELETE, MULTIPART
- Tiada global error handling atau retry logic

**API Definitions file:** `lib/backend/api_requests/api_calls.dart` (~1682 lines)
- Semua endpoint classes dan groups ada dalam fail ini
- Setiap endpoint ada static `call()` method yang return `ApiCallResponse`

---

## 10. API — MEDICAL APPS API

**Base URL:** `EnvConfig.medicalAppsBaseUrl` → default `https://hemedicalapps.com/api`
**Auth:** `Authorization: Bearer {FFAppState().tokenauth}` (token per-user dari login)
**Group Class:** `MedicalAppsApiGroup`

| Method | Endpoint | Call Class | Description |
|--------|----------|------------|-------------|
| POST | `/login` | `LoginCall` | Login — returns token + patient data |
| POST | `/register` | `RegisterCall` | Daftar patient baru (multipart form) |
| GET | `/profile` | `ProfileCall` | Profil user (requires auth token) |
| GET | `/logout` | `LogoutCall` | Logout |
| POST | `/forgot-password` | `RequestForgotPasswordCall` | Request reset code |
| POST | `/verify-reset-code` | `VerifyResetCodeCall` | Verify OTP/reset code |
| POST | `/change-password` | `ChangepasswordCall` | Tukar password |
| POST | `/change-password-first` | `FirsttimechangepasswordCall` | Tukar password kali pertama |
| POST | `/changePasswordforgot` | `ForgotchangeCall` | Reset password melalui forgot flow |
| GET | `/sliders` | `SlidersCall` | Gambar slider homepage |
| GET | `/servicepackages` | `ServicesPackagesCall` | Senarai service packages |
| POST | `/appointments` | `CreateAppointmentCall` | Cipta temujanji (via Medical Apps, bukan Plato) |
| POST | `/update` | `UpdateProfilCall` | Update profil (multipart) |
| GET | `/pdfs` | `GetMedicalCertificateCall` | Senarai sijil perubatan |

### Register Payload (Multipart)
Fields: `email`, `tel`, `name`, `nric`, `dob`, `allergies`, `doctor_list`, dan lain-lain.

---

## 11. API — PLATO API

**Base URL:** `EnvConfig.platomBaseUrl` → default `https://clinic.platomedical.com/api/hemedclinic`
**Auth:** Hardcoded token `1463d1150e7b199effa2793c2d809034` — **CRITICAL SECURITY RISK**
**Docs rasmi:** `docs/api-guidelines.md`
**Group Class:** `PlatomeApiGroup`

> **Nota:** Plato docs guna `/{db}/...` pattern. App guna `hemedclinic` sebagai `{db}`.

### Status Legend
- OK = Diimplementasi dan berfungsi
- BROKEN = Ada call class tapi ada bug/broken
- MISSING = Belum diimplementasi (endpoint ada dalam Plato)
- DUPLICATE = Duplikasi call class yang identik

### Patient

| Method | Endpoint | Call Class | Status | Issue |
|--------|----------|------------|--------|-------|
| GET | `/patient` | `GetPatientCall` | OK | — |
| GET | `/patient/{id}` | `GetPatientbyidCall` | OK | — |
| GET | `/patient/{id}` | `GetPatientbyidCopyCall` | DUPLICATE | Identik dengan `GetPatientbyidCall` |
| PUT | `/patient/{id}` | `EditPatiendCall` | OK | Typo: "Patiend" |
| DELETE | `/patient/{id}` | `DeletePatientForAdminOnlyCall` | MISSING | Class ada, tiada UI |
| GET | `/search/patient` | `CeknumberphoneCall` | OK | Search by phone |
| POST | `/patient` | — | MISSING | Daftar patient direct ke Plato |
| POST | `/patient/merge` | — | MISSING | Merge dua rekod |
| GET | `/patient/{id}/graphing` | — | MISSING | Data vitals/graf |
| GET | `/patient/{id}/updatelink` | — | MISSING | Self-update link |
| GET | `/patient/{id}/note` | `GetReportCall` | OK | Clinical notes |

### Appointment

| Method | Endpoint | Call Class | Status | Issue |
|--------|----------|------------|--------|-------|
| GET | `/appointment` | `GetAppointmentCall` | OK | — |
| GET | `/appointment` | `GetAppointmentUpcomingCall` | OK | — |
| GET | `/appointment/{id}` | `GetAppointmentDetailsCall` | BROKEN | **ID hardcoded** `a052e78b...` |
| GET | `/appointment/calendars` | `GetAppointmentCopyCall` | OK | Nama class confusing |
| GET | `/appointment/codes` | `GetAppointmentCodeCall` | OK | — |
| POST | `/appointment` | — | MISSING | Cipta temujanji direct |
| POST | `/appointment/slots` | — | MISSING | Check slot tersedia |

### Invoice / Queue

| Method | Endpoint | Call Class | Status | Issue |
|--------|----------|------------|--------|-------|
| GET | `/invoice` | `LetterCopyCall` | OK | **Nama class salah** (bukan letter) |
| POST | `/invoice` | — | MISSING | Cipta invois + queue |
| PUT | `/invoice/{id}` | — | MISSING | Update invois |
| POST | `/invoice/items` | — | MISSING | Tambah item bil |
| POST | `/invoice/finalize` | — | MISSING | Finalize invois |
| POST | `/invoice/payment` | — | MISSING | Record bayaran |
| GET | `/queue/status` | — | MISSING | Status giliran |
| POST | `/queue/status` | — | MISSING | Update status giliran |

### Letter / Clinical

| Method | Endpoint | Call Class | Status |
|--------|----------|------------|--------|
| GET | `/letter` | `LetterCall` | OK |
| GET | `/letter/count` | — | MISSING |

### Facility

| Method | Endpoint | Call Class | Status |
|--------|----------|------------|--------|
| GET | `/facility` | `GetproviderCall` | OK |
| POST | `/facility` | — | MISSING |

### Semua Endpoint Belum Diimplementasi

| Category | Endpoints |
|----------|-----------|
| **Payment** | `GET /payment` |
| **WhatsApp** | `POST /whatsapp/send`, `GET /whatsapp/list` |
| **Webhook** | `GET/POST /webhook`, `POST /webhook/activate` |
| **Inventory** | `GET/POST /inventory`, `GET /search/inventory` |
| **Stock** | `GET/POST /adjustment`, `GET/POST /deliveryorder`, `GET/POST /transfer` |
| **Procurement** | `GET/POST /supplier`, `GET/POST /purchaseorder`, `GET/POST /purchaserequisition` |
| **Admin** | `GET/POST /contact`, `GET/POST /corporate`, `GET /search/corporate` |
| **Operations** | `GET/POST /expense`, `GET/POST /task` |
| **Config** | `GET /systemsetup` |

---

## 12. API — WORDPRESS (Articles)

**Base URL:** `EnvConfig.wordpressBaseUrl` → default `https://hemedicalclinic.com/wp-json/wp/v2`
**Auth:** Tiada (public REST API)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/posts?per_page=10` | 10 artikel terbaru (title, excerpt, content, featured image) |

---

## 13. PLATO API — RATE LIMITING & PAGINATION

> **Docs penuh:** `docs/api-guidelines.md` — Bahagian 3.

| Rule | Detail |
|------|--------|
| Max records per request | **20 rekod** sahaja |
| Pagination | Guna `?current_page=N` parameter, loop sampai response kosong |
| Rate limit header | `x-ratelimit-limit` = had, `x-ratelimit-remaining` = baki |
| HTTP 429 | Too Many Requests — wajib implement exponential backoff |
| `modified_since` | UNIX timestamp filter — ambil data berubah sahaja (incremental) |
| Caching | Recommend centralized cache untuk data dikongsi banyak modul |

> **STATUS APP SEKARANG:** Pagination, rate limiting, dan `modified_since` TIDAK diimplementasi.
> Data melebihi 20 rekod akan **silent truncate** tanpa error.

---

## 14. PLATO API — INVOICE/QUEUE FLOW

> **Rujuk:** `docs/api-guidelines.md` — Bahagian 4.
> Dalam Plato, Invoice = Queue. Bila patient masuk queue, invois dicipta auto.

```
Step 1: POST /invoice
        --> Cipta draf invois + entri giliran
        --> Boleh include item dan payment dalam step ini (optional)

Step 2: POST /invoice/items
        --> Tambah ubat/prosedur dari Inventory
        --> Field "given_id" mesti match dengan Inventory Setup

Step 3: POST /invoice/finalize
        --> Muktamadkan invois
        --> Selepas finalize, invois TIDAK boleh diedit lagi

Step 4: POST /invoice/payment
        --> Record pembayaran
        --> Selepas payment, invois DIKUNCI

Step 5: POST /queue/status
        --> Update status: "Dalam Rawatan" / "Selesai"
```

---

## 15. PLATO API — APPOINTMENT BOOKING FLOW

```
Step 1: GET /appointment/calendars
        --> Dapatkan semua kalendar yang ada
        --> Setiap kalendar ada "color" ID (calendar identifier)

Step 2: GET /systemsetup (belum implement)
        --> Dapatkan valid calendar colors

Step 3: POST /appointment/slots
        --> Check slot kosong
        --> Required: month, check_for_conflicts[], simultaneous,
                      interval, starttime, endtime
        --> "month" mesti bulan masa hadapan

Step 4: POST /appointment
        --> Cipta temujanji dengan color (calendar ID)
```

---

## 16. PLATO API — WEBHOOK SETUP

> **Rujuk:** `docs/api-guidelines.md` — Bahagian 6.
> Webhook = real-time event notification bila data berubah dalam Plato.

```
Step 1: POST /{db}/webhook
        --> Hantar: URL HTTPS endpoint anda + list events yang dilanggan
        --> Events: patient:upsert, appointment:upsert, invoice:upsert, dll.

Step 2: Terima webhook:token event
        --> Plato hantar JWT token ke URL anda
        --> Simpan token ini

Step 3: POST /{db}/webhook/activate
        --> Hantar JWT token untuk activate webhook
        --> Selepas activate, Plato akan hantar events secara real-time
```

**Webhook Payload Structure:**
```json
{
  "db": "hemedclinic",
  "event": "patient:upsert",
  "on": 1720000000,
  "object_type": "patient",
  "object_id": "uuid-here"
}
```

**PERINGATAN:**
- Endpoint perlu respond HTTP 200 dalam **3 saat**
- Jika gagal **5 kali dalam 24 jam**, webhook auto-deleted
- Max **5 webhook per database**

---

## 17. CUSTOM ACTIONS

**Directory:** `lib/custom_code/actions/`

| File | Function | Tujuan |
|------|----------|--------|
| `load_login_data.dart` | `loadLoginData()` | Load persisted login state dari SharedPreferences |
| `save_login_custom.dart` | `saveLoginCustom()` | Simpan credentials ke SharedPreferences |
| `logout.dart` | `logout()` | Clear semua session (FFAppState reset + SharedPrefs) |
| `request_notification_permissions_user.dart` | `requestNotificationPermissionsUser()` | Request FCM permissions dari OS |
| `setup_f_c_m_foreground_handler.dart` | `setupFCMForegroundHandler()` | Handle push notification saat app dalam foreground |
| `get_f_c_m.dart` | `getFCM()` | Ambil FCM token dari device |
| `load_biometric_status.dart` | `loadBiometricStatus()` | Load biometric settings dari Firestore |
| `save_biometric_status.dart` | `saveBiometricStatus()` | Simpan biometric toggle ke Firestore |
| `show_local_notification.dart` | `showLocalNotification()` | Display local notification (foreground) |
| `date_to_unix_timestamp_seconds.dart` | `dateToUnixTimestampSeconds()` | Convert DateTime ke UNIX timestamp |
| `generate_password.dart` | `generatePassword()` | Generate random password string |
| `convert_image_files_to_base64_list.dart` | `convertImageFilesToBase64List()` | Convert image files ke Base64 list |
| `hidestatusbar.dart` | `hideStatusBar()` | Hide device status bar |
| `printanything.dart` | `printAnything()` | Debug print utility |

### Custom Widgets (`lib/custom_code/widgets/`)

| Widget | Tujuan |
|--------|--------|
| `dropdownsearch` | Searchable dropdown dengan search field |
| `nationality` | Picker untuk pilih nationaliti |
| `phonefield` | Input telefon dengan country code selector |

---

## 18. MOCK SERVER

**Directory:** `mock_server/`
**Framework:** Express.js (Node.js)
**Port:** `4000`

### Setup

```bash
cd mock_server
npm install
npm start
# Server berjalan di http://localhost:4000
```

### Mock Credentials

| Field | Value |
|-------|-------|
| Phone | `0123456789` |
| Password | Apa-apa value (dummy validation) |

### Mock Data Available

| Data | Details |
|------|---------|
| Patient Profile | Nama "Test User", NRIC "000101-01-0001" |
| Doctors | 3 doctors: Ahmad, Sarah, Lim |
| Appointments | 3 mock appointments (Jul 2025) |
| Articles | 3 health articles |
| Sliders | 3 slider images (placeholder URL) |
| Reports/Notes | 2 mock clinical notes |
| Letters | 1 medical certificate |
| Invoices | 2 invoices dengan items |
| Appointment Codes | 4 doctor codes + 3 location codes |

### Mock API Routes

```
POST  /api/login
GET   /api/profile
POST  /api/register
GET   /platom/patient
GET   /platom/patient/:id
GET   /platom/patient/:id/note
GET   /platom/appointment
GET   /platom/appointment/calendars
GET   /platom/appointment/codes
GET   /platom/letter
GET   /platom/invoice
GET   /platom/facility
GET   /platom/search/patient
GET   /wp-json/wp/v2/posts
```

---

## 19. KNOWN ISSUES & BUGS

### CRITICAL (Security & Breaking)

| # | Issue | File | Detail |
|---|-------|------|--------|
| 1 | **Hardcoded Plato API Token** | `api_calls.dart` line ~586 | Token `1463d1150e7b199effa2793c2d809034` dalam source code. Sesiapa decompile APK boleh akses semua data Plato. Perlu pindah ke server-side. |
| 2 | **Hardcoded Appointment ID** | `GetAppointmentDetailsCall` | ID `a052e78b3a5547bba54ddbbc83619e93` hardcoded dalam URL. Endpoint tidak berfungsi untuk mana-mana appointment lain. |
| 3 | **minSdkVersion terlalu tinggi** | `android/app/build.gradle` | `minSdkVersion 35` — majoriti Android devices guna API 23-33. Perlu turunkan ke 23 untuk coverage lebih luas. |
| 4 | **Tiada pagination** | `api_calls.dart` | Plato limit 20 rekod/request. App tidak implement `current_page`. Data > 20 rekod silent truncate. |
| 5 | **Tiada rate limit handling** | `api_calls.dart` | Tiada monitor `x-ratelimit` headers. Tiada handle HTTP 429. Boleh kena blacklist oleh Plato. |

### MEDIUM (Functionality)

| # | Issue | File | Detail |
|---|-------|------|--------|
| 6 | **Duplicate API Class** | `api_calls.dart` | `GetPatientbyidCall` dan `GetPatientbyidCopyCall` adalah identik. Menyebabkan kekeliruan. |
| 7 | **Misnamed API Class** | `api_calls.dart` | `LetterCopyCall` sebenarnya call ke `/invoice`, bukan `/letter`. Confusing untuk developer. |
| 8 | **Tiada error handling** | Kebanyakan pages | API calls tiada try-catch. Bila API gagal, loading animation jalan selamanya. |
| 9 | **`api_manager.js` dead code** | `firebase/functions/api_manager.js` | File ada tapi `callMap` kosong — tidak berfungsi. |
| 10 | **`onUserDeleted` incomplete** | `firebase/functions/index.js` | Cloud function ada tapi tiada cleanup code. |
| 11 | **Password stored in-memory** | `app_state.dart` | `FFAppState().password` simpan password dalam RAM. |
| 12 | **Unused Firebase deps** | `firebase/functions/package.json` | `braintree`, `stripe`, `razorpay`, `@langchain/*`, `@onesignal` — kemungkinan besar tidak digunakan, tambah attack surface. |

### LOW (Code Quality)

| # | Issue | Location | Detail |
|---|-------|----------|--------|
| 13 | **17 Hardcoded Doctor Modals** | `lib/component/modal_*/` | Setiap doktor ada widget sendiri — extreme code duplication. Sepatutnya dynamic dari `GET /facility`. |
| 14 | **Multiple "Copy" pages** | `lib/` | `RegisterPageCopy`, `ProfileCopy`, `SelectDatecase`, `BookingPagecasse` — duplikasi belum dibersihkan. |
| 15 | **Typos dalam code** | Various | `select_date_reshecedule` (folder), `coutnnotif` (variable), `EditPatiendCall` (class name). |
| 16 | **test_page dalam code** | `lib/front_page/test_page/` | Page test masih dalam production codebase. |
| 17 | **Tiada unit tests** | `test/` | Hanya 1 skeleton test file. Tiada coverage. |
| 18 | **FlutterFlow GitHub deps** | `pubspec.yaml` | `dropdown_button2` dan `webviewx_plus` dari FlutterFlow GitHub forks — bukan pub.dev official packages. |
| 19 | **Service Packages static** | `lib/service_package/` | 4 gambar static hardcoded. API `/servicepackages` wujud tapi tidak digunakan untuk render dynamic content. |

### SECURITY

| Issue | Risk | Mitigation |
|-------|------|------------|
| Plato API token hardcoded | TINGGI — data breach | Pindah ke server-side proxy (Laravel) |
| Firebase rules belum disahkan | Sederhana — data leak | Semak `firestore.rules` dan `storage.rules` |
| Password in `FFAppState` | Rendah-Sederhana | Guna SecureStorage jika perlu persist |

---

## 20. ADMIN PANEL (Laravel) — Nota

> **PENTING:** Admin panel adalah projek **berasingan**, hosted di VPS yang berbeza. **Tidak ada dalam repo ini.**

**V1 Tech Stack (Existing):** Laravel + MySQL
**V2 Tech Stack (Confirmed):** Laravel + Inertia.js + Vue 3 + Tailwind CSS + MySQL
**Tujuan:** Manage patient, appointment, billing, push notifications, CMS, dan WhatsApp dari satu custom web UI

> **Refer:** `docs/v2-decisions.md` untuk full locked decisions.

### V1 vs V2 Feature Comparison

| Modul | V1 (Sekarang) | V2 (Planned) |
|-------|--------------|--------------|
| Patient Management | Basic | Full CRM + Plato sync |
| CMS/Slider | Upload image sahaja | Sliders, articles, doctor profiles (dynamic), service packages |
| Push Notification | Basic (broadcast all) | 3-channel: Push + Email + In-App. Targeted + scheduled + templates |
| Appointment | Tiada | Calendar view, slot management, create for walk-ins |
| Invoice / Billing | Tiada | Full flow: create, items, finalize, payment |
| Queue Management | Tiada | Real-time queue board, status update |
| WhatsApp Center | Tiada | Send single/bulk, message history via Plato API |
| Branch Management | Tiada | CRUD branches + dynamic WhatsApp number per branch |
| Calendar Setup | Tiada | Sync Plato calendar colors + map to doctors |
| Role-Based Access | Single role | Super Admin, Branch Admin, Staff, Doctor |
| Analytics Dashboard | Tiada | Revenue, appointments, patient trends, notif stats |
| Plato API Proxy | Tiada | Token server-side in .env — NOT exposed in mobile APK |
| Loyalty Points | — | Feature plan only (not this cycle) |
| Online Payment | — | Feature plan only (not this cycle) |

### V2 Architecture (Confirmed)

```
Mobile App (Flutter)
        |
        v HTTPS + Bearer token (per-user)
Laravel Admin Panel (VPS)
  ├── Inertia.js + Vue 3 + Tailwind CSS (Custom UI — NOT Filament)
  ├── API routes /api/v2/* (served to Mobile App)
  ├── Plato API Proxy (token in .env — never in mobile code)
  ├── Firebase Admin SDK (FCM push notifications)
  ├── Laravel Mail (emails — Mailgun/SES/SMTP)
  └── MySQL (branches, doctors, calendars, settings)
        |
        v
  Plato API + Firebase (Firestore/FCM)
```

### Dynamic WhatsApp Number (Confirmed)

- Stored in MySQL `branches.whatsapp_number`
- Editable: Admin Panel → Branch Management → Edit Branch
- **Per-branch** — setiap branch boleh ada WA Business number berbeza
- Mobile fetches via `GET /api/v2/config/branches`
- Deep link: `https://wa.me/{whatsapp_number}?text={prefilled_message}`
- Admin boleh update anytime tanpa app update

### Plato Calendar Setup (Confirmed — We Handle It)

```
Admin Panel → Settings → Calendar Setup:
1. "Sync from Plato" → GET /systemsetup → save calendar color IDs to MySQL
2. Admin maps color ID → Doctor (or shared room)
3. Mobile uses color IDs for POST /appointment/slots (real slot availability)
4. Admin creates Plato appointment with correct color after WA booking confirmed
```
---

## 21. V2 ROADMAP (Summary)

> **Rujukan penuh:** `docs/v2-pitch-deck.md`

### Phase 1: Foundation (4 minggu)
- Pindah Plato token ke Laravel (API proxy)
- Implement pagination (`current_page` untuk semua list)
- Proper error handling + skeleton loading
- Firestore security rules audit
- Cleanup: duplicate pages, test_page, unused dependencies

### Phase 2: Core Booking (4 minggu)
- In-app booking dengan real slot availability check
- Fix `GetAppointmentDetailsCall` (gantikan hardcoded ID)
- Reschedule / cancel appointment
- Queue tracker dalam app

### Phase 3: Patient Portal (4 minggu)
- Invoice viewer (dengan breakdown items)
- Payment history
- Document center (MC, surat, lab result)
- Health trends/vitals graph dari Plato

### Phase 4: Loyalty Points (4 minggu)
- Patient Appreciation Points: RM1 = 1 point
- Redemption: 100 points = RM5 discount
- Points dashboard dalam app
- Admin panel: loyalty panel + campaigns

### Phase 5: Communications (3 minggu)
- WhatsApp integration via `POST /whatsapp/send`
- Appointment reminders (push + WhatsApp 24h & 1h before)
- Push notification upgrade (targeted, scheduled, templates)

### Phase 6: Polish (4 minggu)
- Dark mode support
- Multi-language: BM, EN, ZH
- Global search
- Full UI/UX overhaul (skeleton loaders, empty states, error UI)
- Doctor list dynamic dari `GET /facility` (gantikan 17 hardcoded modals)

---

## 22. SETUP & DEVELOPMENT

### Prerequisites

```bash
flutter --version     # Perlu Flutter 3.29.3, Dart >=3.0.0
node --version        # Untuk mock server (Node >=18)
firebase --version    # Untuk deploy Cloud Functions
```

### Quick Start

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2a. Run production (real APIs)
flutter run

# 2b. Run dengan mock server
# Terminal 1 — start mock server:
cd mock_server && npm install && npm start

# Terminal 2 — run Flutter:
flutter run \
  --dart-define=MEDICAL_APPS_URL=http://localhost:4000/api \
  --dart-define=PLATOM_URL=http://localhost:4000/platom \
  --dart-define=WORDPRESS_URL=http://localhost:4000/wp-json/wp/v2
```

### Platform Commands

```bash
# Android
flutter run -d android

# iOS (perlu Xcode + CocoaPods)
cd ios && pod install --repo-update && cd ..
flutter run -d ios

# Web (Chrome)
flutter run -d chrome

# List available devices
flutter devices
```

### Firebase Functions Deploy

```bash
cd firebase/functions
npm install
firebase deploy --only functions --project heclinicapps-8be27
```

---

## 23. QUICK REFERENCE UNTUK AI

### Cari File Ikut Fungsi

| Tujuan | File |
|--------|------|
| Semua API call definitions | `lib/backend/api_requests/api_calls.dart` |
| Global state (semua variables) | `lib/app_state.dart` |
| Route definitions (27 routes) | `lib/flutter_flow/nav/nav.dart` |
| App entry point | `lib/main.dart` |
| Base URLs (3 APIs) | `lib/env_config.dart` |
| Theme/colors/typography | `lib/flutter_flow/flutter_flow_theme.dart` |
| Firebase config + init | `lib/backend/firebase/firebase_config.dart` |
| Auth utilities | `lib/auth/firebase_auth/auth_util.dart` |
| Cloud Functions (Node.js) | `firebase/functions/index.js` |
| Mock server | `mock_server/index.js` |
| Firestore security rules | `firebase/firestore.rules` |
| Biometric logic | `lib/custom_code/actions/load_biometric_status.dart` |
| Push notification handler | `lib/backend/push_notifications/push_notifications_handler.dart` |

### Naming Conventions (FlutterFlow Legacy)

| Pattern | Contoh | Keterangan |
|---------|--------|------------|
| `FFAppState()` | `FFAppState().tokenauth` | Global state singleton |
| `*Widget` | `HomepageNewWidget` | Stateful Flutter widget |
| `*Model` | `HomepageNewModel` | Page model (logic + state) |
| `*Call` | `LoginCall`, `GetPatientCall` | API endpoint class |
| `*Group` | `MedicalAppsApiGroup` | API base URL + group namespace |
| `ff_*` | `ff_isLoggedIn` | FlutterFlow SharedPreferences key prefix |
| `*Copy` / `*copy` | `ProfileCopy` | Duplicate variant (legacy, perlu cleanup) |

### API Group Classes

| Class | API | Base URL |
|-------|-----|----------|
| `MedicalAppsApiGroup` | Medical Apps | `EnvConfig.medicalAppsBaseUrl` |
| `PlatomeApiGroup` | Plato Medical | `EnvConfig.platomBaseUrl` |
| (Direct) | WordPress | `EnvConfig.wordpressBaseUrl` |

### Important pubspec.yaml Notes

```yaml
# Versi dikunci — JANGAN ubah tanpa semak compatibility
dependency_overrides:
  http: 1.4.0
  intl: 0.20.2
  uuid: ^4.0.0

# FlutterFlow GitHub forks — BUKAN pub.dev packages
dropdown_button2:
  git:
    url: https://github.com/FlutterFlow/dropdown_button2.git
webviewx_plus:
  git:
    url: https://github.com/FlutterFlow/webviewx_plus.git
```

---

## 24. DOKUMEN BERKAITAN

| Dokumen | Path | Keterangan |
|---------|------|------------|
| **Codebase Audit (ini)** | `docs/CODEBASE.md` | Rujukan lengkap untuk AI — audit keseluruhan |
| Technical Audit (asal) | `docs/PROJECT.md` | Versi asal — API tables, architecture, known issues |
| Plato API Official Docs | `docs/api-guidelines.md` | Dokumentasi rasmi Plato (BM) — authentication, endpoints, webhook |
| V2 Upgrade Proposal | `docs/v2-pitch-deck.md` | Proposal penuh untuk client — features, timeline, ROI |

---

*Dokumen ini di-generate melalui audit menyeluruh codebase pada July 2026.*
*Kemaskini dokumen ini apabila ada perubahan signifikan pada architecture, API, atau features.*
