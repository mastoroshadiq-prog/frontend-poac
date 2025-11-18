/// Model untuk lokasi pohon yang divalidasi
/// 
/// Digunakan sebagai shortcut untuk menampilkan lokasi pohon
/// tanpa perlu parsing dari target_json yang kompleks
/// 
/// Source: QUICK_REFERENCE_SOP.md - New Fields Summary
class TreeLocation {
  final String divisi;
  final String blok;
  final String? blokDetail;
  final int nBaris;
  final int nPokok;

  TreeLocation({
    required this.divisi,
    required this.blok,
    this.blokDetail,
    required this.nBaris,
    required this.nPokok,
  });

  factory TreeLocation.fromJson(Map<String, dynamic> json) {
    return TreeLocation(
      divisi: json['divisi'] as String,
      blok: json['blok'] as String,
      blokDetail: json['blok_detail'] as String?,
      nBaris: json['n_baris'] as int,
      nPokok: json['n_pokok'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'divisi': divisi,
      'blok': blok,
      'blok_detail': blokDetail,
      'n_baris': nBaris,
      'n_pokok': nPokok,
    };
  }

  /// Display format: "Blok D001A, Baris 1, Pokok 5"
  /// Sesuai dengan UI Recommendations dari QUICK_REFERENCE_SOP.md
  String get displayName {
    final blokText = blokDetail ?? blok;
    return 'Blok $blokText, Baris $nBaris, Pokok $nPokok';
  }

  /// Display format lengkap dengan divisi: "AME II - Blok D001A, Baris 1, Pokok 5"
  String get fullDisplayName {
    return '$divisi - $displayName';
  }

  /// Tree ID format: "P-D001A-01-01"
  String get treeId {
    final blokText = blokDetail ?? blok;
    return 'P-$blokText-${nBaris.toString().padLeft(2, '0')}-${nPokok.toString().padLeft(2, '0')}';
  }
}
