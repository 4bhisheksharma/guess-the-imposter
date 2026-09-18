import 'package:flutter/material.dart';

/// App color palette matching the warm, minimal coffee/amber aesthetic from the design reference.
class AppColors {
  AppColors._();

  // Primary warm amber / tangerine orange accent
  static const Color primary = Color(0xFFF38318);
  static const Color primaryDark = Color(0xFFD66D0C);
  static const Color primaryLight = Color(0xFFFFA048);
  static const Color primarySoft = Color(0xFFFFF2E7);
  static const Color primarySoftDark = Color(0xFF332014);

  // Light Mode neutrals (Crisp off-white & clean porcelain)
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightElevated = Color(0xFFF0F2F5);
  static const Color borderLight = Color(0xFFE8EAEF);
  static const Color textPrimaryLight = Color(0xFF191A23);
  static const Color textSecondaryLight = Color(0xFF70737D);
  static const Color textMutedLight = Color(0xFFA0A4AF);

  // Dark Mode neutrals (Deep obsidian & espresso)
  static const Color backgroundDark = Color(0xFF111216);
  static const Color surfaceDark = Color(0xFF1A1B22);
  static const Color surfaceDarkElevated = Color(0xFF242630);
  static const Color borderDark = Color(0xFF2B2D3A);
  static const Color textPrimaryDark = Color(0xFFF7F8FA);
  static const Color textSecondaryDark = Color(0xFF9FA2B2);
  static const Color textMutedDark = Color(0xFF646778);

  // Status & Role colors
  static const Color imposter = Color(0xFFE84118);
  static const Color civilian = Color(0xFF27AE60);
  static const Color hint = Color(0xFFF39C12);

  // Legacy mappings for backwards compatibility
  static const Color secondary = Color(0xFFFF7675);
  static const Color accent = Color(0xFFF38318);
  static const Color border = borderDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color surfaceElevated = surfaceDarkElevated;
}
