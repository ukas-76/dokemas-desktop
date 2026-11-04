import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════
//  PARTNER REVIEW ITEM MODEL
// ═══════════════════════════════════════════════════════════
class PartnerReviewItem {
  final String name;
  final String owner;
  final String category;
  final String statusLabel;
  final Color statusColor;
  final Color statusBg;
  final IconData statusIcon;

  const PartnerReviewItem({
    required this.name,
    required this.owner,
    required this.category,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
    required this.statusIcon,
  });
}

// ═══════════════════════════════════════════════════════════
//  PARTNER REVIEW PANEL (Right column)
// ═══════════════════════════════════════════════════════════
class PartnerReviewPanel extends StatelessWidget {
  const PartnerReviewPanel({super.key});

  static const List<PartnerReviewItem> _items = [
    PartnerReviewItem(
      name: 'Villa Pinus Sentul',
      owner: 'Hendra Kusuma',
      category: 'Penginapan & Resort',
      statusLabel: 'Menunggu Review',
      statusColor: AppTheme.accentAmber,
      statusBg: AppTheme.accentAmberLight,
      statusIcon: Icons.schedule_rounded,
    ),
    PartnerReviewItem(
      name: 'Wisata Arung Jeram Kalibaru',
      owner: 'Siti Rahayu',
      category: 'Destinasi Petualangan',
      statusLabel: 'Dokumen Lengkap',
      statusColor: AppTheme.primaryGreen,
      statusBg: AppTheme.primaryGreenSoft,
      statusIcon: Icons.check_circle_rounded,
    ),
    PartnerReviewItem(
      name: 'Kedai Kopi Lereng Merapi',
      owner: 'Budi Santoso',
      category: 'Kuliner & UMKM',
      statusLabel: 'Verifikasi Izin',
      statusColor: AppTheme.accentBlue,
      statusBg: AppTheme.accentBlueLight,
      statusIcon: Icons.verified_user_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecorationElevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TINJAUAN DOKUMEN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Permohonan\nMitra Terbaru',
                        style: AppTheme.titleMD),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgContent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Lihat Semua (5)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: AppTheme.primaryGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Items
          ..._items.map((item) => _PartnerCard(item: item)).toList(),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final PartnerReviewItem item;

  const _PartnerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgContent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: thumbnail placeholder + name
          Row(
            children: [
              // Thumbnail
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library_rounded,
                    size: 20, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 10),
              // Name + owner
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${item.owner} • ${item.category}',
                      style: AppTheme.bodyXS,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom: status badge + review button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(item.statusIcon, size: 12, color: item.statusColor),
                    const SizedBox(width: 4),
                    Text(
                      item.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _ReviewButton(onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ReviewButton({required this.onTap});

  @override
  State<_ReviewButton> createState() => _ReviewButtonState();
}

class _ReviewButtonState extends State<_ReviewButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.primaryGreenHover
                : AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Text(
                'Tinjau',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

