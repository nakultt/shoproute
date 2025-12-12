import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ShopRoute Typography System
/// Uses Inter for body text and Poppins for headings
class AppTextStyles {
  AppTextStyles._();

  // Font Families
  static String get _headingFontFamily => 'Poppins';
  static String get _bodyFontFamily => 'Inter';

  // Heading Styles (Poppins)
  static TextStyle
  displayLarge({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  displayMedium({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  displaySmall({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  headlineLarge({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  headlineMedium({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  headlineSmall({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  // Title Styles (Poppins Medium)
  static TextStyle
  titleLarge({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  titleMedium({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  titleSmall({
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  // Body Styles (Inter)
  static TextStyle
  bodyLarge({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  bodyMedium({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  bodySmall({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color:
        color ??
        AppColors.textSecondaryLight,
  );

  // Label Styles (Inter Medium)
  static TextStyle
  labelLarge({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  labelMedium({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color:
        color ??
        AppColors.textPrimaryLight,
  );

  static TextStyle
  labelSmall({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color:
        color ??
        AppColors.textSecondaryLight,
  );

  // Button Styles
  static TextStyle
  buttonLarge({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color:
        color ??
        Colors.white,
  );

  static TextStyle
  buttonMedium({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color:
        color ??
        Colors.white,
  );

  static TextStyle
  buttonSmall({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color:
        color ??
        Colors.white,
  );

  // Special Styles
  static TextStyle
  price({
    Color? color,
    double? fontSize,
  }) => GoogleFonts.inter(
    fontSize:
        fontSize ??
        18,
    fontWeight: FontWeight.w700,
    color:
        color ??
        AppColors.primary,
  );

  static TextStyle
  priceStrikethrough({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
    color:
        color ??
        AppColors.textTertiaryLight,
  );

  static TextStyle
  badge({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color:
        color ??
        Colors.white,
  );

  static TextStyle
  chip({
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color:
        color ??
        AppColors.textSecondaryLight,
  );
}
