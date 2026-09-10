import 'package:flutter/material.dart';

/// TaskMate color palette — designed for modern, premium feel.
class AppColors {
  AppColors._();

  // ═══ DARK MODE ═══
  static const darkBackground = Color(0xFF0F0F23);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkCard = Color(0xFF16213E);
  static const darkCardAlt = Color(0xFF1E2A47);

  // ═══ LIGHT MODE ═══
  static const lightBackground = Color(0xFFF8F9FE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);

  // ═══ BRAND COLORS ═══
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF8B83FF);
  static const primaryDark = Color(0xFF5B52E0);
  static const secondary = Color(0xFF00D4AA);
  static const secondaryLight = Color(0xFF33DDBB);
  static const secondaryDark = Color(0xFF00B894);

  // ═══ SEMANTIC COLORS ═══
  static const error = Color(0xFFFF6B6B);
  static const errorLight = Color(0xFFFF8A8A);
  static const warning = Color(0xFFFFA726);
  static const warningLight = Color(0xFFFFBB55);
  static const success = Color(0xFF00E676);
  static const successLight = Color(0xFF33EB91);
  static const info = Color(0xFF29B6F6);

  // ═══ TEXT COLORS ═══
  static const textPrimaryDark = Color(0xFFF1F1F1);
  static const textSecondaryDark = Color(0xFF8E8E9A);
  static const textTertiaryDark = Color(0xFF5A5A6A);
  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B6B80);
  static const textTertiaryLight = Color(0xFF9E9EB0);

  // ═══ GRADIENT PRESETS ═══
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00E5C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const errorGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warningGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFFBB55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surfaceGradientDark = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
