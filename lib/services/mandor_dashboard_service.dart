import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../config/supabase_config.dart';

class MandorDashboardService {
  final Dio _dio;
  final SupabaseClient _supabase = SupabaseConfig.client;

  MandorDashboardService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = _supabase.auth.currentSession?.accessToken;
      
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final response = await _dio.get(
        '/mandor/dashboard',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Gagal memuat dashboard: ${response.data['message'] ?? 'Unknown error'}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi anda telah berakhir. Silakan login ulang.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Anda tidak memiliki akses ke dashboard mandor.');
      }
      throw Exception('Error koneksi: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
