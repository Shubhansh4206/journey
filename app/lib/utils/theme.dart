import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusPill = 32;

  // ── Shared Card Decoration ────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ── Shared Soft Input Decoration ──────────────────────────────────────────
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.softGrey,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.mediumGrey,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryDarkBlue, width: 1.5),
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDarkBlue,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.nearBlack,
        displayColor: AppColors.nearBlack,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.nearBlack),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.nearBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkBlue,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDarkBlue,
          side: const BorderSide(color: AppColors.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

