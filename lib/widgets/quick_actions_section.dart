import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════
//  QUICK ACTION MODEL
// ═══════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════
//  QUICK ACTIONS SECTION
// ═══════════════════════════════════════════════════════════
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  static final List<QuickActionData> _actions = [
    QuickActionData(
      icon: Icons.category_rounded,
      title: 'Tambah Kategori Baru',
      subtitle:
          'Perluas klasifikasi destinasi dan jenis penginapan.',
      actionLabel: 'Buka Pengaturan →',
      onAction: () {},
    ),
    QuickActionData(
      icon: Icons.rate_review_rounded,
      title: 'Moderasi Ulasan Baru',
      subtitle: 'Ada 14 ulasan pengunjung menunggu persetujuan.',
      actionLabel: 'Buka Moderasi (14) →',
      onAction: () {},
    ),
    QuickActionData(
      icon: Icons.download_rounded,
      title: 'Unduh Laporan Bulanan',
      subtitle: 'Ekspor ringkasan performa dan PAD pariwisata format PDF & Excel.',
      actionLabel: 'Unduh Berkas →',
      onAction: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
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

        // Cards row
        Row(
          children: _actions.asMap().entries.map((entry) {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? AppTheme.primaryGreenLight
                : AppTheme.borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovered ? 0.07 : 0.03),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
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
            // Title
            Text(widget.data.title, style: AppTheme.titleMD),
            const SizedBox(height: 6),
            // Subtitle
            Text(widget.data.subtitle, style: AppTheme.bodySM),
            const SizedBox(height: 16),
            // Action link
            InkWell(
              onTap: widget.data.onAction,
              child: Text(
                widget.data.actionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

