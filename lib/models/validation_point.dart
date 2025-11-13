/// Model untuk validation point (Field vs Drone analysis)
/// Digunakan untuk scatter plot dan distribution analysis
class ValidationPoint {
  final String idNpokok;
  final String treeId;
  final double ndreValue; // Drone NDRE value (0-1)
  final int fieldScore; // Field stress score (0-10)
  final String dronePrediction; // "Stres Berat", "Stres Sedang", "Sehat"
  final String fieldActual; // "Stres Berat", "Normal", "Sehat"
  final String category; // "True Positive", "False Positive", etc
  final String? surveyor;
  final DateTime? validationDate;
  final GpsLocation? gps;
  final String? photoUrl;
  final String? divisi;
  final String? afdeling;
  final String? blok;
  final int? row;
  final int? position;
  final String? cause; // For false positives: "Bayangan awan", "Embun", etc

  ValidationPoint({
    required this.idNpokok,
    required this.treeId,
    required this.ndreValue,
    required this.fieldScore,
    required this.dronePrediction,
    required this.fieldActual,
    required this.category,
    this.surveyor,
    this.validationDate,
    this.gps,
    this.photoUrl,
    this.divisi,
    this.afdeling,
    this.blok,
    this.row,
    this.position,
    this.cause,
  });

