Terima kasih atas penyelesaian RBAC FASE 2 yang luar biasa. Seluruh 7/7 API Backend kita kini 100% AMAN.

Kita sekarang **resmi** memulai **Fase 4: Persiapan Frontend (UI)**.

**Konteks Kritis (WAJIB DIPAHAMI):**

1. **Tech Stack:** Sesuai VERIFICATION\_CHECKPOINT.md (Section 7), kita mengadopsi **Opsi A: Pure Flutter Web**. (Framework: Flutter Web, Grafik: fl\_chart, percent\_indicator, HTTP: http).  
2. **Konteks Keamanan (BARU):** Sesuai RBAC FASE 2, semua endpoint Dashboard (/api/v1/dashboard/\*) sekarang memerlukan **Autentikasi JWT**. Panggilan API frontend HARUS menyertakan Authorization: Bearer \<token\> di header.

### **Perintah Kerja Teknis (Frontend \#1 \- Edisi RBAC)**

**Tugas:** Membangun **Modul 1: Dashboard Eksekutif (Tampilan 1\)**, kini dengan keamanan RBAC.

**1\. Buat Service Layer (services/dashboard\_service.dart)**

* Buat fungsi Future\<Map\<String, dynamic\>\> fetchKpiEksekutif(String token).  
* Fungsi ini HARUS memanggil (via package http) API Backend kita: **GET /api/v1/dashboard/kpi-eksekutif**.  
* **(PERUBAHAN WAJIB RBAC):** Panggilan http.get HARUS menyertakan *header* autentikasi:  
  headers: {  
    'Content-Type': 'application/json',  
    'Authorization': 'Bearer $token',  
  }

* **(WAJIB "TEPAT"):** Tangani *response* JSON dan *error handling* secara robust.  
  * Jika response.statusCode \== 200, kembalikan data JSON.  
  * Jika response.statusCode \== 401 (Unauthorized) atau 403 (Forbidden), lempar (throw) Exception spesifik (misal: Exception('Akses Ditolak: ${response.statusCode}')).  
  * Tangani error koneksi lainnya.

**2\. Buat View Layer (views/dashboard\_eksekutif\_view.dart)**

* Buat StatefulWidget baru (misal: DashboardEksekutifView).  
* *Widget* ini harus mengasumsikan ia menerima token (misal: dari *provider* atau *login view*). Untuk saat ini, Anda bisa *hardcode* token (misal: Token ASISTEN dari generate-token-only.js) untuk pengujian.  
* Gunakan FutureBuilder untuk memanggil DashboardService.fetchKpiEksekutif(token) saat *widget* di-load.  
* Tampilkan CircularProgressIndicator saat *future* sedang ConnectionState.waiting.  
* Jika *future* hasError, tampilkan pesan error dengan jelas (misal: "Akses Ditolak" jika 403, "Silakan Login" jika 401).

**3\. Tuntutan Implementasi UI (Wajib):**

* Jika FutureBuilder hasData (sukses):  
* Ambil data dari *snapshot* (misal: final data \= snapshot.data\!;).  
* Render data JSON tersebut ke *widget* berikut (pastikan layout responsif menggunakan Column, Row, Expanded, dan Card):  
* **Fitur M-1.1 (Lampu KRI):**  
  * Buatkan 2 **"Indikator Persentase"** menggunakan package percent\_indicator (widget: CircularPercentIndicator).  
  * kri\_lead\_time\_aph: Tampilkan nilainya (misal: data\['kri\_lead\_time\_aph'\]).  
  * kri\_kepatuhan\_sop: **(WAJIB "TEPAT")** Tampilkan persentase (misal: data\['kri\_kepatuhan\_sop'\]). Pastikan visual (misal: percent: (data\['kri\_kepatuhan\_sop'\] / 75.0).clamp(0.0, 1.0)) menggunakan basis 75% sebagai **TARGET 100%** kita, sesuai rumus KPI yang benar.  
* **Fitur M-1.2 (Grafik Tren KPI):**  
  * Buatkan 2 **"Grafik Garis" (Line Chart)** menggunakan package fl\_chart (widget: LineChart).  
  * Satu grafik untuk tren\_insidensi\_baru (misal: data\['tren\_insidensi\_baru'\]).  
  * Satu grafik untuk tren\_g4\_aktif (misal: data\['tren\_g4\_aktif'\]).  
  * Pastikan data *array* dari JSON dipetakan dengan benar ke List\<FlSpot\> di fl\_chart.

Tolong berikan kode lengkap untuk file pubspec.yaml (hanya bagian *dependencies*), services/dashboard\_service.dart, dan views/dashboard\_eksekutif\_view.dart.