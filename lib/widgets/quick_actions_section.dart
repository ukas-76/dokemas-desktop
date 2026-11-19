import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  const QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onAction,
  });
}

class QuickActionsSection extends StatelessWidget {
  final int reviewsCount;
  final VoidCallback? onManageCategories;
  final VoidCallback? onOpenReviews;
  final VoidCallback? onOpenReports;

  const QuickActionsSection({
    super.key,
    this.reviewsCount = 0,
    this.onManageCategories,
    this.onOpenReviews,
    this.onOpenReports,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickActionData(
        icon: Icons.category_rounded,
        title: 'Kelola Kategori Wisata',
        subtitle: 'Tambah, ubah, atau perbarui klasifikasi destinasi Kabupaten Banyumas.',
        actionLabel: 'Buka Pengaturan →',
        onAction: onManageCategories,
      ),
      QuickActionData(
        icon: Icons.rate_review_rounded,
        title: 'Moderasi Ulasan Masuk',
        subtitle: 'Terdapat $reviewsCount ulasan wisatawan yang tercatat di sistem.',
        actionLabel: 'Buka Moderasi ($reviewsCount) →',
        onAction: onOpenReviews,
      ),
      QuickActionData(
        icon: Icons.bar_chart_rounded,
        title: 'Laporan & Ekspor Data',
        subtitle: 'Lihat ringkasan statistik destinasi dan ekspor berkas CSV.',
        actionLabel: 'Buka Laporan →',
        onAction: onOpenReports,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PINTASAN ADMINISTRATIF',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Aksi Cepat & Pintasan', style: AppTheme.titleLG),
        const SizedBox(height: 4),
        const Text(
          'Akses cepat ke alur kerja rutin pengelolaan ekosistem pariwisata daerah.',
          style: AppTheme.bodySM,
        ),
        const SizedBox(height: 20),
        Row(
          children: actions.asMap().entries.map((entry) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: entry.key == 0 ? 0 : 16),
                child: _QuickActionCard(data: entry.value),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final QuickActionData data;

  const _QuickActionCard({required this.data});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.data.onAction,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? AppTheme.primaryGreenLight : AppTheme.borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.07 : 0.03),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.data.icon,
                  size: 22,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 14),
              Text(widget.data.title, style: AppTheme.titleMD),
              const SizedBox(height: 6),
              Text(widget.data.subtitle, style: AppTheme.bodySM),
              const SizedBox(height: 16),
              Text(
                widget.data.actionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
