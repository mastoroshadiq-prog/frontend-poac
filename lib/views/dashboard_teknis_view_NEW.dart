import 'package:flutter/material.dart';
import 'dashboard/asisten/widgets/confusion_matrix_heatmap.dart';
import 'dashboard/asisten/widgets/ndre_statistics_card.dart';
import 'dashboard/asisten/widgets/field_vs_drone_scatter.dart';
import 'dashboard/asisten/widgets/spk_kanban_board.dart';
import 'dashboard/asisten/widgets/anomaly_alert_widget.dart';
import 'dashboard/asisten/widgets/mandor_performance_table.dart';
import '../widgets/dashboard_layout.dart';

/// Dashboard Asisten (Tier 3) - Tactical Operations
/// 
/// Dashboard untuk Asisten Manager yang menampilkan:
/// - Validasi drone vs field (accuracy monitoring)
/// - NDRE statistics & health monitoring
/// - SPK management (kanban board)
/// - Anomaly detection & alerts
/// - Mandor performance tracking
/// 
/// Layout: 3-kolom responsif
/// - Left (30%): ConfusionMatrix, NdreStatistics
/// - Center (40%): FieldVsDroneScatter, SpkKanban
/// - Right (30%): AnomalyAlerts, MandorPerformance
/// 
/// RBAC: Memerlukan role ASISTEN atau ADMIN
class DashboardTeknisView extends StatefulWidget {
  final String token;

  const DashboardTeknisView({
    super.key,
    required this.token,
  });

  @override
  State<DashboardTeknisView> createState() => _DashboardTeknisViewState();
}

class _DashboardTeknisViewState extends State<DashboardTeknisView> {
  // Global filters
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedDivisi;
  
  // Refresh counter for force refresh
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    // Default: last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  Future<void> _refreshAll() async {
    // Trigger refresh on all widgets by rebuilding
    setState(() {
      _refreshCounter++;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Dashboard Asisten (Tactical Operations)',
      currentRoute: '/dashboard-teknis',
      breadcrumbs: const [
        BreadcrumbItem(label: 'Home'),
        BreadcrumbItem(label: 'Dashboard Asisten'),
      ],
      actions: [
        // Date Range Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _startDate != null && _endDate != null
                          ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                          : 'Pilih Tanggal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Divisi Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: DropdownButton<String>(
                value: _selectedDivisi,
                hint: const Text(
                  'All Divisi',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                underline: const SizedBox.shrink(),
                dropdownColor: Colors.green[700],
                style: const TextStyle(fontSize: 12, color: Colors.white),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Divisi'),
                  ),
                  ...['Divisi 1', 'Divisi 2', 'Divisi 3', 'Divisi 4']
                      .map((divisi) => DropdownMenuItem<String>(
                            value: divisi,
                            child: Text(divisi),
                          ))
                      ,
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDivisi = value;
                  });
                },
              ),
            ),
          ),
        ),
        // Refresh Button
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshAll,
          tooltip: 'Refresh All Data',
        ),
      ],
      onNavigate: (route) {
        Navigator.of(context).pushNamed(
          route,
          arguments: {'token': widget.token},
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (30%) - Validation & Health
            Expanded(
              flex: 30,
              child: Column(
                children: [
                  // Confusion Matrix Heatmap
                  ConfusionMatrixHeatmap(
                    key: ValueKey('confusion_$_refreshCounter'),
                  ),
                  const SizedBox(height: 16),
                  // NDRE Statistics Card
                  NdreStatisticsCard(
                    key: ValueKey('ndre_$_refreshCounter'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Center Column (40%) - Analysis & Tasks
            Expanded(
              flex: 40,
              child: Column(
                children: [
                  // Field vs Drone Scatter Plot
                  FieldVsDroneScatter(
                    key: ValueKey('scatter_$_refreshCounter'),
                  ),
                  const SizedBox(height: 16),
                  // SPK Kanban Board
                  SpkKanbanBoard(
                    key: ValueKey('kanban_$_refreshCounter'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Column (30%) - Alerts & Performance
            Expanded(
              flex: 30,
              child: Column(
                children: [
                  // Anomaly Alert Widget
                  AnomalyAlertWidget(
                    key: ValueKey('anomaly_$_refreshCounter'),
                  ),
                  const SizedBox(height: 16),
                  // Mandor Performance Table
                  MandorPerformanceTable(
                    key: ValueKey('performance_$_refreshCounter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
