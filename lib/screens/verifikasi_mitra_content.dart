import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Halaman Verifikasi Mitra — terhubung dengan data riil /api/admin/users
class VerifikasiMitraContent extends StatefulWidget {
  const VerifikasiMitraContent({super.key});

  @override
  State<VerifikasiMitraContent> createState() => _VerifikasiMitraContentState();
}

class _VerifikasiMitraContentState extends State<VerifikasiMitraContent> {
  final ApiService _apiService = ApiService();

  List<UserModel> _allAccounts = [];
  List<UserModel> _filteredAccounts = [];
  int _selectedIndex = 0;
  String _statusFilter = 'all'; // all, pending, active
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;

  final Map<String, bool> _checklistState = {
    'Email & Identitas Pemilik Terverifikasi': true,
    'Peran Mitra / Pengelola Sesuai Ketentuan': true,
    'Nomor Kontak Dapat Dihubungi': true,
    'Kepatuhan Standar Layanan DOKEMAS': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getUsers(page: 1);
      // Prioritaskan mitra dan akun non-admin untuk antrean verifikasi mitra
      final candidates = res.users.where((u) => !u.isAdmin).toList();

      if (!mounted) return;
      setState(() {
        _allAccounts = candidates;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredAccounts = _allAccounts.where((u) {
        if (_statusFilter == 'pending') {
          return !u.isActive || !u.isMitra;
        }
        if (_statusFilter == 'active') {
          return u.isMitra && u.isActive;
        }
        return true;
      }).toList();

      if (_selectedIndex >= _filteredAccounts.length) {
        _selectedIndex = 0;
      }
    });
  }

