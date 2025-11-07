import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/dashboard_service.dart';

/// Dashboard Eksekutif View - Modul 1 (RBAC Enabled)
/// Menampilkan KPI Eksekutif (M-1.1 & M-1.2)
/// 
/// Fitur:
/// - M-1.1: Lampu KRI (2 Indikator Persentase Circular)
/// - M-1.2: Grafik Tren KPI (2 Line Charts)
/// 
/// RBAC FASE 2: View ini sekarang memerlukan JWT token untuk autentikasi
class DashboardEksekutifView extends StatefulWidget {
  /// JWT Token untuk autentikasi
  /// Untuk testing, bisa hardcode token dari generate-token-only.js
  /// Untuk production, token akan datang dari login/auth provider
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
  late Future<Map<String, dynamic>> _kpiDataFuture;

  // TODO: Ganti dengan token dari auth provider di production
  // Token ini adalah contoh dari generate-token-only.js untuk role ASISTEN
  // Token ini hanya untuk TESTING
  static const String _testToken = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6ImEwZWViYzk5LTljMGItNGVmOC1iYjZkLTZiYjliZDM4MGExMiIsIm5hbWFfcGloYWsiOiJBc2lzdGVuIENpdHJhIiwicm9sZSI6IkFTSVNURU4iLCJpYXQiOjE3NjI0OTc4NTEsImV4cCI6MTc2MzEwMjY1MX0.P3LEHAjj0iVrc_RtOqYfYsBK8k9RS5ZYfmyQKMiPgQc';

  @override
  void initState() {
    super.initState();
    // Load data KPI saat widget pertama kali dibuat
    // Gunakan token dari widget parameter atau fallback ke test token
    final authToken = widget.token ?? _testToken;
    _kpiDataFuture = _dashboardService.fetchKpiEksekutif(authToken);
  }

  /// Refresh data KPI (bisa dipanggil dari pull-to-refresh)
  void _refreshData() {
    setState(() {
      final authToken = widget.token ?? _testToken;
      _kpiDataFuture = _dashboardService.fetchKpiEksekutif(authToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Eksekutif'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _kpiDataFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data KPI...'),
                ],
              ),
            );
          }

          // Error state (ENHANCED untuk RBAC)
          if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            
            // Detect authentication/authorization errors
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

          // Success state - Render data
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Tidak ada data'),
            );
          }

          final data = snapshot.data!;
          return _buildDashboardContent(data);
        },
      ),
    );
  }

  /// Build konten dashboard dengan data KPI
  Widget _buildDashboardContent(Map<String, dynamic> data) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        // Tunggu future selesai
        await _kpiDataFuture;
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
