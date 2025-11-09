Thanks Agent \- Progress kita luar biasa. Kita telah menyelesaikan **SEMUA 3 Tampilan Dashboard READ** (Eksekutif, Operasional, dan Teknis).

Sekarang kita beralih ke UI **INPUT/WRITE** pertama kita: **Modul 4: Manajemen SPK (Sub-Proses 1: Planning & Organizing)**.

**Konteks Kritis (WAJIB DIPAHAMI):**

1. **Tech Stack:** Flutter Web (Pure), http, supabase\_flutter.  
2. **API Target (Sudah Selesai & Aman):**  
   * POST /api/v1/spk (Membuat Header SPK)  
   * POST /api/v1/spk/:id\_spk/tugas (Menambah tugas ke SPK)  
3. **Keamanan (RBAC):** Kedua endpoint ini memerlukan Authorization: Bearer \<token\> dengan role ASISTEN atau ADMIN. (Sesuai RBAC FASE 1).

### **Perintah Kerja Teknis (Frontend \#4)**

**Tugas:** Membangun halaman formulir untuk **Membuat SPK baru dan menambahkan tugas-tugasnya**.

**1\. Buat Service Layer BARU (services/spk\_service.dart)**

* Buat file *service* baru untuk mengelola logika *write* SPK.  
* **(WAJIB "TEPAT"):** Dapatkan token dari SupabaseConfig.client.auth.currentSession di dalam setiap fungsi (sama seperti pola dashboard\_service.dart yang sudah di-refactor).  
* **Fungsi 1: Future\<Map\<String, dynamic\>\> createSpkHeader(String namaSpk, ...)**  
  * Fungsi ini harus menerima input formulir (minimal nama\_spk).  
  * Panggil (via http.post) API: **POST /api/v1/spk**.  
  * Sertakan Authorization: Bearer $token di header.  
  * Kirim *body* JSON (misal: {'nama\_spk': namaSpk, ...}).  
  * Tangani error 401/403 (RBAC).  
  * Kembalikan *response* JSON dari backend (yang seharusnya berisi id\_spk yang baru dibuat).  
* **Fungsi 2: Future\<bool\> addTugasKeSpk(String idSpk, List\<Map\<String, dynamic\>\> daftarTugas)**  
  * Fungsi ini harus menerima idSpk (dari hasil Fungsi 1\) dan *list* data tugas.  
  * Panggil (via http.post) API: **POST /api/v1/spk/:id\_spk/tugas**.  
  * Sertakan Authorization: Bearer $token di header.  
  * Kirim daftarTugas sebagai *body* JSON.  
  * Kembalikan true jika sukses.

**2\. Buat View Layer BARU (views/spk\_create\_view.dart)**

* Buat StatefulWidget baru (misal: SPKCreateView).  
* **UI Form:** Buat formulir sederhana dengan:  
  * TextField untuk nama\_spk.  
  * (Opsional) DatePicker untuk tanggal\_target\_selesai.  
  * (PENTING) UI untuk menambahkan daftar tugas secara dinamis (misal: TextField untuk id\_pelaksana, DropdownButton untuk tipe\_tugas). Untuk saat ini, Anda bisa *hardcode* 1-2 tugas untuk kesederhanaan.  
  * ElevatedButton ("Simpan SPK").  
* **Logika "Simpan SPK" (WAJIB "TEPAT"):**  
  1. Tampilkan CircularProgressIndicator (loading).  
  2. Panggil spkService.createSpkHeader(...) dengan data dari TextField.  
  3. **Ambil newSpkId** dari *response* Fungsi 1\.  
  4. Siapkan daftarTugas (dari UI atau *hardcode*).  
  5. Panggil spkService.addTugasKeSpk(newSpkId, daftarTugas).  
  6. Jika kedua panggilan sukses, tampilkan SnackBar "SPK Berhasil Dibuat" dan navigasi kembali ke HomeMenuView.  
  7. Jika gagal (misal: 403 Akses Ditolak), tampilkan SnackBar error.

**3\. Modifikasi Navigasi (main.dart atau home\_menu\_view.dart)**

* Tambahkan Card keempat di HomeMenuView Anda (atau FloatingActionButton) untuk menautkan ke SPKCreateView yang baru.

Tolong berikan kode untuk file BARU services/spk\_service.dart, file BARU views/spk\_create\_view.dart, dan file main.dart (atau home\_menu\_view.dart) yang telah dimodifikasi.