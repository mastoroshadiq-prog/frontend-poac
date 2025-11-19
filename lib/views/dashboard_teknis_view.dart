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
/// Layout: Grid 3 baris × 2 kolom (50%-50%)
/// - Baris 1: ConfusionMatrix | FieldVsDroneScatter
/// - Baris 2: NdreStatistics | SpkKanban
/// - Baris 3: AnomalyAlerts | MandorPerformance
/// 
/// RBAC: Memerlukan role ASISTEN atau ADMIN
class DashboardTeknisView extends StatefulWidget {
  final String token;
  final String? userRole; // User role untuk filtering sidebar menu

  const DashboardTeknisView({
    super.key,
    required this.token,
    this.userRole,
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
      userRole: widget.userRole, // Pass role for sidebar filtering
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
          arguments: {'token': widget.token, 'userRole': widget.userRole},
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Account for padding (16px on each side = 32px total) and gap (16px × 1 = 16px)
          final availableWidth = constraints.maxWidth - 32 - 16; // padding + gap
          final columnWidth = availableWidth / 2; // 50% each column
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Baris 1: Confusion Matrix | Field vs Drone Scatter
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: columnWidth,
                      child: ConfusionMatrixHeatmap(
                        key: ValueKey('confusion_$_refreshCounter'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: columnWidth,
                      child: FieldVsDroneScatter(
                        key: ValueKey('scatter_$_refreshCounter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Baris 2: NDRE Statistics | SPK Kanban Board
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: columnWidth,
                      child: NdreStatisticsCard(
                        key: ValueKey('ndre_$_refreshCounter'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: columnWidth,
                      child: SpkKanbanBoard(
                        key: ValueKey('kanban_$_refreshCounter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Baris 3: Anomaly Alerts | Mandor Performance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: columnWidth,
                      child: AnomalyAlertWidget(
                        key: ValueKey('anomaly_$_refreshCounter'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: columnWidth,
                      child: MandorPerformanceTable(
                        key: ValueKey('performance_$_refreshCounter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
