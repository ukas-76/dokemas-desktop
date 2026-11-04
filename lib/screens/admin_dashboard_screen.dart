import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_header.dart';
import '../widgets/stat_cards.dart';
import '../widgets/visitor_chart.dart';
import '../widgets/partner_review_panel.dart';
import '../widgets/quick_actions_section.dart';

/// Main Admin Dashboard Screen — composes Sidebar + Header + Content
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _activeNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgContent,
      body: Row(
        children: [
          // ════════════════════════════
          //  LEFT — Sidebar
          // ════════════════════════════
          AdminSidebar(
            activeIndex: _activeNavIndex,
            onItemTapped: (index) => setState(() => _activeNavIndex = index),
          ),

          // ════════════════════════════
          //  RIGHT — Header + Content
          // ════════════════════════════
          Expanded(
            child: Column(
              children: [
                // ── Top Bar ──
                const AdminHeader(),

                // ── Scrollable Content ──
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Show dashboard home for index 0, placeholder for others
    if (_activeNavIndex != 0) {
      return _PlaceholderContent(index: _activeNavIndex);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Stat Cards ──
          const StatCardsRow(),

          const SizedBox(height: 24),

          // ── 2. Chart + Partner Review (side by side) ──
          _buildMiddleRow(),

          const SizedBox(height: 24),

          // ── 3. Quick Actions ──
          const QuickActionsSection(),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildMiddleRow() {
    return LayoutBuilder(builder: (context, constraints) {
      // Chart takes ~60%, Partner Review ~40%
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          Expanded(
            flex: 60,
            child: const VisitorChartSection(),
          ),
          const SizedBox(width: 20),
          // Partner Review
          Expanded(
            flex: 40,
            child: const PartnerReviewPanel(),
          ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════
//  PLACEHOLDER for other nav pages
// ═══════════════════════════════════════════════════════════
class _PlaceholderContent extends StatelessWidget {
  final int index;

  const _PlaceholderContent({required this.index});

  static const List<String> _pageNames = [
    'Beranda',
    'Kelola Wisata & Hotel',
    'Verifikasi Mitra',
    'Moderasi Ulasan',
    'Laporan & Statistik',
  ];

  static const List<IconData> _pageIcons = [
    Icons.dashboard_rounded,
    Icons.hotel_rounded,
    Icons.verified_user_rounded,
    Icons.rate_review_rounded,
    Icons.bar_chart_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _pageIcons[index],
              size: 36,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _pageNames[index],
            style: AppTheme.titleXL,
          ),
          const SizedBox(height: 8),
          const Text(
            'Halaman ini sedang dalam pengembangan.',
            style: AppTheme.bodySM,
          ),
        ],
      ),
    );
  }
}

