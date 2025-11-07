# Frontend Keboen - Dashboard POAC# Frontend Keboen - Dashboard POAC# Frontend POAC - Dashboard Manajemen Perkebunan# Frontend Keboen - Dashboard POAC



[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)

[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)

Dashboard manajemen perkebunan berbasis **Flutter Web** dengan visualisasi KPI real-time dan RBAC authentication.

[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)

---

[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)Frontend Dashboard berbasis **Flutter Web** untuk sistem manajemen POAC (Plan, Organize, Actuate, Control) perkebunan.

## 🚀 Quick Start



```bash

# Clone & setupFrontend Dashboard berbasis **Flutter Web (Pure)** untuk sistem manajemen POAC (Plan, Organize, Actuate, Control) perkebunan. Aplikasi ini menyediakan visualisasi data real-time untuk monitoring KPI, operasional harian, dan analisis teknis.[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)

git clone https://github.com/mastoroshadiq-prog/frontend-poac.git

cd frontend-poac

flutter pub get

---[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)## 📋 Status Development

# Run development

flutter run -d chrome



# Build production## 📋 Status Development

flutter build web

```



**Requirements:**| Phase | Module | Features | Status |Frontend Dashboard berbasis **Flutter Web (Pure)** untuk sistem manajemen POAC (Plan, Organize, Actuate, Control) perkebunan. Aplikasi ini menyediakan visualisasi data real-time untuk monitoring KPI, operasional harian, dan analisis teknis.- ✅ **Fase 1-3**: Backend API Development (100% Complete)

- Flutter SDK ≥3.9.2

- Backend API running at `http://localhost:3000`|-------|--------|----------|--------|

- JWT Token (generate: `node scripts/generate-token-only.js`)

| **Fase 1-3** | Backend API Development | REST API + Database | ✅ 100% |- ✅ **Fase 3.5**: RBAC Implementation (100% Complete) �

---

| **Fase 3.5** | RBAC Implementation | JWT Auth + Role-based Access | ✅ 100% |

## 📊 Status

| **Fase 4.1** | **Modul 1: Dashboard Eksekutif** | M-1.1 + M-1.2 | ✅ 100% |---- �🚀 **Fase 4**: Frontend UI Development (In Progress)

| Module | Features | Status |

|--------|----------|--------|| **Fase 4.2** | **Modul 2: Dashboard Operasional** | M-2.1 + M-2.2 | ✅ 100% |

| **M-1: Dashboard Eksekutif** | KRI Indicators + Trend Charts | ✅ 100% |

| **M-2: Dashboard Operasional** | Workflow Funnel + Leaderboard | ✅ 100% || **Fase 4.3** | Modul 3: Dashboard Teknis | M-3.1 + M-3.2 | ⏳ Pending |  - ✅ **Modul 1: Dashboard Eksekutif** (100% Complete)

| **M-3: Dashboard Teknis** | Confusion Matrix + NDRE | ⏳ Pending |

| **M-4: Form SPK** | Create/Edit Forms | ⏳ Pending || **Fase 4.4** | Modul 4: Form SPK | M-4.1 + M-4.2 | ⏳ Pending |



**Progress: 4/7 Features (57%)**## 📋 Status Development    - ✅ M-1.1: Lampu KRI (Indikator Persentase)



---**Progress: 4/7 Features (57%)**



## 🏗️ Arsitektur    - ✅ M-1.2: Grafik Tren KPI



```---

UI Layer (Views)

    ↓### ✅ Phase Completed    - ✅ **RBAC Integration**: JWT Authentication ✅ 🔐

Service Layer (DashboardService)

    ↓## 🏗️ Arsitektur

HTTP Client (JWT Auth + Error Handling)

    ↓

Backend API (Node.js + Supabase)

```### Tech Stack



**Tech Stack:**| Phase | Module | Features | Status |## 🏗️ Arsitektur

- Flutter Web 3.9.2 (Pure, no HTML/JS)

- Packages: `http`, `fl_chart`, `percent_indicator`| Category | Technology | Version | Purpose |

- Backend: Node.js + Express + JWT RBAC

|----------|-----------|---------|---------||-------|--------|----------|--------|

---

| **Framework** | Flutter Web | ^3.9.2 | UI Framework (Pure - no HTML/JS) |

## 📖 Features

| **Language** | Dart | 3.x | Programming Language || **Fase 1-3** | Backend API Development | REST API + Database | ✅ 100% |### Tech Stack

### M-1: Dashboard Eksekutif

**Endpoint:** `GET /api/v1/dashboard/kpi-eksekutif` 🔐| **HTTP Client** | http | ^1.1.0 | REST API Communication |



- **M-1.1: Lampu KRI**| **Charts** | fl_chart | ^0.68.0 | Line Charts & Data Visualization || **Fase 3.5** | RBAC Implementation | JWT Auth + Role-based Access | ✅ 100% 🔐 |- **Framework**: Flutter Web (Pure, no HTML/JS embed)

  - KRI Lead Time APH (Target: ≤3 hari)

  - KRI Kepatuhan SOP (Target: ≥75%) ⚠️ Formula: `(Selesai/(Selesai+Dikerjakan)) × 100`| **Progress Indicators** | percent_indicator | ^4.2.3 | Circular & Linear Progress |



- **M-1.2: Grafik Tren**| **Backend** | Node.js + Express | - | REST API Server || **Fase 4.1** | **Modul 1: Dashboard Eksekutif** | M-1.1 + M-1.2 | ✅ 100% |- **HTTP Client**: `http` package

  - Tren Insidensi Baru (G1) - 6 bulan

  - Tren Pohon Mati Aktif (G4) - 6 bulan| **Database** | Supabase (PostgreSQL) | - | Data Persistence |



### M-2: Dashboard Operasional| **Authentication** | JWT | - | Role-Based Access Control || **Fase 4.2** | **Modul 2: Dashboard Operasional** | M-2.1 + M-2.2 | ✅ 100% |- **Charts**: `fl_chart` package

**Endpoint:** `GET /api/v1/dashboard/operasional` 🔐



- **M-2.1: Corong Alur Kerja**

  - Progress Validasi (Blue bar)### Arsitektur Pattern- **Indicators**: `percent_indicator` package

  - Progress APH (Green bar)

  - Progress Sanitasi (Orange bar)



- **M-2.2: Papan Peringkat**```### 🚀 Current Phase: Frontend UI Development- **Backend API**: Node.js + Express + Supabase

  - DataTable dengan ranking pelaksana

  - Top 3 highlighting (🥇🥈🥉)┌─────────────────────────────────────────────┐

  - Color-coded performance rates

│            UI Layer (Views)                 │

---

│  - DashboardEksekutifView                  │

## 🔐 Authentication

│  - DashboardOperasionalView                │**Progress: 4/7 Features (57%)**### Struktur Folder

**Generate JWT Token:**

```bash│  - HomeMenuView                            │

