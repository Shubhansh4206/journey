import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';
import '../services/group_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();

  Map<String, dynamic>? _groupData;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _pendingInvites = [];
  bool _isLoading = true;
  bool _isLeader = false;

  final TextEditingController _emailController = TextEditingController();
  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() => _isLoading = true);

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    try {
      // Fetch group info
      final groupResult = await Supabase.instance.client
          .from('groups')
          .select()
          .eq('id', widget.groupId)
          .maybeSingle();

      // Fetch members
      final members = await _groupService.getGroupMembers(widget.groupId);

      // Fetch pending invites (leader only)
      List<Map<String, dynamic>> pendingInvites = [];
      if (groupResult != null && groupResult['leader_id'] == currentUserId) {
        pendingInvites = await _groupService.getGroupPendingInvites(widget.groupId);
      }

      if (mounted) {
        setState(() {
          _groupData = groupResult;
          _members = members;
          _pendingInvites = pendingInvites;
          _isLeader = groupResult?['leader_id'] == currentUserId;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading group: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addMember() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Enter a valid email');
      return;
    }

    setState(() => _isInviting = true);

    final user = await _groupService.findUserByEmail(email);
    if (user == null) {
      _showSnack('No user found with that email');
      setState(() => _isInviting = false);
      return;
    }

    // Check if already a member
    if (_members.any((m) => m['user_id'] == user['id'])) {
      _showSnack('Already a member');
      setState(() => _isInviting = false);
      return;
    }

    final ok = await _groupService.sendInvite(
      groupId: widget.groupId,
      userId: user['id'],
    );

    setState(() => _isInviting = false);
    if (ok) {
      _emailController.clear();
      _showSnack('Invite sent!', isSuccess: true);
      _loadGroup(); // refresh
    } else {
      _showSnack('Failed to send invite');
    }
  }

  Future<void> _removeMember(String userId) async {
    final ok = await _groupService.removeMember(widget.groupId, userId);
    if (ok) {
      _showSnack('Member removed', isSuccess: true);
      _loadGroup();
    } else {
      _showSnack('Failed to remove member');
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? AppColors.success : null,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final groupName = _groupData?['name'] ?? 'Group';

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        title: Text(
          groupName,
          style: GoogleFonts.poppins(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGroup,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Group Header Card ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.electricBlue, AppColors.vibrantPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.groups, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          groupName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_members.length} member(s) · ${_pendingInvites.length} pending invite(s)',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Add Member (Leader only) ──────────────────────────────
            if (_isLeader) ...[
              Text(
                'Add a Member',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(),
                      onSubmitted: (_) => _addMember(),
                      decoration: InputDecoration(
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
                    onTap: _isInviting ? null : _addMember,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isInviting ? AppColors.textMuted : AppColors.electricBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isInviting
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // ── Pending Invites ───────────────────────────────────────
            if (_pendingInvites.isNotEmpty && _isLeader) ...[
              Text(
                'Pending Invites',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_pendingInvites.length, (index) {
                final invite = _pendingInvites[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.electricYellow.withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.electricYellow.withValues(alpha: 0.15),
                      child: const Icon(Icons.schedule, color: AppColors.electricYellow),
                    ),
                    title: Text(
                      invite['name'] ?? invite['email'] ?? 'Unknown',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      invite['email'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricYellow,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // ── Members ──────────────────────────────────────────────
            Text(
              'Members',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 12),

            if (_members.isEmpty)
              Center(
                child: Text(
                  'No members yet',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                ),
              )
            else
              ...List.generate(_members.length, (index) {
                final member = _members[index];
                final profile = member['profiles'] as Map<String, dynamic>?;
                final name = profile?['full_name'] ?? member['email'] ?? 'Unknown';
                final email = member['email'] ?? '';
                final role = member['role'] ?? 'member';
                final isLeaderMember = role == 'leader';
                final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                final canRemove = _isLeader && !isLeaderMember && member['user_id'] != currentUserId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLeaderMember
                          ? AppColors.electricBlue.withValues(alpha: 0.15)
                          : AppColors.vibrantPurple.withValues(alpha: 0.15),
                      child: Icon(
                        isLeaderMember ? Icons.star : Icons.person,
                        color: isLeaderMember ? AppColors.electricBlue : AppColors.vibrantPurple,
                      ),
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      email,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isLeaderMember ? AppColors.electricBlue : AppColors.success)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isLeaderMember ? 'Leader' : 'Member',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isLeaderMember ? AppColors.electricBlue : AppColors.success,
                            ),
                          ),
                        ),
                        if (canRemove) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
                            onPressed: () => _removeMember(member['user_id']),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
