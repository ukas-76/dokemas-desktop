import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════
//  VISITOR CHART — custom-painted sparkline/area chart
// ═══════════════════════════════════════════════════════════
class VisitorChartSection extends StatefulWidget {
  const VisitorChartSection({super.key});

  @override
  State<VisitorChartSection> createState() => _VisitorChartSectionState();
}

class _VisitorChartSectionState extends State<VisitorChartSection> {
  String _selectedRange = '30 Hari Terakhir';

  static const List<String> _ranges = [
    '7 Hari Terakhir',
    '30 Hari Terakhir',
    '3 Bulan',
  ];

  // Simulated data points (normalized 0.0–1.0)
  static const List<double> _dataPoints = [
    0.30, 0.38, 0.35, 0.42, 0.40, 0.48, 0.52,
    0.49, 0.55, 0.58, 0.54, 0.60, 0.62, 0.59,
    0.65, 0.68, 0.64, 0.70, 0.72, 0.68, 0.75,
    0.80, 0.77, 0.90, 1.00, 0.95, 0.88, 0.82, 0.75, 0.70,
  ];

  static const List<String> _xLabels = [
    '01 Mei', '05 Mei', '10 Mei', '15 Mei',
    '20 Mei', '24 Mei (Puncak)', '30 Mei',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecorationElevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ANALISIS KUNJUNGAN WISATAWAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Statistik Pengunjung &\nReservasi Bulan Ini',
                      style: AppTheme.titleLG,
                    ),
                  ],
                ),
              ),
              // Total badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      '48,920 (+18.4%)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Range selector
              _RangeDropdown(
                value: _selectedRange,
                items: _ranges,
                onChanged: (val) => setState(() => _selectedRange = val!),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Chart ──
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _AreaChartPainter(
                dataPoints: _dataPoints,
                lineColor: AppTheme.primaryGreen,
                fillColor: AppTheme.primaryGreen.withOpacity(0.12),
                gridColor: AppTheme.borderColor,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          const SizedBox(height: 8),

          // ── X-axis labels ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _xLabels.map((label) {
              final bool isPeak = label.contains('Puncak');
              return Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isPeak ? FontWeight.w700 : FontWeight.normal,
                  color: isPeak
                      ? AppTheme.primaryGreen
                      : AppTheme.textMuted,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 20),

          // ── Bottom stat row ──
          Row(
            children: [
              _MiniStat(
                icon: Icons.trending_up_rounded,
                label: 'Rata-rata Harian',
                value: '1,630 Wisatawan',
                iconColor: AppTheme.textSecondary,
                iconBg: AppTheme.bgContent,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon: Icons.star_rounded,
                label: 'Kunjungan Tertinggi',
                value: '3,420 (Sabtu, 24 Mei)',
                iconColor: AppTheme.primaryGreen,
                iconBg: AppTheme.primaryGreenSoft,
                highlighted: true,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon: Icons.percent_rounded,
                label: 'Tingkat Okupansi',
                value: '84% Kapasitas',
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

// ── Custom dropdown for range ──
class _RangeDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _RangeDropdown({
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
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: AppTheme.textSecondary),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Mini stat card inside chart ──
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlighted ? AppTheme.primaryGreenSoft : AppTheme.bgContent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlighted
                ? AppTheme.primaryGreenLight
                : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
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

// ═══════════════════════════════════════════════════════════
//  CUSTOM AREA CHART PAINTER
// ═══════════════════════════════════════════════════════════
class _AreaChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _AreaChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Draw horizontal grid lines (5 lines)
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (dataPoints.isEmpty) return;

    final int n = dataPoints.length;
    final double stepX = size.width / (n - 1);

    // Convert data to canvas points (y is inverted)
    List<Offset> points = List.generate(n, (i) {
      return Offset(
        i * stepX,
        size.height - (dataPoints[i] * size.height * 0.85) - size.height * 0.05,
      );
    });

    // Build smooth path using cubic bezier
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < n - 1; i++) {
      final cp1 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i].dy,
      );
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );
      linePath.cubicTo(
        cp1.dx, cp1.dy,
        cp2.dx, cp2.dy,
        points[i + 1].dx, points[i + 1].dy,
      );
    }

    // Fill area
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = fillColor,
    );

    // Draw line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Find peak point (index 23 — 24 Mei)
    final peakIndex = dataPoints.indexWhere((v) => v == 1.0);
    if (peakIndex >= 0) {
      final peakPoint = points[peakIndex];
      // Draw peak dot
      canvas.drawCircle(
        peakPoint,
        6,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        peakPoint,
        4,
        Paint()..color = Colors.white,
      );

      // Peak tooltip box
      const tooltipText = 'Puncak: 3,420';
      final textPainter = TextPainter(
        text: TextSpan(
          text: tooltipText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final boxPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
      final boxW = textPainter.width + boxPadding.horizontal;
      final boxH = textPainter.height + boxPadding.vertical;
      final boxLeft = math.min(peakPoint.dx - boxW / 2, size.width - boxW);
      final boxTop = peakPoint.dy - boxH - 10;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(boxLeft, boxTop, boxW, boxH),
        const Radius.circular(6),
      );

      canvas.drawRRect(
        rrect,
        Paint()..color = const Color(0xFF0D1B2A),
      );

      textPainter.paint(
        canvas,
        Offset(boxLeft + boxPadding.left, boxTop + boxPadding.top),
      );
    }
  }

  @override
  bool shouldRepaint(_AreaChartPainter old) => false;
}

