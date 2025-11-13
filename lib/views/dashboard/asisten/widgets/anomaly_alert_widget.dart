import 'package:flutter/material.dart';
import '../../../../services/analytics_service.dart';
import '../../../../models/anomaly_item.dart';

/// Helper untuk convert string color ke Color
Color _getColorFromString(String colorString) {
  switch (colorString) {
    case 'red':
      return Colors.red[700]!;
    case 'orange':
      return Colors.orange[700]!;
    case 'green':
      return Colors.green[700]!;
    case 'blue':
      return Colors.blue[700]!;
    case 'grey':
      return Colors.grey[700]!;
    default:
      return Colors.grey[700]!;
  }
}

/// Helper untuk convert severity icon name ke IconData
IconData _getIconFromName(String iconName) {
  switch (iconName) {
    case 'error':
      return Icons.error;
    case 'warning':
      return Icons.warning;
    case 'info':
      return Icons.info;
    default:
      return Icons.help;
  }
}

/// Widget untuk menampilkan Anomaly Alerts
/// 
/// Fitur:
/// - Alert list dengan severity color coding
/// - Filter by anomaly type dan severity
/// - Action buttons (Investigate, Create SPK, Dismiss)
/// - Expandable detail untuk setiap anomaly
/// - Priority sorting
/// - Tree location dengan GPS link
/// - Loading, error, dan refresh states
class AnomalyAlertWidget extends StatefulWidget {
  final String? divisi;
  final String? blok;
  final String? anomalyType;
  final String? severity;
  final Function(AnomalyItem)? onInvestigate;
  final Function(AnomalyItem)? onCreateSpk;

  const AnomalyAlertWidget({
    Key? key,
    this.divisi,
    this.blok,
    this.anomalyType,
    this.severity,
    this.onInvestigate,
    this.onCreateSpk,
  }) : super(key: key);

  @override
  State<AnomalyAlertWidget> createState() => _AnomalyAlertWidgetState();
}

class _AnomalyAlertWidgetState extends State<AnomalyAlertWidget> {
  final AnalyticsService _analyticsService = AnalyticsService();
  AnomalyData? _data;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedTypeFilter;
  String? _selectedSeverityFilter;
  Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedTypeFilter = widget.anomalyType;
    _selectedSeverityFilter = widget.severity;
    _loadData();
  }

  @override
  void didUpdateWidget(AnomalyAlertWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.divisi != widget.divisi ||
        oldWidget.blok != widget.blok ||
        oldWidget.anomalyType != widget.anomalyType ||
        oldWidget.severity != widget.severity) {
      _selectedTypeFilter = widget.anomalyType;
      _selectedSeverityFilter = widget.severity;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _analyticsService.getAnomalyDetection(
        divisi: widget.divisi,
        blok: widget.blok,
        anomalyType: _selectedTypeFilter,
        severity: _selectedSeverityFilter,
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
            if (_data != null) _buildSummary(),
            const SizedBox(height: 16),
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_data != null)
              Expanded(child: _buildAlertList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange[700],
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anomaly Detection',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_data != null)
                Text(
                  '${_data!.totalAnomalies} anomali terdeteksi',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
        _buildTypeFilter(),
        const SizedBox(width: 4),
        _buildSeverityFilter(),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return PopupMenuButton<String>(
      tooltip: 'Filter Tipe',
      icon: Icon(
        Icons.category,
        size: 20,
        color: _selectedTypeFilter != null ? Colors.blue[700] : Colors.grey[600],
      ),
      onSelected: (value) {
        setState(() {
          _selectedTypeFilter = value == 'ALL' ? null : value;
        });
        _loadData();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'ALL',
          child: Text('Semua Tipe'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'pohon_miring',
          child: Text('Pohon Miring'),
        ),
        const PopupMenuItem(
          value: 'pohon_mati',
          child: Text('Pohon Mati'),
        ),
        const PopupMenuItem(
          value: 'gambut_terpapar',
          child: Text('Gambut Terpapar'),
        ),
      ],
    );
  }

  Widget _buildSeverityFilter() {
    return PopupMenuButton<String>(
      tooltip: 'Filter Severity',
      icon: Icon(
        Icons.priority_high,
        size: 20,
        color: _selectedSeverityFilter != null ? Colors.red[700] : Colors.grey[600],
      ),
      onSelected: (value) {
        setState(() {
          _selectedSeverityFilter = value == 'ALL' ? null : value;
        });
        _loadData();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'ALL',
          child: Text('Semua Severity'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'KRITIS',
          child: Row(
            children: [
              Icon(Icons.error, size: 16, color: Colors.red[700]),
              const SizedBox(width: 8),
              const Text('Kritis'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'TINGGI',
          child: Row(
            children: [
              Icon(Icons.warning, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('Tinggi'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'SEDANG',
          child: Row(
            children: [
              Icon(Icons.info, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Sedang'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total',
              _data!.totalAnomalies.toString(),
              Icons.all_inbox,
              Colors.grey[700]!,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Kritis',
              _data!.kritisCount.toString(),
              Icons.error,
              Colors.red[700]!,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Tinggi',
              _data!.tinggiCount.toString(),
              Icons.warning,
              Colors.orange[700]!,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Sedang',
              _data!.sedangCount.toString(),
              Icons.info,
              Colors.blue[700]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
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

  Widget _buildAlertList() {
    if (_data!.anomalies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada anomali terdeteksi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua pohon dalam kondisi normal',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _data!.anomalies.length,
      itemBuilder: (context, index) {
        final anomaly = _data!.anomalies[index];
        final isExpanded = _expandedIds.contains(anomaly.id);
        
        return _buildAnomalyCard(anomaly, isExpanded);
      },
    );
  }

  Widget _buildAnomalyCard(AnomalyItem anomaly, bool isExpanded) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isExpanded ? 4 : 1,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedIds.remove(anomaly.id);
                } else {
                  _expandedIds.add(anomaly.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Icon(
                        _getIconFromName(anomaly.severityIconName),
                        color: _getColorFromString(anomaly.severityColorString),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anomaly.typeDisplayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${anomaly.affectedCount} pohon terdeteksi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorFromString(anomaly.severityColorString).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _getColorFromString(anomaly.severityColorString)),
                        ),
                        child: Text(
                          anomaly.severity,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getColorFromString(anomaly.severityColorString),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Criteria Info
                  if (anomaly.criteria.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.rule, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kriteria: ${anomaly.criteria}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Expanded Detail Section
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Affected Trees Section
                  if (anomaly.trees != null && anomaly.trees!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.forest, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Pohon Terdeteksi (${anomaly.trees!.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...anomaly.trees!.take(3).map((tree) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${tree.treeId} - ${tree.location.blok} (Row: ${tree.location.row}, Pos: ${tree.location.position})',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            if (tree.photoUrl != null)
                              Icon(Icons.photo, size: 14, color: Colors.blue[600]),
                          ],
                        ),
                      );
                    }).toList(),
                    if (anomaly.trees!.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 4),
                        child: Text(
                          '+${anomaly.trees!.length - 3} pohon lainnya',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onInvestigate != null
                              ? () => widget.onInvestigate!(anomaly)
                              : null,
                          icon: const Icon(Icons.search, size: 16),
                          label: const Text('Investigasi', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onCreateSpk != null
                              ? () => widget.onCreateSpk!(anomaly)
                              : null,
                          icon: const Icon(Icons.assignment, size: 16),
                          label: const Text('Buat SPK', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _expandedIds.remove(anomaly.id);
                          });
                        },
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Dismiss',
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
