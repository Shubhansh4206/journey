import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';
import '../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final GroupService _groupService = GroupService();

  // Each entry: {email, userId (nullable), status: 'found' | 'not_found' | 'searching'}
  final List<Map<String, dynamic>> _invitedUsers = [];
  bool _isCreating = false;
  bool _isSearching = false;

  Future<void> _lookupAndInvite() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Please enter a valid email ID');
      return;
    }

    // Check already added
    if (_invitedUsers.any((u) => u['email'] == email)) {
      _showSnack('User already added');
      return;
    }

    // Check not self
    final currentEmail = Supabase.instance.client.auth.currentUser?.email;
    if (email == currentEmail) {
      _showSnack('You are already the leader!');
      return;
    }

    setState(() => _isSearching = true);

    final user = await _groupService.findUserByEmail(email);

    setState(() {
      _isSearching = false;
      if (user != null) {
        _invitedUsers.add({
          'email': email,
          'userId': user['id'],
          'name': user['name'] ?? email.split('@').first,
          'status': 'found',
        });
        _emailController.clear();
      } else {
        _showSnack('No user found with that email. They need to sign up first.');
      }
    });
  }

  void _removeUser(int index) {
    setState(() => _invitedUsers.removeAt(index));
  }

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      _showSnack('Please enter a group name');
      return;
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      _showSnack('Not authenticated');
      return;
    }

    setState(() => _isCreating = true);

    // 1. Create group in Supabase
    final group = await _groupService.createGroup(
      name: groupName,
      leaderId: currentUser.id,
    );

    if (group == null) {
      setState(() => _isCreating = false);
      _showSnack('Failed to create group. Check your connection.');
      return;
    }

    // 2. Send invites to all added users
    int sentCount = 0;
    for (final invitedUser in _invitedUsers) {
      if (invitedUser['userId'] != null) {
        final ok = await _groupService.sendInvite(
          groupId: group.id,
          userId: invitedUser['userId'],
        );
        if (ok) sentCount++;
      }
    }

    setState(() => _isCreating = false);

    if (mounted) {
      _showSnack(
        'Group "$groupName" created! $sentCount invite(s) sent.',
        isSuccess: true,
      );
      // Navigate to the group detail page
      context.pushReplacement('/group/${group.id}');
    }
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : null,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        title: Text(
          'Create a Group',
          style: GoogleFonts.poppins(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Group Name ─────────────────────────────────────────
                    Text(
                      'Group Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _groupNameController,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'e.g., Goa 2026 Squad',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Invite Members ────────────────────────────────────
                    Text(
                      'Invite Members',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'They\'ll receive a request to accept or decline.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email input row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(),
                            onSubmitted: (_) => _lookupAndInvite(),
                            decoration: InputDecoration(
                              labelText: 'Email ID',
                              hintText: 'friend@example.com',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _isSearching ? null : _lookupAndInvite,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isSearching
                                  ? AppColors.textMuted
                                  : AppColors.electricBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _isSearching
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.person_add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Leader (You) ──────────────────────────────────────
                    Text(
                      'Squad',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Leader card
                    _buildMemberTile(
                      name: Supabase.instance.client.auth.currentUser
                              ?.userMetadata?['display_name'] ??
                          Supabase.instance.client.auth.currentUser?.email
                              ?.split('@')
                              .first ??
                          'You',
                      email: Supabase.instance.client.auth.currentUser?.email ?? '',
                      role: 'Leader',
                      roleColor: AppColors.electricBlue,
                      trailing: const SizedBox.shrink(),
                    ),

                    // Invited members
                    ...List.generate(_invitedUsers.length, (index) {
                      final u = _invitedUsers[index];
                      return _buildMemberTile(
                        name: u['name'] ?? u['email'],
                        email: u['email'],
                        role: 'Invite Ready',
                        roleColor: AppColors.electricYellow,
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                          onPressed: () => _removeUser(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create & Send Invites',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required String name,
    required String email,
    required String role,
    required Color roleColor,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.15),
          child: Icon(
            role == 'Leader' ? Icons.star : Icons.person_outline,
            color: roleColor,
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          email,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                role,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
