/// Lifecycle Data Models - Multi-Phase Lifecycle Dashboard
/// Date: November 11, 2025
/// 
/// Models untuk 3 Lifecycle APIs:
/// 1. GET /api/v1/lifecycle/overview
/// 2. GET /api/v1/lifecycle/phase/:phase_name
/// 3. GET /api/v1/lifecycle/sop-compliance
library;

/// Lifecycle Phase Info (dari overview)
class LifecyclePhase {
  final String namaFase;
  final int totalSpks;
  final int totalExecutions;
  final double completionRate;

  LifecyclePhase({
    required this.namaFase,
    required this.totalSpks,
    required this.totalExecutions,
    required this.completionRate,
  });

  factory LifecyclePhase.fromJson(Map<String, dynamic> json) {
    print('  📦 Parsing LifecyclePhase: $json');
    
    return LifecyclePhase(
      namaFase: json['nama_fase'] as String? ?? '',
      totalSpks: (json['total_spks'] as num?)?.toInt() ?? 0,
      totalExecutions: (json['total_executions'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Get status based on completion rate
  String get status {
    if (completionRate >= 80) return 'EXCELLENT';
    if (completionRate >= 60) return 'GOOD';
    if (completionRate >= 40) return 'FAIR';
    return 'CRITICAL';
  }

  /// Get color based on status
  String get colorCode {
    if (completionRate >= 80) return '#10b981'; // Green
    if (completionRate >= 40) return '#f59e0b'; // Yellow
    return '#ef4444'; // Red
  }
}

/// Lifecycle Overview (dari GET /lifecycle/overview)
class LifecycleOverview {
  final double healthIndex;
  final int totalSpks;
  final int totalExecutions;
  final List<LifecyclePhase> phases;

  LifecycleOverview({
    required this.healthIndex,
    required this.totalSpks,
    required this.totalExecutions,
    required this.phases,
  });

  factory LifecycleOverview.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing LifecycleOverview from JSON:');
    print('Raw JSON: $json');
    print('JSON keys: ${json.keys.toList()}');
    
    final phasesData = json['phases'] as List<dynamic>? ?? [];
    print('Phases data: $phasesData');
    print('Phases length: ${phasesData.length}');
    
    return LifecycleOverview(
      healthIndex: (json['health_index'] as num?)?.toDouble() ?? 0.0,
      totalSpks: (json['total_spks'] as num?)?.toInt() ?? 0,
      totalExecutions: (json['total_executions'] as num?)?.toInt() ?? 0,
      phases: phasesData
          .map((p) {
            print('Parsing phase: $p');
            return LifecyclePhase.fromJson(p as Map<String, dynamic>);
          })
          .toList(),
    );
  }
}

/// Execution detail dalam SPK Lifecycle
class ExecutionLifecycle {
  final String idEksekusi;
  final String tanggal;
  final String hasil;
  final String petugas;
  final String? catatan;

  ExecutionLifecycle({
    required this.idEksekusi,
    required this.tanggal,
    required this.hasil,
    required this.petugas,
    this.catatan,
  });

  factory ExecutionLifecycle.fromJson(Map<String, dynamic> json) {
    return ExecutionLifecycle(
      idEksekusi: json['id_eksekusi'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      hasil: json['hasil'] as String? ?? '',
      petugas: json['petugas'] as String? ?? '',
      catatan: json['catatan'] as String?,
    );
  }
}

/// SPK detail dalam phase
class SPKLifecycle {
  final String idSpk;
  final String nomorSpk;
  final String status;
  final String tanggal;
  final String lokasi;
  final String mandor;
  final List<ExecutionLifecycle> executions;

  SPKLifecycle({
    required this.idSpk,
    required this.nomorSpk,
    required this.status,
    required this.tanggal,
    required this.lokasi,
    required this.mandor,
    required this.executions,
  });

  factory SPKLifecycle.fromJson(Map<String, dynamic> json) {
    final execData = json['executions'] as List<dynamic>? ?? [];
    
    return SPKLifecycle(
      idSpk: json['id_spk'] as String? ?? '',
      nomorSpk: json['nomor_spk'] as String? ?? '',
      status: json['status'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      mandor: json['mandor'] as String? ?? '',
      executions: execData
          .map((e) => ExecutionLifecycle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Weekly Breakdown (chart data)
class WeeklyBreakdownLifecycle {
  final String weekStart;
  final int spkCount;
  final int executionCount;

  WeeklyBreakdownLifecycle({
    required this.weekStart,
    required this.spkCount,
    required this.executionCount,
  });

  factory WeeklyBreakdownLifecycle.fromJson(Map<String, dynamic> json) {
    return WeeklyBreakdownLifecycle(
      weekStart: json['week_start'] as String? ?? '',
      spkCount: (json['spk_count'] as num?)?.toInt() ?? 0,
      executionCount: (json['execution_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Phase Summary (summary section in detail page)
class PhaseSummary {
  final int subActivitiesCount;
  final int schedulesCount;
  final int totalSpks;
  final int selesaiSpks;
  final int totalExecutions;

  PhaseSummary({
    required this.subActivitiesCount,
    required this.schedulesCount,
    required this.totalSpks,
    required this.selesaiSpks,
    required this.totalExecutions,
  });

  factory PhaseSummary.fromJson(Map<String, dynamic> json) {
    return PhaseSummary(
      subActivitiesCount: (json['sub_activities_count'] as num?)?.toInt() ?? 0,
      schedulesCount: (json['schedules_count'] as num?)?.toInt() ?? 0,
      totalSpks: (json['total_spks'] as num?)?.toInt() ?? 0,
      selesaiSpks: (json['selesai_spks'] as num?)?.toInt() ?? 0,
      totalExecutions: (json['total_executions'] as num?)?.toInt() ?? 0,
    );
  }

  double get completionRate {
    if (totalSpks == 0) return 0.0;
    return (selesaiSpks / totalSpks) * 100;
  }
}

/// Phase Info (phase metadata)
class PhaseInfo {
  final String namaFase;
  final String description;
  final String ageRange;

  PhaseInfo({
    required this.namaFase,
    required this.description,
    required this.ageRange,
  });

  factory PhaseInfo.fromJson(Map<String, dynamic> json) {
    return PhaseInfo(
      namaFase: json['nama_fase'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ageRange: json['age_range'] as String? ?? '',
    );
  }
}

/// Complete Phase Detail (dari GET /lifecycle/phase/:phase_name)
class PhaseDetail {
  final PhaseInfo phaseInfo;
  final PhaseSummary summary;
  final List<SPKLifecycle> spks;
  final List<WeeklyBreakdownLifecycle> weeklyBreakdown;

  PhaseDetail({
    required this.phaseInfo,
    required this.summary,
    required this.spks,
    required this.weeklyBreakdown,
  });

  factory PhaseDetail.fromJson(Map<String, dynamic> json) {
    final spksData = json['spks'] as List<dynamic>? ?? [];
    final weeklyData = json['weekly_breakdown'] as List<dynamic>? ?? [];
    
    return PhaseDetail(
      phaseInfo: PhaseInfo.fromJson(json['phase_info'] as Map<String, dynamic>? ?? {}),
      summary: PhaseSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      spks: spksData
          .map((s) => SPKLifecycle.fromJson(s as Map<String, dynamic>))
          .toList(),
      weeklyBreakdown: weeklyData
          .map((w) => WeeklyBreakdownLifecycle.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Phase Compliance (for SOP widget)
class PhaseCompliance {
  final String namaFase;
  final bool isCompliant;
  final double complianceScore;

  PhaseCompliance({
    required this.namaFase,
    required this.isCompliant,
    required this.complianceScore,
  });

  factory PhaseCompliance.fromJson(Map<String, dynamic> json) {
    return PhaseCompliance(
      namaFase: json['nama_fase'] as String? ?? '',
      isCompliant: json['is_compliant'] as bool? ?? false,
      complianceScore: (json['compliance_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// SOP Compliance Data (dari GET /lifecycle/sop-compliance)
class SOPComplianceData {
  final double overallCompliance;
  final int compliantPhases;
  final int totalPhases;
  final List<String> needsAttention;
  final List<PhaseCompliance> byPhase;

  SOPComplianceData({
    required this.overallCompliance,
    required this.compliantPhases,
    required this.totalPhases,
    required this.needsAttention,
    required this.byPhase,
  });

  factory SOPComplianceData.fromJson(Map<String, dynamic> json) {
    final needsAttentionData = json['needs_attention'] as List<dynamic>? ?? [];
    final byPhaseData = json['by_phase'] as List<dynamic>? ?? [];
    
    return SOPComplianceData(
      overallCompliance: (json['overall_compliance'] as num?)?.toDouble() ?? 0.0,
      compliantPhases: (json['compliant_phases'] as num?)?.toInt() ?? 0,
      totalPhases: (json['total_phases'] as num?)?.toInt() ?? 5,
      needsAttention: needsAttentionData.map((e) => e.toString()).toList(),
      byPhase: byPhaseData
          .map((p) => PhaseCompliance.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Phase Health (for health widget)
class PhaseHealth {
  final String namaFase;
  final double healthScore;
  final String status;

  PhaseHealth({
    required this.namaFase,
    required this.healthScore,
    required this.status,
  });

  factory PhaseHealth.fromJson(Map<String, dynamic> json) {
    return PhaseHealth(
      namaFase: json['nama_fase'] as String? ?? '',
      healthScore: (json['health_score'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'UNKNOWN',
    );
  }
}

/// Plantation Health Data (extended from overview)
class PlantationHealthData {
  final double overallHealth;
  final List<PhaseHealth> byPhase;
  final List<String> criticalPhases;

  PlantationHealthData({
    required this.overallHealth,
    required this.byPhase,
    required this.criticalPhases,
  });

  factory PlantationHealthData.fromJson(Map<String, dynamic> json) {
    final byPhaseData = json['by_phase'] as List<dynamic>? ?? [];
    final criticalData = json['critical_phases'] as List<dynamic>? ?? [];
    
    return PlantationHealthData(
      overallHealth: (json['overall_health'] as num?)?.toDouble() ?? 0.0,
      byPhase: byPhaseData
          .map((p) => PhaseHealth.fromJson(p as Map<String, dynamic>))
          .toList(),
      criticalPhases: criticalData.map((e) => e.toString()).toList(),
    );
  }
}
