/// Model untuk Dashboard Operasional - KPI Hasil Panen (PANEN Tracking)
/// Data Source: NEW Schema (ops_*, sop_*)
/// Endpoint: GET /api/v1/dashboard/panen
library;

/// Summary metrics for PANEN
class PanenSummary {
  final double totalTonTbs;
  final double avgRejectPersen;
  final int totalSpk;
  final int totalExecutions;

  PanenSummary({
    required this.totalTonTbs,
    required this.avgRejectPersen,
    required this.totalSpk,
    required this.totalExecutions,
  });

  factory PanenSummary.fromJson(Map<String, dynamic> json) {
    return PanenSummary(
      totalTonTbs: (json['total_ton_tbs'] as num?)?.toDouble() ?? 0.0,
      avgRejectPersen: (json['avg_reject_persen'] as num?)?.toDouble() ?? 0.0,
      totalSpk: (json['total_spk'] as num?)?.toInt() ?? 0,
      totalExecutions: (json['total_executions'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Execution detail for a specific harvest event
class PanenExecution {
  final String tanggal;
  final double tonTbs;
  final double rejectPersen;
  final String petugas;
  final String? catatan;

  PanenExecution({
    required this.tanggal,
    required this.tonTbs,
    required this.rejectPersen,
    required this.petugas,
    this.catatan,
  });

  factory PanenExecution.fromJson(Map<String, dynamic> json) {
    return PanenExecution(
      tanggal: json['tanggal'] as String? ?? '',
      tonTbs: (json['ton_tbs'] as num?)?.toDouble() ?? 0.0,
      rejectPersen: (json['reject_persen'] as num?)?.toDouble() ?? 0.0,
      petugas: json['petugas'] as String? ?? 'Unknown',
      catatan: json['catatan'] as String?,
    );
  }
}

/// SPK (Surat Perintah Kerja) detail with executions
class PanenBySPK {
  final String nomorSpk;
  final String lokasi;
  final String mandor;
  final String status;
  final String periode;
  final double totalTon;
  final double avgReject;
  final int executionCount;
  final List<PanenExecution> executions;
  final double? targetTon;
  final String? asisten;

  PanenBySPK({
    required this.nomorSpk,
    required this.lokasi,
    required this.mandor,
    required this.status,
    required this.periode,
    required this.totalTon,
    required this.avgReject,
    required this.executionCount,
    required this.executions,
    this.targetTon,
    this.asisten,
  });

  factory PanenBySPK.fromJson(Map<String, dynamic> json) {
    final executionsList = json['executions'] as List?;
    final executions = executionsList != null
        ? executionsList
            .map((e) => PanenExecution.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PanenExecution>[];

    return PanenBySPK(
      nomorSpk: json['nomor_spk'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      mandor: json['mandor'] as String? ?? '',
      status: json['status'] as String? ?? '',
      periode: json['periode'] as String? ?? '',
      totalTon: (json['total_ton'] as num?)?.toDouble() ?? 0.0,
      avgReject: (json['avg_reject'] as num?)?.toDouble() ?? 0.0,
      executionCount: (json['execution_count'] as num?)?.toInt() ?? 0,
      executions: executions,
      targetTon: (json['target_ton'] as num?)?.toDouble(),
      asisten: json['asisten'] as String?,
    );
  }

  /// Calculate target achievement percentage
  double get targetAchievement {
    if (targetTon == null || targetTon == 0) return 0.0;
    return (totalTon / targetTon!) * 100.0;
  }

  /// Check if target is achieved
  bool get isTargetAchieved {
    if (targetTon == null) return true; // No target set
    return totalTon >= targetTon!;
  }

  /// Get quality status based on reject rate
  String get qualityStatus {
    if (avgReject < 3.0) return 'EXCELLENT';
    if (avgReject < 5.0) return 'GOOD';
    return 'NEEDS_IMPROVEMENT';
  }
}

/// Weekly breakdown for trend analysis
class WeeklyBreakdown {
  final String weekStart;
  final double totalTon;
  final double avgReject;
  final int executionCount;

  WeeklyBreakdown({
    required this.weekStart,
    required this.totalTon,
    required this.avgReject,
    required this.executionCount,
  });

  factory WeeklyBreakdown.fromJson(Map<String, dynamic> json) {
    return WeeklyBreakdown(
      weekStart: json['week_start'] as String? ?? '',
      totalTon: (json['total_ton'] as num?)?.toDouble() ?? 0.0,
      avgReject: (json['avg_reject'] as num?)?.toDouble() ?? 0.0,
      executionCount: (json['execution_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Complete PANEN data for dashboard
class PanenData {
  final PanenSummary summary;
  final List<PanenBySPK> bySpk;
  final List<WeeklyBreakdown> weeklyBreakdown;

  PanenData({
    required this.summary,
    required this.bySpk,
    required this.weeklyBreakdown,
  });

  factory PanenData.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final bySpkList = json['by_spk'] as List?;
    final weeklyList = json['weekly_breakdown'] as List?;

    return PanenData(
      summary: summaryJson != null
          ? PanenSummary.fromJson(summaryJson)
          : PanenSummary(
              totalTonTbs: 0,
              avgRejectPersen: 0,
              totalSpk: 0,
              totalExecutions: 0,
            ),
      bySpk: bySpkList != null
          ? bySpkList
              .map((e) => PanenBySPK.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      weeklyBreakdown: weeklyList != null
          ? weeklyList
              .map((e) => WeeklyBreakdown.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// Get mandor performance comparison
  Map<String, Map<String, double>> getMandorPerformance() {
    final Map<String, Map<String, double>> mandorStats = {};

    for (var spk in bySpk) {
      if (!mandorStats.containsKey(spk.mandor)) {
        mandorStats[spk.mandor] = {'totalTon': 0.0, 'avgReject': 0.0, 'count': 0.0};
      }
      mandorStats[spk.mandor]!['totalTon'] = 
          (mandorStats[spk.mandor]!['totalTon'] ?? 0.0) + spk.totalTon;
      mandorStats[spk.mandor]!['avgReject'] = 
          (mandorStats[spk.mandor]!['avgReject'] ?? 0.0) + spk.avgReject;
      mandorStats[spk.mandor]!['count'] = 
          (mandorStats[spk.mandor]!['count'] ?? 0.0) + 1;
    }

    // Calculate average reject for each mandor
    mandorStats.forEach((key, value) {
      if (value['count']! > 0) {
        value['avgReject'] = value['avgReject']! / value['count']!;
      }
    });

    return mandorStats;
  }

  /// Get afdeling productivity
  Map<String, double> getAfdelingProductivity() {
    final Map<String, double> afdelingTon = {};

    for (var spk in bySpk) {
      // Extract afdeling from lokasi (e.g., "Blok A1-A10 (Afdeling 1)")
      final regex = RegExp(r'Afdeling (\d+)');
      final match = regex.firstMatch(spk.lokasi);
      if (match != null) {
        final afdeling = 'Afdeling ${match.group(1)}';
        afdelingTon[afdeling] = (afdelingTon[afdeling] ?? 0.0) + spk.totalTon;
      }
    }

    return afdelingTon;
  }

  /// Get trend direction (increasing/decreasing)
  String get productivityTrend {
    if (weeklyBreakdown.length < 2) return 'STABLE';
    
    final latest = weeklyBreakdown.last.totalTon;
    final previous = weeklyBreakdown[weeklyBreakdown.length - 2].totalTon;
    
    if (latest > previous * 1.05) return 'INCREASING';
    if (latest < previous * 0.95) return 'DECREASING';
    return 'STABLE';
  }

  /// Get quality trend
  String get qualityTrend {
    if (weeklyBreakdown.length < 2) return 'STABLE';
    
    final latest = weeklyBreakdown.last.avgReject;
    final previous = weeklyBreakdown[weeklyBreakdown.length - 2].avgReject;
    
    if (latest < previous * 0.95) return 'IMPROVING';
    if (latest > previous * 1.05) return 'DECLINING';
    return 'STABLE';
  }
}
