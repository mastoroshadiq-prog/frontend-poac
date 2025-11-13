import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../services/spk_service.dart';
import '../../../../models/spk_kanban_data.dart';

/// Widget Kanban Board untuk SPK Management
/// 
/// Fitur:
/// - 3 kolom kanban: PENDING, DIKERJAKAN, SELESAI
/// - Drag & drop cards antar kolom
/// - SPK cards dengan progress indicators
/// - Filter by tipe SPK, divisi, blok
/// - Statistics summary di header
/// - Color-coded priorities dan status
/// - Loading, error, dan refresh states
class SpkKanbanBoard extends StatefulWidget {
  final String? divisi;
  final String? blok;
  final String? tipeSpk;
  final Function(SpkCard)? onCardTap;

  const SpkKanbanBoard({
    super.key,
    this.divisi,
    this.blok,
    this.tipeSpk,
    this.onCardTap,
  });

  @override
  State<SpkKanbanBoard> createState() => _SpkKanbanBoardState();
}

class _SpkKanbanBoardState extends State<SpkKanbanBoard> {
  final SPKService _spkService = SPKService();
  SpkKanbanData? _data;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedTipeFilter;

  @override
  void initState() {
    super.initState();
    _selectedTipeFilter = widget.tipeSpk;
    _loadData();
  }

  @override
  void didUpdateWidget(SpkKanbanBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.divisi != widget.divisi ||
        oldWidget.blok != widget.blok ||
        oldWidget.tipeSpk != widget.tipeSpk) {
      _selectedTipeFilter = widget.tipeSpk;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _spkService.getSpkKanban(
        divisi: widget.divisi,
        blok: widget.blok,
        tipeSpk: _selectedTipeFilter,
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

  Future<void> _updateSpkStatus(SpkCard card, String newStatus) async {
    try {
      final success = await _spkService.updateSpkStatus(card.idSpk, newStatus);
      if (success) {
        // Reload data after successful update
        _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SPK ${card.nomorSpk} dipindahkan ke $newStatus'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate SPK: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
            if (_data != null) _buildStatistics(),
            const SizedBox(height: 16),
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_data != null)
              Expanded(child: _buildKanbanBoard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.view_kanban,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPK Kanban Board',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_data != null)
                Text(
                  '${_data!.statistics.totalSpk} SPK aktif',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
        _buildTipeFilter(),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildTipeFilter() {
    return PopupMenuButton<String>(
      tooltip: 'Filter Tipe SPK',
      icon: Icon(
        Icons.filter_list,
        color: _selectedTipeFilter != null ? Colors.blue[700] : Colors.grey[600],
      ),
      onSelected: (value) {
        setState(() {
          _selectedTipeFilter = value == 'ALL' ? null : value;
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
              Text('Semua Tipe'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'VALIDASI',
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text('Validasi'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'APH',
          child: Row(
            children: [
              Icon(Icons.agriculture, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text('APH'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'SANITASI',
          child: Row(
            children: [
              Icon(Icons.cleaning_services, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text('Sanitasi'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'PANEN',
          child: Row(
            children: [
              Icon(Icons.shopping_basket, size: 20, color: Colors.purple),
              SizedBox(width: 8),
              Text('Panen'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final stats = _data!.statistics;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total SPK',
            stats.totalSpk.toString(),
            Icons.assignment,
            Colors.blue[700]!,
          ),
          _buildStatItem(
            'Completion',
            '${stats.completionRate.toStringAsFixed(0)}%',
            Icons.check_circle,
            Colors.green[700]!,
          ),
          _buildStatItem(
            'Avg Time',
            '${stats.avgTimeToComplete.toStringAsFixed(1)}d',
            Icons.timer,
            Colors.orange[700]!,
          ),
          _buildStatItem(
            'Overdue',
            stats.overdueCount.toString(),
            Icons.warning,
            Colors.red[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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

  Widget _buildKanbanBoard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildKanbanColumn(
            'PENDING',
            _data!.pending,
            Colors.grey[300]!,
            Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKanbanColumn(
            'DIKERJAKAN',
            _data!.dikerjakan,
            Colors.blue[300]!,
            Icons.work,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKanbanColumn(
            'SELESAI',
            _data!.selesai,
            Colors.green[300]!,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildKanbanColumn(
    String title,
    List<SpkCard> cards,
    Color headerColor,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cards.length.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: headerColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cards Area (DragTarget)
          Expanded(
            child: DragTarget<SpkCard>(
              onWillAcceptWithDetails: (details) => details.data.status != title,
              onAcceptWithDetails: (details) {
                _updateSpkStatus(details.data, title);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? headerColor.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: cards.isEmpty
                      ? _buildEmptyColumn()
                      : ListView.builder(
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            return _buildSpkCard(cards[index], title);
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColumn() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Tidak ada SPK',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpkCard(SpkCard card, String currentColumn) {
    return Draggable<SpkCard>(
      data: card,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 280,
          child: Opacity(
            opacity: 0.8,
            child: _buildCardContent(card, isDragging: true),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(card),
      ),
      child: _buildCardContent(card),
    );
  }

  Widget _buildCardContent(SpkCard card, {bool isDragging = false}) {
    return Card(
      elevation: isDragging ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.onCardTap != null ? () => widget.onCardTap!(card) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nomor SPK + Priority Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.nomorSpk,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (card.prioritas != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(card.prioritas!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        card.prioritas!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Nama SPK
              Text(
                card.namaSpk,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Tipe + Pelaksana
              Row(
                children: [
                  Icon(_getTipeIcon(card.tipeSpk), size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      card.tipeSpk,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    card.pelaksana,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar
              LinearPercentIndicator(
                lineHeight: 8,
                percent: card.progress / 100,
                backgroundColor: Colors.grey[300],
                progressColor: _getProgressColor(card.progress),
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 4),
              // Progress Text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${card.tugasSelesai}/${card.jumlahTugas} tugas',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${card.progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(card.progress),
                    ),
                  ),
                ],
              ),
              // Target Date (if exists)
              if (card.targetSelesai != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      card.isOverdue ? Icons.warning : Icons.calendar_today,
                      size: 12,
                      color: card.isOverdue ? Colors.red[600] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      card.isOverdue
                          ? 'OVERDUE'
                          : 'Target: ${_formatDate(card.targetSelesai!)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: card.isOverdue ? Colors.red[600] : Colors.grey[600],
                        fontWeight: card.isOverdue ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
              // Tags (if exists)
              if (card.tags != null && card.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: card.tags!.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red[600]!;
      case 'MEDIUM':
        return Colors.orange[600]!;
      case 'LOW':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getTipeIcon(String tipe) {
    switch (tipe.toUpperCase()) {
      case 'VALIDASI':
        return Icons.check_circle;
      case 'APH':
        return Icons.agriculture;
      case 'SANITASI':
        return Icons.cleaning_services;
      case 'PANEN':
        return Icons.shopping_basket;
      default:
        return Icons.assignment;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return Colors.green[600]!;
    if (progress >= 50) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff < 0) return 'OVERDUE';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${diff}d';
  }
}
