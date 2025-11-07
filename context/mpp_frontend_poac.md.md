# **Model Context Protocol (MCP) \- Dashboard POAC v1.0**

**(Status: 11/6/2025) \- DOKUMEN PRIMING UNTUK AI AGENT COPILOT**

#### **1\. Prinsip & Aturan Wajib (MPP / Buku Aturan)**

Semua pekerjaan HARUS mematuhi tiga prinsip inti berikut:

1. **"SIMPLE" (Sederhana):** Jangan terlalu rumit. Kode harus modular dan mudah dibaca.  
2. **"TEPAT" (Akurat):** Logika bisnis, perhitungan KPI, dan penanganan data HARUS 100% akurat sesuai definisi. Perhitungan kri\_kepatuhan\_sop adalah (Selesai / (Selesai \+ Dikerjakan)), bukan (Selesai / Total).  
3. **"PENINGKATAN BERTAHAP" (Kaizen):** Kita membangun secara inkremental. Setiap perintah adalah satu langkah logis. Kita memverifikasi setiap langkah sebelum melanjutkan.

#### **2\. Arsitektur & Tumpukan Teknologi (Tech Stack)**

* **Backend (Platform B \- Server):** Node.js (Express)  
* **Database:** Supabase (PostgreSQL)  
* **Frontend (Platform B \- Dashboard):** Flutter Web, AdminLTE (Template), ApexCharts.js (Grafik), Leaflet.js (Peta)  
* **Frontend (Platform A \- Aplikasi Mandor):** Flutter (Offline-First)

#### **3\. Arsitektur Sistem (Siklus POAC)**

Proyek ini memiliki dua platform utama yang menutup siklus POAC:

1. **Platform A (Aplikasi Mandor/Flutter):** Sisi "WRITE". Bertugas untuk *melaksanakan* (Actuate) dan *melaporkan* (Control) pekerjaan. Mengirimkan data 5W1H (Log Aktivitas) ke backend.  
2. **Platform B (Dashboard Manajemen/Web):** Sisi "READ". Bertugas untuk *merencanakan* (Plan), *mengorganisir* (Organize), dan *mengontrol* (Control) KPI. Mengonsumsi data dari backend untuk ditampilkan.

#### **4\. Peta API Backend (Status: 100% SELESAI & LULUS VERIFIKASI)**

Seluruh "pipa ledeng" (API Backend) untuk Fase 3 telah selesai dibangun, diverifikasi, dan berfungsi.

**KATEGORI 1: API OUTPUT (READ) \- Untuk Dashboard (Platform B)**

* GET /api/v1/dashboard/kpi\_eksekutif  
  * (Menghitung 4 KPI: kri\_lead\_time\_aph, kri\_kepatuhan\_sop, tren\_insidensi\_baru, tren\_g4\_aktif)  
* GET /api/v1/dashboard/operasional  
  * (Menghitung data\_corong \[M-2.1\] dan data\_papan\_peringkat \[M-2.2\])  
* GET /api/v1/dashboard/teknis  
  * (Menghitung data\_matriks\_kebingungan \[M-3.1\] dan data\_distribusi\_ndre \[M-3.2\])

**KATEGORI 2: API INPUT (WRITE) \- Sub-Proses 1 (Organizing)**

* POST /api/v1/spk  
  * (Fitur M-4.1: Membuat spk\_header baru. Terapkan validasi server-side).  
* POST /api/v1/spk/:id\_spk/tugas  
  * (Fitur M-4.2: Menambah *multi-tugas* (batch array) ke spk\_tugas yang ada).

**KATEGORI 3: API INTEGRASI \- Sub-Proses 2 (Actuating & Control)**

* GET /api/v1/spk/tugas/saya  
  * (Untuk Platform A. **WAJIB JWT**. Mengambil id\_pelaksana dari token, bukan param. Mengembalikan tugas 'BARU'/'DIKERJAKKAN' dengan paginasi).  
* POST /api/v1/log\_aktivitas  
  * (Untuk Platform A. **WAJIB JWT**. Menerima *batch array* log 5W1H. Ini adalah API inti POAC).

#### **5\. Logika Bisnis Inti (WAJIB DIIKUTI)**

Logika berikut adalah "intelijen" dari sistem ini dan harus ada dalam kode.

1. **Keamanan JWT (WAJIB "TEPAT"):**  
   * Pada GET /.../tugas/saya, id\_pelaksana (WHO) **HARUS** diambil dari **Token JWT** pengguna yang login.  
   * Pada POST /log\_aktivitas, id\_petugas (WHO) **HARUS** diambil dari **Token JWT**.  
   * **ALASAN:** Kita tidak boleh mempercayai input (body/param) dari klien untuk identitas pengguna.  
2. **Siklus POAC (AUTO-TRIGGER):**  
   * Logika ini berada di dalam *service* POST /api/v1/log\_aktivitas.  
   * **Saat INSERT log 5W1H berhasil:**  
     1. **AUTO-UPDATE:** Panggil fungsi internal (updateSpkStatus()) untuk memperbarui spk\_tugas terkait (misal: menjadi 'SELESAI').  
     2. **AUTO-TRIGGER (Inti POAC):** Panggil fungsi internal (autoTriggerWorkOrder()) yang menganalisis hasil\_json dari log tersebut:  
        * IF (hasil\_json.status\_aktual \== 'G1 \- Ganoderma Awal') THEN $\\to$ Buat Work Order (SPK) APH baru.  
        * IF (hasil\_json.status\_aktual \== 'G4 \- Mati') THEN $\\to$ Buat Work Order (SPK) Sanitasi baru.

#### **6\. Konteks Alur Kerja (Cara Bekerja dengan Efisien)**

* **Konteks Error:** Kita pernah mengalami error Request Failed: 400 {"error":{"message":"Invalid JSON format..."}}.  
* **Diagnosis:** Error ini terjadi karena *prompt* yang diberikan ke AI Agent (Copilot) **terlalu kompleks** (misal: meminta 2 endpoint API dalam 1 prompt, dengan banyak contoh JSON bersarang).  
* **ATURAN KERJA (WAJIB):** Untuk menghindari kegagalan, semua "Perintah Kerja Teknis" (prompt) HARUS mengikuti **Prinsip "Peningkatan Bertahap"**.  
  * **Satu (1) Perintah \= Satu (1) Tugas Taktis yang Terfokus.**  
  * *Contoh:* Jangan minta "Buat API SPK". Pecah menjadi: 1\. "Buat Cangkang Router/Service SPK". 2\. "Implementasi POST /spk". 3\. "Implementasi POST /spk/:id\_spk/tugas".

#### **7\. Status Saat Ini & Tugas Berikutnya**

* **Status Fase 3 (Backend API):** 100% SELESAI.  
* **Status Fase 4 (Frontend UI):** DIMULAI.  
* **Tugas Aktif Berikutnya:** **Perintah Kerja Teknis (Frontend \#1)**  
  * **Tujuan:** Membangun UI Dashboard Eksekutif (Fitur M-1.1 & M-1.2).  
  * **Tindakan:** Membuat file HTML/JS (AdminLTE) yang memanggil (fetch) API GET /api/v1/dashboard/kpi\_eksekutif dan merendernya menggunakan ApexCharts.js (Radial Gauge & Line Chart).