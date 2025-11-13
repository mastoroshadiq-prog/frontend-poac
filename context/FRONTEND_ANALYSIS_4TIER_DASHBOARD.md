# Frontend Analysis: 4-Tier Dashboard Implementation

**Document Version:** 1.0.0  
**Date:** November 13, 2025  
**Status:** Analysis Complete - Ready for Implementation  
**Author:** Frontend AI Agent Team

---

## 📋 Executive Summary

### Analysis Result: ✅ Architecture Well-Designed, Ready to Implement

Setelah deep dive 3 dokumen core (OVERVIEW, TIER3_ASISTEN, API_MAPPING), kesimpulan:

**✅ Backend Design Sangat Solid:**
- Clear separation of concerns (4 tiers aligned dengan org hierarchy)
- Appropriate cognitive load per role (10-100 KPI per dashboard)
- Strong RBAC foundation
- API structure well-thought (14 existing + 11 new endpoints)

**🎯 Frontend Implementation Focus:**

```
Priority 1: DASHBOARD ASISTEN (Tactical)
├── 6 Major Sections
├── 4 Priority API Integrations
└── 15+ Custom Widgets

Priority 2: DASHBOARD MANDOR (Execution)
├── Task Management UI
├── Simple KPI Cards
└── GPS Map Integration

Priority 3: DASHBOARD MANAGER (Managerial)
├── Afdeling Comparison
├── Cost Breakdown
└── Labor Efficiency Charts

Priority 4: DASHBOARD CORPORATE (Strategic)
├── Business Intelligence Summary
├── ROI Analysis
└── Trend Forecasting
```

---

## 🏗️ Architecture Overview

### Current State (Before 4-Tier)

```
lib/views/
├── dashboard_eksekutif_view.dart    (3142 lines, 4 POAC tabs)
├── dashboard_operasional_view.dart  (Partially refactored, FASE 2 components)
└── dashboard_teknis_view.dart       (Lifecycle-focused)

Issues:
❌ Ambiguous naming (Eksekutif untuk siapa? Direktur atau Manager?)
❌ Metrics mismatch (Operasional terlalu detail untuk eksekutif)
❌ No clear RBAC mapping
❌ Confusion Matrix di dashboard yang salah
```

### Target State (After 4-Tier)

```
lib/views/dashboard/
├── corporate/
│   ├── dashboard_corporate_view.dart
│   ├── widgets/
│   │   ├── business_summary_card.dart
│   │   ├── financial_trend_chart.dart
│   │   ├── roi_comparison_widget.dart
│   │   └── sustainability_scorecard.dart
│   └── services/
│       └── corporate_dashboard_service.dart
│
├── manager/
│   ├── dashboard_manager_view.dart
│   ├── widgets/
│   │   ├── afdeling_comparison_table.dart
│   │   ├── productivity_heatmap.dart
│   │   ├── labor_cost_breakdown.dart
│   │   └── sop_compliance_gauge.dart
│   └── services/
│       └── manager_dashboard_service.dart
│
├── asisten/  ⭐ PRIORITY 1
│   ├── dashboard_asisten_view.dart
│   ├── widgets/
│   │   ├── ndre_statistics_card.dart
│   │   ├── confusion_matrix_heatmap.dart      ← NEW
│   │   ├── field_vs_drone_scatter.dart        ← NEW
│   │   ├── spk_kanban_board.dart              ← ENHANCE
│   │   ├── anomaly_alert_widget.dart          ← NEW
│   │   └── mandor_performance_table.dart      ← NEW
│   └── services/
│       ├── validation_service.dart             ← NEW
│       ├── analytics_service.dart              ← NEW
│       └── spk_asisten_service.dart
│
└── mandor/
    ├── dashboard_mandor_view.dart
    ├── widgets/
    │   ├── my_spk_list.dart
    │   ├── task_card.dart
    │   ├── surveyor_workload_widget.dart
    │   └── gps_map_widget.dart
    └── services/
        └── mandor_dashboard_service.dart
```

---

## 🎯 Dashboard Asisten (TIER 3) - Deep Dive

