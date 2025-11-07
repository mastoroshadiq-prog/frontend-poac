# 🌴 Frontend POAC - Aplikasi Manajemen Perkebunan

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Aplikasi frontend berbasis **Flutter Web (Pure)** untuk sistem manajemen POAC (Plan, Organize, Actuate, Control).

## 🚀 Ringkasan Teknis

Dokumen ini mencakup panduan instalasi, konfigurasi, dan struktur kode untuk developer frontend.

### Tumpukan Teknologi (Tech Stack)

| Kategori | Teknologi | Versi | Tujuan |
| :--- | :--- | :--- | :--- |
| **Framework** | Flutter Web | ^3.9.2 | UI Framework (Pure - no HTML/JS) |
| **Bahasa** | Dart | 3.x | Programming Language |
| **HTTP Client** | `http` | ^1.1.0 | Komunikasi REST API |
| **Charts** | `fl_chart` | ^0.68.0 | Visualisasi Data |
| **Indicators** | `percent_indicator` | ^4.2.3 | Indikator Progres |
| **Backend** | Node.js + Express | - | *Konteks: REST API Server* |
| **Database** | Supabase (PostgreSQL) | - | *Konteks: Data Persistence* |
| **Autentikasi** | JWT | - | *Konteks: Role-Based Access Control* |

---

## 🏃‍♂️ Panduan Menjalankan Proyek

### 1. Prasyarat

Sebelum memulai, pastikan Anda memiliki:

* **Flutter SDK** (versi `≥3.9.2`)
* **Backend API** yang sudah berjalan di `http://localhost:3000`
* **JWT Token** untuk autentikasi (dihasilkan dari repositori backend)