# Di backend repository

node scripts/generate-token-only.js└────────────────┬────────────────────────────┘```

```

                 │

**Usage di Flutter:**

```dart                 ▼- ✅ **Modul 1: Dashboard Eksekutif** (100% Complete)lib/

// Hardcoded (development)

static const String _testToken = 'eyJhbGci...';┌─────────────────────────────────────────────┐



// Or pass via constructor│         Service Layer (Services)            │  - ✅ M-1.1: Lampu KRI (2 Circular Indicators)├── config/

DashboardEksekutifView(token: userToken)

```│  - DashboardService                        │



**RBAC Matrix:**│    * fetchKpiEksekutif(token)             │  - ✅ M-1.2: Grafik Tren KPI (2 Line Charts)│   └── app_config.dart          # Konfigurasi aplikasi (API URL, timeout, dll)



| Role | M-1 Eksekutif | M-2 Operasional | M-3 Teknis | M-4 Form SPK |│    * fetchDashboardOperasional(token)     │

|------|---------------|-----------------|------------|--------------|

| ADMIN | ✅ Full | ✅ Full | ✅ Full | ✅ Full |└────────────────┬────────────────────────────┘  - ✅ RBAC JWT Authentication Integration├── services/

| MANAJER | ✅ Read | ❌ | ✅ Read | ❌ |

| ASISTEN | ✅ Read | ✅ Read | ✅ Read | ✅ Edit |                 │

| MANDOR | ❌ | ✅ Read | ❌ | ✅ Create |

                 ▼  │   └── dashboard_service.dart   # Service layer untuk API calls

**Error Handling:**

- 401 Unauthorized → "Silakan Login"┌─────────────────────────────────────────────┐

- 403 Forbidden → "Akses Ditolak"

│      HTTP Client Layer (http package)       │- ✅ **Modul 2: Dashboard Operasional** (100% Complete)├── views/

---

│  - JWT Authentication                      │

## 🔌 API Format

│  - Error Handling (401/403/5xx)           │  - ✅ M-2.1: Corong Alur Kerja (3 Progress Bars)│   └── dashboard_eksekutif_view.dart  # UI Dashboard Eksekutif

**Request:**

```http│  - Response Parsing                        │

GET /api/v1/dashboard/kpi-eksekutif

Authorization: Bearer YOUR_JWT_TOKEN└────────────────┬────────────────────────────┘  - ✅ M-2.2: Papan Peringkat Tim (DataTable)└── main.dart                    # Entry point aplikasi

```

                 │

**Response:**

```json                 ▼  - ✅ RBAC JWT Authentication Integration```

{

  "kri_lead_time_aph": 2.5,┌─────────────────────────────────────────────┐

  "kri_kepatuhan_sop": 78.3,

  "tren_insidensi_baru": [{"periode": "2024-06", "nilai": 12}],│         Backend REST API (Node.js)          │

  "tren_g4_aktif": [{"periode": "2024-06", "nilai": 45}]

}│  - GET /api/v1/dashboard/kpi-eksekutif    │

```

│  - GET /api/v1/dashboard/operasional      │- ⏳ **Modul 3: Dashboard Teknis** (Pending)## 🚀 Cara Menjalankan

**Config:** Edit `lib/config/app_config.dart` untuk production URL

│  - RBAC Middleware                         │

---

└─────────────────────────────────────────────┘  - ⏳ M-3.1: Matriks Kebingungan

## 📁 Struktur

```

```

lib/  - ⏳ M-3.2: Data Distribusi NDRE### Prerequisites

├── config/app_config.dart              # API URL & timeout

├── services/dashboard_service.dart     # HTTP calls + parsing**Prinsip:**

├── views/

│   ├── dashboard_eksekutif_view.dart   # M-1- **Separation of Concerns**: UI ↔ Service ↔ API1. Flutter SDK (^3.9.2)

│   └── dashboard_operasional_view.dart # M-2

└── main.dart                           # Entry point- **Type Safety**: Explicit type casting



context/                                # Documentation- **Error Handling**: Comprehensive error coverage- ⏳ **Modul 4: Form SPK** (Pending)2. Backend API sudah running di `http://localhost:3000`

├── VERIFICATION_CHECKPOINT_RBAC.md

├── VERIFICATION_CHECKPOINT_Modul_2.md- **Null Safety**: Dart 3.x null-safety enabled

└── LAPORAN_EKSEKUSI_*.md

```  - ⏳ M-4: Form Surat Perintah Kerja3. **🔐 JWT Token** (untuk RBAC - lihat section Authentication di bawah)



---### Struktur Folder



## 🧪 Testing



**Manual Checklist:**```

- [ ] Loading state saat fetch data

- [ ] Error handling (401/403/network/timeout)lib/---### Install Dependencies

- [ ] KRI Kepatuhan SOP formula TEPAT: `(value/75.0).clamp(0,1)`

- [ ] Charts render dengan data 6 bulan├── config/

- [ ] Refresh functionality

- [ ] Responsive layout│   └── app_config.dart          # Konfigurasi API URL, timeout, dll```bash



**Run Tests:**├── services/

```bash

flutter test│   └── dashboard_service.dart   # Service layer untuk API calls## 🏗️ Arsitektur Aplikasiflutter pub get

flutter test --coverage

```├── views/



---│   ├── dashboard_eksekutif_view.dart   # Modul 1: Dashboard Eksekutif```



## 🐛 Troubleshooting│   └── dashboard_operasional_view.dart # Modul 2: Dashboard Operasional



| Issue | Solution |└── main.dart                    # Entry point aplikasi### Tech Stack

|-------|----------|

| Network error | Backend must run at `http://localhost:3000` |

| CORS error | Add CORS middleware di backend |

| 404 Not Found | Verify endpoint exists: `curl http://localhost:3000/api/v1/dashboard/kpi-eksekutif` |context/### Run Development

| Chart kosong | Check console, verify response data structure |

| Token expired | Generate new: `node scripts/generate-token-only.js` |├── LAPORAN_EKSEKUSI_Frontend_1.md



