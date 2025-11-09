import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/dashboard_service.dart';
import '../models/eksekutif_poac_data.dart';

/// Dashboard Eksekutif View - REFACTOR #1: Intelijen POAC Penuh
/// Menampilkan ringkasan 4 Kuadran: PLAN, ORGANIZE, ACTUATE, CONTROL
/// 
/// Data Source:
/// - Kuadran P & C: GET /dashboard/kpi-eksekutif
/// - Kuadran O & A: GET /dashboard/operasional
/// 
/// RBAC: Memerlukan role ASISTEN atau ADMIN
class DashboardEksekutifView extends StatefulWidget {
  /// JWT Token untuk autentikasi (opsional, akan diambil dari Supabase session)
  final String? token;

  const DashboardEksekutifView({
    super.key,
    this.token,
  });

  @override
  State<DashboardEksekutifView> createState() => _DashboardEksekutifViewState();
}

class _DashboardEksekutifViewState extends State<DashboardEksekutifView> {
  final DashboardService _dashboardService = DashboardService();
  late Future<EksekutifPOACData> _poacDataFuture;

  @override
  void initState() {
    super.initState();
    // Load data POAC gabungan saat widget pertama kali dibuat
    _poacDataFuture = _dashboardService.fetchEksekutifPOACData();
  }

