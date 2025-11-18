import 'package:flutter/material.dart';
import '../models/drone_ndre_tree.dart';
import '../services/spk_service.dart';
import '../config/supabase_config.dart';

/// Modal dialog untuk membuat SPK Validasi Lapangan (Ground Truth)
/// 
/// Context:
/// Prediksi drone NDRE perlu konfirmasi surveyor lapangan untuk:
/// - Grading Ganoderma G0-G4 (manual inspection)
/// - Ground truth validation (actual vs predicted)
/// - Confusion matrix data collection
/// 
/// Features:
/// - Show selected trees summary (prediksi drone)
/// - Mandor selection (assign ke tim surveyor)
/// - Priority selection (URGENT/HIGH/NORMAL)
/// - Target completion date
/// - Optional notes
/// - Submit dengan validasi
class CreateSpkValidasiDialog extends StatefulWidget {
  final List<DroneNdreTree> selectedTrees;
  final VoidCallback? onSuccess;

  const CreateSpkValidasiDialog({
    super.key,
    required this.selectedTrees,
    this.onSuccess,
  });

  @override
  State<CreateSpkValidasiDialog> createState() =>
      _CreateSpkValidasiDialogState();
}

class _CreateSpkValidasiDialogState extends State<CreateSpkValidasiDialog> {
  final SPKService _spkService = SPKService();
  final _notesController = TextEditingController();

  String? _selectedMandorId;
  String _selectedPriority = 'URGENT';
  DateTime? _targetDate;
  bool _isLoading = false;
  bool _isLoadingMandors = true;
  
  List<Map<String, dynamic>> _mandorList = [];

