import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/auth_service.dart';
import 'dashboard_eksekutif_view.dart';
import 'dashboard_operasional_view.dart';
import 'dashboard_teknis_view.dart';
import 'spk_create_view.dart';

/// Halaman menu utama setelah login
/// Menampilkan dashboard yang dapat diakses sesuai role
class HomeMenuView extends StatelessWidget {
  final UserSession session;

  const HomeMenuView({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final accessibleDashboards = authService.getAccessibleDashboards(session.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard POAC - Keboen'),
        elevation: 2,
        actions: [
          // User info
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        session.namaPihak,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(session.role),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          session.getRoleDisplayName(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      session.namaPihak.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome message
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.waving_hand,
                          size: 48,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selamat Datang,',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.namaPihak,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pilih dashboard yang ingin Anda akses',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Dashboard cards
                if (accessibleDashboards.isEmpty)
                  Card(
                    elevation: 2,
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 48, color: Colors.orange[700]),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak Ada Dashboard Tersedia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Role Anda (${session.role}) tidak memiliki akses ke dashboard manapun.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      if (accessibleDashboards.contains('eksekutif'))
                        _buildDashboardCard(
                          context,
                          title: 'Dashboard Eksekutif',
                          subtitle: 'KPI & Tren Produktivitas',
                          icon: Icons.analytics,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardEksekutifView(
                                  token: session.token,
                                  userRole: session.role,
                                ),
                              ),
                            );
                          },
                        ),
                      if (accessibleDashboards.contains('operasional'))
                        _buildDashboardCard(
                          context,
                          title: 'Dashboard Operasional',
                          subtitle: 'Corong & Peringkat Tim',
                          icon: Icons.task_alt,
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardOperasionalView(
                                  token: session.token,
                                  userRole: session.role,
                                ),
                              ),
                            );
                          },
                        ),
                      if (accessibleDashboards.contains('teknis'))
                        _buildDashboardCard(
                          context,
                          title: 'Dashboard Teknis',
                          subtitle: 'Matriks & Distribusi NDRE',
                          icon: Icons.science,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardTeknisView(
                                  token: session.token,
                                  userRole: session.role,
                                ),
                              ),
                            );
                          },
                        ),
                      // SPK Management Card (ASISTEN & ADMIN only)
                      if (['ASISTEN', 'ADMIN'].contains(session.role))
                        _buildDashboardCard(
                          context,
                          title: 'Buat SPK',
                          subtitle: 'Planning & Organizing',
                          icon: Icons.assignment_add,
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SPKCreateView(),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                
                const SizedBox(height: 32),
                
                // Access info
                Card(
                  elevation: 1,
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user, size: 20, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Anda memiliki akses ke ${accessibleDashboards.length} dashboard',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Buka Dashboard',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'MANAJER':
        return Colors.purple;
      case 'ASISTEN':
        return Colors.blue;
      case 'MANDOR':
        return Colors.green;
      case 'PELAKSANA':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
