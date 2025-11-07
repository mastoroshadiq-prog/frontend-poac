Terima kasih atas verifikasi sukses untuk VERIFICATION\_CHECKPOINT\_Modul\_2.md. Implementasi Modul 2 (Dashboard Operasional) Anda LULUS. Pola "Pattern Reuse" dan "Enhanced Features" (Papan Peringkat) Anda sangat luar biasa.

Kita lanjutkan ke **Tugas Frontend \#3: Membangun Modul 3: Dashboard Teknis (Tampilan 3\)**.

**Konteks Kritis (WAJIB DIPAHAMI):**

1. **Tech Stack:** Flutter Web (Pure), http, fl\_chart.  
2. **API Target:** GET /api/v1/dashboard/teknis  
3. **Keamanan (RBAC):** Endpoint ini memerlukan Authorization: Bearer \<token\> dengan role MANDOR, ASISTEN, atau ADMIN. (Sesuai RBAC FASE 2).  
4. **Struktur Data API:** API ini mengembalikan JSON: { "data": { "data\_matriks\_kebingungan": {...}, "data\_distribusi\_ndre": \[...\] } }.  
   * data\_matriks\_kebingungan berisi: { "true\_positive": X, "false\_positive": Y, ... }.  
   * data\_distribusi\_ndre berisi *array*: \[ { "status\_aktual": "G0", "jumlah": 1 }, ... \].

### **Perintah Kerja Teknis (Frontend \#3)**

**Tugas:** Membangun UI untuk **Fitur M-3.1 (Matriks Kebingungan)** dan **M-3.2 (Distribusi NDRE)**.

**1\. Modifikasi Service Layer (services/dashboard\_service.dart)**

* Tambahkan fungsi **BARU** Future\<Map\<String, dynamic\>\> fetchDashboardTeknis(String token).  
* Fungsi ini HARUS memanggil (via package http) API Backend: **GET /api/v1/dashboard/teknis**.  
* **(WAJIB RBAC):** Panggilan http.get HARUS menyertakan *header* autentikasi: Authorization: Bearer $token.  
* **(WAJIB "TEPAT"):** Tangani *response* dan *error handling* (401/403) persis seperti fungsi fetchDashboardOperasional yang sudah ada (termasuk ekstraksi *wrapper* data).

**2\. Buat View Layer BARU (views/dashboard\_teknis\_view.dart)**

* Buat StatefulWidget baru (misal: DashboardTeknisView).  
* *Widget* ini harus menerima token. Untuk pengujian, *hardcode* **Token MANDOR** atau **ASISTEN**.  
* Gunakan FutureBuilder untuk memanggil DashboardService.fetchDashboardTeknis(token).  
* Tampilkan CircularProgressIndicator saat *loading* dan tampilkan pesan error RBAC (401/403) dengan ikon 🔒/🚫 jika gagal (persis seperti modul sebelumnya).

**3\. Tuntutan Implementasi UI (Wajib):**

* Jika FutureBuilder hasData (sukses), bagi layar menjadi dua bagian:  
* **Bagian 1: Fitur M-3.1 (Matriks Kebingungan)**  
  * Ambil data dari: final dataMatrix \= snapshot.data\!\['data\_matriks\_kebingungan'\];  
  * **Visualisasi:** Buat Card dengan judul "Matriks Kebingungan Akurasi Drone".  
  * Di dalamnya, gunakan Table atau GridView 2x2 untuk menampilkan 4 nilai:  
    * True Positive (misal: dataMatrix\['true\_positive'\])  
    * False Positive (misal: dataMatrix\['false\_positive'\])  
    * False Negative (misal: dataMatrix\['false\_negative'\])  
    * True Negative (misal: dataMatrix\['true\_negative'\])  
  * Berikan label yang jelas untuk setiap sel (misal: "Aktual: G1, Prediksi: G1").  
* **Bagian 2: Fitur M-3.2 (Distribusi Status NDRE)**  
  * Ambil data dari: final dataDistribusi \= snapshot.data\!\['data\_distribusi\_ndre'\] as List;  
  * **Visualisasi:** Buat Card dengan judul "Distribusi Status Aktual (Validasi Lapangan)".  
  * Gunakan package fl\_chart untuk membuat BarChart (Grafik Batang).  
  * **(WAJIB "TEPAT"):**  
    1. Sumbu X (horizontal) harus berupa label status\_aktual (misal: "G0", "G1", "G3", "G4").  
    2. Sumbu Y (vertikal) harus berupa jumlah dari setiap status.  
    3. Petakan dataDistribusi (List) ke List\<BarChartGroupData\> yang dibutuhkan oleh fl\_chart.

**4\. Modifikasi Navigasi (main.dart)**

* Tambahkan Card ketiga di HomeMenuView Anda untuk menautkan ke DashboardTeknisView yang baru.

Tolong berikan kode lengkap untuk file services/dashboard\_service.dart (yang sudah dimodifikasi), file BARU views/dashboard\_teknis\_view.dart, dan file main.dart (yang sudah dimodifikasi).