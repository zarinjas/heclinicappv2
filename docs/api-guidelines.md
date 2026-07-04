Dokumentasi Platform Pembangun Plato

1. Pengenalan kepada Platform Pembangun Plato

Platform Pembangun Plato menyediakan infrastruktur yang teguh bagi membolehkan rakan kongsi dan pembangun mengintegrasikan sistem luaran dengan ekosistem penjagaan kesihatan Plato. Berdasarkan keperluan perniagaan dan teknikal anda, terdapat tiga kaedah utama untuk membuat sambungan:

* Plato API: Antara muka RESTful yang membolehkan operasi membaca, mengubah, menambah, atau memadam data secara langsung daripada akaun Plato.
* Apps on Plato: Pembangunan aplikasi peribadi atau aplikasi rakan kongsi yang dipasang di dalam platform Plato untuk memperluaskan fungsi sedia ada.
* Lab/Radiology Linkage: Saluran khusus untuk pusat diagnostik bagi menghantar laporan dan imbasan secara digital terus ke klinik pelanggan tanpa memerlukan faks atau penghantaran fizikal.

Operasi API dilakukan melalui arahan HTTP standard seperti yang diperincikan dalam jadual di bawah:

Arahan	Tujuan
POST	Mencipta objek atau rekod baharu.
GET	Mengambil maklumat satu atau lebih objek.
PUT	Mengemas kini objek sedia ada (hanya sertakan medan yang perlu diubah).
DELETE	Menghapuskan objek atau rekod daripada pangkalan data.

2. Protokol Pengesahan (Authentication)

Keselamatan data dalam Plato diuruskan melalui pengesahan Bearer token. Setiap permintaan API yang dihantar ke pelayan mestilah menyertakan Kunci API (API Key) yang sah dalam pengepala (header) permintaan.

Langkah Menjana Kunci API

Hanya pengguna dengan akses tahap admin dibenarkan menjana kunci ini melalui langkah berikut:

1. Log masuk ke akaun Plato sebagai admin.
2. Navigasi ke System Setup > General Settings.
3. Klik pada tab API.
4. Klik butang Generate API Key.

Format Permintaan

Kunci API yang telah dijana perlu diletakkan dalam pengepala seperti berikut: Authorization: Bearer <Kunci_API_Anda>

Pengesahan Apps on Plato Bagi aplikasi pihak ketiga yang beroperasi sebagai 'Apps on Plato', pengesahan tidak menggunakan Kunci API standard. Sebaliknya, aplikasi akan menggunakan App ID dan App Secret yang dinyatakan dalam pengepala pengesahan setelah keizinan (permissions) yang diperlukan ditetapkan dalam fail Manifest aplikasi tersebut.

(Nota: Untuk integrasi rangkaian makmal, sila pastikan token khas yang dikeluarkan oleh Plato digunakan seperti yang diperincikan dalam Bahagian 7).

3. Had Kadar (Rate Limiting) dan Paginasi

Plato melaksanakan mekanisme had kadar bagi menjamin kestabilan sistem untuk semua pengguna. Paginasi digunakan sebagai kaedah teknikal untuk menguruskan had kadar ini apabila melibatkan set data yang besar.

* Kekangan Had Kadar: Sistem mengehadkan bilangan permintaan API bagi setiap minit. Setiap permintaan API individu dibenarkan mengambil maksimum 20 rekod.
* Kod Status HTTP 429: Jika had kadar dilampaui, sistem akan mengembalikan ralat HTTP 429 (Too Many Requests).
* Pengepala Pemantauan: Gunakan pengepala x-ratelimit-limit (jumlah had) dan x-ratelimit-remaining (baki permintaan) untuk mengawal aliran data aplikasi anda.
* Mekanisme Paginasi: Gunakan parameter pertanyaan current_page untuk menavigasi rekod. Strategi yang disyorkan adalah dengan meneruskan pusingan (loop) sehingga sistem mengembalikan set rekod kosong.

Amalan Terbaik (Best Practices)

1. Gunakan parameter modified_since (dalam format UNIX timestamp) untuk hanya mengambil data yang telah dikemas kini bagi mengurangkan penggunaan kuota API.
2. Laksanakan strategi exponential backoff (penangguhan masa secara berperingkat) bagi permintaan yang menerima ralat kegagalan sementara.
3. Gunakan sistem simpanan sementara (caching) berpusat jika aplikasi anda mempunyai pelbagai modul yang memerlukan data yang sama secara berulang.
4. Pantau pengepala x-ratelimit secara konsisten untuk melakukan throttling pada permintaan API anda.

4. API Invois dan Giliran (Invoice/Queue)

Dalam seni bina maklumat Plato, entri Invois dan Giliran (Queue) adalah sinonim. Setiap kali pesakit dimasukkan ke dalam giliran, satu rekod invois akan dicipta secara automatik, dan sebaliknya.

Urutan Disyorkan (Recommended Sequence)

1. POST /{db}/invoice

Cipta draf invois dan entri giliran untuk pesakit. Anda boleh menyertakan item bil dan maklumat pembayaran secara pilihan dalam langkah ini.

