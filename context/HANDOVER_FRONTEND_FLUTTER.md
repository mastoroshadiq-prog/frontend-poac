# HANDOVER KE TIM FRONTEND FLUTTER WEB

## ✅ CREDENTIALS SUPABASE AUTH (SUDAH DIBUAT)

```
agus.mandor@keboen.com / mandor123 → MANDOR
eko.mandor@keboen.com / mandor123 → MANDOR  
asisten.budi@keboen.com / asisten123 → ASISTEN
admin@keboen.com / admin123 → ADMIN
```

---

## 📡 BACKEND API ENDPOINTS (READY TO USE)

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication Header
```dart
final token = Supabase.instance.client.auth.currentSession?.accessToken;

dio.options.headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

---

## 🎯 ROUTING SETELAH LOGIN

### Login Success → Get Role → Navigate

```dart
// 1. Login
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: 'agus.mandor@keboen.com',
  password: 'mandor123',
);

// 2. Get user profile & role
final userId = response.user!.id;
final profileResponse = await dio.get(
  'http://localhost:3000/api/v1/auth/profile',
  options: Options(headers: {
    'Authorization': 'Bearer ${response.session!.accessToken}',
  }),
);

final role = profileResponse.data['user']['role'];

// 3. Navigate based on role
switch (role) {
  case 'MANDOR':
    Navigator.pushReplacementNamed(context, '/mandor/dashboard');
    break;
  case 'ASISTEN':
    Navigator.pushReplacementNamed(context, '/asisten/dashboard');
    break;
  case 'ADMIN':
    Navigator.pushReplacementNamed(context, '/admin/dashboard');
    break;
}
```

---

## 📊 DASHBOARD ENDPOINTS

### 1. Mandor Dashboard
```dart
// GET /api/v1/mandor/dashboard
final response = await dio.get('/mandor/dashboard');

// Response:
{
  "success": true,
  "data": {
    "mandor": {
      "id_pihak": "...",
      "nama": "Agus (Mandor Sensus)",
      "username": "agus.mandor"
    },
    "metrics": {
      "total_blok": 150,
      "total_pokok": 25000,
      "spk_aktif": 3,
      "spk_pending": 1,
      "spk_selesai": 45
    },
    "recent_spk": [...],
    "anomaly_alerts": [...]
  }
}
```

### 2. Dashboard Operasional (All Roles)
```dart
// GET /api/v1/dashboard/operasional
final response = await dio.get('/dashboard/operasional');

// Response: Grafik panen, produksi, mutu TBS
```

### 3. Dashboard Teknis (All Roles)
```dart
// GET /api/v1/dashboard/teknis
final response = await dio.get('/dashboard/teknis');

// Response: Kesehatan kebun, NDRE, anomali
```

---

## 🔔 NOTIFICATIONS

```dart
// GET /api/v1/notifications?user_id={id_pihak}
final response = await dio.get('/notifications?user_id=$userId');

// Response:
{
  "success": true,
  "data": [
    {
      "id": "...",
      "title": "SPK Baru Ditugaskan",
      "message": "Anda mendapat SPK Sensus Blok A1",
      "type": "SPK_ASSIGNED",
      "is_read": false,
      "created_at": "2025-11-19T10:00:00Z"
    }
  ]
}
```

---

## 🔐 RLS POLICY (SUDAH AKTIF)

**Mandor hanya lihat data blok mereka:**
```sql
-- master_pihak: Mandor hanya lihat data sendiri
-- tugas_spk: Mandor hanya lihat tugas yang ditugaskan ke mereka
-- log_aktivitas_5w1h: Mandor hanya lihat log mereka
```

---

## 📋 FLUTTER ROUTES CONFIG

```dart
final routes = {
  '/': (context) => LoginPage(),
  '/mandor/dashboard': (context) => MandorDashboardPage(),
  '/mandor/spk': (context) => MandorSpkListPage(),
  '/mandor/spk/:id': (context) => MandorSpkDetailPage(),
  '/mandor/notifications': (context) => NotificationsPage(),
  '/asisten/dashboard': (context) => AsistenDashboardPage(),
  '/admin/dashboard': (context) => AdminDashboardPage(),
};
```

---

## 🛡️ AUTH GUARD

```dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }
        
        if (!snapshot.hasData) {
          Navigator.pushReplacementNamed(context, '/');
          return Container();
        }
        
        final role = snapshot.data!['role'];
        if (!allowedRoles.contains(role)) {
          return UnauthorizedPage();
        }
        
        return child;
      },
    );
  }

  Future<Map<String, dynamic>> _checkAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return {};
    
    final response = await dio.get('/auth/profile');
    return response.data['user'];
  }
}
```

---

## 📦 PACKAGES YANG DIBUTUHKAN

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  dio: ^5.0.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.0.0  # atau riverpod/bloc
```

---

## 🚀 QUICK START

1. **Install packages:** `flutter pub get`
2. **Init Supabase:**
```dart
await Supabase.initialize(
  url: 'https://wwbibxdhawlrhmvukovs.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```
3. **Test login:** `agus.mandor@keboen.com` / `mandor123`
4. **Check profile endpoint:** GET `/api/v1/auth/profile`
5. **Navigate ke dashboard sesuai role**

---

## ⚠️ YANG HARUS DICEK BACKEND

- [ ] Endpoint `/api/v1/auth/profile` (get user role & data)
- [ ] Endpoint `/api/v1/mandor/dashboard` (mandor dashboard data)
- [ ] RLS policy untuk mandor (sudah ada tapi perlu verify)
- [ ] Supabase Auth middleware di semua protected routes

**File yang perlu dibuat/update:**
1. `routes/authRoutes.js` - tambah GET `/profile`
2. `routes/mandorRoutes.js` - tambah GET `/dashboard` 
3. `middleware/supabaseAuthMiddleware.js` - verify token & extract role
