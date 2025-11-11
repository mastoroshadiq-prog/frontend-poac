import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../services/dashboard_service.dart';
import '../models/panen_data.dart';
import '../widgets/lifecycle_overview_widget.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/stat_cards.dart';
import '../widgets/enhanced_data_table.dart';
import '../widgets/loading_states.dart';
import '../widgets/toast_helper.dart';

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
  
  // Pagination state untuk Papan Peringkat
  int _currentPage = 0;
  static const int _itemsPerPage = 5;
  
  // Sorting state untuk Papan Peringkat
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

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

  /// Export SPK data to CSV
  void _exportToCSV(PanenData panenData) {
    // Create CSV header
    final csvData = StringBuffer();
    csvData.writeln('No,Nomor SPK,Periode,Lokasi,Mandor,Total TBS (ton),Avg Reject (%),Executions,Status,Target Achieved');
    
    // Add SPK rows
    for (var i = 0; i < panenData.bySpk.length; i++) {
      final spk = panenData.bySpk[i];
      csvData.writeln('${i + 1},"${spk.nomorSpk}","${spk.periode}","${spk.lokasi}","${spk.mandor}",${spk.totalTon.toStringAsFixed(2)},${spk.avgReject.toStringAsFixed(2)},${spk.executions.length},"${spk.status}",${spk.isTargetAchieved ? "Yes" : "No"}');
    }
    
    // Create blob and download
    final bytes = utf8.encode(csvData.toString());
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'SPK_Panen_${DateTime.now().toString().substring(0, 10)}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${panenData.bySpk.length} SPK to CSV'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Dashboard Operasional',
      currentRoute: '/dashboard-operasional',
      breadcrumbs: const [
        BreadcrumbItem(label: 'Home'),
        BreadcrumbItem(label: 'Dashboard Operasional'),
      ],
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'Refresh Data',
        ),
      ],
      onNavigate: (route) {
        // Handle navigation with token
        final authToken = widget.token ?? _testToken;
        Navigator.of(context).pushNamed(
          route,
          arguments: {'token': authToken},
        );
      },
      child: FutureBuilder<Map<String, dynamic>>(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BARIS 1: Gauge Charts (Validasi, APH, Sanitasi)
                    _buildCorongSection(context, dataCorong),
                    
                    const SizedBox(height: 24),
                    
                    // BARIS 2: KPI Hasil PANEN
                    _buildKpiHasilPanenSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // BARIS 3: Papan Peringkat Tim
                    _buildPapanPeringkatSection(context, dataPeringkat),
                    
                    const SizedBox(height: 32),
                    
                    // Lifecycle Overview Widget
                    const LifecycleOverviewWidget(),
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
    final targetValidasi = (dataCorong['target_validasi'] ?? 1) as int;
    final aphSelesai = (dataCorong['aph_selesai'] ?? 0) as int;
    final targetAph = (dataCorong['target_aph'] ?? 1) as int;
    final sanitasiSelesai = (dataCorong['sanitasi_selesai'] ?? 0) as int;
    final targetSanitasi = (dataCorong['target_sanitasi'] ?? 1) as int;

    return Row(
      children: [
        // 1. Validasi Drone - Progress Card
        Expanded(
          child: ProgressStatCard(
            title: 'Validasi Drone',
            current: validasiSelesai,
            total: targetValidasi,
            icon: Icons.verified_outlined,
            color: Colors.blue,
            onTap: () => _showGaugeDetailDialog(
              context, 
              'Validasi Drone', 
              validasiSelesai, 
              targetValidasi, 
              Colors.blue
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // 2. APH - Progress Card
        Expanded(
          child: ProgressStatCard(
            title: 'APH',
            current: aphSelesai,
            total: targetAph,
            icon: Icons.eco_outlined,
            color: Colors.green,
            onTap: () => _showGaugeDetailDialog(
              context, 
              'APH', 
              aphSelesai, 
              targetAph, 
              Colors.green
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // 3. Sanitasi - Progress Card
        Expanded(
          child: ProgressStatCard(
            title: 'Sanitasi',
            current: sanitasiSelesai,
            total: targetSanitasi,
            icon: Icons.cleaning_services_outlined,
            color: Colors.orange,
            onTap: () => _showGaugeDetailDialog(
              context, 
              'Sanitasi', 
              sanitasiSelesai, 
              targetSanitasi, 
              Colors.orange
            ),
          ),
        ),
      ],
    );
  }

  /// Build Gauge Card untuk Validasi/APH/Sanitasi
  Widget _buildGaugeCard(
    BuildContext context, {
    required String title,
    required int selesai,
    required int target,
    required double percent,
    required Color color,
    required IconData icon,
  }) {
    final safePercent = (percent * 100).clamp(0.0, 100.0);
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Show drill-down popup
          _showGaugeDetailDialog(context, title, selesai, target, color);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Icon
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Pie Chart (Gauge) dengan percentage di tengah
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: 270,
                        sections: [
                          // Completed section
                          PieChartSectionData(
                            color: color,
                            value: safePercent,
                            title: '',
                            radius: 25,
                          ),
                          // Remaining section
                          PieChartSectionData(
                            color: Colors.grey[300],
                            value: 100 - safePercent,
                            title: '',
                            radius: 25,
                          ),
                        ],
                      ),
                    ),
                    // Percentage text di tengah
                    Text(
                      '${safePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Stats
              Text(
                '$selesai dari $target',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Selesai',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show drill-down detail dialog untuk gauge
  void _showGaugeDetailDialog(
    BuildContext context,
    String title,
    int selesai,
    int target,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Detail $title',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            selesai.toString(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const Text(
                            'Selesai',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Text(
                        'dari',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Column(
                        children: [
                          Text(
                            target.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'Target',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Breakdown
                Text(
                  'Rincian:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                
                // Selesai list
                _buildDetailItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  label: 'Tugas Selesai',
                  count: selesai,
                  subtitle: 'Sudah dikerjakan dan divalidasi',
                ),
                const SizedBox(height: 8),
                
                // Belum selesai list
                _buildDetailItem(
                  icon: Icons.pending,
                  iconColor: Colors.orange,
                  label: 'Tugas Belum Selesai',
                  count: target - selesai,
                  subtitle: 'Masih dalam proses atau menunggu',
                ),
                const SizedBox(height: 16),
                
                // Additional info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Klik "Lihat Detail" untuk melihat daftar lengkap tugas',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to detail page or show full list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Detail lengkap $title akan ditampilkan'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('Lihat Detail'),
            ),
          ],
        );
      },
    );
  }

  /// Helper untuk build detail item
  Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required int count,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build M-2.2: Papan Peringkat Tim (DataTable dengan Paging & Sort)
  Widget _buildPapanPeringkatSection(BuildContext context, List<dynamic> dataPeringkat) {
    // Sort data
    final sortedData = List<Map<String, dynamic>>.from(
      dataPeringkat.map((e) => e as Map<String, dynamic>)
    );
    
    sortedData.sort((a, b) {
      dynamic aValue, bValue;
      
      switch (_sortColumnIndex) {
        case 0: // Peringkat (index in original list)
          return 0; // Don't sort by peringkat, keep original order
        case 1: // Nama Pelaksana
          aValue = a['nama_pelaksana'] ?? a['id_pelaksana'] ?? '';
          bValue = b['nama_pelaksana'] ?? b['id_pelaksana'] ?? '';
          break;
        case 2: // Selesai
          aValue = a['selesai'] ?? 0;
          bValue = b['selesai'] ?? 0;
          break;
        case 3: // Rate
          aValue = a['rate'] ?? 0.0;
          bValue = b['rate'] ?? 0.0;
          break;
        default:
          return 0;
      }
      
      final comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });
    
    // Calculate pagination
    final totalItems = sortedData.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final paginatedData = sortedData.sublist(startIndex, endIndex);
    
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

            // Enhanced DataTable with search, filter, export
            if (dataPeringkat.isEmpty)
              const EmptyState(
                icon: Icons.leaderboard,
                title: 'Tidak ada data peringkat',
                subtitle: 'Belum ada data kinerja pelaksana',
              )
            else
              EnhancedDataTable(
                title: null, // Title sudah ada di atas
                columns: [
                  DataTableColumn(
                    label: 'Peringkat',
                    key: 'peringkat',
                    numeric: true,
                    builder: (value, row) {
                      final peringkat = value as int;
                      Color badgeColor;
                      if (peringkat == 1) badgeColor = Colors.amber;
                      else if (peringkat == 2) badgeColor = Colors.grey;
                      else if (peringkat == 3) badgeColor = Colors.brown.shade400;
                      else badgeColor = Colors.blue;
                      
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: badgeColor, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$peringkat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                  DataTableColumn(
                    label: 'Nama Pelaksana',
                    key: 'nama_pelaksana',
                    builder: (value, row) {
                      return Text(
                        value ?? row['id_pelaksana'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                  DataTableColumn(
                    label: 'Selesai',
                    key: 'selesai',
                    numeric: true,
                  ),
                  DataTableColumn(
                    label: 'Total',
                    key: 'total',
                    numeric: true,
                  ),
                  DataTableColumn(
                    label: 'Rate (%)',
                    key: 'rate',
                    numeric: true,
                    builder: (value, row) {
                      final rate = (value as num).toDouble();
                      Color rateColor;
                      if (rate >= 80) rateColor = Colors.green;
                      else if (rate >= 50) rateColor = Colors.orange;
                      else rateColor = Colors.red;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: rateColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: rateColor, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${rate.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: rateColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              rate >= 80 ? Icons.trending_up : 
                              rate >= 50 ? Icons.trending_flat : Icons.trending_down,
                              color: rateColor,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                rows: List.generate(dataPeringkat.length, (index) {
                  final item = dataPeringkat[index] as Map<String, dynamic>;
                  return {
                    'peringkat': index + 1,
                    'nama_pelaksana': item['nama_pelaksana'] ?? item['id_pelaksana'],
                    'selesai': item['selesai'] ?? 0,
                    'total': item['total'] ?? 0,
                    'rate': item['rate'] ?? 0.0,
                  };
                }),
                itemsPerPage: 10,
                showSearch: true,
                showExport: true,
                onRowTap: (row) {
                  ToastHelper.showInfo(
                    context,
                    '${row['nama_pelaksana']}: ${row['rate']}% completion rate',
                  );
                },
              ),
              Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      columnSpacing: 30,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn(
                          label: const Text(
                            'Peringkat',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: const Text(
                            'Nama Pelaksana',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: const Text(
                            'Selesai / Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          numeric: true,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: const Text(
                            'Rate (%)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          numeric: true,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        paginatedData.length,
                        (index) {
                          final item = paginatedData[index];
                          final peringkat = startIndex + index + 1;
                          final namaPelaksana = item['nama_pelaksana'] ?? item['id_pelaksana'] ?? '-';
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
                            color: WidgetStateProperty.resolveWith(
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
                                    if (peringkat <= 3) const SizedBox(width: 8),
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
                                  namaPelaksana.toString(),
                                  style: TextStyle(
                                    fontWeight: peringkat <= 3 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '$selesai / $total',
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, 
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: rate >= 80
                                        ? Colors.green.withOpacity(0.2)
                                        : rate >= 50
                                            ? Colors.orange.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${rate.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: rate >= 80
                                          ? Colors.green.shade700
                                          : rate >= 50
                                              ? Colors.orange.shade700
                                              : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Pagination Controls
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 0 
                              ? () => setState(() => _currentPage--) 
                              : null,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Halaman sebelumnya',
                          ),
                          Text(
                            'Halaman ${_currentPage + 1} dari $totalPages',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          IconButton(
                            onPressed: _currentPage < totalPages - 1 
                              ? () => setState(() => _currentPage++) 
                              : null,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Halaman berikutnya',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Build M-2.3: KPI Hasil PANEN (NEW Section)
  Widget _buildKpiHasilPanenSection(BuildContext context) {
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
                  Icons.agriculture,
                  color: Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'KPI Hasil PANEN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tracking hasil panen TBS (Tandan Buah Segar)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // FutureBuilder untuk data PANEN
            FutureBuilder<PanenData>(
              future: _dashboardService.fetchPanenData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonCard(height: 200);
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    title: 'Gagal memuat data PANEN',
                    subtitle: snapshot.error.toString().replaceAll('Exception: ', ''),
                    onRetry: _refreshData,
                  );
                }

                if (!snapshot.hasData) {
                  return const EmptyState(
                    icon: Icons.agriculture,
                    title: 'Tidak ada data PANEN',
                    subtitle: 'Data PANEN belum tersedia',
                  );
                }

                final PanenData panenData = snapshot.data!;
                return _buildPanenContent(context, panenData);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build content untuk PANEN section
  Widget _buildPanenContent(BuildContext context, PanenData panenData) {
    // Calculate trends from weekly data
    double? totalTbsTrend;
    double? avgRejectTrend;
    
    if (panenData.weeklyBreakdown.length >= 2) {
      // Compare last week vs previous week
      final lastWeek = panenData.weeklyBreakdown.last;
      final prevWeek = panenData.weeklyBreakdown[panenData.weeklyBreakdown.length - 2];
      
      if (prevWeek.totalTon > 0) {
        totalTbsTrend = ((lastWeek.totalTon - prevWeek.totalTon) / prevWeek.totalTon * 100);
      }
      
      if (prevWeek.avgReject > 0) {
        avgRejectTrend = ((lastWeek.avgReject - prevWeek.avgReject) / prevWeek.avgReject * 100);
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BARIS 1: 4 Kolom Summary Cards (Horizontal) - Using TrendStatCard
        Row(
          children: [
            Expanded(
              child: totalTbsTrend != null
                  ? TrendStatCard(
                      title: 'Total TBS',
                      value: '${panenData.summary.totalTonTbs.toStringAsFixed(1)} ton',
                      trendPercentage: totalTbsTrend,
                      trendLabel: 'vs last week',
                      icon: Icons.scale,
                      color: Colors.green,
                    )
                  : StatCard(
                      title: 'Total TBS',
                      value: '${panenData.summary.totalTonTbs.toStringAsFixed(1)} ton',
                      icon: Icons.scale,
                      color: Colors.green,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: avgRejectTrend != null
                  ? TrendStatCard(
                      title: 'Avg Reject',
                      value: '${panenData.summary.avgRejectPersen.toStringAsFixed(2)}%',
                      trendPercentage: avgRejectTrend,
                      trendLabel: 'vs last week',
                      icon: Icons.warning_amber,
                      color: panenData.summary.avgRejectPersen < 3.0 
                        ? Colors.green 
                        : Colors.orange,
                    )
                  : StatCard(
                      title: 'Avg Reject',
                      value: '${panenData.summary.avgRejectPersen.toStringAsFixed(2)}%',
                      icon: Icons.warning_amber,
                      color: panenData.summary.avgRejectPersen < 3.0 
                        ? Colors.green 
                        : Colors.orange,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Total SPK',
                value: panenData.summary.totalSpk.toString(),
                icon: Icons.assignment,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Executions',
                value: panenData.summary.totalExecutions.toString(),
                icon: Icons.event_available,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // BARIS 2: Daftar SPK Panen (Full Width) with Export Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar SPK Panen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () => _exportToCSV(panenData),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (panenData.bySpk.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Belum ada SPK'),
          ))
        else
          ...panenData.bySpk.map((spk) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(
                  spk.isTargetAchieved ? Icons.check_circle : Icons.warning,
                  color: spk.isTargetAchieved ? Colors.green : Colors.orange,
                  size: 32,
                ),
                title: Text(
                  spk.nomorSpk,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${spk.lokasi} • ${spk.mandor}\n${spk.totalTon.toStringAsFixed(1)} ton • ${spk.avgReject.toStringAsFixed(2)}% reject',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: spk.status == 'SELESAI' 
                      ? Colors.green.withOpacity(0.2) 
                      : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    spk.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: spk.status == 'SELESAI' ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Periode', spk.periode),
                        const SizedBox(height: 8),
                        _buildInfoRow('Total Eksekusi', '${spk.executionCount} events'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Quality', spk.qualityStatus),
                        const Divider(height: 24),
                        
                        // Execution Timeline
                        Text(
                          'Timeline Eksekusi:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        
                        ...spk.executions.map((exec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: exec.rejectPersen < 3.0 
                                    ? Colors.green 
                                    : Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exec.tanggal,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${exec.tonTbs.toStringAsFixed(1)} ton • ${exec.rejectPersen.toStringAsFixed(2)}% reject',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      Text(
                                        exec.petugas,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        
        // === ANALYTICS SECTION ===
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 32),
        
        // Weekly Trend Chart
        _buildWeeklyTrendChart(context, panenData),
        
        const SizedBox(height: 32),
        
        // Row dengan 2 charts: Mandor Performance & Afdeling Productivity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mandor Performance Comparison
            Expanded(
              child: _buildMandorPerformanceChart(context, panenData),
            ),
            const SizedBox(width: 24),
            // Afdeling Productivity
            Expanded(
              child: _buildAfdelingProductivityBars(context, panenData),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? trendText,
    bool? trendPositive,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          // Trend indicator
          if (trendText != null && trendPositive != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trendPositive 
                    ? Colors.green.withOpacity(0.15) 
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trendPositive ? Icons.trending_up : Icons.trending_down,
                    color: trendPositive ? Colors.green.shade700 : Colors.red.shade700,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trendPositive ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Build Weekly Trend Chart (Bar + Line Combination)
  Widget _buildWeeklyTrendChart(BuildContext context, PanenData panenData) {
    if (panenData.weeklyBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Tren Mingguan (TBS & Reject Rate)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: panenData.weeklyBreakdown.map((w) => w.totalTon).reduce((a, b) => a > b ? a : b) * 1.2,
                  barGroups: panenData.weeklyBreakdown.asMap().entries.map((entry) {
                    final index = entry.key;
                    final week = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: week.totalTon,
                          color: Colors.blue.shade400,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < panenData.weeklyBreakdown.length) {
                            final week = panenData.weeklyBreakdown[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                week.weekStart.substring(5), // Show MM-DD
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}t',
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue.shade400, 'Total TBS (ton)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build Mandor Performance Comparison Chart
  Widget _buildMandorPerformanceChart(BuildContext context, PanenData panenData) {
    // Group by mandor
    final mandorStats = <String, _MandorStat>{};
    for (var spk in panenData.bySpk) {
      final mandor = spk.mandor;
      if (!mandorStats.containsKey(mandor)) {
        mandorStats[mandor] = _MandorStat(name: mandor, totalTon: 0, totalReject: 0, count: 0);
      }
      mandorStats[mandor]!.totalTon += spk.totalTon;
      mandorStats[mandor]!.totalReject += spk.avgReject;
      mandorStats[mandor]!.count++;
    }

    final mandorList = mandorStats.values.map((m) {
      return _MandorStat(
        name: m.name,
        totalTon: m.totalTon,
        totalReject: m.totalReject / m.count, // Average
        count: m.count,
      );
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Performa Mandor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bars
            ...mandorList.map((mandor) {
              final maxTon = mandorList.map((m) => m.totalTon).reduce((a, b) => a > b ? a : b);
              final percentage = (mandor.totalTon / maxTon * 100);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            mandor.name.split(' - ').last, // Ambil nama saja
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${mandor.totalTon.toStringAsFixed(1)} ton',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 20,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Avg Reject: ${mandor.totalReject.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: mandor.totalReject < 3 ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Build Afdeling Productivity Bars
  Widget _buildAfdelingProductivityBars(BuildContext context, PanenData panenData) {
    // Extract afdeling from lokasi
    final afdelingStats = <String, double>{};
    for (var spk in panenData.bySpk) {
      final match = RegExp(r'Afdeling (\d+)').firstMatch(spk.lokasi);
      final afdeling = match != null ? 'Afdeling ${match.group(1)}' : spk.lokasi;
      afdelingStats[afdeling] = (afdelingStats[afdeling] ?? 0) + spk.totalTon;
    }

    final totalTon = panenData.summary.totalTonTbs;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.purple.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Produktivitas Afdeling',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bars
            ...afdelingStats.entries.map((entry) {
              final afdeling = entry.key;
              final ton = entry.value;
              final percentage = (ton / totalTon * 100);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          afdeling,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${ton.toStringAsFixed(1)} ton',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 20,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(Colors.purple.shade400),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Helper untuk legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

/// Helper class untuk Mandor statistics
class _MandorStat {
  final String name;
  double totalTon;
  double totalReject;
  int count;

  _MandorStat({
    required this.name,
    required this.totalTon,
    required this.totalReject,
    required this.count,
  });
}
