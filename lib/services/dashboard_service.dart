import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/eksekutif_poac_data.dart';

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
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        // Extract data dari wrapper
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return responseBody['data'] as Map<String, dynamic>;
        }
        return responseBody;
      } else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses Dashboard Eksekutif (403)');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// [INTERNAL] Raw fetch untuk Dashboard Operasional (tanpa extract dari wrapper)
  /// Digunakan oleh fetchEksekutifPOACData untuk parallel fetching
  Future<Map<String, dynamic>> _fetchDashboardOperasionalRaw(String token) async {
    try {
      final uri = Uri.parse('$baseUrl/dashboard/operasional');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        // Extract data dari wrapper
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          return responseBody['data'] as Map<String, dynamic>;
        }
        return responseBody;
      } else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses Dashboard Operasional (403)');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
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
}
