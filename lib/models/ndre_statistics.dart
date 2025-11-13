import 'package:flutter/material.dart';

/// Model untuk statistik distribusi NDRE
/// 
/// Digunakan untuk menampilkan pie chart dan bar chart
/// distribusi pohon berdasarkan kategori stress (Berat, Sedang, Sehat)
class NdreStatistics {
  final int totalPohon;
  final int stresBerat;
  final int stresSedang;
  final int sehat;
  final double persentaseStresBerat;
  final double persentaseStresSedang;
  final double persentaseSehat;
  final double averageNdre;
  final double minNdre;
  final double maxNdre;
  final String? divisi;
  final String? blok;
  final DateTime timestamp;

  NdreStatistics({
    required this.totalPohon,
    required this.stresBerat,
    required this.stresSedang,
    required this.sehat,
    required this.persentaseStresBerat,
    required this.persentaseStresSedang,
    required this.persentaseSehat,
    required this.averageNdre,
    required this.minNdre,
    required this.maxNdre,
    this.divisi,
    this.blok,
    required this.timestamp,
  });

  /// Factory constructor dari JSON response API
  factory NdreStatistics.fromJson(Map<String, dynamic> json) {
    final total = json['total_pohon'] as int;
    final stresBerat = json['stres_berat'] as int;
    final stresSedang = json['stres_sedang'] as int;
    final sehat = json['sehat'] as int;

    return NdreStatistics(
      totalPohon: total,
      stresBerat: stresBerat,
      stresSedang: stresSedang,
      sehat: sehat,
      persentaseStresBerat: total > 0 ? (stresBerat / total) * 100 : 0,
      persentaseStresSedang: total > 0 ? (stresSedang / total) * 100 : 0,
      persentaseSehat: total > 0 ? (sehat / total) * 100 : 0,
      averageNdre: (json['average_ndre'] as num?)?.toDouble() ?? 0.0,
      minNdre: (json['min_ndre'] as num?)?.toDouble() ?? 0.0,
      maxNdre: (json['max_ndre'] as num?)?.toDouble() ?? 1.0,
      divisi: json['divisi'] as String?,
      blok: json['blok'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Convert ke JSON untuk API request
  Map<String, dynamic> toJson() {
    return {
      'total_pohon': totalPohon,
      'stres_berat': stresBerat,
      'stres_sedang': stresSedang,
      'sehat': sehat,
      'persentase_stres_berat': persentaseStresBerat,
      'persentase_stres_sedang': persentaseStresSedang,
      'persentase_sehat': persentaseSehat,
      'average_ndre': averageNdre,
      'min_ndre': minNdre,
      'max_ndre': maxNdre,
      if (divisi != null) 'divisi': divisi,
      if (blok != null) 'blok': blok,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Helper method: Kategori dominan
  String get dominantCategory {
    if (stresBerat >= stresSedang && stresBerat >= sehat) {
      return 'Stres Berat';
    } else if (stresSedang >= stresBerat && stresSedang >= sehat) {
      return 'Stres Sedang';
    } else {
      return 'Sehat';
    }
  }

  /// Helper method: Warna kategori dominan
  Color get dominantCategoryColor {
    if (stresBerat >= stresSedang && stresBerat >= sehat) {
      return Colors.red[600]!;
    } else if (stresSedang >= stresBerat && stresSedang >= sehat) {
      return Colors.orange[600]!;
    } else {
      return Colors.green[600]!;
    }
  }

  /// Helper method: Apakah kondisi kritis (>50% stres berat)
  bool get isKritisKondisi {
    return persentaseStresBerat > 50.0;
  }

  /// Helper method: Apakah kondisi perlu perhatian (>30% stres berat OR >70% stres sedang)
  bool get perluPerhatian {
    return persentaseStresBerat > 30.0 || persentaseStresSedang > 70.0;
  }

  /// Helper method: Status kesehatan overall
  String get statusKesehatan {
    if (isKritisKondisi) {
      return 'KRITIS';
    } else if (perluPerhatian) {
      return 'PERLU PERHATIAN';
    } else if (persentaseSehat > 50.0) {
      return 'BAIK';
    } else {
      return 'SEDANG';
    }
  }

  /// Helper method: Warna status kesehatan
  Color get statusKesehatanColor {
    if (isKritisKondisi) {
      return Colors.red[700]!;
    } else if (perluPerhatian) {
      return Colors.orange[700]!;
    } else if (persentaseSehat > 50.0) {
      return Colors.green[700]!;
    } else {
      return Colors.blue[700]!;
    }
  }

  /// Helper method: Rekomendasi tindakan
  String get rekomendasi {
    if (isKritisKondisi) {
      return 'Segera lakukan inspeksi lapangan dan buat SPK Validasi untuk semua area stres berat';
    } else if (perluPerhatian) {
      return 'Monitor area stres sedang dan tingkatkan frekuensi pengambilan drone imagery';
    } else if (persentaseSehat > 50.0) {
      return 'Kondisi baik, lanjutkan monitoring rutin';
    } else {
      return 'Lakukan monitoring berkala dan catat perubahan NDRE';
    }
  }

  /// Factory constructor untuk dummy data (development)
  factory NdreStatistics.dummy() {
    return NdreStatistics(
      totalPohon: 910,
      stresBerat: 141,
      stresSedang: 763,
      sehat: 6,
      persentaseStresBerat: 15.49,
      persentaseStresSedang: 83.85,
      persentaseSehat: 0.66,
      averageNdre: 0.289,
      minNdre: 0.12,
      maxNdre: 0.68,
      divisi: 'Divisi 1',
      blok: 'B12A',
      timestamp: DateTime.now(),
    );
  }

  /// Copy with method untuk immutability
  NdreStatistics copyWith({
    int? totalPohon,
    int? stresBerat,
    int? stresSedang,
    int? sehat,
    double? persentaseStresBerat,
    double? persentaseStresSedang,
    double? persentaseSehat,
    double? averageNdre,
    double? minNdre,
    double? maxNdre,
    String? divisi,
    String? blok,
    DateTime? timestamp,
  }) {
    return NdreStatistics(
      totalPohon: totalPohon ?? this.totalPohon,
      stresBerat: stresBerat ?? this.stresBerat,
      stresSedang: stresSedang ?? this.stresSedang,
      sehat: sehat ?? this.sehat,
      persentaseStresBerat: persentaseStresBerat ?? this.persentaseStresBerat,
      persentaseStresSedang: persentaseStresSedang ?? this.persentaseStresSedang,
      persentaseSehat: persentaseSehat ?? this.persentaseSehat,
      averageNdre: averageNdre ?? this.averageNdre,
      minNdre: minNdre ?? this.minNdre,
      maxNdre: maxNdre ?? this.maxNdre,
      divisi: divisi ?? this.divisi,
      blok: blok ?? this.blok,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'NdreStatistics(total: $totalPohon, stresBerat: $stresBerat ($persentaseStresBerat%), '
        'stresSedang: $stresSedang ($persentaseStresSedang%), sehat: $sehat ($persentaseSehat%), '
        'avgNdre: $averageNdre, status: $statusKesehatan)';
  }
}
