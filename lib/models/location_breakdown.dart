/// Model untuk breakdown lokasi per blok dalam SPK summary
/// 
/// Source: SAMPLE_RESPONSE_SPK_WITH_SOP_v2.json - summary.locations[]
/// Digunakan untuk menampilkan grouping pohon per blok
class LocationBreakdown {
  final String divisi;
  final String blok;
  final String blokDetail;
  final int treeCount;
  final List<TreeReference> trees;

  LocationBreakdown({
    required this.divisi,
    required this.blok,
    required this.blokDetail,
    required this.treeCount,
    required this.trees,
  });

  factory LocationBreakdown.fromJson(Map<String, dynamic> json) {
    return LocationBreakdown(
      divisi: json['divisi'] as String,
      blok: json['blok'] as String,
      blokDetail: json['blok_detail'] as String,
      treeCount: json['tree_count'] as int,
      trees: (json['trees'] as List)
          .map((t) => TreeReference.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'divisi': divisi,
      'blok': blok,
      'blok_detail': blokDetail,
      'tree_count': treeCount,
      'trees': trees.map((t) => t.toJson()).toList(),
    };
  }

  /// Display format: "AME II - Blok D001A (2 pohon)"
  String get displayName => '$divisi - Blok $blokDetail ($treeCount pohon)';
}

/// Reference ke pohon individu dalam location breakdown
class TreeReference {
  final int nBaris;
  final int nPokok;
  final String idTugas;

  TreeReference({
    required this.nBaris,
    required this.nPokok,
    required this.idTugas,
  });

  factory TreeReference.fromJson(Map<String, dynamic> json) {
    return TreeReference(
      nBaris: json['n_baris'] as int,
      nPokok: json['n_pokok'] as int,
      idTugas: json['id_tugas'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'n_baris': nBaris,
      'n_pokok': nPokok,
      'id_tugas': idTugas,
    };
  }

  /// Display format: "B1-P5"
  String get shortName => 'B$nBaris-P$nPokok';
  
  /// Display format: "Baris 1, Pokok 5"
  String get displayName => 'Baris $nBaris, Pokok $nPokok';
}
