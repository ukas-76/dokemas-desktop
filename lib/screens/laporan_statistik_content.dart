import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Halaman Laporan & Statistik — menampilkan agregasi riil dan ekspor CSV
class LaporanStatistikContent extends StatefulWidget {
  const LaporanStatistikContent({super.key});

  @override
  State<LaporanStatistikContent> createState() => _LaporanStatistikContentState();
}

class _LaporanStatistikContentState extends State<LaporanStatistikContent> {
  final ApiService _apiService = ApiService();

  DashboardDataBundle? _bundle;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bundle = await _apiService.getDashboardBundle();
      if (!mounted) return;
      setState(() {
        _bundle = bundle;
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

  Future<void> _exportCsv() async {
    if (_bundle == null) return;
    setState(() => _isExporting = true);

    try {
      final buffer = StringBuffer();
      buffer.writeln('ID,Nama Destinasi,Kategori,Harga Tiket,Jam Buka,Rating,Populer,Alamat');
      for (final d in _bundle!.destinations) {
        final safeName = '"${d.name.replaceAll('"', '""')}"';
        final safeCat = '"${(d.category?.name ?? '-').replaceAll('"', '""')}"';
        final safeAddr = '"${d.address.replaceAll('"', '""')}"';
        buffer.writeln(
          '${d.id},$safeName,$safeCat,${d.price},"${d.openingHours}",${d.ratingAvg},${d.isPopular ? "Ya" : "Tidak"},$safeAddr',
        );
      }

      final String? userProfile = Platform.environment['USERPROFILE'];
      final Directory targetDir = userProfile != null && Directory('$userProfile\\Downloads').existsSync()
          ? Directory('$userProfile\\Downloads')
          : Directory.current;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${targetDir.path}${Platform.pathSeparator}laporan_dokemas_$timestamp.csv');
      await file.writeAsString(buffer.toString());

      if (!mounted) return;
      setState(() => _isExporting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan CSV berhasil disimpan ke: ${file.path}'),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor laporan: $e'),
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
            Text('Menyusun laporan & statistik riil...', style: AppTheme.bodySM),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.accentRedLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 38, color: AppTheme.accentRed),
              const SizedBox(height: 10),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton(onPressed: _loadReport, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final bundle = _bundle!;
    final destinations = bundle.destinations;
    final categories = bundle.categories;

    final int avgPrice = destinations.isEmpty
        ? 0
        : (destinations.map((d) => d.price).reduce((a, b) => a + b) / destinations.length).round();

    final int maxCatCount = categories.isEmpty
        ? 1
        : categories.map((c) => c.destinationsCount).reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Ekspor Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laporan & Statistik Ekosistem', style: AppTheme.titleLG),
                  SizedBox(height: 4),
                  Text(
                    'Ringkasan data pariwisata, distribusi kategori, dan ekspor laporan DOKEMAS Banyumas.',
                    style: AppTheme.bodySM,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _loadReport,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Muat Ulang Data',
                    color: AppTheme.primaryGreen,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreenSoft,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportCsv,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'Ekspor Laporan CSV',
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
            ],
          ),

          const SizedBox(height: 22),

          // 4 Summary Cards
          Row(
            children: [
              Expanded(
                child: _ReportMetricCard(
                  label: 'TOTAL DESTINASI',
                  value: '${bundle.totalDestinations}',
                  sub: '${bundle.popularDestinations} destinasi unggulan',
                  icon: Icons.landscape_rounded,
                  color: AppTheme.primaryGreen,
                  bg: AppTheme.primaryGreenSoft,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ReportMetricCard(
                  label: 'RATA-RATA TIKET',
                  value: avgPrice <= 0 ? 'Gratis' : 'Rp $avgPrice',
                  sub: 'Dari ${destinations.length} sampel destinasi',
                  icon: Icons.payments_outlined,
                  color: AppTheme.accentBlue,
                  bg: AppTheme.accentBlueLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ReportMetricCard(
                  label: 'USER & MITRA',
                  value: '${bundle.totalUsers}',
                  sub: '${bundle.totalMitra} akun mitra terdaftar',
                  icon: Icons.groups_rounded,
                  color: AppTheme.accentPurple,
                  bg: AppTheme.accentPurpleLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ReportMetricCard(
                  label: 'ULASAN & RATING',
                  value: '${bundle.totalReviews}',
                  sub: bundle.averageRating > 0
                      ? 'Rata-rata ${bundle.averageRating.toStringAsFixed(1)}★'
                      : 'Belum ada rating',
                  icon: Icons.star_rounded,
                  color: AppTheme.accentAmber,
                  bg: AppTheme.accentAmberLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2 Columns: Category Breakdown & Destination Table
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Distribusi Kategori
              Expanded(
                flex: 40,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Distribusi per Kategori', style: AppTheme.titleMD),
                      const SizedBox(height: 4),
                      const Text('Jumlah destinasi aktif di setiap kategori wisata', style: AppTheme.bodyXS),
                      const SizedBox(height: 18),
                      ...categories.map((cat) {
                        final ratio = (cat.destinationsCount / maxCatCount).clamp(0.0, 1.0);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text(
                                    '${cat.destinationsCount} tempat',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                  backgroundColor: AppTheme.bgContent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Ringkasan Tabel Destinasi
              Expanded(
                flex: 60,
                child: Container(
                  decoration: AppTheme.cardDecoration,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rekap Data Destinasi Aktif', style: AppTheme.titleMD),
                            SizedBox(height: 4),
                            Text('Data riil destinasi wisata & kuliner Kabupaten Banyumas', style: AppTheme.bodyXS),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppTheme.borderColor),
                      Container(
                        color: AppTheme.bgContent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text('NAMA TEMPAT', style: _hdrStyle)),
                            Expanded(flex: 2, child: Text('KATEGORI', style: _hdrStyle)),
                            Expanded(flex: 2, child: Text('TARIF', style: _hdrStyle)),
                            Expanded(flex: 1, child: Text('POPULER', style: _hdrStyle)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppTheme.borderColor),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: destinations.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.borderColor),
                        itemBuilder: (context, index) {
                          final d = destinations[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    d.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(d.category?.name ?? '-', style: AppTheme.bodySM),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    d.formattedPrice,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    d.isPopular ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: 18,
                                    color: d.isPopular ? AppTheme.accentAmber : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const TextStyle _hdrStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: AppTheme.textSecondary,
  letterSpacing: 0.6,
);

class _ReportMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final Color bg;

  const _ReportMetricCard({
    required this.label,
    required this.value,
    required this.sub,
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
                Text(label, style: AppTheme.bodyXS.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(sub, style: AppTheme.bodyXS, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

