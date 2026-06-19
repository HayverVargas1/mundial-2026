// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF050B1A);
  static const Color surface = Color(0xFF0D1630);
  static const Color surfaceVariant = Color(0xFF111D38);
  static const Color surfaceBright = Color(0xFF162040);

  // Brand
  static const Color primary = Color(0xFFE8C56B);
  static const Color primaryDark = Color(0xFFD4A94A);
  static const Color secondary = Color(0xFF39E6D4);
  static const Color secondaryDark = Color(0xFF22C9B7);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Borders
  static const Color border = Color(0xFF1E2A4A);
  static const Color borderLight = Color(0xFF2A3A5C);

  // Status
  static const Color live = Color(0xFFEF4444);
  static const Color liveGlow = Color(0x40EF4444);
  static const Color finished = Color(0xFF6B7280);
  static const Color upcoming = Color(0xFF39E6D4);

  // Groups (for bracket/group coloring)
  static const Color groupA = Color(0xFF6366F1);
  static const Color groupB = Color(0xFF8B5CF6);
  static const Color groupC = Color(0xFFEC4899);
  static const Color win = Color(0xFF22C55E);
  static const Color draw = Color(0xFFF59E0B);
  static const Color loss = Color(0xFFEF4444);

  // Gradient
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1E45), Color(0xFF050B1A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111D38), Color(0xFF0A1628)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE8C56B), Color(0xFFD4A94A)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF39E6D4), Color(0xFF22C9B7)],
  );
}
