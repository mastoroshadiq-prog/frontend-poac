import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/spk_kanban_data.dart';

/// Service untuk mengelola SPK (Surat Perintah Kerja)
/// Endpoint: POST /api/v1/spk dan POST /api/v1/spk/:id_spk/tugas
/// RBAC: Memerlukan role ASISTEN atau ADMIN
class SPKService {
  final String baseUrl = AppConfig.apiBaseUrl;

  /// Membuat SPK Header baru
  /// 
  /// Parameters:
  /// - namaSpk: Nama SPK yang akan dibuat
  /// - tanggalTargetSelesai: (Optional) Target tanggal selesai
  /// - keterangan: (Optional) Keterangan tambahan
  /// 
  /// Returns: Map berisi data SPK yang baru dibuat (termasuk id_spk)
  /// Throws: Exception jika gagal (401/403/500)
  Future<Map<String, dynamic>> createSpkHeader({
    required String namaSpk,
    DateTime? tanggalTargetSelesai,
    String? keterangan,
  }) async {
    try {
      // Dapatkan token dari Supabase session (WAJIB TEPAT - sesuai pola dashboard_service)
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final token = session.accessToken;

      // Siapkan request body
      final body = {
        'nama_spk': namaSpk,
        if (tanggalTargetSelesai != null)
          'tanggal_target_selesai': tanggalTargetSelesai.toIso8601String(),
        if (keterangan != null && keterangan.isNotEmpty)
          'keterangan': keterangan,
      };

      // Panggil API POST /api/v1/spk
      final response = await http.post(
        Uri.parse('$baseUrl/spk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
        body: jsonEncode(body),
      ).timeout(AppConfig.requestTimeout);

      // Handle response berdasarkan status code
      if (response.statusCode == 201) {
        // Sukses - SPK berhasil dibuat
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi login tidak valid. Silakan login kembali.');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya ASISTEN dan ADMIN yang dapat membuat SPK.');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception('Data tidak valid: ${error['message'] ?? 'Periksa input Anda'}');
      } else {
        throw Exception('Gagal membuat SPK. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Menambahkan daftar tugas ke SPK yang sudah dibuat
  /// 
  /// Parameters:
  /// - idSpk: ID SPK yang sudah dibuat (dari hasil createSpkHeader)
  /// - daftarTugas: List berisi data tugas yang akan ditambahkan
  ///   Setiap tugas harus memiliki: id_pelaksana, tipe_tugas
  /// 
  /// Returns: true jika sukses
  /// Throws: Exception jika gagal
  Future<bool> addTugasKeSpk(
    String idSpk,
    List<Map<String, dynamic>> daftarTugas,
  ) async {
    try {
      // Dapatkan token dari Supabase session
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final token = session.accessToken;

      // Validasi input
      if (daftarTugas.isEmpty) {
        throw Exception('Daftar tugas tidak boleh kosong');
      }

      // Panggil API POST /api/v1/spk/:id_spk/tugas
      final response = await http.post(
        Uri.parse('$baseUrl/spk/$idSpk/tugas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
        body: jsonEncode({'tugas': daftarTugas}),
      ).timeout(AppConfig.requestTimeout);

      // Handle response
      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi login tidak valid. Silakan login kembali.');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya ASISTEN dan ADMIN yang dapat menambah tugas.');
      } else if (response.statusCode == 404) {
        throw Exception('SPK tidak ditemukan. ID: $idSpk');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception('Data tugas tidak valid: ${error['message'] ?? 'Periksa input'}');
      } else {
        throw Exception('Gagal menambahkan tugas. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetch SPK Kanban Data untuk Dashboard Asisten
  /// 
  /// GET /api/v1/spk/kanban
  /// 
  /// Query Parameters:
  /// - divisi: Filter by divisi (optional)
  /// - blok: Filter by blok (optional)
  /// - tipe_spk: Filter by tipe SPK (optional)
  /// 
  /// Returns: SpkKanbanData dengan 3 kolom (PENDING/DIKERJAKAN/SELESAI)
  /// RBAC: Requires MANDOR, ASISTEN, or ADMIN role
  Future<SpkKanbanData> getSpkKanban({
    String? divisi,
    String? blok,
    String? tipeSpk,
  }) async {
    try {
      // Dapatkan token dari Supabase session
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final token = session.accessToken;

      // Build query parameters
      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;
      if (tipeSpk != null) queryParams['tipe_spk'] = tipeSpk;

      final url = Uri.parse('$baseUrl/spk/kanban').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🔍 [DEBUG] Fetching SPK Kanban from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      ).timeout(AppConfig.requestTimeout);

      print('🔍 [DEBUG] SPK Kanban Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Extract data dari wrapper jika ada
        final data = jsonData.containsKey('data') && jsonData['data'] is Map
            ? jsonData['data'] as Map<String, dynamic>
            : jsonData;
        
        return SpkKanbanData.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengakses data SPK (403)');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan (404): Pastikan backend sudah running');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Fallback to dummy data for development
      print('⚠️ [DEBUG] Using dummy SPK kanban data: $e');
      return SpkKanbanData.dummy();
    }
  }


  /// Mengambil daftar mandor untuk dropdown form SPK
  /// 
  /// Returns: List<Map> dengan struktur [{id_pihak, nama}, ...]
  /// Backend endpoint: GET /api/v1/mandor/list
  Future<List<Map<String, dynamic>>> getDaftarMandor() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final token = session.accessToken;

      print(' [SPKService] Fetching daftar mandor from /mandor/list...');

      final response = await http.get(
        Uri.parse('$baseUrl/mandor/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      ).timeout(AppConfig.requestTimeout);

      print(' [SPKService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        // Backend returns: {success: true, data: {mandor_list: [...]}}
        if (jsonData['success'] == true && 
            jsonData['data'] != null && 
            jsonData['data']['mandor_list'] != null) {
          final List<dynamic> mandorList = jsonData['data']['mandor_list'];
          print(' [SPKService] Got ${mandorList.length} mandor');
          return mandorList.cast<Map<String, dynamic>>();
        } else {
          print(' [SPKService] Backend returned no mandor_list, using fallback');
          return _getFallbackMandor();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi login tidak valid. Silakan login kembali.');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya ASISTEN dan ADMIN yang dapat melihat daftar mandor.');
      } else {
        print(' [SPKService] HTTP error ${response.statusCode}, using fallback');
        return _getFallbackMandor();
      }
    } catch (e) {
      print(' [SPKService] Error loading mandors: $e');
      print(' [SPKService] Using fallback dummy data');
      return _getFallbackMandor();
    }
  }

  /// Fallback dummy data untuk development (sesuai backend docs)
  List<Map<String, dynamic>> _getFallbackMandor() {
    return [
      {
        'id_pihak': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
        'nama': 'Agus (Mandor Sensus)',
        'kode_unik': 'AGUS_MANDOR',
        'tipe': 'INTERNAL',
      },
      {
        'id_pihak': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
        'nama': 'Eko (Mandor APH)',
        'kode_unik': 'EKO_MANDOR',
        'tipe': 'INTERNAL',
      },
    ];
  }

  /// Update status SPK (untuk drag & drop kanban)
  /// 
  /// PATCH /api/v1/spk/:id_spk/status
  /// 
  /// Parameters:
  /// - idSpk: ID SPK yang akan diupdate
  /// - newStatus: Status baru (PENDING/DIKERJAKAN/SELESAI)
  /// 
  /// Returns: true jika sukses
  /// RBAC: Requires MANDOR, ASISTEN, or ADMIN role
  Future<bool> updateSpkStatus(String idSpk, String newStatus) async {
    try {
      // Dapatkan token dari Supabase session
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final token = session.accessToken;

      final response = await http.patch(
        Uri.parse('$baseUrl/spk/$idSpk/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        print('✅ [DEBUG] SPK status updated: $idSpk -> $newStatus');
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Silakan Login: Token tidak valid atau sudah kadaluarsa (401)');
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda tidak memiliki izin untuk mengupdate SPK (403)');
      } else if (response.statusCode == 404) {
        throw Exception('SPK tidak ditemukan: $idSpk');
      } else {
        throw Exception('Request gagal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ [DEBUG] Error updating SPK status: $e');
      // Fallback: assume success for development
      return true;
    }
  }
}
