# He Rewards & Voucher — Manual & Arahan Staf

Dokumen ini untuk staf klinik yang mengendalikan **points (He Rewards)** dan **voucher** di kaunter.
Baca langkah demi langkah. Kalau ragu-ragu, tanya admin atau supervisor.

> **Penting:** Semua redeem (points ATAU voucher) kini boleh dibuat dari **satu tempat** sahaja:
> **Admin Panel → "Redeem at Counter"**. Taip kod, sahkan, tekan Fulfill. Selesai.

---

## 1. Dua sistem berbeza

| | He Rewards (Points) | Voucher |
|---|---|---|
| Apa dia | Patient kumpul point dari belanja, tebus untuk reward. | Admin upload promo diskaun (untuk servis/produk). |
| Siapa buat | Patient redeem sendiri di app. | Patient claim di app. |
| Kod | `RDM-XXXX-YYYY` | `VCH-XXXX-YYYY` |
| Contoh | "ESWT Package" (1000 pts) | "Pakej Kesihatan Asas" (RM 99) |

---

## 2. Menu dalam Admin Panel

| Menu | Kegunaan |
|------|----------|
| **Redeem at Counter** | **Guna ini setiap hari.** Satu search untuk semua kod (points + voucher). |
| **He Rewards → Redemptions** | Senarai redeem points sahaja. |
| **He Rewards → Rewards Catalog** | Tambah/edit produk & servis yang boleh ditebus. |
| **He Rewards → Settings** | Tukar nilai point — **super admin sahaja**. |
| **Offers & Vouchers → Promotions / Vouchers** | Tambah/edit voucher (promo diskaun). |
| **Offers & Vouchers → Voucher Claims** | Senarai voucher yang patient dah claim. |

---

## 3. SOP harian: Proses redeem di kaunter (walk-in)

### Langkah 1 — Minta kod dari patient
- Minta patient buka app.
  - **Voucher**: app → Offers & Vouchers → claim → dapat kod.
  - **Points**: app → My Points → redeem → dapat kod.
- Patient tunjukkan **kod** + QR.

### Langkah 2 — Cari di "Redeem at Counter"
1. Buka **Admin Panel → Redeem at Counter**.
2. Taip **kod** (atau nama / NRIC / phone) dalam kotak search.
3. Tekan **Search** (atau Enter).

### Langkah 3 — Sahkan status
- **Voucher** → pastikan status **Active**.
- **Points** → pastikan status **Pending**.
- Kalau **Fulfilled/Used** → sudah guna. Tolak sopan.
- Kalau **Cancelled** → sudah batal. Tolak sopan.

### Langkah 4 — Apply diskaun / beri reward (MANUAL di Plato)
> Plato tiada function diskaun, jadi anda key-in diskaun **manual** di Plato.
| Jenis | Apa perlu buat |
|-------|----------------|
| **Voucher** | Key-in nilai diskaun (RM) di Plato. |
| **Points — Diskaun** | Key-in nilai RM diskaun di Plato. |
| **Points — Produk** | Beri barang fizikal. |
| **Points — Servis** | Sahkan appointment & jalankan servis. |

### Langkah 5 — Tekan **Fulfill**
- Tekan **Fulfill** → OK. Kod tak boleh guna lagi.

---

## 4. Kalau tersilap / patient batalkan

- Tekan **Cancel** pada baris tersebut.
  - **Points** → point **refund** automatik (+ stok dikembalikan kalau produk).
  - **Voucher** → kembali **Active** (boleh guna semula).
- **Jangan** Cancel kalau reward/diskaun sudah diberi.

---

## 5. Cetak rekod (untuk audit)

- Butang **Print** (ikon printer) pada setiap baris → resit individu.
- Butang **Print All** di header senarai → laporan penuh (ikut filter semasa).
- Berguna bila audit / perlu simpan rekod fizikal.

---

## 6. Situasi biasa & penyelesaian

| Situasi | Apa perlu buat |
|---------|----------------|
| Patient "dah redeem tapi kod hilang" | Cari guna nama / NRIC / phone. |
| Kod expired | Maklum patient. Points tak refund automatik (rujuk admin). Voucher tak boleh guna. |
| Produk habis stok | Patient tak boleh redeem. Minta admin tambah stok di Rewards Catalog. |
| Point tak cukup | App tolak sendiri ("Insufficient points"). |
| Tak jumpa patient | Sahkan patient dah link akaun Plato. Rujuk admin. |

---

## 7. Cara admin tambah VOUCHER (promo diskaun)

1. Buka **Offers & Vouchers → Promotions / Vouchers** → **Add Promotion**.
2. Isi:
   - **Title** — nama promo (cth "Pakej Kesihatan Asas").
   - **Description** — penerangan.
   - **CTA Button Text** — nilai diskaun (cth `RM 99`).
   - **Promo Code** (optional) — kod promo (cth `BASIC99`).
   - **Valid From / Until** — tempoh promo.
   - **Usage Limit** (optional) — had berapa kali boleh claim.
   - **Image** — gambar voucher. **Saiz disyorkan 1200×600px (nisbah 2:1)** supaya cantik dalam app. Max 5MB, JPG/PNG/WebP.
3. Tekan **Create Promotion**.
4. Promo terus muncul dalam app (sekiranya **Active**).

> Voucher = diskaun untuk servis/produk sahaja. Tiada stock / jenis product.

---

## 8. Cara admin tambah REWARD (points: produk / servis)

1. Buka **He Rewards → Rewards Catalog** → **Add Reward**.
2. Isi:
   - **Title**, **Description**.
   - **Type** — `Product` / `Service / Package` / `Discount`.
   - **Points Cost** — berapa points (cth `1000`).
   - **Stock** — produk sahaja (kosong = tiada had).
   - **CTA Button Text** — teks butang app (cth "Redeem Now").
   - **Image** (optional).
3. Tekan **Create Reward**.

---

## 9. Cara super admin tukar nilai point (Settings)

1. **He Rewards → Settings** (super admin sahaja).
2. Tukar: Earn Rate, Redemption Rate, Minimum Redemption, Max Per Txn, Points Expiry (months), Redemption Code Validity (days).
3. Tekan **Save Settings**.

---

## 10. Ringkasan harian (cheat sheet)

1. Minta **kod** dari patient.
2. Buka **Redeem at Counter**.
3. **Search** kod.
4. Sahkan status (**Active/Pending**).
5. Key-in diskaun / beri reward (manual di Plato).
6. Tekan **Fulfill**.
7. Tersilap? Tekan **Cancel**.
8. Nak rekod? Tekan **Print**.
