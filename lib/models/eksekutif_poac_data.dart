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
}
