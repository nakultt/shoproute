import 'package:flutter/material.dart';

/// ShopRoute App Colors
/// Professional, modern color palette for trust and reliability
class AppColors {
  AppColors._();

  // Primary Colors - Blue (Trust, Reliability)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primarySurface = Color(0xFFDBEAFE);

  // Accent Colors - Emerald (Success, Savings)
  static const Color accent = Color(0xFF10B981);
  static const Color accentDark = Color(0xFF059669);
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentSurface = Color(0xFFD1FAE5);

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceElevatedDark = Color(0xFF374151);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF1F2937);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceLight, backgroundLight],
  );

  // Category Colors
  static const Color categoryHotDeals = Color(0xFFEF4444);
  static const Color categorySeasonal = Color(0xFF8B5CF6);
  static const Color categoryTrending = Color(0xFFF59E0B);
  static const Color categoryPersonalized = Color(0xFF06B6D4);
  static const Color categoryTopRated = Color(0xFFEAB308);
  static const Color categoryGroceries = Color(0xFF22C55E);
  static const Color categoryBakery = Color(0xFFF97316);
  static const Color categoryMeat = Color(0xFFDC2626);
  static const Color categoryBeverages = Color(0xFF0EA5E9);
  static const Color categoryPersonalCare = Color(0xFFEC4899);
  static const Color categoryHousehold = Color(0xFF8B5CF6);
}
