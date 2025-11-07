# 🌴 Frontend Keboen - Dashboard POAC# Frontend Keboen - Dashboard POAC# Frontend Keboen - Dashboard POAC# Frontend POAC - Dashboard Manajemen Perkebunan# Frontend Keboen - Dashboard POAC



**Frontend Dashboard untuk Platform Operasional Kebun Kelapa Sawit**  

Sistem visualisasi data real-time untuk monitoring KPI, operasional harian, dan analisis teknis berbasis framework **POAC** (Planning, Organizing, Actuating, Controlling).

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)

---

[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)

## 📋 Deskripsi Project

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)

Platform **Frontend Keboen** adalah aplikasi dashboard yang dibangun menggunakan **Master Priming Prompt (MPP)** dengan prinsip **3P**:

- ✅ **SIMPLE** - UI modular dan mudah dipahamiDashboard manajemen perkebunan berbasis **Flutter Web** dengan visualisasi KPI real-time dan RBAC authentication.

- ✅ **TEPAT** - Perhitungan KPI akurat dan visualisasi presisi

- ✅ **PENINGKATAN BERTAHAB** - Development iteratif dan terukur[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)



### **Tech Stack:**---

- **Framework:** Flutter Web (Pure)

- **Language:** Dart 3.x[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)Frontend Dashboard berbasis **Flutter Web** untuk sistem manajemen POAC (Plan, Organize, Actuate, Control) perkebunan.

- **HTTP Client:** http ^1.1.0

- **Charts:** fl_chart ^0.68.0## 🚀 Quick Start

- **Indicators:** percent_indicator ^4.2.3

- **Backend:** Node.js + Express + Supabase

- **Authentication:** JWT Bearer Token

```bash

---

# Clone & setupFrontend Dashboard berbasis **Flutter Web (Pure)** untuk sistem manajemen POAC (Plan, Organize, Actuate, Control) perkebunan. Aplikasi ini menyediakan visualisasi data real-time untuk monitoring KPI, operasional harian, dan analisis teknis.[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)

## 🚀 Quick Start

git clone https://github.com/mastoroshadiq-prog/frontend-poac.git

### **1. Prerequisites**

```bashcd frontend-poac

flutter --version  # v3.9.2 or higher

dart --version     # v3.x or higherflutter pub get

```

---[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)## 📋 Status Development

### **2. Installation**

# Run development

```bash

# Clone repositoryflutter run -d chrome

git clone https://github.com/mastoroshadiq-prog/frontend-poac.git

cd frontend-poac



# Install dependencies# Build production## 📋 Status Development

flutter pub get

```flutter build web



### **3. Environment Setup**```



Edit `lib/config/app_config.dart`:



```dart**Requirements:**| Phase | Module | Features | Status |Frontend Dashboard berbasis **Flutter Web (Pure)** untuk sistem manajemen POAC (Plan, Organize, Actuate, Control) perkebunan. Aplikasi ini menyediakan visualisasi data real-time untuk monitoring KPI, operasional harian, dan analisis teknis.- ✅ **Fase 1-3**: Backend API Development (100% Complete)

class AppConfig {

  // Backend API URL- Flutter SDK ≥3.9.2

  static const String apiBaseUrl = 'http://localhost:3000/api/v1';

  - Backend API running at `http://localhost:3000`|-------|--------|----------|--------|

  // Request timeout

  static const Duration requestTimeout = Duration(seconds: 10);- JWT Token (generate: `node scripts/generate-token-only.js`)

}

```| **Fase 1-3** | Backend API Development | REST API + Database | ✅ 100% |- ✅ **Fase 3.5**: RBAC Implementation (100% Complete) �



> **⚠️ IMPORTANT:** ---

> - Pastikan backend API sudah running di `http://localhost:3000`

> - JWT Token diperlukan untuk semua endpoint (lihat section Authentication)| **Fase 3.5** | RBAC Implementation | JWT Auth + Role-based Access | ✅ 100% |



### **4. Run Development**## 📊 Status



```bash| **Fase 4.1** | **Modul 1: Dashboard Eksekutif** | M-1.1 + M-1.2 | ✅ 100% |---- �🚀 **Fase 4**: Frontend UI Development (In Progress)

# Run on Chrome

flutter run -d chrome| Module | Features | Status |



# Run on Edge|--------|----------|--------|| **Fase 4.2** | **Modul 2: Dashboard Operasional** | M-2.1 + M-2.2 | ✅ 100% |

flutter run -d edge

| **M-1: Dashboard Eksekutif** | KRI Indicators + Trend Charts | ✅ 100% |

# Run with custom port

flutter run -d chrome --web-port=8080| **M-2: Dashboard Operasional** | Workflow Funnel + Leaderboard | ✅ 100% || **Fase 4.3** | Modul 3: Dashboard Teknis | M-3.1 + M-3.2 | ⏳ Pending |  - ✅ **Modul 1: Dashboard Eksekutif** (100% Complete)



# Expected output:| **M-3: Dashboard Teknis** | Confusion Matrix + NDRE | ⏳ Pending |

# 🚀 Launching lib/main.dart on Chrome...

# 🌐 http://localhost:xxxxx| **M-4: Form SPK** | Create/Edit Forms | ⏳ Pending || **Fase 4.4** | Modul 4: Form SPK | M-4.1 + M-4.2 | ⏳ Pending |

```



### **5. Build Production**

**Progress: 4/7 Features (57%)**## 📋 Status Development    - ✅ M-1.1: Lampu KRI (Indikator Persentase)

```bash

# Build for web

flutter build web --release

---**Progress: 4/7 Features (57%)**

# Output: build/web/

# Deploy folder ini ke web server

```

## 🏗️ Arsitektur    - ✅ M-1.2: Grafik Tren KPI

---



## 📡 Dashboard Endpoints

```---

### **Base URL:** `http://localhost:3000/api/v1`

UI Layer (Views)

### **Dashboard Features (READ/OUTPUT)** 🔐 ✅

    ↓### ✅ Phase Completed    - ✅ **RBAC Integration**: JWT Authentication ✅ 🔐

| Endpoint | Method | Auth | Roles | Description | Status |

|----------|--------|------|-------|-------------|--------|Service Layer (DashboardService)

| `/dashboard/kpi-eksekutif` | GET | JWT | ASISTEN, MANAJER, ADMIN | Dashboard Eksekutif (KRI + Trend) | ✅ M-1 🔐 |

| `/dashboard/operasional` | GET | JWT | MANDOR, ASISTEN, ADMIN | Dashboard Operasional (Funnel + Leaderboard) | ✅ M-2 🔐 |    ↓## 🏗️ Arsitektur

| `/dashboard/teknis` | GET | JWT | MANDOR, ASISTEN, ADMIN | Dashboard Teknis (Matrix + NDRE) | ⏳ M-3 |

HTTP Client (JWT Auth + Error Handling)

**🔐 RBAC Implementation:**

- **Authentication:** JWT Required (Bearer token in Authorization header)    ↓

- **Authorization:** Role-based access control enforced

