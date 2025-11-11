/// Model data gabungan untuk Dashboard Eksekutif POAC
/// Menggabungkan data dari 2 endpoint:
/// 1. GET /dashboard/kpi-eksekutif (Control data)
/// 2. GET /dashboard/operasional (Organize & Actuate data)
class EksekutifPOACData {
  /// Data KPI Eksekutif (untuk kuadran C - Control)
  final Map<String, dynamic> kpiData;
  
  /// Data Operasional (untuk kuadran O - Organize & A - Actuate)
  final Map<String, dynamic> operasionalData;

  EksekutifPOACData({
    required this.kpiData,
    required this.operasionalData,
  });

  /// Helper: Get KRI Lead Time APH (Control)
  double get kriLeadTimeAph {
    return (kpiData['kri_lead_time_aph'] as num?)?.toDouble() ?? 0.0;
  }

  /// Helper: Get KRI Kepatuhan SOP (Plan)
  double get kriKepatuhanSop {
    return (kpiData['kri_kepatuhan_sop'] as num?)?.toDouble() ?? 0.0;
  }

  /// Helper: Get Tren Insidensi Baru (Control)
  List<Map<String, dynamic>> get trenInsidensiBaru {
    final tren = kpiData['tren_insidensi_baru'];
    if (tren is List) {
      return tren.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Tren G4 Aktif (Control)
  List<Map<String, dynamic>> get trenG4Aktif {
    final tren = kpiData['tren_g4_aktif'];
    if (tren is List) {
      return tren.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Data Corong (Organize)
  Map<String, dynamic> get dataCorong {
    final corong = operasionalData['data_corong'];
    if (corong is Map<String, dynamic>) {
      return corong;
    }
    return {};
  }

  /// Helper: Get Data Papan Peringkat (Actuate)
  List<Map<String, dynamic>> get dataPapanPeringkat {
    final peringkat = operasionalData['data_papan_peringkat'];
    if (peringkat is List) {
      return peringkat.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Hitung Total SPK Aktif (Organize)
  int get totalSpkAktif {
    final corong = dataCorong;
    final targetValidasi = (corong['target_validasi'] as num?)?.toInt() ?? 0;
    final targetAph = (corong['target_aph'] as num?)?.toInt() ?? 0;
    final targetSanitasi = (corong['target_sanitasi'] as num?)?.toInt() ?? 0;
    return targetValidasi + targetAph + targetSanitasi;
  }

  /// Helper: Hitung Tugas Sedang Dikerjakan (Organize)
  int get tugasDikerjakan {
    final corong = dataCorong;
    final targetTotal = totalSpkAktif;
    final selesaiValidasi = (corong['selesai_validasi'] as num?)?.toInt() ?? 0;
    final selesaiAph = (corong['selesai_aph'] as num?)?.toInt() ?? 0;
    final selesaiSanitasi = (corong['selesai_sanitasi'] as num?)?.toInt() ?? 0;
    final totalSelesai = selesaiValidasi + selesaiAph + selesaiSanitasi;
    return targetTotal - totalSelesai;
  }

  /// Helper: Hitung Pelaksana Aktif (Actuate)
  int get pelaksanaAktif {
    return dataPapanPeringkat.length;
  }

  // ========== ENHANCEMENT HELPERS (New API Fields) ==========

  /// Helper: Get Tren Kepatuhan SOP (Plan - NEW)
  List<Map<String, dynamic>> get trenKepatuhanSop {
    final tren = kpiData['tren_kepatuhan_sop'];
    if (tren is List) {
      return tren.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get SOP Compliance Breakdown (Plan - V2 NEW)
  Map<String, dynamic> get sopComplianceBreakdown {
    final breakdown = kpiData['sop_compliance_breakdown'];
    if (breakdown is Map<String, dynamic>) {
      return breakdown;
    }
    return {
      'compliant_items': [],
      'non_compliant_items': [],
      'partially_compliant_items': [],
    };
  }

  /// Helper: Get Compliant Items
  List<Map<String, dynamic>> get compliantItems {
    final breakdown = sopComplianceBreakdown;
    final items = breakdown['compliant_items'];
    if (items is List) {
      return items.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Non-Compliant Items
  List<Map<String, dynamic>> get nonCompliantItems {
    final breakdown = sopComplianceBreakdown;
    final items = breakdown['non_compliant_items'];
    if (items is List) {
      return items.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Partially Compliant Items
  List<Map<String, dynamic>> get partiallyCompliantItems {
    final breakdown = sopComplianceBreakdown;
    final items = breakdown['partially_compliant_items'];
    if (items is List) {
      return items.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Planning Accuracy (Plan - NEW)
  Map<String, dynamic> get planningAccuracy {
    final accuracy = kpiData['planning_accuracy'];
    if (accuracy is Map<String, dynamic>) {
      return accuracy;
    }
    return {
      'last_month': {
        'target_completion': 0,
        'actual_completion': 0,
        'accuracy_percentage': 0.0,
      },
      'current_month': {
        'target_completion': 0,
        'actual_completion': 0,
        'accuracy_percentage': 0.0,
        'projected_final_accuracy': 0.0,
      },
    };
  }

  /// Helper: Calculate SOP Velocity (Plan - Calculated)
  /// Returns velocity in percentage points per week (can be negative)
  double get sopVelocity {
    final tren = trenKepatuhanSop;
    if (tren.length < 2) return 0.0;
    
    final latest = (tren.last['nilai'] as num?)?.toDouble() ?? 0.0;
    final previous = (tren[tren.length - 2]['nilai'] as num?)?.toDouble() ?? 0.0;
    return latest - previous;
  }

  /// Helper: Calculate weeks to target 90% SOP (Plan - Calculated)
  /// Returns null if velocity is 0 or negative
  int? get weeksToTarget90 {
    final current = kriKepatuhanSop;
    final velocity = sopVelocity;
    
    if (velocity <= 0 || current >= 90.0) return null;
    
    final gap = 90.0 - current;
    return (gap / velocity).ceil();
  }

  // ========== DEADLINE HELPERS (Organize - NEW) ==========

  /// Helper: Get Deadline Validasi (nullable)
  DateTime? get deadlineValidasi {
    final deadline = dataCorong['deadline_validasi'];
    if (deadline == null || deadline == 'null') return null;
    try {
      return DateTime.parse(deadline);
    } catch (e) {
      return null;
    }
  }

  /// Helper: Get Deadline APH (nullable)
  DateTime? get deadlineAph {
    final deadline = dataCorong['deadline_aph'];
    if (deadline == null || deadline == 'null') return null;
    try {
      return DateTime.parse(deadline);
    } catch (e) {
      return null;
    }
  }

  /// Helper: Get Deadline Sanitasi (nullable)
  DateTime? get deadlineSanitasi {
    final deadline = dataCorong['deadline_sanitasi'];
    if (deadline == null || deadline == 'null') return null;
    try {
      return DateTime.parse(deadline);
    } catch (e) {
      return null;
    }
  }

  /// Helper: Calculate days until deadline (negative if overdue)
  int? daysUntilDeadline(DateTime? deadline) {
    if (deadline == null) return null;
    return deadline.difference(DateTime.now()).inDays;
  }

  // ========== RISK LEVEL HELPERS (Organize - NEW) ==========

  /// Helper: Get Risk Level Validasi
  String get riskLevelValidasi {
    return dataCorong['risk_level_validasi'] ?? 'LOW';
  }

  /// Helper: Get Risk Level APH
  String get riskLevelAph {
    return dataCorong['risk_level_aph'] ?? 'LOW';
  }

  /// Helper: Get Risk Level Sanitasi
  String get riskLevelSanitasi {
    return dataCorong['risk_level_sanitasi'] ?? 'LOW';
  }

  // ========== BLOCKER HELPERS (Organize - NEW) ==========

  /// Helper: Get Blockers Validasi (OLD - Simple String List)
  List<String> get blockersValidasi {
    final blockers = dataCorong['blockers_validasi'];
    if (blockers is List) {
      return blockers.cast<String>();
    }
    return [];
  }

  /// Helper: Get Blockers APH (OLD - Simple String List)
  List<String> get blockersAph {
    final blockers = dataCorong['blockers_aph'];
    if (blockers is List) {
      return blockers.cast<String>();
    }
    return [];
  }

  /// Helper: Get Blockers Sanitasi (OLD - Simple String List)
  List<String> get blockersSanitasi {
    final blockers = dataCorong['blockers_sanitasi'];
    if (blockers is List) {
      return blockers.cast<String>();
    }
    return [];
  }

  // ========== BLOCKER DETAIL HELPERS (Organize - V2 NEW) ==========

  /// Helper: Get Blockers Detail for Validasi
  List<Map<String, dynamic>> get validasiBlockersDetail {
    final blockers = dataCorong['validasi_blockers_detail'];
    if (blockers is List) {
      return blockers.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Blockers Detail for APH
  List<Map<String, dynamic>> get aphBlockersDetail {
    final blockers = dataCorong['aph_blockers_detail'];
    if (blockers is List) {
      return blockers.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Blockers Detail for Sanitasi
  List<Map<String, dynamic>> get sanitasiBlockersDetail {
    final blockers = dataCorong['sanitasi_blockers_detail'];
    if (blockers is List) {
      return blockers.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ========== PLANNING TASKS HELPERS (Organize - V2 NEW) ==========

  /// Helper: Get Tasks for Validasi
  List<Map<String, dynamic>> get validasiTasks {
    final tasks = dataCorong['validasi_tasks'];
    if (tasks is List) {
      return tasks.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Tasks for APH
  List<Map<String, dynamic>> get aphTasks {
    final tasks = dataCorong['aph_tasks'];
    if (tasks is List) {
      return tasks.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Helper: Get Tasks for Sanitasi
  List<Map<String, dynamic>> get sanitasiTasks {
    final tasks = dataCorong['sanitasi_tasks'];
    if (tasks is List) {
      return tasks.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ========== RESOURCE ALLOCATION HELPERS (Organize - NEW) ==========

  /// Helper: Get Pelaksana Assigned to Validasi
  int get pelaksanaAssignedValidasi {
    return (dataCorong['pelaksana_assigned_validasi'] as num?)?.toInt() ?? 0;
  }

  /// Helper: Get Pelaksana Assigned to APH
  int get pelaksanaAssignedAph {
    return (dataCorong['pelaksana_assigned_aph'] as num?)?.toInt() ?? 0;
  }

  /// Helper: Get Pelaksana Assigned to Sanitasi
  int get pelaksanaAssignedSanitasi {
    return (dataCorong['pelaksana_assigned_sanitasi'] as num?)?.toInt() ?? 0;
  }
}
