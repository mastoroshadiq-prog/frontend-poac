/// Configuration constants untuk aplikasi
/// Sesuai Prinsip MPP: SIMPLE - Sentralisasi konfigurasi
class AppConfig {
  // Backend API Base URL
  // TODO: Ganti dengan URL production saat deployment
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';
  
  // Timeout untuk HTTP requests
  static const Duration requestTimeout = Duration(seconds: 10);
  
  // App Information
  static const String appName = 'Dashboard POAC - Keboen';
  static const String appVersion = '1.0.0';
}
