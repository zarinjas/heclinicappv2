# HE CLINIC V2 — Proposal Pembaharuan Sistem

> **Disediakan untuk:** Client He Clinic
> **Tarikh:** Jun 2026
> **Platform:** Mobile App (Flutter) + Admin Panel (Laravel) + Plato API

---

## 📋 Kandungan

1. [Problem Statement](#1-problem-statement)
2. [Current State (V1) — Apa Yang Ada Sekarang](#2-current-state-v1)
3. [Kenapa Perlu Upgrade](#3-kenapa-perlu-upgrade)
4. [Architecture V2 — Sistem Baru](#4-architecture-v2)
5. [Mobile App V2 — Feature Matrix](#5-mobile-app-v2)
6. [Admin Panel V2 — Feature Matrix](#6-admin-panel-v2)
7. [Loyalty Points System](#7-loyalty-points-system)
8. [UI/UX Overhaul](#8-uiux-overhaul)
9. [Implementation Timeline](#9-implementation-timeline)
10. [Return on Investment](#10-return-on-investment)

---

## 1. Problem Statement

### 🚩 Masalah Utama Sekarang

| # | Problem | Kesan |
|---|---------|-------|
| 1 | **Patient kena WhatsApp untuk booking** — app hanya show kalendar, lepas pilih tarikh terus redirect ke WhatsApp | Tiada slot availability check. Staff kena manual reply. Slow. Patient frust kalau lambat reply. |
| 2 | **Tiada loyalty / rewards program** — patient datang dan bayar, lepas tu nothing. No incentive to come back. | Patient churn tinggi. Klinik bergantung pada iklan / word-of-mouth je. |
| 3 | **Admin panel limited** — manage patient, slider, push notif. Takde appointment management, billing view, queue, analytics. | Staff kena guna Plato system untuk banyak benda. Admin panel underutilized. |
| 4 | **Plato API token hardcoded dalam mobile app** — sesiapa decompile APK boleh access semua data Plato | **Security risk tinggi.** Patient data boleh bocor. |
| 5 | **Data tak bersambung** — mobile app call Plato direct, admin panel pakai MySQL sendiri, Firebase for push notif. No central orchestration. | Data inconsistent. Hard to maintain. Hard to add new features. |
| 6 | **Tiada queue visibility** — patient duduk tunggu tanpa tahu nombor giliran | Patient experience rendah. Staff kena jawab "berapa lama lagi?" berkali-kali. |
| 7 | **Tiada offline support** — app terus blank tanpa internet | Patient hilang akses bila coverage teruk. |
| 8 | **Tiada proper error handling** — loading GIF jalan forever bila API gagal | Patient keliru. Call klinik tanya "app rosak ke?" |

### 🎯 Objektif V2

> **"Satu platform untuk patient booking, track health records, dapat reward — dan satu admin panel untuk clinic manage everything."**

1. **Patient** — senang book appointment, tengok rekod, dapat loyalty points
2. **Staff** — senang manage appointment, queue, billing dalam satu panel
3. **Management** — nampak data analytics, revenue, patient trends
4. **Secure** — Plato token server-side, Firestore terkunci, data encrypted

---

## 2. Current State (V1)

### 📱 Mobile App (Flutter) — Current Feature Set

| Modul | Status | Notes |
|-------|--------|-------|
| Login/Register | ✅ | Form 15 field panjang, FCM token bug |
| Homepage | ✅ | 5 API calls sequential, slow load |
| Booking | ⚠️ | **Booking guna WhatsApp** — broken UX |
| My Booking | ✅ | View appointments, no cancel/reschedule |
| Branch List | ⚠️ | Tab 2-6 button "Get Direction" hanya `print()` — broken |
| Profile | ⚠️ | Wrong icon on button, hidden fields |
| Reports | ✅ | 3 tabs, tapi fragile filter logic |
| Notifications | ✅ | No mark-all-read, no swipe |
| Articles | ✅ | Static from WordPress |
| Service Packages | ❌ | **4 gambar static** — API endpoint tak guna |
| Doctors List | ❌ | **17 modal hardcoded** — tak sync dengan Plato |
| Doctor Modals | ❌ | 17 duplicate files, extreme code duplication |
| Biometric | ✅ | Works |

### 🖥️ Admin Panel (Laravel) — Current Feature Set

| Modul | Status | Notes |
|-------|--------|-------|
| Patient Management | ⚠️ | Ada tapi "tak proper" |
| Slider Images | ✅ | Upload & change slider |
| Push Notification | ✅ | Send from admin panel |
| Database | ✅ | MySQL — data simpan sini |
| Role Management | ❌ | Single role je |
| Plato API Integration | ❌ | Standalone, tak connect ke Plato |
| Appointment Dashboard | ❌ | Tiada |
| Billing/Invoice View | ❌ | Tiada |
| Queue Management | ❌ | Tiada |
| Analytics & Reports | ❌ | Tiada |

### 🔗 System Architecture V1

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Mobile App  │────>│  Medical Apps API │     │  Plato API       │
│  (Flutter)   │     │  (hemedicalapps) │     │  (clinic.plato)  │
│              │────>│  Firebase         │     │  (hardcoded token│
│  token in    │     │  (Firestore/FCM)  │     │   in source code)│
│  source code │     └──────────────────┘     └─────────────────┘
└─────────────┘
        │
        └──────────────────────────────────────┘

┌─────────────┐     ┌──────────────────┐
│ Admin Panel  │────>│  MySQL (local)    │
│ (Laravel)    │     └──────────────────┘
│              │────>│  Firebase (FCM)   │
└─────────────┘
```

**Issues:**
- Mobile **direct call** Plato — token exposed
- Admin panel **standalone** — tak sync dengan Plato
- Tiada central business logic layer
- Data scattered across 3 systems + 2 databases

---

## 3. Kenapa Perlu Upgrade

### 🔴 Kenapa V1 Tak Cukup Lagi

| Perspektif | Kenapa Upgrade |
|------------|----------------|
| **Patient** | "Nak book appointment kena WhatsApp. Lambat. Tak tau slot mana available. Takde reward pun." |
| **Staff Klinik** | "Kena guna 3 system: app utk check booking, Plato untuk billing, WhatsApp untuk reply patient. Susah." |
| **Management** | "Tak nampak data. Berapa patient hari ni? Revenue? Appointment no-show rate? Tak ada dashboard." |
| **Developer** | "Maintain 3 system berasingan. Token hardcoded. Code banyak duplicate. Scalability isu." |
| **Security** | "Kalau ada pihak tak bertanggungjawab decompile APK, semua patient data bocor. Firestore pun open read. GDPR/PDPA compliance risiko." |

### 🟢 Apa Yang V2 Bawa

| Untuk Siapa | V2 Value |
|-------------|----------|
| **Patient** | In-app booking, real-time slot availability, queue tracking, health records, loyalty points, WhatsApp reminders, dark mode |
| **Staff Klinik** | Satu panel untuk appointment, queue, billing, patient lookup. Push notification & WhatsApp integrated |
| **Management** | Dashboard: revenue, appointment trends, patient demographics, loyalty engagement, branch comparison |
| **Developer** | Clean architecture: Laravel API hub, Plato token server-side, Firebase for real-time, unit tests, proper error handling |
| **Security** | Token server-side. Firestore rules ketat. PDPA compliance. Activity audit log. |

### 📊 Competitive Landscape (Malaysia)

| Klinik | Booking | Digital Loyalty | Patient Portal |
|--------|---------|----------------|----------------|
| **Kebanyakan klinik swasta** | WhatsApp/Call je | ❌ Stamp card manual | ❌ Tiada |
| **Klinik panel besar (Mediviron etc)** | Call/WhatsApp | ❌ | ⚠️ Simple website |
| **Hospital swasta besar** | Ada app | ✅ Points (terhad) | ✅ |
| **HE CLINIC V2** | **✅ In-app booking + slots** | **✅ RM1=1pt + redeem** | **✅ Full patient portal** |

**He Clinic V2 boleh jadi first-mover** untuk klinik swasta Malaysia yang ada digital loyalty + booking app.

---

## 4. Architecture V2

### 🏗️ Sistem Baru

```
                    ┌───────────────────────────────────────┐
                    │            PLATO API                  │
                    │  (https://clinic.platomedical.com)     │
                    └──────────────┬────────────────────────┘
                                   │ Bearer Token (server-side)
                                   │ ✅ Secure — takde dalam APK
                                   ▼
┌──────────────┐     ┌──────────────────────────────┐     ┌──────────────────┐
│  Mobile App   │────>│   LARAVEL ADMIN PANEL (VPS)  │────>│  MySQL            │
│  (Flutter)    │     │                              │     │  (local data)     │
│              │     │  • API Proxy (Plato gateway)  │────>│  Firebase          │
│  WhatsApp     │<────│  • Business Logic             │     │  (Firestore/FCM)   │
│  (Twilio)     │     │  • Points Calculation         │     └──────────────────┘
│              │     │  • Authentication              │
│  Queue Status │<────│  • Notification Engine        │
│  (Real-time)  │     │  • Analytics                  │
└──────────────┘     └──────────────────────────────┘
```

### 🔄 Data Flow

```
MOBILE APP → Laravel API (/api/v2/*) 
           → Laravel proxy ke Plato API (/api/plato/*)
           → Laravel cache & log
           → Response balik ke mobile

ADMIN PANEL UI (Laravel Blade / Inertia)
           → Direct internal API calls
           → Plato integration same layer
           → MySQL queries for local data

REAL-TIME (Firebase)
           → Queue status updates → push ke mobile
           → Loyalty points changes → push ke mobile
           → Appointment reminders → push notif + WhatsApp
```

### ✅ Kenapa Architecture Ni?

| Keputusan | Reason |
|-----------|--------|
| **Laravel sebagai API Hub** | Token Plato tak exposed. Business logic centralized. Rate limiting, caching, logging satu tempat. |
| **Firestore untuk real-time** | Mobile app need real-time queue & points. Firestore stream lebih sesuai dari REST polling. |
| **MySQL untuk admin data** | Admin panel butuh complex queries (reports, analytics). SQL lebih power. |
| **Webhook nanti** | Plato support webhook — nanti bila integrate, Laravel boleh webhook receiver. |

---

## 5. Mobile App V2

### 🔴 TIER 1: Critical — Wajib

| # | Feature | Description | Plato API |
|---|---------|-------------|-----------|
| 1 | **Smart Booking Flow** | Pilih doctor → tengok slot available → hantar request via WhatsApp dengan details pre-filled | `POST /{db}/appointment/slots` |
| 2 | **Slot Availability** | Kalendar tunjuk waktu tersedia. Patient pilih slot, staff confirm via Plato. | `POST /{db}/appointment/slots` |
| 3 | **Token Security Fix** | Pindah Plato token ke Laravel. Mobile panggil Laravel API je. | Via Laravel proxy |
| 4 | **Firestore Rules** | Kunci semua collection dengan `request.auth.uid` | N/A |
| 5 | **Error Handling** | Retry, error state UI, loading skeleton (ganti GIF) | N/A |
| 6 | **Pagination** | Guna `current_page` untuk semua list (appointments, invoices, reports) | `current_page` param |

### 🔵 TIER 2: Penting — Patient Experience

| # | Feature | Description | Plato API |
|---|---------|-------------|-----------|
| 7 | **Reschedule/Cancel Appointment** | Ubah tarikh atau cancel — auto-notify klinik | `PUT /{db}/appointment/{id}` |
| 8 | **Appointment Detail** | Info lengkap: doctor, time, location, status | `GET /{db}/appointment/{id}` |
| 9 | **Add to Phone Calendar** | Satu click — simpan appointment ke Google/Apple Calendar | N/A |
| 10 | **Queue Tracker** | Lihat nombor giliran & status (menunggu/dalam rawatan/selesai) | `GET /{db}/queue/status` |
| 11 | **Invoice Viewer** | Billing detail — breakdown item, total, status bayaran | `GET /{db}/invoice` |
| 12 | **Payment History** | Senarai pembayaran lepas + resit digital | `GET /{db}/payment` |
| 13 | **Document Center** | Semua dokumen satu page: MC, surat rujukan, lab result, preskripsi | `GET /{db}/letter`, `GET /{db}/invoice` |
| 14 | **Health Trends Dashboard** | Graf BP, gula, berat, cholesterol trending | `GET /{db}/patient/{id}/graphing` |
| 15 | **Service Packages (Dynamic)** | Package dari API — bukan gambar static | `GET /api/servicepackages` |
| 16 | **Doctors From Plato** | List doctor dynamic — bukan 17 hardcoded widget | `GET /{db}/facility` |
| 17 | **Appointment Reminders** | Push notification 24h & 1h sebelum appointment | Laravel scheduler + FCM |
| 18 | **Offline Mode** | Cache profile, appointments, branches guna Hive/sqflite | N/A |
| 19 | **Registration Wizard** | 15 fields → 3-step wizard dengan progress bar | N/A |
| 20 | **Empty States** | "No upcoming appointments" with CTA button | N/A |

### 🟡 TIER 3: Wow Factor — Differentiation

| # | Feature | Description | Plato API / Notes |
|---|---------|-------------|-------------------|
| 21 | **Patient Appreciation Points** | RM1 = 1pt. Redeem RM5 off per 100pts. Tier system: Standard → Silver → Gold. | Via invoice finalize — Section 7 |
| 22 | **WhatsApp Integration** | "Send details via WhatsApp" — appointment, invoice | `POST /{db}/whatsapp/send` |
| 23 | **Dark Mode** | Toggle light/dark — ikut system preference | `ThemeMode.system` |
| 24 | **Multi-Language** | BM, English, Chinese | `flutter_localizations` |
| 25 | **Global Search** | Search doctor, branch, article, report | Local + API |

---

## 6. Admin Panel V2

### 📊 Dashboard

| Widget | Source | Description |
|--------|--------|-------------|
| Today's Appointments | Plato `GET /{db}/appointment` | Count + list ringkas |
| Current Queue | Plato `GET /{db}/queue/status` | Berapa patient waiting/treatment/done |
| Today's Revenue | Plato `GET /{db}/invoice` | Total collected hari ni |
| New Registrations | Local MySQL | Signup count this month |
| Points Issued Today | Firestore `loyalty_transactions` | Points earned & redeemed |
| Appointment No-Shows | Local tracking | Rate % |
| Branch Comparison | Aggregate | All branches side-by-side |

### 👥 Patient Management (Upgrade)

| Feature | Description | Plato Sync |
|---------|-------------|------------|
| Patient List | Table: photo, name, NRIC, phone, last visit, total spent | ✅ `GET /{db}/patient` |
| Advanced Search | Search by name, NRIC, phone, email, branch | ✅ |
| Patient Detail | Full profile + appointment history + invoices + documents + points | ✅ All endpoints |
| Quick Actions | Book appointment, create invoice, send WhatsApp, view Plato notes | ✅ |
| Patient Merge | Merge duplicate records with safety confirmation | ✅ `POST /{db}/patient/merge` |
| Export | CSV/PDF export with filters | Local |
| Activity Timeline | Log per patient — appointments, payments, notes | Local + Plato |

### 📅 Appointment Management (NEW)

| Feature | Description | Plato Sync |
|---------|-------------|------------|
| Calendar View | Month/week/day — color by doctor | ✅ `GET /{db}/appointment/calendars` |
| Appointment List | Table: time, patient, doctor, status, action buttons | ✅ `GET /{db}/appointment` |
| Create Appointment | Manual booking for walk-in patients | ✅ `POST /{db}/appointment` |
| Reschedule | Change date/time — auto WhatsApp reminder | ✅ `PUT /{db}/appointment/{id}` |
| Cancel | Cancel with reason — auto-notify patient | ✅ `DELETE /{db}/appointment/{id}` |
| Slot Management | Block/unblock time slots for specific dates | ✅ `POST /{db}/appointment/slots` |
| Doctor Schedule | Each doctor's working days & hours | ✅ Via systemsetup |

### 🧾 Invoice & Billing (NEW)

| Feature | Description | Plato Sync |
|---------|-------------|------------|
| Create Invoice | Select patient → pick items from inventory | ✅ `POST /{db}/invoice` |
| Add Items | Search inventory, set quantity/price | ✅ `POST /{db}/invoice/items` |
| Finalize | Lock invoice — trigger points earn | ✅ `POST /{db}/invoice/finalize` |
| Record Payment | Enter amount, method (cash/card/points) | ✅ `POST /{db}/invoice/payment` |
| Invoice History | Search by patient, date, status | ✅ `GET /{db}/invoice` |
| Receipt Print | Generate & print PDF receipt | Local |
| Void Invoice | Cancel invoice (with reason & audit) | ✅ Via Plato |

### 🎯 Queue Management (NEW)

| Feature | Description |
|---------|-------------|
| Queue Board | Real-time view: Waiting → In Treatment → Done |
| Update Status | One click — move patient to next stage |
| Priority | Flag urgent cases, elderly, children |
| Auto-Notify | Status change → push notification ke mobile |
| History | Average waiting time per doctor/hour |
| Call Patient | Button to trigger notification + display board |

### ⭐ Loyalty Points Panel (NEW)

| Feature | Description |
|---------|-------------|
| Dashboard | Total earned, redeemed, active members, points ageing |
| Patient Lookup | Search → view balance, tier, full transaction history |
| Manual Adjust | Add/deduct points with reason — logged to audit trail |
| Campaigns | Create "Double Points Weekend", birthday bonus, referral bonus |
| Redemption Queue | View pending redemption requests → approve/reject |
| Expiry Report | Points expiring in 30/60/90 days |
| Config | Earn rate (RM1=1pt), redemption rate (100pt=RM5), expiry period |

### 🔔 Push Notification (Upgrade)

| Feature | Current V1 | V2 Upgrade |
|---------|------------|------------|
| Compose | Basic title + body | Title + body + image + deep link + action buttons |
| Target | All users | Filter: by branch, by patient, by doctor, by role |
| Schedule | No | Send now / schedule later |
| Templates | No | Save reusable notification templates |
| History | No | Delivery stats (sent, delivered, opened, failed) |

### 💬 WhatsApp Integration (NEW)

| Feature | Description | Plato Sync |
|---------|-------------|------------|
| Send Single | Send templated WhatsApp to one patient | ✅ `POST /{db}/whatsapp/send` |
| Send Bulk | Send to filtered patient list (e.g., "all overdue appointments") | ✅ |
| Templates | Appointment reminder, invoice ready, lab result ready | Twilio |
| History | Message log with delivery status | ✅ `GET /{db}/whatsapp/list` |
| Auto-Trigger | Automatik: appointment confirm → send WhatsApp | Laravel event |

### 🏢 Branch & Doctor Management (NEW)

| Feature | Description |
|---------|-------------|
| Branch CRUD | Add/edit/deactivate branches. Address, phone, operating hours, photos |
| Doctor CRUD | Name, specialty, qualifications, languages, photo, bio |
| Doctor Assignment | Assign doctors to branches with schedule |
| Staff Management | Create admin panel users. Assign role & branch. |
| Calendar Setup | Link doctor to Plato calendar color ID |

### 📄 CMS — Content Management (Upgrade)

| Feature | Current V1 | V2 Upgrade |
|---------|------------|------------|
| Slider | Upload image | Upload image + link URL + schedule + A/B test |
| Articles | ❌ Takde | CRUD health articles with rich text editor |
| Videos | ❌ Takde | Upload/embed YouTube videos |
| Service Packages | ❌ Ada 4 gambar static je | CRUD packages with name, desc, price, image, validity |
| Branch Info | ❌ Need edit Firebase | Edit from admin → auto-sync to Firestore |

### 👤 Role-Based Access Control (NEW)

| Role | Permissions |
|------|------------|
| **Super Admin** | Full access — all branches, all modules, user management |
| **Branch Admin** | Own branch only — manage patients, appointments, invoices, queue |
| **Staff** | Own branch — manage queue, create invoices, view patients |
| **Doctor** | View own appointments, view patient history, add clinical notes |

### 📈 Reports & Export

| Report | Format | Source |
|--------|--------|--------|
| Patient Registration Report | CSV/PDF | MySQL |
| Appointment Summary (daily/weekly/monthly) | CSV/PDF | Plato |
| Revenue Report by Branch | CSV/PDF | Plato Invoice |
| Top Services / Products | CSV/PDF | Plato Invoice Items |
| Loyalty Points Report | CSV/PDF | Firestore |
| No-Show Rate Analysis | CSV/PDF | Local Tracking |
| Patient Demographics | CSV/PDF | Plato Patient |

---

## 7. Loyalty Points System

### 7.1 Konsep

> **Patient Appreciation Program** — bukan "Loyalty/Rewards" untuk elak isu MMC (Malaysian Medical Council).
>
> Setiap RM1 yang dibelanjakan = 1 Point. Points boleh ditebus untuk diskaun bil akan datang.

### 7.2 Mekanisma

| Item | Detail |
|------|--------|
| Earn Rate | **RM1 = 1 point** (flat rate) |
| Redemption Rate | **100 points = RM5 discount** |
| Min Redemption | **100 points** minimum tebus |
| Max Per Transaction | **1,000 points** max guna sekali bayar |
| Expiry | **12 bulan** dari tarikh earn (FIFO — points lama guna dulu) |
| Auto-Earn | Bila staff finalize invoice di admin panel → points auto-credit |
| Tiers | Standard (0pt), Silver (5,000pt) → 2x earn rate, Gold (20,000pt) → 3x + free screening |

### 7.3 Technical Implementation

Plato tidak ada dedicated loyalty API — kita bina sendiri di atas data invoice Plato.

```
Admin Panel: Staff finalize invoice (POST /{db}/invoice/finalize)
         │
         ▼
Laravel: LoyaltyService::earnFromInvoice()
         │
         ├── Check duplicate: invoice_id unique — tak boleh earn dua kali
         ├── Apply tier multiplier (1x / 2x / 3x)
         ├── Calculate: points = floor(invoice_total) × earn_rate × multiplier
         ├── Save: loyalty_transactions (MySQL) — atomic, auditable
         └── Update: loyalty_accounts balance + lifetime_earned
              │
              ▼
         FCM Push: "You earned X points!"
         Firestore mirror → real-time balance update di mobile app
```

**Kenapa MySQL, bukan Firestore sahaja?** Financial data perlu atomic transactions — SQL lebih selamat untuk pastikan balance tak corrupt kalau ada concurrent requests.

### 7.4 Fraud Prevention

| Measure | Implementation |
|---------|---------------|
| Duplicate Check | `invoice_id` unique — tak boleh guna invoice sama dua kali |
| Audit Log | Setiap transaction ada `staff_id`, `timestamp`, `reason` |
| Max Points Per Invoice | Capped at reasonable value |
| Non-Transferable | Points tied to patient NRIC |
| Staff Permissions | Only supervisor can manually adjust points |
| Cooling Period | 24h delay before new points redeemable |

### 7.5 Regulatory Note (MMC)

**Risiko:** Malaysian Medical Council Code of Professional Conduct melarang doktor memberi "inducement" untuk menarik pesakit.

**Mitigasi:**
1. **Iklan dalam app sahaja** — bukan billboard atau Facebook ads
2. **"Patient Appreciation"** — bukan "Loyalty Rewards"
3. **Tiada referral bonus** — points hanya dari spend sendiri
4. **Dapatkan written guidance dari KKM/MMC** sebelum launch
5. **Terms & Conditions clear** — points bukan cash value, clinic berhak ubah terma

---

## 8. UI/UX Overhaul

### 8.1 Mobile App — Perbandingan

| Aspek | V1 (Current) | V2 (Proposed) |
|-------|--------------|---------------|
| **Loading** | GIF animation | Skeleton shimmer (content placeholder) |
| **Error** | GIF forever | Error illustration + retry button + cached data |
| **Empty State** | Tiada langsung | Illustration + message + CTA button |
| **Homepage** | Slider + side drawer | Dashboard: upcoming appointment, points badge, quick actions |
| **Booking** | 6 tabs copy-paste | Single list + filter + interactive calendar |
| **Doctor** | 17 hardcoded modals | Single dynamic widget from API |
| **Registration** | 15 fields scroll | 3-step wizard + progress bar |
| **Nav** | 4 tabs (Home, Branches, Booking, Profile) | 5 tabs (Home, Book, Records, Loyalty, Profile) |
| **Colors** | Light mode only | Light + Dark mode toggle |
| **Icons** | Inconsistent | Uniform Material 3 icon pack |
| **Typography** | .override() everywhere | Clean theme-based typography |

### 8.2 Admin Panel — Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Mobile-First** | Bootstrap 5 / Tailwind — responsive untuk tablet & phone |
| **Dark Mode** | Toggle — especially for counter staff yg guna malam |
| **Keyboard Shortcuts** | Power users — Cmd+Enter submit, / search |
| **Real-Time** | Queue board auto-refresh — no page reload |
| **Print-Friendly** | Invoice, receipt, report — print CSS optimized |

### 8.3 New User Flows

**Patient Booking (V1):**
```
Buka App → Pilih Branch → Pilih Tarikh → WhatsApp → Staff Reply → Confirm
```
*Rata-rata: 5-30 minit*

**Patient Booking (V2):**
```
Buka App → Pilih Doctor → Pilih Slot Available → WhatsApp (pre-filled, 1 tap) → Staff Confirm
```
*Rata-rata: 2-3 minit — patient tak perlu taip apa-apa, staff still upsell & confirm*

**Admin Queue (V1):**
```
Staff tanya "siapa lepas?" → check Plato → panggil nama → tulis manual
```

**Admin Queue (V2):**
```
Dashboard → "Next Patient" button → auto-update queue board → push notif ke patient
```

---

## 9. Implementation Timeline

### 📅 Mobile App + Admin Panel (Parallel)

| Phase | Mobile App | Admin Panel | Duration |
|-------|-----------|-------------|----------|
| **Phase 1: Foundation** | Fix token (proxy via Laravel), pagination, error handling, offline cache, cleanup dead code | Auth roles, patient CRM proper, API proxy setup, basic dashboard | 3-4 minggu |
| **Phase 2: UI/UX Overhaul** | New design system, 5-tab nav, doctor list dynamic, home screen redesign, skeleton loaders | Branch & Doctor management, CMS (sliders, packages, articles) | 3-4 minggu |
| **Phase 3: Booking + Health** | Booking flow (slot preview → WhatsApp), appointment history, health tab (records, vitals, docs) | Appointment calendar, slot management, patient document upload | 3-4 minggu |
| **Phase 4: Patient Portal** | Invoice viewer, payment history, queue tracker | Invoice management, queue board, billing view | 3-4 minggu |
| **Phase 5: Loyalty** | Points balance widget, My Points screen, redeem flow | Loyalty panel, invoice finalize hook, tier management | 3-4 minggu |
| **Phase 6: Comms + Polish** | Push notif upgrade, WhatsApp integration, dark mode, multi-language | WhatsApp center, notification composer, analytics dashboard | 3 minggu |

### 🚀 Total Anggaran

| Fasa | Fokus | Anggaran Masa | Parallel? |
|------|-------|---------------|-----------|
| **Foundation** | Security, cleanup, architecture | 3-4 minggu | ✅ Ya |
| **Core Features** | Booking, appointment, invoice | 3-4 minggu | ✅ Ya |
| **Advanced** | Loyalty, WhatsApp, queue, webhook | 3-4 minggu | ✅ Ya |
| **Polish** | UI, dark mode, multi-lang, analytics | 2-3 minggu | ✅ Ya |
| **QA & UAT** | Testing, bug fix, deploy | 2 minggu | ❌ Sequential |
| | **TOTAL** | **~16-18 minggu** | |

> **Nota:** Timeline ni assume:
> - Client team sedia data Plato (patient sudah register)
> - Plato API key dan calendar setup sudah sedia
> - Laravel VPS sudah ada (sedia ada)
> - Review & approval dari client dalam timeline

---

## 10. Return on Investment

### 💰 Value Untuk Client

| Metrik | V1 | V2 Target | Improvement |
|--------|----|-----------|-------------|
| **Booking Experience** | WhatsApp (manual, patient taip sendiri) | Pilih slot + WhatsApp pre-filled (1 tap) | ⏱️ **5-30 min → 2-3 min** |
| **Staff Operational Time** | Reply WhatsApp, check Plato, manual queue | One dashboard, auto notifications | ⏱️ **~70% less admin time** |
| **Patient Retention** | Tiada loyalty | RM1=1pt, redeem discount | 📈 **Target: repeat rate +30%** |
| **No-Show Rate** | Tiada reminder | Push + WhatsApp 24h & 1h before | 📉 **Target: no-show -50%** |
| **Data Visibility** | Tiada analytics | Real-time dashboard + reports | ✅ **Management melihat data** |
| **Queue Experience** | Patient tanya "bila lagi?" | App tunjuk nombor giliran real-time | 😊 **Patient satisfaction up** |
| **Security** | Token hardcoded, Firestore open | Token server-side, rules ketat | 🔒 **PDPA compliance** |
| **Maintenance** | 3 system berasingan, duplicate code | Clean architecture, one hub | 🔧 **Dev cost down 50%** |

### 🏆 Why Invest Now

| Reason | Detail |
|--------|--------|
| **First-Mover Advantage** | Hampir **tiada klinik swasta Malaysia** ada slot availability preview + digital loyalty points. He Clinic jadi pioneer. |
| **Patient Stickiness** | Dengan points system, patient akan pilih He Clinic dari klinik lain sebab "ada point saya kat sini." Staff masih boleh upsell semasa WhatsApp confirmation. |
| **Operational Efficiency** | Staff spend less time on phone/manual entry — fokus pada patient care. |
| **Data-Driven Decisions** | Management boleh buat keputusan based on real data — bukan feeling. |
| **Scalable** | Architecture V2 sedia untuk multi-branch expansion, telehealth, AI appointment prediction. |
| **Future-Proof** | Dengan Plato API webhook + Laravel API hub, apa-apa integration masa depan (insurance, BPJS, KKM) plug-and-play. |

---

## APPENDIX: Dokumen Rujukan

| Document | Location | Description |
|----------|----------|-------------|
| Plato API Documentation | `docs/api-guidelines.md` | Official Plato API specs |
| Current System Architecture | `docs/PROJECT.md` | V1 architecture & endpoints |
| Technical Audit | `docs/PROJECT.md` (Known Issues section) | Complete codebase audit findings |
| V2 Pitch Deck | **This document** | V2 proposal for client |

---

> **Dokumen ini disediakan untuk tujuan pitch ke client.**
> Untuk sebarang pertanyaan teknikal, sila refer kepada `docs/api-guidelines.md` (Plato API) dan `docs/PROJECT.md` (current system).
