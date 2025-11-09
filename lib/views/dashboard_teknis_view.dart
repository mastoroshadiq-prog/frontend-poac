import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/dashboard_service.dart';

/// Dashboard Teknis View - Modul 3
/// 
/// Fitur:
/// - M-3.1: Matriks Kebingungan (Confusion Matrix) - Tabel 2x2
/// - M-3.2: Distribusi Status NDRE - Bar Chart
/// 
/// RBAC: Memerlukan JWT token dengan role MANDOR, ASISTEN, atau ADMIN
/// Prinsip MPP: SIMPLE, TEPAT, PENINGKATAN BERTAHAB
class DashboardTeknisView extends StatefulWidget {
  final String token;

  const DashboardTeknisView({
    super.key,
    required this.token,
  });

  @override
  State<DashboardTeknisView> createState() => _DashboardTeknisViewState();
}

class _DashboardTeknisViewState extends State<DashboardTeknisView> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load data dari API
  void _loadData() {
    setState(() {
      _dashboardData = _dashboardService.fetchDashboardTeknis(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Teknis'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data teknis...'),
                ],
              ),
            );
          }

          // Error state (termasuk 401/403 RBAC)
          if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            
            // Handle 401 Unauthorized
            if (errorMessage.contains('Silakan Login') || errorMessage.contains('401')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Silakan Login',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Token tidak valid atau sudah kadaluarsa (401)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }
            
            // Handle 403 Forbidden
            if (errorMessage.contains('Akses Ditolak') || errorMessage.contains('403')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Akses Ditolak',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anda tidak memiliki izin untuk mengakses data ini (403)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }
            
            // Other errors
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMessage.replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Success state - hasData
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final dataMatrix = data['data_matriks_kebingungan'] as Map<String, dynamic>;
            final dataDistribusi = data['data_distribusi_ndre'] as List<dynamic>;

            return RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // M-3.1: Matriks Kebingungan
                    _buildMatriksKebingungan(dataMatrix),
                    
                    const SizedBox(height: 24),
                    
                    // M-3.2: Distribusi NDRE
                    _buildDistribusiNDRE(dataDistribusi),
                  ],
                ),
              ),
            );
          }

          // Fallback (seharusnya tidak pernah sampai sini)
          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }

  /// M-3.1: Build Matriks Kebingungan (Confusion Matrix)
  /// 
  /// Menampilkan tabel 2x2 dengan 4 nilai:
  /// - True Positive (Prediksi: Positif, Aktual: Positif)
  /// - False Positive (Prediksi: Positif, Aktual: Negatif)
  /// - False Negative (Prediksi: Negatif, Aktual: Positif)
  /// - True Negative (Prediksi: Negatif, Aktual: Negatif)
  Widget _buildMatriksKebingungan(Map<String, dynamic> dataMatrix) {
    // Extract values dengan type casting yang aman
    final int truePositive = (dataMatrix['true_positive'] ?? 0) as int;
    final int falsePositive = (dataMatrix['false_positive'] ?? 0) as int;
    final int falseNegative = (dataMatrix['false_negative'] ?? 0) as int;
    final int trueNegative = (dataMatrix['true_negative'] ?? 0) as int;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Matriks Kebingungan Akurasi Drone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perbandingan prediksi drone vs validasi lapangan',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Tabel 2x2 Confusion Matrix
            Table(
              border: TableBorder.all(color: Colors.grey, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Aktual: Positif\n(G1/G3/G4)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Aktual: Negatif\n(G0)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                
                // Row 1: Prediksi Positif
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        'Prediksi:\nPositif',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildMatrixCell(
                      value: truePositive,
                      label: 'True Positive',
                      color: Colors.green[100]!,
                      isGood: true,
                    ),
                    _buildMatrixCell(
                      value: falsePositive,
                      label: 'False Positive',
                      color: Colors.orange[100]!,
                      isGood: false,
                    ),
                  ],
                ),
                
                // Row 2: Prediksi Negatif
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        'Prediksi:\nNegatif',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildMatrixCell(
                      value: falseNegative,
                      label: 'False Negative',
                      color: Colors.red[100]!,
                      isGood: false,
                    ),
                    _buildMatrixCell(
                      value: trueNegative,
                      label: 'True Negative',
                      color: Colors.green[100]!,
                      isGood: true,
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.green, 'Prediksi Benar'),
                _buildLegendItem(Colors.orange, 'False Positive'),
                _buildLegendItem(Colors.red, 'False Negative'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Build single cell in confusion matrix
  Widget _buildMatrixCell({
    required int value,
    required String label,
    required Color color,
    required bool isGood,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isGood ? Colors.green[900] : Colors.red[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Helper: Build legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// M-3.2: Build Distribusi Status NDRE (Bar Chart)
  /// 
  /// Menampilkan grafik batang distribusi status aktual dari validasi lapangan.
  /// X-Axis: Status (G0, G1, G3, G4)
  /// Y-Axis: Jumlah
  Widget _buildDistribusiNDRE(List<dynamic> dataDistribusi) {
    // Parse data menjadi List<BarChartGroupData>
    final List<BarChartGroupData> barGroups = [];
    final List<String> statusLabels = [];
    
    for (int i = 0; i < dataDistribusi.length; i++) {
      final item = dataDistribusi[i] as Map<String, dynamic>;
      final String statusAktual = item['status_aktual'] ?? '';
      final int jumlah = (item['jumlah'] ?? 0) as int;
      
      statusLabels.add(statusAktual);
      
      // Tentukan warna berdasarkan status
      Color barColor;
      switch (statusAktual) {
        case 'G0':
          barColor = Colors.green;
          break;
        case 'G1':
          barColor = Colors.orange;
          break;
        case 'G3':
          barColor = Colors.deepOrange;
          break;
        case 'G4':
          barColor = Colors.red;
          break;
        default:
          barColor = Colors.grey;
      }
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: jumlah.toDouble(),
              color: barColor,
              width: 40,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    // Hitung max Y untuk scaling chart
    final double maxY = dataDistribusi.isEmpty
        ? 100
        : dataDistribusi
            .map((item) => (item['jumlah'] ?? 0) as int)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Status Aktual (Validasi Lapangan)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hasil validasi lapangan per status Ganoderma',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Bar Chart
            SizedBox(
              height: 300,
              child: dataDistribusi.isEmpty
                  ? const Center(
                      child: Text('Tidak ada data distribusi'),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY * 1.2, // Tambah 20% padding atas
                        minY: 0,
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          show: true,
                          // Bottom titles (X-Axis: Status)
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < statusLabels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      statusLabels[value.toInt()],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          // Left titles (Y-Axis: Jumlah)
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          // Hide top and right titles
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxY / 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: Colors.grey[400]!),
                            bottom: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final status = statusLabels[group.x.toInt()];
                              final jumlah = rod.toY.toInt();
                              return BarTooltipItem(
                                '$status\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$jumlah pohon',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend untuk status Ganoderma
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildStatusLegend(Colors.green, 'G0', 'Sehat'),
                _buildStatusLegend(Colors.orange, 'G1', 'Awal'),
                _buildStatusLegend(Colors.deepOrange, 'G3', 'Parah'),
                _buildStatusLegend(Colors.red, 'G4', 'Mati'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Build status legend item
  Widget _buildStatusLegend(Color color, String status, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$status ($label)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
