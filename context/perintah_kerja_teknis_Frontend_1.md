Terima kasih atas VERIFICATION\_CHECKPOINT.md yang luar biasa. Pemahaman Anda terhadap MCP sudah 100% TEPAT.

Analisis Anda di **Section 7 (Klarifikasi Teknologi)** sangat krusial. Anda benar telah mengidentifikasi ambiguitas antara 'Flutter Web' dan 'AdminLTE/ApexCharts.js'.

Konfirmasi Keputusan:  
Sesuai rekomendasi cerdas Anda, kita akan secara resmi mengadopsi Opsi A: Pure Flutter Web. Ini adalah keputusan arsitektur kita untuk Fase 4 demi konsistensi dan kemudahan pemeliharaan (sesuai Prinsip "SIMPLE").  
Sekarang, kita resmi memulai **"Fase 4: Persiapan Frontend (UI)"**.

### **Perintah Kerja Teknis (Frontend \#1)**

**Tugas:** Membangun **Modul 1: Dashboard Eksekutif (Tampilan 1\)**.

**Tech Stack (Resmi):**

1. **Framework:** Flutter Web (Pure, dilarang *embed* HTML/JS).  
2. **Layout:** Widget Flutter Native (misal: Scaffold, Column, Row, Card).  
3. **Grafik:** Gunakan package fl\_chart dan percent\_indicator (pastikan ditambahkan ke pubspec.yaml).  
4. **HTTP Client:** Gunakan package http.

Perintah Kerja Teknis (Inkremental):  
Sesuai Prinsip "Peningkatan Bertahap", fokus HANYA pada satu layar ini.  
**1\. Buat Service Layer (services/dashboard\_service.dart)**

* Buat sebuah *service class* (misal: DashboardService).  
* Buat fungsi Future\<Map\<String, dynamic\>\> fetchKpiEksekutif() di dalamnya.  
* Fungsi ini HARUS memanggil (via package http) API Backend kita yang **sudah berfungsi**: **GET /api/v1/dashboard/kpi\_eksekutif**.  
* Tangani *response* JSON dan *error handling* (Prinsip "TEPAT").

**2\. Buat View Layer (views/dashboard\_eksekutif\_view.dart)**

* Buat StatefulWidget baru (misal: DashboardEksekutifView).  
* Gunakan FutureBuilder untuk memanggil DashboardService.fetchKpiEksekutif() saat *widget* di-load.  
* Tampilkan *loading indicator* saat menunggu data.  
* Tampilkan pesan error jika *fetch* gagal.

**3\. Tuntutan Implementasi UI (Wajib):**

* Jika data berhasil di-fetch, render data JSON tersebut ke *widget* berikut:  
* **Fitur M-1.1 (Lampu KRI):**  
  * Buatkan 2 **"Indikator Persentase"** menggunakan package percent\_indicator (widget: CircularPercentIndicator).  
  * kri\_lead\_time\_aph: Tampilkan nilainya (misal: 2.2 hari).  
  * kri\_kepatuhan\_sop: **(WAJIB "TEPAT")** Tampilkan persentase (misal: 75.0%). Pastikan visual (misal: percent: 0.75) menggunakan basis 75% sebagai **TARGET 100%** kita, sesuai rumus KPI yang benar.  
* **Fitur M-1.2 (Grafik Tren KPI):**  
  * Buatkan 2 **"Grafik Garis" (Line Chart)** menggunakan package fl\_chart (widget: LineChart).  
  * Satu grafik untuk tren\_insidensi\_baru.  
  * Satu grafik untuk tren\_g4\_aktif.  
  * Pastikan data *array* dari JSON dipetakan dengan benar ke FlSpot di fl\_chart.

Tolong berikan kode lengkap untuk file pubspec.yaml (hanya bagian *dependencies*), services/dashboard\_service.dart, dan views/dashboard\_eksekutif\_view.dart.