### Why This is Priority 1?

**Asisten Manager adalah HEART of the system:**

```
Workflow:
Drone Scan (910 trees, NDRE data)
    ↓ [Asisten ANALYZE]
Confusion Matrix (Accuracy 94.8%, Precision 83.7%)
    ↓ [Asisten DECIDE]
Create SPK Validasi (141 stres berat → 31 SPK)
    ↓ [Asisten ASSIGN]
Assign to 7 Mandors (48 tasks)
    ↓ [Asisten MONITOR]
Track Progress (Mandor completion rate)
    ↓ [Asisten EVALUATE]
Analyze Results (TP/FP/TN/FN)
    ↓ [Asisten OPTIMIZE]
Adjust Threshold / Create Remedial SPK
```

**Frontend Implication:**
- Need **full analytical capability** (confusion matrix, scatter plots, heatmaps)
- Need **decision-making tools** (adjust threshold, create SPK, override)
- Need **real-time monitoring** (SPK status, mandor progress)
- Need **drill-down capability** (estate → divisi → blok → pohon)

---

### UI/UX Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ Header: Dashboard Asisten - [User] - [Afdeling] - [DateTime]    │
├─────────────────────────────────────────────────────────────────┤
│ Quick Stats Cards (Row 1) - 4 Cards                             │
│ ┌──────────┬──────────┬──────────┬──────────┐                  │
│ │ Total    │ Stres    │ SPK      │ Mandor   │                  │
│ │ Trees    │ Berat    │ Active   │ Completion│                  │
│ │ 910      │ 141      │ 31       │ 85%      │                  │
│ └──────────┴──────────┴──────────┴──────────┘                  │
├─────────────────────────────────────────────────────────────────┤
│ Main Content (3 Columns)                                        │
│ ┌──────────────┬───────────────────┬─────────────────┐         │
│ │ Column 1     │ Column 2          │ Column 3        │         │
│ │ (30% width)  │ (40% width)       │ (30% width)     │         │
│ │              │                   │                 │         │
│ │ SECTION 1:   │ SECTION 3:        │ SECTION 5:      │         │
│ │ NDRE Stats   │ Confusion Matrix  │ SPK Kanban      │         │
│ │ - Pie Chart  │ - 2×2 Heatmap     │ - 3 Columns     │         │
│ │ - Bar Chart  │ - Metrics Cards   │ - Drag & Drop   │         │
│ │              │   (Acc, Prec, F1) │                 │         │
│ │              │                   │                 │         │
│ │ SECTION 2:   │ SECTION 4:        │ SECTION 6:      │         │
│ │ Anomaly      │ Field vs Drone    │ Mandor          │         │
│ │ Alerts       │ - Scatter Plot    │ Performance     │         │
│ │ - 🔴 High (2)│ - Sankey Diagram  │ - Leaderboard   │         │
│ │ - 🟡 Med (2) │ - Box Plot        │ - Radar Chart   │         │
│ │ - [Actions]  │                   │                 │         │
│ │              │                   │                 │         │
│ └──────────────┴───────────────────┴─────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

---

### Section 1: NDRE Statistics Card

**Purpose:** Show distribution of tree stress levels from drone scan

