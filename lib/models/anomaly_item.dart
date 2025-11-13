/// Model untuk anomaly detection data
/// Digunakan untuk identifikasi operational issues (pohon miring, mati, gambut, etc)
class AnomalyData {
  final AnomaliSummary summary;
  final List<AnomalyItem> anomalies;

  AnomalyData({
    required this.summary,
    required this.anomalies,
  });

  factory AnomalyData.fromJson(Map<String, dynamic> json) {
    return AnomalyData(
      summary: AnomaliSummary.fromJson(json['summary'] as Map<String, dynamic>),
      anomalies: (json['anomalies'] as List<dynamic>)
          .map((e) => AnomalyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Helper: Total anomalies count
  int get totalAnomalies => summary.totalAnomalies;

  /// Helper: Kritis severity count (map from high_severity)
  int get kritisCount => summary.highSeverity;

  /// Helper: Tinggi severity count (map from medium_severity)
  int get tinggiCount => summary.mediumSeverity;

  /// Helper: Sedang severity count (map from low_severity)
  int get sedangCount => summary.lowSeverity;
}

/// Summary of anomalies by severity
class AnomaliSummary {
  final int totalAnomalies;
  final int highSeverity;
  final int mediumSeverity;
  final int lowSeverity;

  AnomaliSummary({
    required this.totalAnomalies,
    required this.highSeverity,
    required this.mediumSeverity,
    required this.lowSeverity,
  });

  factory AnomaliSummary.fromJson(Map<String, dynamic> json) {
    return AnomaliSummary(
      totalAnomalies: json['total_anomalies'] as int,
      highSeverity: json['high_severity'] as int,
      mediumSeverity: json['medium_severity'] as int,
      lowSeverity: json['low_severity'] as int,
    );
  }
}

/// Individual anomaly item
class AnomalyItem {
  final String type; // "pohon_miring", "pohon_mati", "gambut_amblas", "spacing"
  final String severity; // "high", "medium", "low"
  final int count;
  final String criteria;
  final List<AnomalyTree>? trees; // For tree-level anomalies
  final List<String>? bloks; // For blok-level anomalies (gambut)
  final int? treesAffected; // Total trees affected (for blok-level)
  final String recommendedAction;
  final int estimatedCost;
  final String priority; // "critical", "urgent", "high", "normal"
  final DateTime? dueDate;

  AnomalyItem({
    required this.type,
    required this.severity,
    required this.count,
    required this.criteria,
    this.trees,
    this.bloks,
    this.treesAffected,
    required this.recommendedAction,
    required this.estimatedCost,
    required this.priority,
    this.dueDate,
  });

  factory AnomalyItem.fromJson(Map<String, dynamic> json) {
    return AnomalyItem(
      type: json['type'] as String,
      severity: json['severity'] as String,
      count: json['count'] as int,
      criteria: json['criteria'] as String,
      trees: json['trees'] != null
          ? (json['trees'] as List<dynamic>)
              .map((e) => AnomalyTree.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      bloks: json['bloks'] != null
          ? (json['bloks'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      treesAffected: json['trees_affected'] as int?,
      recommendedAction: json['recommended_action'] as String,
      estimatedCost: json['estimated_cost'] as int,
      priority: json['priority'] as String,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
    );
  }

  /// Get display name for anomaly type
  String get typeDisplayName {
    switch (type) {
      case 'pohon_miring':
        return 'Pohon Miring';
      case 'pohon_mati':
        return 'Pohon Mati';
      case 'gambut_amblas':
        return 'Gambut Amblas';
      case 'spacing':
        return 'Spacing Tidak Standar';
      case 'ndre':
        return 'NDRE Rendah';
      default:
        return type;
    }
  }

  /// Get icon for anomaly type
  String get typeIcon {
    switch (type) {
      case 'pohon_miring':
        return '📐';
      case 'pohon_mati':
        return '💀';
      case 'gambut_amblas':
        return '🕳️';
      case 'spacing':
        return '📏';
      case 'ndre':
        return '📊';
      default:
        return '⚠️';
    }
  }

  /// Get severity color (as Color import from Flutter)
  String get severityColorString {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'kritis':
        return 'red';
      case 'medium':
      case 'tinggi':
        return 'orange';
      case 'low':
      case 'sedang':
        return 'green';
      default:
        return 'grey';
    }
  }

  /// Get priority color
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return 'darkred';
      case 'urgent':
        return 'red';
      case 'high':
        return 'orange';
      case 'normal':
        return 'blue';
      default:
        return 'grey';
    }
  }

  /// Helper: Get unique ID for this anomaly
  String get id => '${type}_${severity}_${count}';

  /// Helper: Get affected count (trees or treesAffected)
  int get affectedCount => trees?.length ?? treesAffected ?? count;

  /// Helper: Get severity icon (MaterialIcons)
  String get severityIconName {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'kritis':
        return 'error';
      case 'medium':
      case 'tinggi':
        return 'warning';
      case 'low':
      case 'sedang':
        return 'info';
      default:
        return 'help';
    }
  }
}

/// Tree with anomaly detail
class AnomalyTree {
  final String idNpokok;
  final String treeId;
  final double? angleDegree; // For pohon_miring
  final TreeLocation location;
  final GpsLocation gps;
  final String? photoUrl;
  final DateTime detectedDate;
  final Map<String, dynamic>? additionalData;

  AnomalyTree({
    required this.idNpokok,
    required this.treeId,
    this.angleDegree,
    required this.location,
    required this.gps,
    this.photoUrl,
    required this.detectedDate,
    this.additionalData,
  });

  factory AnomalyTree.fromJson(Map<String, dynamic> json) {
    return AnomalyTree(
      idNpokok: json['id_npokok'] as String,
      treeId: json['tree_id'] as String,
      angleDegree: json['angle_degree'] != null
          ? (json['angle_degree'] as num).toDouble()
          : null,
      location: TreeLocation.fromJson(json['location'] as Map<String, dynamic>),
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>),
      photoUrl: json['photo_url'] as String?,
      detectedDate: DateTime.parse(json['detected_date']),
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }
}

/// Tree location detail
class TreeLocation {
  final String divisi;
  final String afdeling;
  final String blok;
  final int row;
  final int position;

  TreeLocation({
    required this.divisi,
    required this.afdeling,
    required this.blok,
    required this.row,
    required this.position,
  });

  factory TreeLocation.fromJson(Map<String, dynamic> json) {
    return TreeLocation(
      divisi: json['divisi'] as String,
      afdeling: json['afdeling'] as String,
      blok: json['blok'] as String,
      row: json['row'] as int,
      position: json['position'] as int,
    );
  }

  String get fullLocation => '$divisi / $afdeling / Blok $blok / Baris $row-$position';
}

/// GPS Location (reuse from validation_point if needed)
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
