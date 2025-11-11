import 'package:flutter/material.dart';
import 'dart:async';
import '../services/dashboard_service.dart';
import '../models/lifecycle_data.dart';

/// Lifecycle Overview Widget - For Operasional Dashboard
/// Date: November 11, 2025
/// 
/// Shows: 5 phase cards with SPK count, completion %, color-coded status
/// Features: Auto-refresh every 5 minutes, clickable cards navigate to detail page
/// API: GET /api/v1/lifecycle/overview

class LifecycleOverviewWidget extends StatefulWidget {
  final String? token;

  const LifecycleOverviewWidget({
    super.key,
    this.token,
  });

  @override
  State<LifecycleOverviewWidget> createState() => _LifecycleOverviewWidgetState();
}

class _LifecycleOverviewWidgetState extends State<LifecycleOverviewWidget> {
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
          .then((data) {
            print('✅ Received data in widget: $data');
            try {
              final overview = LifecycleOverview.fromJson(data);
              print('✅ Successfully parsed LifecycleOverview');
              return overview;
            } catch (e, stackTrace) {
              print('❌ Error parsing LifecycleOverview: $e');
              print('Stack trace: $stackTrace');
              rethrow;
            }
          });
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
                      Icons.eco,
                      color: Colors.green.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lifecycle Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Multi-Phase Plantation Status',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _loadData,
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 20),
                      onPressed: () {
                        Navigator.pushNamed(context, '/lifecycle/Pembibitan');
                      },
                      tooltip: 'Open Detail Page',
                    ),
                  ],
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
                          'Error loading lifecycle data',
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

                if (!snapshot.hasData || snapshot.data!.phases.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No lifecycle data available'),
                    ),
                  );
                }

                final overview = snapshot.data!;
                return Column(
                  children: [
                    // Health Index Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getHealthColor(overview.healthIndex),
                            _getHealthColor(overview.healthIndex).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall Health Index',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${overview.healthIndex.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${overview.totalSpks} SPKs',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${overview.totalExecutions} Executions',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5 Phase Cards (Horizontal Scroll)
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: overview.phases.length,
                        itemBuilder: (context, index) {
                          final phase = overview.phases[index];
                          return _buildPhaseCard(context, phase);
                        },
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

  Widget _buildPhaseCard(BuildContext context, LifecyclePhase phase) {
    final color = _getPhaseColor(phase.completionRate);
    
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/lifecycle/${phase.namaFase}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase icon and name
            Row(
              children: [
                Icon(
                  _getPhaseIcon(phase.namaFase),
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phase.namaFase,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Completion percentage (large)
            Text(
              '${phase.completionRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'Completion',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            // SPK count
            Row(
              children: [
                Icon(Icons.assignment, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${phase.totalSpks} SPKs',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.check_circle, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${phase.totalExecutions}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPhaseColor(double completionRate) {
    if (completionRate >= 80) return Colors.green.shade700; // Excellent
    if (completionRate >= 40) return Colors.orange.shade700; // Fair
    return Colors.red.shade700; // Critical
  }

  Color _getHealthColor(double healthIndex) {
    if (healthIndex >= 80) return const Color(0xFF10b981); // Excellent
    if (healthIndex >= 60) return const Color(0xFF3b82f6); // Good
    if (healthIndex >= 40) return const Color(0xFFf59e0b); // Fair
    return const Color(0xFFef4444); // Critical
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
