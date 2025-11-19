import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'config/app_theme.dart';
import 'views/login_view.dart';
import 'views/home_menu_view.dart';
import 'views/lifecycle_detail_view.dart';
import 'views/dashboard_eksekutif_view.dart';
import 'views/dashboard_operasional_view.dart';
import 'views/dashboard_teknis_view.dart';
import 'views/drone_ndre_analysis_page.dart';
import 'views/dashboard_mandor_view.dart';
import 'views/dashboard/mandor/mandor_dashboard_page.dart';
import 'models/user_session.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard POAC - Keboen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Apply custom theme
      // Landing page adalah Login (RBAC FASE 3)
      initialRoute: '/',
      routes: {'/': (context) => const LoginView()},
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final session = settings.arguments as UserSession?;
          if (session == null) {
            // If no session, redirect to login
            return MaterialPageRoute(builder: (context) => const LoginView());
          }
          return MaterialPageRoute(
            builder: (context) => HomeMenuView(session: session),
          );
        }
        
        // Dashboard Eksekutif
        if (settings.name == '/dashboard-eksekutif') {
          final args = settings.arguments;
          final String? token = args is Map ? args['token'] : args as String?;
          final String? userRole = args is Map ? args['userRole'] : null;
          return MaterialPageRoute(
            builder: (context) => DashboardEksekutifView(token: token, userRole: userRole),
          );
        }
        
        // Dashboard Operasional
        if (settings.name == '/dashboard-operasional') {
          final args = settings.arguments;
          final String? token = args is Map ? args['token'] : args as String?;
          final String? userRole = args is Map ? args['userRole'] : null;
          return MaterialPageRoute(
            builder: (context) => DashboardOperasionalView(token: token, userRole: userRole),
          );
        }
        
        // Dashboard Teknis
        if (settings.name == '/dashboard-teknis') {
          final args = settings.arguments;
          final String? token = args is Map ? args['token'] : args as String?;
          final String? userRole = args is Map ? args['userRole'] : null;
          if (token == null) {
            return MaterialPageRoute(builder: (context) => const LoginView());
          }
          return MaterialPageRoute(
            builder: (context) => DashboardTeknisView(token: token, userRole: userRole),
          );
        }
        
        // Drone NDRE Analysis Page
        if (settings.name == '/drone-ndre-analysis') {
          return MaterialPageRoute(
            builder: (context) => const DroneNdreAnalysisPage(),
          );
        }        
        // MANDOR Dashboard (HANDOVER V2)
        if (settings.name == '/mandor/dashboard') {
          final session = settings.arguments as UserSession?;
          if (session == null) {
            return MaterialPageRoute(builder: (context) => const LoginView());
          }
          return MaterialPageRoute(
            builder: (context) => DashboardMandorView(session: session),
          );
        }


        
        // Mandor Dashboard
        if (settings.name == '/mandor-dashboard') {
          final args = settings.arguments as Map<String, dynamic>?;
          final String mandorId = args?['mandorId'] ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12';
          return MaterialPageRoute(
            builder: (context) => MandorDashboardPage(mandorId: mandorId),
          );
        }
        
        // Lifecycle detail route: /lifecycle/:phase
        if (settings.name?.startsWith('/lifecycle/') ?? false) {
          final phase = settings.name!.substring(11); // Extract phase name
          return MaterialPageRoute(
            builder: (context) => LifecycleDetailView(initialPhase: phase),
          );
        }
        
        // Reports route (placeholder for now)
        if (settings.name == '/reports') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Reports')),
              body: const Center(child: Text('Reports - Coming Soon')),
            ),
          );
        }
        
        // Settings route (placeholder)
        if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: const Center(child: Text('Settings - Coming Soon')),
            ),
          );
        }
        
        // Help route (placeholder)
        if (settings.name == '/help') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Help')),
              body: const Center(child: Text('Help - Coming Soon')),
            ),
          );
        }
        
        return null;
      },
    );
  }
}

