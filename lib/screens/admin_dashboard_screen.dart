import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/destination_form_dialog.dart';
import 'beranda_content.dart';
import 'kelola_user_mitra_content.dart';
import 'kelola_wisata_content.dart';
import 'laporan_statistik_content.dart';
import 'login_screen.dart';
import 'moderasi_ulasan_content.dart';
import 'verifikasi_mitra_content.dart';

/// Main Admin Dashboard Screen — Mengintegrasikan Sidebar, Header, dan Konten Utama
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _activeNavIndex = 0;
  String? _globalSearchQuery;
  int _refreshTrigger = 0;

  Future<void> _handleAddNewPlace() async {
    try {
      final created = await DestinationFormDialog.show(context);
      if (created == true && mounted) {
        setState(() {
          _refreshTrigger++;
          _activeNavIndex = 1; // Arahkan ke Kelola Wisata & Hotel agar item baru langsung terlihat
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Destinasi baru berhasil ditambahkan!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka form tambah tempat: $e'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  void _handleGlobalSearch(String query) {
    setState(() {
      _globalSearchQuery = query;
      _activeNavIndex = 1; // Pindah ke halaman Kelola Wisata & Hotel
    });
  }

  Future<void> _handleLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Konfirmasi Keluar',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari sesi Super Admin DOKEMAS?',
            style: AppTheme.bodySM,
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ApiService().logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgContent,
      body: Row(
        children: [
          AdminSidebar(
            activeIndex: _activeNavIndex,
            onItemTapped: (index) => setState(() => _activeNavIndex = index),
            currentUser: user,
            onLogout: _handleLogout,
          ),
          Expanded(
            child: Column(
              children: [
                AdminHeader(
                  adminName: user?.name,
                  onSearchSubmitted: _handleGlobalSearch,
                  onAddNewPlace: _handleAddNewPlace,
                  onNavigateToTab: (idx) => setState(() => _activeNavIndex = idx),
                ),
                Expanded(
                  child: _buildCurrentContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentContent() {
    switch (_activeNavIndex) {
      case 0:
        return BerandaContent(
          refreshTrigger: _refreshTrigger,
          onNavigateToTab: (idx) => setState(() => _activeNavIndex = idx),
        );
      case 1:
        return KelolaWisataContent(
          initialSearchQuery: _globalSearchQuery,
          refreshTrigger: _refreshTrigger,
        );
      case 2:
        return const KelolaUserMitraContent();
      case 3:
        return const VerifikasiMitraContent();
      case 4:
        return const ModerasiUlasanContent();
      case 5:
        return const LaporanStatistikContent();
      default:
        return BerandaContent(
          refreshTrigger: _refreshTrigger,
          onNavigateToTab: (idx) => setState(() => _activeNavIndex = idx),
        );
    }
  }
}