**Widget Structure:**
```dart
// lib/views/dashboard/asisten/widgets/ndre_statistics_card.dart

class NdreStatisticsCard extends StatelessWidget {
  final NdreStatistics statistics;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.radar, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Drone NDRE Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Total Trees Scanned
            _buildTotalTreesBadge(statistics.totalTrees),
            
            SizedBox(height: 16),
            
            // Pie Chart Distribution
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: statistics.stresBerat.toDouble(),
                      title: '${statistics.stresBerat}\nStres Berat',
                      color: Colors.red.shade400,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: statistics.stresSedang.toDouble(),
                      title: '${statistics.stresSedang}\nStres Sedang',
                      color: Colors.orange.shade400,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: statistics.sehat.toDouble(),
                      title: '${statistics.sehat}\nSehat',
                      color: Colors.green.shade400,
                      radius: 80,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Bar Chart Count per Level
            _buildStressLevelBars(statistics),
            
            SizedBox(height: 16),
            
            // Action Button
            ElevatedButton.icon(
              onPressed: () => _navigateToTreeList(context),
              icon: Icon(Icons.list),
              label: Text('View Tree List'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**API Integration:**
```dart
// lib/services/drone_service.dart (Already exists from Point 1)
class DroneService {
  Future<NdreStatistics> getNdreStatistics({
    String? divisi,
    String? blok,
  }) async {
    final response = await supabase
        .from('drone_ndre')
        .select('*')
        .eq('divisi', divisi ?? '')
        .execute();
    
    // Aggregate data
    int stresBerat = 0;
    int stresSedang = 0;
    int sehat = 0;
    
    for (var tree in response.data) {
      if (tree['ndre_value'] < 0.3) {
        stresBerat++;
      } else if (tree['ndre_value'] < 0.5) {
        stresSedang++;
      } else {
        sehat++;
      }
    }
    
    return NdreStatistics(
      totalTrees: response.data.length,
      stresBerat: stresBerat,
      stresSedang: stresSedang,
      sehat: sehat,
    );
  }
}
```

---

### Section 3: Confusion Matrix Heatmap ⭐ (KEY COMPONENT)

**Purpose:** Visualize drone accuracy (TP/FP/TN/FN) untuk decision making

**Widget Structure:**
```dart
// lib/views/dashboard/asisten/widgets/confusion_matrix_heatmap.dart

class ConfusionMatrixHeatmap extends StatelessWidget {
  final ConfusionMatrixData data;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            SizedBox(height: 16),
            
