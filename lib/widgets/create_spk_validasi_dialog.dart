import 'package:flutter/material.dart';
import '../models/drone_ndre_tree.dart';
import '../services/spk_service.dart';
import '../config/supabase_config.dart';

/// Modal dialog untuk membuat SPK Validasi Drone
/// 
/// Features:
/// - Show selected trees summary
/// - Mandor selection (dari Supabase users dengan role MANDOR)
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
        .where((t) => t.blok != null)
        .map((t) => t.blok!)
        .toSet()
        .toList();

    if (bloks.isEmpty) return 'N/A';
    if (bloks.length <= 3) return bloks.join(', ');
    return '${bloks.take(3).join(', ')} +${bloks.length - 3} lainnya';
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
      final namaSpk = 'SPK Validasi Drone - ${widget.selectedTrees.length} Pohon';
      final keterangan = _notesController.text.isNotEmpty
          ? _notesController.text
          : 'Validasi ${widget.selectedTrees.length} pohon dari analisis drone NDRE';

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
          'catatan': 'NDRE Value: ${tree.ndreValue.toStringAsFixed(2)} - ${tree.stressLevel}',
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
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.add_task,
                    color: Colors.green[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Create SPK Validasi Drone',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

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
                          'Selected Trees: ${widget.selectedTrees.length}',
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
                      '• Blok: ${_getBlokSummary()}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
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
                      value: _selectedMandorId,
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
                    label: Text(_isLoading ? 'Creating...' : 'Create SPK'),
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
