import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../services/validation_service.dart';
import '../../../../models/validation_point.dart';

/// Widget untuk menampilkan Scatter Plot Field vs Drone Validation
/// 
/// Fitur:
/// - Scatter plot dengan fl_chart ScatterChart
/// - Color-coded points by category (TP/FP/TN/FN)
/// - Interactive tooltips dengan detail informasi
/// - Drill-down capability ke detail pohon
/// - Filter by category, divisi, blok, stress level
/// - Legend dengan kategori validation
/// - Loading, error, dan refresh states
/// - Responsive layout
class FieldVsDroneScatter extends StatefulWidget {
  final String? divisi;
  final String? blok;
  final String? stressLevel;
  final String? category; // TP, FP, TN, FN, atau null untuk semua
  final Function(ValidationPoint)? onPointTap;

  const FieldVsDroneScatter({
    Key? key,
    this.divisi,
    this.blok,
    this.stressLevel,
    this.category,
    this.onPointTap,
  }) : super(key: key);

  @override
  State<FieldVsDroneScatter> createState() => _FieldVsDroneScatterState();
}

class _FieldVsDroneScatterState extends State<FieldVsDroneScatter> {
  final ValidationService _validationService = ValidationService();
  FieldVsDroneData? _data;
  bool _isLoading = true;
  String? _errorMessage;
  int _touchedSpotIndex = -1;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _loadData();
  }

  @override
  void didUpdateWidget(FieldVsDroneScatter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.divisi != widget.divisi ||
        oldWidget.blok != widget.blok ||
        oldWidget.stressLevel != widget.stressLevel ||
        oldWidget.category != widget.category) {
      _selectedCategory = widget.category;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _validationService.getFieldVsDrone(
        divisi: widget.divisi,
        blok: widget.blok,
        stressLevel: widget.stressLevel,
        category: _selectedCategory,
      );

      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
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
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_data != null)
              _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.scatter_plot,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field vs Drone Validation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_data != null)
                Text(
                  '${_data!.totalPoints} pohon | Akurasi: ${_data!.accuracy.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
        _buildCategoryFilter(),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return PopupMenuButton<String>(
      tooltip: 'Filter Kategori',
      icon: Icon(
        Icons.filter_alt,
        color: _selectedCategory != null ? Colors.blue[700] : Colors.grey[600],
      ),
      onSelected: (value) {
        setState(() {
          _selectedCategory = value == 'ALL' ? null : value;
        });
        _loadData();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'ALL',
          child: Row(
            children: [
              Icon(Icons.all_inclusive, size: 20),
              SizedBox(width: 8),
              Text('Semua Kategori'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'TP',
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              const Text('True Positive (TP)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'FP',
          child: Row(
            children: [
              Icon(Icons.error, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              const Text('False Positive (FP)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'TN',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('True Negative (TN)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'FN',
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('False Negative (FN)'),
            ],
          ),
        ),
      ],
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

  Widget _buildContent() {
    return Column(
      children: [
        // Scatter Plot
        _buildScatterPlot(),
        const SizedBox(height: 24),
        // Legend & Statistics
        _buildLegendAndStats(),
        const SizedBox(height: 16),
        // Distribution Summary
        _buildDistributionSummary(),
        const SizedBox(height: 16),
        // Common Causes Section
        if (_data!.commonCauses.isNotEmpty) _buildCommonCauses(),
      ],
    );
  }

  Widget _buildScatterPlot() {
    return SizedBox(
      height: 400,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: _buildScatterSpots(),
          minX: 0,
          maxX: 1,
          minY: 0,
          maxY: 1,
          backgroundColor: Colors.grey[50],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 0.1,
            verticalInterval: 0.1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[400]!),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                'Field Score (Ground Truth)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 0.2,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text(
                'NDRE Value (Drone Prediction)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 0.2,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    ),
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
          scatterTouchData: ScatterTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchCallback: (FlTouchEvent event, ScatterTouchResponse? response) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSpot == null) {
                setState(() {
                  _touchedSpotIndex = -1;
                });
                return;
              }

              final spot = response.touchedSpot!;
              final spotIndex = spot.spotIndex;

              if (spotIndex >= 0 && spotIndex < _data!.points.length) {
                setState(() {
                  _touchedSpotIndex = spotIndex;
                });

                // Handle tap untuk drill-down
                if (event is FlTapUpEvent && widget.onPointTap != null) {
                  final point = _data!.points[spotIndex];
                  widget.onPointTap!(point);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  List<ScatterSpot> _buildScatterSpots() {
    if (_data == null || _data!.points.isEmpty) return [];

    return List.generate(_data!.points.length, (index) {
      final point = _data!.points[index];
      final isTouched = index == _touchedSpotIndex;

      return ScatterSpot(
        point.fieldScore.toDouble(),
        point.ndreValue,
        dotPainter: FlDotCirclePainter(
          radius: isTouched ? 8 : 5,
          color: _getCategoryColor(point.category).withOpacity(0.7),
          strokeWidth: isTouched ? 2 : 0,
          strokeColor: Colors.white,
        ),
      );
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'TP':
        return Colors.green[600]!;
      case 'FP':
        return Colors.red[600]!;
      case 'TN':
        return Colors.blue[600]!;
      case 'FN':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _buildTooltipText(int spotIndex) {
    if (_data == null || spotIndex >= _data!.points.length) {
      return 'Invalid point';
    }

    final point = _data!.points[spotIndex];
    final gpsText = point.gps != null
        ? '${point.gps!.latitude.toStringAsFixed(6)}, ${point.gps!.longitude.toStringAsFixed(6)}'
        : 'No GPS';
    
    return '${_getCategoryLabel(point.category)}\n'
        'Tree ID: ${point.treeId}\n'
        'Field: ${point.fieldScore.toStringAsFixed(0)}\n'
        'Drone: ${point.ndreValue.toStringAsFixed(2)}\n'
        'GPS: $gpsText';
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'TP':
      case 'True Positive':
        return 'True Positive ✓';
      case 'FP':
      case 'False Positive':
        return 'False Positive ✗';
      case 'TN':
      case 'True Negative':
        return 'True Negative ✓';
      case 'FN':
      case 'False Negative':
        return 'False Negative ✗';
      default:
        return 'Unknown';
    }
  }

  int _getCountForCategory(String category) {
    if (_data == null) return 0;
    
    // Count points in category
    return _data!.points.where((p) {
      // Normalize category (both short form TP and long form True Positive)
      final normalizedPointCat = p.category.replaceAll(' ', '').toUpperCase();
      final normalizedSearchCat = category.replaceAll(' ', '').toUpperCase();
      return normalizedPointCat.contains(normalizedSearchCat) || 
             normalizedSearchCat.contains(normalizedPointCat);
    }).length;
  }

  Widget _buildLegendAndStats() {
    return Row(
      children: [
        // Legend
        Expanded(
          flex: 2,
          child: _buildLegend(),
        ),
        const SizedBox(width: 24),
        // Statistics
        Expanded(
          flex: 3,
          child: _buildStatistics(),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final categories = [
      ('TP', 'True Positive', Colors.green[600]!, Icons.check_circle),
      ('FP', 'False Positive', Colors.red[600]!, Icons.error),
      ('TN', 'True Negative', Colors.blue[600]!, Icons.check_circle_outline),
      ('FN', 'False Negative', Colors.orange[600]!, Icons.error_outline),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...categories.map((cat) {
          final count = _getCountForCategory(cat.$1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(cat.$4, color: cat.$3, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${cat.$1}: ${cat.$2}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: cat.$3,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Validasi',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildStatRow('Akurasi', '${_data!.accuracy.toStringAsFixed(1)}%',
            _data!.accuracy >= 85 ? Colors.green[700]! : Colors.orange[700]!),
        _buildStatRow('Presisi', '${_data!.precision.toStringAsFixed(1)}%',
            Colors.grey[700]!),
        _buildStatRow('Recall', '${_data!.recall.toStringAsFixed(1)}%',
            Colors.grey[700]!),
        _buildStatRow('F1-Score', '${_data!.f1Score.toStringAsFixed(1)}%',
            Colors.grey[700]!),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Analisis Distribusi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _data!.distributionAnalysis,
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonCauses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.troubleshoot, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Penyebab Umum Mismatch',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._data!.commonCauses.map((cause) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getCauseIcon(cause.cause),
                  size: 16,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cause.cause,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${cause.count} kasus (${cause.percentage.toStringAsFixed(1)}%)',
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
          );
        }).toList(),
      ],
    );
  }

  IconData _getCauseIcon(String cause) {
    if (cause.toLowerCase().contains('shadow') ||
        cause.toLowerCase().contains('bayangan')) {
      return Icons.wb_sunny_outlined;
    } else if (cause.toLowerCase().contains('cloud') ||
        cause.toLowerCase().contains('awan')) {
      return Icons.cloud;
    } else if (cause.toLowerCase().contains('water') ||
        cause.toLowerCase().contains('air')) {
      return Icons.water_drop;
    } else if (cause.toLowerCase().contains('edge') ||
        cause.toLowerCase().contains('border')) {
      return Icons.border_outer;
    }
    return Icons.info_outline;
  }
}
