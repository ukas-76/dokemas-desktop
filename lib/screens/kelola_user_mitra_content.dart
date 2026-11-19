import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

/// Halaman Kelola User & Mitra — terhubung langsung dengan /api/admin/users
class KelolaUserMitraContent extends StatefulWidget {
  const KelolaUserMitraContent({super.key});

  @override
  State<KelolaUserMitraContent> createState() => _KelolaUserMitraContentState();
}

class _KelolaUserMitraContentState extends State<KelolaUserMitraContent> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];

  String _selectedRoleFilter = 'all'; // all, user, mitra, admin
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalUsers = 0;

  bool _isLoading = true;
  String? _errorMessage;
  bool _isUnauthorized = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isUnauthorized = false;
    });

    try {
      final result = await _apiService.getUsers(
        page: page,
        search: _searchController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _allUsers = result.users;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _totalUsers = result.total;
        _isLoading = false;
      });
      _applyLocalFilter();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isUnauthorized = e.statusCode == 401;
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

  void _applyLocalFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final bool matchesRole;
        switch (_selectedRoleFilter) {
          case 'mitra':
            matchesRole = u.isMitra;
            break;
          case 'admin':
            matchesRole = u.isAdmin;
            break;
          case 'user':
            matchesRole = !u.isMitra && !u.isAdmin;
            break;
          case 'all':
          default:
            matchesRole = true;
        }

        final bool matchesSearch = query.isEmpty ||
            u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query) ||
            (u.phone?.toLowerCase().contains(query) ?? false) ||
            (u.businessName?.toLowerCase().contains(query) ?? false);

        return matchesRole && matchesSearch;
      }).toList();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DIALOG: LIHAT DETAIL USER / MITRA
  // ═══════════════════════════════════════════════════════════════════════
  void _showUserDetailDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _UserAvatar(user: user, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: AppTheme.titleLG),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _RoleBadge(user: user),
                                const SizedBox(width: 8),
                                _StatusBadge(isActive: user.isActive),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppTheme.borderColor),
                  const SizedBox(height: 18),

                  _DetailRow(icon: Icons.tag_rounded, label: 'ID Akun', value: '#${user.id}'),
                  _DetailRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'No. Telepon',
                    value: (user.phone != null && user.phone!.isNotEmpty) ? user.phone! : '-',
                  ),
                  if (user.businessName != null && user.businessName!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.storefront_outlined,
                      label: 'Nama Usaha / Mitra',
                      value: user.businessName!,
                    ),
                  if (user.destinationsCount != null)
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: 'Jumlah Destinasi',
                      value: '${user.destinationsCount} Destinasi',
                    ),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Terdaftar Sejak',
                    value: user.formattedCreatedAt,
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppTheme.borderColor),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          _showUserFormDialog(existing: user);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Akun'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: const BorderSide(color: AppTheme.borderColor),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DIALOG: TAMBAH / EDIT USER & MITRA
  // ═══════════════════════════════════════════════════════════════════════
  void _showUserFormDialog({UserModel? existing}) {
    final bool isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final passwordCtrl = TextEditingController();

    const baseRoles = ['user', 'mitra', 'admin', 'super_admin'];
    final roleOptions = <String>[...baseRoles];
    if (existing != null && !roleOptions.contains(existing.role)) {
      roleOptions.add(existing.role);
    }

    String selectedRole = existing?.role ?? 'mitra';
    bool isActive = existing?.isActive ?? true;
    bool isSubmitting = false;
    String? modalError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenSoft,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isEdit ? Icons.manage_accounts_rounded : Icons.person_add_alt_1_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEdit ? 'Edit User / Mitra' : 'Tambah User / Mitra Baru',
                                      style: AppTheme.titleMD.copyWith(fontSize: 18),
                                    ),
                                    Text(
                                      isEdit
                                          ? 'ID Akun #${existing.id}'
                                          : 'Data akan langsung disimpan ke server backend',
                                      style: AppTheme.bodyXS,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppTheme.borderColor),
                        const SizedBox(height: 16),

                        if (modalError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accentRedLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.accentRed.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              modalError!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentRed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: nameCtrl,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                                  decoration: _inputDecoration('Contoh: Budi Santoso'),
                                ),
                                const SizedBox(height: 14),

                                const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    final t = v?.trim() ?? '';
                                    if (t.isEmpty) return 'Email wajib diisi';
                                    if (!t.contains('@')) return 'Format email tidak valid';
                                    return null;
                                  },
                                  decoration: _inputDecoration('nama@email.com'),
                                ),
                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Peran (Role)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          const SizedBox(height: 6),
                                          DropdownButtonFormField<String>(
                                            initialValue: selectedRole,
                                            decoration: _inputDecoration('Pilih role'),
                                            items: roleOptions.map((r) {
                                              return DropdownMenuItem(
                                                value: r,
                                                child: Text(_formatRoleName(r)),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                setModalState(() => selectedRole = val);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('No. Telepon (Opsional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: phoneCtrl,
                                            keyboardType: TextInputType.phone,
                                            decoration: _inputDecoration('0812xxxxxxxx'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                Text(
                                  isEdit ? 'Kata Sandi Baru (Kosongkan jika tidak diubah)' : 'Kata Sandi',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: passwordCtrl,
                                  obscureText: true,
                                  validator: (v) {
                                    if (!isEdit && (v == null || v.length < 6)) {
                                      return 'Minimal 6 karakter';
                                    }
                                    if (isEdit && v != null && v.isNotEmpty && v.length < 6) {
                                      return 'Minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                  decoration: _inputDecoration('Minimal 6 karakter'),
                                ),
                                const SizedBox(height: 14),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgContent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status Akun Aktif',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'Nonaktifkan untuk menangguhkan akses login',
                                            style: AppTheme.bodyXS,
                                          ),
                                        ],
                                      ),
                                      Switch(
                                        value: isActive,
                                        activeThumbColor: AppTheme.primaryGreen,
                                        onChanged: (val) => setModalState(() => isActive = val),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1, color: AppTheme.borderColor),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Batal'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (formKey.currentState?.validate() != true) return;
                                      setModalState(() {
                                        isSubmitting = true;
                                        modalError = null;
                                      });

                                      final payload = <String, dynamic>{
                                        'name': nameCtrl.text.trim(),
                                        'email': emailCtrl.text.trim(),
                                        'role': selectedRole,
                                        'is_active': isActive,
                                      };
                                      if (phoneCtrl.text.trim().isNotEmpty) {
                                        payload['phone'] = phoneCtrl.text.trim();
                                      }
                                      if (passwordCtrl.text.isNotEmpty) {
                                        payload['password'] = passwordCtrl.text;
                                      }

                                      try {
                                        if (isEdit) {
                                          await _apiService.updateUser(existing.id, payload);
                                        } else {
                                          await _apiService.createUser(payload);
                                        }

                                        if (!dialogCtx.mounted) return;
                                        Navigator.of(dialogCtx).pop();

                                        await _fetchUsers(page: _currentPage);

                                        if (!mounted) return;
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEdit
                                                  ? 'Akun "${nameCtrl.text.trim()}" berhasil diperbarui.'
                                                  : 'Akun "${nameCtrl.text.trim()}" berhasil ditambahkan.',
                                            ),
                                            backgroundColor: AppTheme.primaryGreen,
                                          ),
                                        );
                                      } catch (e) {
                                        setModalState(() {
                                          modalError = e.toString();
                                          isSubmitting = false;
                                        });
                                      }
                                    },
                              icon: isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                              label: Text(
                                isEdit ? 'Simpan Perubahan' : 'Buat Akun',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DIALOG: KONFIRMASI HAPUS USER / MITRA
  // ═══════════════════════════════════════════════════════════════════════
  void _showDeleteConfirmDialog(UserModel user) {
    if (ApiService.currentUser?.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun Super Admin yang sedang aktif tidak dapat dihapus.'),
          backgroundColor: AppTheme.accentAmber,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRedLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Hapus Akun', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5),
                    children: [
                      const TextSpan(text: 'Apakah Anda yakin ingin menghapus akun '),
                      TextSpan(
                        text: '"${user.name}" (${user.email})',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentRed),
                      ),
                      const TextSpan(text: ' dari database DOKEMAS? Tindakan ini tidak dapat dibatalkan.'),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogCtx).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Batal'),
                ),
                ElevatedButton.icon(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setModalState(() => isDeleting = true);
                          try {
                            await _apiService.deleteUser(user.id);
                            if (!dialogCtx.mounted) return;
                            Navigator.of(dialogCtx).pop();

                            await _fetchUsers(page: _currentPage);
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Akun "${user.name}" berhasil dihapus.'),
                                backgroundColor: AppTheme.accentRed,
                              ),
                            );
                          } catch (e) {
                            if (!dialogCtx.mounted) return;
                            Navigator.of(dialogCtx).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus akun: $e'),
                                backgroundColor: AppTheme.accentRed,
                              ),
                            );
                          }
                        },
                  icon: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.delete_forever_rounded, size: 16, color: Colors.white),
                  label: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _formatRoleName(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'mitra':
        return 'Mitra Pengelola';
      case 'user':
        return 'User / Wisatawan';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int mitraCount = _allUsers.where((u) => u.isMitra).length;
    final int regularUserCount = _allUsers.where((u) => !u.isMitra && !u.isAdmin).length;
    final int adminCount = _allUsers.where((u) => u.isAdmin).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Header Bar Halaman ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Kelola User & Mitra', style: AppTheme.titleLG),
                  SizedBox(height: 4),
                  Text(
                    'Data akun wisatawan, mitra pengelola wisata, dan administrator langsung dari server backend.',
                    style: AppTheme.bodySM,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showUserFormDialog(),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: Colors.white),
                label: const Text(
                  '+ Tambah User / Mitra',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── 2. 4 Kartu Metrik Ringkasan Riil ──
          Row(
            children: [
              Expanded(
                child: _UserStatCard(
                  title: 'TOTAL PENGGUNA',
                  value: _isLoading ? '...' : _totalUsers.toString(),
                  subtitle: 'Total Akun Terdaftar',
                  icon: Icons.groups_rounded,
                  color: AppTheme.primaryGreen,
                  bg: AppTheme.primaryGreenSoft,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _UserStatCard(
                  title: 'MITRA PENGELOLA',
                  value: _isLoading ? '...' : mitraCount.toString(),
                  subtitle: 'UMKM, Hotel & Pengelola',
                  icon: Icons.storefront_rounded,
                  color: AppTheme.accentBlue,
                  bg: AppTheme.accentBlueLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _UserStatCard(
                  title: 'USER / WISATAWAN',
                  value: _isLoading ? '...' : regularUserCount.toString(),
                  subtitle: 'Akun Pengunjung Reguler',
                  icon: Icons.person_outline_rounded,
                  color: AppTheme.accentPurple,
                  bg: AppTheme.accentPurpleLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _UserStatCard(
                  title: 'ADMIN & SUPER ADMIN',
                  value: _isLoading ? '...' : adminCount.toString(),
                  subtitle: _errorMessage != null ? 'Koneksi Bermasalah' : 'Tersinkronisasi Backend',
                  icon: Icons.admin_panel_settings_outlined,
                  color: _errorMessage != null ? AppTheme.accentRed : AppTheme.accentAmber,
                  bg: _errorMessage != null ? AppTheme.accentRedLight : AppTheme.accentAmberLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 3. Search & Filter Role Bar ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 340,
                  height: 42,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgContent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyLocalFilter(),
                      onSubmitted: (_) => _fetchUsers(page: 1),
                      decoration: InputDecoration(
                        hintText: 'Cari nama, email, atau no. HP...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  _fetchUsers(page: 1);
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),

                _RoleFilterChip(
                  label: 'Semua',
                  isSelected: _selectedRoleFilter == 'all',
                  onTap: () {
                    setState(() => _selectedRoleFilter = 'all');
                    _applyLocalFilter();
                  },
                ),
                _RoleFilterChip(
                  label: 'Mitra',
                  isSelected: _selectedRoleFilter == 'mitra',
                  onTap: () {
                    setState(() => _selectedRoleFilter = 'mitra');
                    _applyLocalFilter();
                  },
                ),
                _RoleFilterChip(
                  label: 'User / Wisatawan',
                  isSelected: _selectedRoleFilter == 'user',
                  onTap: () {
                    setState(() => _selectedRoleFilter = 'user');
                    _applyLocalFilter();
                  },
                ),
                _RoleFilterChip(
                  label: 'Admin',
                  isSelected: _selectedRoleFilter == 'admin',
                  onTap: () {
                    setState(() => _selectedRoleFilter = 'admin');
                    _applyLocalFilter();
                  },
                ),

                IconButton(
                  onPressed: () => _fetchUsers(page: _currentPage),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  tooltip: 'Muat Ulang Data Backend',
                  color: AppTheme.primaryGreen,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreenSoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 4. Tabel Daftar User & Mitra ──
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 64),
              decoration: AppTheme.cardDecoration,
              child: const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text('Memuat data user & mitra dari server...', style: AppTheme.bodySM),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.accentRedLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.accentRed),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _fetchUsers(page: _currentPage),
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                          label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                        ),
                        if (_isUnauthorized) ...[
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _apiService.logout();
                              if (!context.mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (_) => false,
                              );
                            },
                            icon: const Icon(Icons.login_rounded, size: 16),
                            label: const Text('Login Ulang'),
                            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.accentRed),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: AppTheme.cardDecoration,
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.person_search_rounded, size: 48, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada user atau mitra ditemukan.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Coba ubah filter role atau kata kunci pencarian.',
                      style: AppTheme.bodySM,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: AppTheme.cardDecoration,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Header Tabel
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    color: AppTheme.bgContent,
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('PENGGUNA', style: _tableHeaderStyle),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('EMAIL & KONTAK', style: _tableHeaderStyle),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('ROLE', style: _tableHeaderStyle),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('STATUS', style: _tableHeaderStyle),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('BERGABUNG', style: _tableHeaderStyle),
                        ),
                        SizedBox(
                          width: 132,
                          child: Text(
                            'AKSI',
                            style: _tableHeaderStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.borderColor),

                  // Baris Data
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.borderColor),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _UserTableRow(
                        user: user,
                        onView: () => _showUserDetailDialog(user),
                        onEdit: () => _showUserFormDialog(existing: user),
                        onDelete: () => _showDeleteConfirmDialog(user),
                      );
                    },
                  ),

                  // Paginasi jika halaman > 1
                  if (_lastPage > 1) ...[
                    const Divider(height: 1, color: AppTheme.borderColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Halaman $_currentPage dari $_lastPage (Total $_totalUsers akun)',
                            style: AppTheme.bodyXS,
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _currentPage > 1
                                    ? () => _fetchUsers(page: _currentPage - 1)
                                    : null,
                                child: const Text('Sebelumnya'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: _currentPage < _lastPage
                                    ? () => _fetchUsers(page: _currentPage + 1)
                                    : null,
                                child: const Text('Berikutnya'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

const TextStyle _tableHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: AppTheme.textSecondary,
  letterSpacing: 0.7,
);

// ═════════════════════════════════════════════════════════════════════════
//  CUSTOM WIDGETS MODULAR (Row, Badges, Cards)
// ═════════════════════════════════════════════════════════════════════════

class _UserTableRow extends StatefulWidget {
  final UserModel user;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserTableRow({
    required this.user,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_UserTableRow> createState() => _UserTableRowState();
}

class _UserTableRowState extends State<_UserTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hovered ? AppTheme.bgContent : AppTheme.bgCard,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Pengguna
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _UserAvatar(user: user, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.businessName?.isNotEmpty == true
                              ? user.businessName!
                              : 'ID #${user.id}',
                          style: AppTheme.bodyXS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Email & Kontak
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    Text(
                      user.phone!,
                      style: AppTheme.bodyXS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Role Badge
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RoleBadge(user: user),
              ),
            ),

            // Status Badge
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusBadge(isActive: user.isActive),
              ),
            ),

            // Bergabung
            Expanded(
              flex: 2,
              child: Text(
                user.formattedCreatedAt,
                style: AppTheme.bodySM,
              ),
            ),

            // Aksi
            SizedBox(
              width: 132,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: widget.onView,
                    icon: const Icon(Icons.visibility_outlined, size: 17),
                    tooltip: 'Lihat Detail',
                    color: AppTheme.primaryGreen,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreenSoft,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    tooltip: 'Edit Data / Role',
                    color: AppTheme.textPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.borderLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 17),
                    tooltip: 'Hapus Akun',
                    color: AppTheme.accentRed,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accentRedLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final UserModel user;
  final double size;

  const _UserAvatar({required this.user, this.size = 38});

  @override
  Widget build(BuildContext context) {
    final Color bg = user.isAdmin
        ? AppTheme.primaryGreenSoft
        : user.isMitra
            ? AppTheme.accentBlueLight
            : AppTheme.accentPurpleLight;

    final Color fg = user.isAdmin
        ? AppTheme.primaryGreen
        : user.isMitra
            ? AppTheme.accentBlue
            : AppTheme.accentPurple;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserModel user;

  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final Color bg;

    if (user.isAdmin) {
      fg = AppTheme.primaryGreen;
      bg = AppTheme.primaryGreenSoft;
    } else if (user.isMitra) {
      fg = AppTheme.accentBlue;
      bg = AppTheme.accentBlueLight;
    } else {
      fg = AppTheme.textSecondary;
      bg = AppTheme.borderLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        user.roleLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGreenSoft : AppTheme.accentRedLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryGreen : AppTheme.accentRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? AppTheme.primaryGreen : AppTheme.accentRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreenSoft : AppTheme.bgContent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _UserStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;

  const _UserStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyXS.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.bodyXS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(label, style: AppTheme.bodySM),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

