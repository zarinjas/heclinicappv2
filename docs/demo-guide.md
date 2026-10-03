# Demo — Panduan Penuh: He Rewards + Voucher

Panduan induk untuk demo kedua-dua sistem (points + voucher).
Baca ini dulu, kemudian rujuk fail flow masing-masing.

---

## Fail berkaitan

| Fail | Kandungan |
|---|---|
| `demo-flow-loyalty-points.md` | Flow + SOP He Rewards (points). |
| `demo-flow-voucher.md` | Flow + SOP Voucher. |
| `he-rewards-staff-manual.md` | Manual operasi penuh untuk staf. |

---

## Persediaan demo (sebelum mula)

- [ ] Laravel backend running (`php artisan migrate` + `php artisan serve`).
- [ ] Admin panel boleh login (super admin).
- [ ] Ada reward dalam catalog (cth "ESWT Package 1000 pts").
- [ ] Ada voucher/promo (cth "Pakej Kesihatan Asas RM99") dengan image 1200×600.
- [ ] Ada akaun patient untuk demo redeem/claim.
- [ ] Flutter app running (emulator/device).

---

## Dua sistem — ringkasan cepat

| | He Rewards (Points) | Voucher |
|---|---|---|
| Konsep | Kumpul point dari belanja, tebus reward. | Promo diskaun admin upload, patient claim. |
| Kod | `RDM-XXXX-YYYY` | `VCH-XXXX-YYYY` |
| Nilai | 1 point = RM0.05 | Nilai tetap (cth RM99) |
| Dibuat oleh | Auto (invoice) | Admin upload |

**Persamaan:** kedua-duanya di sahkan di kaunter guna **satu skrin** — **"Redeem at Counter"**.

---

## Skrip demo (dicadangkan)

### Bahagian 1 — Points (earn → redeem)
1. Tunjukkan config: **He Rewards → Settings** (earn rate = 1, expiry = 12 bulan).
2. Tunjukkan catalog: **Rewards Catalog** (ESWT = 1000 pts).
3. App → **My Points**: tunjuk balance.
4. App → redeem diskaun → dapat kod `RDM-...`.
5. App → **He Rewards** → redeem ESWT → book appointment (remark).
6. Admin → **Redeem at Counter** → cari kod → **Fulfill**.
7. Admin → **Redemptions** → tunjuk senarai + **Print**.

### Bahagian 2 — Voucher (upload → claim → fulfill)
1. Admin → **Promotions/Vouchers** → tunjuk tambah promo + image 2:1.
2. App → **Home** → tunjuk design voucher.
3. App → claim → dapat kod `VCH-...`.
4. Admin → **Redeem at Counter** → cari kod → **Fulfill**.
5. Admin → **Voucher Claims** → tunjuk senarai + **Print**.

---

## Titik jualan untuk demo

- **Satu search box** untuk semua kod — staf tak perlu fikir "voucher ke points".
- **Fulfill / Cancel / Print** — rekod audit lengkap.
- **Patient Detail** tunjuk points + voucher + redemptions sekaligus.
- **Manual key-in di Plato** — sebab Plato tiada function diskaun; sistem ni jadi rekod & pengesahan.
- **Design voucher 2:1** — admin upload, muncul cantik di Home & list.
