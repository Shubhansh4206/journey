import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

export 'custom_text_field.dart';

/// ── Primary Indigo Action Button ──────────────────────────────────────────
/// Matches user's UI theme with elevation, rounded borders, and loading state.
class CustomPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double? width;
  final double height;

  const CustomPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: onPressed != null && !loading
            ? [
                BoxShadow(
                  color: AppColors.primaryDarkBlue.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDarkBlue.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

/// ── Social OAuth Button (Google) ──────────────────────────────────────────
/// Matches user's exact yellow[700] rounded button styling with ripple effect.
class SocialIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.googleButton,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (backgroundColor ?? AppColors.googleButton)
                  .withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: icon,
      ),
    );
  }
}
