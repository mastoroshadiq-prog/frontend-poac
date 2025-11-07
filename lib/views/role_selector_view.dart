import 'package:flutter/material.dart';
import '../models/user_session.dart';

/// Halaman pemilihan role untuk testing
/// Karena backend tidak memiliki endpoint login,
/// kita gunakan hardcoded token sesuai role yang dipilih
class RoleSelectorView extends StatelessWidget {
  const RoleSelectorView({super.key});

  // Hardcoded tokens untuk setiap role (dari backend generate-token-only.js)
  static const Map<String, Map<String, String>> _roleTokens = {
    'ADMIN': {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6ImFkbWluLTEyMzQiLCJuYW1hX3BpaGFrIjoiQWRtaW4gU2lzdGVtIiwicm9sZSI6IkFETUlOIiwiaWF0IjoxNzMwOTUyMDAwLCJleHAiOjE3OTQ5NTIwMDB9.SIGNATURE',
      'nama': 'Admin Sistem',
      'id': 'admin-1234',
    },
    'MANAJER': {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6IjdiZTJkYjg4LTRkYWYtNDdjNy04OWJjLTg0MmNlMGUyOGM4OCIsIm5hbWFfcGloYWsiOiJNYW5hamVyIFN1ZGFybW8iLCJyb2xlIjoiTUFOQUpFUiIsImlhdCI6MTczMDk1MjAwMCwiZXhwIjoxNzk0OTUyMDAwfQ.SIGNATURE',
      'nama': 'Manajer Sudarmo',
      'id': '7be2db88-4daf-47c7-89bc-842ce0e28c88',
    },
    'ASISTEN': {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6ImEwZWViYzk5LTljMGItNGVmOC1iYjZkLTZiYjliZDM4MGExMiIsIm5hbWFfcGloYWsiOiJBc2lzdGVuIENpdHJhIiwicm9sZSI6IkFTSVNURU4iLCJpYXQiOjE3NjI0OTc4NTEsImV4cCI6MTc2MzEwMjY1MX0.P3LEHAjj0iVrc_RtOqYfYsBK8k9RS5ZYfmyQKMiPgQc',
      'nama': 'Asisten Citra',
      'id': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
    },
    'MANDOR': {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6ImJjM2Y4ZGE2LTdjNTQtNGJiMS04NjhkLWVmYzUwYTdkOTQwNiIsIm5hbWFfcGloYWsiOiJNYW5kb3IgQnVkaSIsInJvbGUiOiJNQU5ET1IiLCJpYXQiOjE3MzA5NTIwMDAsImV4cCI6MTc5NDk1MjAwMH0.SIGNATURE',
      'nama': 'Mandor Budi',
      'id': 'bc3f8da6-7c54-4bb1-868d-efc50a7d9406',
    },
    'PELAKSANA': {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6InBlbGFrc2FuYS0xMjM0IiwibmFtYV9waWhhayI6IlBlbGFrc2FuYSBBaG1hZCIsInJvbGUiOiJQRUxBS1NBTkEiLCJpYXQiOjE3MzA5NTIwMDAsImV4cCI6MTc5NDk1MjAwMH0.SIGNATURE',
      'nama': 'Pelaksana Ahmad',
      'id': 'pelaksana-1234',
    },
  };

  void _selectRole(BuildContext context, String role) {
    final tokenData = _roleTokens[role]!;
    
    final session = UserSession(
      token: tokenData['token']!,
      idPihak: tokenData['id']!,
      namaPihak: tokenData['nama']!,
      role: role,
    );

    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Icon(
                    Icons.dashboard_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Dashboard POAC',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Pilih Role untuk Testing',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Role selection cards
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Pilih Role:',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // RBAC info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              border: Border.all(color: Colors.blue[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'RBAC Matrix (Backend):',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildRBACInfo('ADMIN', '✅ Eksekutif, ✅ Operasional, ✅ Teknis'),
                                _buildRBACInfo('ASISTEN', '✅ Eksekutif, ✅ Operasional, ✅ Teknis'),
                                _buildRBACInfo('MANDOR', '✅ Operasional, ✅ Teknis'),
                                _buildRBACInfo('MANAJER', '❌ Tidak ada akses dashboard'),
                                _buildRBACInfo('PELAKSANA', '❌ Tidak ada akses dashboard'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Role buttons
                          _buildRoleButton(
                            context,
                            role: 'ADMIN',
                            icon: Icons.admin_panel_settings,
                            color: Colors.red,
                            description: 'Full Access',
                          ),
                          const SizedBox(height: 12),
                          
                          _buildRoleButton(
                            context,
                            role: 'ASISTEN',
                            icon: Icons.supervisor_account,
                            color: Colors.blue,
                            description: 'Full Access (3 Dashboards)',
                          ),
                          const SizedBox(height: 12),
                          
                          _buildRoleButton(
                            context,
                            role: 'MANDOR',
                            icon: Icons.engineering,
                            color: Colors.green,
                            description: 'Operasional & Teknis Only',
                          ),
                          const SizedBox(height: 12),
                          
                          _buildRoleButton(
                            context,
                            role: 'MANAJER',
                            icon: Icons.business_center,
                            color: Colors.purple,
                            description: 'No Dashboard Access',
                          ),
                          const SizedBox(height: 12),
                          
                          _buildRoleButton(
                            context,
                            role: 'PELAKSANA',
                            icon: Icons.people,
                            color: Colors.orange,
                            description: 'No Dashboard Access',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRBACInfo(String role, String access) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$role: $access',
        style: TextStyle(
          fontSize: 11,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String role,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return ElevatedButton(
      onPressed: () => _selectRole(context, role),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
