import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/destination_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_manager_dialog.dart';
import '../widgets/destination_form_dialog.dart';

// ═════════════════════════════════════════════════════════════════════
//  DESTINATION CARD WIDGET (Menampilkan Data Riil dari Backend)
// ═════════════════════════════════════════════════════════════════════
class DestinationCard extends StatelessWidget {
  final DestinationModel item;
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const DestinationCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryName = item.category?.name.isNotEmpty == true
        ? item.category!.name
        : 'Destinasi';

    return Container(
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail Header dengan Badge Kategori & Rating Riil ──
          Container(
            height: 145,
            width: double.infinity,
            color: const Color(0xFFE2E8F0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty)
                  Image.network(
                    item.thumbnailUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Center(
                          child: Icon(
                            Icons.landscape_rounded,
                            size: 44,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 44,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),

                // Badge Kategori (Pojok Kiri Atas)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),

                // Rating & Popularitas (Pojok Kanan Atas)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppTheme.accentAmber),
                        const SizedBox(width: 4),
                        Text(
                          item.ratingAvg > 0 ? item.ratingAvg.toStringAsFixed(1) : 'Baru',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Informasi Detail Tempat ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.address.isNotEmpty ? item.address : 'Kabupaten Banyumas',
                        style: AppTheme.bodyXS,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.formattedPrice,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.bgContent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 11, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(item.openingHours, style: AppTheme.bodyXS),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (item.images.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreenSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.images.length} Foto',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),
          const Divider(height: 1, color: AppTheme.borderColor),

          // ── Tombol Aksi (Edit Data, View, Hapus) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 13),
                    label: const Text('Edit Data', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  tooltip: 'Lihat Detail',
                  color: AppTheme.primaryGreen,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreenSoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  tooltip: 'Hapus Tempat',
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
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
//  MAIN SCREEN CONTENT (Kelola Wisata & Hotel Terhubung Backend Riil)
// ═════════════════════════════════════════════════════════════════════
class KelolaWisataContent extends StatefulWidget {
  final String? initialSearchQuery;
  final int refreshTrigger;

  const KelolaWisataContent({
    super.key,
    this.initialSearchQuery,
    this.refreshTrigger = 0,
  });

  @override
  State<KelolaWisataContent> createState() => _KelolaWisataContentState();
}

class _KelolaWisataContentState extends State<KelolaWisataContent> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<DestinationModel> _allDestinations = [];
  List<DestinationModel> _filteredDestinations = [];
  List<CategoryModel> _categories = [];
  List<FacilityModel> _facilities = [];

  String _selectedCategorySlug = 'all';
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalDestinations = 0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _fetchInitialData();
  }

  @override
  void didUpdateWidget(covariant KelolaWisataContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSearchQuery != oldWidget.initialSearchQuery &&
        widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
      _applyFilter();
    }
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _fetchInitialData(page: _currentPage);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getDestinationsPaginated(page: page),
        _apiService.getCategories(),
        _apiService.getFacilities().catchError((_) => <FacilityModel>[]),
      ]);

      final destRes = results[0] as PaginatedDestinationsResponse;
      final categories = results[1] as List<CategoryModel>;
      final facilities = results[2] as List<FacilityModel>;

      if (!mounted) return;
      setState(() {
        _allDestinations = destRes.destinations;
        _currentPage = destRes.currentPage;
        _lastPage = destRes.lastPage;
        _totalDestinations = destRes.total;
        _categories = categories;
        _facilities = facilities;
        _isLoading = false;
      });

      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredDestinations = _allDestinations.where((item) {
        final bool matchesCategory = _selectedCategorySlug == 'all' ||
            item.category?.slug == _selectedCategorySlug;

        final bool matchesSearch = query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            item.address.toLowerCase().contains(query) ||
            (item.category?.name.toLowerCase().contains(query) ?? false);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  //  AKSI 1: DETAIL DESTINASI (VIEW DIALOG MODAL + FASILITAS RIIL)
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _showDetailDialog(DestinationModel item) async {
    DestinationModel detail = item;
    try {
      detail = await _apiService.getDestinationDetail(item.id);
    } catch (_) {}

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: detail.thumbnailUrl != null && detail.thumbnailUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                detail.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(Icons.landscape, size: 64, color: AppTheme.textMuted),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.landscape, size: 64, color: AppTheme.textMuted),
                            ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: Colors.black54),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          detail.category?.name ?? 'Destinasi Wisata',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(detail.name, style: AppTheme.titleLG),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(detail.address, style: AppTheme.bodySM),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreenSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                detail.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1, color: AppTheme.borderColor),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            _buildDetailBadge(
                              Icons.star_rounded,
                              'Rating Pengunjung',
                              '${detail.ratingAvg > 0 ? detail.ratingAvg.toStringAsFixed(1) : '0'} (${detail.reviewsCount} Ulasan)',
                              AppTheme.accentAmber,
                            ),
                            const SizedBox(width: 16),
                            _buildDetailBadge(
                              Icons.access_time_rounded,
                              'Jam Buka',
                              detail.openingHours,
                              AppTheme.accentBlue,
                            ),
                            const SizedBox(width: 16),
                            _buildDetailBadge(
                              Icons.verified_rounded,
                              'Popularitas',
                              detail.isPopular ? 'Destinasi Populer' : 'Reguler',
                              AppTheme.primaryGreen,
                            ),
                          ],
                        ),

                        if (detail.facilities.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'FASILITAS TERSEDIA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: detail.facilities.map((fac) {
                              return Chip(
                                avatar: const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.primaryGreen),
                                label: Text(fac.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                backgroundColor: AppTheme.primaryGreenSoft,
                                side: const BorderSide(color: AppTheme.primaryGreenLight),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 22),

                        const Text(
                          'DESKRIPSI DESTINASI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detail.description.isNotEmpty
                              ? detail.description
                              : 'Belum ada deskripsi lengkap untuk tempat ini.',
                          style: const TextStyle(fontSize: 13.5, height: 1.6, color: AppTheme.textPrimary),
                        ),

                        if (detail.images.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'GALERI FOTO (${detail.images.length})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: detail.images.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 10),
                              itemBuilder: (context, idx) {
                                final img = detail.images[idx];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: img.imageUrl != null
                                      ? Image.network(
                                          img.imageUrl!,
                                          width: 140,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 140,
                                          height: 100,
                                          color: AppTheme.bgContent,
                                          child: const Icon(Icons.image, color: AppTheme.textMuted),
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppTheme.bgContent,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    border: Border(top: BorderSide(color: AppTheme.borderColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openDestinationForm(existing: detail);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Destinasi'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailBadge(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgContent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.bodyXS),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  AKSI 2: TAMBAH / EDIT DESTINASI (TERVALIDASI API RIIL)
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _openDestinationForm({DestinationModel? existing}) async {
    final saved = await DestinationFormDialog.show(
      context,
      existing: existing,
      categories: _categories,
      facilities: _facilities,
    );

    if (saved == true && mounted) {
      await _fetchInitialData(page: _currentPage);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing != null
                ? 'Data "${existing.name}" berhasil diperbarui!'
                : 'Destinasi baru berhasil ditambahkan!',
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  AKSI 3: HAPUS DATA (TERVALIDASI API RIIL)
  // ═══════════════════════════════════════════════════════════════════
  void _showDeleteConfirmDialog(DestinationModel item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isDeleting = false;

        return StatefulBuilder(builder: (context, setModalState) {
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
                  child: const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRed, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5),
                  children: [
                    const TextSpan(text: 'Apakah Anda yakin ingin menghapus destinasi '),
                    TextSpan(
                      text: '"${item.name}"',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentRed),
                    ),
                    const TextSpan(
                      text: ' dari database DOKEMAS? Tindakan ini tidak dapat dibatalkan.',
                    ),
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
                          await _apiService.deleteDestination(item.id);
                          if (!dialogCtx.mounted) return;
                          Navigator.of(dialogCtx).pop();

                          await _fetchInitialData(page: _currentPage);
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Destinasi "${item.name}" berhasil dihapus.'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        } catch (e) {
                          if (!dialogCtx.mounted) return;
                          Navigator.of(dialogCtx).pop();
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menghapus: $e'),
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
                label: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPopuler = _allDestinations.where((d) => d.isPopular).length;
    final int totalKategori = _categories.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Metrik Statistik Riil (4 Small Stat Cards) ──
          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  title: 'TOTAL DESTINASI AKTIF',
                  value: _isLoading ? '...' : _totalDestinations.toString(),
                  subtitle: 'Tersedia di Ekosistem DOKEMAS',
                  icon: Icons.place_rounded,
                  color: AppTheme.primaryGreen,
                  bg: AppTheme.primaryGreenSoft,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SmallStatCard(
                  title: 'DESTINASI POPULER',
                  value: _isLoading ? '...' : totalPopuler.toString(),
                  subtitle: 'Rekomendasi Utama Wisatawan',
                  icon: Icons.trending_up_rounded,
                  color: AppTheme.accentAmber,
                  bg: AppTheme.accentAmberLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SmallStatCard(
                  title: 'TOTAL KATEGORI',
                  value: _isLoading ? '...' : totalKategori.toString(),
                  subtitle: '${_facilities.length} Fasilitas Tersedia',
                  icon: Icons.category_rounded,
                  color: AppTheme.accentBlue,
                  bg: AppTheme.accentBlueLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SmallStatCard(
                  title: 'STATUS SERVER',
                  value: _errorMessage != null ? 'Error' : 'Terhubung',
                  subtitle: 'Backend Laravel Live',
                  icon: _errorMessage != null ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                  color: _errorMessage != null ? AppTheme.accentRed : AppTheme.primaryGreen,
                  bg: _errorMessage != null ? AppTheme.accentRedLight : AppTheme.primaryGreenSoft,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 2. Filter Bar + Kelola Kategori + Tambah Tempat ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.bgContent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilter(),
                      decoration: InputDecoration(
                        hintText: 'Cari destinasi berdasarkan nama, alamat, atau kategori...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFilter();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.bgContent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategorySlug,
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('Semua Kategori'),
                        ),
                        ..._categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.slug,
                            child: Text(cat.name),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategorySlug = val);
                          _applyFilter();
                        }
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                OutlinedButton.icon(
                  onPressed: () => CategoryManagerDialog.show(
                    context,
                    onChanged: () => _fetchInitialData(page: _currentPage),
                  ),
                  icon: const Icon(Icons.category_outlined, size: 16),
                  label: const Text('Kelola Kategori', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.borderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed: () => _openDestinationForm(),
                  icon: const Icon(Icons.add_rounded, size: 17, color: Colors.white),
                  label: const Text('Tambah Tempat', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: () => _fetchInitialData(page: _currentPage),
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

          const SizedBox(height: 24),

          // ── 3. Area Grid Destinasi Riil / Loading / Error State ──
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Menghubungi Backend Laravel DOKEMAS...',
                      style: AppTheme.bodySM,
                    ),
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
                      'Gagal Mengambil Data: $_errorMessage',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _fetchInitialData(page: _currentPage),
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                      label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredDestinations.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: AppTheme.cardDecoration,
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada destinasi yang sesuai dengan filter.',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Coba ubah kata kunci pencarian atau pilih kategori lain.',
                      style: AppTheme.bodySM,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _selectedCategorySlug = 'all');
                        _applyFilter();
                      },
                      child: const Text('Reset Filter'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 380,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                mainAxisExtent: 350,
              ),
              itemCount: _filteredDestinations.length,
              itemBuilder: (context, index) {
                final destination = _filteredDestinations[index];
                return DestinationCard(
                  item: destination,
                  onEdit: () => _openDestinationForm(existing: destination),
                  onView: () => _showDetailDialog(destination),
                  onDelete: () => _showDeleteConfirmDialog(destination),
                );
              },
            ),

            if (_lastPage > 1) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: AppTheme.cardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Halaman $_currentPage dari $_lastPage (Total $_totalDestinations destinasi)',
                      style: AppTheme.bodySM,
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: _currentPage > 1
                              ? () => _fetchInitialData(page: _currentPage - 1)
                              : null,
                          child: const Text('Sebelumnya'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _currentPage < _lastPage
                              ? () => _fetchInitialData(page: _currentPage + 1)
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

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;

  const _SmallStatCard({
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
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
