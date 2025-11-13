/// Model untuk SPK (Surat Perintah Kerja) - Kanban Board
/// 
/// Digunakan untuk menampilkan SPK dalam kanban board dengan status:
/// - PENDING: SPK baru dibuat, belum dikerjakan
/// - DIKERJAKAN: SPK sedang dalam proses
/// - SELESAI: SPK sudah selesai dikerjakan

class SpkKanbanData {
  final List<SpkCard> pending;
  final List<SpkCard> dikerjakan;
  final List<SpkCard> selesai;
  final SpkStatistics statistics;

  SpkKanbanData({
    required this.pending,
    required this.dikerjakan,
    required this.selesai,
    required this.statistics,
  });

  factory SpkKanbanData.fromJson(Map<String, dynamic> json) {
    return SpkKanbanData(
      pending: (json['pending'] as List<dynamic>?)
              ?.map((e) => SpkCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dikerjakan: (json['dikerjakan'] as List<dynamic>?)
              ?.map((e) => SpkCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selesai: (json['selesai'] as List<dynamic>?)
              ?.map((e) => SpkCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statistics: json['statistics'] != null
          ? SpkStatistics.fromJson(json['statistics'] as Map<String, dynamic>)
          : SpkStatistics.empty(),
    );
  }

  /// Factory untuk dummy data development
  factory SpkKanbanData.dummy() {
    return SpkKanbanData(
      pending: [
        SpkCard.dummy('SPK-001', 'Validasi Pohon B12A', 'VALIDASI', 'Mandor A'),
        SpkCard.dummy('SPK-004', 'APH Blok B14C', 'APH', 'Mandor D'),
      ],
      dikerjakan: [
        SpkCard.dummy('SPK-002', 'Sanitasi Blok B13A', 'SANITASI', 'Mandor B',
            progress: 45),
        SpkCard.dummy('SPK-003', 'Validasi Area Stres', 'VALIDASI', 'Mandor C',
            progress: 78),
      ],
      selesai: [
        SpkCard.dummy('SPK-000', 'APH Rutin B11A', 'APH', 'Mandor Z',
            progress: 100, completedAt: DateTime.now().subtract(const Duration(hours: 2))),
      ],
      statistics: SpkStatistics(
        totalSpk: 5,
        completionRate: 20.0,
        avgTimeToComplete: 3.5,
        overdueCount: 1,
      ),
    );
  }
}

/// Card model untuk setiap SPK di kanban board
class SpkCard {
  final String idSpk;
  final String nomorSpk;
  final String namaSpk;
  final String tipeSpk; // VALIDASI, APH, SANITASI, PANEN
  final String status; // PENDING, DIKERJAKAN, SELESAI
  final String pelaksana; // Nama Mandor
  final DateTime createdAt;
  final DateTime? targetSelesai;
  final DateTime? completedAt;
  final int jumlahTugas;
  final int tugasSelesai;
  final double progress; // 0-100
  final String? prioritas; // HIGH, MEDIUM, LOW
  final String? divisi;
  final String? blok;
  final List<String>? tags;

  SpkCard({
    required this.idSpk,
    required this.nomorSpk,
    required this.namaSpk,
    required this.tipeSpk,
    required this.status,
    required this.pelaksana,
    required this.createdAt,
    this.targetSelesai,
    this.completedAt,
    required this.jumlahTugas,
    required this.tugasSelesai,
    required this.progress,
    this.prioritas,
    this.divisi,
    this.blok,
    this.tags,
  });

  factory SpkCard.fromJson(Map<String, dynamic> json) {
    final jumlahTugas = json['jumlah_tugas'] as int? ?? 0;
    final tugasSelesai = json['tugas_selesai'] as int? ?? 0;
    final progress = jumlahTugas > 0 ? (tugasSelesai / jumlahTugas) * 100 : 0.0;

    return SpkCard(
      idSpk: json['id_spk'] as String,
      nomorSpk: json['nomor_spk'] as String,
      namaSpk: json['nama_spk'] as String,
      tipeSpk: json['tipe_spk'] as String,
      status: json['status'] as String,
      pelaksana: json['pelaksana'] as String? ?? 'Unassigned',
      createdAt: DateTime.parse(json['created_at'] as String),
      targetSelesai: json['target_selesai'] != null
          ? DateTime.parse(json['target_selesai'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      jumlahTugas: jumlahTugas,
      tugasSelesai: tugasSelesai,
      progress: progress,
      prioritas: json['prioritas'] as String?,
      divisi: json['divisi'] as String?,
      blok: json['blok'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_spk': idSpk,
      'nomor_spk': nomorSpk,
      'nama_spk': namaSpk,
      'tipe_spk': tipeSpk,
      'status': status,
      'pelaksana': pelaksana,
      'created_at': createdAt.toIso8601String(),
      if (targetSelesai != null) 'target_selesai': targetSelesai!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'jumlah_tugas': jumlahTugas,
      'tugas_selesai': tugasSelesai,
      'progress': progress,
      if (prioritas != null) 'prioritas': prioritas,
      if (divisi != null) 'divisi': divisi,
      if (blok != null) 'blok': blok,
      if (tags != null) 'tags': tags,
    };
  }

  /// Helper: Check if SPK is overdue
  bool get isOverdue {
    if (targetSelesai == null || status == 'SELESAI') return false;
    return DateTime.now().isAfter(targetSelesai!);
  }

  /// Helper: Days until target
  int? get daysUntilTarget {
    if (targetSelesai == null) return null;
    return targetSelesai!.difference(DateTime.now()).inDays;
  }

  /// Helper: Progress color
  String get progressColor {
    if (progress >= 80) return 'green';
    if (progress >= 50) return 'orange';
    return 'red';
  }

  /// Helper: Priority color
  String get priorityColor {
    switch (prioritas?.toUpperCase()) {
      case 'HIGH':
        return 'red';
      case 'MEDIUM':
        return 'orange';
      case 'LOW':
        return 'blue';
      default:
        return 'grey';
    }
  }

  /// Helper: Tipe icon
  String get tipeIcon {
    switch (tipeSpk.toUpperCase()) {
      case 'VALIDASI':
        return 'check_circle';
      case 'APH':
        return 'agriculture';
      case 'SANITASI':
        return 'cleaning_services';
      case 'PANEN':
        return 'shopping_basket';
      default:
        return 'assignment';
    }
  }

  /// Factory untuk dummy data
  factory SpkCard.dummy(
    String nomor,
    String nama,
    String tipe,
    String pelaksana, {
    double progress = 0,
    DateTime? completedAt,
  }) {
    final status = progress == 100
        ? 'SELESAI'
        : progress > 0
            ? 'DIKERJAKAN'
            : 'PENDING';
    final jumlahTugas = 10;
    final tugasSelesai = (jumlahTugas * progress / 100).round();

    return SpkCard(
      idSpk: 'id-$nomor',
      nomorSpk: nomor,
      namaSpk: nama,
      tipeSpk: tipe,
      status: status,
      pelaksana: pelaksana,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      targetSelesai: DateTime.now().add(const Duration(days: 3)),
      completedAt: completedAt,
      jumlahTugas: jumlahTugas,
      tugasSelesai: tugasSelesai,
      progress: progress,
      prioritas: progress < 30 ? 'HIGH' : 'MEDIUM',
      divisi: 'Divisi 1',
      blok: 'B12A',
      tags: [tipe, 'URGENT'],
    );
  }

  /// Copy with method
  SpkCard copyWith({
    String? status,
    int? tugasSelesai,
    double? progress,
    DateTime? completedAt,
  }) {
    return SpkCard(
      idSpk: idSpk,
      nomorSpk: nomorSpk,
      namaSpk: namaSpk,
      tipeSpk: tipeSpk,
      status: status ?? this.status,
      pelaksana: pelaksana,
      createdAt: createdAt,
      targetSelesai: targetSelesai,
      completedAt: completedAt ?? this.completedAt,
      jumlahTugas: jumlahTugas,
      tugasSelesai: tugasSelesai ?? this.tugasSelesai,
      progress: progress ?? this.progress,
      prioritas: prioritas,
      divisi: divisi,
      blok: blok,
      tags: tags,
    );
  }
}

/// Statistics untuk SPK kanban board
class SpkStatistics {
  final int totalSpk;
  final double completionRate; // Percentage
  final double avgTimeToComplete; // Days
  final int overdueCount;

  SpkStatistics({
    required this.totalSpk,
    required this.completionRate,
    required this.avgTimeToComplete,
    required this.overdueCount,
  });

  factory SpkStatistics.fromJson(Map<String, dynamic> json) {
    return SpkStatistics(
      totalSpk: json['total_spk'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      avgTimeToComplete: (json['avg_time_to_complete'] as num).toDouble(),
      overdueCount: json['overdue_count'] as int,
    );
  }

  factory SpkStatistics.empty() {
    return SpkStatistics(
      totalSpk: 0,
      completionRate: 0.0,
      avgTimeToComplete: 0.0,
      overdueCount: 0,
    );
  }
}
