Terima kasih atas verifikasi sukses untuk Frontend \#1 (Dashboard Eksekutif). Implementasi Flutter \+ JWT Header \+ Error Handling 401/403 Anda sudah TEPAT.

Kita lanjutkan ke **Tugas Frontend \#2: Membangun Modul 2: Dashboard Operasional (Tampilan 2\)**.

**Konteks Kritis (WAJIB DIPAHAMI):**

1. **Tech Stack:** Flutter Web (Pure), http, percent\_indicator, fl\_chart.  
2. **API Target:** GET /api/v1/dashboard/operasional  
3. **Keamanan (RBAC):** Endpoint ini memerlukan Authorization: Bearer \<token\> dengan role MANDOR, ASISTEN, atau ADMIN.  
4. **Struktur Data API:** API ini mengembalikan JSON: { "data": { "data\_corong": {...}, "data\_papan\_peringkat": \[...\] } }.

### **Perintah Kerja Teknis (Frontend \#2)**

**Tugas:** Membangun UI untuk **Fitur M-2.1 (Corong Alur Kerja)** dan **M-2.2 (Papan Peringkat Tim)**.

**1\. Modifikasi Service Layer (services/dashboard\_service.dart)**

* Tambahkan fungsi **BARU** Future\<Map\<String, dynamic\>\> fetchDashboardOperasional(String token).  
* Fungsi ini HARUS memanggil (via package http) API Backend: **GET /api/v1/dashboard/operasional**.  
* **(WAJIB RBAC):** Panggilan http.get HARUS menyertakan *header* autentikasi: Authorization: Bearer $token.  
* **(WAJIB "TEPAT"):** Tangani *response* dan *error handling* (401/403) persis seperti fungsi fetchKpiEksekutif yang sudah ada.  
* Pastikan Anda mengekstrak dan mengembalikan responseBody\['data'\] (yang berisi data\_corong dan data\_papan\_peringkat).

**2\. Buat View Layer BARU (views/dashboard\_operasional\_view.dart)**

* Buat StatefulWidget baru (misal: DashboardOperasionalView).  
* *Widget* ini harus menerima token. Untuk pengujian, *hardcode* **Token MANDOR** atau **ASISTEN** dari generate-token-only.js.  
* Gunakan FutureBuilder untuk memanggil DashboardService.fetchDashboardOperasional(token).  
* Tampilkan CircularProgressIndicator saat *loading* dan tampilkan pesan error RBAC (401/403) dengan ikon 🔒/🚫 jika gagal (persis seperti Dashboard Eksekutif).

**3\. Tuntutan Implementasi UI (Wajib):**

* Jika FutureBuilder hasData (sukses), bagi layar menjadi dua bagian (misal: dalam ListView atau Column):  
* **Bagian 1: Fitur M-2.1 (Corong Alur Kerja)**  
  * Ambil data dari: final dataCorong \= snapshot.data\!\['data\_corong'\];  
  * Tampilkan 3 **Indikator Progres Linier** menggunakan package percent\_indicator (widget: LinearPercentIndicator).  
  * **Validasi:** percent: (dataCorong\['validasi\_selesai'\] / dataCorong\['target\_validasi'\])  
  * **APH:** percent: (dataCorong\['aph\_selesai'\] / dataCorong\['target\_aph'\])  
  * **Sanitasi:** percent: (dataCorong\['sanitasi\_selesai'\] / dataCorong\['target\_sanitasi'\])  
  * Tampilkan label teks untuk setiap progres (misal: "Validasi: 2 dari 2 Selesai").  
* **Bagian 2: Fitur M-2.2 (Papan Peringkat Tim)**  
  * Ambil data dari: final dataPeringkat \= snapshot.data\!\['data\_papan\_peringkat'\] as List;  
  * Buat DataTable atau ListView.builder untuk menampilkan data peringkat.  
  * **(WAJIB "TEPAT"):** Tampilkan kolom-kolom berikut untuk setiap item dalam *list* (data sudah diurutkan oleh backend):  
    1. Peringkat (misal: \#${index \+ 1})  
    2. ID Pelaksana (misal: item\['id\_pelaksana'\])  
    3. Selesai / Total (misal: ${item\['selesai'\]} / ${item\['total'\]})  
    4. Rate (misal: ${item\['rate'\].toStringAsFixed(1)}%)

Tolong berikan kode lengkap untuk file services/dashboard\_service.dart (yang sudah dimodifikasi) dan file BARU views/dashboard\_operasional\_view.dart.