import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dokemas_dekstop/main.dart';
import 'package:dokemas_dekstop/models/user_model.dart';
import 'package:dokemas_dekstop/screens/admin_dashboard_screen.dart';
import 'package:dokemas_dekstop/services/api_service.dart';

void main() {
  setUp(() {
    ApiService.authToken = null;
    ApiService.currentUser = null;
  });

  testWidgets('Menampilkan halaman Login Super Admin saat belum terautentikasi',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const DokemasAdminApp());

    expect(find.text('Super Admin Portal'), findsOneWidget);
    expect(find.text('Masuk ke Dashboard'), findsOneWidget);
    expect(find.text('Lupa Kata Sandi?'), findsOneWidget);
    expect(find.text('Masuk ke Admin Panel'), findsOneWidget);
  });

  testWidgets('AdminDashboardScreen menampilkan 6 menu navigasi utama',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    ApiService.authToken = 'test-token';
    ApiService.currentUser = const UserModel(
      id: 1,
      name: 'Budi Admin',
      email: 'admin@dokemas.id',
      role: 'super_admin',
    );

    await tester.pumpWidget(
      const MaterialApp(home: AdminDashboardScreen()),
    );

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Kelola Wisata & Hotel'), findsOneWidget);
    expect(find.text('Kelola User & Mitra'), findsOneWidget);
    expect(find.text('Verifikasi Mitra'), findsOneWidget);
    expect(find.text('Moderasi Ulasan'), findsOneWidget);
    expect(find.text('Laporan & Statistik'), findsOneWidget);
    expect(find.text('Halo, Budi!'), findsOneWidget);
  });
}
