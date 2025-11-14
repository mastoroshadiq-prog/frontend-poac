/// Model untuk data pohon dari hasil scan drone NDRE
/// 
/// Digunakan untuk:
/// - Menampilkan list pohon dengan NDRE value
/// - Selection pohon untuk create SPK
/// - Filter berdasarkan stress level
class DroneNdreTree {
  final String idNpokok;
  final String? nomorPohon;
  final double ndreValue;
  final String stressLevel; // "Stres Berat", "Stres Sedang", "Sehat"
  final String? blok;
  final String? blokDetail;
  final String? divisi;
  final int? nBaris;
  final int? nPokok;
  final DateTime? tanggalScan;
  final double? latitude;
  final double? longitude;
  final double? confidence;

  DroneNdreTree({
    required this.idNpokok,
    this.nomorPohon,
    required this.ndreValue,
    required this.stressLevel,
    this.blok,
    this.blokDetail,
    this.divisi,
    this.nBaris,
    this.nPokok,
    this.tanggalScan,
    this.latitude,
    this.longitude,
    this.confidence,
  });

  factory DroneNdreTree.fromJson(Map<String, dynamic> json) {
    return DroneNdreTree(
      idNpokok: json['id_npokok'] as String,
      nomorPohon: json['nomor_pohon'] as String?,
      ndreValue: (json['ndre_value'] as num).toDouble(),
      stressLevel: json['stress_level'] as String,
      blok: json['blok'] as String?,
      blokDetail: json['blok_detail'] as String?,
      divisi: json['divisi'] as String?,
      nBaris: json['n_baris'] as int?,
      nPokok: json['n_pokok'] as int?,
      tanggalScan: json['tanggal_scan'] != null
          ? DateTime.parse(json['tanggal_scan'] as String)
          : null,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_npokok': idNpokok,
      'nomor_pohon': nomorPohon,
      'ndre_value': ndreValue,
      'stress_level': stressLevel,
      'blok': blok,
      'blok_detail': blokDetail,
      'divisi': divisi,
      'n_baris': nBaris,
      'n_pokok': nPokok,
      'tanggal_scan': tanggalScan?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'confidence': confidence,
    };
  }

  /// Get tree location display name
  /// Format: "Blok D001A, Baris 1, Pokok 5"
  String get locationDisplayName {
    if (nBaris == null || nPokok == null) return 'Lokasi tidak tersedia';
    final blokText = blokDetail ?? blok ?? 'N/A';
    return 'Blok $blokText, Baris $nBaris, Pokok $nPokok';
  }

  /// Get full location with divisi
  /// Format: "AME II - Blok D001A, Baris 1, Pokok 5"
  String get fullLocationDisplayName {
    if (divisi == null) return locationDisplayName;
    return '$divisi - $locationDisplayName';
  }

  /// Generate dummy data untuk development/testing
  static List<DroneNdreTree> dummyList() {
    return [
      DroneNdreTree(
        idNpokok: 'a0b1c2d3-e4f5-6789-0abc-def123456789',
        nomorPohon: 'T-001',
        ndreValue: 0.25,
        stressLevel: 'Stres Berat',
        blok: 'D01',
        blokDetail: 'D001A',
        divisi: 'AME II',
        nBaris: 1,
        nPokok: 1,
        tanggalScan: DateTime.now().subtract(const Duration(days: 1)),
        confidence: 92.5,
      ),
      DroneNdreTree(
        idNpokok: 'b1c2d3e4-f5a6-7890-bcde-f01234567890',
        nomorPohon: 'T-002',
        ndreValue: 0.32,
        stressLevel: 'Stres Berat',
        blok: 'D01',
        blokDetail: 'D001B',
        divisi: 'AME II',
        nBaris: 1,
        nPokok: 2,
        tanggalScan: DateTime.now().subtract(const Duration(days: 1)),
        confidence: 88.3,
      ),
      DroneNdreTree(
        idNpokok: 'c2d3e4f5-a6b7-8901-cdef-012345678901',
        nomorPohon: 'T-003',
        ndreValue: 0.48,
        stressLevel: 'Stres Sedang',
        blok: 'D02',
        blokDetail: 'D002A',
        divisi: 'AME II',
        nBaris: 2,
        nPokok: 3,
        tanggalScan: DateTime.now().subtract(const Duration(days: 1)),
        confidence: 85.7,
      ),
      DroneNdreTree(
        idNpokok: 'd3e4f5a6-b7c8-9012-def0-123456789012',
        nomorPohon: 'T-004',
        ndreValue: 0.42,
        stressLevel: 'Stres Sedang',
        blok: 'D01',
        blokDetail: 'D001A',
        divisi: 'AME I',
        nBaris: 3,
        nPokok: 2,
        tanggalScan: DateTime.now().subtract(const Duration(days: 2)),
        confidence: 90.1,
      ),
      DroneNdreTree(
        idNpokok: 'e4f5a6b7-c8d9-0123-ef01-234567890123',
        nomorPohon: 'T-005',
        ndreValue: 0.68,
        stressLevel: 'Sehat',
        blok: 'D03',
        blokDetail: 'D003A',
        divisi: 'AME I',
        nBaris: 1,
        nPokok: 5,
        tanggalScan: DateTime.now().subtract(const Duration(days: 2)),
        confidence: 94.2,
      ),
      DroneNdreTree(
        idNpokok: 'f5a6b7c8-d9e0-1234-f012-345678901234',
        nomorPohon: 'T-006',
        ndreValue: 0.28,
        stressLevel: 'Stres Berat',
        blok: 'D01',
        blokDetail: 'D001B',
        divisi: 'AME II',
        nBaris: 2,
        nPokok: 1,
        tanggalScan: DateTime.now().subtract(const Duration(days: 3)),
        confidence: 91.8,
      ),
      DroneNdreTree(
        idNpokok: 'a6b7c8d9-e0f1-2345-0123-456789012345',
        nomorPohon: 'T-007',
        ndreValue: 0.51,
        stressLevel: 'Stres Sedang',
        blok: 'D02',
        blokDetail: 'D002B',
        divisi: 'AME III',
        nBaris: 4,
        nPokok: 2,
        tanggalScan: DateTime.now().subtract(const Duration(days: 3)),
        confidence: 87.4,
      ),
      DroneNdreTree(
        idNpokok: 'b7c8d9e0-f1a2-3456-1234-567890123456',
        nomorPohon: 'T-008',
        ndreValue: 0.35,
        stressLevel: 'Stres Berat',
        blok: 'D01',
        blokDetail: 'D001A',
        divisi: 'AME I',
        nBaris: 5,
        nPokok: 1,
        tanggalScan: DateTime.now().subtract(const Duration(days: 4)),
        confidence: 89.6,
      ),
    ];
  }
}
