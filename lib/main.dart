import 'package:flutter/material.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.restoreSession();
  runApp(const DokemasAdminApp());
}

class DokemasAdminApp extends StatelessWidget {
  const DokemasAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOKEMAS — Enterprise Destination Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF198754),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        focusColor: const Color(0xFF198754),
        highlightColor: Colors.transparent,
        splashColor: const Color(0xFFD1FAE5),
      ),
      home: ApiService.isAuthenticated
          ? const AdminDashboardScreen()
          : const LoginScreen(),
    );
  }
}