- **Dashboard Eksekutif:** Only ASISTEN, MANAJER, and ADMIN (executive level)Backend API (Node.js + Supabase)

- **Dashboard Operasional & Teknis:** MANDOR, ASISTEN, ADMIN (operational + executive)

```### Tech Stack

**⚠️ Authentication Required (Nov 7, 2025):**

- All Dashboard endpoints require JWT authentication

- Unauthorized requests return 401, forbidden requests return 403

- Token must be passed in Authorization header: `Bearer YOUR_JWT_TOKEN`**Tech Stack:**| Phase | Module | Features | Status |## 🏗️ Arsitektur



**Example:**- Flutter Web 3.9.2 (Pure, no HTML/JS)

```bash

# PowerShell - Dashboard Eksekutif- Packages: `http`, `fl_chart`, `percent_indicator`| Category | Technology | Version | Purpose |

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # ASISTEN/MANAJER/ADMIN token

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/dashboard/kpi-eksekutif" `- Backend: Node.js + Express + JWT RBAC

  -Headers @{Authorization="Bearer $token"} | ConvertTo-Json -Depth 10

|----------|-----------|---------|---------||-------|--------|----------|--------|

# PowerShell - Dashboard Operasional

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # MANDOR/ASISTEN/ADMIN token---

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/dashboard/operasional" `

  -Headers @{Authorization="Bearer $token"} | ConvertTo-Json -Depth 10| **Framework** | Flutter Web | ^3.9.2 | UI Framework (Pure - no HTML/JS) |



# cURL - Dashboard Eksekutif## 📖 Features

curl -X GET http://localhost:3000/api/v1/dashboard/kpi-eksekutif \

  -H "Authorization: Bearer <your-jwt-token>"| **Language** | Dart | 3.x | Programming Language || **Fase 1-3** | Backend API Development | REST API + Database | ✅ 100% |### Tech Stack

```

### M-1: Dashboard Eksekutif

---

**Endpoint:** `GET /api/v1/dashboard/kpi-eksekutif` 🔐| **HTTP Client** | http | ^1.1.0 | REST API Communication |

## 📝 Dashboard Documentation



### **M-1: Dashboard Eksekutif**

- **M-1.1: Lampu KRI**| **Charts** | fl_chart | ^0.68.0 | Line Charts & Data Visualization || **Fase 3.5** | RBAC Implementation | JWT Auth + Role-based Access | ✅ 100% 🔐 |- **Framework**: Flutter Web (Pure, no HTML/JS embed)

**Endpoint:** `GET /api/v1/dashboard/kpi-eksekutif` 🔐

  - KRI Lead Time APH (Target: ≤3 hari)

🔐 **Authentication Required:** JWT Bearer Token  

🛡️ **Authorized Roles:** `ASISTEN`, `MANAJER`, `ADMIN`  - KRI Kepatuhan SOP (Target: ≥75%) ⚠️ Formula: `(Selesai/(Selesai+Dikerjakan)) × 100`| **Progress Indicators** | percent_indicator | ^4.2.3 | Circular & Linear Progress |



**Request Headers:**

```http

Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...- **M-1.2: Grafik Tren**| **Backend** | Node.js + Express | - | REST API Server || **Fase 4.1** | **Modul 1: Dashboard Eksekutif** | M-1.1 + M-1.2 | ✅ 100% |- **HTTP Client**: `http` package

Content-Type: application/json

Accept: application/json  - Tren Insidensi Baru (G1) - 6 bulan

```

  - Tren Pohon Mati Aktif (G4) - 6 bulan| **Database** | Supabase (PostgreSQL) | - | Data Persistence |

**Response Format:**

```json

