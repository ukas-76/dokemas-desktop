import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Header / Top Bar Widget — sits above the main content area
class AdminHeader extends StatefulWidget {
  final String? adminName;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onAddNewPlace;
  final ValueChanged<int>? onNavigateToTab;

  const AdminHeader({
    super.key,
    this.adminName,
    this.onSearchSubmitted,
    this.onAddNewPlace,
    this.onNavigateToTab,
  });

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasNotification = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    widget.onSearchSubmitted?.call(_searchController.text.trim());
  }

  void _showNotificationsDialog() {
    setState(() => _hasNotification = false);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notifikasi & Pintasan', style: AppTheme.titleMD),
                      IconButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppTheme.borderColor),
                  _NotifTile(
                    icon: Icons.people_alt_rounded,
                    color: AppTheme.accentBlue,
                    title: 'Kelola User & Mitra',
                    subtitle: 'Pantau akun mitra pengelola & pengguna baru.',
                    onTap: () {
                      Navigator.of(dialogCtx).pop();
                      widget.onNavigateToTab?.call(2);
                    },
                  ),
                  _NotifTile(
                    icon: Icons.verified_user_rounded,
                    color: AppTheme.primaryGreen,
                    title: 'Verifikasi Mitra',
                    subtitle: 'Tinjau aktivasi & persetujuan mitra usaha.',
                    onTap: () {
                      Navigator.of(dialogCtx).pop();
                      widget.onNavigateToTab?.call(3);
                    },
                  ),
                  _NotifTile(
                    icon: Icons.rate_review_rounded,
                    color: AppTheme.accentAmber,
                    title: 'Moderasi Ulasan',
                    subtitle: 'Periksa ulasan pengunjung terbaru dari server.',
                    onTap: () {
                      Navigator.of(dialogCtx).pop();
                      widget.onNavigateToTab?.call(4);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildGreeting(),
          const SizedBox(width: 32),
          Expanded(child: _buildSearchBar()),
          const SizedBox(width: 20),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final String name = widget.adminName?.isNotEmpty == true
        ? widget.adminName!.split(' ').first
        : 'Admin';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Selamat Pagi, $name! ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Text('👋', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Pantau dan kelola ekosistem pariwisata DOKEMAS.',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppTheme.bgContent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _triggerSearch(),
        style: const TextStyle(
          fontSize: 13.5,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Cari destinasi, hotel... (tekan Enter)',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppTheme.textMuted,
          ),
          prefixIcon: IconButton(
            icon: const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            onPressed: _triggerSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _IconButton(
              icon: Icons.notifications_outlined,
              onTap: _showNotificationsDialog,
            ),
            if (_hasNotification)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        _AddButton(
          label: '+ Tambah Tempat Baru',
          onTap: widget.onAddNewPlace ?? () {},
        ),
      ],
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NotifTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: AppTheme.bodyXS),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: onTap,
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.bgContent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? AppTheme.borderColor : Colors.transparent,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _AddButton({required this.label, required this.onTap});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.primaryGreenHover : AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: _hovered ? 0.35 : 0.2),
                blurRadius: _hovered ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
