/// Configuration constants untuk aplikasi
class Config {
  // API Base URL
  static const String apiBaseUrl = 'http://localhost:3000';
  
  // Supabase Configuration (already configured in main.dart)
  // static const String supabaseUrl = '...';
  // static const String supabaseAnonKey = '...';
  
  // App Configuration
  static const String appName = 'KEBOEN POAC';
  static const String appVersion = '1.0.0';
  
  // NDRE Thresholds (default values)
  static const double ndreThresholdStresBerat = 0.30;
  static const double ndreThresholdStresSedang = 0.50;
  
  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration apiConnectTimeout = Duration(seconds: 15);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(minutes: 30);
  static const Duration cacheLongDuration = Duration(hours: 24);
}