---├── LAPORAN_EKSEKUSI_Frontend_Modul_2.md| Category | Technology | Version | Purpose |```bash



## 📖 Development Principles (MPP)├── LAPORAN_EKSEKUSI_Frontend_RBAC_1.md



1. **SIMPLE** - Modular code, single responsibility├── VERIFICATION_CHECKPOINT_RBAC.md|----------|-----------|---------|---------|# Web (Chrome)

2. **TEPAT** - Accurate business logic (esp. KRI formulas)

3. **PENINGKATAN BERTAHAP** - Incremental commits, test each feature└── VERIFICATION_CHECKPOINT_Modul_2.md



---| **Framework** | Flutter Web | ^3.9.2 | UI Framework (Pure - no HTML/JS) |flutter run -d chrome



## 🤝 Contributingpubspec.yaml                     # Dependencies



```bashanalysis_options.yaml            # Linter configuration| **Language** | Dart | 3.x | Programming Language |

git checkout -b feature/your-feature

git commit -m "feat: Your feature description"README.md                        # This file

git push origin feature/your-feature

``````| **HTTP Client** | http | ^1.1.0 | REST API Communication |# Web (Edge)



**Commit Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`



------| **Charts** | fl_chart | ^0.68.0 | Line Charts & Data Visualization |flutter run -d edge



## 📞 Resources



- **Repository:** https://github.com/mastoroshadiq-prog/frontend-poac.git## 🚀 Quick Start| **Progress Indicators** | percent_indicator | ^4.2.3 | Circular & Linear Progress |

- **Documentation:** See `context/` folder

- **Issues:** GitHub Issues



---### Prerequisites| **Backend** | Node.js + Express | - | REST API Server |# Web dengan port custom



**Built with MPP: SIMPLE. TEPAT. PENINGKATAN BERTAHAP.**



*Version 1.0.0 | Last Updated: Nov 7, 2025 | Status: M-1 & M-2 Complete ✅*1. **Flutter SDK** (≥3.9.2)| **Database** | Supabase (PostgreSQL) | - | Data Persistence |flutter run -d chrome --web-port=8080


   ```bash

   flutter --version| **Authentication** | JWT | - | Role-Based Access Control |```

   # Flutter 3.9.2 • channel stable

   ```



2. **Backend API Running**### Struktur Folder### Build Production

   - URL: `http://localhost:3000`

   - Endpoints available:```bash

     - `GET /api/v1/dashboard/kpi-eksekutif`

     - `GET /api/v1/dashboard/operasional````# Build untuk web production



3. **JWT Token** (for authentication)frontend_keboen/flutter build web

   - Generate from backend: `node scripts/generate-token-only.js`

   - Or use hardcoded test token (development only)├── lib/



### Installation│   ├── config/# Output akan ada di folder: build/web/



```bash│   │   └── app_config.dart                # Konfigurasi API URL, timeout```

# Clone repository

git clone https://github.com/mastoroshadiq-prog/frontend-poac.git│   ├── services/

cd frontend-poac

│   │   └── dashboard_service.dart         # Service layer untuk API calls## 📊 Fitur Dashboard Eksekutif

# Install dependencies

flutter pub get│   ├── views/



# Verify no issues│   │   ├── dashboard_eksekutif_view.dart  # Modul 1: Dashboard Eksekutif### M-1.1: Lampu KRI (Key Risk Indicators)

flutter doctor

```│   │   └── dashboard_operasional_view.dart # Modul 2: Dashboard Operasional



### Run Development Server│   └── main.dart                          # Entry point + Home Menu**1. KRI Lead Time APH**



```bash├── context/- Menampilkan waktu rata-rata penanganan dari deteksi hingga tindakan

# Run on Chrome

flutter run -d chrome│   ├── LAPORAN_EKSEKUSI_Frontend_RBAC_1.md- Visual: Circular Progress Indicator



# Run on Edge│   ├── LAPORAN_EKSEKUSI_Frontend_Modul_2.md- Target: ≤ 3 hari

flutter run -d edge

│   ├── LAPORAN_PERBAIKAN_Response_Format_Fix.md- Formula: Semakin rendah semakin baik

# Run with custom port

flutter run -d chrome --web-port=8080│   ├── VERIFICATION_CHECKPOINT_RBAC.md



# Hot reload: Press 'r' in terminal│   └── VERIFICATION_CHECKPOINT_Modul_2.md**2. KRI Kepatuhan SOP** ⚠️ **WAJIB TEPAT**

# Hot restart: Press 'R' in terminal

```├── pubspec.yaml                           # Dependencies- Menampilkan persentase kepatuhan terhadap SOP



### Build for Production├── analysis_options.yaml                  # Linter configuration- Visual: Circular Progress Indicator



```bash└── README.md                              # This file- Target: ≥ 75%

# Build optimized web app

flutter build web --release```- Formula: `kri_kepatuhan_sop = Selesai / (Selesai + Dikerjakan) * 100`



# Output location: build/web/- **PENTING**: Perhitungan menggunakan basis 75% sebagai target 100%

# Deploy this folder to your web server

### Arsitektur Pattern

# Build with base href (for subdirectory deployment)

flutter build web --base-href /dashboard/### M-1.2: Grafik Tren KPI

```

```

---

┌─────────────────────────────────────────────┐**1. Tren Insidensi Baru (Kasus G1)**

## 📊 Features & Modules

│            UI Layer (Views)                 │- Line Chart menampilkan tren kasus Ganoderma Awal (G1)

### 🎯 Modul 1: Dashboard Eksekutif

│  - DashboardEksekutifView                  │- Data 6 bulan terakhir

**Endpoint:** `GET /api/v1/dashboard/kpi-eksekutif` 🔐  

**Roles:** ASISTEN, MANAJER, ADMIN│  - DashboardOperasionalView                │- Warna: Orange



#### M-1.1: Lampu KRI (Key Risk Indicators)│  - HomeMenuView                            │



Visual indikator performa menggunakan **Circular Progress Indicators**.└────────────────┬────────────────────────────┘**2. Tren Pohon Mati Aktif (G4)**



**1. KRI Lead Time APH**                 │- Line Chart menampilkan tren pohon status G4 (Mati)

- **Deskripsi:** Waktu rata-rata dari deteksi hingga tindakan APH

- **Visual:** Circular Percent Indicator (Orange)                 ▼- Data 6 bulan terakhir

- **Target:** ≤ 3 hari

- **Formula:** `Σ(tanggal_aph - tanggal_validasi) / jumlah_pohon`┌─────────────────────────────────────────────┐- Warna: Red

- **Interpretasi:** Semakin rendah semakin baik

│         Service Layer (Services)            │

**2. KRI Kepatuhan SOP** ⚠️ **CRITICAL**

- **Deskripsi:** Persentase kepatuhan pelaksanaan SOP│  - DashboardService                        │## 🔌 API Integration

- **Visual:** Circular Percent Indicator (Green)

- **Target:** ≥ 75%│    * fetchKpiEksekutif(token)             │

- **Formula:** `(Selesai / (Selesai + Dikerjakan)) × 100`

- **Perhitungan Display:** `(value / 75.0)` untuk normalisasi ke skala 100%│    * fetchDashboardOperasional(token)     │### 🔐 Authentication (RBAC Fase 2)

- **Interpretasi:**

  - 🟢 ≥80%: Excellent└────────────────┬────────────────────────────┘

  - 🟠 60-79%: Good

  - 🔴 <60%: Need Improvement                 │**PENTING:** Semua endpoint Dashboard sekarang memerlukan **JWT Authentication**.



#### M-1.2: Grafik Tren KPI                 ▼



Visual tren historis menggunakan **Line Charts (fl_chart)**.┌─────────────────────────────────────────────┐#### Mendapatkan JWT Token



**1. Tren Insidensi Baru (Kasus G1)**│      HTTP Client Layer (http package)       │

- **Deskripsi:** Grafik tren kasus Ganoderma Awal (G1) per bulan

- **Data:** 6 bulan terakhir│  - JWT Authentication                      │**Option 1: Generate Token (Testing)**

- **Warna:** Orange (`#FF9800`)

