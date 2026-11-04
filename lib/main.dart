import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DokemasDesktopApp());
}

class DokemasDesktopApp extends StatelessWidget {
  const DokemasDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOKEMAS Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF198754)),
      ),
      home: const HomeScreen(),
    );
  }
}