  Future<void> _updatePartnerStatus(UserModel account, {required bool approve}) async {
    setState(() => _isUpdating = true);

    try {
      await _apiService.updateUser(account.id, {
        'name': account.name,
        'email': account.email,
        'role': approve ? 'mitra' : account.role,
        'is_active': approve,
      });

      await _fetchAccounts();
      if (!mounted) return;
      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Akun "${account.name}" disetujui dan diaktifkan sebagai Mitra.'
                : 'Akun "${account.name}" dinonaktifkan / diminta revisi.',
          ),
          backgroundColor: approve ? AppTheme.primaryGreen : AppTheme.accentRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryGreen),
            SizedBox(height: 14),
            Text('Memuat daftar mitra dari server...', style: AppTheme.bodySM),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.accentRedLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.accentRed),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentRed),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchAccounts,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              ),
            ],
          ),
        ),
      );
    }

    final UserModel? selectedItem =
        _filteredAccounts.isNotEmpty ? _filteredAccounts[_selectedIndex] : null;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═════════════════════════════════════════════
          //  KOLOM KIRI (35%): Daftar Antrean Mitra
          // ═════════════════════════════════════════════
          Expanded(
            flex: 35,
            child: Container(
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Antrean Verifikasi Mitra',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: _fetchAccounts,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              tooltip: 'Muat Ulang',
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _FilterPill(
                              label: 'Semua (${_allAccounts.length})',
                              selected: _statusFilter == 'all',
                              onTap: () {
                                _statusFilter = 'all';
                                _applyFilter();
                              },
                            ),
                            _FilterPill(
                              label: 'Perlu Tinjau',
                              selected: _statusFilter == 'pending',
                              onTap: () {
                                _statusFilter = 'pending';
                                _applyFilter();
                              },
                            ),
                            _FilterPill(
                              label: 'Mitra Aktif',
                              selected: _statusFilter == 'active',
                              onTap: () {
                                _statusFilter = 'active';
                                _applyFilter();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.borderColor),
                  Expanded(
                    child: _filteredAccounts.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Tidak ada akun pada filter ini.',
                                style: AppTheme.bodySM,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _filteredAccounts.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.borderColor),
                            itemBuilder: (context, index) {
                              final item = _filteredAccounts[index];
                              final bool isSelected = _selectedIndex == index;

                              final String badgeText = item.isMitra && item.isActive
                                  ? 'Mitra Aktif'
                                  : !item.isActive
                                      ? 'Nonaktif'
                                      : 'Kandidat Mitra';
                              final Color statusColor = item.isMitra && item.isActive
                                  ? AppTheme.primaryGreen
                                  : !item.isActive
                                      ? AppTheme.accentRed
                                      : AppTheme.accentAmber;
                              final Color statusBg = item.isMitra && item.isActive
                                  ? AppTheme.primaryGreenSoft
                                  : !item.isActive
                                      ? AppTheme.accentRedLight
                                      : AppTheme.accentAmberLight;

                              return InkWell(
                                onTap: () => setState(() => _selectedIndex = index),
                                child: Container(
                                  color: isSelected
                                      ? AppTheme.primaryGreenSoft.withValues(alpha: 0.4)
                                      : Colors.transparent,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isSelected)
                                        Container(
                                          width: 3,
                                          height: 48,
                                          margin: const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGreen,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.businessName?.isNotEmpty == true
                                                        ? item.businessName!
                                                        : item.name,
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: statusBg,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    badgeText,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text('${item.name} • ${item.roleLabel}', style: AppTheme.bodyXS),
                                            const SizedBox(height: 4),
                                            Text(item.email, style: AppTheme.bodyXS),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),

          // ═════════════════════════════════════════════
          //  KOLOM KANAN (65%): Detail Terpilih
          // ═════════════════════════════════════════════
          Expanded(
            flex: 65,
            child: selectedItem == null
                ? Container(
                    padding: const EdgeInsets.all(48),
                    decoration: AppTheme.cardDecoration,
                    child: const Center(
                      child: Text('Pilih akun di sebelah kiri untuk meninjau detail.', style: AppTheme.bodySM),
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      decoration: AppTheme.cardDecoration,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedItem.businessName?.isNotEmpty == true
                                          ? selectedItem.businessName!
                                          : selectedItem.name,
                                      style: AppTheme.titleLG,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID Akun: #${selectedItem.id} • Role: ${selectedItem.roleLabel}',
                                      style: AppTheme.bodySM,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selectedItem.isActive
                                      ? AppTheme.primaryGreenSoft
                                      : AppTheme.accentRedLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  selectedItem.isActive ? 'Status: Aktif' : 'Status: Nonaktif',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: selectedItem.isActive
                                        ? AppTheme.primaryGreen
                                        : AppTheme.accentRed,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: AppTheme.borderColor),
                          const SizedBox(height: 20),

                          const Text(
                            'IDENTITAS PENGELOLA / PEMILIK AKUN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgContent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(Icons.person_outline, 'Nama Pemilik', selectedItem.name),
                                ),
                                Expanded(
                                  child: _buildInfoItem(
                                    Icons.phone_outlined,
                                    'Kontak Telepon',
                                    selectedItem.phone?.isNotEmpty == true ? selectedItem.phone! : '-',
                                  ),
                                ),
                                Expanded(
                                  child: _buildInfoItem(Icons.email_outlined, 'Email Terdaftar', selectedItem.email),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'RINGKASAN AKUN & KELENGKAPAN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                            children: [
                              _DocPreviewCard(
                                title: 'Role Saat Ini',
                                subtitle: selectedItem.roleLabel,
                                icon: Icons.badge_outlined,
                              ),
                              _DocPreviewCard(
                                title: 'Verifikasi Email',
                                subtitle: selectedItem.emailVerifiedAt != null ? 'Terverifikasi' : 'Belum/Opsional',
                                icon: Icons.mark_email_read_outlined,
                              ),
                              _DocPreviewCard(
                                title: 'Terdaftar Sejak',
                                subtitle: selectedItem.formattedCreatedAt,
                                icon: Icons.calendar_today_outlined,
                              ),
                              _DocPreviewCard(
                                title: 'Status Akun',
                                subtitle: selectedItem.isActive ? 'Aktif' : 'Ditangguhkan',
                                icon: Icons.verified_user_outlined,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'DAFTAR PERIKSA KEPATUHAN (VERIFIKASI)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.bgContent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              children: _checklistState.keys.map((key) {
                                return CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppTheme.primaryGreen,
                                  title: Text(
                                    key,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  value: _checklistState[key],
                                  onChanged: (val) {
                                    setState(() => _checklistState[key] = val ?? false);
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isUpdating
                                      ? null
                                      : () => _updatePartnerStatus(selectedItem, approve: false),
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  label: const Text(
                                    'Nonaktifkan / Minta Revisi',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.accentRed,
                                    side: const BorderSide(color: AppTheme.accentRed, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isUpdating
                                      ? null
                                      : () => _updatePartnerStatus(selectedItem, approve: true),
                                  icon: _isUpdating
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.check_circle_outline_rounded, size: 18),
                                  label: const Text(
                                    'Setujui & Aktifkan Mitra',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodyXS),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreenSoft : AppTheme.bgContent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DocPreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DocPreviewCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgContent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryGreen),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
