import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../services/analytics_service.dart';
import '../../../../models/mandor_performance.dart';

/// Widget untuk menampilkan Mandor Performance Table & Leaderboard
/// 
/// Fitur:
/// - Data table dengan sorting capability
/// - Radar chart overlay untuk performance metrics
/// - Leaderboard ranking dengan badges
/// - Color-coded performance ratings
/// - Expandable detail untuk setiap mandor
/// - Performance breakdown (validation, SOP compliance, speed)
/// - Issues/alerts section
/// - Filter by date range
class MandorPerformanceTable extends StatefulWidget {
  final String? mandorId;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String mandorId)? onMandorTap;

  const MandorPerformanceTable({
    super.key,
    this.mandorId,
    this.startDate,
    this.endDate,
    this.onMandorTap,
  });

  @override
  State<MandorPerformanceTable> createState() => _MandorPerformanceTableState();
}

class _MandorPerformanceTableState extends State<MandorPerformanceTable> {
  final AnalyticsService _analyticsService = AnalyticsService();
  MandorPerformanceData? _data;
  bool _isLoading = true;
  String? _errorMessage;
  String _sortColumn = 'overall';
  bool _sortAscending = false;
  final Set<String> _expandedRows = {};
  String? _selectedMandorForRadar;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(MandorPerformanceTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mandorId != widget.mandorId ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _analyticsService.getMandorPerformance(
        mandorId: widget.mandorId,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
          _sortData();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _sortData() {
    if (_data == null) return;

    _data!.mandors.sort((a, b) {
      int comparison;
      switch (_sortColumn) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'overall':
          comparison = a.performance.qualityScore.compareTo(b.performance.qualityScore);
          break;
        case 'completion':
          comparison = a.performance.completionRate.compareTo(b.performance.completionRate);
          break;
        case 'quality':
          comparison = a.performance.qualityScore.compareTo(b.performance.qualityScore);
          break;
        case 'speed':
          comparison = a.breakdown.speedScore.compareTo(b.breakdown.speedScore);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (_data != null) _buildLeaderboard(),
            const SizedBox(height: 16),
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_data != null)
              SizedBox(
                height: 600, // Fixed height to avoid unbounded constraints
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildDataTable(),
                    ),
                    if (_selectedMandorForRadar != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildRadarChart(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.leaderboard,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mandor Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_data != null)
                Text(
                  '${_data!.mandors.length} mandor dipantau',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    // Use byQuality as top performers list
    final topPerformers = _data!.rankings.byQuality;
    if (topPerformers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[100]!, Colors.amber[50]!],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Performers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: topPerformers.take(3).map((performer) {
              final index = topPerformers.indexOf(performer);
              return Expanded(
                child: _buildLeaderboardCard(performer, index + 1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(MandorRanking performer, int rank) {
    Color medalColor;
    IconData medalIcon;
    
    switch (rank) {
      case 1:
        medalColor = Colors.amber[700]!;
        medalIcon = Icons.emoji_events;
        break;
      case 2:
        medalColor = Colors.grey[600]!;
        medalIcon = Icons.military_tech;
        break;
      case 3:
        medalColor = Colors.orange[700]!;
        medalIcon = Icons.workspace_premium;
        break;
      default:
        medalColor = Colors.blue[700]!;
        medalIcon = Icons.star;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(medalIcon, color: medalColor, size: 32),
            const SizedBox(height: 4),
            Text(
              '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: medalColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              performer.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${(performer.rate * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: medalColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Table Header
          _buildTableHeader(),
          const Divider(height: 1),
          // Table Rows
          ..._data!.mandors.map((mandor) {
            final isExpanded = _expandedRows.contains(mandor.mandorId);
            return _buildTableRow(mandor, isExpanded);
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          const SizedBox(width: 40), // For expand icon
          _buildHeaderCell('Mandor', 'name', flex: 2),
          _buildHeaderCell('Overall', 'overall', flex: 1),
          _buildHeaderCell('Completion', 'completion', flex: 1),
          _buildHeaderCell('Quality', 'quality', flex: 1),
          _buildHeaderCell('Speed', 'speed', flex: 1),
          const SizedBox(width: 80), // For actions
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, String columnKey, {int flex = 1}) {
    final isActive = _sortColumn == columnKey;
    
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          setState(() {
            if (_sortColumn == columnKey) {
              _sortAscending = !_sortAscending;
            } else {
              _sortColumn = columnKey;
              _sortAscending = false;
            }
            _sortData();
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isActive ? Colors.blue[700] : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            if (isActive)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: Colors.blue[700],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(MandorPerformance mandor, bool isExpanded) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedRows.remove(mandor.mandorId);
              } else {
                _expandedRows.add(mandor.mandorId);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isExpanded ? Colors.blue[50] : null,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                // Expand Icon
                SizedBox(
                  width: 40,
                  child: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
                // Mandor Name
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _getPerformanceColor(mandor.performance.qualityScore * 100),
                        child: Text(
                          mandor.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mandor.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${mandor.mandorId} • ${mandor.afdeling}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Overall Score
                Expanded(
                  flex: 1,
                  child: _buildScoreCell(mandor.performance.qualityScore * 100),
                ),
                // Completion Rate
                Expanded(
                  flex: 1,
                  child: _buildScoreCell(mandor.performance.completionRate * 100),
                ),
                // Quality Score
                Expanded(
                  flex: 1,
                  child: _buildScoreCell(mandor.performance.qualityScore * 100),
                ),
                // Speed Score
                Expanded(
                  flex: 1,
                  child: _buildScoreCell(mandor.breakdown.speedScore * 100),
                ),
                // Actions
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.radar,
                          size: 18,
                          color: _selectedMandorForRadar == mandor.mandorId
                              ? Colors.blue[700]
                              : Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedMandorForRadar =
                                _selectedMandorForRadar == mandor.mandorId
                                    ? null
                                    : mandor.mandorId;
                          });
                        },
                        tooltip: 'Radar Chart',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded Detail
        if (isExpanded) _buildExpandedDetail(mandor),
      ],
    );
  }

  Widget _buildScoreCell(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPerformanceColor(score).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${score.toStringAsFixed(0)}%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: _getPerformanceColor(score),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getPerformanceColor(double score) {
    if (score >= 85) return Colors.green[700]!;
    if (score >= 70) return Colors.blue[700]!;
    if (score >= 50) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  Widget _buildExpandedDetail(MandorPerformance mandor) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Breakdown
          Text(
            'Performance Breakdown',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Validation Accuracy',
                  mandor.breakdown.validationAccuracy * 100,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  'SOP Compliance',
                  mandor.breakdown.sopCompliance * 100,
                  Icons.rule,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  'Speed Score',
                  mandor.breakdown.speedScore * 100,
                  Icons.speed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // SPK Stats
          Row(
            children: [
              Icon(Icons.assignment, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'SPK: ${mandor.performance.spkCompleted}/${mandor.performance.spkAssigned}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              if (mandor.performance.spkOverdue > 0) ...[
                Icon(Icons.warning, size: 16, color: Colors.red[600]),
                const SizedBox(width: 4),
                Text(
                  '${mandor.performance.spkOverdue} overdue',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          // Issues
          if (mandor.issues.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Issues (${mandor.issues.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...mandor.issues.take(2).map((issue) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 24),
                child: Text(
                  '• ${issue.type}: ${issue.nomorSpk}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, double value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: _getPerformanceColor(value)),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getPerformanceColor(value),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart() {
    final mandor = _data!.mandors.firstWhere(
      (m) => m.mandorId == _selectedMandorForRadar,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Radar',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mandor.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedMandorForRadar = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.transparent),
                  radarBorderData: BorderSide(color: Colors.grey[300]!, width: 2),
                  gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
                  tickBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
                  getTitle: (index, angle) {
                    final titles = [
                      'Overall',
                      'Completion',
                      'Quality',
                      'Speed',
                      'SOP',
                    ];
                    return RadarChartTitle(
                      text: titles[index],
                      angle: angle,
                    );
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue[400]!.withOpacity(0.3),
                      borderColor: Colors.blue[700]!,
                      borderWidth: 2,
                      dataEntries: [
                        RadarEntry(value: mandor.performance.qualityScore * 100),
                        RadarEntry(value: mandor.performance.completionRate * 100),
                        RadarEntry(value: mandor.performance.qualityScore * 100),
                        RadarEntry(value: mandor.breakdown.speedScore * 100),
                        RadarEntry(value: mandor.breakdown.sopCompliance * 100),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            _buildRadarLegend(mandor),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarLegend(MandorPerformance mandor) {
    final metrics = [
      ('Overall', mandor.performance.qualityScore * 100),
      ('Completion', mandor.performance.completionRate * 100),
      ('Quality', mandor.performance.qualityScore * 100),
      ('Speed', mandor.breakdown.speedScore * 100),
      ('SOP', mandor.breakdown.sopCompliance * 100),
    ];

    return Column(
      children: metrics.map((metric) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.$1,
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                '${metric.$2.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getPerformanceColor(metric.$2),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