2. POST /{db}/invoice/items

Tambah item bil (ubat, prosedur, atau perkhidmatan) ke dalam invois. Medan given_id mestilah sepadan dengan rekod dalam 'Inventory Setup'.

3. POST /{db}/invoice/finalize

Muktamadkan draf invois. Ambil perhatian bahawa setelah invois dimuktamadkan, ia tidak lagi boleh dipinda melalui API.

4. POST /{db}/invoice/payment

Rekodkan bayaran terhadap invois tersebut. Sebaik sahaja bayaran direkodkan, invois dikunci daripada sebarang pengubahsuaian.

5. POST /{db}/queue/status

Kemas kini status giliran pesakit (contoh: menukar status kepada 'Selesai' atau 'Dalam Rawatan').

5. API Temujanji (Appointments)

Sistem temujanji Plato menggunakan konsep pemetaan kalendar melalui medan color. Setiap warna mewakili ID unik bagi kalendar tertentu di klinik tersebut.

* Medan color: Bertindak sebagai ID Kalendar. Parameter ini mandatori untuk mencipta atau menapis temujanji.
* Carian ID Kalendar: Pembangun boleh mendapatkan senarai kalendar yang sah dan ID warna yang sepadan melalui titik akhir GET /{db}/systemsetup.

Parameter Mendapatkan Slot Masa Tersedia

Untuk mencari slot masa kosong menggunakan POST /{db}/appointment/slots, parameter berikut diperlukan:

* month: Bulan pencarian (Contoh: "Sep 2023"). Peringatan: Medan ini mestilah bulan pada masa hadapan.
* check_for_conflicts: Tatasusunan ID kalendar untuk menyemak ketersediaan.
* simultaneous: Bilangan temujanji selari yang dibenarkan bagi satu slot.
* interval: Selang masa setiap slot (Contoh: 15 bagi setiap 15 minit).
* starttime & endtime: Menentukan jendela waktu operasi dalam format HH:MM.

6. Integrasi Webhook

Webhook membolehkan aplikasi luaran menerima notifikasi masa-nyata apabila berlaku perubahan data dalam Plato (hanya bagi tindakan oleh pengguna, bukan melalui API).

Proses Pendaftaran 3-Langkah

1. Pendaftaran: Hantar POST ke {db}/webhook bersama URL HTTPS anda dan senarai acara (events) yang ingin dilanggan.
2. Terima Token: Plato akan menghantar token JWT ke URL anda melalui acara webhook:token.
3. Aktifkan: Hantar POST ke {db}/webhook/activate dengan menyertakan token tersebut untuk memulakan aliran data.

Struktur Muatan (Payload) Acara

Setiap acara dihantar dalam struktur berikut:

Medan	Jenis	Penerangan
db	String	Identiti pangkalan data Plato.
event	String	Jenis acara (contoh: patient:upsert).
on	Integer	Cap masa Unix (Unix timestamp) acara berlaku.
object_type	String	Jenis entiti (contoh: patient, invoice, appointment).
object_id	String	ID unik bagi objek yang terlibat.

AMARAN: Sebab Penyingkiran Automatik Plato akan memadamkan pendaftaran webhook anda secara automatik jika penghantaran gagal sebanyak 5 kali dalam tempoh 24 jam. Titik akhir (endpoint) anda mestilah memberikan respons HTTP 200 dalam masa 3 saat untuk dianggap berjaya. Terdapat had maksimum 5 webhook bagi setiap pangkalan data.

7. Garis Panduan Rangkaian Makmal dan Radiologi

Bagi pusat diagnostik, integrasi ini membolehkan penghantaran keputusan ujian terus ke 'Results Inbox' klinik.

Proses Onboarding

* List: Gunakan action: list untuk melihat senarai klinik yang telah disambungkan.
* Onboard: Sambungkan klinik baharu menggunakan action: onboard. Parameter clinic (HCI Code) dan database (nama pangkalan data klinik yang tepat) adalah mandatori.
* Offboard: Gunakan action: offboard untuk memutuskan sambungan dengan klinik tertentu.

13 Parameter Penghantaran Data

Data mestilah dihantar dengan parameter berikut:

1. Authorization (Mandatori): Token pengesahan khas yang dikeluarkan oleh Plato.
2. lab (Mandatori): Kod establishment makmal anda.
3. id (Mandatori): ID unik laporan untuk pengurusan de-duplikasi.
4. date (Mandatori): Tarikh laporan (YYYY-MM-DD).
5. ic (Mandatori): No. Kad Pengenalan/Pasport pesakit sebagai identiti utama.
6. name (Mandatori): Nama penuh pesakit sebagai identiti sekunder.
7. clinic (Mandatori): HCI Code atau ID klinik destinasi.
8. sex (Pilihan): Jantina (M, F, atau U).
9. dob (Pilihan): Tarikh lahir (YYYY-MM-DD).
10. testname (Pilihan): Nama ujian atau jenis scan.
11. doctor (Pilihan): Nama doktor yang merujuk.
12. report (Pilihan*): Laporan dalam format HTML.
13. file (Pilihan*): Fail PDF laporan (Maksimum 500 KB).