- **X-Axis:** Periode (YYYY-MM)│  - Error Handling (401/403/5xx)           │```bash

- **Y-Axis:** Jumlah kasus

│  - Response Parsing                        │# Di backend repository, jalankan:

**2. Tren Pohon Mati Aktif (G4)**

- **Deskripsi:** Grafik tren pohon status G4 (Mati) per bulan└────────────────┬────────────────────────────┘node scripts/generate-token-only.js

- **Data:** 6 bulan terakhir

- **Warna:** Red (`#F44336`)                 │

- **X-Axis:** Periode (YYYY-MM)

- **Y-Axis:** Jumlah pohon                 ▼# Output contoh untuk role ASISTEN:



**Features:**┌─────────────────────────────────────────────┐eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwidXNlcm5hbWUiOiJhc2lzdGVuMSIsInJvbGUiOiJBU0lTVEVOIiwiaWF0IjoxNzMwODQwMDAwLCJleHAiOjE3MzA5MjY0MDB9.SIGNATURE

- ✅ Interactive touch tooltips

- ✅ Grid lines untuk referensi│         Backend REST API (Node.js)          │```

- ✅ Responsive chart sizing

- ✅ Animated transitions│  - GET /api/v1/dashboard/kpi-eksekutif    │



---│  - GET /api/v1/dashboard/operasional      │**Option 2: Login API (Production)**



### 🎯 Modul 2: Dashboard Operasional│  - RBAC Middleware                         │```dart



**Endpoint:** `GET /api/v1/dashboard/operasional` 🔐  └─────────────────────────────────────────────┘// TODO: Implement login screen

**Roles:** MANDOR, ASISTEN, ADMIN

```POST /api/v1/auth/login

#### M-2.1: Corong Alur Kerja (Workflow Funnel)

Body: { "username": "asisten1", "password": "password123" }

Visual progress tahapan kerja menggunakan **Linear Progress Bars**.

**Prinsip:**Response: { "token": "eyJhbGc..." }

**3 Tahapan Progress:**

- **Separation of Concerns**: UI ↔ Service ↔ API```

**1. Validasi**

- **Deskripsi:** Progress validasi lapangan- **Type Safety**: Explicit type casting

- **Visual:** Linear Progress Bar (Blue)

- **Data:** `validasi_selesai / target_validasi`- **Error Handling**: Comprehensive error coverage#### Menggunakan Token

- **Label:** "Validasi: X dari Y Selesai"

- **Null Safety**: Dart 3.x null-safety enabled

**2. APH (Aplikasi Pupuk Hayati)**

- **Deskripsi:** Progress aplikasi pupuk hayati```dart

- **Visual:** Linear Progress Bar (Green)

- **Data:** `aph_selesai / target_aph`---// Di main.dart atau auth provider

- **Label:** "APH: X dari Y Selesai"

const String token = 'YOUR_JWT_TOKEN_HERE';

**3. Sanitasi**

- **Deskripsi:** Progress sanitasi pohon## 🚀 Quick Start

- **Visual:** Linear Progress Bar (Orange)

- **Data:** `sanitasi_selesai / target_sanitasi`// Pass ke DashboardEksekutifView

- **Label:** "Sanitasi: X dari Y Selesai"

### Prerequisiteshome: DashboardEksekutifView(token: token),

**Features:**

- ✅ Percentage display inside bar```

- ✅ Animated progress (800ms)

- ✅ Safe division (prevent div by zero)1. **Flutter SDK** (≥3.9.2)

- ✅ Clamped percentage (0-100%)

   ```bash### Endpoint yang Digunakan

#### M-2.2: Papan Peringkat Tim (Team Leaderboard)

   flutter --version

Visual ranking pelaksana menggunakan **DataTable**.

   # Flutter 3.9.2 • channel stable**GET /api/v1/dashboard/kpi-eksekutif** 🔐

**Columns:**

1. **Peringkat**: #1, #2, #3... (generated)   ```

2. **ID Pelaksana**: UUID pelaksana

3. **Selesai / Total**: "X / Y" format**Headers (WAJIB):**

4. **Rate (%)**: Performance percentage

2. **Backend API Running**```http

**Enhanced Features:**

- 🥇 **Rank #1**: Gold background + trophy icon   - URL: `http://localhost:3000`Content-Type: application/json

- 🥈 **Rank #2**: Silver background + trophy icon

- 🥉 **Rank #3**: Bronze background + trophy icon   - Endpoints available:Accept: application/json

- 🎨 **Color-coded Rates**:

  - Green (≥80%): High performance     - `GET /api/v1/dashboard/kpi-eksekutif`Authorization: Bearer YOUR_JWT_TOKEN_HERE

  - Orange (50-79%): Medium performance

  - Red (<50%): Low performance     - `GET /api/v1/dashboard/operasional````

- 📱 Horizontal scrolling untuk responsiveness

- 📊 Empty state handling



---3. **JWT Token** (for authentication)**Response Format:**



## 🔐 Authentication & RBAC   - Generate from backend: `node scripts/generate-token-only.js````json



### JWT Authentication   - Or use hardcoded test token (development only){



Semua endpoint dashboard memerlukan **JWT Bearer Token**.  "kri_lead_time_aph": 2.5,



#### Generate Token (Development)### Installation  "kri_kepatuhan_sop": 78.3,



