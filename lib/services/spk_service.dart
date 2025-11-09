import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/supabase_config.dart';

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
}
