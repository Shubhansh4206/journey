import 'package:flutter/material.dart';

/// ── Theme Color Palette ──────────────────────────────────────────────────
/// Indigo Accent & Clean Light / Modern UI matching user specifications.
class AppColors {
  AppColors._();

  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary = Colors.indigoAccent;
  static const Color primaryDark = Color(0xFF3F51B5);
  static const Color primaryLight = Color(0xFFE0E7FF);
  static const Color primaryMuted = Color(0x1F536DFE); // 12% opacity

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color inputFill = Color(0xFFF1F4FF);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Colors.indigoAccent;

  // ── Social & Semantic ─────────────────────────────────────────────────────
  static const Color googleButton = Color(0xFFFBC02D);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // ── New Home Screen Colors ──────────────────────────────────────────────────
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color darkCharcoal = Color(0xFF1A1A1A);
  static const Color electricBlue = Color(0xFF2373F4);
  static const Color vibrantPurple = Color(0xFF9564DD);
  static const Color punchPink = Color(0xFFFF0052);
  static const Color electricYellow = Color(0xFFFFD400);
}
