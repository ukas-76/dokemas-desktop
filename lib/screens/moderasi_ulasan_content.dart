import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Halaman Moderasi Ulasan — terhubung dengan GET /api/admin/reviews & DELETE /api/admin/reviews/{id}
class ModerasiUlasanContent extends StatefulWidget {
  const ModerasiUlasanContent({super.key});

  @override
  State<ModerasiUlasanContent> createState() => _ModerasiUlasanContentState();
}

class _ModerasiUlasanContentState extends State<ModerasiUlasanContent> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ReviewModel> _allReviews = [];
  List<ReviewModel> _filteredReviews = [];
  final Set<int> _approvedIds = {};

  int _activeFilterIndex = 0; // 0 = Semua / Perlu Tinjau, 1 = Disetujui Lokal, 2 = Rating Rendah
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalReviews = 0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getReviews(
        page: page,
        search: _searchController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _allReviews = res.reviews;
        _currentPage = res.currentPage;
        _lastPage = res.lastPage;
        _totalReviews = res.total;
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
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredReviews = _allReviews.where((r) {
        final bool matchesTab;
        if (_activeFilterIndex == 1) {
          matchesTab = _approvedIds.contains(r.id) || r.rating >= 4.0;
        } else if (_activeFilterIndex == 2) {
          matchesTab = r.isLowRating || (r.reportReason != null && r.reportReason!.isNotEmpty);
        } else {
          matchesTab = !_approvedIds.contains(r.id);
        }

        final bool matchesQuery = query.isEmpty ||
            r.userName.toLowerCase().contains(query) ||
            r.destinationName.toLowerCase().contains(query) ||
            r.comment.toLowerCase().contains(query);

        return matchesTab && matchesQuery;
      }).toList();
    });
  }

  void _ignoreOrApprove(ReviewModel review) {
    setState(() {
      _approvedIds.add(review.id);
      _applyFilter();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ulasan dari ${review.userName} ditandai aman.'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _confirmDeleteReview(ReviewModel review) {
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
                    child: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentRed),
                  ),
                  const SizedBox(width: 12),
                  const Text('Hapus Ulasan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  'Yakin ingin menghapus ulasan dari "${review.userName}" untuk "${review.destinationName}" secara permanen dari server?',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setModalState(() => isDeleting = true);
                          try {
                            await _apiService.deleteReview(review.id);
                            if (!dialogCtx.mounted) return;
                            Navigator.of(dialogCtx).pop();

                            await _fetchReviews(page: _currentPage);
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Ulasan berhasil dihapus dari server.'),
                                backgroundColor: AppTheme.accentRed,
                              ),
                            );
                          } catch (e) {
                            if (!dialogCtx.mounted) return;
                            Navigator.of(dialogCtx).pop();
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus ulasan: $e'),
                                backgroundColor: AppTheme.accentRed,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Ya, Hapus'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int pendingCount = _allReviews.where((r) => !_approvedIds.contains(r.id)).length;
    final int positiveCount = _allReviews.where((r) => r.rating >= 4.0 || _approvedIds.contains(r.id)).length;
    final int lowRatingCount = _allReviews.where((r) => r.isLowRating || (r.reportReason?.isNotEmpty == true)).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Top Status Filters (3 Kartu Filter Status) ──
          Row(
            children: [
              Expanded(
                child: _FilterStatusCard(
                  title: 'PERLU DITINJAU',
                  count: _isLoading ? '...' : '$pendingCount Ulasan',
                  subtitle: 'Total seluruh ulasan masuk: $_totalReviews',
                  icon: Icons.pending_actions_rounded,
                  color: AppTheme.accentAmber,
                  bg: AppTheme.accentAmberLight,
                  isSelected: _activeFilterIndex == 0,
                  onTap: () {
                    _activeFilterIndex = 0;
                    _applyFilter();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FilterStatusCard(
                  title: 'ULASAN POSITIF / AMAN',
                  count: _isLoading ? '...' : '$positiveCount Ulasan',
                  subtitle: 'Rating ≥ 4★ atau telah disetujui',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTheme.primaryGreen,
                  bg: AppTheme.primaryGreenSoft,
                  isSelected: _activeFilterIndex == 1,
                  onTap: () {
                    _activeFilterIndex = 1;
                    _applyFilter();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FilterStatusCard(
                  title: 'RATING RENDAH / DILAPORKAN',
                  count: _isLoading ? '...' : '$lowRatingCount Ulasan',
                  subtitle: 'Perlu perhatian moderasi (≤ 3★)',
                  icon: Icons.report_problem_outlined,
                  color: AppTheme.accentRed,
                  bg: AppTheme.accentRedLight,
                  isSelected: _activeFilterIndex == 2,
                  onTap: () {
                    _activeFilterIndex = 2;
                    _applyFilter();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Search & Refresh Bar ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.bgContent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilter(),
                      decoration: const InputDecoration(
                        hintText: 'Cari ulasan berdasarkan pengulas, destinasi, atau isi komentar...',
                        hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppTheme.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _fetchReviews(page: _currentPage),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Ulasan Wisatawan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Menampilkan ${_filteredReviews.length} ulasan',
                style: AppTheme.bodySM,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 2. Konten: Loading / Error / Empty / List ──
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 14),
                    Text('Memuat daftar ulasan dari backend...', style: AppTheme.bodySM),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentRedLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 36, color: AppTheme.accentRed),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _fetchReviews(page: _currentPage),
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                      label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredReviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: AppTheme.cardDecoration,
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 44, color: AppTheme.textMuted),
                    SizedBox(height: 10),
                    Text(
                      'Tidak ada ulasan pada kategori ini.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Belum ada ulasan wisatawan yang perlu ditinjau di server.',
                      style: AppTheme.bodySM,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredReviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = _filteredReviews[index];
                return _ReportedReviewCard(
                  review: review,
                  onIgnore: () => _ignoreOrApprove(review),
                  onDelete: () => _confirmDeleteReview(review),
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
                    Text('Halaman $_currentPage dari $_lastPage', style: AppTheme.bodySM),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: _currentPage > 1
                              ? () => _fetchReviews(page: _currentPage - 1)
                              : null,
                          child: const Text('Sebelumnya'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _currentPage < _lastPage
                              ? () => _fetchReviews(page: _currentPage + 1)
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

class _FilterStatusCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterStatusCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryGreen.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyXS.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodyXS, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportedReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onIgnore;
  final VoidCallback onDelete;

  const _ReportedReviewCard({
    required this.review,
    required this.onIgnore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String badgeText = (review.reportReason != null && review.reportReason!.isNotEmpty)
        ? 'Alasan: ${review.reportReason}'
        : review.isLowRating
            ? 'Perhatian: Rating Rendah (${review.rating.toStringAsFixed(1)}★)'
            : 'Ulasan Pengunjung • ID #${review.id}';

    final bool isAlert = (review.reportReason != null && review.reportReason!.isNotEmpty) || review.isLowRating;

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAlert ? AppTheme.accentRedLight : AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (isAlert ? AppTheme.accentRed : AppTheme.primaryGreen).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAlert ? Icons.report_problem_outlined : Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: isAlert ? AppTheme.accentRed : AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isAlert ? AppTheme.accentRed : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Text(review.formattedDate, style: AppTheme.bodyXS),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryGreenSoft,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Destinasi: ${review.destinationName}',
                            style: AppTheme.bodyXS.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: AppTheme.accentAmber,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgContent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              review.comment.isNotEmpty ? '"${review.comment}"' : '(Tidak ada teks komentar)',
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppTheme.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onIgnore,
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: const Text('Abaikan Laporan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.borderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.white),
                label: const Text('Hapus Ulasan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
