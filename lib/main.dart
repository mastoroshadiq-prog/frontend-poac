import 'package:flutter/material.dart';
import 'views/dashboard_eksekutif_view.dart';
import 'views/dashboard_operasional_view.dart';
import 'views/dashboard_teknis_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard POAC - Keboen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Set Home Menu sebagai landing page
      home: const HomeMenuView(),
    );
  }
}

/// Home Menu untuk navigasi antar dashboard
class HomeMenuView extends StatelessWidget {
  const HomeMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard POAC - Keboen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Title
              Icon(
                Icons.dashboard,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Pilih Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),

              // Dashboard Eksekutif Button
              _buildDashboardCard(
                context,
                title: 'Dashboard Eksekutif',
                subtitle: 'KPI & Tren Eksekutif',
                icon: Icons.bar_chart,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardEksekutifView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Dashboard Operasional Button
              _buildDashboardCard(
                context,
                title: 'Dashboard Operasional',
                subtitle: 'Corong & Peringkat Tim',
                icon: Icons.analytics,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardOperasionalView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Dashboard Teknis Button
              _buildDashboardCard(
                context,
                title: 'Dashboard Teknis',
                subtitle: 'Matriks & Distribusi NDRE',
                icon: Icons.science,
                color: Colors.purple,
                onTap: () {
                  // TODO: Generate JWT token untuk MANDOR/ASISTEN/ADMIN
                  // Untuk testing, hardcode token di sini
                  const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZF9waWhhayI6ImEwZWViYzk5LTljMGItNGVmOC1iYjZkLTZiYjliZDM4MGExMiIsIm5hbWFfcGloYWsiOiJNYW5kb3IgQnVkaSIsInJvbGUiOiJNQU5ET1IiLCJpYXQiOjE3MzA4NDAwMDAsImV4cCI6MTczMDkyNjQwMH0.SIGNATURE';
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardTeknisView(
                        token: testToken,
                      ),
                    ),
                  );
                },
              ),
            ],
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
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
