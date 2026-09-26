import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../widgets/group_manage_view.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        title: Text(
          'Squad Details',
          style: GoogleFonts.poppins(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: GroupManageView(
          groupId: groupId,
          onGroupLeft: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
