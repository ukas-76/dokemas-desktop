class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? businessName;
  final String? avatarUrl;
  final String? status;
  final bool isActive;
  final String? emailVerifiedAt;
  final String? createdAt;
  final int? destinationsCount;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.businessName,
    this.avatarUrl,
    this.status,
    this.isActive = true,
    this.emailVerifiedAt,
    this.createdAt,
    this.destinationsCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final String rawRole = (json['role'] ?? json['user_type'] ?? 'user')
        .toString()
        .trim()
        .toLowerCase();

    final String? rawStatus = json['status']?.toString();
    bool active = true;
    if (json['is_active'] != null) {
      active = json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1';
    } else if (rawStatus != null) {
      final s = rawStatus.toLowerCase();
      active = s != 'inactive' && s != 'suspended' && s != 'banned' && s != 'rejected';
    }

    int? destCount;
    if (json['destinations_count'] != null) {
      destCount = json['destinations_count'] is num
          ? (json['destinations_count'] as num).toInt()
          : int.tryParse(json['destinations_count'].toString());
    }

    return UserModel(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['full_name'] ?? 'Tanpa Nama').toString(),
      email: (json['email'] ?? '-').toString(),
      role: rawRole.isEmpty ? 'user' : rawRole,
      phone: (json['phone'] ?? json['no_hp'] ?? json['phone_number'])?.toString(),
      businessName: (json['business_name'] ?? json['nama_usaha'])?.toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatar'])?.toString(),
      status: rawStatus,
      isActive: active,
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      destinationsCount: destCount,
    );
  }

  bool get isSuperAdmin => role == 'super_admin' || role == 'superadmin';
  bool get isAdmin => role == 'admin' || isSuperAdmin;
  bool get isMitra => role == 'mitra' || role == 'partner' || role == 'merchant';

  String get roleLabel {
    switch (role) {
      case 'super_admin':
      case 'superadmin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'mitra':
      case 'partner':
      case 'merchant':
        return 'Mitra';
      case 'user':
      case 'wisatawan':
      default:
        return 'User / Wisatawan';
    }
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return '-';
    final parsed = DateTime.tryParse(createdAt!);
    if (parsed == null) return createdAt!;
    final local = parsed.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
  }
}

class PaginatedUsersResponse {
  final List<UserModel> users;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedUsersResponse({
    required this.users,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