**Backend Script:**  "tren_insidensi_baru": [

```bash

# Di backend repository```bash    {"periode": "2024-06", "nilai": 12},

cd backend

node scripts/generate-token-only.js# Clone repository    {"periode": "2024-07", "nilai": 8},



# Output example:git clone https://github.com/mastoroshadiq-prog/frontend-poac.git    ...

# ==================

# ASISTEN Token:cd frontend-poac  ],

# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ==================  "tren_g4_aktif": [

```

# Install dependencies    {"periode": "2024-06", "nilai": 45},

**Token Payload Example:**

```jsonflutter pub get    {"periode": "2024-07", "nilai": 38},

{

  "id_pihak": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12",    ...

  "nama_pihak": "Asisten Citra",

  "role": "ASISTEN",# Verify no issues  ]

  "iat": 1762497851,

  "exp": 1763102651flutter doctor}

}

`````````



#### Using Token in Flutter



**Option 1: Hardcoded (Development Only)**### Run Development Server**Error Responses:**

```dart

// In dashboard_eksekutif_view.dart or dashboard_operasional_view.dart- **401 Unauthorized**: Token tidak valid atau expired

static const String _testToken = 'eyJhbGci...';

``````bash- **403 Forbidden**: User tidak memiliki permission untuk endpoint ini



**Option 2: Pass as Parameter (Recommended)**# Run on Chrome- **404 Not Found**: Endpoint tidak ditemukan

```dart

// In main.dartflutter run -d chrome- **500 Server Error**: Error di backend

const String userToken = 'YOUR_JWT_TOKEN';



MaterialApp(

  home: DashboardEksekutifView(token: userToken),# Run on Edge### Konfigurasi API

)

```flutter run -d edge



**Option 3: From Auth Provider (Production)**Edit file `lib/config/app_config.dart`:

```dart

// TODO: Implement authentication system# Run with custom port

final authProvider = Provider.of<AuthProvider>(context);

final token = authProvider.token;flutter run -d chrome --web-port=8080```dart



Navigator.push(class AppConfig {

  context,

  MaterialPageRoute(# Hot reload: Press 'r' in terminal  // Ganti dengan URL production

    builder: (_) => DashboardEksekutifView(token: token),

  ),# Hot restart: Press 'R' in terminal  static const String apiBaseUrl = 'https://your-backend-url.com/api/v1';

);

``````  



### RBAC Roles & Permissions  // Timeout request (default: 10 detik)



| Role | Dashboard Eksekutif | Dashboard Operasional | Dashboard Teknis | Form SPK |### Build for Production  static const Duration requestTimeout = Duration(seconds: 10);

|------|--------------------|-----------------------|------------------|----------|

| **ADMIN** | ✅ Full Access | ✅ Full Access | ✅ Full Access | ✅ Full Access |}

| **MANAJER** | ✅ Read Only | ❌ No Access | ✅ Read Only | ❌ No Access |

| **ASISTEN** | ✅ Read Only | ✅ Read Only | ✅ Read Only | ✅ Create/Edit |```bash```

| **MANDOR** | ❌ No Access | ✅ Read Only | ❌ No Access | ✅ Create Only |

# Build optimized web app

### Error Handling

flutter build web --release## 🎨 UI/UX Features

**401 Unauthorized** 🔒

- **Icon:** Orange lock (`Icons.lock_outline`)

- **Title:** "Silakan Login"

- **Message:** "Token tidak valid atau sudah kadaluarsa (401)"# Output location: build/web/### Loading State

- **Action:** Redirect to login (future) or retry

# Deploy this folder to your web server- Circular Progress Indicator dengan teks "Memuat data KPI..."

**403 Forbidden** 🚫

- **Icon:** Red block (`Icons.block`)

- **Title:** "Akses Ditolak"

- **Message:** "Anda tidak memiliki izin untuk mengakses data ini (403)"# Build with base href (for subdirectory deployment)### Error Handling (Enhanced untuk RBAC)

- **Action:** Show error, provide back navigation

flutter build web --base-href /dashboard/- 🔒 **401 Unauthorized**: Orange lock icon + "Silakan Login"

**Other Errors** ❌

- Network errors```- 🚫 **403 Forbidden**: Red block icon + "Akses Ditolak"

- Timeout (10 seconds)

- Server errors (5xx)- Icon error dengan pesan yang jelas

- Parse errors (invalid JSON)

---- Tombol "Coba Lagi" untuk retry

---

- Error messages yang informatif:

## 🔌 API Integration

## 📊 Features & Modules  - Network error

### Endpoint: Dashboard Eksekutif

  - Timeout error

**GET /api/v1/dashboard/kpi-eksekutif** 🔐

### 🎯 Modul 1: Dashboard Eksekutif  - Server error (5xx)

**Headers (WAJIB):**

```http  - Not found (404)

Content-Type: application/json

Accept: application/json**Endpoint:** `GET /api/v1/dashboard/kpi-eksekutif` 🔐  - Parse error (invalid JSON)

Authorization: Bearer YOUR_JWT_TOKEN_HERE

```



**Response Format:****Roles:** ASISTEN, MANAJER, ADMIN### Refresh Data

```json

{- Pull-to-refresh gesture

  "kri_lead_time_aph": 2.5,

  "kri_kepatuhan_sop": 78.3,#### M-1.1: Lampu KRI (Key Risk Indicators)- Tombol refresh di AppBar

  "tren_insidensi_baru": [

    {"periode": "2024-06", "nilai": 12},- Auto-reload saat error recovery

    {"periode": "2024-07", "nilai": 8}

  ],Visual indikator performa menggunakan **Circular Progress Indicators**.

  "tren_g4_aktif": [

    {"periode": "2024-06", "nilai": 45},### Responsive Design

    {"periode": "2024-07", "nilai": 38}

  ]**1. KRI Lead Time APH**- Layout adaptif untuk berbagai ukuran layar

}

```- **Deskripsi:** Waktu rata-rata dari deteksi hingga tindakan APH- Card-based design untuk modular components



### Endpoint: Dashboard Operasional- **Visual:** Circular Percent Indicator (Orange)- Color-coded indicators:



**GET /api/v1/dashboard/operasional** 🔐- **Target:** ≤ 3 hari  - 🟢 Green: Performa baik (≥80%)



**Headers (WAJIB):**- **Formula:** `Σ(tanggal_aph - tanggal_validasi) / jumlah_pohon`  - 🟠 Orange: Performa sedang (60-80%)

```http

Content-Type: application/json- **Interpretasi:** Semakin rendah semakin baik  - 🔴 Red: Performa buruk (<60%)

Accept: application/json

Authorization: Bearer YOUR_JWT_TOKEN_HERE

```

**2. KRI Kepatuhan SOP** ⚠️ **CRITICAL**## 📖 Prinsip Development (MPP)

**Response Format:**

```json- **Deskripsi:** Persentase kepatuhan pelaksanaan SOP

