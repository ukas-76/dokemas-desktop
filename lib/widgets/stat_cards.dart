import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════
//  STAT CARD MODEL
// ═══════════════════════════════════════════════════════════
class StatCardData {
  final IconData icon;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
  final String value;
  final String title;
  final String subtitle;

  const StatCardData({
    required this.icon,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    required this.value,
    required this.title,
    required this.subtitle,
  });
}

// ═══════════════════════════════════════════════════════════
//  STAT CARD WIDGET
// ═══════════════════════════════════════════════════════════
class StatCard extends StatelessWidget {
  final StatCardData data;

  const StatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + badge
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 20, color: AppTheme.primaryGreen),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: data.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.badgeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: data.badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Title
          Text(data.title, style: AppTheme.bodyXS.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          )),
          const SizedBox(height: 4),
          // Value
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(data.subtitle, style: AppTheme.bodySM),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  STAT CARDS ROW (4 cards grid)
// ═══════════════════════════════════════════════════════════
class StatCardsRow extends StatelessWidget {
  const StatCardsRow({super.key});

  static const List<StatCardData> _cards = [
    StatCardData(
      icon: Icons.landscape_rounded,
      badgeLabel: '+12 bulan ini',
      badgeColor: AppTheme.primaryGreen,
      badgeBg: AppTheme.primaryGreenSoft,
      value: '142\nTempat',
      title: 'TOTAL WISATA',
      subtitle: 'Destinasi alam, budaya & edukasi aktif',
    ),
    StatCardData(
      icon: Icons.hotel_rounded,
      badgeLabel: '+8 baru terdaftar',
      badgeColor: AppTheme.accentBlue,
      badgeBg: AppTheme.accentBlueLight,
      value: '328 Hotel\n& Villa',
      title: 'TOTAL PENGINAPAN',
      subtitle: 'Resort, homestay, dan hotel berbintang',
    ),
    StatCardData(
      icon: Icons.verified_rounded,
      badgeLabel: '98.4% kepatuhan',
      badgeColor: AppTheme.primaryGreen,
      badgeBg: AppTheme.primaryGreenSoft,
      value: '1,280\nMitra',
      title: 'MITRA TERVERIFIKASI',
      subtitle: 'Pelaku UMKM, tour guide & pengelola',
    ),
    StatCardData(
      icon: Icons.pending_actions_rounded,
      badgeLabel: 'Perlu tindakan segera',
      badgeColor: AppTheme.accentAmber,
      badgeBg: AppTheme.accentAmberLight,
      value: '5\nPermohonan',
      title: 'PERLU DITINJAU',
      subtitle: '3 pendaftaran tempat baru, 2 mitra',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: _cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: entry.key == 0 ? 0 : 12,
              ),
              child: StatCard(data: entry.value),
            ),
          );
        }).toList(),
      );
    });
  }
}

