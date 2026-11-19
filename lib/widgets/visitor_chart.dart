import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/category_model.dart';
import '../models/dashboard_model.dart';
import '../theme/app_theme.dart';

/// Bagian Grafik Statistik & Sebaran Kategori Destinasi (Berbasis Data Riil)
class VisitorChartSection extends StatefulWidget {
  final DashboardDataBundle? data;
  final bool isLoading;

  const VisitorChartSection({
    super.key,
    this.data,
    this.isLoading = false,
  });

  @override
  State<VisitorChartSection> createState() => _VisitorChartSectionState();
}

class _VisitorChartSectionState extends State<VisitorChartSection> {
  String _selectedMode = 'Sebaran Kategori';

  static const List<String> _modes = [
    'Sebaran Kategori',
    'Harga Tiket Destinasi',
  ];

  @override
  Widget build(BuildContext context) {
    final categories = widget.data?.categories ?? <CategoryModel>[];
    final destinations = widget.data?.destinations ?? [];

    // Hitung nilai bar untuk mode terpilih
    final List<_ChartPoint> points;
    if (_selectedMode == 'Harga Tiket Destinasi') {
      points = destinations.take(7).map((d) {
        return _ChartPoint(
          label: d.name.length > 12 ? '${d.name.substring(0, 12)}…' : d.name,
          value: d.price.toDouble(),
          displayValue: d.price <= 0 ? 'Gratis' : 'Rp ${d.price}',
        );
      }).toList();
    } else {
      points = categories.map((c) {
        return _ChartPoint(
          label: c.name,
          value: c.destinationsCount.toDouble(),
          displayValue: '${c.destinationsCount} Tempat',
        );
      }).toList();
    }

    final double maxValue = points.isEmpty
        ? 1.0
        : math.max(1.0, points.map((e) => e.value).reduce(math.max));

    final _ChartPoint? topPoint = points.isEmpty
        ? null
        : points.reduce((a, b) => a.value >= b.value ? a : b);

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
                      'ANALITIK EKOSISTEM WISATA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Statistik Destinasi &\nDistribusi Kategori Riil',
                      style: AppTheme.titleLG,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.data?.totalDestinations ?? 0} Destinasi Aktif',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ModeDropdown(
                value: _selectedMode,
                items: _modes,
                onChanged: (val) => setState(() => _selectedMode = val!),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 205,
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : points.isEmpty
                    ? const Center(
                        child: Text('Belum ada data statistik dari server.', style: AppTheme.bodySM),
                      )
                    : CustomPaint(
                        painter: _BarLineChartPainter(
                          points: points,
                          maxValue: maxValue,
                          primaryColor: AppTheme.primaryGreen,
                          softColor: AppTheme.primaryGreenSoft,
                          gridColor: AppTheme.borderColor,
                        ),
                        child: const SizedBox.expand(),
                      ),
          ),

          const SizedBox(height: 10),

          if (points.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: points.map((p) {
                final isTop = topPoint != null && p.label == topPoint.label && p.value > 0;
                return Expanded(
                  child: Text(
                    p.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isTop ? FontWeight.w700 : FontWeight.normal,
                      color: isTop ? AppTheme.primaryGreen : AppTheme.textMuted,
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 20),

          Row(
            children: [
              _MiniStat(
                icon: Icons.place_rounded,
                label: 'Destinasi Populer',
                value: '${widget.data?.popularDestinations ?? 0} Tempat Unggulan',
                iconColor: AppTheme.textSecondary,
                iconBg: AppTheme.bgContent,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon: Icons.star_rounded,
                label: _selectedMode == 'Harga Tiket Destinasi' ? 'Tarif Tertinggi' : 'Kategori Terbanyak',
                value: topPoint != null ? '${topPoint.label} (${topPoint.displayValue})' : '-',
                iconColor: AppTheme.primaryGreen,
                iconBg: AppTheme.primaryGreenSoft,
                highlighted: true,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon: Icons.storefront_rounded,
                label: 'Fasilitas Tercatat',
                value: '${widget.data?.totalFacilities ?? 0} Jenis Fasilitas',
                iconColor: AppTheme.textSecondary,
                iconBg: AppTheme.bgContent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPoint {
  final String label;
  final double value;
  final String displayValue;

  const _ChartPoint({
    required this.label,
    required this.value,
    required this.displayValue,
  });
}

class _ModeDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ModeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bgContent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.textSecondary),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;
  final bool highlighted;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlighted ? AppTheme.primaryGreenSoft : AppTheme.bgContent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlighted ? AppTheme.primaryGreenLight : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.bodyXS),
                  const SizedBox(height: 2),
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
        ),
      ),
    );
  }
}

class _BarLineChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  final double maxValue;
  final Color primaryColor;
  final Color softColor;
  final Color gridColor;

  _BarLineChartPainter({
    required this.points,
    required this.maxValue,
    required this.primaryColor,
    required this.softColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) return;

    final int n = points.length;
    final double slotWidth = size.width / n;
    final double barWidth = math.min(42.0, slotWidth * 0.48);

    final List<Offset> centers = [];

    for (int i = 0; i < n; i++) {
      final ratio = maxValue > 0 ? (points[i].value / maxValue).clamp(0.0, 1.0) : 0.0;
      final barHeight = math.max(6.0, ratio * (size.height * 0.78));
      final left = i * slotWidth + (slotWidth - barWidth) / 2;
      final top = size.height - barHeight;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      canvas.drawRRect(rrect, Paint()..color = softColor);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, top, barWidth, math.min(6.0, barHeight)),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        Paint()..color = primaryColor,
      );

      centers.add(Offset(left + barWidth / 2, top));

      // Label angka di atas bar
      final tp = TextPainter(
        text: TextSpan(
          text: points[i].value.toInt().toString(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(left + (barWidth - tp.width) / 2, math.max(0, top - 16)));
    }

    if (centers.length > 1) {
      final linePath = Path()..moveTo(centers[0].dx, centers[0].dy);
      for (int i = 0; i < centers.length - 1; i++) {
        final midX = (centers[i].dx + centers[i + 1].dx) / 2;
        linePath.cubicTo(midX, centers[i].dy, midX, centers[i + 1].dy, centers[i + 1].dx, centers[i + 1].dy);
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = primaryColor
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarLineChartPainter oldDelegate) => true;
}