{

  "corong_alur_kerja": {- **Visual:** Circular Percent Indicator (Green)Semua development mengikuti **3 Prinsip Inti**:

    "validasi": {"selesai": 80, "target": 100},

    "aph": {"selesai": 65, "target": 100},- **Target:** ≥ 75%

    "sanitasi": {"selesai": 40, "target": 100}

  },- **Formula:** `(Selesai / (Selesai + Dikerjakan)) × 100`### 1. SIMPLE (Sederhana)

  "papan_peringkat": [

    {- **Perhitungan Display:** `(value / 75.0)` untuk normalisasi ke skala 100%- Kode modular dan mudah dibaca

      "id_pelaksana": "uuid-1",

      "selesai": 45,- **Interpretasi:** - Satu file = satu tanggung jawab

      "total": 50

    }  - 🟢 ≥80%: Excellent- Widget reusable dengan parameter yang jelas

  ]

}  - 🟠 60-79%: Good

```

  - 🔴 <60%: Need Improvement### 2. TEPAT (Akurat)

### Konfigurasi API

- Logika bisnis 100% akurat

Edit file `lib/config/app_config.dart`:

#### M-1.2: Grafik Tren KPI- Error handling komprehensif

```dart

class AppConfig {- Perhitungan KPI sesuai definisi bisnis

  // Ganti dengan URL production

  static const String apiBaseUrl = 'https://your-backend-url.com/api/v1';Visual tren historis menggunakan **Line Charts (fl_chart)**.- **KHUSUS**: Formula KRI Kepatuhan SOP harus TEPAT!

  

  // Timeout request (default: 10 detik)

  static const Duration requestTimeout = Duration(seconds: 10);

}**1. Tren Insidensi Baru (Kasus G1)**### 3. PENINGKATAN BERTAHAP (Kaizen)

```

- **Deskripsi:** Grafik tren kasus Ganoderma Awal (G1) per bulan- Build secara inkremental

---

- **Data:** 6 bulan terakhir- 1 fitur = 1 commit yang fokus

## 🎨 UI/UX Features

- **Warna:** Orange (`#FF9800`)- Verifikasi setiap langkah sebelum lanjut

### Loading State

- Circular Progress Indicator dengan teks "Memuat data KPI..."- **X-Axis:** Periode (YYYY-MM)- No big-bang development



### Error Handling (Enhanced untuk RBAC)- **Y-Axis:** Jumlah kasus

- 🔒 **401 Unauthorized**: Orange lock icon + "Silakan Login"

- 🚫 **403 Forbidden**: Red block icon + "Akses Ditolak"## 🧪 Testing Checklist

- Icon error dengan pesan yang jelas

- Tombol "Coba Lagi" untuk retry**2. Tren Pohon Mati Aktif (G4)**

- Error messages yang informatif:

  - Network error- **Deskripsi:** Grafik tren pohon status G4 (Mati) per bulan### Manual Testing

  - Timeout error

  - Server error (5xx)- **Data:** 6 bulan terakhir- [ ] Aplikasi bisa dijalankan tanpa error

  - Not found (404)

  - Parse error (invalid JSON)- **Warna:** Red (`#F44336`)- [ ] Loading state muncul saat fetch data



### Refresh Data- **X-Axis:** Periode (YYYY-MM)- [ ] Error state muncul saat backend offline

- Pull-to-refresh gesture

- Tombol refresh di AppBar- **Y-Axis:** Jumlah pohon- [ ] Data KRI ditampilkan dengan benar

- Auto-reload saat error recovery

- [ ] Perhitungan persentase KRI Kepatuhan SOP TEPAT

### Responsive Design

- Layout adaptif untuk berbagai ukuran layar**Features:**- [ ] Line chart menampilkan tren dengan benar

- Card-based design untuk modular components

- Color-coded indicators:- ✅ Interactive touch tooltips- [ ] Pull-to-refresh berfungsi

  - 🟢 Green: Performa baik (≥80%)

  - 🟠 Orange: Performa sedang (60-80%)- ✅ Grid lines untuk referensi- [ ] Tombol refresh di AppBar berfungsi

  - 🔴 Red: Performa buruk (<60%)

- ✅ Responsive chart sizing- [ ] Responsive di berbagai ukuran layar web

---

- ✅ Animated transitions

## 📖 Development Principles (MPP)

### Integration Testing

Semua development mengikuti **Metode Pengembangan POAC (MPP)**:

---- [ ] Service layer memanggil endpoint yang benar

### 1. 🎯 SIMPLE (Sederhana)

- [ ] Response JSON di-parse dengan benar

**Prinsip:**

- Kode mudah dibaca dan dipahami### 🎯 Modul 2: Dashboard Operasional- [ ] Error dari backend di-handle dengan baik

- Satu file = satu tanggung jawab (SRP)

- Widget kecil dan reusable- [ ] Timeout handling bekerja

- Minimal dependencies

**Endpoint:** `GET /api/v1/dashboard/operasional` 🔐

**Implementasi:**

- `app_config.dart`: Hanya konfigurasi## 🐛 Troubleshooting

- `dashboard_service.dart`: Hanya API calls

- `dashboard_eksekutif_view.dart`: Hanya UI Modul 1**Roles:** MANDOR, ASISTEN, ADMIN

- `dashboard_operasional_view.dart`: Hanya UI Modul 2

### Error: "Network error"

### 2. ✅ TEPAT (Akurat)

#### M-2.1: Corong Alur Kerja (Workflow Funnel)**Solusi**: Pastikan backend API sudah running di `http://localhost:3000`

**Prinsip:**

- Logika bisnis 100% akurat

- Formula perhitungan sesuai requirement

- Error handling komprehensifVisual progress tahapan kerja menggunakan **Linear Progress Bars**.### Error: "Endpoint tidak ditemukan (404)"

- Type safety enforced

**Solusi**: Verifikasi bahwa endpoint `GET /api/v1/dashboard/kpi_eksekutif` tersedia di backend

**Implementasi:**

- KRI Kepatuhan SOP: `(value / 75.0).clamp(0.0, 1.0)` - TEPAT!**3 Tahapan Progress:**

- Safe division: `selesai / max(target, 1)` - Prevent div by zero

- Type casting: `as double`, `as int` - Explicit types### Error: "CORS error" (di browser)

- Null checks: `data?['field'] ?? defaultValue` - Null safety

**1. Validasi****Solusi**: Tambahkan CORS middleware di backend Express:

### 3. 📈 PENINGKATAN BERTAHAP (Kaizen)

