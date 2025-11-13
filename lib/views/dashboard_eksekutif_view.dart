import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/dashboard_service.dart';
import '../models/eksekutif_poac_data.dart';
import '../widgets/stat_cards.dart';

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

  const DashboardEksekutifView({super.key, this.token});

  @override
  State<DashboardEksekutifView> createState() => _DashboardEksekutifViewState();
}

class _DashboardEksekutifViewState extends State<DashboardEksekutifView>
    with SingleTickerProviderStateMixin {
  final DashboardService _dashboardService = DashboardService();
  late Future<EksekutifPOACData> _poacDataFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController for 4 POAC tabs
    _tabController = TabController(length: 4, vsync: this);
    // Load data POAC gabungan saat widget pertama kali dibuat
    _poacDataFuture = _dashboardService.fetchEksekutifPOACData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.flag), text: 'PLAN'),
            Tab(icon: Icon(Icons.work), text: 'ORGANIZE'),
            Tab(icon: Icon(Icons.people), text: 'ACTUATE'),
            Tab(icon: Icon(Icons.analytics), text: 'CONTROL'),
          ],
        ),
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

            if (errorMessage.contains('Silakan Login') ||
                errorMessage.contains('401')) {
              errorIcon = Icons.lock_outline;
              errorColor = Colors.orange;
              errorTitle = 'Silakan Login';
            } else if (errorMessage.contains('Akses Ditolak') ||
                errorMessage.contains('403')) {
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
                    Icon(errorIcon, color: errorColor, size: 64),
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
            return const Center(child: Text('Tidak ada data'));
          }

          final poacData = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTabPlan(poacData),
              _buildTabOrganize(poacData),
              _buildTabActuate(poacData),
              _buildTabControl(poacData),
            ],
          );
        },
      ),
    );
  }

  /// TAB 1: PLAN - Target & Progress (Full Screen)
  Widget _buildTabPlan(EksekutifPOACData poacData) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await _poacDataFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: _buildKuadranPlan(poacData),
      ),
    );
  }

  /// TAB 2: ORGANIZE - Resources & Distribution (Full Screen)
  Widget _buildTabOrganize(EksekutifPOACData poacData) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await _poacDataFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: _buildKuadranOrganize(poacData),
      ),
    );
  }

  /// TAB 3: ACTUATE - Execution & Performance (Full Screen)
  Widget _buildTabActuate(EksekutifPOACData poacData) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await _poacDataFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: _buildKuadranActuate(poacData),
      ),
    );
  }

  /// TAB 4: CONTROL - Monitoring & Compliance (Full Screen)
  Widget _buildTabControl(EksekutifPOACData poacData) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await _poacDataFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: _buildKuadranControl(poacData),
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
    final overallProgress = totalTarget > 0
        ? (totalSelesai / totalTarget * 100)
        : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material 3 Header dengan AnimatedContainer
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'P (PLAN) - Target & Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content dengan Padding
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MODERN 2-COLUMN LAYOUT: SOP Gauge (Left) | Trend Chart (Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: SOP Compliance Gauge with Target & Gap
                      Expanded(
                        flex: 5,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                            children: [
                              // Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.verified_user,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Kepatuhan SOP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Circular Gauge - Interactive with Drill-Down
                              InkWell(
                                onTap: () => _showSopComplianceDetail(
                                  context,
                                  kepatuhanSop,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                child: Tooltip(
                                  message: 'Tap untuk melihat detail',
                                  child: CircularPercentIndicator(
                                    radius: 70.0,
                                    lineWidth: 14.0,
                                    percent: kepatuhanSop / 100.0,
                                    center: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${kepatuhanSop.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                            color: kepatuhanSop >= targetSop
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                          ),
                                        ),
                                        Text(
                                          'Compliance',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Icon(
                                          Icons.touch_app,
                                          size: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                    progressColor: kepatuhanSop >= targetSop
                                        ? Colors.green.shade400
                                        : Colors.orange.shade400,
                                    backgroundColor: Colors.grey.shade200,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    animation: true,
                                    animationDuration: 1200,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Target Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Target: ${targetSop.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Gap Indicator with Modern Design
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: kepatuhanSop >= targetSop
                                        ? [
                                            Colors.green.shade400,
                                            Colors.green.shade600,
                                          ]
                                        : [
                                            Colors.red.shade400,
                                            Colors.red.shade600,
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (kepatuhanSop >= targetSop
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      kepatuhanSop >= targetSop
                                          ? Icons.check_circle
                                          : Icons.warning_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Gap: ${(kepatuhanSop - targetSop >= 0 ? "+" : "")}${(kepatuhanSop - targetSop).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Velocity & ETA (if available)
                              if (poacData.trenKepatuhanSop.length >= 2) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            poacData.sopVelocity >= 0
                                                ? Icons.trending_up
                                                : Icons.trending_down,
                                            size: 16,
                                            color: poacData.sopVelocity >= 0
                                                ? Colors.green.shade600
                                                : Colors.red.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${poacData.sopVelocity >= 0 ? "+" : ""}${poacData.sopVelocity.toStringAsFixed(1)}% per week',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: poacData.sopVelocity >= 0
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (poacData.weeksToTarget90 != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'ETA: ~${poacData.weeksToTarget90} weeks to 90%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // RIGHT COLUMN: SOP Trend Chart
                      Expanded(
                        flex: 7,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.show_chart,
                                      color: Colors.purple.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'SOP Trend (${poacData.trenKepatuhanSop.length} Week${poacData.trenKepatuhanSop.length > 1 ? "s" : ""})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Trend Chart with Fixed Height
                              if (poacData.trenKepatuhanSop.isNotEmpty)
                                SizedBox(
                                  height: 250,
                                  child: _buildModernSopTrendChart(
                                    poacData.trenKepatuhanSop,
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 250,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.insert_chart_outlined,
                                          size: 48,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No trend data available',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Planning Execution Section
                  const Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 16,
                        color: Colors.black87,
                      ),
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

                  // Progress Cards (Modern FASE 2 Components)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ProgressStatCard(
                          title: 'Validasi',
                          current: selesaiVal,
                          total: targetVal,
                          icon: Icons.fact_check,
                          color: Colors.blue,
                          onTap: () => _showPlanningDetail(context, 'Validasi', selesaiVal, targetVal, Colors.blue, poacData.deadlineValidasi, poacData.riskLevelValidasi, poacData.blockersValidasi, ['Team ${poacData.pelaksanaAssignedValidasi}']),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProgressStatCard(
                          title: 'APH',
                          current: selesaiAph,
                          total: targetAph,
                          icon: Icons.health_and_safety,
                          color: Colors.green,
                          onTap: () => _showPlanningDetail(context, 'APH', selesaiAph, targetAph, Colors.green, poacData.deadlineAph, poacData.riskLevelAph, poacData.blockersAph, ['Team ${poacData.pelaksanaAssignedAph}']),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProgressStatCard(
                          title: 'Sanitasi',
                          current: selesaiSan,
                          total: targetSan,
                          icon: Icons.cleaning_services,
                          color: Colors.purple,
                          onTap: () => _showPlanningDetail(context, 'Sanitasi', selesaiSan, targetSan, Colors.purple, poacData.deadlineSanitasi, poacData.riskLevelSanitasi, poacData.blockersSanitasi, ['Team ${poacData.pelaksanaAssignedSanitasi}']),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Summary Cards (Modern FASE 2 Components)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CompactStatCard(label: 'Total', value: totalTarget.toString(), icon: Icons.list_alt, color: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CompactStatCard(label: 'Done', value: totalSelesai.toString(), icon: Icons.check_circle, color: Colors.green),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CompactStatCard(label: 'Progress', value: '${overallProgress.toStringAsFixed(0)}%', icon: Icons.trending_up, color: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Build Enhanced Planning Progress Row (with Deadline, Risk, Blockers)
  Widget _buildEnhancedProgressRow(
    String label,
    int selesai,
    int target,
    Color color,
    DateTime? deadline,
    String riskLevel,
    List<String> blockers,
    int pelaksanaAssigned,
  ) {
    final percent = target > 0 ? selesai / target : 0.0;
    final percentText = (percent * 100).toStringAsFixed(0);

    // Get risk color and icon
    final riskColor = _getRiskColor(riskLevel);
    final riskIcon = _getRiskIcon(riskLevel);

    // Calculate days until deadline
    final daysLeft = deadline?.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Label, Progress %, Risk Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(riskIcon, size: 14, color: riskColor),
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
              Row(
                children: [
                  Text(
                    '$percentText% ($selesai/$target)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      riskLevel,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),

          // Row 3: Deadline & Worker Info (if available)
          if (deadline != null || pelaksanaAssigned > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                // Deadline info
                if (deadline != null) ...[
                  Icon(
                    daysLeft! < 0 ? Icons.alarm : Icons.calendar_today,
                    size: 10,
                    color: daysLeft < 0
                        ? Colors.red
                        : (daysLeft < 7 ? Colors.orange : Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysLeft < 0
                        ? 'OVERDUE ${-daysLeft}d'
                        : '$daysLeft days left',
                    style: TextStyle(
                      fontSize: 9,
                      color: daysLeft < 0
                          ? Colors.red
                          : (daysLeft < 7
                                ? Colors.orange
                                : Colors.grey.shade600),
                      fontWeight: daysLeft < 7
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
                if (deadline != null && pelaksanaAssigned > 0)
                  const SizedBox(width: 8),
                // Worker info
                if (pelaksanaAssigned > 0) ...[
                  Icon(Icons.people, size: 10, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '$pelaksanaAssigned workers',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ],

          // Row 4: Blockers (if any)
          if (blockers.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 12,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Blockers:',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...blockers.map(
                    (blocker) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              blocker,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  /// Helper: Build Circular Progress Gauge (Modern Material 3 Design)
  Widget _buildCircularProgressGauge(
    String label,
    int selesai,
    int target,
    Color baseColor,
    DateTime? deadline,
    String riskLevel,
    List<String> blockers,
    int pelaksanaAssigned,
  ) {
    final progress = target > 0 ? (selesai / target) : 0.0;
    final percentage = (progress * 100).clamp(0, 100);

    // Get gradient colors based on label
    List<Color> gradientColors;
    if (label.contains('Validasi')) {
      gradientColors = [Colors.blue.shade50, Colors.white];
    } else if (label.contains('APH')) {
      gradientColors = [Colors.green.shade50, Colors.white];
    } else {
      gradientColors = [Colors.deepPurple.shade50, Colors.white];
    }

    return InkWell(
      onTap: () {
        _showPlanningDetail(
          context,
          label,
          selesai,
          target,
          baseColor,
          deadline,
          riskLevel,
          blockers,
          ['Team Member $pelaksanaAssigned'], // Convert int to list for demo
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              offset: const Offset(-5, -5),
            ),
          ],
          border: Border.all(color: baseColor.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      label.contains('Validasi')
                          ? Icons.fact_check
                          : label.contains('APH')
                          ? Icons.health_and_safety
                          : Icons.cleaning_services,
                      color: baseColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Circular Gauge with Modern Styling
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow effect
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          baseColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Main gauge
                  CircularPercentIndicator(
                    radius: 55.0,
                    lineWidth: 11.0,
                    percent: progress.clamp(0.0, 1.0),
                    center: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: progress >= 0.8
                                  ? Colors.green.shade700
                                  : progress >= 0.5
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$selesai/$target',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    progressColor: progress >= 0.8
                        ? Colors.green.shade400
                        : progress >= 0.5
                        ? Colors.orange.shade400
                        : Colors.red.shade400,
                    backgroundColor: Colors.grey.shade200,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1000,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Info Section with Cards
              Column(
                children: [
                  // Risk Badge (Modern Chip Style)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getRiskColor(riskLevel).withOpacity(0.2),
                          _getRiskColor(riskLevel).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getRiskColor(riskLevel).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRiskIcon(riskLevel),
                          size: 14,
                          color: _getRiskColor(riskLevel),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          riskLevel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(riskLevel),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Deadline & Workers Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Deadline
                        if (deadline != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _formatDeadline(deadline),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Workers
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.groups,
                              size: 14,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$pelaksanaAssigned Workers',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Blockers Alert
                  if (blockers.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${blockers.length} Blocker${blockers.length > 1 ? "s" : ""}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper: Format deadline for display
  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue ${-difference}d';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in ${difference}d';
    }
  }

  /// Helper: Get risk color from risk level string
  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
      default:
        return Colors.green;
    }
  }

  /// Helper: Get risk icon from risk level string
  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return Icons.error;
      case 'MEDIUM':
        return Icons.warning_amber_rounded;
      case 'LOW':
      default:
        return Icons.check_circle;
    }
  }

  /// Helper: Build Modern SOP Trend Chart (2-Column Layout Version)
  Widget _buildModernSopTrendChart(List<Map<String, dynamic>> trenData) {
    if (trenData.isEmpty) return const SizedBox.shrink();

    final spots = trenData.asMap().entries.map((entry) {
      final nilai = (entry.value['nilai'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(entry.key.toDouble(), nilai);
    }).toList();

    // Calculate min/max for better scaling
    final values = spots.map((s) => s.y).toList();
    final minValue = values.isNotEmpty
        ? values.reduce((a, b) => a < b ? a : b)
        : 0.0;
    final maxValue = values.isNotEmpty
        ? values.reduce((a, b) => a > b ? a : b)
        : 100.0;
    final padding = (maxValue - minValue) * 0.15; // 15% padding

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.purple.shade100,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.purple.shade50, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < trenData.length) {
                  final periode = trenData[index]['periode'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      periode.toString().replaceAll('Week ', 'W'),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.purple.shade200, width: 1.5),
        ),
        minX: 0,
        maxX: (trenData.length - 1).toDouble(),
        minY: (minValue - padding).clamp(0, double.infinity),
        maxY: (maxValue + padding).clamp(0, 100),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: Colors.purple.shade600,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade200.withOpacity(0.4),
                  Colors.purple.shade100.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot spot) => Colors.purple.shade700,
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toStringAsFixed(1)}%',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  /// Helper: Build SOP Trend Sparkline Chart
  Widget _buildSopTrendSparkline(List<Map<String, dynamic>> trenData) {
    if (trenData.isEmpty) return const SizedBox.shrink();

    final spots = trenData.asMap().entries.map((entry) {
      final nilai = (entry.value['nilai'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(entry.key.toDouble(), nilai);
    }).toList();

    // Calculate min/max for better scaling
    final values = spots.map((s) => s.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxValue - minValue) * 0.1; // 10% padding

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, size: 12, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(
                'SOP Trend (${trenData.length} weeks)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < trenData.length) {
                          final periode = trenData[index]['periode'] ?? '';
                          return Text(
                            periode.toString().replaceAll('Week ', 'W'),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.blue,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: minValue - padding,
                maxY: maxValue + padding,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Build Planning Progress Row (Old - DEPRECATED, kept for reference)
  // ignore: unused_element
  Widget _buildPlanProgressRow(
    String label,
    int selesai,
    int target,
    Color color,
  ) {
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
  Widget _buildPlanMiniCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          leadTimeAph.toStringAsFixed(1),
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
                        progressColor: leadTimeAph <= 3.0
                            ? Colors.green
                            : Colors.red,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Mini Tren Charts
                    if (trenInsidensi.isNotEmpty)
                      _buildMiniTrendChart(
                        'Tren Insidensi',
                        trenInsidensi,
                        Colors.red,
                      ),
                    if (trenG4.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildMiniTrendChart(
                        'Tren G4 Aktif',
                        trenG4,
                        Colors.orange,
                      ),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
  Widget _buildMiniTrendChart(
    String title,
    List<Map<String, dynamic>> data,
    Color color,
  ) {
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          'count': trenG4AktifData,
        },
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        maxX: spots.length > 1
                            ? (spots.length - 1).toDouble()
                            : 5,
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
    const style = TextStyle(fontSize: 10, color: Colors.grey);

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
    const style = TextStyle(fontSize: 10, color: Colors.grey);
    return Text(
      value.toInt().toString(),
      style: style,
      textAlign: TextAlign.left,
    );
  }

  /// Helper: Konversi bulan ke singkatan
  String _getMonthAbbreviation(String month) {
    const months = {
      '01': 'Jan',
      '02': 'Feb',
      '03': 'Mar',
      '04': 'Apr',
      '05': 'Mei',
      '06': 'Jun',
      '07': 'Jul',
      '08': 'Agu',
      '09': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Des',
    };
    return months[month] ?? month;
  }

  /// Helper: Hitung max Y untuk chart agar tidak terlalu rapat
  double _calculateMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;

    final maxValue = spots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);
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

  /// Show SOP Compliance Drill-Down Dialog
  void _showSopComplianceDetail(BuildContext context, double compliance) {
    // Dummy data untuk breakdown SOP
    final compliantItems = [
      {'name': 'Personal Hygiene', 'status': 'Compliant', 'score': 95.0},
      {'name': 'Equipment Sanitasi', 'status': 'Compliant', 'score': 88.0},
      {'name': 'Dokumentasi Kerja', 'status': 'Compliant', 'score': 92.0},
    ];

    final nonCompliantItems = [
      {
        'name': 'Waktu Istirahat',
        'status': 'Non-Compliant',
        'score': 45.0,
        'reason': 'Sering melebihi waktu yang ditentukan',
      },
      {
        'name': 'Penggunaan APD',
        'status': 'Non-Compliant',
        'score': 60.0,
        'reason': 'Masih ada yang tidak lengkap',
      },
      {
        'name': 'Kebersihan Area Kerja',
        'status': 'Partial',
        'score': 70.0,
        'reason': 'Perlu peningkatan di shift malam',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Kepatuhan SOP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Breakdown & Analisis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Overall Score
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: compliance >= 90
                        ? [Colors.green.shade50, Colors.green.shade100]
                        : [Colors.orange.shade50, Colors.orange.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      compliance >= 90
                          ? Icons.check_circle
                          : Icons.warning_amber,
                      size: 48,
                      color: compliance >= 90 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Compliance',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '${compliance.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: compliance >= 90
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Compliant Items
              const Text(
                '✅ Compliant Items (${3})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...compliantItems.map(
                (item) => _buildSopItemCard(
                  context,
                  item['name'] as String,
                  item['score'] as double,
                  Colors.green,
                  null,
                ),
              ),

              const SizedBox(height: 20),

              // Non-Compliant Items
              const Text(
                '⚠️ Issues & Improvements (${3})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: nonCompliantItems
                      .map(
                        (item) => _buildSopItemCard(
                          context,
                          item['name'] as String,
                          item['score'] as double,
                          item['score'] as double >= 70
                              ? Colors.orange
                              : Colors.red,
                          item['reason'] as String?,
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to detailed SOP management page
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Full SOP Report'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show Planning Gauge Drill-Down Dialog (Validasi/APH/Sanitasi)
  void _showPlanningDetail(
    BuildContext context,
    String title,
    int selesai,
    int target,
    Color color,
    DateTime? deadline,
    String riskLevel,
    List<String> blockers,
    List<String> pelaksanaAssigned,
  ) {
    final progress = target > 0 ? (selesai / target * 100) : 0.0;

    // Dummy detail tasks
    final tasks = [
      {'name': 'Persiapan Dokumentasi', 'status': 'Done', 'pic': 'Ahmad'},
      {'name': 'Review Prosedur', 'status': 'Done', 'pic': 'Budi'},
      {'name': 'Training Tim', 'status': 'In Progress', 'pic': 'Citra'},
      {'name': 'Implementasi Sistem', 'status': 'Pending', 'pic': 'Dewi'},
      {'name': 'Quality Check', 'status': 'Pending', 'pic': 'Eko'},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650, maxHeight: 750),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Progress & Breakdown',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Progress Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Text(
                              '${progress.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Target',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Text(
                              '$selesai / $target',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (deadline != null) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: riskLevel == 'High'
                                  ? Colors.red.shade100
                                  : riskLevel == 'Medium'
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Risk: $riskLevel',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: riskLevel == 'High'
                                    ? Colors.red.shade700
                                    : riskLevel == 'Medium'
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Blockers
              if (blockers.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Blockers & Issues',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...blockers.map(
                  (blocker) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.orange.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            blocker,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tasks List
              const Text(
                'Task Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isDone = task['status'] == 'Done';
                    final isInProgress = task['status'] == 'In Progress';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.shade50
                            : isInProgress
                            ? Colors.blue.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDone
                              ? Colors.green.shade200
                              : isInProgress
                              ? Colors.blue.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle
                                : isInProgress
                                ? Icons.pending
                                : Icons.radio_button_unchecked,
                            color: isDone
                                ? Colors.green
                                : isInProgress
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  'PIC: ${task['pic']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? Colors.green
                                  : isInProgress
                                  ? Colors.blue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task['status'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to full task management
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Full Task Manager'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSopItemCard(
    BuildContext context,
    String name,
    double score,
    Color color,
    String? reason,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (reason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
