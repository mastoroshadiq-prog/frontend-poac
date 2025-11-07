import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/dashboard_service.dart';

/// Dashboard Operasional View - Modul 2 (RBAC Enabled)
/// Menampilkan Data Operasional (M-2.1 & M-2.2)
/// 
/// Fitur:
/// - M-2.1: Corong Alur Kerja (3 Progress Bar Linear)
/// - M-2.2: Papan Peringkat Tim (DataTable)
/// 
/// RBAC: View ini memerlukan JWT token dengan role MANDOR, ASISTEN, atau ADMIN
class DashboardOperasionalView extends StatefulWidget {
  /// JWT Token untuk autentikasi
  /// Untuk testing, bisa hardcode token dari generate-token-only.js
  /// Untuk production, token akan datang dari login/auth provider
  final String? token;

  const DashboardOperasionalView({
    super.key,
    this.token,
  });

  @override
  State<DashboardOperasionalView> createState() => _DashboardOperasionalViewState();
}

class _DashboardOperasionalViewState extends State<DashboardOperasionalView> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>> _operasionalDataFuture;

  // Token untuk TESTING - Role ASISTEN (memiliki akses ke dashboard operasional)
  // TODO: Ganti dengan token dari auth provider di production
  static const String _testToken = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6ImEwZWViYzk5LTljMGItNGVmOC1iYjZkLTZiYjliZDM4MGExMiIsIm5hbWFfcGloYWsiOiJBc2lzdGVuIENpdHJhIiwicm9sZSI6IkFTSVNURU4iLCJpYXQiOjE3NjI0OTc4NTEsImV4cCI6MTc2MzEwMjY1MX0.P3LEHAjj0iVrc_RtOqYfYsBK8k9RS5ZYfmyQKMiPgQc';

  @override
  void initState() {
    super.initState();
    // Load data operasional saat widget pertama kali dibuat
    // Gunakan token dari widget parameter atau fallback ke test token
    final authToken = widget.token ?? _testToken;
    _operasionalDataFuture = _dashboardService.fetchDashboardOperasional(authToken);
  }

  /// Refresh data operasional (bisa dipanggil dari pull-to-refresh)
  void _refreshData() {
    setState(() {
      final authToken = widget.token ?? _testToken;
      _operasionalDataFuture = _dashboardService.fetchDashboardOperasional(authToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Operasional'),
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
        future: _operasionalDataFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data operasional...'),
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
                      size: 64,
                      color: errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage.replaceAll('Exception: ', ''),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
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

          // Success state - render UI
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final dataCorong = data['data_corong'] as Map<String, dynamic>;
            final dataPeringkat = data['data_papan_peringkat'] as List<dynamic>;

            return RefreshIndicator(
              onRefresh: () async {
                _refreshData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // M-2.1: Corong Alur Kerja
                    _buildCorongSection(context, dataCorong),
                    
                    const SizedBox(height: 32),
                    
                    // M-2.2: Papan Peringkat Tim
                    _buildPapanPeringkatSection(context, dataPeringkat),
                  ],
                ),
              ),
            );
          }

          // Fallback (seharusnya tidak pernah terjadi)
          return const Center(
            child: Text('Tidak ada data'),
          );
        },
      ),
    );
  }

  /// Build M-2.1: Corong Alur Kerja (3 Progress Bars)
  Widget _buildCorongSection(BuildContext context, Map<String, dynamic> dataCorong) {
    // Extract data dengan safety check
    final validasiSelesai = (dataCorong['validasi_selesai'] ?? 0) as int;
    final targetValidasi = (dataCorong['target_validasi'] ?? 1) as int; // Avoid division by zero
    final aphSelesai = (dataCorong['aph_selesai'] ?? 0) as int;
    final targetAph = (dataCorong['target_aph'] ?? 1) as int;
    final sanitasiSelesai = (dataCorong['sanitasi_selesai'] ?? 0) as int;
    final targetSanitasi = (dataCorong['target_sanitasi'] ?? 1) as int;

    // Calculate percentages (safe division)
    final percentValidasi = targetValidasi > 0 ? validasiSelesai / targetValidasi : 0.0;
    final percentAph = targetAph > 0 ? aphSelesai / targetAph : 0.0;
    final percentSanitasi = targetSanitasi > 0 ? sanitasiSelesai / targetSanitasi : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Corong Alur Kerja',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Progress penyelesaian tahapan kerja',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // 1. Progress Validasi
            _buildLinearProgress(
              context,
              label: 'Validasi',
              selesai: validasiSelesai,
              target: targetValidasi,
              percent: percentValidasi,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),

            // 2. Progress APH (Aplikasi Pupuk Hayati)
            _buildLinearProgress(
              context,
              label: 'APH',
              selesai: aphSelesai,
              target: targetAph,
              percent: percentAph,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            // 3. Progress Sanitasi
            _buildLinearProgress(
              context,
              label: 'Sanitasi',
              selesai: sanitasiSelesai,
              target: targetSanitasi,
              percent: percentSanitasi,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper untuk membuat Linear Progress Indicator dengan label
  Widget _buildLinearProgress(
    BuildContext context, {
    required String label,
    required int selesai,
    required int target,
    required double percent,
    required Color color,
  }) {
    // Clamp percent between 0.0 and 1.0
    final safePercent = percent.clamp(0.0, 1.0);
    final percentageText = (safePercent * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label dan angka
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '$selesai dari $target Selesai',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Linear Progress Bar
        LinearPercentIndicator(
          lineHeight: 20.0,
          percent: safePercent,
          center: Text(
            '$percentageText%',
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.grey[200],
          progressColor: color,
          barRadius: const Radius.circular(10),
          animation: true,
          animationDuration: 800,
        ),
      ],
    );
  }

  /// Build M-2.2: Papan Peringkat Tim (DataTable)
  Widget _buildPapanPeringkatSection(BuildContext context, List<dynamic> dataPeringkat) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Papan Peringkat Tim',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ranking kinerja pelaksana berdasarkan tingkat penyelesaian',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // DataTable
            if (dataPeringkat.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Tidak ada data peringkat'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Peringkat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ID Pelaksana',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Selesai / Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Rate (%)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    dataPeringkat.length,
                    (index) {
                      final item = dataPeringkat[index] as Map<String, dynamic>;
                      final peringkat = index + 1;
                      final idPelaksana = item['id_pelaksana'] ?? '-';
                      final selesai = item['selesai'] ?? 0;
                      final total = item['total'] ?? 0;
                      final rate = (item['rate'] ?? 0.0) as num;

                      // Highlight top 3
                      Color? rowColor;
                      if (peringkat == 1) {
                        rowColor = Colors.amber[100]; // Gold
                      } else if (peringkat == 2) {
                        rowColor = Colors.grey[300]; // Silver
                      } else if (peringkat == 3) {
                        rowColor = Colors.orange[100]; // Bronze
                      }

                      return DataRow(
                        color: MaterialStateProperty.resolveWith(
                          (states) => rowColor,
                        ),
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Medal icon for top 3
                                if (peringkat <= 3)
                                  Icon(
                                    Icons.emoji_events,
                                    size: 20,
                                    color: peringkat == 1
                                        ? Colors.amber[700]
                                        : peringkat == 2
                                            ? Colors.grey[700]
                                            : Colors.orange[700],
                                  ),
                                if (peringkat <= 3) const SizedBox(width: 6),
                                Text(
                                  '#$peringkat',
                                  style: TextStyle(
                                    fontWeight: peringkat <= 3
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              idPelaksana.toString(),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          DataCell(
                            Text('$selesai / $total'),
                          ),
                          DataCell(
                            Text(
                              '${rate.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: rate >= 80
                                    ? Colors.green[700]
                                    : rate >= 50
                                        ? Colors.orange[700]
                                        : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
