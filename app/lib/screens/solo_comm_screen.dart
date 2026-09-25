import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SoloCommScreen extends StatelessWidget {
  const SoloCommScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: Text(
          'Solo Community',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
    );
  }
}
