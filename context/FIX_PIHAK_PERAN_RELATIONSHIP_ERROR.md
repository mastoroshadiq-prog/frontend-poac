# FIX: PostgrestException pihak_peran Relationship Error

## ❌ ERROR

```
PostgrestException(
  message: Could not find a relationship between 'pihak_peran' and 'pihak',
  code: PGRST200,
  details: Searched for a foreign key relationship between 'pihak_peran' 
           and 'pihak' in the schema 'public', but no matches were found.
)
```

**Source:** Flutter frontend code loading mandor list

---

## 🔍 ROOT CAUSE

**Problem:** Flutter query menggunakan table name `pihak` tapi table yang benar adalah `master_pihak`.

**Schema Actual:**
```sql
-- Table yang ada:
master_pihak (bukan 'pihak')

-- Foreign key:
pihak_peran.id_pihak → master_pihak.id_pihak
```

---

## ✅ SOLUSI

### Option 1: Ganti Table Name di Query

**File Flutter:** Wherever you're loading mandor list (e.g., `lib/services/mandor_service.dart`)

**Wrong Code:**
```dart
// ❌ SALAH - Table 'pihak' tidak exist
final response = await supabase
  .from('pihak_peran')
  .select('*, pihak(nama, username, email)')
  .eq('role', 'MANDOR');
```

**Fixed Code:**
```dart
// ✅ BENAR - Table name adalah 'master_pihak'
final response = await supabase
  .from('pihak_peran')
  .select('*, master_pihak(nama, username, email)')
  .eq('role', 'MANDOR');
```

---

### Option 2: Specify Foreign Key Explicitly

Jika masih error, specify foreign key constraint name:

```dart
// Get foreign key name first
final response = await supabase
  .from('pihak_peran')
  .select('''
    *,
    master_pihak!pihak_peran_id_pihak_fkey(
      id_pihak,
      nama,
      username,
      email
    )
  ''')
  .eq('role', 'MANDOR');
```

---

### Option 3: Use Backend Endpoint Instead

**RECOMMENDED:** Jangan query `pihak_peran` langsung dari Flutter. Pakai backend endpoint.

**Backend sudah ada:** GET `/api/v1/mandor/list`

**Flutter Code:**
```dart
// File: lib/services/mandor_service.dart

Future<List<Mandor>> getMandorList() async {
  try {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api/v1'));
    
    final response = await dio.get(
      '/mandor/list',  // ✅ Backend endpoint
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      final mandors = (response.data['data'] as List)
          .map((json) => Mandor.fromJson(json))
          .toList();
      return mandors;
    } else {
      throw Exception(response.data['message']);
    }
  } catch (e) {
    print('Error loading mandors: $e');
    rethrow;
  }
}
```

**Response from Backend:**
```json
{
  "success": true,
  "data": [
    {
      "id_pihak": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "nama": "Agus (Mandor Sensus)",
      "username": "agus.mandor",
      "email": "agus.mandor@keboen.com",
      "kode_unik": "MANDOR_SENSUS"
    },
    {
      "id_pihak": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12",
      "nama": "Eko (Mandor APH)",
      "username": "eko.mandor",
      "email": "eko.mandor@keboen.com",
      "kode_unik": "MANDOR_APH"
    }
  ]
}
```

---

## 🔍 DEBUG STEPS

### Step 1: Check Table Name

Run di Supabase SQL Editor:
```sql
-- Check tables dengan 'pihak'
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name LIKE '%pihak%';

-- Expected:
-- master_pihak ✅
-- pihak_peran (if exists)
-- NOT 'pihak' ❌
```

### Step 2: Check Foreign Key

```sql
-- Check foreign keys di pihak_peran
SELECT
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'pihak_peran'
AND tc.constraint_type = 'FOREIGN KEY';

-- Expected:
-- pihak_peran_id_pihak_fkey | id_pihak | master_pihak | id_pihak
```

### Step 3: Test Query

```sql
-- Test join query
SELECT 
  pr.*,
  mp.nama,
  mp.username
FROM pihak_peran pr
JOIN master_pihak mp ON pr.id_pihak = mp.id_pihak
WHERE pr.role = 'MANDOR';
```

---

## 📋 CHECKLIST FIX

### Frontend Changes
- [ ] Cari semua `.from('pihak_peran').select('*, pihak(...)')`
- [ ] Ganti `pihak(...)` → `master_pihak(...)`
- [ ] Atau pakai backend endpoint `/mandor/list`
- [ ] Test: Load mandor list → Should work

### Verify Backend Endpoint
- [ ] Check endpoint exists: GET `/api/v1/mandor/list`
- [ ] Test dengan curl/Postman
- [ ] Verify response format

---

## 🧪 TEST

### Test Backend Endpoint

**PowerShell:**
```powershell
$token = "YOUR_SUPABASE_TOKEN"
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/mandor/list" -Headers @{Authorization="Bearer $token"}
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    { "id_pihak": "...", "nama": "Agus (Mandor Sensus)", ... },
    { "id_pihak": "...", "nama": "Eko (Mandor APH)", ... }
  ]
}
```

### Test Flutter

```dart
// In widget
final mandors = await mandorService.getMandorList();
print('Loaded ${mandors.length} mandors');

// Expected:
// Loaded 2 mandors
// Mandor 1: Agus (Mandor Sensus)
// Mandor 2: Eko (Mandor APH)
```

---

## 💡 RECOMMENDATION

**USE BACKEND ENDPOINT** instead of direct Supabase query:

**Why?**
1. ✅ Backend handles table names & relationships correctly
2. ✅ Backend applies proper filtering & security
3. ✅ Easier to debug (check backend logs)
4. ✅ Consistent error handling
5. ✅ Frontend doesn't need to know database schema

**Avoid:**
- ❌ Direct complex joins dari Flutter
- ❌ Hardcoded table/column names di frontend
- ❌ Frontend code tightly coupled dengan DB schema

---

## 📞 IF STILL ERROR

1. **Check backend logs:** Is `/mandor/list` endpoint registered?
2. **Verify schema:** Run `sql/debug_pihak_peran_relationship.sql`
3. **Check RLS:** Ensure `pihak_peran` table has proper RLS policies
4. **Test backend:** Use curl/Postman to verify endpoint works

**Show me:**
- Backend endpoint code for `/mandor/list`
- Full error stack trace
- Supabase schema for `pihak_peran` table
