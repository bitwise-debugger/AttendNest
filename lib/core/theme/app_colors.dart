import 'package:flutter/material.dart';

class AppColors {
  // Primary palette — deep indigo core
  static const Color primary = Color(0xFF6C3CE1);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4A1FB8);

  // Secondary palette — warm teal
  static const Color secondary = Color(0xFF0EA5A0);
  static const Color secondaryLight = Color(0xFF2DD4BF);

  // Accent — soft coral for highlights
  static const Color accent = Color(0xFFF472B6);
  static const Color accentLight = Color(0xFFFBCFE8);

  // Surfaces
  static const Color background = Color(0xFFF5F3FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDE9FE);
  static const Color cardBorder = Color(0xFFE5E1F5);

  // Dark accent for gradients
  static const Color darkAccent = Color(0xFF3B0FA5);

  // Text
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
