/// Model untuk Mandor Performance tracking
/// Digunakan untuk monitor KPI mandor (completion rate, quality, speed)
class MandorPerformanceData {
  final PerformanceSummary summary;
  final List<MandorPerformance> mandors;
  final PerformanceRankings rankings;

  MandorPerformanceData({
    required this.summary,
    required this.mandors,
    required this.rankings,
  });

  factory MandorPerformanceData.fromJson(Map<String, dynamic> json) {
    return MandorPerformanceData(
      summary:
          PerformanceSummary.fromJson(json['summary'] as Map<String, dynamic>),
      mandors: (json['mandors'] as List<dynamic>)
          .map((e) => MandorPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
      rankings: PerformanceRankings.fromJson(
          json['rankings'] as Map<String, dynamic>),
    );
  }
}

/// Summary of all mandors performance
class PerformanceSummary {
  final int totalMandors;
  final double avgCompletionRate;
  final double avgQualityScore;

  PerformanceSummary({
    required this.totalMandors,
    required this.avgCompletionRate,
    required this.avgQualityScore,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      totalMandors: json['total_mandors'] as int,
      avgCompletionRate: (json['avg_completion_rate'] as num).toDouble(),
      avgQualityScore: (json['avg_quality_score'] as num).toDouble(),
    );
  }
}

/// Individual mandor performance
class MandorPerformance {
  final String mandorId;
  final String name;
  final String afdeling;
  final PerformanceMetrics performance;
  final PerformanceBreakdown breakdown;
  final List<PerformanceIssue> issues;
  final List<String> recommendations;

  MandorPerformance({
    required this.mandorId,
    required this.name,
    required this.afdeling,
    required this.performance,
    required this.breakdown,
    required this.issues,
    required this.recommendations,
  });

  factory MandorPerformance.fromJson(Map<String, dynamic> json) {
    return MandorPerformance(
      mandorId: json['mandor_id'] as String,
      name: json['name'] as String,
      afdeling: json['afdeling'] as String,
      performance: PerformanceMetrics.fromJson(
          json['performance'] as Map<String, dynamic>),
      breakdown: PerformanceBreakdown.fromJson(
          json['breakdown'] as Map<String, dynamic>),
      issues: (json['issues'] as List<dynamic>)
          .map((e) => PerformanceIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  /// Get performance rating (A, B, C, D)
  String get performanceRating {
    final score = performance.qualityScore;
    if (score >= 0.90) return 'A';
    if (score >= 0.80) return 'B';
    if (score >= 0.70) return 'C';
    return 'D';
  }

  /// Check if mandor is top performer
  bool get isTopPerformer =>
      performance.completionRate >= 0.90 && performance.qualityScore >= 0.90;

  /// Check if mandor needs attention
  bool get needsAttention =>
      performance.completionRate < 0.70 ||
      performance.qualityScore < 0.80 ||
      performance.spkOverdue > 0;
}

/// Performance metrics
class PerformanceMetrics {
  final int spkAssigned;
  final int spkCompleted;
  final int spkOverdue;
  final double completionRate;
  final double avgCompletionDays;
  final double qualityScore;

  PerformanceMetrics({
    required this.spkAssigned,
    required this.spkCompleted,
    required this.spkOverdue,
    required this.completionRate,
    required this.avgCompletionDays,
    required this.qualityScore,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      spkAssigned: json['spk_assigned'] as int,
      spkCompleted: json['spk_completed'] as int,
      spkOverdue: json['spk_overdue'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      avgCompletionDays: (json['avg_completion_days'] as num).toDouble(),
      qualityScore: (json['quality_score'] as num).toDouble(),
    );
  }
}

/// Performance breakdown (sub-metrics)
class PerformanceBreakdown {
  final double validationAccuracy; // % correct field assessment
  final double sopCompliance; // % tasks with photo+GPS+timestamp
  final double speedScore; // Completion speed vs target
  final double surveyorRating; // Avg rating from surveyor (1-5)

  PerformanceBreakdown({
    required this.validationAccuracy,
    required this.sopCompliance,
    required this.speedScore,
    required this.surveyorRating,
  });

  factory PerformanceBreakdown.fromJson(Map<String, dynamic> json) {
    return PerformanceBreakdown(
      validationAccuracy: (json['validation_accuracy'] as num).toDouble(),
      sopCompliance: (json['sop_compliance'] as num).toDouble(),
      speedScore: (json['speed_score'] as num).toDouble(),
      surveyorRating: (json['surveyor_rating'] as num).toDouble(),
    );
  }

  /// Get radar chart data points (for visualization)
  List<double> get radarDataPoints => [
        validationAccuracy,
        sopCompliance,
        speedScore,
        surveyorRating / 5.0, // Normalize to 0-1
      ];

  /// Get radar chart labels
  List<String> get radarLabels => [
        'Validation\nAccuracy',
        'SOP\nCompliance',
        'Speed\nScore',
        'Surveyor\nRating',
      ];
}

/// Performance issue
class PerformanceIssue {
  final String type; // "overdue_spk", "low_quality", "slow_completion"
  final String spkId;
  final String nomorSpk;
  final int? daysOverdue;
  final String? reason;

  PerformanceIssue({
    required this.type,
    required this.spkId,
    required this.nomorSpk,
    this.daysOverdue,
    this.reason,
  });

  factory PerformanceIssue.fromJson(Map<String, dynamic> json) {
    return PerformanceIssue(
      type: json['type'] as String,
      spkId: json['spk_id'] as String,
      nomorSpk: json['nomor_spk'] as String,
      daysOverdue: json['days_overdue'] as int?,
      reason: json['reason'] as String?,
    );
  }

  /// Get severity color
  String get severityColor {
    switch (type) {
      case 'overdue_spk':
        if (daysOverdue != null && daysOverdue! > 5) return 'darkred';
        return 'red';
      case 'low_quality':
        return 'orange';
      case 'slow_completion':
        return 'yellow';
      default:
        return 'grey';
    }
  }
}

/// Performance rankings
class PerformanceRankings {
  final List<MandorRanking> byCompletionRate;
  final List<MandorRanking> byQuality;
  final List<MandorRanking> bySpeed;

  PerformanceRankings({
    required this.byCompletionRate,
    required this.byQuality,
    required this.bySpeed,
  });

  factory PerformanceRankings.fromJson(Map<String, dynamic> json) {
    return PerformanceRankings(
      byCompletionRate: (json['by_completion_rate'] as List<dynamic>)
          .map((e) => MandorRanking.fromJson(e as Map<String, dynamic>))
          .toList(),
      byQuality: (json['by_quality'] as List<dynamic>)
          .map((e) => MandorRanking.fromJson(e as Map<String, dynamic>))
          .toList(),
      bySpeed: (json['by_speed'] as List<dynamic>)
          .map((e) => MandorRanking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Mandor ranking item
class MandorRanking {
  final String mandorId;
  final String name;
  final double rate;

  MandorRanking({
    required this.mandorId,
    required this.name,
    required this.rate,
  });

  factory MandorRanking.fromJson(Map<String, dynamic> json) {
    return MandorRanking(
      mandorId: json['mandor_id'] as String,
      name: json['name'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }
}