```bash
# Verifikasi versi Flutter Anda
flutter --version
````

### 2\. Instalasi

```bash
# 1. Clone repositori
git clone [https://github.com/mastoroshadiq-prog/frontend-poac.git](https://github.com/mastoroshadiq-prog/frontend-poac.git)

# 2. Masuk ke direktori
cd frontend-poac

# 3. Install dependencies
flutter pub get
```

### 3\. Konfigurasi Lingkungan

Edit file `lib/config/app_config.dart` untuk mengarahkan aplikasi ke backend API Anda.

```dart
// lib/config/app_config.dart

class AppConfig {
  // Ganti dengan URL backend Anda
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';

  // Timeout request
  static const Duration requestTimeout = Duration(seconds: 10);
}
```

### 4\. Menjalankan (Development)

```bash
# Jalankan di Chrome
flutter run -d chrome

# Jalankan di Edge
flutter run -d edge

# Jalankan di port spesifik
flutter run -d chrome --web-port=8080
```

### 5\. Membangun (Production)

```bash
# Build aplikasi web untuk production
flutter build web --release

# Output akan tersedia di folder /build/web/
# Deploy folder ini ke web server Anda.
```

-----

## 🏗️ Arsitektur & Struktur Proyek

Proyek ini menggunakan arsitektur sederhana dengan pemisahan tanggung jawab (Separation of Concerns).

```
frontend_keboen/
├── lib/
│   ├── config/
│   │   └── app_config.dart        # Konfigurasi API URL & timeout
│   ├── services/
│   │   └── dashboard_service.dart # Service layer untuk API calls & JWT
│   ├── views/
│   │   ├── dashboard_eksekutif_view.dart  # UI untuk Modul 1
│   │   └── dashboard_operasional_view.dart # UI untuk Modul 2
│   └── main.dart                  # Entry point aplikasi
├── context/
│   └── ... (Dokumentasi & Laporan Verifikasi)
├── web/
│   └── ... (File spesifik web)
├── pubspec.yaml                   # Dependencies
└── README.md                      # File ini
```

### Pola Arsitektur

```
┌─────────────────────────────────────────────┐
│            UI Layer (Views)                 │
│  (dashboard_eksekutif_view.dart, ...)       │
└────────────────┬────────────────────────────┘
                 │ (Memanggil service)
                 ▼
┌─────────────────────────────────────────────┐
│         Service Layer (Services)            │
│  (dashboard_service.dart)                   │
│    * fetchKpiEksekutif(token)             │
│    * fetchDashboardOperasional(token)     │
└────────────────┬────────────────────────────┘
                 │ (Menggunakan HTTP Client)
                 ▼
┌─────────────────────────────────────────────┐
│      HTTP Client Layer (http package)       │
│  - Injeksi JWT Header                       │
│  - Error Handling (401/403/5xx)           │
│  - Response Parsing                         │
└────────────────┬────────────────────────────┘
                 │ (Request ke API)
                 ▼
┌─────────────────────────────────────────────┐
│         Backend REST API (Node.js)          │
└─────────────────────────────────────────────┘
```

-----

## 🔐 Autentikasi (Aspek Frontend)

  * **Mekanisme:** Semua request API yang aman memerlukan **JWT Bearer Token**.
  * **Implementasi:** Token harus disertakan dalam `Authorization` header pada setiap panggilan HTTP.
  * **Service Layer:** File `lib/services/dashboard_service.dart` bertanggung jawab untuk:
    1.  Menambahkan header `Authorization: Bearer $token` ke request.
    2.  Menggunakan `timeout()` sesuai `AppConfig.requestTimeout`.
    3.  Melempar `Exception` spesifik berdasarkan status code (misalnya 401, 403) untuk ditangani oleh UI.

### Penanganan Error (UI)

UI harus mampu menangani error yang dilempar oleh *Service Layer*:

  * 🔒 **401 Unauthorized**: Menampilkan pesan "Silakan Login" (Token tidak valid atau kadaluarsa).
  * 🚫 **403 Forbidden**: Menampilkan pesan "Akses Ditolak" (Role tidak memiliki izin).
  * ❌ **Error Lainnya** (Network, Timeout, 5xx): Menampilkan pesan error umum dengan tombol "Coba Lagi".

-----

## 📖 Prinsip Pengembangan (MPP)

Pengembangan proyek ini mengikuti 3 prinsip inti:

1.  **🎯 SIMPLE (Sederhana)**
      * Kode modular, mudah dibaca, dan *single responsibility*.
      * Widget dipecah menjadi komponen-komponen kecil yang dapat digunakan kembali.
2.  **✅ TEPAT (Akurat)**
      * Logika bisnis dan kalkulasi (jika ada) harus 100% akurat.
      * Penanganan error harus komprehensif (network, auth, parsing).
3.  **📈 PENINGKATAN BERTAHAP (Kaizen)**
      * Pengembangan dilakukan secara inkremental, fitur per fitur.
      * Setiap fitur diverifikasi sebelum melanjutkan ke fitur berikutnya.

-----

## 🤝 Berkontribusi

### Alur Kerja Git

1.  Buat *feature branch* baru:
    ```bash
    git checkout -b feature/nama-fitur-baru
    ```
2.  Lakukan perubahan dan lakukan *test* secara menyeluruh.
3.  Commit perubahan Anda dengan pesan yang jelas:
    ```bash
    git commit -m "feat: Implementasi fitur X"
    ```
4.  Push ke branch Anda:
    ```bash
    git push origin feature/nama-fitur-baru
    ```
5.  Buat *Pull Request* di GitHub.

### Konvensi Pesan Commit

Gunakan format: `<type>: <subject>`

  * **feat**: Fitur baru
  * **fix**: Perbaikan bug
  * **docs**: Perubahan dokumentasi
  * **refactor**: Refaktor kode (tidak ada perubahan fungsional)
  * **test**: Penambahan atau perbaikan tes
  * **chore**: Tugas pemeliharaan (update dependencies, dll)

-----

## 📄 Lisensi

Proyek ini menggunakan lisensi MIT. Lihat file [LICENSE](https://www.google.com/search?q=LICENSE) untuk detailnya.

```
```