- **Deskripsi:** Progress validasi lapangan```javascript

**Prinsip:**

- Incremental development (1 feature at a time)- **Visual:** Linear Progress Bar (Blue)app.use(cors({

- Test after each feature

- Commit small, focused changes- **Data:** `validasi_selesai / target_validasi`  origin: 'http://localhost:YOUR_FLUTTER_PORT',

- Build on previous foundation

- **Label:** "Validasi: X dari Y Selesai"  credentials: true

**Implementasi:**

- Fase 1: Config & Service Layer}));

- Fase 2: Modul 1 (M-1.1 → M-1.2)

- Fase 3: RBAC Integration**2. APH (Aplikasi Pupuk Hayati)**```

- Fase 4: Modul 2 (M-2.1 → M-2.2)

- Fase 5: Next modules...- **Deskripsi:** Progress aplikasi pupuk hayati



---- **Visual:** Linear Progress Bar (Green)### Chart tidak muncul / kosong



## 🧪 Testing- **Data:** `aph_selesai / target_aph`**Solusi**: 



### Manual Testing Checklist- **Label:** "APH: X dari Y Selesai"1. Cek response API memiliki data tren



**Basic Functionality:**2. Cek console untuk error parsing data

- [ ] Aplikasi bisa dijalankan tanpa error

- [ ] Loading state muncul saat fetch data**3. Sanitasi**3. Verifikasi struktur data sesuai format yang diharapkan

- [ ] Error state muncul saat backend offline

- [ ] Data KRI ditampilkan dengan benar- **Deskripsi:** Progress sanitasi pohon

- [ ] Perhitungan persentase KRI Kepatuhan SOP TEPAT

- [ ] Line chart menampilkan tren dengan benar- **Visual:** Linear Progress Bar (Orange)### Indicator persentase tidak akurat

- [ ] Pull-to-refresh berfungsi

- [ ] Tombol refresh di AppBar berfungsi- **Data:** `sanitasi_selesai / target_sanitasi`**Solusi**: Verifikasi formula di `_buildKriCard()`:

- [ ] Responsive di berbagai ukuran layar web

- **Label:** "Sanitasi: X dari Y Selesai"- Untuk Kepatuhan SOP: `percent = (value / target).clamp(0.0, 1.0)`

**RBAC Testing:**

- [ ] 401 error ditampilkan saat token invalid- Pastikan target = 75.0

- [ ] 403 error ditampilkan saat role tidak sesuai

- [ ] Token Bearer dikirim di header**Features:**

- [ ] Expired token dihandle dengan baik

- ✅ Percentage display inside bar## 📝 Next Steps

**Integration Testing:**

- [ ] Service layer memanggil endpoint yang benar- ✅ Animated progress (800ms)

- [ ] Response JSON di-parse dengan benar

- [ ] Error dari backend di-handle dengan baik- ✅ Safe division (prevent div by zero)Setelah Modul 1 selesai, lanjut ke:

- [ ] Timeout handling bekerja

- ✅ Clamped percentage (0-100%)- [ ] **Modul 2**: Dashboard Operasional (M-2.1 & M-2.2)

### Unit Testing (Future)

- [ ] **Modul 3**: Dashboard Teknis (M-3.1 & M-3.2)

```bash

# Run all tests#### M-2.2: Papan Peringkat Tim (Team Leaderboard)- [ ] **Modul 4**: Form SPK (M-4.1 & M-4.2)

flutter test

- [ ] **Authentication**: JWT Login & Token Management

# Run specific test file

flutter test test/services/dashboard_service_test.dartVisual ranking pelaksana menggunakan **DataTable**.- [ ] **State Management**: Provider/Riverpod untuk global state



# Run with coverage- [ ] **Routing**: Multi-page navigation

flutter test --coverage

```**Columns:**



---1. **Peringkat**: #1, #2, #3... (generated)## 📞 Support



## 🐛 Troubleshooting2. **ID Pelaksana**: UUID pelaksana



### Error: "Network error"3. **Selesai / Total**: "X / Y" formatUntuk pertanyaan atau issue, hubungi tim development atau buat issue di repository.



**Solusi**: Pastikan backend API sudah running di `http://localhost:3000`4. **Rate (%)**: Performance percentage



```bash---

# Di terminal backend

npm run dev**Enhanced Features:**

# atau

node index.js- 🥇 **Rank #1**: Gold background + trophy icon**Dibuat dengan Prinsip MPP**: SIMPLE. TEPAT. PENINGKATAN BERTAHAP.

```

- 🥈 **Rank #2**: Silver background + trophy icon

### Error: "Endpoint tidak ditemukan (404)"

- 🥉 **Rank #3**: Bronze background + trophy icon

**Solusi**: Verifikasi bahwa endpoint tersedia di backend- 🎨 **Color-coded Rates**:

  - Green (≥80%): High performance

```bash  - Orange (50-79%): Medium performance

# Test endpoint with curl  - Red (<50%): Low performance

curl http://localhost:3000/api/v1/dashboard/kpi-eksekutif \- 📱 Horizontal scrolling untuk responsiveness

  -H "Authorization: Bearer YOUR_TOKEN"- 📊 Empty state handling

```

---

### Error: "CORS error" (di browser)

## 🔐 Authentication & RBAC

**Solusi**: Tambahkan CORS middleware di backend Express:

### JWT Authentication

```javascript

const cors = require('cors');Semua endpoint dashboard memerlukan **JWT Bearer Token**.



app.use(cors({#### Generate Token (Development)

  origin: 'http://localhost:YOUR_FLUTTER_PORT',

  credentials: true**Backend Script:**

}));```bash

```# Di backend repository

cd backend

### Chart tidak muncul / kosongnode scripts/generate-token-only.js



**Solusi**: # Output example:

1. Cek response API memiliki data tren# ==================

2. Cek console untuk error parsing data# ASISTEN Token:

3. Verifikasi struktur data sesuai format yang diharapkan# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ==================

```dart```

// Debug: Print response

print('Response: $responseBody');**Token Payload Example:**

``````json

{

### Indicator persentase tidak akurat  "id_pihak": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12",

  "nama_pihak": "Asisten Citra",

**Solusi**: Verifikasi formula di `_buildKriCard()`:  "role": "ASISTEN",

- Untuk Kepatuhan SOP: `percent = (value / 75.0).clamp(0.0, 1.0)`  "iat": 1762497851,

- Pastikan target = 75.0  "exp": 1763102651

}

### Token expired terus-menerus```



**Solusi**: Generate token baru dengan expiry lebih lama#### Using Token in Flutter



```javascript**Option 1: Hardcoded (Development Only)**

// Di backend: scripts/generate-token-only.js```dart

// Ubah expiresIn: '7d' (7 hari)// In dashboard_eksekutif_view.dart or dashboard_operasional_view.dart

const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });static const String _testToken = 'eyJhbGci...';

``````



---**Option 2: Pass as Parameter (Recommended)**