*Nota Penting: Sekurang-kurangnya satu daripada medan 'report' atau 'file' mestilah disediakan.

Penyelesaian Masalah

Senario	Penyelesaian
Keputusan tidak diterima oleh klinik	Hantar semula data menggunakan id yang sama. Pastikan parameter clinic adalah tepat.
Laporan dihantar ke klinik yang salah	Hantar semula laporan dengan id yang sama tetapi betulkan nilai dalam medan clinic.
Fail corrupt atau maklumat tidak lengkap	Hantar semula laporan dengan id yang sama beserta kandungan report atau file yang telah dibetulkan.
Pembatalan atau pemadaman laporan	Hantar semula rekod dengan id yang sama dan tetapkan medan clinic sebagai "DELETE".

8. Rujukan API Plato (Technical Reference)

Adjustment

* /{db}/adjustment (GET, POST): Menguruskan senarai pelarasan inventori.
* /{db}/adjustment/{adjustment_id} (GET, PUT, DELETE): Operasi pada rekod pelarasan spesifik.
* Parameter: db (path), skip, current_page, start_date, end_date, modified_since.

Appointment

* /{db}/appointment (GET, POST): Menguruskan temujanji. Gunakan medan color untuk ID Kalendar.
* /{db}/appointment/slots (POST): Carian slot masa kosong berdasarkan kriteria klinik.
* /{db}/appointment/calendars (GET): Mendapatkan semua senarai kalendar yang tersedia.

Communication (WhatsApp)

* /{db}/whatsapp/send (POST): Menghantar mesej melalui templat Twilio.
* /{db}/whatsapp/list (GET): Mengambil sejarah mesej dengan sokongan paginasi.

Contact

* /{db}/contact (GET, POST): Menguruskan pangkalan data kenalan luaran (doktor luar/pembekal).
* /{db}/contact/{contact_id} (GET, PUT, DELETE): Menguruskan butiran kenalan tertentu.

Corporate

* /{db}/corporate (GET, POST): Menguruskan maklumat syarikat panel atau korporat.
* /{db}/search/corporate (GET): Mencari korporat melalui nama atau given_id.

DeliveryOrder

* /{db}/deliveryorder (GET, POST): Merekodkan penerimaan stok daripada pembekal.
* Parameter: db (path), supplier, start_date, end_date.

Expense

* /{db}/expense (GET, POST): Merekodkan perbelanjaan operasi klinik.

Facility

* /{db}/facility (GET, POST): Menguruskan maklumat kemudahan seperti makmal rakan kongsi.

Graphing

* /{db}/patient/{patient_id}/graphing (GET): Mengambil data pemplotan graf bagi pesakit tertentu.
* /{db}/patient/graphing/count (GET): Mendapatkan jumlah rekod graphing dalam pangkalan data.

Inventory

* /{db}/inventory (GET, POST): Menguruskan item stok, harga, dan kawalan inventori.
* /{db}/search/inventory (GET): Carian item berdasarkan given_id atau nama.

Invoice / Queue

* /{db}/invoice (GET, POST, PUT): Menguruskan draf invois dan giliran.
* /{db}/invoice/items (POST): Menambah item daripada Inventory Setup ke invois.
* /{db}/invoice/finalize (POST): Proses memuktamadkan bil.
* /{db}/queue/status (GET, POST): Mengambil atau mengubah status giliran semasa.

Letter

* /{db}/letter (GET): Mendapatkan senarai surat rujukan atau surat klinikal.
* /{db}/letter/count (GET): Mendapatkan jumlah surat yang tersimpan.
* Parameter: db (path), skip, current_page, patient_id, modified_since.

Patient

* /{db}/patient (GET, POST): Menguruskan rekod utama pesakit.
* /{db}/patient/merge (POST): Menggabungkan dua fail pesakit. Mandatori: Anda mesti menghantar string "I understand that this action cannot be undone" dalam parameter acknowledge.
* /{db}/patient/{patient_id}/updatelink (GET): Menjana pautan kemas kini kendiri untuk pesakit.

Payment

* /{db}/payment (GET): Mengambil senarai transaksi pembayaran.
* /{db}/invoice/payment (POST): Menambah rekod bayaran ke invois tertentu.

PurchaseOrder & PurchaseRequisition

* /{db}/purchaseorder (GET, POST): Menguruskan pesanan pembelian kepada pembekal.
* /{db}/purchaserequisition (GET, POST): Menguruskan permintaan pembelian dalaman.

Supplier

* /{db}/supplier (GET, POST): Menguruskan pangkalan data pembekal stok.

Task

* /{db}/task (GET, POST): Menguruskan tugasan klinikal atau pentadbiran yang berkaitan dengan pesakit.

Transfer

* /{db}/transfer (GET, POST): Merekodkan pemindahan stok antara lokasi atau cawangan.

Webhook

* /{db}/webhook (GET, POST): Menguruskan pendaftaran dan senarai webhook.
* /{db}/webhook/activate (POST): Mengaktifkan webhook menggunakan token JWT.
