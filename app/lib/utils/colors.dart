import 'package:flutter/material.dart';

/// ── Theme Color Palette ──────────────────────────────────────────────────
/// Restrained luxury palette: White, Dark Blue (#0A2647), Grey, and Black
class AppColors {
  AppColors._();

  // ── Primary Brand Tokens ───────────────────────────────────────────────────
  static const Color primaryDarkBlue = Color(0xFF0A2647); // Deep Navy Hero CTA
  static const Color primary = primaryDarkBlue;
  static const Color primaryDark = Color(0xFF06172D);
  static const Color primaryLight = Color(0xFFE8EEF5);
  static const Color primaryMuted = Color(0x1F0A2647); // 12% opacity

  // ── Backgrounds & Surfaces ─────────────────────────────────────────────────
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color background = pureWhite;
  static const Color softGrey = Color(0xFFF5F6F8);
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color surface = pureWhite;
  static const Color inputFill = Color(0xFFF5F6F8);

  // ── Text & Typography ──────────────────────────────────────────────────────
  static const Color nearBlack = Color(0xFF1A1A1A);
  static const Color textPrimary = nearBlack;
  static const Color mediumGrey = Color(0xFF64748B);
  static const Color textSecondary = mediumGrey;
  static const Color textMuted = Color(0xFF9AA0A6);

  // ── Borders & Dividers ─────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = primaryDarkBlue;

  // ── Semantic / Functional Status Colors (Preserved for meaning) ─────────────
  static const Color googleButton = Color(0xFFFBC02D);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // ── Legacy aliases mapped to harmonious tokens ─────────────────────────────
  static const Color offWhite = softGrey;
  static const Color darkCharcoal = nearBlack;
  static const Color electricBlue = primaryDarkBlue;
  static const Color vibrantPurple = primaryDarkBlue;
  static const Color punchPink = Color(0xFFE11D48);
  static const Color electricYellow = Color(0xFFF59E0B);
}
