# Demo — Flow & SOP: He Rewards (Loyalty Points)

Dokumen demo untuk **He Rewards (points)**. Guna untuk tunjukkan aliran penuh:
**earn → redeem → sahkan di kaunter (Fulfill)**.

---

## 1. Ringkasan sistem

| Perkara | Nilai |
|---|---|
| Cara dapat point | Belanja RM1 = 1 point (auto bila invoice di-finalize) |
| Nilai point | 1 point = RM0.05 (100 point = RM5) |
| Minimum tebus | 100 point |
| Maksimum sekali tebus | 1000 point |
| Kod redeem | `RDM-XXXX-YYYY` |
| Kod sah | 30 hari (boleh tukar) |
| Point luput | 12 bulan (boleh tukar) |

**3 jenis redeem:**
1. **Diskaun** (RM off) — tebus N point jadi RM diskaun.
2. **Produk** — tebus point untuk barang fizikal (dengan stok).
3. **Servis / Pakej** — tebus point untuk servis (cth ESWT = 1000 point).

---

## 2. Peranan

| Peranan | Tugas |
|---|---|
| **Super Admin** | Setup config point, tambah reward catalog. |
| **Admin** | Tambah/edit reward (produk/servis). |
| **Staf (kaunter)** | Sahkan redeem, apply diskaun, tekan Fulfill. |
| **Patient** | Kumpul point, redeem dalam app. |

---

## 3. FLOW A — Patient dapat point (Earn)

> Demonstrasi: tunjukkan point naik selepas bayar.

1. Patient buat appointment + dapat rawatan di klinik.
2. Staf **finalize invoice** di Plato.
3. Sistem (Laravel) auto-kira: `points = floor(invoice_total × earn_rate)`.
   - Contoh: invoice RM250 → **250 point**.
4. Point masuk akaun patient + `expires_at` = sekarang + 12 bulan.
5. (Pilihan) FCM push "You earned 250 points!".

**Demo point:** tunjuk invoice RM250 → 250 point masuk akaun.

---

## 4. FLOW B — Patient redeem DISKAUN (RM off)

1. Patient buka app → **My Points**.
2. Tekan **Redeem Points** → pilih jumlah (min 100, gandaan 100, max 1000).
3. Preview: `= RM X.XX discount`.
4. Tekan **Confirm Redemption**.
5. Point **tolak terus**, app papar **kod `RDM-XXXX-YYYY`** + QR.
6. Di kaunter:
   - Staf buka **Admin Panel → Redeem at Counter**.
   - Taip kod → nampak "Points" + nilai RM + status **Pending**.
   - Staf key-in diskaun **manual** di Plato.
   - Tekan **Fulfill**.
7. Selesai — kod jadi **Fulfilled**, tak boleh guna lagi.

---

## 5. FLOW C — Patient redeem PRODUK / SERVIS (He Rewards)

1. Admin tambah reward:
   - **He Rewards → Rewards Catalog → Add Reward**.
   - Isi Title, Description, Type (`Product`/`Service`/`Discount`), Points Cost, Stock (produk), Image, CTA.
2. Patient buka app → **My Points → He Rewards** (atau Home).
3. Pilih reward → **Redeem (XXXX pts)**.
4. Point tolak, stok produk **-1**, dapat kod `RDM-XXXX-YYYY`.
5. Kalau **servis** → app tanya "Book appointment?" → booking flow dengan remark `He Rewards: ... (Code: RDM-...)`.
6. Di kaunter: staf cari kod → **Fulfill** → beri produk / jalankan servis.

---

## 6. SOP KAUNTER (cheat sheet staf)

1. Minta **kod** dari patient.
2. Buka **Redeem at Counter**.
3. **Search** kod (atau nama/NRIC/phone).
4. Sahkan status **Pending**.
5. Key-in diskaun / beri produk / jalankan servis (manual di Plato).
6. Tekan **Fulfill**.
7. Tersilap? Tekan **Cancel** (point refund auto + stok pulih).
8. Nak rekod? Tekan **Print**.

---

## 7. Skrin demo (urutkan)

1. **Admin → He Rewards → Settings** — tunjuk config (earn rate, expiry).
2. **Admin → He Rewards → Rewards Catalog** — tunjuk reward (cth "ESWT Package 1000 pts").
3. **App → My Points** — tunjuk balance + "He Rewards" button.
4. **App → He Rewards** — tunjuk catalog + redeem.
5. **App → My Redemptions** — tunjuk history (Pending/Fulfilled).
6. **Admin → Redeem at Counter** — cari kod → Fulfill.
7. **Admin → He Rewards → Redemptions** — tunjuk senarai + Print.

---

## 8. Edge cases (untuk demo Q&A)

| Soalan | Jawapan |
|---|---|
| Point tak cukup? | App tolak ("Insufficient points"). |
| Produk habis stok? | Tak boleh redeem; admin tambah stok. |
| Kod expired? | Status expired; point tak refund auto. |
| Patient cancel? | Staf tekan Cancel → refund auto. |
