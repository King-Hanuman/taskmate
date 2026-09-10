import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TaskMate typography using Poppins from Google Fonts.
class AppTypography {
  AppTypography._();

  static TextStyle get _basePoppins => GoogleFonts.poppins();

  // ═══ HEADINGS ═══
  static TextStyle h1([Color? color]) => _basePoppins.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
        letterSpacing: -0.5,
      );

  static TextStyle h2([Color? color]) => _basePoppins.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle h3([Color? color]) => _basePoppins.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle h4([Color? color]) => _basePoppins.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  // ═══ BODY TEXT ═══
  static TextStyle bodyLarge([Color? color]) => _basePoppins.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium([Color? color]) => _basePoppins.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall([Color? color]) => _basePoppins.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // ═══ LABELS & BUTTONS ═══
  static TextStyle labelLarge([Color? color]) => _basePoppins.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle labelMedium([Color? color]) => _basePoppins.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle labelSmall([Color? color]) => _basePoppins.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.2,
        letterSpacing: 0.5,
      );

  // ═══ CAPTION ═══
  static TextStyle caption([Color? color]) => _basePoppins.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
        letterSpacing: 0.3,
      );

  // ═══ SPECIAL ═══
  static TextStyle number([Color? color]) => _basePoppins.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.1,
      );

  static TextStyle numberSmall([Color? color]) => _basePoppins.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.1,
      );
}
