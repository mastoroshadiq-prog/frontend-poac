/// Model untuk Confusion Matrix data dari validation API
/// Digunakan untuk analisis akurasi drone prediction vs field validation
class ConfusionMatrixData {
  final int truePositive; // Drone: stres, Field: stres ✅
  final int falsePositive; // Drone: stres, Field: sehat ❌
  final int trueNegative; // Drone: sehat, Field: sehat ✅
  final int falseNegative; // Drone: sehat, Field: stres ❌
  final double accuracy; // (TP+TN) / Total
  final double precision; // TP / (TP+FP)
  final double recall; // TP / (TP+FN)
  final double f1Score; // 2 × (P×R)/(P+R)
  final double fpr; // False positive rate: FP / (FP+TN)
  final double fnr; // False negative rate: FN / (TP+FN)
  final List<String> recommendations;
  final List<DivisiAccuracy>? perDivisi;
  final DateTime? validationDateStart;
  final DateTime? validationDateEnd;
  final int totalValidated;

  ConfusionMatrixData({
    required this.truePositive,
    required this.falsePositive,
    required this.trueNegative,
    required this.falseNegative,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.fpr,
    required this.fnr,
    required this.recommendations,
    this.perDivisi,
    this.validationDateStart,
    this.validationDateEnd,
    required this.totalValidated,
  });

  factory ConfusionMatrixData.fromJson(Map<String, dynamic> json) {
    final matrixData = (json['matrix'] as Map<String, dynamic>?) ?? {};
    final metricsData = (json['metrics'] as Map<String, dynamic>?) ?? {};
    final summaryData = json['summary'] as Map<String, dynamic>?;

    return ConfusionMatrixData(
      truePositive: (matrixData['true_positive'] as num?)?.toInt() ?? 0,
      falsePositive: (matrixData['false_positive'] as num?)?.toInt() ?? 0,
      trueNegative: (matrixData['true_negative'] as num?)?.toInt() ?? 0,
      falseNegative: (matrixData['false_negative'] as num?)?.toInt() ?? 0,
      accuracy: (metricsData['accuracy'] as num?)?.toDouble() ?? 0.0,
      precision: (metricsData['precision'] as num?)?.toDouble() ?? 0.0,
      recall: (metricsData['recall'] as num?)?.toDouble() ?? 0.0,
      f1Score: (metricsData['f1_score'] as num?)?.toDouble() ?? 0.0,
      fpr: (metricsData['fpr'] as num?)?.toDouble() ?? 0.0,
      fnr: (metricsData['fnr'] as num?)?.toDouble() ?? 0.0,
      recommendations: _parseRecommendations(json['recommendations']),
      perDivisi: json['per_divisi'] != null
          ? ((json['per_divisi'] as List<dynamic>?) ?? [])
              .map((e) => DivisiAccuracy.fromJson((e as Map<String, dynamic>?) ?? {}))
              .toList()
          : null,
      validationDateStart: summaryData?['validation_date_range']?['start'] != null
          ? DateTime.parse(summaryData!['validation_date_range']['start'])
          : null,
      validationDateEnd: summaryData?['validation_date_range']?['end'] != null
          ? DateTime.parse(summaryData!['validation_date_range']['end'])
          : null,
      totalValidated: summaryData?['total_validated'] as int? ?? 0,
    );
  }

  /// Parse recommendations - backend may return array of strings OR array of objects
  static List<String> _parseRecommendations(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    
    final List<String> recommendations = [];
    for (final item in data) {
      if (item is String) {
        // Backend returns string directly
        recommendations.add(item);
      } else if (item is Map) {
        // Backend returns object with message field
        final message = item['message'] as String?;
        if (message != null && message.isNotEmpty) {
          recommendations.add(message);
        }
      }
    }
    return recommendations;
  }

  Map<String, dynamic> toJson() {
    return {
      'matrix': {
        'true_positive': truePositive,
        'false_positive': falsePositive,
        'true_negative': trueNegative,
        'false_negative': falseNegative,
      },
      'metrics': {
        'accuracy': accuracy,
        'precision': precision,
        'recall': recall,
        'f1_score': f1Score,
        'fpr': fpr,
        'fnr': fnr,
      },
      'recommendations': recommendations,
      'summary': {
        'total_validated': totalValidated,
        'validation_date_range': {
          'start': validationDateStart?.toIso8601String(),
          'end': validationDateEnd?.toIso8601String(),
        },
      },
    };
  }

  /// Get total trees in matrix
  int get totalTrees => truePositive + falsePositive + trueNegative + falseNegative;

  /// Check if metrics meet target thresholds
  /// Backend returns decimal (0-1), not percentage (0-100)
  bool get meetsTargetAccuracy => accuracy >= 0.80; // 80% target
  bool get meetsTargetPrecision => precision >= 0.75; // 75% target
  bool get meetsTargetRecall => recall >= 0.80; // 80% target

  /// Get severity level based on FPR/FNR
  /// Backend returns decimal (0-1), not percentage (0-100)
  String get fprSeverity {
    if (fpr > 0.10) return 'HIGH'; // > 10% false alarms
    if (fpr > 0.05) return 'MEDIUM'; // > 5% false alarms
    return 'LOW';
  }

  String get fnrSeverity {
    if (fnr > 0.20) return 'HIGH'; // > 20% missed detections
    if (fnr > 0.10) return 'MEDIUM'; // > 10% missed detections
    return 'LOW';
  }
}

/// Accuracy breakdown per divisi
class DivisiAccuracy {
  final String divisi;
  final double accuracy;
  final double precision;
  final int totalTrees;
  final BlokTerburuk? blokTerburuk;

  DivisiAccuracy({
    required this.divisi,
    required this.accuracy,
    required this.precision,
    required this.totalTrees,
    this.blokTerburuk,
  });

  factory DivisiAccuracy.fromJson(Map<String, dynamic> json) {
    return DivisiAccuracy(
      divisi: json['divisi'] as String? ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      precision: (json['precision'] as num?)?.toDouble() ?? 0.0,
      totalTrees: (json['total_trees'] as num?)?.toInt() ?? 0,
      blokTerburuk: json['blok_terburuk'] != null
          ? BlokTerburuk.fromJson((json['blok_terburuk'] as Map<String, dynamic>?) ?? {})
          : null,
    );
  }
}

/// Blok dengan accuracy terburuk
class BlokTerburuk {
  final String blok;
  final double accuracy;
  final String issue;

  BlokTerburuk({
    required this.blok,
    required this.accuracy,
    required this.issue,
  });

  factory BlokTerburuk.fromJson(Map<String, dynamic> json) {
    return BlokTerburuk(
      blok: json['blok'] as String? ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      issue: json['issue'] as String? ?? '',
    );
  }
}
