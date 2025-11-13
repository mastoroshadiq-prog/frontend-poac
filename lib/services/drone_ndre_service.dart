import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/drone_ndre_tree.dart';

/// Service untuk mengelola data Drone NDRE
/// Endpoint: GET /api/v1/drone/ndre
class DroneNdreService {
  final String baseUrl = AppConfig.apiBaseUrl;

  /// Fetch list pohon dengan NDRE data
  /// 
  /// Query Parameters:
  /// - stressLevel: Filter by stress level ("Stres Berat", "Stres Sedang", "Sehat")
  /// - divisi: Filter by divisi
  /// - blok: Filter by blok
  /// - limit: Limit results (default 100)
  /// - offset: Pagination offset
  /// 
  /// Returns: List of DroneNdreTree
  Future<List<DroneNdreTree>> getDroneNdreTrees({
    String? stressLevel,
    String? divisi,
    String? blok,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      // Dapatkan token dari Supabase session
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final token = session.accessToken;

      // Build query parameters
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (stressLevel != null && stressLevel.isNotEmpty) {
        queryParams['stress_level'] = stressLevel;
      }
      if (divisi != null && divisi.isNotEmpty) {
        queryParams['divisi'] = divisi;
      }
      if (blok != null && blok.isNotEmpty) {
        queryParams['blok'] = blok;
      }

      final url = Uri.parse('$baseUrl/drone/ndre').replace(
        queryParameters: queryParams,
      );

      print('🔍 [DroneNdreService] Fetching from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      ).timeout(AppConfig.requestTimeout);

      print('🔍 [DroneNdreService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> dataList = jsonData['data'] as List<dynamic>;
        
        return dataList
            .map((item) => DroneNdreTree.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token tidak valid. Silakan login kembali.');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak.');
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to dummy data for development
      print('⚠️ [DroneNdreService] Using dummy data: $e');
      return DroneNdreTree.dummyList();
    }
  }

  /// Get count summary by stress level
  Future<Map<String, int>> getStressLevelSummary({
    String? divisi,
    String? blok,
  }) async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('Sesi login tidak ditemukan.');
      }
      final token = session.accessToken;

      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;

      final url = Uri.parse('$baseUrl/drone/ndre/summary').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonData['data'] as Map<String, dynamic>;
        
        return {
          'Stres Berat': data['stres_berat'] as int? ?? 0,
          'Stres Sedang': data['stres_sedang'] as int? ?? 0,
          'Sehat': data['sehat'] as int? ?? 0,
        };
      } else {
        throw Exception('Gagal mengambil summary');
      }
    } catch (e) {
      print('⚠️ [DroneNdreService] Using dummy summary: $e');
      return {
        'Stres Berat': 141,
        'Stres Sedang': 763,
        'Sehat': 6,
      };
    }
  }
}
