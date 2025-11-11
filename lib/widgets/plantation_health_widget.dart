import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import '../services/dashboard_service.dart';
import '../models/lifecycle_data.dart';

/// Plantation Health Widget - For Technical Dashboard
/// Date: November 11, 2025
/// 
/// Shows: Gauge chart (overall health 0-100), phase breakdown table, critical alerts
/// Features: Auto-refresh every 5 minutes
/// API: GET /api/v1/lifecycle/overview (reuses overview API with health data)

class PlantationHealthWidget extends StatefulWidget {
  final String? token;

  const PlantationHealthWidget({
    super.key,
    this.token,
  });

  @override
  State<PlantationHealthWidget> createState() => _PlantationHealthWidgetState();
}

class _PlantationHealthWidgetState extends State<PlantationHealthWidget> {
  final DashboardService _service = DashboardService();
  Future<LifecycleOverview>? _overviewFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Auto-refresh every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _overviewFuture = _service
          .fetchLifecycleOverview()
          .then((data) => LifecycleOverview.fromJson(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plantation Health',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Overall Health Monitoring',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content
            FutureBuilder<LifecycleOverview>(
              future: _overviewFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading health data',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString().replaceAll('Exception: ', ''),
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No health data available'),
                    ),
                  );
                }

                final overview = snapshot.data!;
                final criticalPhases = overview.phases
                    .where((p) => p.completionRate < 40)
                    .toList();

                return Column(
                  children: [
                    // Row: Gauge Chart + Critical Alerts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gauge Chart (Overall Health)
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              CircularPercentIndicator(
                                radius: 90.0,
                                lineWidth: 18.0,
                                percent: overview.healthIndex / 100,
                                center: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${overview.healthIndex.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _getHealthColor(overview.healthIndex),
                                      ),
                                    ),
                                    Text(
                                      _getHealthStatus(overview.healthIndex),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getHealthColor(overview.healthIndex),
                                      ),
                                    ),
                                  ],
                                ),
                                progressColor: _getHealthColor(overview.healthIndex),
                                backgroundColor: Colors.grey.shade200,
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                                animationDuration: 1200,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Overall Health Index',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // Critical Alerts
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Critical Alerts',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (criticalPhases.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'No critical phases detected\nAll phases healthy!',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...criticalPhases.map((phase) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error, size: 20, color: Colors.red.shade700),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  phase.namaFase,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red.shade900,
                                                  ),
                                                ),
                                                Text(
                                                  'Completion: ${phase.completionRate.toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.red.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade700,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'CRITICAL',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
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
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Phase Breakdown Table
                    Text(
                      'Phase Health Breakdown',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Phase',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Score',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Table Rows
                          ...overview.phases.asMap().entries.map((entry) {
                            final index = entry.key;
                            final phase = entry.value;
                            final isLast = index == overview.phases.length - 1;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                                borderRadius: isLast
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getPhaseIcon(phase.namaFase),
                                          size: 18,
                                          color: _getPhaseColor(phase.completionRate),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          phase.namaFase,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${phase.completionRate.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _getPhaseColor(phase.completionRate),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getPhaseColor(phase.completionRate).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          phase.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _getPhaseColor(phase.completionRate),
                                          ),
                                        ),
                                      ),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(double health) {
    if (health >= 80) return const Color(0xFF10b981); // Excellent - Green
    if (health >= 60) return const Color(0xFF3b82f6); // Good - Blue
    if (health >= 40) return const Color(0xFFf59e0b); // Fair - Orange
    return const Color(0xFFef4444); // Critical - Red
  }

  Color _getPhaseColor(double completionRate) {
    if (completionRate >= 80) return Colors.green.shade700;
    if (completionRate >= 40) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  String _getHealthStatus(double health) {
    if (health >= 80) return 'EXCELLENT';
    if (health >= 60) return 'GOOD';
    if (health >= 40) return 'FAIR';
    return 'CRITICAL';
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
