# Demo — Flow & SOP: Voucher

Dokumen demo untuk **Voucher**. Aliran penuh:
**admin upload promo → patient claim → sahkan di kaunter (Fulfill)**.

---

## 1. Ringkasan sistem

| Perkara | Nilai |
|---|---|
| Apa dia | Promo diskaun yang admin upload (untuk servis/produk) |
| Siapa claim | Patient dalam app |
| Kod voucher | `VCH-XXXX-YYYY` |
| Kod sah | Ikut `valid_until` promo |
| Claim | Sekali setiap patient bagi setiap promo (unique) |
| Had | `usage_limit` (optional) — had berapa kali boleh claim |

> Voucher = **diskaun sahaja** (RM off untuk servis/produk). Tiada stock / jenis product.

---

## 2. Peranan

| Peranan | Tugas |
|---|---|
| **Admin** | Upload/edit voucher (promo diskaun). |
| **Staf (kaunter)** | Sahkan kod, apply diskaun, tekan Fulfill. |
| **Patient** | Claim voucher dalam app. |

---

## 3. FLOW — Admin upload voucher

1. Buka **Admin → Offers & Vouchers → Promotions / Vouchers**.
2. Tekan **Add Promotion**.
3. Isi:
   - **Title** — nama promo (cth "Pakej Kesihatan Asas").
   - **Description** — penerangan.
   - **CTA Button Text** — nilai diskaun (cth `RM 99`).
   - **Promo Code** (optional) — cth `BASIC99`.
   - **Valid From / Until** — tempoh promo.
   - **Usage Limit** (optional) — had claim.
   - **Image** — design voucher. **Saiz disyorkan 1200×600px (nisbah 2:1)**, JPG/PNG/WebP, max 5MB.
4. Tekan **Create Promotion**.
5. Voucher terus muncul dalam app (sekiranya **Active**).

---

## 4. FLOW — Patient claim voucher

1. Patient buka app → **Home ("Deals & Vouchers")** atau **Offers & Vouchers**.
2. Nampak design voucher (image 2:1).
3. Tekan voucher → **Claim**.
4. Sistem semak: aktif, dalam tempoh, belum claim, usage limit.
5. Dapat **kod `VCH-XXXX-YYYY`** + QR.
6. Kod juga tersimpan di **My Vouchers** (tab Active / Used).

---

## 5. FLOW — Sahkan di kaunter (Fulfill)

1. Patient tunjuk kod/QR kepada staf.
2. Staf buka **Admin Panel → Redeem at Counter**.
3. Taip kod → nampak "Voucher" + promo + status **Active**.
4. Staf key-in diskaun **manual** di Plato (Plato tiada function).
5. Tekan **Fulfill**.
6. Kod jadi **Used** — tak boleh guna lagi.

---

## 6. SOP KAUNTER (cheat sheet staf)

1. Minta **kod** dari patient.
2. Buka **Redeem at Counter**.
3. **Search** kod.
4. Sahkan status **Active** (bukan expired/used).
5. Key-in diskaun manual di Plato.
6. Tekan **Fulfill**.
7. Tersilap? Tekan **Cancel** (voucher kembali Active).
8. Nak rekod? Tekan **Print**.

---

## 7. Skrin demo (urutkan)

1. **Admin → Offers & Vouchers → Promotions/Vouchers** — tunjuk tambah promo + image.
2. **App → Home** — tunjuk design voucher di "Deals & Vouchers".
3. **App → Offers & Vouchers** — tunjuk senarai + claim.
4. **App → My Vouchers** — tunjuk kod + status.
5. **Admin → Redeem at Counter** — cari kod → Fulfill.
6. **Admin → Offers & Vouchers → Voucher Claims** — tunjuk senarai + Print.

---

## 8. Edge cases (untuk demo Q&A)

| Soalan | Jawapan |
|---|---|
| Claim dua kali? | Ditolak ("already claimed"). |
| Usage limit penuh? | Ditolak ("reached its usage limit"). |
| Promo expired? | Tak muncul dalam app / tak boleh claim. |
| Kod tersilap Fulfill? | Staf tekan Cancel → kembali Active. |
| Design tak muncul? | Sahkan image uploaded + promo **Active** + saiz 2:1. |
