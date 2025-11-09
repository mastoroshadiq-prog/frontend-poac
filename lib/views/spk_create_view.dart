import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/spk_service.dart';

/// Halaman untuk membuat SPK (Surat Perintah Kerja) baru
/// RBAC: Hanya ASISTEN dan ADMIN yang dapat akses
class SPKCreateView extends StatefulWidget {
  const SPKCreateView({super.key});

  @override
  State<SPKCreateView> createState() => _SPKCreateViewState();
}

class _SPKCreateViewState extends State<SPKCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _spkService = SPKService();
  
  // Form controllers
  final _namaSpkController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime? _tanggalTargetSelesai;
  
  // Daftar tugas (untuk saat ini hardcode 2 tugas sebagai demo)
  final List<Map<String, dynamic>> _daftarTugas = [];
  
  // State
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan 2 tugas kosong sebagai template
    _daftarTugas.add({
      'id_pelaksana': '',
      'tipe_tugas': 'PANEN_APH',
    });
    _daftarTugas.add({
      'id_pelaksana': '',
      'tipe_tugas': 'PANEN_BPH',
    });
  }

  @override
  void dispose() {
    _namaSpkController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalTargetSelesai ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Target Selesai',
    );
    if (picked != null && picked != _tanggalTargetSelesai) {
      setState(() {
        _tanggalTargetSelesai = picked;
      });
    }
  }

  Future<void> _handleSimpanSPK() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi minimal 1 tugas memiliki pelaksana
    final tugasValid = _daftarTugas.where((t) => t['id_pelaksana'].toString().isNotEmpty).toList();
    if (tugasValid.isEmpty) {
      setState(() {
        _errorMessage = 'Minimal harus ada 1 tugas dengan pelaksana yang diisi';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Buat SPK Header
      final spkData = await _spkService.createSpkHeader(
        namaSpk: _namaSpkController.text.trim(),
        tanggalTargetSelesai: _tanggalTargetSelesai,
        keterangan: _keteranganController.text.trim(),
      );

      // Step 2: Ambil ID SPK yang baru dibuat
      final newSpkId = spkData['id_spk'] as String;

      // Step 3: Tambahkan tugas-tugas ke SPK
      await _spkService.addTugasKeSpk(newSpkId, tugasValid);

      if (!mounted) return;

      // Step 4: Sukses - tampilkan notifikasi dan kembali
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SPK Berhasil Dibuat!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'ID: $newSpkId | ${tugasValid.length} tugas ditambahkan',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Navigasi kembali ke home
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat SPK Baru'),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Form SPK Baru',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Planning & Organizing',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Nama SPK
                      TextFormField(
                        controller: _namaSpkController,
                        decoration: InputDecoration(
                          labelText: 'Nama SPK *',
                          hintText: 'Contoh: SPK Panen Minggu 45',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama SPK wajib diisi';
                          }
                          if (value.trim().length < 5) {
                            return 'Nama SPK minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Target Selesai
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Target Selesai (Opsional)',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          child: Text(
                            _tanggalTargetSelesai == null
                                ? 'Pilih tanggal target'
                                : DateFormat('dd MMMM yyyy', 'id_ID').format(_tanggalTargetSelesai!),
                            style: TextStyle(
                              color: _tanggalTargetSelesai == null
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Keterangan
                      TextFormField(
                        controller: _keteranganController,
                        decoration: InputDecoration(
                          labelText: 'Keterangan (Opsional)',
                          hintText: 'Catatan tambahan untuk SPK ini',
                          prefixIcon: const Icon(Icons.notes),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      const Divider(thickness: 2),
                      const SizedBox(height: 16),

                      // Daftar Tugas Header
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Daftar Tugas',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_daftarTugas.length} tugas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Untuk demo: Isi ID Pelaksana (UUID) untuk tugas yang ingin ditambahkan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daftar Tugas
                      ..._buildDaftarTugas(),

                      const SizedBox(height: 24),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tombol Simpan
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleSimpanSPK,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isLoading ? 'Menyimpan...' : 'Simpan SPK',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDaftarTugas() {
    return _daftarTugas.asMap().entries.map((entry) {
      final index = entry.key;
      final tugas = entry.value;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: tugas['tipe_tugas'] as String,
                    decoration: InputDecoration(
                      labelText: 'Tipe Tugas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'PANEN_APH',
                        child: Text('Panen APH'),
                      ),
                      DropdownMenuItem(
                        value: 'PANEN_BPH',
                        child: Text('Panen BPH'),
                      ),
                      DropdownMenuItem(
                        value: 'RAWAT_APH',
                        child: Text('Rawat APH'),
                      ),
                      DropdownMenuItem(
                        value: 'RAWAT_BPH',
                        child: Text('Rawat BPH'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _daftarTugas[index]['tipe_tugas'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: tugas['id_pelaksana'] as String,
              decoration: InputDecoration(
                labelText: 'ID Pelaksana (UUID)',
                hintText: 'contoh: a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
                prefixIcon: const Icon(Icons.person, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (value) {
                _daftarTugas[index]['id_pelaksana'] = value;
              },
            ),
          ],
        ),
      );
    }).toList();
  }
}
