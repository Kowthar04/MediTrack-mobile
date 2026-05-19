import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF9FAFC);
  static const border = Color(0xFFE7EBF3);
  static const borderSubtle = Color(0xFFF0F3F9);

  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const textSubtle = Color(0xFF94A3B8);

  static const primary = Color(0xFF3B5FE0);
  static const primaryHover = Color(0xFF2D4EE8);
  static const primaryLight = Color(0xFFEEF2FF);
  static const primaryBright = Color(0xFF6E8AFF);

  static const success = Color(0xFF22C55E);
  static const successBg = Color(0xFFECFDF5);
  static const successText = Color(0xFF047857);

  static const warning = Color(0xFFEAB308);
  static const warningBg = Color(0xFFFEF9C3);
  static const warningText = Color(0xFF854D0E);

  static const danger = Color(0xFFEF4444);
  static const dangerBg = Color(0xFFFEF2F2);
  static const dangerText = Color(0xFFB91C1C);

  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 22.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
  );
}