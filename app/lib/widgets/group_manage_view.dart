import 'package:flutter/material.dart';
import '../models/group_models.dart';
import '../services/group_service.dart';

/// A drop-in widget for managing an active group, viewing member rosters,
/// inviting members via email, renaming group, or leaving.
class GroupManageView extends StatefulWidget {
  final String groupId;
  final VoidCallback? onGroupUpdated;
  final VoidCallback? onGroupLeft;

  const GroupManageView({
    super.key,
    required this.groupId,
    this.onGroupUpdated,
    this.onGroupLeft,
  });

  @override
  State<GroupManageView> createState() => _GroupManageViewState();
}

class _GroupManageViewState extends State<GroupManageView> {
  final GroupService _groupService = GroupService();
  final TextEditingController _emailController = TextEditingController();

  GroupData? _group;
  List<GroupMemberItem> _members = [];
  bool _isLoading = true;
  bool _isInviting = false;
  String? _errorMessage;

  String? get _currentUserId => _groupService.currentUserId;
  bool get _isLeader => _group != null && _currentUserId != null && _group!.leaderId == _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final group = await _groupService.getGroupDetails(widget.groupId);
      final members = await _groupService.getGroupMemberItems(widget.groupId);

      if (mounted) {
        setState(() {
          _group = group;
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enter an email address', isError: true);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    setState(() {
      _isInviting = true;
    });

    try {
      // 1. Search user by email
      final user = await _groupService.searchUserByEmail(email);
      if (user == null) {
        _showSnackBar('User not found with email: $email', isError: true);
        return;
      }

      if (user.id == _currentUserId) {
        _showSnackBar('You are already the group leader!', isError: true);
        return;
      }

      // 2. Dispatch invitation
      await _groupService.sendInvite(
        groupId: widget.groupId,
        userId: user.id,
        groupName: _group?.name,
      );
      _emailController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        _showSnackBar('Invite sent to ${user.fullName.isNotEmpty ? user.fullName : email}!');
      }
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isInviting = false;
        });
      }
    }
  }

  Future<void> _showRenameDialog() async {
    if (_group == null) return;
    final renameController = TextEditingController(text: _group!.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename Group', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: renameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new group name',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(renameController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _group!.name) {
      try {
        await _groupService.updateGroupName(widget.groupId, newName);
        _showSnackBar('Group renamed successfully');
        _loadGroupData();
        widget.onGroupUpdated?.call();
      } catch (e) {
        _showSnackBar('Failed to rename group', isError: true);
      }
    }
  }

  Future<void> _removeMember(GroupMemberItem member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Member', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${member.fullName} from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _groupService.removeMember(widget.groupId, member.userId);
        _showSnackBar('${member.fullName} removed from group');
        _loadGroupData();
        widget.onGroupUpdated?.call();
      } catch (e) {
        _showSnackBar('Failed to remove member: $e', isError: true);
      }
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Group', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && _currentUserId != null) {
      try {
        await _groupService.removeMember(widget.groupId, _currentUserId!);
        _showSnackBar('You have left the group.');
        widget.onGroupLeft?.call();
      } catch (e) {
        _showSnackBar('Failed to leave group: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.indigo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _group == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Group not found',
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadGroupData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroupData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Group Header Card ─────────────────────────────────────
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // ── 2. Invite Section (Leader Only) ──────────────────────────
            if (_isLeader) ...[
              _buildInviteSection(),
              const SizedBox(height: 20),
            ],

            // ── 3. Roster Section ─────────────────────────────────────────
            _buildRosterSection(),
            const SizedBox(height: 24),

            // ── 4. Member Leave Action ────────────────────────────────────
            if (!_isLeader)
              _buildLeaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 0,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.indigo.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _group!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isLeader)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.indigo),
                          tooltip: 'Rename Group',
                          onPressed: _showRenameDialog,
                        ),
                    ],
                  ),
                  Text(
                    '${_members.length} Member${_members.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.indigo.shade900.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_add_alt_1_rounded, size: 20, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Invite Members via Email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the email address of a registered user to invite them to this group.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleInvite(),
                    decoration: InputDecoration(
                      hintText: 'user@example.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isInviting ? null : _handleInvite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: _isInviting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Invite',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRosterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Group Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_members.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _members.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final member = _members[index];
              final isCurrent = member.userId == _currentUserId;
              final isLeaderRole = member.isLeader;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: isLeaderRole ? Colors.amber.shade100 : Colors.indigo.shade50,
                  child: Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLeaderRole ? Colors.amber.shade900 : Colors.indigo.shade700,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.fullName + (isCurrent ? ' (You)' : ''),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLeaderRole)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Leader',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: member.email.isNotEmpty
                    ? Text(
                        member.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      )
                    : null,
                trailing: (_isLeader && !isLeaderRole)
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                        tooltip: 'Remove member',
                        onPressed: () => _removeMember(member),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveButton() {
    return OutlinedButton.icon(
      onPressed: _leaveGroup,
      icon: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
      label: const Text(
        'Leave Group',
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.red.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