{

  "kri_lead_time_aph": 2.5,### M-2: Dashboard Operasional| **Authentication** | JWT | - | Role-Based Access Control || **Fase 4.2** | **Modul 2: Dashboard Operasional** | M-2.1 + M-2.2 | ✅ 100% |- **Charts**: `fl_chart` package

  "kri_kepatuhan_sop": 78.3,

  "tren_insidensi_baru": [**Endpoint:** `GET /api/v1/dashboard/operasional` 🔐

    {"periode": "2024-06", "nilai": 12},

    {"periode": "2024-07", "nilai": 8},

    {"periode": "2024-08", "nilai": 15},

    {"periode": "2024-09", "nilai": 10},- **M-2.1: Corong Alur Kerja**

    {"periode": "2024-10", "nilai": 7},

    {"periode": "2024-11", "nilai": 9}  - Progress Validasi (Blue bar)### Arsitektur Pattern- **Indicators**: `percent_indicator` package

  ],

  "tren_g4_aktif": [  - Progress APH (Green bar)

    {"periode": "2024-06", "nilai": 45},

    {"periode": "2024-07", "nilai": 38},  - Progress Sanitasi (Orange bar)

    {"periode": "2024-08", "nilai": 42},

    {"periode": "2024-09", "nilai": 35},

    {"periode": "2024-10", "nilai": 30},

    {"periode": "2024-11", "nilai": 28}- **M-2.2: Papan Peringkat**```### 🚀 Current Phase: Frontend UI Development- **Backend API**: Node.js + Express + Supabase

  ]

}  - DataTable dengan ranking pelaksana

```

  - Top 3 highlighting (🥇🥈🥉)┌─────────────────────────────────────────────┐

#### **M-1.1: Lampu KRI (Key Risk Indicators)**

  - Color-coded performance rates

Visual indikator performa menggunakan **Circular Progress Indicators**.

│            UI Layer (Views)                 │

**1. KRI Lead Time APH**

- **Deskripsi:** Waktu rata-rata dari deteksi hingga tindakan APH---

- **Visual:** Circular Percent Indicator (Orange)

- **Target:** ≤ 3 hari│  - DashboardEksekutifView                  │

- **Formula:** `Σ(tanggal_aph - tanggal_validasi) / jumlah_pohon`

- **Interpretasi:** Semakin rendah semakin baik## 🔐 Authentication

- **Display Logic:**

  ```dart│  - DashboardOperasionalView                │**Progress: 4/7 Features (57%)**### Struktur Folder

  double displayPercent = (value / 3.0).clamp(0.0, 1.0);

  Color color = value <= 3 ? Colors.green : Colors.orange;**Generate JWT Token:**

  ```

```bash│  - HomeMenuView                            │

**2. KRI Kepatuhan SOP** ⚠️ **CRITICAL**

- **Deskripsi:** Persentase kepatuhan pelaksanaan SOP# Di backend repository

- **Visual:** Circular Percent Indicator (Green)

- **Target:** ≥ 75%node scripts/generate-token-only.js└────────────────┬────────────────────────────┘```

- **Formula:** `(Selesai / (Selesai + Dikerjakan)) × 100`

- **Display Logic (TEPAT!):**```

  ```dart

  // PENTING: Normalisasi ke basis 75%                 │

  double displayPercent = (value / 75.0).clamp(0.0, 1.0);

  Color color = value >= 80 ? Colors.green : **Usage di Flutter:**

                value >= 60 ? Colors.orange : Colors.red;

  ``````dart                 ▼- ✅ **Modul 1: Dashboard Eksekutif** (100% Complete)lib/

- **Interpretasi:**

  - 🟢 ≥80%: Excellent// Hardcoded (development)

  - 🟠 60-79%: Good

  - 🔴 <60%: Need Improvementstatic const String _testToken = 'eyJhbGci...';┌─────────────────────────────────────────────┐



#### **M-1.2: Grafik Tren KPI**



Visual tren historis menggunakan **Line Charts (fl_chart)**.// Or pass via constructor│         Service Layer (Services)            │  - ✅ M-1.1: Lampu KRI (2 Circular Indicators)├── config/



**1. Tren Insidensi Baru (Kasus G1)**DashboardEksekutifView(token: userToken)

- **Deskripsi:** Grafik tren kasus Ganoderma Awal (G1) per bulan

- **Data:** 6 bulan terakhir dari backend```│  - DashboardService                        │

- **Warna:** Orange (`#FF9800`)

- **X-Axis:** Periode (YYYY-MM)

- **Y-Axis:** Jumlah kasus

- **Features:****RBAC Matrix:**│    * fetchKpiEksekutif(token)             │  - ✅ M-1.2: Grafik Tren KPI (2 Line Charts)│   └── app_config.dart          # Konfigurasi aplikasi (API URL, timeout, dll)

  - ✅ Interactive touch tooltips

  - ✅ Grid lines untuk referensi

  - ✅ Responsive chart sizing

  - ✅ Animated transitions (300ms)| Role | M-1 Eksekutif | M-2 Operasional | M-3 Teknis | M-4 Form SPK |│    * fetchDashboardOperasional(token)     │



**2. Tren Pohon Mati Aktif (G4)**|------|---------------|-----------------|------------|--------------|

- **Deskripsi:** Grafik tren pohon status G4 (Mati) per bulan

- **Data:** 6 bulan terakhir dari backend| ADMIN | ✅ Full | ✅ Full | ✅ Full | ✅ Full |└────────────────┬────────────────────────────┘  - ✅ RBAC JWT Authentication Integration├── services/

- **Warna:** Red (`#F44336`)

- **X-Axis:** Periode (YYYY-MM)| MANAJER | ✅ Read | ❌ | ✅ Read | ❌ |

- **Y-Axis:** Jumlah pohon

- **Features:**| ASISTEN | ✅ Read | ✅ Read | ✅ Read | ✅ Edit |                 │

  - ✅ Interactive touch tooltips

  - ✅ Grid lines untuk referensi| MANDOR | ❌ | ✅ Read | ❌ | ✅ Create |

  - ✅ Responsive chart sizing

  - ✅ Animated transitions (300ms)                 ▼  │   └── dashboard_service.dart   # Service layer untuk API calls



**Validation:****Error Handling:**

- ✅ JWT authentication (`401` if missing/invalid token)

- ✅ Role authorization (`403` if not ASISTEN/MANAJER/ADMIN)- 401 Unauthorized → "Silakan Login"┌─────────────────────────────────────────────┐

- ✅ Error handling (network, timeout, parse errors)

- ✅ Loading state dengan CircularProgressIndicator- 403 Forbidden → "Akses Ditolak"

- ✅ Empty state handling

│      HTTP Client Layer (http package)       │- ✅ **Modul 2: Dashboard Operasional** (100% Complete)├── views/

**UI/UX Features:**

- Pull-to-refresh gesture---

- Refresh button di AppBar

- Error state dengan retry button│  - JWT Authentication                      │

- Color-coded indicators (green/orange/red)

## 🔌 API Format

📄 **Verification:** `context/VERIFICATION_CHECKPOINT_RBAC.md`

│  - Error Handling (401/403/5xx)           │  - ✅ M-2.1: Corong Alur Kerja (3 Progress Bars)│   └── dashboard_eksekutif_view.dart  # UI Dashboard Eksekutif

---

**Request:**

### **M-2: Dashboard Operasional**

```http│  - Response Parsing                        │

**Endpoint:** `GET /api/v1/dashboard/operasional` 🔐

GET /api/v1/dashboard/kpi-eksekutif

🔐 **Authentication Required:** JWT Bearer Token  

🛡️ **Authorized Roles:** `MANDOR`, `ASISTEN`, `ADMIN`Authorization: Bearer YOUR_JWT_TOKEN└────────────────┬────────────────────────────┘  - ✅ M-2.2: Papan Peringkat Tim (DataTable)└── main.dart                    # Entry point aplikasi



**Request Headers:**```

```http

Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...                 │

Content-Type: application/json

Accept: application/json**Response:**

```

```json                 ▼  - ✅ RBAC JWT Authentication Integration```

**Response Format:**

```json{

{

  "corong_alur_kerja": {  "kri_lead_time_aph": 2.5,┌─────────────────────────────────────────────┐

    "validasi": {"selesai": 80, "target": 100},

    "aph": {"selesai": 65, "target": 100},  "kri_kepatuhan_sop": 78.3,

    "sanitasi": {"selesai": 40, "target": 100}

  },  "tren_insidensi_baru": [{"periode": "2024-06", "nilai": 12}],│         Backend REST API (Node.js)          │

  "papan_peringkat": [

    {  "tren_g4_aktif": [{"periode": "2024-06", "nilai": 45}]

      "id_pelaksana": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a10",

      "selesai": 45,}│  - GET /api/v1/dashboard/kpi-eksekutif    │

      "total": 50

    },```

    {

      "id_pelaksana": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",│  - GET /api/v1/dashboard/operasional      │- ⏳ **Modul 3: Dashboard Teknis** (Pending)## 🚀 Cara Menjalankan

      "selesai": 38,

      "total": 50**Config:** Edit `lib/config/app_config.dart` untuk production URL

    }

  ]│  - RBAC Middleware                         │

}

```---



#### **M-2.1: Corong Alur Kerja (Workflow Funnel)**└─────────────────────────────────────────────┘  - ⏳ M-3.1: Matriks Kebingungan



Visual progress tahapan kerja menggunakan **Linear Progress Bars**.## 📁 Struktur



**3 Tahapan Progress:**```



**1. Validasi**```

- **Deskripsi:** Progress validasi lapangan

- **Visual:** Linear Progress Bar (Blue `#2196F3`)lib/  - ⏳ M-3.2: Data Distribusi NDRE### Prerequisites

- **Data:** `validasi.selesai / validasi.target`

- **Label:** "Validasi: X dari Y Selesai"├── config/app_config.dart              # API URL & timeout

- **Formula:**

  ```dart├── services/dashboard_service.dart     # HTTP calls + parsing**Prinsip:**

  double percent = (selesai / max(target, 1)).clamp(0.0, 1.0);

  ```├── views/



**2. APH (Aplikasi Pupuk Hayati)**│   ├── dashboard_eksekutif_view.dart   # M-1- **Separation of Concerns**: UI ↔ Service ↔ API1. Flutter SDK (^3.9.2)

- **Deskripsi:** Progress aplikasi pupuk hayati