  factory ValidationPoint.fromJson(Map<String, dynamic> json) {
    return ValidationPoint(
      idNpokok: json['id_npokok'] as String? ?? '',
      treeId: json['tree_id'] as String? ?? '',
      ndreValue: (json['ndre_value'] as num?)?.toDouble() ?? 0.0,
      fieldScore: (json['field_score'] as num?)?.toInt() ?? 0,
      dronePrediction: json['drone_prediction'] as String? ?? 'Unknown',
      fieldActual: json['field_actual'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'UNKNOWN',
      surveyor: json['surveyor'] as String?,
      validationDate: json['validation_date'] != null
          ? DateTime.parse(json['validation_date'])
          : null,
      gps: json['gps'] != null
          ? GpsLocation.fromJson((json['gps'] as Map<String, dynamic>?) ?? {})
          : null,
      photoUrl: json['photo_url'] as String?,
      divisi: json['divisi'] as String?,
      afdeling: json['afdeling'] as String?,
      blok: json['blok'] as String?,
      row: json['row'] as int?,
      position: json['position'] as int?,
      cause: json['cause'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_npokok': idNpokok,
      'tree_id': treeId,
      'ndre_value': ndreValue,
      'field_score': fieldScore,
      'drone_prediction': dronePrediction,
      'field_actual': fieldActual,
      'category': category,
      'surveyor': surveyor,
      'validation_date': validationDate?.toIso8601String(),
      'gps': gps?.toJson(),
      'photo_url': photoUrl,
      'divisi': divisi,
      'afdeling': afdeling,
      'blok': blok,
      'row': row,
      'position': position,
      'cause': cause,
    };
  }

  /// Check if this is a mismatch (FP or FN)
  bool get isMismatch =>
      category == 'False Positive' || category == 'False Negative';

  /// Get color for category
  String get categoryColor {
    switch (category) {
      case 'True Positive':
        return 'green';
      case 'False Positive':
        return 'red';
      case 'True Negative':
        return 'blue';
      case 'False Negative':
        return 'orange';
      default:
        return 'grey';
    }
  }
}

/// GPS Location model
class GpsLocation {
  final double latitude;
  final double longitude;

  GpsLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GpsLocation.fromJson(Map<String, dynamic> json) {
    return GpsLocation(
      latitude: (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
    };
  }
}

/// Field vs Drone distribution data
class FieldVsDroneData {
  final List<ValidationDistribution> distribution;
  final List<String> recommendations;
  final int totalTrees;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;

  FieldVsDroneData({
    required this.distribution,
    required this.recommendations,
    required this.totalTrees,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
  });

  factory FieldVsDroneData.fromJson(Map<String, dynamic> json) {
    // Defensive: check if distribution is actually a List
    final distributionData = json['distribution'];
    final List<ValidationDistribution> parsedDistribution;
    if (distributionData is List) {
      parsedDistribution = distributionData
          .map((e) => ValidationDistribution.fromJson((e as Map<String, dynamic>?) ?? {}))
          .toList();
    } else {
      parsedDistribution = [];
    }

    // Defensive: check if recommendations is actually a List
    final recommendationsData = json['recommendations'];
    final List<String> parsedRecommendations;
    if (recommendationsData is List) {
      parsedRecommendations = recommendationsData
          .map((e) => e.toString())
          .toList();
    } else {
      parsedRecommendations = [];
    }

    return FieldVsDroneData(
      distribution: parsedDistribution,
      recommendations: parsedRecommendations,
      totalTrees: (json['total_trees'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      precision: (json['precision'] as num?)?.toDouble() ?? 0.0,
      recall: (json['recall'] as num?)?.toDouble() ?? 0.0,
      f1Score: (json['f1_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Helper: Get all validation points from all distribution categories
  List<ValidationPoint> get points {
    final List<ValidationPoint> allPoints = [];
    for (final dist in distribution) {
      allPoints.addAll(dist.trees);
    }
    return allPoints;
  }

  /// Helper: Get total point count
  int get totalPoints => points.length;

  /// Helper: Get all common causes from False Positive and False Negative categories
  List<CommonCause> get commonCauses {
    final List<CommonCause> causes = [];
    for (final dist in distribution) {
      if (dist.commonCauses != null &&
          (dist.category == 'FP' || dist.category == 'FN')) {
        causes.addAll(dist.commonCauses!);
      }
    }
    return causes;
  }

  /// Helper: Get distribution analysis text
  String get distributionAnalysis {
    final tpDist = distribution.where((d) => d.category == 'TP').firstOrNull;
    final fpDist = distribution.where((d) => d.category == 'FP').firstOrNull;
    final tnDist = distribution.where((d) => d.category == 'TN').firstOrNull;
    final fnDist = distribution.where((d) => d.category == 'FN').firstOrNull;

    final tpCount = tpDist?.count ?? 0;
    final fpCount = fpDist?.count ?? 0;
    final tnCount = tnDist?.count ?? 0;
    final fnCount = fnDist?.count ?? 0;

    if (accuracy >= 90) {
      return 'Validasi sangat baik dengan akurasi ${accuracy.toStringAsFixed(1)}%. '
          'Drone mampu mengidentifikasi stres dengan akurat ($tpCount TP, $tnCount TN). '
          'Hanya ${fpCount + fnCount} kasus mismatch yang perlu perhatian.';
    } else if (accuracy >= 75) {
      return 'Validasi cukup baik dengan akurasi ${accuracy.toStringAsFixed(1)}%. '
          'Terdapat ${fpCount + fnCount} kasus mismatch ($fpCount FP, $fnCount FN) '
          'yang perlu diselidiki lebih lanjut.';
    } else {
      return 'Akurasi rendah (${accuracy.toStringAsFixed(1)}%). '
          'Drone menghasilkan ${fpCount + fnCount} prediksi salah dari $totalTrees pohon. '
          'Perlu kalibrasi threshold NDRE dan review metodologi.';
    }
  }
}

/// Validation distribution category
class ValidationDistribution {
  final String dronePrediction;
  final String fieldActual;
  final int count;
  final double percentage;
  final String category;
  final double avgNdre;
  final List<ValidationPoint> trees;
  final List<CommonCause>? commonCauses;

  ValidationDistribution({
    required this.dronePrediction,
    required this.fieldActual,
    required this.count,
    required this.percentage,
    required this.category,
    required this.avgNdre,
    required this.trees,
    this.commonCauses,
  });

  factory ValidationDistribution.fromJson(Map<String, dynamic> json) {
    // Handle 'trees' field: backend returns integer (count), frontend expects List
    final treesData = json['trees'];
    final List<ValidationPoint> parsedTrees;
    final int treeCount;
    
    if (treesData is int) {
      // Backend returns count only (e.g., "trees": 118)
      parsedTrees = [];
      treeCount = treesData;
    } else if (treesData is List) {
      // Backend returns array of tree objects
      parsedTrees = treesData
          .map((e) => ValidationPoint.fromJson((e as Map<String, dynamic>?) ?? {}))
          .toList();
      treeCount = parsedTrees.length;
    } else {
      parsedTrees = [];
      treeCount = 0;
    }

    return ValidationDistribution(
      dronePrediction: json['drone_prediction'] as String? ?? 'Unknown',
      fieldActual: json['field_actual'] as String? ?? json['field_validation'] as String? ?? 'Unknown',
      count: (json['count'] as num?)?.toInt() ?? treeCount,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'UNKNOWN',
      avgNdre: (json['avg_ndre'] as num?)?.toDouble() ?? 0.0,
      trees: parsedTrees,
      commonCauses: json['common_causes'] != null
          ? _parseCommonCauses(json['common_causes'])
          : null,
    );
  }

  /// Parse common_causes - backend may return array of strings OR array of objects
  static List<CommonCause>? _parseCommonCauses(dynamic data) {
    if (data == null) return null;
    if (data is! List) return null;
    
    final List<CommonCause> causes = [];
    for (final item in data) {
      if (item is String) {
        // Backend returns string only (e.g., "Ganoderma confirmed")
        causes.add(CommonCause(
          cause: item,
          count: 0,
          percentage: 0.0,
        ));
      } else if (item is Map) {
        // Backend returns full object
        causes.add(CommonCause.fromJson((item as Map<String, dynamic>?) ?? {}));
      }
    }
    return causes.isEmpty ? null : causes;
  }
}

/// Common cause for false positives/negatives
class CommonCause {
  final String cause;
  final int count;
  final double percentage;

  CommonCause({
    required this.cause,
    required this.count,
    required this.percentage,
  });

  factory CommonCause.fromJson(Map<String, dynamic> json) {
    return CommonCause(
      cause: json['cause'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