  @override
  void initState() {
    super.initState();
    _loadMandors();
    _calculateDefaultTargetDate();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMandors() async {
    try {
      // Query users dengan role MANDOR dari Supabase
      // Try pihak_peran table first (as per schema)
      final response = await SupabaseConfig.client
          .from('pihak_peran')
          .select('id_pihak, pihak!inner(nama_pihak)')
          .eq('role', 'MANDOR');

      setState(() {
        _mandorList = (response as List).map((item) {
          final pihakData = item['pihak'] as Map<String, dynamic>;
          return {
            'id_pihak': item['id_pihak'] as String,
            'nama_pihak': pihakData['nama_pihak'] as String,
            'role': 'MANDOR'
          };
        }).toList();
        _isLoadingMandors = false;
      });

      print('✅ Loaded ${_mandorList.length} mandors');
    } catch (e) {
      print('❌ Error loading mandors: $e');
      setState(() {
        // Dummy data untuk development
        _mandorList = [
          {
            'id_pihak': 'mandor-001',
            'nama_pihak': 'Ahmad Supardi',
            'role': 'MANDOR'
          },
          {
            'id_pihak': 'mandor-002',
            'nama_pihak': 'Budi Santoso',
            'role': 'MANDOR'
          },
          {
            'id_pihak': 'mandor-003',
            'nama_pihak': 'Cahyo Wibowo',
            'role': 'MANDOR'
          },
        ];
        _isLoadingMandors = false;
      });
    }
  }

  void _calculateDefaultTargetDate() {
    // Auto-calculate based on priority
    final daysToAdd = _selectedPriority == 'URGENT'
        ? 3
        : _selectedPriority == 'HIGH'
            ? 7
            : 14;
    
    setState(() {
      _targetDate = DateTime.now().add(Duration(days: daysToAdd));
    });
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  String _getStressSummary() {
    final stresBerat = widget.selectedTrees
        .where((t) => t.stressLevel == 'Stres Berat')
        .length;
    final stresSedang = widget.selectedTrees
        .where((t) => t.stressLevel == 'Stres Sedang')
        .length;
    final sehat = widget.selectedTrees
        .where((t) => t.stressLevel == 'Sehat')
        .length;

    final parts = <String>[];
    if (stresBerat > 0) parts.add('Stres Berat: $stresBerat');
    if (stresSedang > 0) parts.add('Stres Sedang: $stresSedang');
    if (sehat > 0) parts.add('Sehat: $sehat');

    return parts.join(', ');
  }

  String _getBlokSummary() {
    final bloks = widget.selectedTrees
        .where((t) => t.blokDetail != null || t.blok != null)
        .map((t) => t.blokDetail ?? t.blok!)
        .toSet()
        .toList();

    if (bloks.isEmpty) return 'N/A';
    if (bloks.length <= 3) return bloks.join(', ');
    return '${bloks.take(3).join(', ')} +${bloks.length - 3} lainnya';
  }

  String _getLocationSummary() {
    // Group by divisi and count
    final divisiCounts = <String, int>{};
    for (var tree in widget.selectedTrees) {
      if (tree.divisi != null) {
        divisiCounts[tree.divisi!] = (divisiCounts[tree.divisi!] ?? 0) + 1;
      }
    }

    if (divisiCounts.isEmpty) return 'Lokasi tidak tersedia';

    return divisiCounts.entries
        .map((e) => '${e.key}: ${e.value} pohon')
        .join(', ');
  }

  /// Build location breakdown widget (Priority 2 - Should Have)
  /// Group trees by blok_detail and show tree count per location
  Widget _buildLocationBreakdown() {
    // Group trees by blok_detail
    final Map<String, List<dynamic>> groupedByBlok = {};
    
    for (var tree in widget.selectedTrees) {
      final blokKey = tree.blokDetail ?? tree.blok ?? 'N/A';
      if (!groupedByBlok.containsKey(blokKey)) {
        groupedByBlok[blokKey] = [];
      }
      groupedByBlok[blokKey]!.add({
        'divisi': tree.divisi,
        'n_baris': tree.nBaris,
        'n_pokok': tree.nPokok,
        'tree': tree,
      });
    }

    if (groupedByBlok.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Location Breakdown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...groupedByBlok.entries.map((entry) {
            final blokDetail = entry.key;
            final trees = entry.value;
            final divisi = trees.first['divisi'] ?? 'N/A';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_city, 
                        size: 16, 
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$divisi - Blok $blokDetail',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${trees.length} pohon',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: trees
                        .where((t) => t['n_baris'] != null && t['n_pokok'] != null)
                        .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.park,
                                size: 12,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Baris ${t['n_baris']} - Pokok ${t['n_pokok']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                        ))
                        .toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _submitCreateSPK() async {
    // Validasi
    if (_selectedMandorId == null) {
      _showError('Silakan pilih mandor terlebih dahulu');
      return;
    }

    if (_targetDate == null) {
      _showError('Silakan pilih target tanggal selesai');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Create SPK Header
      final namaSpk = 'SPK Validasi Lapangan (Ground Truth) - ${widget.selectedTrees.length} Pohon';
      final keterangan = _notesController.text.isNotEmpty
          ? _notesController.text
          : 'Validasi lapangan ${widget.selectedTrees.length} pohon - Konfirmasi grading Ganoderma (G0-G4) vs prediksi drone NDRE';

      final spkHeaderResponse = await _spkService.createSpkHeader(
        namaSpk: namaSpk,
        tanggalTargetSelesai: _targetDate,
        keterangan: keterangan,
      );

      final idSpk = spkHeaderResponse['id_spk'] as String;
      final noSpk = spkHeaderResponse['no_spk'] as String;

      print('✅ SPK Header created: $noSpk ($idSpk)');

      // Step 2: Create tugas list
      final daftarTugas = widget.selectedTrees.map((tree) {
        return {
          'id_pelaksana': _selectedMandorId,
          'tipe_tugas': 'VALIDASI_LAPANGAN',
          'id_npokok': tree.idNpokok,
          'prioritas': _selectedPriority,
          'catatan': 'Ground Truth Validation - Prediksi Drone: ${tree.stressLevel} (NDRE: ${tree.ndreValue.toStringAsFixed(2)}) - Surveyor konfirmasi: Grading Ganoderma G0-G4',
        };
      }).toList();

      // Step 3: Add tugas to SPK
      await _spkService.addTugasKeSpk(idSpk, daftarTugas);

      print('✅ Added ${daftarTugas.length} tugas to SPK $noSpk');

      // Success!
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccess('SPK $noSpk berhasil dibuat dengan ${widget.selectedTrees.length} tugas validasi');
        widget.onSuccess?.call();
      }
    } catch (e) {
      print('❌ Error creating SPK: $e');
      _showError('Gagal membuat SPK: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_task,
                        color: Colors.green[700],
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Create SPK Validasi Lapangan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // SOP Badge (Priority 2 - Should Have)
                                Tooltip(
                                  message: 'SOP Validasi Lapangan Ground Truth v1.0',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.description,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'SOP-VAL-001 v1.0',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Ground Truth Validation (G0-G4)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Box - Ground Truth Validation
                    Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Surveyor akan validasi lapangan untuk konfirmasi grading Ganoderma (G0-G4) vs prediksi drone NDRE',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Selected Trees Summary
              Container(
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
                        Icon(Icons.forest, color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Trees (Prediksi Drone): ${widget.selectedTrees.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${_getStressSummary()}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      '• Lokasi: ${_getLocationSummary()}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      '• Blok: ${_getBlokSummary()}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Location Breakdown (Priority 2 - Should Have)
              _buildLocationBreakdown(),
              const SizedBox(height: 20),

              // Mandor Selection
              Text(
                'Assign to Mandor: *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingMandors
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedMandorId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        hintText: 'Pilih Mandor',
                      ),
                      items: _mandorList.map((mandor) {
                        return DropdownMenuItem<String>(
                          value: mandor['id_pihak'] as String,
                          child: Text(mandor['nama_pihak'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMandorId = value;
                        });
                      },
                    ),
              const SizedBox(height: 20),

              // Priority Selection
              Text(
                'Priority:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPriorityButton('URGENT', Colors.red[400]!,
                        Icons.error, 3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityButton('HIGH', Colors.orange[400]!,
                        Icons.warning, 7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityButton('NORMAL', Colors.green[400]!,
                        Icons.check_circle, 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Target Date
              Text(
                'Target Completion:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTargetDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        _targetDate != null
                            ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                            : 'Pilih tanggal',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      if (_targetDate != null)
                        Text(
                          '(${_targetDate!.difference(DateTime.now()).inDays} hari dari sekarang)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notes (Optional)
              Text(
                'Notes: (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Catatan tambahan untuk SPK ini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitCreateSPK,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Creating...' : 'Create SPK Validasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton(
      String priority, Color color, IconData icon, int days) {
    final isSelected = _selectedPriority == priority;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
          _calculateDefaultTargetDate();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              priority,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
            Text(
              '$days hari',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