- **Visual:** Linear Progress Bar (Green `#4CAF50`)│   └── dashboard_operasional_view.dart # M-2

- **Data:** `aph.selesai / aph.target`

- **Label:** "APH: X dari Y Selesai"└── main.dart                           # Entry point- **Type Safety**: Explicit type casting

- **Formula:**

  ```dart

  double percent = (selesai / max(target, 1)).clamp(0.0, 1.0);

  ```context/                                # Documentation- **Error Handling**: Comprehensive error coverage- ⏳ **Modul 4: Form SPK** (Pending)2. Backend API sudah running di `http://localhost:3000`



**3. Sanitasi**├── VERIFICATION_CHECKPOINT_RBAC.md

- **Deskripsi:** Progress sanitasi pohon

- **Visual:** Linear Progress Bar (Orange `#FF9800`)├── VERIFICATION_CHECKPOINT_Modul_2.md- **Null Safety**: Dart 3.x null-safety enabled

- **Data:** `sanitasi.selesai / sanitasi.target`

- **Label:** "Sanitasi: X dari Y Selesai"└── LAPORAN_EKSEKUSI_*.md

- **Formula:**

  ```dart```  - ⏳ M-4: Form Surat Perintah Kerja3. **🔐 JWT Token** (untuk RBAC - lihat section Authentication di bawah)

  double percent = (selesai / max(target, 1)).clamp(0.0, 1.0);

  ```



**Features:**---### Struktur Folder

- ✅ Percentage display inside bar (white text)

- ✅ Animated progress (800ms duration)

- ✅ Safe division (prevent div by zero: `max(target, 1)`)

- ✅ Clamped percentage (0-100%)## 🧪 Testing

- ✅ Height: 40px untuk readability



#### **M-2.2: Papan Peringkat Tim (Team Leaderboard)**

**Manual Checklist:**```

Visual ranking pelaksana menggunakan **DataTable**.

- [ ] Loading state saat fetch data

**Columns:**

1. **Peringkat**: #1, #2, #3... (auto-generated dari index)- [ ] Error handling (401/403/network/timeout)lib/---### Install Dependencies

2. **ID Pelaksana**: UUID pelaksana (8 karakter pertama)

3. **Selesai / Total**: "X / Y" format- [ ] KRI Kepatuhan SOP formula TEPAT: `(value/75.0).clamp(0,1)`

4. **Rate (%)**: Performance percentage

- [ ] Charts render dengan data 6 bulan├── config/

**Enhanced Features:**

- 🥇 **Rank #1**: Gold background (`Colors.amber[100]`) + trophy icon- [ ] Refresh functionality

- 🥈 **Rank #2**: Silver background (`Colors.grey[300]`) + trophy icon

- 🥉 **Rank #3**: Bronze background (`Colors.orange[200]`) + trophy icon- [ ] Responsive layout│   └── app_config.dart          # Konfigurasi API URL, timeout, dll```bash

- 🎨 **Color-coded Rates**:

  ```dart

  Color getRateColor(double rate) {

    if (rate >= 80) return Colors.green;      // High performance**Run Tests:**├── services/

    if (rate >= 50) return Colors.orange;     // Medium performance

    return Colors.red;                        // Low performance```bash

  }

  ```flutter test│   └── dashboard_service.dart   # Service layer untuk API calls## 🏗️ Arsitektur Aplikasiflutter pub get

- 📱 Horizontal scrolling untuk responsiveness

- 📊 Empty state handling ("Belum ada data peringkat")flutter test --coverage



**Validation:**```├── views/

- ✅ JWT authentication (`401` if missing/invalid token)

- ✅ Role authorization (`403` if not MANDOR/ASISTEN/ADMIN)

- ✅ Error handling (network, timeout, parse errors)

- ✅ Loading state dengan CircularProgressIndicator---│   ├── dashboard_eksekutif_view.dart   # Modul 1: Dashboard Eksekutif```

- ✅ Empty state handling



📄 **Verification:** `context/VERIFICATION_CHECKPOINT_Modul_2.md`

## 🐛 Troubleshooting│   └── dashboard_operasional_view.dart # Modul 2: Dashboard Operasional

---



## 🔐 Security & RBAC

| Issue | Solution |└── main.dart                    # Entry point aplikasi### Tech Stack

### **Authentication**

- **JWT Bearer Token** required for all Dashboard endpoints|-------|----------|

- Token expires in **7 days** (backend configuration)

- Token generated via backend: `node scripts/generate-token-only.js`| Network error | Backend must run at `http://localhost:3000` |



### **Role-Based Access Control (RBAC)**| CORS error | Add CORS middleware di backend |



**Role Hierarchy:**| 404 Not Found | Verify endpoint exists: `curl http://localhost:3000/api/v1/dashboard/kpi-eksekutif` |context/### Run Development

```

ADMIN         → Full access to all dashboards| Chart kosong | Check console, verify response data structure |

  ↓

MANAJER       → Dashboard Eksekutif only| Token expired | Generate new: `node scripts/generate-token-only.js` |├── LAPORAN_EKSEKUSI_Frontend_1.md

  ↓

ASISTEN       → Dashboard Eksekutif + Operasional + Teknis

  ↓

MANDOR        → Dashboard Operasional + Teknis only---├── LAPORAN_EKSEKUSI_Frontend_Modul_2.md| Category | Technology | Version | Purpose |```bash

  ↓

PELAKSANA     → No dashboard access (403 Forbidden)

