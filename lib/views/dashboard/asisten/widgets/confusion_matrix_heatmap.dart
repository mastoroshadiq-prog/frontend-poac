import 'package:flutter/material.dart';
import '../../../../models/confusion_matrix_data.dart';
import '../../../../services/validation_service.dart';

/// Confusion Matrix Heatmap Widget untuk Dashboard Asisten
/// Menampilkan 2×2 grid (TP/FP/TN/FN) dengan metrics dan recommendations
class ConfusionMatrixHeatmap extends StatefulWidget {
  final String? divisi;
  final String? blok;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String category)? onCategoryTap;

  const ConfusionMatrixHeatmap({
    super.key,
    this.divisi,
    this.blok,
    this.startDate,
    this.endDate,
    this.onCategoryTap,
  });

  @override
  State<ConfusionMatrixHeatmap> createState() => _ConfusionMatrixHeatmapState();
}

class _ConfusionMatrixHeatmapState extends State<ConfusionMatrixHeatmap> {
  final ValidationService _validationService = ValidationService();
  ConfusionMatrixData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _validationService.getConfusionMatrix(
        divisi: widget.divisi,
        blok: widget.blok,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              _buildError(context)
            else if (_data != null) ...[
              _buildMatrix(context),
              const SizedBox(height: 20),
              _buildMetricsRow(context),
              if (_data!.recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildRecommendations(context),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.purple.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Confusion Matrix - Drone Accuracy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh data',
        ),
      ],
    );
  }

  Widget _buildMatrix(BuildContext context) {
    final data = _data!;

    return SizedBox(
      height: 280,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 400,
          height: 300,
          child: Row(
            children: [
              // Y-axis label (Actual)
              RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    'ACTUAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Matrix Grid
              Expanded(
                child: Column(
              children: [
                // X-axis label (Predicted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'PREDICTED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                // Column headers
                Row(
                  children: [
                    const SizedBox(width: 80), // Space for row labels
                    Expanded(
                      child: Center(
                        child: Text(
                          'Stres',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Normal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Matrix cells
                Expanded(
                  child: Column(
                    children: [
                      // Row 1: Actual Stres | TP | FN
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  'Stres',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildMatrixCell(
                                'TP',
                                data.truePositive,
                                Colors.green.shade400,
                                'True Positive',
                                'Drone correct:\nPredicted stres,\nActually stres',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMatrixCell(
                                'FN',
                                data.falseNegative,
                                Colors.orange.shade400,
                                'False Negative',
                                'Drone missed:\nPredicted normal,\nActually stres',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Row 2: Actual Normal | FP | TN
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  'Normal',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildMatrixCell(
                                'FP',
                                data.falsePositive,
                                Colors.red.shade400,
                                'False Positive',
                                'False alarm:\nPredicted stres,\nActually normal',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMatrixCell(
                                'TN',
                                data.trueNegative,
                                Colors.blue.shade400,
                                'True Negative',
                                'Drone correct:\nPredicted normal,\nActually normal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  }

  Widget _buildMatrixCell(
    String label,
    int count,
    Color color,
    String category,
    String tooltip,
  ) {
    final percentage = (_data!.totalTrees > 0)
        ? (count / _data!.totalTrees * 100)
        : 0.0;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          if (widget.onCategoryTap != null) {
            widget.onCategoryTap!(label);
          } else {
            _showTreeList(context, label, category);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'trees',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.touch_app,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    final data = _data!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildCircularMetricGauge(
            'Accuracy',
            data.accuracy,
            const Color(0xFF5B8C5A), // Dark green like in image
            'Overall correctness\nTarget: ≥80%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCircularMetricGauge(
            'Precision',
            data.precision,
            const Color(0xFF1E88A8), // Teal/cyan like in image
            'Positive prediction reliability\nTarget: ≥75%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCircularMetricGauge(
            'Recall',
            data.recall,
            const Color(0xFFE67E3A), // Orange like in image
            'Detection completeness\nTarget: ≥80%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCircularMetricGauge(
            'F1 Score',
            data.f1Score,
            const Color(0xFF6B7280), // Gray like in image
            'Balanced performance\n(Precision × Recall)',
          ),
        ),
      ],
    );
  }

  Widget _buildCircularMetricGauge(
    String label,
    double value,
    Color color,
    String tooltip,
  ) {
    final percentage = (value * 100).toInt();
    
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular gauge
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Custom painted circular gauge
                  CustomPaint(
                    size: const Size(100, 100),
                    painter: _CircularGaugePainter(
                      progress: value.clamp(0.0, 1.0),
                      progressColor: color,
                      backgroundColor: Colors.grey.shade200,
                      strokeWidth: 10,
                    ),
                  ),
                  // Percentage text in center
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 6),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._data!.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.blue.shade700)),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _adjustThreshold(context),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Adjust Threshold'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _exportReport(context),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export Report'),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            'Failed to load confusion matrix',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showTreeList(BuildContext context, String label, String category) {
    // Navigate to tree list page or show modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing $category trees ($label)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _adjustThreshold(BuildContext context) {
    // Navigate to threshold adjustment page or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adjust Threshold - To be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportReport(BuildContext context) {
    // Export confusion matrix report as PDF/Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export Report - To be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Custom painter for circular gauge (semi-circle from top)
class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularGaugePainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Starting angle: -180° (left), sweep to 0° (right) = 180° semicircle
    // But we want it to start from top, so: -135° to +135° (270° arc)
    const startAngle = -2.356; // -135° in radians (top-left)
    const sweepAngle = 4.712; // 270° in radians (3/4 circle, like in the image)
    
    // Background arc (gray)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );
    
    // Progress arc (colored)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
