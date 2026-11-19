import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

/// Panel Kanan Beranda — Menampilkan Akun Mitra / Pengguna Terbaru dari Backend
class PartnerReviewPanel extends StatelessWidget {
  final List<UserModel> users;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final VoidCallback? onReviewUser;

  const PartnerReviewPanel({
    super.key,
    this.users = const [],
    this.isLoading = false,
    this.onSeeAll,
    this.onReviewUser,
  });

  @override
  Widget build(BuildContext context) {
    final mitraOrRecent = users.where((u) => !u.isAdmin).take(3).toList();

    return Container(
      decoration: AppTheme.cardDecorationElevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TINJAUAN MITRA & AKUN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Mitra & Pengguna\nTerbaru', style: AppTheme.titleMD),
                  ],
                ),
              ),
              InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgContent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua (${users.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.primaryGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
            )
          else if (mitraOrRecent.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.bgContent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Center(
                child: Text(
                  'Belum ada data mitra atau pengguna non-admin di server.',
                  style: AppTheme.bodySM,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...mitraOrRecent.map(
              (u) => _PartnerCard(
                user: u,
                onTapReview: onReviewUser ?? onSeeAll ?? () {},
              ),
            ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTapReview;

  const _PartnerCard({
    required this.user,
    required this.onTapReview,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMitraActive = user.isMitra && user.isActive;
    final Color statusColor = isMitraActive
        ? AppTheme.primaryGreen
        : !user.isActive
            ? AppTheme.accentRed
            : AppTheme.accentAmber;
    final Color statusBg = isMitraActive
        ? AppTheme.primaryGreenSoft
        : !user.isActive
            ? AppTheme.accentRedLight
            : AppTheme.accentAmberLight;
    final IconData statusIcon = isMitraActive
        ? Icons.check_circle_rounded
        : !user.isActive
            ? Icons.pause_circle_outline_rounded
            : Icons.schedule_rounded;
    final String statusLabel = isMitraActive
        ? 'Mitra Terverifikasi'
        : !user.isActive
            ? 'Menunggu Aktivasi'
            : 'Perlu Verifikasi';

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.businessName?.isNotEmpty == true ? user.businessName! : user.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${user.email} • ${user.roleLabel}',
                      style: AppTheme.bodyXS,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _ReviewButton(onTap: onTapReview),
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
            color: _hovered ? AppTheme.primaryGreenHover : AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
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