```

## 📖 Development Principles (MPP)├── LAPORAN_EKSEKUSI_Frontend_RBAC_1.md

**Permission Matrix:**



| Role | Dashboard Eksekutif | Dashboard Operasional | Dashboard Teknis |

|------|--------------------|-----------------------|------------------|1. **SIMPLE** - Modular code, single responsibility├── VERIFICATION_CHECKPOINT_RBAC.md|----------|-----------|---------|---------|# Web (Chrome)

| **ADMIN** | ✅ Full Access | ✅ Full Access | ✅ Full Access |

| **MANAJER** | ✅ Read Only | ❌ No Access | ❌ No Access |2. **TEPAT** - Accurate business logic (esp. KRI formulas)

| **ASISTEN** | ✅ Read Only | ✅ Read Only | ✅ Read Only |

| **MANDOR** | ❌ No Access | ✅ Read Only | ✅ Read Only |3. **PENINGKATAN BERTAHAP** - Incremental commits, test each feature└── VERIFICATION_CHECKPOINT_Modul_2.md

| **PELAKSANA** | ❌ No Access | ❌ No Access | ❌ No Access |



### **Error Handling**

---| **Framework** | Flutter Web | ^3.9.2 | UI Framework (Pure - no HTML/JS) |flutter run -d chrome

**401 Unauthorized** 🔒

- **Icon:** Orange lock (`Icons.lock_outline`)

- **Title:** "Silakan Login"

- **Message:** "Token tidak valid atau sudah kadaluarsa (401)"## 🤝 Contributingpubspec.yaml                     # Dependencies

- **Action:** Redirect to login (future) or display error

- **UI:**

  ```dart

  Center(```bashanalysis_options.yaml            # Linter configuration| **Language** | Dart | 3.x | Programming Language |

    child: Column(

      children: [git checkout -b feature/your-feature

        Icon(Icons.lock_outline, size: 64, color: Colors.orange),

        Text('Silakan Login', style: TextStyle(fontSize: 20)),git commit -m "feat: Your feature description"README.md                        # This file

        Text('Token tidak valid atau sudah kadaluarsa (401)'),

      ],git push origin feature/your-feature

    ),

  )``````| **HTTP Client** | http | ^1.1.0 | REST API Communication |# Web (Edge)

  ```



**403 Forbidden** 🚫

- **Icon:** Red block (`Icons.block`)**Commit Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

- **Title:** "Akses Ditolak"

- **Message:** "Anda tidak memiliki izin untuk mengakses data ini (403)"

- **Action:** Show error, provide back navigation

- **UI:**------| **Charts** | fl_chart | ^0.68.0 | Line Charts & Data Visualization |flutter run -d edge

  ```dart

  Center(

    child: Column(

      children: [## 📞 Resources

        Icon(Icons.block, size: 64, color: Colors.red),

        Text('Akses Ditolak', style: TextStyle(fontSize: 20)),

        Text('Anda tidak memiliki izin untuk mengakses data ini (403)'),

      ],- **Repository:** https://github.com/mastoroshadiq-prog/frontend-poac.git## 🚀 Quick Start| **Progress Indicators** | percent_indicator | ^4.2.3 | Circular & Linear Progress |

    ),

  )- **Documentation:** See `context/` folder

  ```

- **Issues:** GitHub Issues

**Other Errors** ❌

- Network errors (`SocketException`)

- Timeout (10 seconds via `AppConfig.requestTimeout`)

- Server errors (5xx)---### Prerequisites| **Backend** | Node.js + Express | - | REST API Server |# Web dengan port custom

- Parse errors (invalid JSON via `FormatException`)

- 404 Not Found



**Implementation Files:****Built with MPP: SIMPLE. TEPAT. PENINGKATAN BERTAHAP.**

- `lib/services/dashboard_service.dart` - HTTP calls + JWT header injection

- `lib/views/dashboard_eksekutif_view.dart` - Error UI for M-1

- `lib/views/dashboard_operasional_view.dart` - Error UI for M-2

*Version 1.0.0 | Last Updated: Nov 7, 2025 | Status: M-1 & M-2 Complete ✅*1. **Flutter SDK** (≥3.9.2)| **Database** | Supabase (PostgreSQL) | - | Data Persistence |flutter run -d chrome --web-port=8080

📄 **RBAC Analysis:** `context/VERIFICATION_CHECKPOINT_RBAC.md`



---   ```bash



## 🗄️ Service Layer   flutter --version| **Authentication** | JWT | - | Role-Based Access Control |```



### **DashboardService**   # Flutter 3.9.2 • channel stable



```dart   ```

class DashboardService {

  static Future<Map<String, dynamic>> fetchKpiEksekutif(String token) async {

    final response = await http.get(

      Uri.parse('${AppConfig.apiBaseUrl}/dashboard/kpi-eksekutif'),2. **Backend API Running**### Struktur Folder### Build Production

      headers: {

        'Content-Type': 'application/json',   - URL: `http://localhost:3000`

        'Accept': 'application/json',

        'Authorization': 'Bearer $token',   - Endpoints available:```bash

      },

    ).timeout(AppConfig.requestTimeout);     - `GET /api/v1/dashboard/kpi-eksekutif`

    

    if (response.statusCode == 200) {     - `GET /api/v1/dashboard/operasional````# Build untuk web production

      return json.decode(response.body);

    } else if (response.statusCode == 401) {

      throw Exception('Unauthorized: Token tidak valid atau kadaluarsa');

    } else if (response.statusCode == 403) {3. **JWT Token** (for authentication)frontend_keboen/flutter build web

      throw Exception('Forbidden: Anda tidak memiliki izin akses');

    } else {   - Generate from backend: `node scripts/generate-token-only.js`

      throw Exception('Error ${response.statusCode}: ${response.body}');

    }   - Or use hardcoded test token (development only)├── lib/

  }

  

  static Future<Map<String, dynamic>> fetchDashboardOperasional(String token) async {

    // Similar implementation with JWT header### Installation│   ├── config/# Output akan ada di folder: build/web/

  }

}

```

```bash│   │   └── app_config.dart                # Konfigurasi API URL, timeout```

**Features:**

- ✅ JWT Bearer token injection# Clone repository

- ✅ Timeout handling (10 seconds)

- ✅ HTTP status code validationgit clone https://github.com/mastoroshadiq-prog/frontend-poac.git│   ├── services/

- ✅ JSON parsing dengan error handling

- ✅ Exception throwing untuk error propagationcd frontend-poac



---│   │   └── dashboard_service.dart         # Service layer untuk API calls## 📊 Fitur Dashboard Eksekutif



## 📂 Project Structure# Install dependencies



```flutter pub get│   ├── views/

frontend_keboen/

├── lib/

│   ├── config/

│   │   └── app_config.dart              # API URL & timeout configuration# Verify no issues│   │   ├── dashboard_eksekutif_view.dart  # Modul 1: Dashboard Eksekutif### M-1.1: Lampu KRI (Key Risk Indicators)

│   ├── services/

│   │   └── dashboard_service.dart       # HTTP calls + JWT authenticationflutter doctor

│   ├── views/

│   │   ├── dashboard_eksekutif_view.dart   # M-1: Dashboard Eksekutif UI```│   │   └── dashboard_operasional_view.dart # Modul 2: Dashboard Operasional

│   │   └── dashboard_operasional_view.dart # M-2: Dashboard Operasional UI

│   └── main.dart                        # Entry point + Home Menu

├── context/

│   ├── LAPORAN_EKSEKUSI_Frontend_1.md### Run Development Server│   └── main.dart                          # Entry point + Home Menu**1. KRI Lead Time APH**

│   ├── LAPORAN_EKSEKUSI_Frontend_Modul_2.md

│   ├── LAPORAN_EKSEKUSI_Frontend_RBAC_1.md

│   ├── VERIFICATION_CHECKPOINT_RBAC.md

│   ├── VERIFICATION_CHECKPOINT_Modul_2.md```bash├── context/- Menampilkan waktu rata-rata penanganan dari deteksi hingga tindakan

│   └── mpp_frontend_poac.md.md

├── android/                             # Android platform files# Run on Chrome

├── ios/                                 # iOS platform files

├── web/                                 # Web platform filesflutter run -d chrome│   ├── LAPORAN_EKSEKUSI_Frontend_RBAC_1.md- Visual: Circular Progress Indicator

├── linux/                               # Linux platform files

├── macos/                               # macOS platform files

├── windows/                             # Windows platform files

├── pubspec.yaml                         # Dependencies# Run on Edge│   ├── LAPORAN_EKSEKUSI_Frontend_Modul_2.md- Target: ≤ 3 hari

├── analysis_options.yaml                # Linter configuration

└── README.md                            # This fileflutter run -d edge

```

│   ├── LAPORAN_PERBAIKAN_Response_Format_Fix.md- Formula: Semakin rendah semakin baik

---

# Run with custom port

## 🧪 Testing

flutter run -d chrome --web-port=8080│   ├── VERIFICATION_CHECKPOINT_RBAC.md

### **Manual Testing (PowerShell)**



```powershell

# 1. Generate JWT token (di backend repository)# Hot reload: Press 'r' in terminal│   └── VERIFICATION_CHECKPOINT_Modul_2.md**2. KRI Kepatuhan SOP** ⚠️ **WAJIB TEPAT**

cd path/to/backend

node scripts/generate-token-only.js# Hot restart: Press 'R' in terminal

# Select role: ASISTEN, MANAJER, ADMIN, atau MANDOR

# Copy token yang dihasilkan```├── pubspec.yaml                           # Dependencies- Menampilkan persentase kepatuhan terhadap SOP



# 2. Test Dashboard Eksekutif

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # ASISTEN/MANAJER/ADMIN token

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/dashboard/kpi-eksekutif" `### Build for Production├── analysis_options.yaml                  # Linter configuration- Visual: Circular Progress Indicator

  -Headers @{Authorization="Bearer $token"} | ConvertTo-Json -Depth 10



# Expected output: JSON dengan kri_lead_time_aph, kri_kepatuhan_sop, tren_insidensi_baru, tren_g4_aktif

```bash└── README.md                              # This file- Target: ≥ 75%

# 3. Test Dashboard Operasional

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # MANDOR/ASISTEN/ADMIN token# Build optimized web app

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/dashboard/operasional" `

  -Headers @{Authorization="Bearer $token"} | ConvertTo-Json -Depth 10flutter build web --release```- Formula: `kri_kepatuhan_sop = Selesai / (Selesai + Dikerjakan) * 100`



# Expected output: JSON dengan corong_alur_kerja dan papan_peringkat



# 4. Test 401 Unauthorized (no token)# Output location: build/web/- **PENTING**: Perhitungan menggunakan basis 75% sebagai target 100%

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/dashboard/kpi-eksekutif"

# Expected: 401 error# Deploy this folder to your web server



# 5. Test 403 Forbidden (wrong role)### Arsitektur Pattern

$pelaksanaToken = "eyJhbG..." # PELAKSANA token

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/dashboard/kpi-eksekutif" `# Build with base href (for subdirectory deployment)

  -Headers @{Authorization="Bearer $pelaksanaToken"}

# Expected: 403 errorflutter build web --base-href /dashboard/### M-1.2: Grafik Tren KPI

```

```

### **Flutter UI Testing**

```

```bash

# 1. Hardcode test token in view files---

# Edit lib/views/dashboard_eksekutif_view.dart:

static const String _testToken = 'YOUR_JWT_TOKEN_HERE';┌─────────────────────────────────────────────┐**1. Tren Insidensi Baru (Kasus G1)**



# 2. Run Flutter app## 📊 Features & Modules

flutter run -d chrome

│            UI Layer (Views)                 │- Line Chart menampilkan tren kasus Ganoderma Awal (G1)

# 3. Manual test checklist:

```### 🎯 Modul 1: Dashboard Eksekutif



**Manual Test Checklist:**│  - DashboardEksekutifView                  │- Data 6 bulan terakhir



**M-1: Dashboard Eksekutif****Endpoint:** `GET /api/v1/dashboard/kpi-eksekutif` 🔐  

- [ ] Loading state muncul saat fetch data

- [ ] KRI Lead Time APH ditampilkan dengan benar**Roles:** ASISTEN, MANAJER, ADMIN│  - DashboardOperasionalView                │- Warna: Orange

- [ ] KRI Kepatuhan SOP menggunakan formula TEPAT: `(value/75.0).clamp(0,1)`

- [ ] Tren Insidensi Baru (G1) chart render dengan 6 data points

- [ ] Tren G4 Aktif chart render dengan 6 data points

- [ ] Chart interactive tooltips berfungsi#### M-1.1: Lampu KRI (Key Risk Indicators)│  - HomeMenuView                            │

- [ ] Error state (401/403) ditampilkan dengan icon dan pesan yang benar

- [ ] Refresh button di AppBar berfungsi

- [ ] Pull-to-refresh gesture berfungsi

- [ ] Responsive layout di berbagai ukuran layarVisual indikator performa menggunakan **Circular Progress Indicators**.└────────────────┬────────────────────────────┘**2. Tren Pohon Mati Aktif (G4)**



**M-2: Dashboard Operasional**

- [ ] Loading state muncul saat fetch data

- [ ] Progress bar Validasi menampilkan persentase yang benar**1. KRI Lead Time APH**                 │- Line Chart menampilkan tren pohon status G4 (Mati)

- [ ] Progress bar APH menampilkan persentase yang benar

- [ ] Progress bar Sanitasi menampilkan persentase yang benar- **Deskripsi:** Waktu rata-rata dari deteksi hingga tindakan APH

- [ ] Safe division (tidak error saat target = 0)

- [ ] Papan Peringkat DataTable render dengan benar- **Visual:** Circular Percent Indicator (Orange)                 ▼- Data 6 bulan terakhir

- [ ] Top 3 highlighting (gold/silver/bronze) berfungsi

- [ ] Color-coded rates (green/orange/red) sesuai threshold- **Target:** ≤ 3 hari

- [ ] Error state (401/403) ditampilkan dengan benar

- [ ] Refresh button di AppBar berfungsi- **Formula:** `Σ(tanggal_aph - tanggal_validasi) / jumlah_pohon`┌─────────────────────────────────────────────┐- Warna: Red

- [ ] Responsive layout dengan horizontal scrolling

- **Interpretasi:** Semakin rendah semakin baik

**RBAC Testing:**

- [ ] 401 error saat token tidak valid/expired│         Service Layer (Services)            │

- [ ] 403 error saat role tidak sesuai (PELAKSANA coba akses dashboard)

- [ ] ASISTEN bisa akses M-1 dan M-2**2. KRI Kepatuhan SOP** ⚠️ **CRITICAL**

- [ ] MANAJER bisa akses M-1, tidak bisa M-2

- [ ] MANDOR bisa akses M-2, tidak bisa M-1- **Deskripsi:** Persentase kepatuhan pelaksanaan SOP│  - DashboardService                        │## 🔌 API Integration

- [ ] ADMIN bisa akses semua dashboard

- **Visual:** Circular Percent Indicator (Green)

### **Automated Testing (Future)**

- **Target:** ≥ 75%│    * fetchKpiEksekutif(token)             │

```bash

# Unit tests (services)- **Formula:** `(Selesai / (Selesai + Dikerjakan)) × 100`

flutter test test/services/dashboard_service_test.dart

- **Perhitungan Display:** `(value / 75.0)` untuk normalisasi ke skala 100%│    * fetchDashboardOperasional(token)     │### 🔐 Authentication (RBAC Fase 2)

# Widget tests (UI)

flutter test test/views/dashboard_eksekutif_view_test.dart- **Interpretasi:**



# Integration tests  - 🟢 ≥80%: Excellent└────────────────┬────────────────────────────┘

flutter test integration_test/

  - 🟠 60-79%: Good

# Coverage report

flutter test --coverage  - 🔴 <60%: Need Improvement                 │**PENTING:** Semua endpoint Dashboard sekarang memerlukan **JWT Authentication**.

```



---

#### M-1.2: Grafik Tren KPI                 ▼

## 🐛 Troubleshooting



### **Common Issues:**

Visual tren historis menggunakan **Line Charts (fl_chart)**.┌─────────────────────────────────────────────┐#### Mendapatkan JWT Token

**1. Network Error / Connection Refused**

```bash

# Pastikan backend API sudah running

cd path/to/backend**1. Tren Insidensi Baru (Kasus G1)**│      HTTP Client Layer (http package)       │

node index.js

# Expected: 🚀 Server running on http://localhost:3000- **Deskripsi:** Grafik tren kasus Ganoderma Awal (G1) per bulan

```

- **Data:** 6 bulan terakhir│  - JWT Authentication                      │**Option 1: Generate Token (Testing)**

**2. CORS Error (di browser)**

```javascript- **Warna:** Orange (`#FF9800`)

// Di backend: index.js atau app.js

const cors = require('cors');- **X-Axis:** Periode (YYYY-MM)│  - Error Handling (401/403/5xx)           │```bash



app.use(cors({- **Y-Axis:** Jumlah kasus

  origin: 'http://localhost:YOUR_FLUTTER_PORT',

  credentials: true│  - Response Parsing                        │# Di backend repository, jalankan:

}));

```**2. Tren Pohon Mati Aktif (G4)**



**3. Chart Tidak Muncul / Kosong**- **Deskripsi:** Grafik tren pohon status G4 (Mati) per bulan└────────────────┬────────────────────────────┘node scripts/generate-token-only.js

```bash

# Check browser console (F12)- **Data:** 6 bulan terakhir

# Verify response API memiliki data tren:

# - tren_insidensi_baru: array of {periode, nilai}- **Warna:** Red (`#F44336`)                 │

# - tren_g4_aktif: array of {periode, nilai}

- **X-Axis:** Periode (YYYY-MM)

# Test API directly:

curl -X GET http://localhost:3000/api/v1/dashboard/kpi-eksekutif \- **Y-Axis:** Jumlah pohon                 ▼# Output contoh untuk role ASISTEN:

  -H "Authorization: Bearer YOUR_TOKEN"

```



**4. KRI Kepatuhan SOP Tidak Akurat****Features:**┌─────────────────────────────────────────────┐eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwidXNlcm5hbWUiOiJhc2lzdGVuMSIsInJvbGUiOiJBU0lTVEVOIiwiaWF0IjoxNzMwODQwMDAwLCJleHAiOjE3MzA5MjY0MDB9.SIGNATURE

```dart

// Verifikasi formula di lib/views/dashboard_eksekutif_view.dart- ✅ Interactive touch tooltips

// HARUS menggunakan normalisasi ke basis 75%:

- ✅ Grid lines untuk referensi│         Backend REST API (Node.js)          │```

double displayPercent = (value / 75.0).clamp(0.0, 1.0);

- ✅ Responsive chart sizing

// JANGAN gunakan:

// double displayPercent = (value / 100.0).clamp(0.0, 1.0); // ❌ SALAH!- ✅ Animated transitions│  - GET /api/v1/dashboard/kpi-eksekutif    │

```



**5. Token Expired Terus-Menerus**

```bash---│  - GET /api/v1/dashboard/operasional      │**Option 2: Login API (Production)**

# Generate token baru dengan expiry lebih lama (di backend)

# Edit backend: middleware/authMiddleware.js atau JWT config

# Change expiresIn: '7d' → '30d'

### 🎯 Modul 2: Dashboard Operasional│  - RBAC Middleware                         │```dart

# Generate new token:

node scripts/generate-token-only.js

```

**Endpoint:** `GET /api/v1/dashboard/operasional` 🔐  └─────────────────────────────────────────────┘// TODO: Implement login screen

**6. 401 Unauthorized Padahal Token Valid**

```dart**Roles:** MANDOR, ASISTEN, ADMIN

// Verifikasi header format di dashboard_service.dart

headers: {```POST /api/v1/auth/login

  'Authorization': 'Bearer $token',  // ✅ CORRECT

  // NOT: 'Authorization': token,     // ❌ WRONG (missing 'Bearer')#### M-2.1: Corong Alur Kerja (Workflow Funnel)

},

```Body: { "username": "asisten1", "password": "password123" }



**7. 403 Forbidden Padahal Role Benar**Visual progress tahapan kerja menggunakan **Linear Progress Bars**.

```bash

# Verify role di JWT token payload:**Prinsip:**Response: { "token": "eyJhbGc..." }

# 1. Copy token

# 2. Paste di https://jwt.io/**3 Tahapan Progress:**

# 3. Check payload.role

# 4. Ensure role matches endpoint requirements:- **Separation of Concerns**: UI ↔ Service ↔ API```

#    - M-1: ASISTEN, MANAJER, ADMIN

#    - M-2: MANDOR, ASISTEN, ADMIN**1. Validasi**

```

- **Deskripsi:** Progress validasi lapangan- **Type Safety**: Explicit type casting

**8. Flutter Build Error**

```bash- **Visual:** Linear Progress Bar (Blue)

# Clean build cache

flutter clean- **Data:** `validasi_selesai / target_validasi`- **Error Handling**: Comprehensive error coverage#### Menggunakan Token



# Get dependencies- **Label:** "Validasi: X dari Y Selesai"

flutter pub get

- **Null Safety**: Dart 3.x null-safety enabled

# Rebuild

flutter run -d chrome**2. APH (Aplikasi Pupuk Hayati)**

```

- **Deskripsi:** Progress aplikasi pupuk hayati```dart

---

- **Visual:** Linear Progress Bar (Green)

## 📚 Documentation

- **Data:** `aph_selesai / target_aph`---// Di main.dart atau auth provider

- 📖 **Master Priming Prompt:** `context/mpp_frontend_poac.md.md`

- 🧪 **Verification Checkpoints:**- **Label:** "APH: X dari Y Selesai"

  - `context/VERIFICATION_CHECKPOINT_RBAC.md` (M-1 + RBAC)

  - `context/VERIFICATION_CHECKPOINT_Modul_2.md` (M-2)const String token = 'YOUR_JWT_TOKEN_HERE';

- 📊 **Execution Reports:**

  - `context/LAPORAN_EKSEKUSI_Frontend_1.md` (M-1 implementation)**3. Sanitasi**

  - `context/LAPORAN_EKSEKUSI_Frontend_Modul_2.md` (M-2 implementation)

  - `context/LAPORAN_EKSEKUSI_Frontend_RBAC_1.md` (RBAC implementation)- **Deskripsi:** Progress sanitasi pohon## 🚀 Quick Start



---- **Visual:** Linear Progress Bar (Orange)



## 🚀 Roadmap- **Data:** `sanitasi_selesai / target_sanitasi`// Pass ke DashboardEksekutifView



### **Phase 1: Foundation** ✅- **Label:** "Sanitasi: X dari Y Selesai"

- [x] Flutter project setup

- [x] Dependencies configuration (http, fl_chart, percent_indicator)### Prerequisiteshome: DashboardEksekutifView(token: token),

- [x] App configuration (API URL, timeout)

**Features:**

### **Phase 2: Dashboard READ UI** ✅

- [x] M-1: Dashboard Eksekutif (M-1.1 + M-1.2)- ✅ Percentage display inside bar```

  - [x] M-1.1: Lampu KRI (Lead Time APH + Kepatuhan SOP)

  - [x] M-1.2: Grafik Tren (Insidensi Baru + G4 Aktif)- ✅ Animated progress (800ms)

- [x] M-2: Dashboard Operasional (M-2.1 + M-2.2)

  - [x] M-2.1: Corong Alur Kerja (3 progress bars)- ✅ Safe division (prevent div by zero)1. **Flutter SDK** (≥3.9.2)

  - [x] M-2.2: Papan Peringkat (DataTable dengan top 3 highlighting)

- [x] **RBAC Integration: JWT Authentication**- ✅ Clamped percentage (0-100%)



### **Phase 3: Dashboard Teknis** 🔜   ```bash### Endpoint yang Digunakan

- [ ] M-3: Dashboard Teknis (M-3.1 + M-3.2)

  - [ ] M-3.1: Matriks Kebingungan (Confusion Matrix)#### M-2.2: Papan Peringkat Tim (Team Leaderboard)

  - [ ] M-3.2: Data Distribusi NDRE (NDRE Distribution Chart)

   flutter --version

### **Phase 4: Form SPK** 🔜

- [ ] M-4: Form Surat Perintah KerjaVisual ranking pelaksana menggunakan **DataTable**.

  - [ ] M-4.1: Form Input SPK Header

  - [ ] M-4.2: Form Add Tugas (Batch)   # Flutter 3.9.2 • channel stable**GET /api/v1/dashboard/kpi-eksekutif** 🔐

  - [ ] M-4.3: Preview & Submit

**Columns:**

### **Phase 5: Authentication System** 🔜

- [ ] Login screen dengan JWT1. **Peringkat**: #1, #2, #3... (generated)   ```

- [ ] Token storage (SharedPreferences / FlutterSecureStorage)

- [ ] Auto-refresh token2. **ID Pelaksana**: UUID pelaksana

- [ ] Logout functionality

- [ ] Session management3. **Selesai / Total**: "X / Y" format**Headers (WAJIB):**



### **Phase 6: Advanced Features** 🔜4. **Rate (%)**: Performance percentage

- [ ] State Management (Provider / Riverpod)

- [ ] Multi-page routing (Named routes + Route guards)2. **Backend API Running**```http

- [ ] Offline caching

- [ ] Push notifications**Enhanced Features:**

- [ ] Real-time updates (WebSocket / SSE)

- 🥇 **Rank #1**: Gold background + trophy icon   - URL: `http://localhost:3000`Content-Type: application/json

### **Phase 7: Production Ready** 🔜

- [ ] Comprehensive error logging- 🥈 **Rank #2**: Silver background + trophy icon

- [ ] Analytics integration

- [ ] Performance optimization- 🥉 **Rank #3**: Bronze background + trophy icon   - Endpoints available:Accept: application/json

- [ ] Accessibility improvements

- [ ] Unit + Integration tests- 🎨 **Color-coded Rates**:

- [ ] E2E testing

  - Green (≥80%): High performance     - `GET /api/v1/dashboard/kpi-eksekutif`Authorization: Bearer YOUR_JWT_TOKEN_HERE

---

  - Orange (50-79%): Medium performance

## 👥 Contributors

  - Red (<50%): Low performance     - `GET /api/v1/dashboard/operasional````

- **Developer:** AI Agent (GitHub Copilot)

- **Architect:** Master Priming Prompt (MPP)- 📱 Horizontal scrolling untuk responsiveness

- **Owner:** mastoroshadiq-prog

- 📊 Empty state handling

---



## 📄 License

---3. **JWT Token** (for authentication)**Response Format:**

This project is developed for internal use. All rights reserved.



---

## 🔐 Authentication & RBAC   - Generate from backend: `node scripts/generate-token-only.js````json

## 📞 Support



For issues or questions:

1. Check `context/` folder for documentation### JWT Authentication   - Or use hardcoded test token (development only){

2. Review verification checkpoints

3. Check troubleshooting section above

4. Contact project owner

Semua endpoint dashboard memerlukan **JWT Bearer Token**.  "kri_lead_time_aph": 2.5,

---



**Last Updated:** November 7, 2025  

**Version:** 1.0.0 (M-1 & M-2 Complete)  #### Generate Token (Development)### Installation  "kri_kepatuhan_sop": 78.3,

**Framework:** Master Priming Prompt (MPP) - 3P Principles



**Module Status:**

**Backend Script:**  "tren_insidensi_baru": [

| Module | Feature | Status | Verification Doc |

|--------|---------|--------|------------------|```bash

| M-1 | Dashboard Eksekutif | ✅ Complete | ✅ VERIFICATION_CHECKPOINT_RBAC.md |

| - | M-1.1: Lampu KRI (Lead Time + Kepatuhan SOP) | ✅ Complete | - |# Di backend repository```bash    {"periode": "2024-06", "nilai": 12},

| - | M-1.2: Grafik Tren (G1 + G4) | ✅ Complete | - |

| - | RBAC Integration (JWT) | ✅ Complete | - |cd backend

| M-2 | Dashboard Operasional | ✅ Complete | ✅ VERIFICATION_CHECKPOINT_Modul_2.md |

| - | M-2.1: Corong Alur Kerja (3 bars) | ✅ Complete | - |node scripts/generate-token-only.js# Clone repository    {"periode": "2024-07", "nilai": 8},

| - | M-2.2: Papan Peringkat (Top 3 + Color codes) | ✅ Complete | - |

| - | RBAC Integration (JWT) | ✅ Complete | - |

| M-3 | Dashboard Teknis | 🔜 Next | - |

| M-4 | Form SPK | 🔜 Planned | - |# Output example:git clone https://github.com/mastoroshadiq-prog/frontend-poac.git    ...



**Recent Updates:**# ==================

- ✅ M-1: Dashboard Eksekutif with KRI Indicators & Trend Charts

- ✅ M-2: Dashboard Operasional with Workflow Funnel & Leaderboard# ASISTEN Token:cd frontend-poac  ],

- ✅ RBAC: JWT Authentication for all Dashboard endpoints

- ✅ Error Handling: 401/403 UI with icons and messages# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

- ✅ Formula Accuracy: KRI Kepatuhan SOP normalized to 75% basis (TEPAT!)

# ==================  "tren_g4_aktif": [

**Progress:** 4/7 Features (57% Complete)

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