  /// Refresh data POAC (pull-to-refresh)
  void _refreshData() {
    setState(() {
      _poacDataFuture = _dashboardService.fetchEksekutifPOACData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Eksekutif - Intelijen POAC'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: FutureBuilder<EksekutifPOACData>(
        future: _poacDataFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data POAC...'),
                ],
              ),
            );
          }

          // Error state (RBAC errors)
          if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            
            IconData errorIcon;
            Color errorColor;
            String errorTitle;
            
            if (errorMessage.contains('Silakan Login') || errorMessage.contains('401')) {
              errorIcon = Icons.lock_outline;
              errorColor = Colors.orange;
              errorTitle = 'Silakan Login';
            } else if (errorMessage.contains('Akses Ditolak') || errorMessage.contains('403')) {
              errorIcon = Icons.block;
              errorColor = Colors.red;
              errorTitle = 'Akses Ditolak';
            } else {
              errorIcon = Icons.error_outline;
              errorColor = Colors.red;
              errorTitle = 'Gagal memuat data';
            }
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      errorIcon,
                      color: errorColor,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Success state - Render 4 Kuadran POAC
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Tidak ada data'),
            );
          }

          final poacData = snapshot.data!;
          return _buildDashboardPOAC(poacData);
        },
      ),
    );
  }

  /// Build konten dashboard dengan 4 Kuadran POAC
  Widget _buildDashboardPOAC(EksekutifPOACData poacData) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        // Tunggu future selesai
        await _poacDataFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: GridView untuk desktop, Column untuk mobile
            if (constraints.maxWidth > 800) {
              // Desktop: 2x2 Grid
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildKuadranPlan(poacData),
                  _buildKuadranOrganize(poacData),
                  _buildKuadranActuate(poacData),
                  _buildKuadranControl(poacData),
                ],
              );
            } else {
              // Mobile: Column
              return Column(
                children: [
                  _buildKuadranPlan(poacData),
                  const SizedBox(height: 16),
                  _buildKuadranOrganize(poacData),
                  const SizedBox(height: 16),
                  _buildKuadranActuate(poacData),
                  const SizedBox(height: 16),
                  _buildKuadranControl(poacData),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  /// KUADRAN P (PLAN) - Target & Progress
  Widget _buildKuadranPlan(EksekutifPOACData poacData) {
    final double kepatuhanSop = poacData.kriKepatuhanSop;
    const double targetSop = 90.0; // HARDCODED as per business rule

    // Extract planning execution data from data_corong
    final corong = poacData.dataCorong;
    final targetVal = (corong['target_validasi'] as num?)?.toInt() ?? 0;
    final selesaiVal = (corong['selesai_validasi'] as num?)?.toInt() ?? 0;
    final targetAph = (corong['target_aph'] as num?)?.toInt() ?? 0;
    final selesaiAph = (corong['selesai_aph'] as num?)?.toInt() ?? 0;
    final targetSan = (corong['target_sanitasi'] as num?)?.toInt() ?? 0;
    final selesaiSan = (corong['selesai_sanitasi'] as num?)?.toInt() ?? 0;

    final totalTarget = targetVal + targetAph + targetSan;
    final totalSelesai = selesaiVal + selesaiAph + selesaiSan;
    final overallProgress = totalTarget > 0 ? (totalSelesai / totalTarget * 100) : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flag, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'P (PLAN) - Target & Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // SOP Compliance Gauge (Existing)
                    Center(
                      child: CircularPercentIndicator(
                        radius: 50.0,
                        lineWidth: 10.0,
                        percent: kepatuhanSop / 100.0,
                        center: Text(
                          '${kepatuhanSop.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        progressColor: kepatuhanSop >= targetSop ? Colors.green : Colors.orange,
                        backgroundColor: Colors.grey.shade200,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Kepatuhan SOP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'Target: ${targetSop.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Planning Execution Section
                    const Row(
                      children: [
                        Icon(Icons.assignment_outlined, size: 16, color: Colors.black87),
                        SizedBox(width: 6),
                        Text(
                          'PLANNING EXECUTION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Progress Bars
                    _buildPlanProgressRow('Validasi', selesaiVal, targetVal, Colors.blue),
                    const SizedBox(height: 10),
                    _buildPlanProgressRow('APH', selesaiAph, targetAph, Colors.green),
                    const SizedBox(height: 10),
                    _buildPlanProgressRow('Sanitasi', selesaiSan, targetSan, Colors.purple),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Summary Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildPlanMiniCard(
                            'Total',
                            totalTarget.toString(),
                            Icons.list_alt,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPlanMiniCard(
                            'Done',
                            totalSelesai.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPlanMiniCard(
                            'Progress',
                            '${overallProgress.toStringAsFixed(0)}%',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Build Planning Progress Row (Linear Progress Bar)
  Widget _buildPlanProgressRow(String label, int selesai, int target, Color color) {
    final percent = target > 0 ? selesai / target : 0.0;
    final percentText = (percent * 100).toStringAsFixed(0);
    
    // Status icon
    IconData statusIcon;
    Color statusColor;
    if (percent >= 1.0) {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else if (percent >= 0.5) {
      statusIcon = Icons.warning_amber_rounded;
      statusColor = Colors.orange;
    } else {
      statusIcon = Icons.error_outline;
      statusColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$percentText% ($selesai/$target)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// Helper: Build Planning Mini Card
  Widget _buildPlanMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// KUADRAN O (ORGANIZE) - Work in Progress
  Widget _buildKuadranOrganize(EksekutifPOACData poacData) {
    final int totalSpk = poacData.totalSpkAktif;
    final int tugasDikerjakan = poacData.tugasDikerjakan;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.work, color: Colors.orange.shade700),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'O (ORGANIZE) - WIP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatTile(
                    icon: Icons.assignment,
                    label: 'Total SPK Aktif',
                    value: totalSpk.toString(),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildStatTile(
                    icon: Icons.hourglass_empty,
                    label: 'Tugas "DIKERJAKAN"',
                    value: tugasDikerjakan.toString(),
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// KUADRAN A (ACTUATE) - Aktivitas Lapangan
  Widget _buildKuadranActuate(EksekutifPOACData poacData) {
    final int pelaksanaAktif = poacData.pelaksanaAktif;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.people, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'A (ACTUATE) - Aktivitas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _buildStatTile(
                  icon: Icons.groups,
                  label: 'Pelaksana Aktif',
                  value: pelaksanaAktif.toString(),
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// KUADRAN C (CONTROL) - Hasil & Dampak
  Widget _buildKuadranControl(EksekutifPOACData poacData) {
    final double leadTimeAph = poacData.kriLeadTimeAph;
    final List<Map<String, dynamic>> trenInsidensi = poacData.trenInsidensiBaru;
    final List<Map<String, dynamic>> trenG4 = poacData.trenG4Aktif;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.analytics, color: Colors.purple.shade700),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'C (CONTROL) - Hasil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lead Time APH
                    Center(
                      child: CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 8.0,
                        percent: (3.0 - leadTimeAph).clamp(0.0, 3.0) / 3.0,
                        center: Text(
                          '${leadTimeAph.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        footer: const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Lead Time APH (hari)',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                        progressColor: leadTimeAph <= 3.0 ? Colors.green : Colors.red,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Mini Tren Charts
                    if (trenInsidensi.isNotEmpty)
                      _buildMiniTrendChart('Tren Insidensi', trenInsidensi, Colors.red),
                    if (trenG4.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildMiniTrendChart('Tren G4 Aktif', trenG4, Colors.orange),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Build Stat Tile
  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Build Mini Trend Chart
  Widget _buildMiniTrendChart(String title, List<Map<String, dynamic>> data, Color color) {
    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data.asMap().entries.map((entry) {
      final nilai = (entry.value['nilai'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(entry.key.toDouble(), nilai);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 60,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
              minY: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// Build konten dashboard dengan data KPI (OLD - DEPRECATED, NOT USED)
  // ignore: unused_element
  Widget _buildDashboardContent(Map<String, dynamic> data) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        // Tunggu future selesai
        await _poacDataFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section M-1.1: Lampu KRI (Indikator Persentase)
            _buildKriIndicatorsSection(data),
            
            const SizedBox(height: 32),
            
            // Section M-1.2: Grafik Tren KPI
            _buildTrendChartsSection(data),
          ],
        ),
      ),
    );
  }

  /// M-1.1: Section Indikator KRI
  Widget _buildKriIndicatorsSection(Map<String, dynamic> data) {
    final double kriLeadTimeAph = (data['kri_lead_time_aph'] ?? 0).toDouble();
    final double kriKepatuhanSop = (data['kri_kepatuhan_sop'] ?? 0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Risk Indicators (KRI)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // KRI 1: Lead Time APH
            Expanded(
              child: _buildKriCard(
                title: 'Lead Time APH',
                value: kriLeadTimeAph,
                unit: 'hari',
                target: 3.0, // Target maksimal 3 hari
                isPercentage: false,
                icon: Icons.timer,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            // KRI 2: Kepatuhan SOP (WAJIB TEPAT!)
            Expanded(
              child: _buildKriCard(
                title: 'Kepatuhan SOP',
                value: kriKepatuhanSop,
                unit: '%',
                target: 75.0, // Target minimal 75%
                isPercentage: true,
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card individual untuk KRI dengan CircularPercentIndicator
  Widget _buildKriCard({
    required String title,
    required double value,
    required String unit,
    required double target,
    required bool isPercentage,
    required IconData icon,
    required Color color,
  }) {
    // Hitung persentase untuk indicator
    // PRINSIP TEPAT: Perhitungan harus akurat!
    double percent;
    if (isPercentage) {
      // Untuk KRI Kepatuhan SOP: value sudah dalam bentuk persentase (0-100)
      // Target 75% = 100% di indicator kita
      percent = (value / target).clamp(0.0, 1.0);
    } else {
      // Untuk Lead Time APH: semakin rendah semakin baik
      // Jika value <= target, maka 100%
      // Jika value > target, maka kurangi persentase
      percent = (target / value).clamp(0.0, 1.0);
    }

    // Tentukan warna berdasarkan performa
    Color indicatorColor;
    if (percent >= 0.8) {
      indicatorColor = Colors.green;
    } else if (percent >= 0.6) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.red;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 10.0,
              percent: percent,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              progressColor: indicatorColor,
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            Text(
              'Target: ${target.toStringAsFixed(0)} $unit',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// M-1.2: Section Grafik Tren KPI
  Widget _buildTrendChartsSection(Map<String, dynamic> data) {
    // Handle tren_insidensi_baru (should be array)
    final List<dynamic> trenInsidensiBaruRaw = 
        data['tren_insidensi_baru'] is List 
            ? data['tren_insidensi_baru'] as List 
            : [];
    
    // Handle tren_g4_aktif (backend returns int, not array!)
    // CATATAN: Backend mengembalikan integer, bukan array
    // Kita perlu konversi ke format yang sesuai untuk chart
    final dynamic trenG4AktifData = data['tren_g4_aktif'];
    final List<dynamic> trenG4AktifRaw;
    
    if (trenG4AktifData is List) {
      // Jika backend mengembalikan array (expected format)
      trenG4AktifRaw = trenG4AktifData;
    } else if (trenG4AktifData is num) {
      // Jika backend mengembalikan number (actual format saat ini)
      // Convert ke array dengan 1 entry untuk hari ini
      trenG4AktifRaw = [
        {
          'date': DateTime.now().toString().substring(0, 10),
          'count': trenG4AktifData
        }
      ];
    } else {
      // Fallback ke empty array
      trenG4AktifRaw = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tren KPI (6 Bulan Terakhir)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Chart 1: Tren Insidensi Baru
        _buildTrendChartCard(
          title: 'Tren Insidensi Baru (Kasus G1)',
          data: trenInsidensiBaruRaw,
          color: Colors.orange,
          icon: Icons.trending_up,
        ),
        
        const SizedBox(height: 16),
        
        // Chart 2: Tren G4 Aktif
        _buildTrendChartCard(
          title: 'Tren Pohon Mati Aktif (G4)',
          data: trenG4AktifRaw,
          color: Colors.red,
          icon: Icons.trending_down,
        ),
      ],
    );
  }

  /// Card untuk Line Chart
  Widget _buildTrendChartCard({
    required String title,
    required List<dynamic> data,
    required Color color,
    required IconData icon,
  }) {
    // Parse data untuk chart
    final List<FlSpot> spots = _parseChartData(data);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: spots.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada data tren',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 1,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return bottomTitleWidgets(value, meta, data);
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: _calculateLeftInterval(spots),
                              reservedSize: 42,
                              getTitlesWidget: leftTitleWidgets,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        minX: 0,
                        maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 5,
                        minY: 0,
                        maxY: _calculateMaxY(spots),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: color,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: color,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse data array dari backend ke FlSpot untuk fl_chart
  /// PRINSIP TEPAT: Mapping data harus akurat!
  /// 
  /// Handles dua format dari backend:
  /// 1. {"periode": "2024-01", "nilai": 5} - Format lama
  /// 2. {"date": "2025-11-07", "count": 1} - Format actual dari backend
  List<FlSpot> _parseChartData(List<dynamic> data) {
    if (data.isEmpty) return [];

    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is Map<String, dynamic>) {
        // Try 'nilai' first (old format), then 'count' (new format)
        final double nilai = (item['nilai'] ?? item['count'] ?? 0).toDouble();
        spots.add(FlSpot(i.toDouble(), nilai));
      }
    }
    return spots;
  }

  /// Widget untuk label sumbu X (periode/bulan)
  Widget bottomTitleWidgets(double value, TitleMeta meta, List<dynamic> data) {
    const style = TextStyle(
      fontSize: 10,
      color: Colors.grey,
    );

    final int index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const Text('');
    }

    final item = data[index];
    String label = '';
    if (item is Map<String, dynamic>) {
      // Try 'periode' first (old format), then 'date' (new format)
      final String periodeOrDate = item['periode'] ?? item['date'] ?? '';
      
      if (periodeOrDate.isNotEmpty) {
        // Format: "2024-01" atau "2025-11-07"
        if (periodeOrDate.length >= 7) {
          final month = periodeOrDate.substring(5, 7);
          label = _getMonthAbbreviation(month);
        }
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(label, style: style),
    );
  }

  /// Widget untuk label sumbu Y (nilai)
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      color: Colors.grey,
    );
    return Text(value.toInt().toString(), style: style, textAlign: TextAlign.left);
  }

  /// Helper: Konversi bulan ke singkatan
  String _getMonthAbbreviation(String month) {
    const months = {
      '01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr',
      '05': 'Mei', '06': 'Jun', '07': 'Jul', '08': 'Agu',
      '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Des',
    };
    return months[month] ?? month;
  }

  /// Helper: Hitung max Y untuk chart agar tidak terlalu rapat
  double _calculateMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    
    final maxValue = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // Tambah 20% padding di atas
    return (maxValue * 1.2).ceilToDouble();
  }

  /// Helper: Hitung interval untuk sumbu Y
  double _calculateLeftInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    
    final maxY = _calculateMaxY(spots);
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    return (maxY / 5).ceilToDouble();
  }
}
