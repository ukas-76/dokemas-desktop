import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../theme/app_theme.dart';

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
          Text(
            data.title,
            style: AppTheme.bodyXS.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.subtitle,
            style: AppTheme.bodySM,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StatCardsRow extends StatelessWidget {
  final DashboardDataBundle? data;
  final bool isLoading;

  const StatCardsRow({
    super.key,
    this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCardData(
        icon: Icons.landscape_rounded,
        badgeLabel: isLoading
            ? 'Memuat...'
            : '${data?.popularDestinations ?? 0} populer',
        badgeColor: AppTheme.primaryGreen,
        badgeBg: AppTheme.primaryGreenSoft,
        value: isLoading ? '...' : '${data?.totalDestinations ?? 0}\nDestinasi',
        title: 'TOTAL DESTINASI',
        subtitle: 'Destinasi wisata & penginapan aktif di DOKEMAS',
      ),
      StatCardData(
        icon: Icons.category_rounded,
        badgeLabel: isLoading
            ? 'Memuat...'
            : '${data?.totalFacilities ?? 0} fasilitas',
        badgeColor: AppTheme.accentBlue,
        badgeBg: AppTheme.accentBlueLight,
        value: isLoading ? '...' : '${data?.totalCategories ?? 0}\nKategori',
        title: 'KATEGORI & FASILITAS',
        subtitle: 'Klasifikasi destinasi & sarana wisata Banyumas',
      ),
      StatCardData(
        icon: Icons.groups_rounded,
        badgeLabel: isLoading
            ? 'Memuat...'
            : '${data?.totalMitra ?? 0} mitra',
        badgeColor: AppTheme.primaryGreen,
        badgeBg: AppTheme.primaryGreenSoft,
        value: isLoading ? '...' : '${data?.totalUsers ?? 0}\nPengguna',
        title: 'USER & MITRA',
        subtitle: 'Total akun wisatawan, mitra & pengelola terdaftar',
      ),
      StatCardData(
        icon: Icons.rate_review_rounded,
        badgeLabel: isLoading
            ? 'Memuat...'
            : (data != null && data!.averageRating > 0
                ? '${data!.averageRating.toStringAsFixed(1)}★ rata-rata'
                : 'Live API'),
        badgeColor: AppTheme.accentAmber,
        badgeBg: AppTheme.accentAmberLight,
        value: isLoading ? '...' : '${data?.totalReviews ?? 0}\nUlasan',
        title: 'ULASAN WISATAWAN',
        subtitle: 'Total ulasan & masukan pengunjung masuk',
      ),
    ];

    return Row(
      children: cards.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: entry.key == 0 ? 0 : 12),
            child: StatCard(data: entry.value),
          ),
        );
      }).toList(),
    );
  }
}
