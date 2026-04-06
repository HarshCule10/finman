import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const accent = Color(0xFF00E5A0);
  static const accentDark = Color(0xFF00C48C);
  static const secondary = Color(0xFF7B61FF);

  // Dark theme - Updated to match spec requirements
  static const darkBg = Color(0xFF171717);
  static const darkSurface = Color(0xFF262626);
  static const darkCard = Color(0xFF262626);
  static const darkBorder = Color(0xFF2A2A3E);

  // Light theme
  static const lightBg = Color(0xFFF5F5F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE5E5EA);

  // Text - Updated to match spec requirements
  static const textWhite = Color(0xFFFAFAFA);
  static const textGrey = Color(0xFFA0A0A0);
  static const textDark = Color(0xFF1C1C1E);

  // Semantic
  static const income = Color(0xFF00E5A0);
  static const expense = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFD60A);

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D09C), Color(0xFF7B61FF)],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00E5A0), Color(0xFF00C48C)],
  );

  static const darkSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );
}
