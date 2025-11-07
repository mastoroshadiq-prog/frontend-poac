import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../config/supabase_config.dart';

/// Service untuk mengelola autentikasi pengguna
/// Menggunakan Supabase Auth (RBAC FASE 3 - Revised)
class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Login pengguna dengan email dan password menggunakan Supabase Auth
  /// 
  /// Mengirim request ke Supabase Auth untuk authentication
  /// Return Map berisi: token, role, nama_pihak, id_pihak, email
  /// 
  /// Throws Exception jika login gagal
  Future<Map<String, dynamic>> loginWithSupabase(String email, String password) async {
    try {
      // Login dengan Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw Exception('Login gagal: User atau session tidak valid');
      }

      final user = response.user!;
      final session = response.session!;

      // Extract user metadata (role, id_pihak, nama_pihak)
      final userMetadata = user.userMetadata ?? {};
      final role = userMetadata['role'] ?? 'VIEWER';
      final idPihak = userMetadata['id_pihak'] ?? user.id;
      final namaPihak = userMetadata['nama_pihak'] ?? user.email ?? 'User';

      return {
        'token': session.accessToken,
        'id_pihak': idPihak,
        'nama_pihak': namaPihak,
        'role': role,
        'email': user.email ?? '',
        'user_id': user.id,
        'expires_at': session.expiresAt?.toString() ?? '',
      };
    } on AuthException catch (e) {
      // Supabase Auth specific errors
      if (e.statusCode == '400' || e.message.contains('Invalid login')) {
        throw Exception('Login Gagal: Email atau password salah');
      }
      throw Exception('Login Gagal: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get current user session from Supabase
  Future<Map<String, dynamic>?> getCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;
      
      if (session == null) {
        return null;
      }

      final user = session.user;
      final userMetadata = user.userMetadata ?? {};

      return {
        'token': session.accessToken,
        'id_pihak': userMetadata['id_pihak'] ?? user.id,
        'nama_pihak': userMetadata['nama_pihak'] ?? user.email ?? 'User',
        'role': userMetadata['role'] ?? 'VIEWER',
        'email': user.email ?? '',
        'user_id': user.id,
      };
    } catch (e) {
      return null;
    }
  }

  /// Logout user from Supabase
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Refresh current session
  Future<String?> refreshToken() async {
    try {
      final response = await _supabase.auth.refreshSession();
      return response.session?.accessToken;
    } catch (e) {
      return null;
    }
  }

  /// Validasi apakah role memiliki akses ke dashboard tertentu
  /// 
  /// Dashboard Types (SESUAI BACKEND RBAC):
  /// - 'eksekutif': ASISTEN, ADMIN (BUKAN MANAJER!)
  /// - 'operasional': MANDOR, ASISTEN, ADMIN
  /// - 'teknis': MANDOR, ASISTEN, ADMIN
  bool hasAccess(String role, String dashboardType) {
    switch (dashboardType.toLowerCase()) {
      case 'eksekutif':
        // Sesuai backend: authorizeRole(['ASISTEN', 'ADMIN'])
        return ['ASISTEN', 'ADMIN'].contains(role);
      case 'operasional':
        // Sesuai backend: authorizeRole(['MANDOR', 'ASISTEN', 'ADMIN'])
        return ['MANDOR', 'ASISTEN', 'ADMIN'].contains(role);
      case 'teknis':
        // Sesuai backend: authorizeRole(['MANDOR', 'ASISTEN', 'ADMIN'])
        return ['MANDOR', 'ASISTEN', 'ADMIN'].contains(role);
      default:
        return false;
    }
  }

  /// Get daftar dashboard yang dapat diakses berdasarkan role
  List<String> getAccessibleDashboards(String role) {
    final accessible = <String>[];
    
    if (hasAccess(role, 'eksekutif')) {
      accessible.add('eksekutif');
    }
    if (hasAccess(role, 'operasional')) {
      accessible.add('operasional');
    }
    if (hasAccess(role, 'teknis')) {
      accessible.add('teknis');
    }
    
    return accessible;
  }
}