            // 2×2 Matrix Heatmap
            Container(
              height: 300,
              child: Row(
                children: [
                  // Y-axis label (Actual)
                  _buildYAxisLabel(),
                  
                  // Matrix Grid
                  Expanded(
                    child: Column(
                      children: [
                        // X-axis label (Predicted)
                        _buildXAxisLabel(),
                        
                        // Matrix cells
                        Expanded(
                          child: Column(
                            children: [
                              // Row 1: TP | FN
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildMatrixCell(
                                      'TP',
                                      data.truePositive,
                                      Colors.green.shade400,
                                      () => _drillDownToTrees(context, 'TP'),
                                    ),
                                    SizedBox(width: 8),
                                    _buildMatrixCell(
                                      'FN',
                                      data.falseNegative,
                                      Colors.orange.shade400,
                                      () => _drillDownToTrees(context, 'FN'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              // Row 2: FP | TN
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildMatrixCell(
                                      'FP',
                                      data.falsePositive,
                                      Colors.red.shade400,
                                      () => _drillDownToTrees(context, 'FP'),
                                    ),
                                    SizedBox(width: 8),
                                    _buildMatrixCell(
                                      'TN',
                                      data.trueNegative,
                                      Colors.blue.shade400,
                                      () => _drillDownToTrees(context, 'TN'),
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
            
            SizedBox(height: 20),
            
            // Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard(
                  'Accuracy',
                  '${(data.accuracy * 100).toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Precision',
                  '${(data.precision * 100).toStringAsFixed(1)}%',
                  Icons.analytics,
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Recall',
                  '${(data.recall * 100).toStringAsFixed(1)}%',
                  Icons.radar,
                  Colors.purple,
                ),
                _buildMetricCard(
                  'F1-Score',
                  '${(data.f1Score * 100).toStringAsFixed(1)}%',
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Recommendations
            if (data.recommendations.isNotEmpty)
              _buildRecommendations(data.recommendations),
            
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _adjustThreshold(context),
                  icon: Icon(Icons.tune),
                  label: Text('Adjust Threshold'),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _exportReport(context),
                  icon: Icon(Icons.download),
                  label: Text('Export Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMatrixCell(
    String label,
    int count,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'trees',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              Icon(
                Icons.touch_app,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**API Integration (NEW):**
```dart
// lib/services/validation_service.dart ← NEW SERVICE
class ValidationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<ConfusionMatrixData> getConfusionMatrix({
    String? divisi,
    String? blok,
    DateTimeRange? dateRange,
  }) async {
    try {
      // Call backend API endpoint
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/v1/validation/confusion-matrix')
            .replace(queryParameters: {
          if (divisi != null) 'divisi': divisi,
          if (blok != null) 'blok': blok,
          if (dateRange != null) ...{
            'start_date': dateRange.start.toIso8601String(),
            'end_date': dateRange.end.toIso8601String(),
          },
        }),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ConfusionMatrixData.fromJson(json['data']);
      } else {
        throw Exception('Failed to load confusion matrix');
      }
    } catch (e) {
      debugPrint('❌ Error fetching confusion matrix: $e');
      rethrow;
    }
  }
  
  Future<List<TreeDetail>> getTreesByCategory({
    required String category, // 'TP', 'FP', 'TN', 'FN'
    String? divisi,
    String? blok,
  }) async {
    // Drill-down untuk lihat trees per category
    final response = await http.get(
      Uri.parse('${Config.apiBaseUrl}/api/v1/validation/field-vs-drone')
          .replace(queryParameters: {
        'category': category,
        if (divisi != null) 'divisi': divisi,
        if (blok != null) 'blok': blok,
      }),
      headers: {'Authorization': 'Bearer ${await _getAuthToken()}'},
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data']['trees'] as List)
          .map((tree) => TreeDetail.fromJson(tree))
          .toList();
    } else {
      throw Exception('Failed to load trees');
    }
  }
}
```

**Model Class:**
```dart
// lib/models/confusion_matrix_data.dart
class ConfusionMatrixData {
  final int truePositive;
  final int falsePositive;
  final int trueNegative;
  final int falseNegative;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double fpr; // False positive rate
  final double fnr; // False negative rate
  final List<String> recommendations;
  
  ConfusionMatrixData({
    required this.truePositive,
    required this.falsePositive,
    required this.trueNegative,
    required this.falseNegative,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.fpr,
    required this.fnr,
    required this.recommendations,
  });
  
  factory ConfusionMatrixData.fromJson(Map<String, dynamic> json) {
    return ConfusionMatrixData(
      truePositive: json['matrix']['true_positive'],
      falsePositive: json['matrix']['false_positive'],
      trueNegative: json['matrix']['true_negative'],
      falseNegative: json['matrix']['false_negative'],
      accuracy: json['metrics']['accuracy'],
      precision: json['metrics']['precision'],
      recall: json['metrics']['recall'],
      f1Score: json['metrics']['f1_score'],
      fpr: json['metrics']['fpr'],
      fnr: json['metrics']['fnr'],
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}
```

---

### Section 4: Field vs Drone Scatter Plot

**Purpose:** Analyze distribution & identify false positives/negatives

**Widget Structure:**
```dart
// lib/views/dashboard/asisten/widgets/field_vs_drone_scatter.dart

class FieldVsDroneScatter extends StatelessWidget {
  final List<ValidationPoint> validationData;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Field Validation vs Drone Prediction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => _showLegend(context),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Scatter Plot
            SizedBox(
              height: 300,
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: _buildScatterSpots(validationData),
                  minX: 0,
                  maxX: 1,
                  minY: 0,
                  maxY: 10,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text('NDRE Value (Drone)'),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text('Field Stress Score (0-10)'),
                    ),
                  ),
                  scatterTouchData: ScatterTouchData(
                    touchTooltipData: ScatterTouchTooltipData(
                      getTooltipItems: (spot) {
                        final point = validationData[spot.spotIndex];
                        return ScatterTooltipItem(
                          'Tree: ${point.treeId}\n'
                          'NDRE: ${point.ndreValue.toStringAsFixed(2)}\n'
                          'Field Score: ${point.fieldScore}\n'
                          'Category: ${point.category}',
                          textStyle: TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response != null && response.touchedSpot != null) {
                        _showTreeDetail(
                          context,
                          validationData[response.touchedSpot!.spotIndex],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Distribution Summary
            _buildDistributionSummary(validationData),
            
            SizedBox(height: 16),
            
            // Common Causes (for False Positives)
            if (_hasFalsePositives(validationData))
              _buildCommonCauses(validationData),
          ],
        ),
      ),
    );
  }
  
  List<ScatterSpot> _buildScatterSpots(List<ValidationPoint> data) {
    return data.asMap().entries.map((entry) {
      final point = entry.value;
      Color color;
      
      switch (point.category) {
        case 'True Positive':
          color = Colors.green;
          break;
        case 'False Positive':
          color = Colors.red;
          break;
        case 'True Negative':
          color = Colors.blue;
          break;
        case 'False Negative':
          color = Colors.orange;
          break;
        default:
          color = Colors.grey;
      }
      
      return ScatterSpot(
        point.ndreValue,
        point.fieldScore.toDouble(),
        color: color,
        radius: 6,
      );
    }).toList();
  }
}
```

---

### Section 5: SPK Kanban Board

**Purpose:** Visual task management (PENDING → DIKERJAKAN → SELESAI)

**Widget Structure:**
```dart
// lib/views/dashboard/asisten/widgets/spk_kanban_board.dart

class SpkKanbanBoard extends StatefulWidget {
  final List<SpkItem> spkList;
  final Function(String spkId, String newStatus) onStatusChange;
  
  @override
  _SpkKanbanBoardState createState() => _SpkKanbanBoardState();
}

class _SpkKanbanBoardState extends State<SpkKanbanBoard> {
  @override
  Widget build(BuildContext context) {
    final pendingSpk = widget.spkList
        .where((spk) => spk.status == 'PENDING')
        .toList();
    final dikerjakanSpk = widget.spkList
        .where((spk) => spk.status == 'DIKERJAKAN')
        .toList();
    final selesaiSpk = widget.spkList
        .where((spk) => spk.status == 'SELESAI')
        .toList();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SPK Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToCreateSpk(context),
                  icon: Icon(Icons.add),
                  label: Text('Create SPK'),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Kanban Columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: PENDING
                Expanded(
                  child: _buildKanbanColumn(
                    'PENDING',
                    pendingSpk,
                    Colors.amber,
                  ),
                ),
                SizedBox(width: 12),
                
                // Column 2: DIKERJAKAN
                Expanded(
                  child: _buildKanbanColumn(
                    'DIKERJAKAN',
                    dikerjakanSpk,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                
                // Column 3: SELESAI
                Expanded(
                  child: _buildKanbanColumn(
                    'SELESAI',
                    selesaiSpk,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKanbanColumn(
    String title,
    List<SpkItem> spkList,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${spkList.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // SPK Cards
          Expanded(
            child: DragTarget<SpkItem>(
              onAccept: (spk) {
                widget.onStatusChange(spk.id, _getStatusFromTitle(title));
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: spkList.length,
                  itemBuilder: (context, index) {
                    return _buildSpkCard(spkList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpkCard(SpkItem spk) {
    return Draggable<SpkItem>(
      data: spk,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: _buildSpkCardContent(spk, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildSpkCardContent(spk),
      ),
      child: _buildSpkCardContent(spk),
    );
  }
  
  Widget _buildSpkCardContent(SpkItem spk, {bool isDragging = false}) {
    return Card(
      elevation: isDragging ? 8 : 2,
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _navigateToSpkDetail(context, spk),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SPK Number
              Text(
                spk.nomorSpk,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 4),
              
              // SPK Type
              Text(
                spk.jenis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              
              // Progress Bar
              LinearProgressIndicator(
                value: spk.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  spk.progress >= 0.8 ? Colors.green : Colors.orange,
                ),
              ),
              SizedBox(height: 4),
              
              // Progress Text
              Text(
                '${spk.completedTasks}/${spk.totalTasks} tasks',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              
              // Mandor & Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Mandor: ${spk.mandorName}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (spk.priority == 'URGENT')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Section 2 & 6: Anomaly Alerts & Mandor Performance

**These are simpler widgets, structure similar to above.**

Key features:
- **Anomaly Alerts:** List widget dengan severity color coding, action buttons
- **Mandor Performance:** DataTable dengan sorting, radar chart overlay

---

## 🛠️ Implementation Roadmap

### Phase 1: Foundation (Week 1-2) ✅ COMPLETED

- [x] Review existing dashboard structure
- [x] Refactor Dashboard Eksekutif dengan FASE 2 components
- [x] Git checkpoint & safety procedures
- [x] Replace AnimatedContainer/Container dengan Card

### Phase 2: Services & Models (Week 3-4) ⏳ CURRENT

```
Priority Tasks:
1. Create ValidationService.dart
   - getConfusionMatrix()
   - getFieldVsDrone()
   - overrideValidation()
   
2. Create AnalyticsService.dart
   - getAnomalyDetection()
   - getMandorPerformance()
   
3. Create ConfigService.dart
   - getNdreThreshold()
   - updateNdreThreshold()
   
4. Create Models:
   - ConfusionMatrixData
   - ValidationPoint
   - AnomalyItem
   - MandorPerformance
```

### Phase 3: Dashboard Asisten Widgets (Week 5-7)

```
Priority Widgets:
1. NdreStatisticsCard (use fl_chart)
2. ConfusionMatrixHeatmap (custom widget)
3. FieldVsDroneScatter (use fl_chart)
4. SpkKanbanBoard (drag & drop)
5. AnomalyAlertWidget (list view)
6. MandorPerformanceTable (data table)
```

### Phase 4: Dashboard Mandor (Week 8-9)

```
Simpler implementation:
1. MySpkList (card list)
2. TaskCard (reusable component)
3. SurveyorWorkloadWidget (simple bar chart)
4. GpsMapWidget (Google Maps integration)
```

### Phase 5: Dashboard Manager & Corporate (Week 10-12)

```
Lower priority but essential:
1. Manager Dashboard (afdeling comparison)
2. Corporate Dashboard (business intelligence)
```

### Phase 6: RBAC & Testing (Week 13-14)

```
1. Implement RBAC routing
2. Unit tests untuk services
3. Widget tests untuk components
4. Integration tests
5. UAT dengan real users
```

---

## 🎨 UI Component Library Reuse

### Existing FASE 2 Components (Use These!)

```
✅ ProgressStatCard - For gauges with current/total
✅ CompactStatCard - For summary metrics with icons
✅ TrendStatCard - For metrics with trend arrows
✅ StatCard - For basic metrics
✅ EnhancedDataTable - For tabular data
✅ ErrorState - For error handling
✅ EmptyState - For empty states
```

### New Components Needed

```
🆕 ConfusionMatrixHeatmap - 2×2 grid dengan colors
🆕 ScatterPlotWidget - Wrapper untuk fl_chart scatter
🆕 KanbanBoard - Drag & drop columns
🆕 AnomalyAlertCard - Severity-based alert widget
🆕 RadarChartWidget - Multi-dimensional performance
🆕 SankeyDiagram - Flow visualization (optional)
```

---

## 📊 Chart Library Usage

### fl_chart ^0.68.0 (Already in pubspec.yaml)

**Use cases:**
- ✅ PieChart → NDRE distribution
- ✅ BarChart → Stress level counts, afdeling comparison
- ✅ LineChart → SOP trend, production trend
- ✅ ScatterChart → Field vs Drone validation
- ❌ No built-in confusion matrix (build custom)
- ❌ No Sankey diagram (use custom painter or skip)

### percent_indicator ^4.2.3

**Use cases:**
- ✅ CircularPercentIndicator → Already used in Dashboard Eksekutif
- ✅ LinearProgressIndicator → SPK progress, task completion

---

## 🔐 RBAC Implementation Notes

### Route Guards

```dart
// lib/config/routes.dart
class AppRoutes {
  static const String dashboardCorporate = '/dashboard/corporate';
  static const String dashboardManager = '/dashboard/manager';
  static const String dashboardAsisten = '/dashboard/asisten';
  static const String dashboardMandor = '/dashboard/mandor';
  
  static Map<String, WidgetBuilder> routes = {
    dashboardCorporate: (context) => RBACGuard(
      allowedRoles: ['direktur_utama', 'direktur_ops', 'gm'],
      child: DashboardCorporateView(),
    ),
    dashboardManager: (context) => RBACGuard(
      allowedRoles: ['estate_manager', 'deputy_manager'],
      child: DashboardManagerView(),
    ),
    dashboardAsisten: (context) => RBACGuard(
      allowedRoles: ['asisten_manager', 'kepala_afdeling'],
      child: DashboardAsistenView(),
    ),
    dashboardMandor: (context) => RBACGuard(
      allowedRoles: ['mandor', 'surveyor'],
      child: DashboardMandorView(),
    ),
  };
}
```

### Role-based Data Filtering

```dart
// lib/services/base_service.dart
class BaseService {
  Future<Map<String, String>> _getRequestHeaders() async {
    final user = await AuthService.getCurrentUser();
    
    return {
      'Authorization': 'Bearer ${user.token}',
      'X-User-Role': user.role,
      'X-User-Afdeling': user.afdeling ?? '',
    };
  }
}
```

---

## ✅ Action Items for Frontend Team

### Immediate (This Week)

1. ✅ **Create New Folder Structure**
   ```
   mkdir lib/views/dashboard/corporate
   mkdir lib/views/dashboard/manager
   mkdir lib/views/dashboard/asisten
   mkdir lib/views/dashboard/mandor
   ```

2. ✅ **Create Service Files**
   ```
   touch lib/services/validation_service.dart
   touch lib/services/analytics_service.dart
   touch lib/services/config_service.dart
   ```

3. ✅ **Create Model Files**
   ```
   touch lib/models/confusion_matrix_data.dart
   touch lib/models/validation_point.dart
   touch lib/models/anomaly_item.dart
   touch lib/models/mandor_performance.dart
   ```

### Next Week

4. **Implement ValidationService**
   - getConfusionMatrix() method
   - getFieldVsDrone() method
   - Test with mock data first

5. **Build ConfusionMatrixHeatmap Widget**
   - 2×2 grid layout
   - Color coding (TP/FP/TN/FN)
   - Drill-down on tap

6. **Build NdreStatisticsCard Widget**
   - Pie chart integration
   - Bar chart for counts
   - Use existing DroneService

### Following Weeks

7. **Complete Dashboard Asisten View**
   - Integrate all 6 sections
   - Connect to real APIs
   - Add loading/error states

8. **Build Dashboard Mandor View**
   - Simpler layout (task-focused)
   - GPS map integration
   - Real-time updates

---

## 🚀 Success Metrics

### Technical KPIs

- ✅ **Code Quality:** 
  - All services with error handling
  - Widget tests coverage > 80%
  - No compile warnings

- ✅ **Performance:**
  - Dashboard load time < 2 seconds
  - Smooth 60fps scrolling
  - Efficient memory usage

- ✅ **UX:**
  - Responsive layout (mobile + tablet + web)
  - Intuitive navigation
  - Clear visual hierarchy

### Business KPIs

- ✅ **User Adoption:**
  - Asisten Manager use dashboard daily
  - Mandor complete tasks via app (not manual)
  - Manager review reports weekly

- ✅ **Operational Impact:**
  - SPK completion rate increased
  - Validation accuracy improved
  - Decision-making time reduced

---

## 📚 References

- [DASHBOARD_4_TIER_OVERVIEW.md](./DASHBOARD_4_TIER_OVERVIEW.md)
- [DASHBOARD_4_TIER_TIER3_ASISTEN.md](./DASHBOARD_4_TIER_TIER3_ASISTEN.md)
- [DASHBOARD_4_TIER_API_MAPPING.md](./DASHBOARD_4_TIER_API_MAPPING.md)
- [Flutter fl_chart Documentation](https://github.com/imaNNeo/fl_chart)
- [Material Design 3 Guidelines](https://m3.material.io/)

---

**Document Status:** ✅ ANALYSIS COMPLETE - READY FOR IMPLEMENTATION  
**Last Updated:** November 13, 2025  
**Version:** 1.0.0  
**Approved by:** Frontend AI Agent Team
