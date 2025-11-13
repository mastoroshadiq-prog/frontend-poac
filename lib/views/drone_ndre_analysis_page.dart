import 'package:flutter/material.dart';
import '../../models/drone_ndre_tree.dart';
import '../../services/drone_ndre_service.dart';
import '../../widgets/create_spk_validasi_dialog.dart';

/// Drone NDRE Analysis Page
/// 
/// Fitur:
/// - List pohon dengan NDRE data
/// - Filter berdasarkan stress level, divisi, blok
/// - Selection-based Create SPK (checkbox + FAB)
/// - Filter-based Create SPK
/// - Statistics summary
/// - Pagination
class DroneNdreAnalysisPage extends StatefulWidget {
  const DroneNdreAnalysisPage({super.key});

  @override
  State<DroneNdreAnalysisPage> createState() => _DroneNdreAnalysisPageState();
}

class _DroneNdreAnalysisPageState extends State<DroneNdreAnalysisPage> {
  final DroneNdreService _service = DroneNdreService();
  
  List<DroneNdreTree> _trees = [];
  Map<String, int> _summary = {};
  Set<String> _selectedTreeIds = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filters
  String? _filterStressLevel;
  String? _filterDivisi;
  String? _filterBlok;
  
  // Pagination
  int _currentPage = 0;
  final int _itemsPerPage = 50;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final trees = await _service.getDroneNdreTrees(
        stressLevel: _filterStressLevel,
        divisi: _filterDivisi,
        blok: _filterBlok,
        limit: _itemsPerPage,
        offset: _currentPage * _itemsPerPage,
      );

      final summary = await _service.getStressLevelSummary(
        divisi: _filterDivisi,
        blok: _filterBlok,
      );

      if (mounted) {
        setState(() {
          _trees = trees;
          _summary = summary;
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

  void _toggleSelection(String treeId) {
    setState(() {
      if (_selectedTreeIds.contains(treeId)) {
        _selectedTreeIds.remove(treeId);
      } else {
        _selectedTreeIds.add(treeId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedTreeIds.length == _trees.length) {
        _selectedTreeIds.clear();
      } else {
        _selectedTreeIds = _trees.map((t) => t.idNpokok).toSet();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedTreeIds.clear();
    });
  }

  Future<void> _createSpkFromSelection() async {
    if (_selectedTreeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih minimal 1 pohon'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedTrees = _trees
        .where((t) => _selectedTreeIds.contains(t.idNpokok))
        .toList();

    await showDialog(
      context: context,
      builder: (context) => CreateSpkValidasiDialog(
        selectedTrees: selectedTrees,
        onSuccess: () {
          setState(() {
            _selectedTreeIds.clear();
          });
          _loadData(); // Refresh data
        },
      ),
    );
  }

  Future<void> _createSpkFromFilter() async {
    if (_filterStressLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih filter stress level terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Use all trees matching current filter
    await showDialog(
      context: context,
      builder: (context) => CreateSpkValidasiDialog(
        selectedTrees: _trees,
        onSuccess: () {
          _loadData(); // Refresh data
        },
      ),
    );
  }

  Color _getStressColor(String stressLevel) {
    switch (stressLevel) {
      case 'Stres Berat':
        return const Color(0xFFEF5350);
      case 'Stres Sedang':
        return const Color(0xFFFFC107);
      case 'Sehat':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  IconData _getStressIcon(String stressLevel) {
    switch (stressLevel) {
      case 'Stres Berat':
        return Icons.error_outline;
      case 'Stres Sedang':
        return Icons.warning_amber_outlined;
      case 'Sehat':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚁 Drone NDRE Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Analisis Kesehatan Pohon dari Scan Drone',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          // Statistics Summary
          _buildStatisticsSummary(),
          
          // Quick Actions Bar (when trees selected)
          if (_selectedTreeIds.isNotEmpty) _buildQuickActionsBar(),
          
          // Filters
          _buildFiltersBar(),
          
          // Tree List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildTreeList(),
          ),
        ],
      ),
      
      // Floating Action Button (when trees selected)
      floatingActionButton: _selectedTreeIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _createSpkFromSelection,
              icon: const Icon(Icons.add_task),
              label: Text('Create SPK (${_selectedTreeIds.length})'),
              backgroundColor: Colors.green[700],
            )
          : null,
    );
  }

  Widget _buildStatisticsSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Statistics Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Stres Berat',
                  _summary['Stres Berat'] ?? 0,
                  const Color(0xFFEF5350),
                  Icons.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Stres Sedang',
                  _summary['Stres Sedang'] ?? 0,
                  const Color(0xFFFFC107),
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Sehat',
                  _summary['Sehat'] ?? 0,
                  const Color(0xFF4CAF50),
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Text(
            '${_selectedTreeIds.length} pohon selected',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green[900],
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _clearSelection,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Clear'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Stress Level Filter
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _filterStressLevel,
              decoration: const InputDecoration(
                labelText: 'Filter: Stress Level',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                const DropdownMenuItem(
                    value: 'Stres Berat', child: Text('Stres Berat')),
                const DropdownMenuItem(
                    value: 'Stres Sedang', child: Text('Stres Sedang')),
                const DropdownMenuItem(value: 'Sehat', child: Text('Sehat')),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStressLevel = value;
                  _currentPage = 0;
                });
                _loadData();
              },
            ),
          ),
          
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: _selectAll,
                icon: Icon(
                  _selectedTreeIds.length == _trees.length
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                ),
                label: Text(
                  _selectedTreeIds.length == _trees.length
                      ? 'Deselect All'
                      : 'Select All',
                ),
              ),
              if (_filterStressLevel != null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _createSpkFromFilter,
                  icon: const Icon(Icons.add_task, size: 18),
                  label: const Text('Create SPK from Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreeList() {
    if (_trees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forest, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data pohon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trees.length,
      itemBuilder: (context, index) {
        final tree = _trees[index];
        final isSelected = _selectedTreeIds.contains(tree.idNpokok);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelection(tree.idNpokok),
              activeColor: Colors.green[700],
            ),
            title: Row(
              children: [
                Text(
                  tree.nomorPohon ?? tree.idNpokok.substring(0, 8),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStressColor(tree.stressLevel).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStressColor(tree.stressLevel),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStressIcon(tree.stressLevel),
                        size: 14,
                        color: _getStressColor(tree.stressLevel),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tree.stressLevel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStressColor(tree.stressLevel),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text('NDRE: ${tree.ndreValue.toStringAsFixed(2)}'),
                  const SizedBox(width: 16),
                  if (tree.blok != null) Text('Blok: ${tree.blok}'),
                  const SizedBox(width: 16),
                  if (tree.divisi != null) Text('Divisi: ${tree.divisi}'),
                ],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // TODO: Show tree detail modal
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: TextStyle(color: Colors.grey[600]),
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
    );
  }
}
