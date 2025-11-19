import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../config/supabase_config.dart';

class ProfileService {
  final Dio _dio;
  final SupabaseClient _supabase = SupabaseConfig.client;

  ProfileService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = _supabase.auth.currentSession?.accessToken;
      
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final response = await _dio.get(
        '/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['user'] as Map<String, dynamic>;
      }

      throw Exception('Gagal mendapatkan profile: ${response.data['message'] ?? 'Unknown error'}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi anda telah berakhir. Silakan login ulang.');
      }
      throw Exception('Error koneksi: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
