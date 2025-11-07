/// Model untuk menyimpan sesi user yang sedang login
class UserSession {
  final String token;
  final String idPihak;
  final String namaPihak;
  final String role;

  UserSession({
    required this.token,
    required this.idPihak,
    required this.namaPihak,
    required this.role,
  });

  /// Create from JSON (dari auth service)
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      token: json['token'] as String,
      idPihak: json['id_pihak'] as String,
      namaPihak: json['nama_pihak'] as String,
      role: json['role'] as String,
    );
  }

  /// Convert to JSON (untuk storage)
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id_pihak': idPihak,
      'nama_pihak': namaPihak,
      'role': role,
    };
  }

  /// Get role display name
  String getRoleDisplayName() {
    switch (role) {
      case 'ADMIN':
        return 'Administrator';
      case 'MANAJER':
        return 'Manajer';
      case 'ASISTEN':
        return 'Asisten';
      case 'MANDOR':
        return 'Mandor';
      case 'PELAKSANA':
        return 'Pelaksana';
      default:
        return role;
    }
  }

  /// Get role color
  String getRoleColor() {
    switch (role) {
      case 'ADMIN':
        return '#F44336'; // Red
      case 'MANAJER':
        return '#9C27B0'; // Purple
      case 'ASISTEN':
        return '#2196F3'; // Blue
      case 'MANDOR':
        return '#4CAF50'; // Green
      case 'PELAKSANA':
        return '#FF9800'; // Orange
      default:
        return '#757575'; // Grey
    }
  }
}
