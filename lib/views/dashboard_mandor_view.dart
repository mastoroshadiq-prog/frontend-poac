import 'package:flutter/material.dart';
import '../services/mandor_dashboard_service.dart';
import '../models/user_session.dart';
import '../services/auth_service.dart';
import 'login_view.dart';

class DashboardMandorView extends StatefulWidget {
  final UserSession session;

  const DashboardMandorView({super.key, required this.session});

  @override
  State<DashboardMandorView> createState() => _DashboardMandorViewState();
}

class _DashboardMandorViewState extends State<DashboardMandorView> {
  final _dashboardService = MandorDashboardService();
  final _authService = AuthService();
  
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _dashboardService.getDashboard();
      
      if (mounted) {
        setState(() {
          dashboardData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${widget.session.namaPihak}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorView()
              : dashboardData != null
                  ? _buildDashboardContent()
                  : const Center(child: Text('Tidak ada data')),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Terjadi Kesalahan', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final mandor = dashboardData!['mandor'] as Map<String, dynamic>;
    final metrics = dashboardData!['metrics'] as Map<String, dynamic>;
    final recentSpk = dashboardData!['recent_spk'] as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCard(mandor),
          const SizedBox(height: 24),
          Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildMetricsGrid(metrics),
          const SizedBox(height: 24),
          Text('SPK Terbaru', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSpkList(recentSpk),
        ],
      ),
    );
  }
  Widget _buildUserInfoCard(Map<String, dynamic> mandor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.green.shade700,
              child: Text(
                mandor['nama'].toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mandor['nama'] ?? 'N/A', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(mandor['email'] ?? 'N/A', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Total SPK', metrics['total_spk']?.toString() ?? '0', Icons.assignment, Colors.blue),
        _buildMetricCard('SPK Aktif', metrics['spk_aktif']?.toString() ?? '0', Icons.assignment_turned_in, Colors.orange),
        _buildMetricCard('Tugas Pending', metrics['tugas_pending']?.toString() ?? '0', Icons.pending_actions, Colors.amber),
        _buildMetricCard('Tugas Selesai', metrics['tugas_selesai']?.toString() ?? '0', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpkList(List spkList) {
    if (spkList.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: Text('Belum ada SPK', style: TextStyle(color: Colors.grey.shade600))),
        ),
      );
    }
    return Column(children: spkList.map((spk) => _buildSpkCard(spk)).toList());
  }

  Widget _buildSpkCard(Map<String, dynamic> spk) {
    final status = spk['status_spk'] ?? 'UNKNOWN';
    Color statusColor;
    switch (status) {
      case 'PENDING': statusColor = Colors.orange; break;
      case 'DIKERJAKAN': statusColor = Colors.blue; break;
      case 'SELESAI': statusColor = Colors.green; break;
      default: statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.assignment, color: statusColor),
        ),
        title: Text(spk['nama_spk'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${spk['id_spk'] ?? 'N/A'}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detail SPK ${spk['id_spk']}')),
          );
        },
      ),
    );
  }
}

