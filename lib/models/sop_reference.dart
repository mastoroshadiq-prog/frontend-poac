/// Model untuk referensi SOP yang digunakan dalam SPK
/// 
/// Source: SAMPLE_RESPONSE_SPK_WITH_SOP.json
/// Digunakan untuk menampilkan badge SOP di UI
class SOPReference {
  final String idSop;
  final String sopCode;
  final String sopVersion;
  final String sopName;

  SOPReference({
    required this.idSop,
    required this.sopCode,
    required this.sopVersion,
    required this.sopName,
  });

  factory SOPReference.fromJson(Map<String, dynamic> json) {
    return SOPReference(
      idSop: json['id_sop'] as String,
      sopCode: json['sop_code'] as String,
      sopVersion: json['sop_version'] as String,
      sopName: json['sop_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sop': idSop,
      'sop_code': sopCode,
      'sop_version': sopVersion,
      'sop_name': sopName,
    };
  }

  /// Display badge: "SOP-VAL-001 v1.0"
  String get badgeText => '$sopCode $sopVersion';

  /// Full display: "SOP-VAL-001 v1.0 - SOP Validasi Lapangan Ground Truth v1.0"
  String get fullDisplayName => '$badgeText - $sopName';
}
