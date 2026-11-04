import 'package:flutter/material.dart';

class AppTheme {
  // === COLOR PALETTE ===
  static const Color primaryGreen = Color(0xFF198754);
  static const Color primaryGreenLight = Color(0xFFD1FAE5);
  static const Color primaryGreenSoft = Color(0xFFECFDF5);
  static const Color primaryGreenHover = Color(0xFF146C43);

  static const Color navyDark = Color(0xFF0D1B2A);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color bgContent = Color(0xFFF9FAFB);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSidebar = Color(0xFFFFFFFF);

  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  static const Color accentRed = Color(0xFFDC2626);
  static const Color accentRedLight = Color(0xFFFEE2E2);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberLight = Color(0xFFFEF3C7);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentBlueLight = Color(0xFFEFF6FF);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleLight = Color(0xFFF5F3FF);

  // === TEXT STYLES ===
  static const TextStyle titleXL = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLG = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMD = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodySM = TextStyle(
    fontSize: 13,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyXS = TextStyle(
    fontSize: 11,
    color: textMuted,
  );

  // === DECORATIONS ===
  static BoxDecoration cardDecoration = BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardDecorationElevated = BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

