import 'package:flutter/material.dart';

/// ── Design System Color Tokens ──────────────────────────────────────────────
/// Curated dark-mode palette for Journey.
class AppColors {
  AppColors._();

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF14141F);
  static const Color surfaceElevated = Color(0xFF1C1C2A);

  // ── Primary Accent (vibrant teal-cyan) ────────────────────────────────────
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryMuted = Color(0x1A00D4AA); // 10% opacity

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8E8EA0);
  static const Color textMuted = Color(0xFF52526A);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A3D);
  static const Color borderFocused = Color(0xFF00D4AA);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB347);
  static const Color success = Color(0xFF00D4AA);
}
