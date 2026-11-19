import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_manager_dialog.dart';
import '../widgets/partner_review_panel.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/stat_cards.dart';
import '../widgets/visitor_chart.dart';

class BerandaContent extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  final int refreshTrigger;

  const BerandaContent({
    super.key,
    this.onNavigateToTab,
    this.refreshTrigger = 0,
  });

  @override
  State<BerandaContent> createState() => _BerandaContentState();
}

class _BerandaContentState extends State<BerandaContent> {
  final ApiService _apiService = ApiService();

  DashboardDataBundle? _bundle;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void didUpdateWidget(covariant BerandaContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _loadDashboard();
    }
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bundle = await _apiService.getDashboardBundle();
      if (!mounted) return;
      setState(() {
        _bundle = bundle;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accentRedLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sebagian data beranda gagal dimuat: $_errorMessage',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accentRed),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadDashboard,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Muat Ulang'),
                  ),
                ],
              ),
            ),
          ],

          // ── 1. Metrik Ringkasan Real-time ──
          StatCardsRow(data: _bundle, isLoading: _isLoading),

          const SizedBox(height: 24),

          // ── 2. Grid Tengah (Analitik Kiri 60% & Tinjauan Mitra Kanan 40%) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 60,
                child: VisitorChartSection(data: _bundle, isLoading: _isLoading),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 40,
                child: PartnerReviewPanel(
                  users: _bundle?.recentUsers ?? const [],
                  isLoading: _isLoading,
                  onSeeAll: () => widget.onNavigateToTab?.call(2),
                  onReviewUser: () => widget.onNavigateToTab?.call(3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 3. Aksi Cepat & Pintasan ──
          QuickActionsSection(
            reviewsCount: _bundle?.totalReviews ?? 0,
            onManageCategories: () => CategoryManagerDialog.show(
              context,
              onChanged: _loadDashboard,
            ),
            onOpenReviews: () => widget.onNavigateToTab?.call(4),
            onOpenReports: () => widget.onNavigateToTab?.call(5),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
