import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../services/dashboard_service.dart';
import '../../../../models/ndre_statistics.dart';

/// Widget untuk menampilkan statistik NDRE dalam bentuk Pie Chart dan Bar Chart
/// 
/// Fitur:
/// - Pie Chart untuk distribusi persentase (Stres Berat, Sedang, Sehat)
/// - Bar Chart untuk jumlah absolut pohon per kategori
/// - Color-coded categories (Red, Orange, Green)
/// - Interactive legend dengan onTap drill-down
/// - Loading dan error states
/// - Refresh capability
/// - Responsive layout
class NdreStatisticsCard extends StatefulWidget {
  final String? divisi;
  final String? blok;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback? onCategoryTap;

  const NdreStatisticsCard({
    super.key,
    this.divisi,
    this.blok,
    this.startDate,
    this.endDate,
    this.onCategoryTap,
  });

  @override
  State<NdreStatisticsCard> createState() => _NdreStatisticsCardState();
}

class _NdreStatisticsCardState extends State<NdreStatisticsCard> {
  final DashboardService _dashboardService = DashboardService();
  NdreStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void didUpdateWidget(NdreStatisticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.divisi != widget.divisi ||
        oldWidget.blok != widget.blok ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _loadStatistics();
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await _dashboardService.getNdreStatistics(
        divisi: widget.divisi,
        blok: widget.blok,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (mounted) {
        setState(() {
          _statistics = stats;
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
            else if (_statistics != null)
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
          Icons.analytics_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distribusi NDRE',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_statistics != null)
                Text(
                  'Total ${_statistics!.totalPohon} pohon',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStatistics,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
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
              onPressed: _loadStatistics,
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
        // Pie Chart Section
        _buildPieChartSection(),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        // Bar Chart Section
        _buildBarChartSection(),
        const SizedBox(height: 16),
        // Summary Section
        _buildSummarySection(),
      ],
    );
  }

  Widget _buildPieChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Persentase Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildPieChartSections(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                flex: 2,
                child: _buildPieLegend(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final stats = _statistics!;
    final categories = [
      (
        'Stres Berat',
        stats.stresBerat,
        stats.persentaseStresBerat,
        Colors.red[400]!
      ),
      (
        'Stres Sedang',
        stats.stresSedang,
        stats.persentaseStresSedang,
        Colors.orange[400]!
      ),
      ('Sehat', stats.sehat, stats.persentaseSehat, Colors.green[400]!),
    ];

    return List.generate(categories.length, (index) {
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 65.0 : 55.0;
      final category = categories[index];

      return PieChartSectionData(
        color: category.$4,
        value: category.$3,
        title: '${category.$3.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
      );
    });
  }

  Widget _buildPieLegend() {
    final stats = _statistics!;
    final categories = [
      ('Stres Berat', stats.stresBerat, stats.persentaseStresBerat,
          Colors.red[400]!, Icons.error),
      ('Stres Sedang', stats.stresSedang, stats.persentaseStresSedang,
          Colors.orange[400]!, Icons.warning),
      ('Sehat', stats.sehat, stats.persentaseSehat, Colors.green[400]!,
          Icons.check_circle),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: widget.onCategoryTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(category.$5, color: category.$4, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.$1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${category.$2} pohon',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jumlah Pohon per Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final categories = ['Stres Berat', 'Stres Sedang', 'Sehat'];
                    return BarTooltipItem(
                      '${categories[group.x.toInt()]}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toInt()} pohon',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _getBottomTitles,
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: _getLeftTitles,
                  ),
                ),
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
                horizontalInterval: _getMaxY() / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxY() {
    final stats = _statistics!;
    final maxValue =
        [stats.stresBerat, stats.stresSedang, stats.sehat].reduce((a, b) => a > b ? a : b);
    // Add 20% padding to max value
    return (maxValue * 1.2).ceilToDouble();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    );

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Stres\nBerat', style: style, textAlign: TextAlign.center);
        break;
      case 1:
        text = const Text('Stres\nSedang', style: style, textAlign: TextAlign.center);
        break;
      case 2:
        text = const Text('Sehat', style: style, textAlign: TextAlign.center);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: text,
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        value.toInt().toString(),
        style: style,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final stats = _statistics!;
    final data = [
      (stats.stresBerat.toDouble(), Colors.red[400]!),
      (stats.stresSedang.toDouble(), Colors.orange[400]!),
      (stats.sehat.toDouble(), Colors.green[400]!),
    ];

    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].$1,
            color: data[index].$2,
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey[200],
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  Widget _buildSummarySection() {
    final stats = _statistics!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Ringkasan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Kategori Dominan',
            stats.dominantCategory,
            stats.dominantCategoryColor,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Rata-rata NDRE',
            stats.averageNdre.toStringAsFixed(3),
            Colors.grey[700]!,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Range NDRE',
            '${stats.minNdre.toStringAsFixed(3)} - ${stats.maxNdre.toStringAsFixed(3)}',
            Colors.grey[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
