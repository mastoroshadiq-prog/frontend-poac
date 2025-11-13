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
      idNpokok: json['id_npokok'] as String,
      treeId: json['tree_id'] as String,
      ndreValue: (json['ndre_value'] as num).toDouble(),
      fieldScore: json['field_score'] as int,
      dronePrediction: json['drone_prediction'] as String,
      fieldActual: json['field_actual'] as String,
      category: json['category'] as String,
      surveyor: json['surveyor'] as String?,
      validationDate: json['validation_date'] != null
          ? DateTime.parse(json['validation_date'])
          : null,
      gps: json['gps'] != null
          ? GpsLocation.fromJson(json['gps'] as Map<String, dynamic>)
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
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
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

  FieldVsDroneData({
    required this.distribution,
    required this.recommendations,
    required this.totalTrees,
  });

  factory FieldVsDroneData.fromJson(Map<String, dynamic> json) {
    return FieldVsDroneData(
      distribution: (json['distribution'] as List<dynamic>)
          .map((e) => ValidationDistribution.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalTrees: json['total_trees'] as int? ?? 0,
    );
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
    return ValidationDistribution(
      dronePrediction: json['drone_prediction'] as String,
      fieldActual: json['field_actual'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      category: json['category'] as String,
      avgNdre: (json['avg_ndre'] as num).toDouble(),
      trees: (json['trees'] as List<dynamic>)
          .map((e) => ValidationPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      commonCauses: json['common_causes'] != null
          ? (json['common_causes'] as List<dynamic>)
              .map((e) => CommonCause.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
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
      cause: json['cause'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
