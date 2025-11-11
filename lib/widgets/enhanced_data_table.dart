import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../config/app_theme.dart';
import '../config/responsive_helper.dart';

/// Enhanced DataTable Widget
/// Advanced data table dengan fitur lengkap:
/// - Search & Filter
/// - Sort (multi-column)
/// - Pagination
/// - Export CSV/Excel
/// - Column visibility toggle
/// - Row selection
/// - Responsive design
/// 
/// Usage:
/// ```dart
/// EnhancedDataTable(
///   columns: [
///     DataTableColumn(label: 'Name', key: 'name'),
///     DataTableColumn(label: 'Age', key: 'age', numeric: true),
///   ],
///   rows: data,
///   onRowTap: (row) => print(row),
/// )
/// ```

class EnhancedDataTable extends StatefulWidget {
  final List<DataTableColumn> columns;
  final List<Map<String, dynamic>> rows;
  final Function(Map<String, dynamic>)? onRowTap;
  final int itemsPerPage;
  final bool showSearch;
  final bool showExport;
  final bool showColumnSelector;
  final String? title;
  final Widget? headerActions;
  
  const EnhancedDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.itemsPerPage = 10,
    this.showSearch = true,
    this.showExport = true,
    this.showColumnSelector = true,
    this.title,
    this.headerActions,
  });

  @override
  State<EnhancedDataTable> createState() => _EnhancedDataTableState();
}

class _EnhancedDataTableState extends State<EnhancedDataTable> {
  // State
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchQuery = '';
  final Set<int> _selectedRows = {};
  final Set<String> _hiddenColumns = {};
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Get filtered rows
  List<Map<String, dynamic>> get _filteredRows {
    if (_searchQuery.isEmpty) return widget.rows;
    
    return widget.rows.where((row) {
      return row.values.any((value) {
        return value.toString().toLowerCase().contains(_searchQuery.toLowerCase());
      });
    }).toList();
  }
  
