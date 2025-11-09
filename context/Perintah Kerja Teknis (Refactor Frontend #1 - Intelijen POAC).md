### **Perintah Kerja Teknis (Refactor Frontend \#1 \- Intelijen POAC)**

Tanggal: 8 November 2025

Tujuan: Me-refactor Dashboard Eksekutif (Modul 1\) dari "Hanya Kontrol" menjadi "Ringkasan POAC Penuh".

Konteks: Analisis image\_9bccc0.png, VERIFICATION\_CHECKPOINT\_Modul\_2.md (API Operasional Siap), VERIFICATION\_CHECKPOINT\_Supabase\_Auth.md (Sistem Auth Siap)

---

#### **1\. Konteks & Analisis**

Analisis kita terhadap image\_9bccc0.png (Dashboard Eksekutif saat ini) menyimpulkan bahwa dashboard tersebut **100% reaktif** dan hanya fokus pada **"C" (Control)**. Ini tidak memberikan nilai "Intelijen" penuh kepada Eksekutif.

Refactor ini bertujuan untuk mengubahnya menjadi ringkasan POAC (Plan, Organize, Actuate, Control) yang komprehensif.

Untuk melakukan ini, kita harus **menggabungkan data** dari DUA endpoint API yang sudah ada dan aman:

1. GET /api/v1/dashboard/kpi-eksekutif (data "C" \- *sudah ada di Modul 1*)  
2. GET /api/v1/dashboard/operasional (data "O" dan "A" \- *dari Modul 2*)

---

#### **2\. Tugas 1: Modifikasi Service Layer (Data Gabungan)**

**File:** lib/services/dashboard\_service.dart

**Tujuan:** Mengambil data dari *dua* endpoint API secara paralel (menggunakan satu token) dan menggabungkannya ke dalam satu model data yang bersih.

1. **(BARU) Buat Model Data Gabungan:**  
   * Buat file baru: lib/models/eksekutif\_poac\_data.dart.  
   * Buat kelas EksekutifPOACData di dalamnya.  
   * Kelas ini harus bisa menampung dua Map\<String, dynamic\>: kpiData (untuk hasil dari /kpi-eksekutif) dan operasionalData (untuk hasil dari /operasional).  
2. **(REFACTOR) Modifikasi DashboardService:**  
   * Buat fungsi publik baru: Future\<EksekutifPOACData\> fetchEksekutifPOACData().  
   * Di dalam fungsi ini, pertama-tama panggil \_getAuthToken() (fungsi internal yang sudah ada) untuk mendapatkan token Supabase saat ini.  
   * Gunakan Future.wait untuk memanggil GET /dashboard/kpi-eksekutif dan GET /dashboard/operasional secara paralel. Pastikan **kedua** panggilan menyertakan *header* JWT (Authorization: Bearer $token).  
   * Tambahkan penanganan error yang kuat: Jika *salah satu* panggilan gagal dengan 401 (Unauthorized) atau 403 (Forbidden), seluruh fungsi harus gagal dengan *exception* yang jelas (misal: "Akses Ditolak" atau "Sesi Berakhir").  
   * Setelah kedua panggilan berhasil (status 200), *decode* JSON dari kedua respons.  
   * Ekstrak *wrapper* data dari **kedua** respons (sesuai verifikasi kita sebelumnya, misal: kpiJson\['data'\]).  
   * Kembalikan (return) satu instance dari EksekutifPOACData yang baru, yang telah diisi dengan kedua hasil data tersebut.  
   * Fungsi fetchKpiEksekutif() yang lama sekarang sudah usang (deprecated) dan dapat dihapus atau dibiarkan (namun tidak digunakan oleh *view* ini lagi).

---

#### **3\. Tugas 2: Refactor View Layer (UI 4 Kuadran)**

**File:** lib/views/dashboard\_eksekutif\_view.dart

**Tujuan:** Mengatur ulang UI menjadi 4 kuadran (P, O, A, C) dan mengisi data dari model EksekutifPOACData yang baru.

1. **Perbarui State dan FutureBuilder:**  
   * Ubah FutureBuilder agar memanggil fungsi dashboardService.fetchEksekutifPOACData() yang baru.  
   * Tipe data yang diharapkan FutureBuilder sekarang adalah EksekutifPOACData.  
2. **Bangun Layout 4 Kuadran:**  
   * Di dalam snapshot.hasData, ambil data gabungan: final poacData \= snapshot.data\!;.  
   * Ganti layout ListView atau Column yang ada dengan GridView.count(crossAxisCount: 2, ...) (untuk desktop) atau Column (untuk mobile) yang berisi 4 Card.  
   * Buat 4 *widget* Card terpisah, masing-masing untuk satu kuadran POAC.  
3. **Implementasi Kuadran P (PLAN):**  
   * Buat Card dengan judul Text("P (PLAN) \- Target").  
   * Tampilkan CircularPercentIndicator untuk "KRI Kepatuhan SOP" (data dari poacData.kpiData\['kri\_kepatuhan\_sop'\]).  
   * **WAJIB:** Di bawah *gauge* tersebut, tambahkan Text yang di-*hardcode* sebagai aturan bisnis: Target: 90.0%.  
4. **Implementasi Kuadran O (ORGANIZE):**  
   * Buat Card dengan judul Text("O (ORGANIZE) \- Work in Progress").  
   * Ambil dataCorong dari poacData.operasionalData\['data\_corong'\].  
   * **Hitung dan tampilkan (sebagai StatCard atau ListTile):**  
     * **"Total SPK Aktif":** (jumlah dari target\_validasi \+ target\_aph \+ target\_sanitasi).  
     * **"Tugas 'DIKERJAKAN'":** (selisih antara total target dan total selesai).  
5. **Implementasi Kuadran A (ACTUATE):**  
   * Buat Card dengan judul Text("A (ACTUATE) \- Aktivitas Lapangan").  
   * Ambil dataPapanPeringkat dari poacData.operasionalData\['data\_papan\_peringkat'\].  
   * **Hitung dan tampilkan (sebagai StatCard atau ListTile):**  
     * **"Pelaksana Aktif":** (dataPapanPeringkat.length).  
6. **Implementasi Kuadran C (CONTROL):**  
   * Buat Card dengan judul Text("C (CONTROL) \- Hasil & Dampak").  
   * **PINDAHKAN** sisa *widget* dari UI lama ke dalam *card* ini.  
   * **Data diambil dari poacData.kpiData:**  
     * CircularPercentIndicator untuk "KRI Lead Time APH" (kri\_lead\_time\_aph).  
     * LineChart (fl\_chart) untuk "Tren Insidensi Baru" (tren\_insidensi\_baru).  
     * LineChart (fl\_chart) untuk "Tren Pohon Mati (G4) Aktif" (tren\_g4\_aktif).

---

#### **4\. Kriteria Penerimaan (Acceptance Criteria)**

1. **LULUS** jika: dashboard\_service.dart sekarang memiliki fungsi fetchEksekutifPOACData yang memanggil 2 API (Eksekutif & Operasional) secara paralel.  
2. **LULUS** jika: dashboard\_eksekutif\_view.dart berhasil me-render UI 4 kuadran (P, O, A, C) dalam GridView atau Column.  
3. **LULUS** jika: Kuadran **P** menunjukkan Target 90.0% (hardcoded) di samping Kepatuhan SOP.  
4. **LULUS** jika: Kuadran **O** dan **A** berhasil menampilkan data yang dihitung dari API /operasional (Total SPK, Pelaksana Aktif, dll).  
5. **LULUS** jika: Kuadran **C** berisi 3 metrik sisanya (Lead Time, Tren Insidensi, Tren G4).  
6. **LULUS** jika: Semua penanganan error RBAC (401/403) dari kedua panggilan API tetap berfungsi dengan benar.

