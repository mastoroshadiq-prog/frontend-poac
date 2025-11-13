import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/eksekutif_poac_data.dart';
import '../models/panen_data.dart';
import '../models/ndre_statistics.dart';

/// Service class untuk mengelola API calls ke Dashboard Backend
/// Sesuai Prinsip MPP: SIMPLE, TEPAT, PENINGKATAN BERTAHAP
class DashboardService {
  // Base URL Backend API dari AppConfig
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// [INTERNAL] Helper untuk mendapatkan JWT token dari Supabase session
  /// 
  /// Throws: Exception jika session tidak ditemukan atau token null
  String _getAuthToken() {
    final session = SupabaseConfig.client.auth.currentSession;
    if (session == null) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }
    return session.accessToken;
  }

  /// [REFACTOR FRONTEND #1] Fetch data gabungan untuk Dashboard Eksekutif POAC
  /// 
  /// Menggabungkan data dari 2 endpoint secara PARALEL:
  /// 1. GET /dashboard/kpi-eksekutif (untuk kuadran C - Control & P - Plan)
  /// 2. GET /dashboard/operasional (untuk kuadran O - Organize & A - Actuate)
  /// 
  /// RBAC: Memerlukan role ASISTEN atau ADMIN
  /// 
  /// Returns: EksekutifPOACData yang berisi kedua set data
  /// 
  /// Throws:
  ///   - Exception('Sesi login tidak ditemukan') jika tidak ada session
  ///   - Exception('Akses Ditolak') jika 403 Forbidden pada salah satu endpoint
  ///   - Exception('Silakan Login') jika 401 Unauthorized pada salah satu endpoint
  Future<EksekutifPOACData> fetchEksekutifPOACData() async {
    try {
      // Step 1: Dapatkan token dari Supabase session
      final token = _getAuthToken();

      // Step 2: Panggil KEDUA endpoint secara PARALEL menggunakan Future.wait
      final results = await Future.wait([
        _fetchKpiEksekutifRaw(token),
        _fetchDashboardOperasionalRaw(token),
      ]);

      // Step 3: Extract hasil dari kedua panggilan
      final kpiData = results[0];
      final operasionalData = results[1];

      // Step 4: Kembalikan model data gabungan
      return EksekutifPOACData(
        kpiData: kpiData,
        operasionalData: operasionalData,
      );
    } catch (e) {
      // Preserve specific error messages
      rethrow;
    }
  }

  /// [INTERNAL] Raw fetch untuk KPI Eksekutif (tanpa extract dari wrapper)
  /// Digunakan oleh fetchEksekutifPOACData untuk parallel fetching
  Future<Map<String, dynamic>> _fetchKpiEksekutifRaw(String token) async {
    try {
      final uri = Uri.parse('$baseUrl/dashboard/kpi-eksekutif');
      print('🔍 [DEBUG] Fetching KPI Eksekutif from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.requestTimeout);

      print('🔍 [DEBUG] KPI Eksekutif Response Status: ${response.statusCode}');
      print('🔍 [DEBUG] KPI Eksekutif Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        // Extract data dari wrapper
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          print('✅ [DEBUG] KPI Eksekutif data extracted successfully');
          return responseBody['data'] as Map<String, dynamic>;
        }
        print('✅ [DEBUG] KPI Eksekutif using raw response body');
        return responseBody;
      } else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses Dashboard Eksekutif (403)');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ [DEBUG] Error in _fetchKpiEksekutifRaw: $e');
      rethrow;
    }
  }

  /// [INTERNAL] Raw fetch untuk Dashboard Operasional (tanpa extract dari wrapper)
  /// Digunakan oleh fetchEksekutifPOACData untuk parallel fetching
  Future<Map<String, dynamic>> _fetchDashboardOperasionalRaw(String token) async {
    try {
      final uri = Uri.parse('$baseUrl/dashboard/operasional');
      print('🔍 [DEBUG] Fetching Dashboard Operasional from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.requestTimeout);

      print('🔍 [DEBUG] Operasional Response Status: ${response.statusCode}');
      print('🔍 [DEBUG] Operasional Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        // Extract data dari wrapper
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          print('✅ [DEBUG] Operasional data extracted successfully');
          return responseBody['data'] as Map<String, dynamic>;
        }
        print('✅ [DEBUG] Operasional using raw response body');
        return responseBody;
      } else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses Dashboard Operasional (403)');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ [DEBUG] Error in _fetchDashboardOperasionalRaw: $e');
      rethrow;
    }
  }

  /// Fetch KPI Eksekutif dari Backend (dengan JWT Authentication)
  /// 
  /// RBAC FASE 2: Endpoint ini sekarang memerlukan autentikasi JWT
  /// Memanggil endpoint: GET /api/v1/dashboard/kpi-eksekutif
  /// 
  /// Parameters:
  ///   - token: JWT token untuk autentikasi (dari login/generate-token-only.js)
  /// 
  /// Returns: Map dengan struktur:
  /// {
  ///   "kri_lead_time_aph": double,
  ///   "kri_kepatuhan_sop": double,
  ///   "tren_insidensi_baru": List<Map<String, dynamic>>,
  ///   "tren_g4_aktif": List<Map<String, dynamic>>
  /// }
  /// 
  /// Throws: 
  ///   - Exception('Silakan Login') jika 401 Unauthorized
  ///   - Exception('Akses Ditolak') jika 403 Forbidden
  ///   - Exception lain untuk error lainnya
  Future<Map<String, dynamic>> fetchKpiEksekutif(String token) async {
    try {
      // Buat URI endpoint (PERUBAHAN: kpi_eksekutif → kpi-eksekutif)
      final uri = Uri.parse('$baseUrl/dashboard/kpi-eksekutif');

      // Panggil API dengan JWT token di header (WAJIB RBAC)
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ⬅️ PERUBAHAN KRITIS: JWT Authentication
        },
      ).timeout(
        AppConfig.requestTimeout,
        onTimeout: () {
          throw Exception('Request timeout: Server tidak merespons dalam ${AppConfig.requestTimeout.inSeconds} detik');
        },
      );

      // Validasi status code (Prinsip TEPAT: Error handling yang akurat + RBAC)
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Backend mengembalikan struktur: { "success": true, "data": {...}, "message": "..." }
        // Kita perlu extract object 'data'
        Map<String, dynamic> data;
        
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          // Extract data object dari wrapper
          data = responseBody['data'] as Map<String, dynamic>;
        } else {
          // Fallback: assume data is at root level
          data = responseBody;
        }
        
        // Validasi struktur data
        if (!data.containsKey('kri_lead_time_aph') ||
            !data.containsKey('kri_kepatuhan_sop') ||
            !data.containsKey('tren_insidensi_baru') ||
            !data.containsKey('tren_g4_aktif')) {
          
          throw Exception('Format response tidak sesuai: Missing required fields. Keys found: ${data.keys.join(", ")}');
        }

        return data;
      } 
      // PERUBAHAN KRITIS: Handle 401 Unauthorized (RBAC)
      else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } 
      // PERUBAHAN KRITIS: Handle 403 Forbidden (RBAC)
      else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses data ini (403)');
      } 
      else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan (404): Pastikan backend sudah running');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Tidak dapat terhubung ke server - $e');
    } on FormatException catch (e) {
      throw Exception('Parse error: Response bukan JSON valid - $e');
    } catch (e) {
      // Re-throw exception lain dengan pesan yang jelas
      if (e.toString().contains('Silakan Login') || 
          e.toString().contains('Akses Ditolak')) {
        rethrow; // Preserve specific auth errors
      }
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch Dashboard Operasional dari Backend (dengan JWT Authentication)
  /// 
  /// RBAC: Endpoint ini memerlukan autentikasi JWT dengan role MANDOR, ASISTEN, atau ADMIN
  /// Memanggil endpoint: GET /api/v1/dashboard/operasional
  /// 
  /// Parameters:
  ///   - token: JWT token untuk autentikasi (dari login/generate-token-only.js)
  /// 
  /// Returns: Map dengan struktur:
  /// {
  ///   "data_corong": {
  ///     "validasi_selesai": int,
  ///     "target_validasi": int,
  ///     "aph_selesai": int,
  ///     "target_aph": int,
  ///     "sanitasi_selesai": int,
  ///     "target_sanitasi": int
  ///   },
  ///   "data_papan_peringkat": [
  ///     {
  ///       "id_pelaksana": String,
  ///       "selesai": int,
  ///       "total": int,
  ///       "rate": double
  ///     }
  ///   ]
  /// }
  /// 
  /// Throws: 
  ///   - Exception('Silakan Login') jika 401 Unauthorized
  ///   - Exception('Akses Ditolak') jika 403 Forbidden
  ///   - Exception lain untuk error lainnya
  Future<Map<String, dynamic>> fetchDashboardOperasional(String token) async {
    try {
      // Buat URI endpoint
      final uri = Uri.parse('$baseUrl/dashboard/operasional');

      // Panggil API dengan JWT token di header (WAJIB RBAC)
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ⬅️ KRITIS: JWT Authentication
        },
      ).timeout(
        AppConfig.requestTimeout,
        onTimeout: () {
          throw Exception('Request timeout: Server tidak merespons dalam ${AppConfig.requestTimeout.inSeconds} detik');
        },
      );

      // Validasi status code (Prinsip TEPAT: Error handling yang akurat + RBAC)
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Backend mengembalikan struktur: { "success": true, "data": {...}, "message": "..." }
        // Kita perlu extract object 'data'
        Map<String, dynamic> data;
        
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          // Extract data object dari wrapper
          data = responseBody['data'] as Map<String, dynamic>;
        } else {
          // Fallback: assume data is at root level
          data = responseBody;
        }
        
        // Validasi struktur data
        if (!data.containsKey('data_corong') ||
            !data.containsKey('data_papan_peringkat')) {
          throw Exception('Format response tidak sesuai: Missing required fields. Keys found: ${data.keys.join(", ")}');
        }

        return data;
      } 
      // Handle 401 Unauthorized (RBAC)
      else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } 
      // Handle 403 Forbidden (RBAC)
      else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses data ini (403)');
      } 
      else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan (404): Pastikan backend sudah running');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Tidak dapat terhubung ke server - $e');
    } on FormatException catch (e) {
      throw Exception('Parse error: Response bukan JSON valid - $e');
    } catch (e) {
      // Re-throw exception lain dengan pesan yang jelas
      if (e.toString().contains('Silakan Login') || 
          e.toString().contains('Akses Ditolak')) {
        rethrow; // Preserve specific auth errors
      }
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch Dashboard Teknis dari Backend (dengan JWT Authentication)
  /// 
  /// RBAC: Endpoint ini memerlukan autentikasi JWT dengan role MANDOR, ASISTEN, atau ADMIN
  /// Memanggil endpoint: GET /api/v1/dashboard/teknis
  /// 
  /// Parameters:
  ///   - token: JWT token untuk autentikasi (dari login/generate-token-only.js)
  /// 
  /// Returns: Map dengan struktur:
  /// {
  ///   "data_matriks_kebingungan": {
  ///     "true_positive": int,
  ///     "false_positive": int,
  ///     "false_negative": int,
  ///     "true_negative": int
  ///   },
  ///   "data_distribusi_ndre": [
  ///     {
  ///       "status_aktual": String,
  ///       "jumlah": int
  ///     }
  ///   ]
  /// }
  /// 
  /// Throws: 
  ///   - Exception('Silakan Login') jika 401 Unauthorized
  ///   - Exception('Akses Ditolak') jika 403 Forbidden
  ///   - Exception lain untuk error lainnya
  Future<Map<String, dynamic>> fetchDashboardTeknis(String token) async {
    try {
      // Buat URI endpoint
      final uri = Uri.parse('$baseUrl/dashboard/teknis');

      // Panggil API dengan JWT token di header (WAJIB RBAC)
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ⬅️ KRITIS: JWT Authentication
        },
      ).timeout(
        AppConfig.requestTimeout,
        onTimeout: () {
          throw Exception('Request timeout: Server tidak merespons dalam ${AppConfig.requestTimeout.inSeconds} detik');
        },
      );

      // Validasi status code (Prinsip TEPAT: Error handling yang akurat + RBAC)
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Backend mengembalikan struktur: { "success": true, "data": {...}, "message": "..." }
        // Kita perlu extract object 'data'
        Map<String, dynamic> data;
        
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          // Extract data object dari wrapper
          data = responseBody['data'] as Map<String, dynamic>;
        } else {
          // Fallback: assume data is at root level
          data = responseBody;
        }
        
        // Validasi struktur data
        if (!data.containsKey('data_matriks_kebingungan') ||
            !data.containsKey('data_distribusi_ndre')) {
          throw Exception('Format response tidak sesuai: Missing required fields. Keys found: ${data.keys.join(", ")}');
        }

        return data;
      } 
      // Handle 401 Unauthorized (RBAC)
      else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } 
      // Handle 403 Forbidden (RBAC)
      else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses data ini (403)');
      } 
      else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan (404): Pastikan backend sudah running');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Tidak dapat terhubung ke server - $e');
    } on FormatException catch (e) {
      throw Exception('Parse error: Response bukan JSON valid - $e');
    } catch (e) {
      // Re-throw exception lain dengan pesan yang jelas
      if (e.toString().contains('Silakan Login') || 
          e.toString().contains('Akses Ditolak')) {
        rethrow; // Preserve specific auth errors
      }
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch Dashboard Panen (KPI Hasil PANEN) dari Backend (dengan JWT Authentication)
  /// 
  /// ENHANCEMENT: Endpoint NEW untuk tracking hasil panen (TBS tonnage, reject rate, SPK execution)
  /// Data Source: NEW Schema (ops_panen, ops_spk_panen, ops_panen_execution, sop_checklist_panen_item)
  /// Memanggil endpoint: GET /api/v1/dashboard/panen
  /// 
  /// RBAC: Endpoint ini memerlukan autentikasi JWT dengan role MANDOR, ASISTEN, atau ADMIN
  /// 
  /// Returns: PanenData dengan struktur:
  /// {
  ///   "summary": {
  ///     "total_ton_tbs": double,
  ///     "avg_reject_persen": double,
  ///     "total_spk": int,
  ///     "total_executions": int
  ///   },
  ///   "by_spk": [
  ///     {
  ///       "nomor_spk": String,
  ///       "lokasi": String,
  ///       "mandor": String,
  ///       "status": String,
  ///       "periode": String,
  ///       "total_ton": double,
  ///       "avg_reject": double,
  ///       "execution_count": int,
  ///       "executions": [...]
  ///     }
  ///   ],
  ///   "weekly_breakdown": [
  ///     {
  ///       "week_start": String,
  ///       "total_ton": double,
  ///       "avg_reject": double,
  ///       "execution_count": int
  ///     }
  ///   ]
  /// }
  /// 
  /// Throws: 
  ///   - Exception('Silakan Login') jika 401 Unauthorized
  ///   - Exception('Akses Ditolak') jika 403 Forbidden
  ///   - Exception lain untuk error lainnya
  Future<PanenData> fetchPanenData() async {
    try {
      // Step 1: Dapatkan token dari Supabase session
      final token = _getAuthToken();

      // Step 2: Buat URI endpoint
      final uri = Uri.parse('$baseUrl/dashboard/panen');
      print('🔍 [DEBUG] Fetching Dashboard Panen from: $uri');

      // Step 3: Panggil API dengan JWT token di header (WAJIB RBAC)
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        AppConfig.requestTimeout,
        onTimeout: () {
          throw Exception('Request timeout: Server tidak merespons dalam ${AppConfig.requestTimeout.inSeconds} detik');
        },
      );

      print('🔍 [DEBUG] Panen Response Status: ${response.statusCode}');
      print('🔍 [DEBUG] Panen Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      // Step 4: Validasi status code
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Backend mengembalikan struktur: { "success": true, "data": {...}, "message": "..." }
        // Extract object 'data'
        Map<String, dynamic> data;
        
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          data = responseBody['data'] as Map<String, dynamic>;
          print('✅ [DEBUG] Panen data extracted successfully');
        } else {
          data = responseBody;
          print('✅ [DEBUG] Panen using raw response body');
        }
        
        // Parse ke PanenData model
        return PanenData.fromJson(data);
      } 
      // Handle 401 Unauthorized (RBAC)
      else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } 
      // Handle 403 Forbidden (RBAC)
      else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses Dashboard Panen (403)');
      } 
      else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan (404): Pastikan backend sudah running');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Tidak dapat terhubung ke server - $e');
    } on FormatException catch (e) {
      throw Exception('Parse error: Response bukan JSON valid - $e');
    } catch (e) {
      // Re-throw exception lain dengan pesan yang jelas
      if (e.toString().contains('Silakan Login') || 
          e.toString().contains('Akses Ditolak')) {
        rethrow; // Preserve specific auth errors
      }
      print('❌ [DEBUG] Error in fetchPanenData: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fungsi helper untuk konversi array tren ke format chart
  /// 
  /// Input: List dari backend, misal:
  /// [{"periode": "2024-01", "nilai": 5}, {"periode": "2024-02", "nilai": 3}]
  /// 
  /// Output: List<Map<String, dynamic>> yang siap digunakan untuk fl_chart
  List<Map<String, dynamic>> parseTrendData(List<dynamic> trendArray) {
    if (trendArray.isEmpty) {
      return [];
    }

    return trendArray.map((item) {
      return {
        'periode': item['periode'] ?? '',
        'nilai': (item['nilai'] ?? 0).toDouble(),
      };
    }).toList();
  }

  // ============================================================================
  // NDRE STATISTICS API - Dashboard Asisten Tier 3
  // ============================================================================

  /// Fetch NDRE Statistics (Distribution Pie Chart & Bar Chart)
  /// 
  /// GET /api/v1/dashboard/ndre-statistics
  /// 
  /// Query Parameters:
  ///   - divisi: Filter by divisi (optional)
  ///   - blok: Filter by blok (optional)
  ///   - startDate: Filter start date (optional, ISO 8601)
  ///   - endDate: Filter end date (optional, ISO 8601)
  /// 
  /// Returns: NdreStatistics with:
  /// {
  ///   "total_pohon": int,
  ///   "stres_berat": int (NDRE < 0.30),
  ///   "stres_sedang": int (0.30 <= NDRE < 0.45),
  ///   "sehat": int (NDRE >= 0.45),
  ///   "average_ndre": double,
  ///   "min_ndre": double,
  ///   "max_ndre": double,
  ///   "divisi": String (optional),
  ///   "blok": String (optional),
  ///   "timestamp": String (ISO 8601)
  /// }
  /// 
  /// RBAC: Requires MANDOR, ASISTEN, or ADMIN role
  Future<NdreStatistics> getNdreStatistics({
    String? divisi,
    String? blok,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = _getAuthToken();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final url = Uri.parse('$baseUrl/api/v1/dashboard/ndre-statistics').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🔍 [DEBUG] Fetching NDRE Statistics from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(AppConfig.requestTimeout);

      print('🔍 [DEBUG] NDRE Statistics Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        // Extract data dari wrapper jika ada
        final data = jsonData.containsKey('data') && jsonData['data'] is Map
            ? jsonData['data'] as Map<String, dynamic>
            : jsonData;

        print('✅ [DEBUG] NDRE Statistics fetched successfully');
        return NdreStatistics.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses data NDRE (403)');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan (404): Pastikan backend sudah running');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Fallback to dummy data for development
      print('⚠️ [DEBUG] Using dummy NDRE statistics data: $e');
      return NdreStatistics.dummy();
    }
  }

  // ============================================================================
  // LIFECYCLE APIs - Multi-Phase Lifecycle Dashboard
  // ============================================================================

  /// Fetch Lifecycle Overview (5 phases summary)
  /// 
  /// GET /api/v1/lifecycle/overview
  /// 
  /// Returns: LifecycleOverview with health_index, total_spks, phases array
  /// 
  /// RBAC: Requires MANDOR, ASISTEN, or ADMIN role
  Future<Map<String, dynamic>> fetchLifecycleOverview() async {
    try {
      final token = _getAuthToken();
      final url = Uri.parse('$baseUrl/lifecycle/overview');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Silakan Login - Session expired');
      }

      if (response.statusCode == 403) {
        throw Exception('Akses Ditolak - Requires MANDOR/ASISTEN/ADMIN role');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch lifecycle overview: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      
      // DEBUG: Print response untuk troubleshooting
      print('📡 Lifecycle Overview Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Parsed JSON: $jsonData');
      print('JSON Keys: ${jsonData is Map ? jsonData.keys.toList() : 'Not a Map'}');
      
      // Validate response structure
      if (jsonData == null) {
        throw Exception('Response body is null');
      }
      
      if (jsonData is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      
      // Backend might return data directly or wrapped in "data" field
      // Check which structure is used
      if (jsonData.containsKey('data') && jsonData['data'] != null) {
        // Wrapped format: { "data": {...} }
        if (jsonData['data'] is! Map<String, dynamic>) {
          throw Exception('Response "data" is not a valid object');
        }
        return jsonData['data'] as Map<String, dynamic>;
      } else {
        // Direct format: { "health_index": ..., "phases": [...] }
        // Return the entire response as-is
        return jsonData;
      }
    } catch (e) {
      print('❌ Error in fetchLifecycleOverview: $e');
      throw Exception('Error fetching lifecycle overview: $e');
    }
  }

  /// Fetch Phase Detail (specific phase data)
  /// 
  /// GET /api/v1/lifecycle/phase/:phase_name
  /// 
  /// Params:
  ///   - phaseName: Pembibitan | TBM | TM | Pemanenan | Replanting
  /// 
  /// Returns: PhaseDetail with phase_info, summary, spks, weekly_breakdown
  /// 
  /// RBAC: Requires MANDOR, ASISTEN, or ADMIN role
  Future<Map<String, dynamic>> fetchPhaseDetail(String phaseName) async {
    try {
      final token = _getAuthToken();
      final url = Uri.parse('$baseUrl/lifecycle/phase/$phaseName');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Silakan Login - Session expired');
      }

      if (response.statusCode == 403) {
        throw Exception('Akses Ditolak - Requires MANDOR/ASISTEN/ADMIN role');
      }

      if (response.statusCode == 404) {
        throw Exception('Phase "$phaseName" tidak ditemukan');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch phase detail: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      
      // Validate response structure
      if (jsonData == null) {
        throw Exception('Response body is null');
      }
      
      if (jsonData is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      
      // Backend might return data directly or wrapped in "data" field
      if (jsonData.containsKey('data') && jsonData['data'] != null) {
        if (jsonData['data'] is! Map<String, dynamic>) {
          throw Exception('Response "data" is not a valid object');
        }
        return jsonData['data'] as Map<String, dynamic>;
      } else {
        return jsonData;
      }
    } catch (e) {
      throw Exception('Error fetching phase detail: $e');
    }
  }

  /// Fetch SOP Compliance Data
  /// 
  /// GET /api/v1/lifecycle/sop-compliance
  /// 
  /// Returns: SOPComplianceData with overall_compliance, compliant_phases, needs_attention
  /// 
  /// RBAC: Requires ASISTEN or ADMIN role (executive level)
  Future<Map<String, dynamic>> fetchSOPCompliance() async {
    try {
      final token = _getAuthToken();
      final url = Uri.parse('$baseUrl/lifecycle/sop-compliance');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Silakan Login - Session expired');
      }

      if (response.statusCode == 403) {
        throw Exception('Akses Ditolak - Requires ASISTEN/ADMIN role');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch SOP compliance: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      
      // Validate response structure
      if (jsonData == null) {
        throw Exception('Response body is null');
      }
      
      if (jsonData is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      
      // Backend might return data directly or wrapped in "data" field
      if (jsonData.containsKey('data') && jsonData['data'] != null) {
        if (jsonData['data'] is! Map<String, dynamic>) {
          throw Exception('Response "data" is not a valid object');
        }
        return jsonData['data'] as Map<String, dynamic>;
      } else {
        return jsonData;
      }
    } catch (e) {
      throw Exception('Error fetching SOP compliance: $e');
    }
  }
}
