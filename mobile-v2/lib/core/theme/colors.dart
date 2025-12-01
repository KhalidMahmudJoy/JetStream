import 'package:flutter/material.dart';

/// JetStream Color System
/// Minimalistic Dark Theme with 4 Carefully Curated Colors
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Background - Deep Space Black (Adjusted to Pure Black for "Green & Black" theme)
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF121212);
  static const Color backgroundTertiary = Color(0xFF1E1E1E);

  // Accent Color - Spotify Green (Promoted to Primary)
  static const Color accentPrimary = Color(0xFF1ED760);
  static const Color accentLight = Color(0xFF1FDF64);
  static const Color accentDark = Color(0xFF1DB954);
  static const Color accentGlow = Color(0x331ED760);

  // Secondary Accent - Electric Blue (Demoted to Secondary)
  static const Color secondaryPrimary = Color(0xFF00D9FF);
  static const Color secondaryLight = Color(0xFF33E3FF);
  static const Color secondaryDark = Color(0xFF00A3CC);
  static const Color secondaryGlow = Color(0x2600D9FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A9C0);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textInverse = Color(0xFF0A0E27);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = accentPrimary;

  // Border Colors
  static const Color borderDefault = Color(0xFF1C2541);
  static const Color borderFocus = accentPrimary;
  static const Color borderSubtle = Color(0xFF141B34);

  // Overlay and Shadow
  static const Color overlay = Color(0xCC0A0E27); // 80% opacity
  static const Color shadow = Color(0x80000000); // 50% opacity

  // Standard Colors
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPrimary, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryPrimary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundPrimary, backgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
