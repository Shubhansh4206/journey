import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../widgets/pending_invites_tray.dart';

class PendingInvitesScreen extends StatelessWidget {
  const PendingInvitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        title: Text(
          'Group Invitations',
          style: GoogleFonts.poppins(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: const SafeArea(
        child: PendingInvitesTray(
          padding: EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}
