import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'views/login_view.dart';
import 'views/home_menu_view.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
      // Landing page adalah Login (RBAC FASE 3)
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final session = settings.arguments as UserSession;
          return MaterialPageRoute(
            builder: (context) => HomeMenuView(session: session),
          );
        }
        return null;
      },
    );
  }
}