```dart

## 📝 Next Steps// In main.dart

const String userToken = 'YOUR_JWT_TOKEN';

### Roadmap

MaterialApp(

- [ ] **Modul 3**: Dashboard Teknis (M-3.1 & M-3.2)  home: DashboardEksekutifView(token: userToken),

  - M-3.1: Matriks Kebingungan (Confusion Matrix))

  - M-3.2: Data Distribusi NDRE```

  

- [ ] **Modul 4**: Form SPK (M-4.1 & M-4.2)**Option 3: From Auth Provider (Production)**

  - M-4.1: Form Input Surat Perintah Kerja```dart

  - M-4.2: Preview & Submit SPK// TODO: Implement authentication system

  final authProvider = Provider.of<AuthProvider>(context);

- [ ] **Authentication**: JWT Login & Token Managementfinal token = authProvider.token;

  - Login screen

  - Token storage (SharedPreferences)Navigator.push(

  - Auto-refresh token  context,

  - Logout functionality  MaterialPageRoute(

      builder: (_) => DashboardEksekutifView(token: token),

- [ ] **State Management**: Provider/Riverpod untuk global state  ),

  - Auth state);

  - Dashboard data caching```

  - User profile management

  ### RBAC Roles & Permissions

- [ ] **Routing**: Multi-page navigation

  - Named routes| Role | Dashboard Eksekutif | Dashboard Operasional | Dashboard Teknis | Form SPK |

  - Route guards (RBAC)|------|--------------------|-----------------------|------------------|----------|

  - Deep linking| **ADMIN** | ✅ Full Access | ✅ Full Access | ✅ Full Access | ✅ Full Access |

| **MANAJER** | ✅ Read Only | ❌ No Access | ✅ Read Only | ❌ No Access |

### Immediate Tasks| **ASISTEN** | ✅ Read Only | ✅ Read Only | ✅ Read Only | ✅ Create/Edit |

| **MANDOR** | ❌ No Access | ✅ Read Only | ❌ No Access | ✅ Create Only |

1. **Integration Testing** dengan backend live

2. **Performance Optimization** untuk large datasets### Error Handling

3. **Accessibility** improvements

4. **Documentation** lengkap untuk setiap modul**401 Unauthorized** 🔒

- **Icon:** Orange lock (`Icons.lock_outline`)

---- **Title:** "Silakan Login"

- **Message:** "Token tidak valid atau sudah kadaluarsa (401)"

## 🤝 Contributing- **Action:** Redirect to login (future) or retry



### Git Workflow**403 Forbidden** 🚫

- **Icon:** Red block (`Icons.block`)

```bash- **Title:** "Akses Ditolak"

# Create feature branch- **Message:** "Anda tidak memiliki izin untuk mengakses data ini (403)"

git checkout -b feature/module-3-dashboard-teknis- **Action:** Show error, provide back navigation



# Make changes, test thoroughly**Other Errors** ❌

flutter test- Network errors

- Timeout (10 seconds)

# Commit with descriptive message- Server errors (5xx)

git add .- Parse errors (invalid JSON)

git commit -m "feat: Implement M-3.1 Matriks Kebingungan"

---

# Push to remote

git push origin feature/module-3-dashboard-teknis## 📖 Development Principles (MPP)



# Create Pull Request on GitHubSemua development mengikuti **Metode Pengembangan POAC (MPP)**:

```

### 1. 🎯 SIMPLE (Sederhana)

### Commit Message Convention

**Prinsip:**

**Format:** `<type>: <subject>`- Kode mudah dibaca dan dipahami

- Satu file = satu tanggung jawab (SRP)

**Types:**- Widget kecil dan reusable

- `feat`: New feature- Minimal dependencies

- `fix`: Bug fix

- `docs`: Documentation only### 2. ✅ TEPAT (Akurat)

- `style`: Code style (formatting, semicolons, etc)

- `refactor`: Code refactoring (no functionality change)**Prinsip:**

- `test`: Adding tests- Logika bisnis 100% akurat

- `chore`: Maintenance tasks (dependencies, config, etc)- Formula perhitungan sesuai requirement

- Error handling komprehensif

**Examples:**- Type safety enforced

```bash

git commit -m "feat: Add M-2.1 Corong Alur Kerja"### 3. 📈 PENINGKATAN BERTAHAP (Kaizen)

git commit -m "fix: Correct KRI Kepatuhan SOP formula"

git commit -m "docs: Update API integration guide"**Prinsip:**

git commit -m "refactor: Extract chart widget to separate file"- Incremental development (1 feature at a time)

```- Test after each feature

- Commit small, focused changes

### Code Style- Build on previous foundation



- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart)---

- Use `flutter analyze` before committing

- Format code with `dart format .`## 🤝 Contributing

- Add meaningful comments for complex logic

### Git Workflow

---

```bash

## 📞 Support & Contact# Create feature branch

git checkout -b feature/module-3-dashboard-teknis

**Resources:**

- **GitHub Repository**: https://github.com/mastoroshadiq-prog/frontend-poac.git# Make changes, test thoroughly

- **Issues**: Report bugs atau request features via GitHub Issuesflutter test

- **Documentation**: Lihat folder `context/` untuk dokumentasi teknis

# Commit with descriptive message

**Team:**git add .

- Frontend Developer: [Your Name]git commit -m "feat: Implement M-3.1 Matriks Kebingungan"

- Backend Developer: [Backend Team]

- Product Owner: [PO Name]# Push to remote

git push origin feature/module-3-dashboard-teknis

---```



## 📄 License### Commit Message Convention



MIT License - See [LICENSE](LICENSE) file for details.**Format:** `<type>: <subject>`



---**Types:**

- `feat`: New feature

## 🙏 Acknowledgments- `fix`: Bug fix

- `docs`: Documentation only

Terima kasih kepada semua yang berkontribusi dalam pengembangan sistem POAC ini.- `style`: Code style

- `refactor`: Code refactoring

**Built with ❤️ following MPP Principles:**  - `test`: Adding tests

**SIMPLE. TEPAT. PENINGKATAN BERTAHAP.**- `chore`: Maintenance tasks



------



**Version:** 1.0.0  ## 📞 Support & Contact

**Last Updated:** November 7, 2025  

**Status:** ✅ Modul 1 & 2 Complete - Ready for Integration Testing**Resources:**

- **GitHub Repository**: https://github.com/mastoroshadiq-prog/frontend-poac.git
- **Backend Repository**: [Link]
- **API Documentation**: [Link]

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Built with ❤️ following MPP Principles:**  
**SIMPLE. TEPAT. PENINGKATAN BERTAHAP.**

---

**Version:** 1.0.0  
**Last Updated:** November 7, 2025  
**Status:** ✅ Modul 1 & 2 Complete - Ready for Integration Testing
