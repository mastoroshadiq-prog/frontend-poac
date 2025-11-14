import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/mandor_dashboard_data.dart';
import '../../../services/mandor_service.dart';

/// Dashboard Mandor - Monitor surveyor dan task real-time
/// Refresh: Dashboard 30s, Surveyors 60s, Realtime 10s
class MandorDashboardPage extends StatefulWidget {
  final String mandorId;

  const MandorDashboardPage({
    super.key,
    this.mandorId = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
  });

  @override
  State<MandorDashboardPage> createState() => _MandorDashboardPageState();
}

class _MandorDashboardPageState extends State<MandorDashboardPage> {
  final MandorService _service = MandorService();
  
  MandorDashboardData? _dashboardData;
  SurveyorListData? _surveyorData;
  RealtimeTaskData? _realtimeData;
  
  bool _isLoadingDashboard = true;
  bool _isLoadingSurveyors = true;
  bool _isLoadingRealtime = true;
  
  Timer? _dashboardTimer;
  Timer? _surveyorTimer;
  Timer? _realtimeTimer;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _dashboardTimer?.cancel();
    _surveyorTimer?.cancel();
    _realtimeTimer?.cancel();
    super.dispose();
  }

  void _setupAutoRefresh() {
    // Dashboard: 30s
    _dashboardTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadDashboard();
    });

    // Surveyors: 60s
    _surveyorTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadSurveyors();
    });

    // Realtime: 10s
    _realtimeTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadRealtimeTasks();
    });
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadDashboard(),
      _loadSurveyors(),
      _loadRealtimeTasks(),
    ]);
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() => _isLoadingDashboard = true);
    }

    try {
      final data = await _service.getDashboard(widget.mandorId);
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDashboard = false);
      }
    }
  }

  Future<void> _loadSurveyors() async {
    if (mounted) {
      setState(() => _isLoadingSurveyors = true);
    }

    try {
      final data = await _service.getSurveyors(widget.mandorId);
      if (mounted) {
        setState(() {
          _surveyorData = data;
          _isLoadingSurveyors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSurveyors = false);
      }
    }
  }

  Future<void> _loadRealtimeTasks() async {
    if (mounted) {
      setState(() => _isLoadingRealtime = true);
    }

    try {
      final data = await _service.getRealtimeTasks(widget.mandorId);
      if (mounted) {
        setState(() {
          _realtimeData = data;
          _isLoadingRealtime = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRealtime = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Mandor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh semua data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Statistics (6 cards)
              _buildSummarySection(),
              const SizedBox(height: 24),

              // Today's Target Progress
              _buildTargetProgressSection(),
              const SizedBox(height: 24),

              // Surveyor Status Grid
              _buildSurveyorSection(),
              const SizedBox(height: 24),

              // Real-time Activity Feed
              _buildRealtimeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    if (_isLoadingDashboard) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboardData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Gagal memuat data dashboard'),
        ),
      );
    }

    final summary = _dashboardData!.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'SPK Aktif',
              summary.activeSpk.toString(),
              Icons.assignment,
              Colors.blue,
            ),
            _buildStatCard(
              'Pending',
              summary.pendingTasks.toString(),
              Icons.pending_actions,
              Colors.orange,
            ),
            _buildStatCard(
              'Progress',
              summary.inProgressTasks.toString(),
              Icons.work_history,
              Colors.purple,
            ),
            _buildStatCard(
              'Selesai Hari Ini',
              summary.completedToday.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Urgent',
              summary.urgentCount.toString(),
              Icons.priority_high,
              Colors.red,
            ),
            _buildStatCard(
              'Overdue',
              summary.overdueCount.toString(),
              Icons.warning,
              Colors.deepOrange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetProgressSection() {
    if (_dashboardData == null) return const SizedBox.shrink();

    final targets = _dashboardData!.todayTargets;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Target Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${targets.progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(targets.progressPercentage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: targets.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(targets.progressPercentage),
              ),
              minHeight: 12,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTargetStat('Target', targets.treesToValidate, Colors.blue),
                _buildTargetStat('Selesai', targets.completed, Colors.green),
                _buildTargetStat('Tersisa', targets.remaining, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSurveyorSection() {
    if (_isLoadingSurveyors) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_surveyorData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Gagal memuat data surveyor'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status Surveyor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _buildStatusBadge('Tersedia', _surveyorData!.summary.available, Colors.green),
                const SizedBox(width: 8),
                _buildStatusBadge('Bekerja', _surveyorData!.summary.working, Colors.blue),
                const SizedBox(width: 8),
                _buildStatusBadge('Off', _surveyorData!.summary.offDuty, Colors.grey),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _surveyorData!.surveyors.length,
          itemBuilder: (context, index) {
            final surveyor = _surveyorData!.surveyors[index];
            return _buildSurveyorCard(surveyor);
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSurveyorCard(SurveyorData surveyor) {
    final statusColor = _getSurveyorStatusColor(surveyor.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Surveyor info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surveyor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSurveyorStatusText(surveyor.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Workload
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${surveyor.currentWorkload.activeTasks} aktif',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${surveyor.currentWorkload.completedToday} selesai',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Performance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    surveyor.performance.qualityScore.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSurveyorStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return const Color(0xFF10B981); // green
      case 'WORKING':
        return const Color(0xFF3B82F6); // blue
      case 'OFF_DUTY':
        return const Color(0xFF6B7280); // gray
      default:
        return Colors.grey;
    }
  }

  String _getSurveyorStatusText(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Tersedia';
      case 'WORKING':
        return 'Sedang Bekerja';
      case 'OFF_DUTY':
        return 'Off Duty';
      default:
        return status;
    }
  }

  Widget _buildRealtimeSection() {
    if (_isLoadingRealtime) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_realtimeData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Gagal memuat data real-time'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Real-time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.refresh, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  'Update setiap 10 detik',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Active Tasks
        if (_realtimeData!.activeTasks.isNotEmpty) ...[
          const Text(
            'Sedang Berlangsung',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _realtimeData!.activeTasks.length,
            itemBuilder: (context, index) {
              final task = _realtimeData!.activeTasks[index];
              return _buildActiveTaskCard(task);
            },
          ),
          const SizedBox(height: 16),
        ],

        // Recent Completions
        if (_realtimeData!.recentCompletions.isNotEmpty) ...[
          const Text(
            'Baru Selesai',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _realtimeData!.recentCompletions.length,
            itemBuilder: (context, index) {
              final completion = _realtimeData!.recentCompletions[index];
              return _buildCompletionCard(completion);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActiveTaskCard(ActiveTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work_history, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.surveyorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${task.elapsedTimeMins} menit',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.treeId,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildProgressChip(
                  Icons.photo_camera,
                  '${task.photosUploaded} foto',
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildProgressChip(
                  Icons.checklist,
                  '${task.checklistCompleted} item',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(RecentCompletion completion) {
    final timeAgo = DateTime.now().difference(completion.completedAt);
    final timeAgoText = timeAgo.inMinutes < 60
        ? '${timeAgo.inMinutes} menit lalu'
        : '${timeAgo.inHours} jam lalu';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    completion.surveyorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completion.treeId,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgoText,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    completion.result,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${completion.timeTakenMins} menit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
