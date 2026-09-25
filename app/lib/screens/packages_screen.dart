import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: Text(
          'Packages',
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
