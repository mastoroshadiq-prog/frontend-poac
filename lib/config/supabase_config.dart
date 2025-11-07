import 'package:supabase_flutter/supabase_flutter.dart';

/// Konfigurasi Supabase untuk authentication
class SupabaseConfig {
  // TODO: Ganti dengan Supabase Project URL Anda
  static const String supabaseUrl = 'https://wwbibxdhawlrhmvukovs.supabase.co';
  
  // TODO: Ganti dengan Supabase Anon Key Anda
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3YmlieGRoYXdscmhtdnVrb3ZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1MzUyMTYsImV4cCI6MjA3NzExMTIxNn0.qH0hCc7Gdl5lzD6EijBbol0LL-iuBXn9AlJYOscsymk';
  
  /// Initialize Supabase (call this in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // Optional: Enable debug mode untuk development
      debug: true,
    );
  }
  
  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Get current auth instance
  static GoTrueClient get auth => client.auth;
}