  // Get sorted rows
  List<Map<String, dynamic>> get _sortedRows {
    final rows = List<Map<String, dynamic>>.from(_filteredRows);
    
    if (_sortColumnIndex != null && _sortColumnIndex! < widget.columns.length) {
      final column = widget.columns[_sortColumnIndex!];
      rows.sort((a, b) {
        final aValue = a[column.key];
        final bValue = b[column.key];
        
        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return 1;
        if (bValue == null) return -1;
        
        final comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }
    
    return rows;
  }
  
  // Get paginated rows
  List<Map<String, dynamic>> get _paginatedRows {
    final sorted = _sortedRows;
    final startIndex = _currentPage * widget.itemsPerPage;
    final endIndex = (startIndex + widget.itemsPerPage).clamp(0, sorted.length);
    return sorted.sublist(startIndex, endIndex);
  }
  
  // Total pages
  int get _totalPages {
    return (_sortedRows.length / widget.itemsPerPage).ceil();
  }
  
  // Export to CSV
  void _exportToCSV() {
    final csvData = StringBuffer();
    
    // Header
    final visibleColumns = widget.columns.where((c) => !_hiddenColumns.contains(c.key)).toList();
    csvData.writeln(visibleColumns.map((c) => '"${c.label}"').join(','));
    
    // Rows
    for (var row in _sortedRows) {
      final values = visibleColumns.map((c) {
        final value = row[c.key]?.toString() ?? '';
        return '"${value.replaceAll('"', '""')}"';
      });
      csvData.writeln(values.join(','));
    }
    
    // Download
    final bytes = utf8.encode(csvData.toString());
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'data_${DateTime.now().millisecondsSinceEpoch}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${_sortedRows.length} rows to CSV'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
  
  // Copy to clipboard
  void _copyToClipboard() {
    final visibleColumns = widget.columns.where((c) => !_hiddenColumns.contains(c.key)).toList();
    final data = StringBuffer();
    
    // Header
    data.writeln(visibleColumns.map((c) => c.label).join('\t'));
    
    // Rows
    for (var row in _sortedRows) {
      final values = visibleColumns.map((c) => row[c.key]?.toString() ?? '');
      data.writeln(values.join('\t'));
    }
    
    Clipboard.setData(ClipboardData(text: data.toString()));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data copied to clipboard'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header section
        if (widget.title != null || widget.showSearch || widget.showExport)
          _buildHeader(),
        
        const SizedBox(height: 16),
        
        // Table
        _buildTable(),
        
        const SizedBox(height: 16),
        
        // Pagination
        if (_totalPages > 1)
          _buildPagination(),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      children: [
        // Title & row count
        if (widget.title != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_sortedRows.length} rows',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        
        // Search & Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search
            if (widget.showSearch)
              SizedBox(
                width: context.isMobile ? 200 : 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _currentPage = 0;
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 0;
                    });
                  },
                ),
              ),
            
            if (widget.showSearch) const SizedBox(width: 12),
            
            // Export button
            if (widget.showExport)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'More actions',
                onSelected: (value) {
                  switch (value) {
                    case 'csv':
                      _exportToCSV();
                      break;
                    case 'copy':
                      _copyToClipboard();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 12),
                        Text('Export CSV'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.content_copy, size: 20),
                        SizedBox(width: 12),
                        Text('Copy to Clipboard'),
                      ],
                    ),
                  ),
                ],
              ),
            
            // Column selector
            if (widget.showColumnSelector && !context.isMobile)
              PopupMenuButton<String>(
                icon: const Icon(Icons.view_column),
                tooltip: 'Column visibility',
                itemBuilder: (context) => widget.columns.map((column) {
                  return CheckedPopupMenuItem<String>(
                    value: column.key,
                    checked: !_hiddenColumns.contains(column.key),
                    child: Text(column.label),
                    onTap: () {
                      setState(() {
                        if (_hiddenColumns.contains(column.key)) {
                          _hiddenColumns.remove(column.key);
                        } else {
                          _hiddenColumns.add(column.key);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            
            // Custom header actions
            if (widget.headerActions != null)
              widget.headerActions!,
          ],
        ),
      ],
    );
  }
  
  Widget _buildTable() {
    if (_paginatedRows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.inbox : Icons.search_off,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No data available' : 'No results found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }
    
    final visibleColumns = widget.columns.where((c) => !_hiddenColumns.contains(c.key)).toList();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 48,
        ),
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          showCheckboxColumn: false,
          columns: visibleColumns.map((column) {
            final index = widget.columns.indexOf(column);
            return DataColumn(
              label: Text(
                column.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: column.numeric,
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = index;
                  _sortAscending = ascending;
                });
              },
            );
          }).toList(),
          rows: _paginatedRows.asMap().entries.map((entry) {
            final rowIndex = _currentPage * widget.itemsPerPage + entry.key;
            final row = entry.value;
            
            return DataRow(
              selected: _selectedRows.contains(rowIndex),
              onSelectChanged: widget.onRowTap != null
                  ? (_) {
                      widget.onRowTap!(row);
                    }
                  : null,
              cells: visibleColumns.map((column) {
                final value = row[column.key];
                return DataCell(
                  column.builder != null
                      ? column.builder!(value, row)
                      : Text(value?.toString() ?? '-'),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Rows info
        Text(
          'Showing ${_currentPage * widget.itemsPerPage + 1}-${(_currentPage * widget.itemsPerPage + widget.itemsPerPage).clamp(0, _sortedRows.length)} of ${_sortedRows.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        
        // Page controls
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: _currentPage > 0
                  ? () => setState(() => _currentPage = 0)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 0
                  ? () => setState(() => _currentPage--)
                  : null,
            ),
            Text(
              'Page ${_currentPage + 1} of $_totalPages',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < _totalPages - 1
                  ? () => setState(() => _currentPage++)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < _totalPages - 1
                  ? () => setState(() => _currentPage = _totalPages - 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Data table column definition
class DataTableColumn {
  final String label;
  final String key;
  final bool numeric;
  final Widget Function(dynamic value, Map<String, dynamic> row)? builder;
  
  const DataTableColumn({
    required this.label,
    required this.key,
    this.numeric = false,
    this.builder,
  });
}
