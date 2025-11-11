import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/dashboard_service.dart';
import '../models/lifecycle_data.dart';

/// Lifecycle Detail View - Multi-Phase Lifecycle Dashboard
/// Date: November 11, 2025
/// 
/// Route: /lifecycle/:phase_name
/// 
/// 5 Sections:
/// A. Phase Selector (Top Tabs) - 5 tabs with badges
/// B. Phase Info Card - nama_fase, age range, description
/// C. Summary Metrics - 4 KPI Cards
/// D. SPK Table - Expandable rows with execution details
/// E. Weekly Breakdown Chart - Line chart showing weekly data

class LifecycleDetailView extends StatefulWidget {
  final String initialPhase;
  final String? token;

  const LifecycleDetailView({
    super.key,
    this.initialPhase = 'Pembibitan',
    this.token,
  });

  @override
  State<LifecycleDetailView> createState() => _LifecycleDetailViewState();
}

class _LifecycleDetailViewState extends State<LifecycleDetailView> with SingleTickerProviderStateMixin {
  final DashboardService _service = DashboardService();
  
  late TabController _tabController;
  late String _selectedPhase;
  
  // 5 phases for tabs
  final List<String> _phases = ['Pembibitan', 'TBM', 'TM', 'Pemanenan', 'Replanting'];
  
  Future<PhaseDetail>? _phaseDetailFuture;
  Future<LifecycleOverview>? _overviewFuture; // For tab badges

  @override
  void initState() {
    super.initState();
    _selectedPhase = widget.initialPhase;
    
    // Initialize TabController
    final initialIndex = _phases.indexOf(_selectedPhase);
    _tabController = TabController(
      length: _phases.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
    
    // Add listener for tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedPhase = _phases[_tabController.index];
          _loadPhaseDetail();
        });
      }
    });
    
    // Load initial data
    _loadPhaseDetail();
    _loadOverview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPhaseDetail() {
    setState(() {
      _phaseDetailFuture = _service
          .fetchPhaseDetail(_selectedPhase)
          .then((data) => PhaseDetail.fromJson(data));
    });
  }

  void _loadOverview() {
    setState(() {
      _overviewFuture = _service
          .fetchLifecycleOverview()
          .then((data) => LifecycleOverview.fromJson(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifecycle Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: _buildPhaseSelector(),
        ),
      ),
      body: FutureBuilder<PhaseDetail>(
        future: _phaseDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading phase data...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadPhaseDetail,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final phaseDetail = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // B. Phase Info Card
                _buildPhaseInfoCard(context, phaseDetail.phaseInfo),
                const SizedBox(height: 24),
                
                // C. Summary Metrics (4 KPI Cards)
                _buildSummaryMetrics(context, phaseDetail.summary),
                const SizedBox(height: 32),
                
                // D. SPK Table (Expandable)
                _buildSPKTable(context, phaseDetail.spks),
                const SizedBox(height: 32),
                
                // E. Weekly Breakdown Chart
                if (phaseDetail.weeklyBreakdown.isNotEmpty)
                  _buildWeeklyChart(context, phaseDetail.weeklyBreakdown),
              ],
            ),
          );
        },
      ),
    );
  }

  /// A. Phase Selector (Top Tabs)
  Widget _buildPhaseSelector() {
    return FutureBuilder<LifecycleOverview>(
      future: _overviewFuture,
      builder: (context, snapshot) {
        final overview = snapshot.data;
        
        return Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.green.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.green.shade700,
            tabs: _phases.map((phase) {
              // Find phase data from overview
              final phaseData = overview?.phases.firstWhere(
                (p) => p.namaFase == phase,
                orElse: () => LifecyclePhase(
                  namaFase: phase,
                  totalSpks: 0,
                  totalExecutions: 0,
                  completionRate: 0,
                ),
              );
              
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(phase),
                    if (phaseData != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPhaseColor(phaseData.completionRate),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${phaseData.totalSpks} • ${phaseData.completionRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// B. Phase Info Card
  Widget _buildPhaseInfoCard(BuildContext context, PhaseInfo info) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getPhaseIcon(info.namaFase),
                size: 40,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.namaFase,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age Range: ${info.ageRange}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// C. Summary Metrics (4 KPI Cards)
  Widget _buildSummaryMetrics(BuildContext context, PhaseSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                icon: Icons.category,
                label: 'Sub Activities',
                value: summary.subActivitiesCount.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                icon: Icons.event_note,
                label: 'Schedules',
                value: summary.schedulesCount.toString(),
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                icon: Icons.assignment,
                label: 'SPKs',
                value: '${summary.selesaiSpks}/${summary.totalSpks}',
                color: Colors.orange,
                subtitle: '${summary.completionRate.toStringAsFixed(0)}% Complete',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                icon: Icons.check_circle,
                label: 'Executions',
                value: summary.totalExecutions.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// D. SPK Table (Expandable)
  Widget _buildSPKTable(BuildContext context, List<SPKLifecycle> spks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPK List (${spks.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (spks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No SPK available for this phase',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...spks.map((spk) => _buildSPKCard(context, spk)),
      ],
    );
  }

  Widget _buildSPKCard(BuildContext context, SPKLifecycle spk) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(
          spk.status == 'SELESAI' ? Icons.check_circle : Icons.pending,
          color: spk.status == 'SELESAI' ? Colors.green : Colors.orange,
          size: 32,
        ),
        title: Text(
          spk.nomorSpk,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${spk.lokasi} • ${spk.mandor}\n${spk.tanggal} • ${spk.executions.length} executions',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: spk.status == 'SELESAI' 
                ? Colors.green.withOpacity(0.2) 
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            spk.status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: spk.status == 'SELESAI' ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ),
        children: [
          if (spk.executions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No executions yet'),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Execution History:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...spk.executions.map((exec) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        exec.tanggal,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          exec.hasil,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Petugas: ${exec.petugas}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (exec.catatan != null && exec.catatan!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Note: ${exec.catatan}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// E. Weekly Breakdown Chart
  Widget _buildWeeklyChart(BuildContext context, List<WeeklyBreakdownLifecycle> weeklyData) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Activity Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= weeklyData.length) {
                            return const Text('');
                          }
                          final week = weeklyData[index].weekStart;
                          // Extract week number or format date
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              week.substring(5, 10), // MM-DD format
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
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
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    // Execution count line
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.executionCount.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.green.shade700,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.shade100.withOpacity(0.3),
                      ),
                    ),
                    // SPK count line
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.spkCount.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue.shade700,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.grey.shade800,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= weeklyData.length) {
                            return null;
                          }
                          final data = weeklyData[index];
                          final isExecution = spot.barIndex == 0;
                          return LineTooltipItem(
                            '${data.weekStart}\n${isExecution ? "Exec" : "SPK"}: ${spot.y.toInt()}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Executions', Colors.green.shade700),
                const SizedBox(width: 24),
                _buildLegendItem('SPKs', Colors.blue.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Helper methods
  Color _getPhaseColor(double completionRate) {
    if (completionRate >= 80) return Colors.green.shade700;
    if (completionRate >= 40) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  IconData _getPhaseIcon(String phaseName) {
    switch (phaseName) {
      case 'Pembibitan':
        return Icons.spa;
      case 'TBM':
        return Icons.park;
      case 'TM':
        return Icons.forest;
      case 'Pemanenan':
        return Icons.agriculture;
      case 'Replanting':
        return Icons.autorenew;
      default:
        return Icons.category;
    }
  }
}
